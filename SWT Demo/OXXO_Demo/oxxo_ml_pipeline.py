"""
🏪 OXXO ML Pipeline - Predicción de Quiebre de Stock y Forecasting
=================================================================

Este script contiene el pipeline completo de Machine Learning para:
1. Clasificación: Predecir quiebres de stock (clases desbalanceadas)
2. Forecasting: Pronosticar ventas diarias

Se ejecuta completamente en Snowflake usando Snowpark Python.

Autor: Snowflake México
Fecha: Octubre 2025
"""

# ============================================================================
# IMPORTS
# ============================================================================
import pandas as pd
import numpy as np
from snowflake.snowpark import Session
from snowflake.snowpark.functions import col
import json

# ML Libraries
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import (
    classification_report, 
    confusion_matrix, 
    roc_auc_score,
    precision_recall_fscore_support,
    roc_curve
)
from imblearn.over_sampling import SMOTE  # Para balancear clases
import xgboost as xgb

# Visualización
import matplotlib.pyplot as plt
import seaborn as sns

# ============================================================================
# CONFIGURACIÓN DE CONEXIÓN A SNOWFLAKE
# ============================================================================

def crear_sesion_snowflake():
    """
    Crea una sesión de Snowpark conectada a Snowflake.
    
    NOTA: En producción, usar variables de entorno o secretos para credenciales.
    En Snowflake Notebook, la sesión ya está creada y se llama 'session'.
    """
    
    # Opción 1: Si estás en Snowflake Notebook, usa la sesión existente
    # session = session  # Ya existe
    
    # Opción 2: Si ejecutas localmente, crea la conexión
    connection_parameters = {
        "account": "TU_ACCOUNT",      # ej: xy12345.us-east-1
        "user": "TU_USUARIO",
        "password": "TU_PASSWORD",
        "role": "OXXO_DATA_SCIENTIST",
        "warehouse": "OXXO_ML_WH",
        "database": "OXXO_DEMO_DB",
        "schema": "RETAIL"
    }
    
    # session = Session.builder.configs(connection_parameters).create()
    # return session
    
    print("⚠️  NOTA: Configura tus credenciales de Snowflake arriba")
    print("📘 Si estás en Snowflake Notebook, la sesión 'session' ya existe")
    return None


# ============================================================================
# FUNCIONES DE UTILIDAD
# ============================================================================

def imprimir_banner(texto, emoji="🎯"):
    """Imprime un banner bonito para separar secciones"""
    print("\n" + "="*80)
    print(f"{emoji} {texto}")
    print("="*80 + "\n")


def calcular_valor_negocio(modelo, X_test, y_test, precio_promedio=20):
    """
    Calcula el valor de negocio del modelo de clasificación.
    
    Lógica:
    - Falso Negativo (predice NO quiebre, pero SÍ hubo): Pérdida de venta
    - Falso Positivo (predice SI quiebre, pero NO hubo): Sobre-inventario
    """
    from sklearn.metrics import confusion_matrix
    
    y_pred = modelo.predict(X_test)
    tn, fp, fn, tp = confusion_matrix(y_test, y_pred).ravel()
    
    # Costos de negocio
    costo_por_venta_perdida = precio_promedio * 50  # 50 unidades promedio
    costo_por_sobrecapital = precio_promedio * 30   # 30 unidades extra
    
    ahorro_ventas_perdidas = fn * costo_por_venta_perdida
    costo_sobrecapital = fp * costo_por_sobrecapital
    
    valor_neto = ahorro_ventas_perdidas - costo_sobrecapital
    
    return {
        "falsos_negativos": int(fn),
        "falsos_positivos": int(fp),
        "ahorro_ventas_perdidas_usd": round(ahorro_ventas_perdidas, 2),
        "costo_sobrecapital_usd": round(costo_sobrecapital, 2),
        "valor_neto_usd": round(valor_neto, 2)
    }


# ============================================================================
# PARTE 1: CLASIFICACIÓN - PREDECIR QUIEBRE DE STOCK
# ============================================================================

def entrenar_modelo_clasificacion(session=None, usar_snowpark=False):
    """
    Entrena un modelo de Random Forest para predecir quiebres de stock.
    
    Args:
        session: Sesión de Snowpark (opcional)
        usar_snowpark: Si True, carga datos desde Snowflake; si False, usa datos sintéticos
    """
    imprimir_banner("PARTE 1: MODELO DE CLASIFICACIÓN - QUIEBRE DE STOCK", "🎯")
    
    # -------------------------------------------------------------------------
    # 1.1 Cargar datos desde Snowflake
    # -------------------------------------------------------------------------
    print("📊 Cargando datos de entrenamiento desde Snowflake...")
    
    if usar_snowpark and session:
        # Cargar desde Snowflake con Snowpark
        df_train = session.table("TRAIN_CLASIFICACION").to_pandas()
        df_test = session.table("TEST_CLASIFICACION").to_pandas()
    else:
        # Para demo sin conexión, generar datos sintéticos
        print("⚠️  Modo sin conexión: Generando datos sintéticos...")
        from sklearn.datasets import make_classification
        
        X, y = make_classification(
            n_samples=10000,
            n_features=15,
            n_informative=10,
            n_redundant=3,
            weights=[0.9, 0.1],  # Clases desbalanceadas
            random_state=42
        )
        
        # Crear DataFrame
        feature_names = [f'feature_{i}' for i in range(15)]
        df = pd.DataFrame(X, columns=feature_names)
        df['QUIEBRE_STOCK'] = y
        
        # Split
        train_size = int(0.8 * len(df))
        df_train = df[:train_size]
        df_test = df[train_size:]
    
    print(f"✅ Datos cargados: {len(df_train)} registros de entrenamiento, {len(df_test)} de test")
    
    # -------------------------------------------------------------------------
    # 1.2 Análisis exploratorio rápido
    # -------------------------------------------------------------------------
    print("\n📈 Distribución de clases en entrenamiento:")
    print(df_train['QUIEBRE_STOCK'].value_counts(normalize=True))
    
    porcentaje_quiebre = df_train['QUIEBRE_STOCK'].mean() * 100
    print(f"\n⚠️  CLASES DESBALANCEADAS: {porcentaje_quiebre:.1f}% tienen quiebre de stock")
    
    # -------------------------------------------------------------------------
    # 1.3 Preparación de features
    # -------------------------------------------------------------------------
    print("\n🔧 Preparando features...")
    
    # Columnas a excluir del modelo
    columnas_excluir = [
        'VENTA_ID', 'FECHA', 'TIENDA_ID', 'PRODUCTO_ID', 
        'QUIEBRE_STOCK',  # Target
        'CREATED_AT'
    ]
    
    # Identificar columnas categóricas y numéricas
    if usar_snowpark:
        columnas_categoricas = [
            'ROTACION', 'CATEGORIA', 'TIPO_UBICACION', 
            'NIVEL_SOCIOECONOMICO', 'ZONA', 'TIENE_PROMOCION',
            'DIA_SEMANA', 'CLIMA'
        ]
    else:
        columnas_categoricas = []
    
    # Encoding de variables categóricas
    df_train_encoded = df_train.copy()
    df_test_encoded = df_test.copy()
    
    label_encoders = {}
    
    for col_cat in columnas_categoricas:
        if col_cat in df_train.columns:
            le = LabelEncoder()
            df_train_encoded[col_cat] = le.fit_transform(df_train[col_cat].astype(str))
            df_test_encoded[col_cat] = le.transform(df_test[col_cat].astype(str))
            label_encoders[col_cat] = le
    
    # Seleccionar features
    if usar_snowpark:
        feature_columns = [col for col in df_train_encoded.columns 
                          if col not in columnas_excluir]
    else:
        feature_columns = [col for col in df_train_encoded.columns 
                          if col != 'QUIEBRE_STOCK']
    
    X_train = df_train_encoded[feature_columns]
    y_train = df_train_encoded['QUIEBRE_STOCK'].astype(int)
    
    X_test = df_test_encoded[feature_columns]
    y_test = df_test_encoded['QUIEBRE_STOCK'].astype(int)
    
    print(f"✅ Features preparadas: {X_train.shape[1]} columnas")
    print(f"   Columnas: {', '.join(feature_columns[:10])}...")
    
    # -------------------------------------------------------------------------
    # 1.4 Balanceo de clases con SMOTE
    # -------------------------------------------------------------------------
    print("\n⚖️  Aplicando SMOTE para balancear clases...")
    
    smote = SMOTE(random_state=42)
    X_train_balanced, y_train_balanced = smote.fit_resample(X_train, y_train)
    
    print(f"   Antes de SMOTE: {len(y_train)} registros")
    print(f"   Después de SMOTE: {len(y_train_balanced)} registros")
    print(f"   Clase minoritaria balanceada: {y_train_balanced.mean()*100:.1f}%")
    
    # -------------------------------------------------------------------------
    # 1.5 Entrenamiento del modelo
    # -------------------------------------------------------------------------
    print("\n🤖 Entrenando Random Forest Classifier...")
    
    modelo_rf = RandomForestClassifier(
        n_estimators=100,
        max_depth=15,
        min_samples_split=50,
        min_samples_leaf=20,
        class_weight='balanced',  # Extra ayuda para desbalanceo
        random_state=42,
        n_jobs=-1  # Usar todos los cores
    )
    
    modelo_rf.fit(X_train_balanced, y_train_balanced)
    
    print("✅ Modelo entrenado exitosamente!")
    
    # -------------------------------------------------------------------------
    # 1.6 Evaluación del modelo
    # -------------------------------------------------------------------------
    print("\n📊 Evaluando modelo en datos de test...")
    
    y_pred = modelo_rf.predict(X_test)
    y_pred_proba = modelo_rf.predict_proba(X_test)[:, 1]
    
    # Métricas detalladas
    print("\n📋 Classification Report:")
    print(classification_report(y_test, y_pred, target_names=['No Quiebre', 'Quiebre']))
    
    # Confusion Matrix
    cm = confusion_matrix(y_test, y_pred)
    print("\n🔢 Matriz de Confusión:")
    print(f"                 Predicho NO    Predicho SI")
    print(f"Real NO          {cm[0,0]:<14} {cm[0,1]:<14}")
    print(f"Real SI          {cm[1,0]:<14} {cm[1,1]:<14}")
    
    # ROC-AUC
    roc_auc = roc_auc_score(y_test, y_pred_proba)
    print(f"\n🎯 ROC-AUC Score: {roc_auc:.4f}")
    
    # Precision, Recall, F1 por clase
    precision, recall, f1, support = precision_recall_fscore_support(
        y_test, y_pred, average=None, labels=[0, 1]
    )
    
    print("\n📈 Métricas por Clase:")
    print(f"   Clase 0 (No Quiebre) - Precision: {precision[0]:.3f}, Recall: {recall[0]:.3f}, F1: {f1[0]:.3f}")
    print(f"   Clase 1 (Quiebre)    - Precision: {precision[1]:.3f}, Recall: {recall[1]:.3f}, F1: {f1[1]:.3f}")
    
    # -------------------------------------------------------------------------
    # 1.7 Feature Importance
    # -------------------------------------------------------------------------
    print("\n🔍 Top 10 Features Más Importantes:")
    
    feature_importance = pd.DataFrame({
        'feature': feature_columns,
        'importance': modelo_rf.feature_importances_
    }).sort_values('importance', ascending=False)
    
    print(feature_importance.head(10).to_string(index=False))
    
    # -------------------------------------------------------------------------
    # 1.8 Valor de Negocio
    # -------------------------------------------------------------------------
    print("\n💰 VALOR DE NEGOCIO:")
    
    valor = calcular_valor_negocio(modelo_rf, X_test, y_test, precio_promedio=20)
    
    print(f"   Falsos Negativos (quiebres no detectados): {valor['falsos_negativos']}")
    print(f"   → Pérdida evitada: ${valor['ahorro_ventas_perdidas_usd']:,.2f} USD")
    print(f"   ")
    print(f"   Falsos Positivos (sobre-inventario): {valor['falsos_positivos']}")
    print(f"   → Costo de sobre-capital: ${valor['costo_sobrecapital_usd']:,.2f} USD")
    print(f"   ")
    print(f"   🎉 VALOR NETO MENSUAL: ${valor['valor_neto_usd']:,.2f} USD")
    
    # -------------------------------------------------------------------------
    # 1.9 Visualizaciones
    # -------------------------------------------------------------------------
    print("\n📊 Generando visualizaciones...")
    
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    
    # 1. Confusion Matrix Heatmap
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=axes[0,0])
    axes[0,0].set_title('Matriz de Confusión', fontsize=14, fontweight='bold')
    axes[0,0].set_ylabel('Real')
    axes[0,0].set_xlabel('Predicho')
    axes[0,0].set_xticklabels(['No Quiebre', 'Quiebre'])
    axes[0,0].set_yticklabels(['No Quiebre', 'Quiebre'])
    
    # 2. Feature Importance
    top_features = feature_importance.head(10)
    axes[0,1].barh(top_features['feature'], top_features['importance'], color='steelblue')
    axes[0,1].set_title('Top 10 Features Más Importantes', fontsize=14, fontweight='bold')
    axes[0,1].set_xlabel('Importancia')
    axes[0,1].invert_yaxis()
    
    # 3. ROC Curve
    fpr, tpr, thresholds = roc_curve(y_test, y_pred_proba)
    axes[1,0].plot(fpr, tpr, color='darkorange', lw=2, label=f'ROC curve (AUC = {roc_auc:.2f})')
    axes[1,0].plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
    axes[1,0].set_xlim([0.0, 1.0])
    axes[1,0].set_ylim([0.0, 1.05])
    axes[1,0].set_xlabel('False Positive Rate')
    axes[1,0].set_ylabel('True Positive Rate')
    axes[1,0].set_title('Curva ROC', fontsize=14, fontweight='bold')
    axes[1,0].legend(loc="lower right")
    axes[1,0].grid(alpha=0.3)
    
    # 4. Distribución de Probabilidades Predichas
    axes[1,1].hist(y_pred_proba[y_test == 0], bins=50, alpha=0.5, label='No Quiebre', color='green')
    axes[1,1].hist(y_pred_proba[y_test == 1], bins=50, alpha=0.5, label='Quiebre', color='red')
    axes[1,1].set_xlabel('Probabilidad Predicha')
    axes[1,1].set_ylabel('Frecuencia')
    axes[1,1].set_title('Distribución de Probabilidades', fontsize=14, fontweight='bold')
    axes[1,1].legend()
    axes[1,1].grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('oxxo_clasificacion_resultados.png', dpi=300, bbox_inches='tight')
    print("✅ Gráficas guardadas en: oxxo_clasificacion_resultados.png")
    
    # -------------------------------------------------------------------------
    # 1.10 Guardar modelo (opcional)
    # -------------------------------------------------------------------------
    print("\n💾 Guardando modelo...")
    
    import joblib
    joblib.dump(modelo_rf, 'modelo_quiebre_stock.pkl')
    joblib.dump(label_encoders, 'label_encoders.pkl')
    
    print("✅ Modelo guardado en: modelo_quiebre_stock.pkl")
    
    return modelo_rf, feature_importance, valor


# ============================================================================
# PARTE 2: FORECASTING - PREDECIR VENTAS FUTURAS
# ============================================================================

def entrenar_modelo_forecasting(session=None, usar_snowpark=False):
    """
    Entrena un modelo de XGBoost para pronosticar ventas diarias.
    """
    imprimir_banner("PARTE 2: MODELO DE FORECASTING - VENTAS DIARIAS", "📈")
    
    # -------------------------------------------------------------------------
    # 2.1 Cargar datos
    # -------------------------------------------------------------------------
    print("📊 Cargando datos de series de tiempo desde Snowflake...")
    
    if usar_snowpark and session:
        df_forecast = session.table("FEATURES_FORECASTING").to_pandas()
    else:
        # Datos sintéticos para demo
        print("⚠️  Modo sin conexión: Generando serie de tiempo sintética...")
        
        dates = pd.date_range('2025-07-01', '2025-09-15', freq='D')
        np.random.seed(42)
        
        # Generar ventas con tendencia + estacionalidad + ruido
        trend = np.linspace(50, 80, len(dates))
        seasonal = 20 * np.sin(np.arange(len(dates)) * 2 * np.pi / 7)  # Ciclo semanal
        noise = np.random.normal(0, 5, len(dates))
        ventas = trend + seasonal + noise + 100
        
        df_forecast = pd.DataFrame({
            'FECHA': dates,
            'UNIDADES_VENDIDAS_TOTAL': ventas,
            'ES_FIN_SEMANA': [1 if d.dayofweek >= 5 else 0 for d in dates],
            'ES_QUINCENA': [1 if d.day in [15, 30, 31] else 0 for d in dates],
            'TEMPERATURA_PROMEDIO': np.random.uniform(20, 35, len(dates)),
            'PRECIO_PROMEDIO': np.random.uniform(15, 25, len(dates))
        })
    
    print(f"✅ Datos cargados: {len(df_forecast)} días de historia")
    
    # -------------------------------------------------------------------------
    # 2.2 Feature Engineering para Time Series
    # -------------------------------------------------------------------------
    print("\n🔧 Creando features temporales...")
    
    df_forecast = df_forecast.sort_values('FECHA').reset_index(drop=True)
    df_forecast['FECHA'] = pd.to_datetime(df_forecast['FECHA'])
    
    # Features temporales
    df_forecast['DIA_SEMANA'] = df_forecast['FECHA'].dt.dayofweek
    df_forecast['DIA_MES'] = df_forecast['FECHA'].dt.day
    df_forecast['MES'] = df_forecast['FECHA'].dt.month
    df_forecast['SEMANA_ANO'] = df_forecast['FECHA'].dt.isocalendar().week
    
    # Lag features (ventas de días anteriores)
    for lag in [1, 7, 14]:
        df_forecast[f'VENTAS_LAG_{lag}'] = df_forecast['UNIDADES_VENDIDAS_TOTAL'].shift(lag)
    
    # Rolling features (promedios móviles)
    df_forecast['VENTAS_ROLLING_7'] = df_forecast['UNIDADES_VENDIDAS_TOTAL'].rolling(7, min_periods=1).mean()
    df_forecast['VENTAS_ROLLING_14'] = df_forecast['UNIDADES_VENDIDAS_TOTAL'].rolling(14, min_periods=1).mean()
    
    # Eliminar NaNs de los lags
    df_forecast = df_forecast.dropna()
    
    print(f"✅ Features creadas. Dataset: {df_forecast.shape}")
    
    # -------------------------------------------------------------------------
    # 2.3 Train/Test Split (temporal)
    # -------------------------------------------------------------------------
    split_date = '2025-09-01'
    train_forecast = df_forecast[df_forecast['FECHA'] < split_date]
    test_forecast = df_forecast[df_forecast['FECHA'] >= split_date]
    
    print(f"\n📊 Split temporal:")
    print(f"   Train: {len(train_forecast)} días hasta {train_forecast['FECHA'].max().date()}")
    print(f"   Test:  {len(test_forecast)} días desde {test_forecast['FECHA'].min().date()}")
    
    # Features y target
    feature_cols_forecast = [col for col in df_forecast.columns 
                            if col not in ['FECHA', 'UNIDADES_VENDIDAS_TOTAL', 'TIENDA_ID', 'PRODUCTO_ID']]
    
    X_train_ts = train_forecast[feature_cols_forecast]
    y_train_ts = train_forecast['UNIDADES_VENDIDAS_TOTAL']
    
    X_test_ts = test_forecast[feature_cols_forecast]
    y_test_ts = test_forecast['UNIDADES_VENDIDAS_TOTAL']
    
    # -------------------------------------------------------------------------
    # 2.4 Entrenamiento XGBoost
    # -------------------------------------------------------------------------
    print("\n🤖 Entrenando XGBoost Regressor...")
    
    modelo_xgb = xgb.XGBRegressor(
        n_estimators=100,
        max_depth=6,
        learning_rate=0.1,
        subsample=0.8,
        colsample_bytree=0.8,
        random_state=42,
        n_jobs=-1
    )
    
    modelo_xgb.fit(X_train_ts, y_train_ts)
    
    print("✅ Modelo XGBoost entrenado!")
    
    # -------------------------------------------------------------------------
    # 2.5 Evaluación
    # -------------------------------------------------------------------------
    print("\n📊 Evaluando modelo de forecasting...")
    
    y_pred_ts = modelo_xgb.predict(X_test_ts)
    
    from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
    
    mae = mean_absolute_error(y_test_ts, y_pred_ts)
    rmse = np.sqrt(mean_squared_error(y_test_ts, y_pred_ts))
    r2 = r2_score(y_test_ts, y_pred_ts)
    mape = np.mean(np.abs((y_test_ts - y_pred_ts) / y_test_ts)) * 100
    
    print(f"\n📈 Métricas de Forecasting:")
    print(f"   MAE (Mean Absolute Error):  {mae:.2f} unidades")
    print(f"   RMSE (Root Mean Squared Error): {rmse:.2f} unidades")
    print(f"   R² Score: {r2:.4f}")
    print(f"   MAPE (Mean Absolute % Error): {mape:.2f}%")
    
    # -------------------------------------------------------------------------
    # 2.6 Visualización
    # -------------------------------------------------------------------------
    print("\n📊 Generando visualización de forecast...")
    
    fig, axes = plt.subplots(2, 1, figsize=(15, 10))
    
    # 1. Predicciones vs Real
    axes[0].plot(test_forecast['FECHA'], y_test_ts, label='Real', marker='o', color='blue', linewidth=2)
    axes[0].plot(test_forecast['FECHA'], y_pred_ts, label='Predicción', marker='s', color='red', linestyle='--', linewidth=2)
    axes[0].set_title('Forecasting de Ventas: Real vs Predicción', fontsize=14, fontweight='bold')
    axes[0].set_xlabel('Fecha')
    axes[0].set_ylabel('Unidades Vendidas')
    axes[0].legend()
    axes[0].grid(alpha=0.3)
    axes[0].tick_params(axis='x', rotation=45)
    
    # 2. Residuales
    residuales = y_test_ts - y_pred_ts
    axes[1].scatter(y_pred_ts, residuales, alpha=0.6, color='purple')
    axes[1].axhline(y=0, color='red', linestyle='--', linewidth=2)
    axes[1].set_title('Residuales (Error de Predicción)', fontsize=14, fontweight='bold')
    axes[1].set_xlabel('Predicción')
    axes[1].set_ylabel('Residual (Real - Predicción)')
    axes[1].grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('oxxo_forecasting_resultados.png', dpi=300, bbox_inches='tight')
    print("✅ Gráficas guardadas en: oxxo_forecasting_resultados.png")
    
    # -------------------------------------------------------------------------
    # 2.7 Feature Importance
    # -------------------------------------------------------------------------
    print("\n🔍 Top 10 Features para Forecasting:")
    
    feature_importance_ts = pd.DataFrame({
        'feature': feature_cols_forecast,
        'importance': modelo_xgb.feature_importances_
    }).sort_values('importance', ascending=False)
    
    print(feature_importance_ts.head(10).to_string(index=False))
    
    # -------------------------------------------------------------------------
    # 2.8 Guardar modelo
    # -------------------------------------------------------------------------
    print("\n💾 Guardando modelo de forecasting...")
    
    import joblib
    joblib.dump(modelo_xgb, 'modelo_forecasting_ventas.pkl')
    print("✅ Modelo guardado en: modelo_forecasting_ventas.pkl")
    
    return modelo_xgb, feature_importance_ts, {'mae': mae, 'rmse': rmse, 'r2': r2, 'mape': mape}


# ============================================================================
# MAIN - EJECUTAR EL PIPELINE COMPLETO
# ============================================================================

def main():
    """
    Ejecuta el pipeline completo de ML para OXXO.
    """
    imprimir_banner("🏪 OXXO ML PIPELINE - DEMO COMPLETO", "🚀")
    
    print("""
    Este pipeline demuestra:
    1. 🎯 Clasificación con clases desbalanceadas (SMOTE)
    2. 📈 Time Series Forecasting con features externos
    3. 💰 Cálculo de valor de negocio
    4. 📊 Visualizaciones profesionales
    5. 💾 Persistencia de modelos
    
    ⏱️  Tiempo estimado: 3-5 minutos
    """)
    
    # Crear sesión (comentar si estás en Notebook)
    # session = crear_sesion_snowflake()
    
    # -------------------------------------------------------------------------
    # PARTE 1: Clasificación
    # -------------------------------------------------------------------------
    modelo_clasificacion, feature_imp_cls, valor_negocio = entrenar_modelo_clasificacion(
        session=None, 
        usar_snowpark=False  # Cambiar a True si estás conectado a Snowflake
    )
    
    # -------------------------------------------------------------------------
    # PARTE 2: Forecasting
    # -------------------------------------------------------------------------
    modelo_forecasting, feature_imp_ts, metricas_ts = entrenar_modelo_forecasting(
        session=None,
        usar_snowpark=False  # Cambiar a True si estás conectado a Snowflake
    )
    
    # -------------------------------------------------------------------------
    # RESUMEN FINAL
    # -------------------------------------------------------------------------
    imprimir_banner("🎉 PIPELINE COMPLETADO - RESUMEN EJECUTIVO", "✅")
    
    print(f"""
    📊 MODELO DE CLASIFICACIÓN (Quiebre de Stock):
       - Algoritmo: Random Forest con SMOTE
       - ROC-AUC: Ver reporte arriba
       - Valor de Negocio: ${valor_negocio['valor_neto_usd']:,.2f} USD/mes
       - Top Feature: {feature_imp_cls.iloc[0]['feature']}
    
    📈 MODELO DE FORECASTING (Ventas Diarias):
       - Algoritmo: XGBoost Regressor
       - MAE: {metricas_ts['mae']:.2f} unidades
       - MAPE: {metricas_ts['mape']:.2f}%
       - R²: {metricas_ts['r2']:.4f}
    
    💾 ARCHIVOS GENERADOS:
       - modelo_quiebre_stock.pkl
       - modelo_forecasting_ventas.pkl
       - label_encoders.pkl
       - oxxo_clasificacion_resultados.png
       - oxxo_forecasting_resultados.png
    
    🚀 PRÓXIMOS PASOS:
       1. Subir modelos a Snowflake Stage
       2. Crear Stored Procedure para inferencia
       3. Programar reentrenamiento con TASKS
       4. Integrar con Streamlit para dashboard
    
    💡 PARA PRODUCCIÓN:
       - Cambiar usar_snowpark=True
       - Configurar credenciales de Snowflake
       - Agregar validación cruzada
       - Implementar model monitoring
       - Agregar alerts de data drift
    """)
    
    print("="*80)
    print("🏪 Demo completado exitosamente!")
    print("="*80)


# ============================================================================
# EJECUTAR
# ============================================================================

if __name__ == "__main__":
    main()
    
    # Si estás en Snowflake Notebook, ejecuta las funciones individualmente:
    # modelo_cls, _, _ = entrenar_modelo_clasificacion(session=session, usar_snowpark=True)
    # modelo_ts, _, _ = entrenar_modelo_forecasting(session=session, usar_snowpark=True)

