# ============================================================================
# 📓 OXXO ML - Notebook de Ejemplo para Snowflake
# ============================================================================
# Este notebook está diseñado para ejecutarse en Snowflake Notebooks.
# Copia y pega cada celda en orden.
# ============================================================================

# ============================================================================
# CELDA 1: Importar librerías
# ============================================================================
import pandas as pd
import numpy as np
from snowflake.snowpark import Session
from snowflake.snowpark.functions import col, lit
import matplotlib.pyplot as plt
import seaborn as sns

print("✅ Librerías importadas correctamente")
print(f"📦 Pandas version: {pd.__version__}")
print(f"🔢 NumPy version: {np.__version__}")

# ============================================================================
# CELDA 2: Configurar contexto (solo si ejecutas localmente)
# ============================================================================
# En Snowflake Notebook, la sesión 'session' ya está creada
# Si ejecutas localmente, descomenta y configura:

"""
connection_parameters = {
    "account": "TU_ACCOUNT",
    "user": "TU_USUARIO", 
    "password": "TU_PASSWORD",
    "role": "OXXO_DATA_SCIENTIST",
    "warehouse": "OXXO_ML_WH",
    "database": "OXXO_DEMO_DB",
    "schema": "RETAIL"
}

session = Session.builder.configs(connection_parameters).create()
"""

# En Snowflake Notebook:
print("✅ Sesión de Snowpark lista")
print(f"📍 Warehouse actual: {session.get_current_warehouse()}")
print(f"📁 Database actual: {session.get_current_database()}")
print(f"📂 Schema actual: {session.get_current_schema()}")

# ============================================================================
# CELDA 3: Explorar datos
# ============================================================================
print("📊 Explorando datos de ventas históricas...")

# Cargar tabla como Snowpark DataFrame
df_ventas_sp = session.table("VENTAS_HISTORICAS")

# Mostrar esquema
print("\n🔍 Esquema de la tabla:")
df_ventas_sp.printSchema()

# Contar registros (ejecuta en Snowflake)
print(f"\n📈 Total de registros: {df_ventas_sp.count():,}")

# Primeras filas
print("\n👀 Primeras 10 filas:")
df_ventas_sp.show(10)

# ============================================================================
# CELDA 4: Análisis exploratorio con Pandas
# ============================================================================
print("🔬 Convirtiendo a Pandas para análisis...")

# Convertir una muestra a Pandas (cuidado con datasets grandes)
df_ventas_pd = df_ventas_sp.sample(0.1).to_pandas()  # 10% de muestra

print(f"✅ Muestra de {len(df_ventas_pd):,} registros en Pandas")

# Estadísticas descriptivas
print("\n📊 Estadísticas descriptivas:")
print(df_ventas_pd[['UNIDADES_VENDIDAS', 'PRECIO_DIA', 'TEMPERATURA_CELSIUS']].describe())

# Distribución de clases
print("\n⚖️ Distribución de clases (QUIEBRE_STOCK):")
print(df_ventas_pd['QUIEBRE_STOCK'].value_counts(normalize=True) * 100)

# Datos faltantes
print("\n🔍 Datos faltantes por columna:")
print(df_ventas_pd.isnull().sum())

# ============================================================================
# CELDA 5: Visualizaciones exploratorias
# ============================================================================
print("📊 Generando visualizaciones exploratorias...")

fig, axes = plt.subplots(2, 2, figsize=(15, 10))

# 1. Distribución de ventas
axes[0, 0].hist(df_ventas_pd['UNIDADES_VENDIDAS'], bins=50, color='steelblue', edgecolor='black')
axes[0, 0].set_title('Distribución de Unidades Vendidas', fontsize=14, fontweight='bold')
axes[0, 0].set_xlabel('Unidades')
axes[0, 0].set_ylabel('Frecuencia')
axes[0, 0].grid(alpha=0.3)

# 2. Quiebres por día de semana
quiebres_dia = df_ventas_pd.groupby('DIA_SEMANA')['QUIEBRE_STOCK'].mean() * 100
dias_orden = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']
quiebres_dia = quiebres_dia.reindex(dias_orden)
axes[0, 1].bar(range(len(quiebres_dia)), quiebres_dia.values, color='coral')
axes[0, 1].set_title('Tasa de Quiebre por Día de Semana', fontsize=14, fontweight='bold')
axes[0, 1].set_xlabel('Día')
axes[0, 1].set_ylabel('% de Quiebres')
axes[0, 1].set_xticks(range(len(dias_orden)))
axes[0, 1].set_xticklabels(dias_orden, rotation=45, ha='right')
axes[0, 1].grid(alpha=0.3, axis='y')

# 3. Temperatura vs Ventas
axes[1, 0].scatter(df_ventas_pd['TEMPERATURA_CELSIUS'], 
                   df_ventas_pd['UNIDADES_VENDIDAS'], 
                   alpha=0.3, color='green')
axes[1, 0].set_title('Temperatura vs Ventas', fontsize=14, fontweight='bold')
axes[1, 0].set_xlabel('Temperatura (°C)')
axes[1, 0].set_ylabel('Unidades Vendidas')
axes[1, 0].grid(alpha=0.3)

# 4. Matriz de correlación (para columnas numéricas)
corr_cols = ['UNIDADES_VENDIDAS', 'PRECIO_DIA', 'TEMPERATURA_CELSIUS', 'DESCUENTO_PORCENTAJE']
corr_data = df_ventas_pd[corr_cols].dropna()
corr_matrix = corr_data.corr()
sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', center=0, ax=axes[1, 1], 
            fmt='.2f', square=True, linewidths=1)
axes[1, 1].set_title('Matriz de Correlación', fontsize=14, fontweight='bold')

plt.tight_layout()
plt.show()

print("✅ Visualizaciones generadas")

# ============================================================================
# CELDA 6: Cargar datos de entrenamiento
# ============================================================================
print("🎯 Cargando datos de entrenamiento y test...")

# Cargar tablas de features
df_train_sp = session.table("TRAIN_CLASIFICACION")
df_test_sp = session.table("TEST_CLASIFICACION")

print(f"📚 Train: {df_train_sp.count():,} registros")
print(f"📖 Test:  {df_test_sp.count():,} registros")

# Convertir a Pandas para ML
df_train = df_train_sp.to_pandas()
df_test = df_test_sp.to_pandas()

print("✅ Datos cargados en memoria")

# ============================================================================
# CELDA 7: Preparar features para ML
# ============================================================================
print("🔧 Preparando features para Machine Learning...")

from sklearn.preprocessing import LabelEncoder

# Columnas a excluir
columnas_excluir = ['VENTA_ID', 'FECHA', 'TIENDA_ID', 'PRODUCTO_ID', 'QUIEBRE_STOCK', 'CREATED_AT']

# Columnas categóricas a encodear
columnas_categoricas = ['ROTACION', 'CATEGORIA', 'TIPO_UBICACION', 'NIVEL_SOCIOECONOMICO', 
                       'ZONA', 'TIENE_PROMOCION', 'DIA_SEMANA', 'CLIMA']

# Label Encoding
df_train_encoded = df_train.copy()
df_test_encoded = df_test.copy()

label_encoders = {}

for col in columnas_categoricas:
    if col in df_train.columns:
        le = LabelEncoder()
        df_train_encoded[col] = le.fit_transform(df_train[col].astype(str))
        df_test_encoded[col] = le.transform(df_test[col].astype(str))
        label_encoders[col] = le
        print(f"  ✓ Encoded: {col}")

# Seleccionar features
feature_columns = [col for col in df_train_encoded.columns if col not in columnas_excluir]

X_train = df_train_encoded[feature_columns]
y_train = df_train_encoded['QUIEBRE_STOCK'].astype(int)

X_test = df_test_encoded[feature_columns]
y_test = df_test_encoded['QUIEBRE_STOCK'].astype(int)

print(f"\n✅ Features preparadas: {len(feature_columns)} columnas")
print(f"   Dimensión X_train: {X_train.shape}")
print(f"   Dimensión X_test:  {X_test.shape}")

# ============================================================================
# CELDA 8: Balanceo de clases con SMOTE
# ============================================================================
print("⚖️ Aplicando SMOTE para balancear clases...")

from imblearn.over_sampling import SMOTE

# Verificar desbalanceo inicial
print(f"\n📊 Antes de SMOTE:")
print(f"   Clase 0 (No Quiebre): {(y_train == 0).sum():,} ({(y_train == 0).mean()*100:.1f}%)")
print(f"   Clase 1 (Quiebre):    {(y_train == 1).sum():,} ({(y_train == 1).mean()*100:.1f}%)")

# Aplicar SMOTE
smote = SMOTE(random_state=42, k_neighbors=5)
X_train_balanced, y_train_balanced = smote.fit_resample(X_train, y_train)

print(f"\n📊 Después de SMOTE:")
print(f"   Clase 0 (No Quiebre): {(y_train_balanced == 0).sum():,} ({(y_train_balanced == 0).mean()*100:.1f}%)")
print(f"   Clase 1 (Quiebre):    {(y_train_balanced == 1).sum():,} ({(y_train_balanced == 1).mean()*100:.1f}%)")

print(f"\n✅ Dataset balanceado: {len(y_train_balanced):,} registros totales")

# ============================================================================
# CELDA 9: Entrenar Random Forest
# ============================================================================
print("🤖 Entrenando Random Forest Classifier...")

from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score, roc_curve
import time

# Configurar modelo
modelo_rf = RandomForestClassifier(
    n_estimators=100,
    max_depth=15,
    min_samples_split=50,
    min_samples_leaf=20,
    class_weight='balanced',
    random_state=42,
    n_jobs=-1,
    verbose=1
)

# Entrenar
inicio = time.time()
print("⏳ Entrenando modelo...")
modelo_rf.fit(X_train_balanced, y_train_balanced)
tiempo_entrenamiento = time.time() - inicio

print(f"\n✅ Modelo entrenado en {tiempo_entrenamiento:.2f} segundos")
print(f"   Número de árboles: {modelo_rf.n_estimators}")
print(f"   Features usadas: {modelo_rf.n_features_in_}")

# ============================================================================
# CELDA 10: Evaluar modelo
# ============================================================================
print("📊 Evaluando modelo en datos de test...")

# Predicciones
y_pred = modelo_rf.predict(X_test)
y_pred_proba = modelo_rf.predict_proba(X_test)[:, 1]

# Classification Report
print("\n📋 Classification Report:")
print(classification_report(y_test, y_pred, target_names=['No Quiebre', 'Quiebre'], digits=3))

# Confusion Matrix
cm = confusion_matrix(y_test, y_pred)
print("\n🔢 Matriz de Confusión:")
print(pd.DataFrame(cm, 
                  index=['Real: No Quiebre', 'Real: Quiebre'],
                  columns=['Pred: No Quiebre', 'Pred: Quiebre']))

# ROC-AUC
roc_auc = roc_auc_score(y_test, y_pred_proba)
print(f"\n🎯 ROC-AUC Score: {roc_auc:.4f}")

# Desglose de la confusion matrix
tn, fp, fn, tp = cm.ravel()
print(f"\n📊 Desglose:")
print(f"   True Negatives (correcto no quiebre):  {tn:,}")
print(f"   False Positives (falsa alarma):        {fp:,}")
print(f"   False Negatives (quiebre no detectado): {fn:,}")
print(f"   True Positives (quiebre detectado):    {tp:,}")

# ============================================================================
# CELDA 11: Feature Importance
# ============================================================================
print("🔍 Analizando importancia de features...")

# Crear DataFrame de feature importance
feature_importance = pd.DataFrame({
    'feature': feature_columns,
    'importance': modelo_rf.feature_importances_
}).sort_values('importance', ascending=False)

print("\n🏆 Top 15 Features Más Importantes:")
print(feature_importance.head(15).to_string(index=False))

# Visualización
fig, ax = plt.subplots(figsize=(10, 8))
top_n = 15
top_features = feature_importance.head(top_n)
ax.barh(range(top_n), top_features['importance'].values, color='steelblue')
ax.set_yticks(range(top_n))
ax.set_yticklabels(top_features['feature'].values)
ax.set_xlabel('Importancia')
ax.set_title(f'Top {top_n} Features Más Importantes', fontsize=14, fontweight='bold')
ax.invert_yaxis()
ax.grid(alpha=0.3, axis='x')
plt.tight_layout()
plt.show()

# ============================================================================
# CELDA 12: Curva ROC
# ============================================================================
print("📈 Generando Curva ROC...")

from sklearn.metrics import roc_curve, auc

fpr, tpr, thresholds = roc_curve(y_test, y_pred_proba)
roc_auc = auc(fpr, tpr)

fig, ax = plt.subplots(figsize=(8, 8))
ax.plot(fpr, tpr, color='darkorange', lw=2, label=f'ROC curve (AUC = {roc_auc:.3f})')
ax.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--', label='Random Classifier')
ax.set_xlim([0.0, 1.0])
ax.set_ylim([0.0, 1.05])
ax.set_xlabel('False Positive Rate', fontsize=12)
ax.set_ylabel('True Positive Rate', fontsize=12)
ax.set_title('Receiver Operating Characteristic (ROC) Curve', fontsize=14, fontweight='bold')
ax.legend(loc="lower right", fontsize=12)
ax.grid(alpha=0.3)
plt.tight_layout()
plt.show()

print(f"✅ ROC-AUC Score: {roc_auc:.4f}")

# ============================================================================
# CELDA 13: Valor de Negocio
# ============================================================================
print("💰 Calculando valor de negocio del modelo...")

# Parámetros de negocio
precio_promedio_producto = 20  # MXN
unidades_promedio_por_quiebre = 50
unidades_sobrecapital = 30

# Costos
costo_venta_perdida = precio_promedio_producto * unidades_promedio_por_quiebre
costo_sobrecapital = precio_promedio_producto * unidades_sobrecapital

# Calcular impacto
tn, fp, fn, tp = cm.ravel()

# Valor generado al prevenir ventas perdidas
valor_prevenir_ventas = fn * costo_venta_perdida

# Costo de sobre-inventariar (falsos positivos)
costo_fp = fp * costo_sobrecapital

# Valor neto
valor_neto = valor_prevenir_ventas - costo_fp

print(f"\n💼 ANÁLISIS DE VALOR DE NEGOCIO:")
print(f"   {'='*60}")
print(f"   Falsos Negativos (quiebres no detectados): {fn:,}")
print(f"   → Valor de prevenir ventas perdidas: ${valor_prevenir_ventas:,.2f} MXN")
print(f"")
print(f"   Falsos Positivos (sobre-inventario): {fp:,}")
print(f"   → Costo de capital inmovilizado: ${costo_fp:,.2f} MXN")
print(f"   {'='*60}")
print(f"   🎉 VALOR NETO (por período test): ${valor_neto:,.2f} MXN")
print(f"")

# Proyección mensual (el test es ~15 días)
dias_en_test = (df_test['FECHA'].max() - df_test['FECHA'].min()).days
valor_mensual = valor_neto * (30 / dias_en_test)
valor_anual = valor_mensual * 12

print(f"   📊 Proyección:")
print(f"   Valor mensual estimado: ${valor_mensual:,.2f} MXN (~${valor_mensual/20:,.2f} USD)")
print(f"   Valor anual estimado:   ${valor_anual:,.2f} MXN (~${valor_anual/20:,.2f} USD)")

# ============================================================================
# CELDA 14: Guardar modelo
# ============================================================================
print("💾 Guardando modelo y artefactos...")

import joblib

# Guardar modelo
joblib.dump(modelo_rf, 'modelo_quiebre_stock_rf.pkl')
print("✅ Modelo guardado: modelo_quiebre_stock_rf.pkl")

# Guardar label encoders
joblib.dump(label_encoders, 'label_encoders.pkl')
print("✅ Label encoders guardados: label_encoders.pkl")

# Guardar lista de features
with open('feature_names.txt', 'w') as f:
    for feat in feature_columns:
        f.write(f"{feat}\n")
print("✅ Feature names guardados: feature_names.txt")

# Guardar métricas
metricas = {
    'roc_auc': roc_auc,
    'precision': tp / (tp + fp) if (tp + fp) > 0 else 0,
    'recall': tp / (tp + fn) if (tp + fn) > 0 else 0,
    'f1': 2 * tp / (2 * tp + fp + fn) if (2 * tp + fp + fn) > 0 else 0,
    'valor_mensual_mxn': valor_mensual,
    'valor_anual_mxn': valor_anual
}

import json
with open('metricas_modelo.json', 'w') as f:
    json.dump(metricas, f, indent=2)
print("✅ Métricas guardadas: metricas_modelo.json")

# ============================================================================
# CELDA 15: Ejemplo de predicción individual
# ============================================================================
print("🔮 Ejemplo de predicción individual...")

# Tomar un ejemplo del test set
ejemplo_idx = 100
ejemplo = X_test.iloc[ejemplo_idx:ejemplo_idx+1]
ejemplo_real = y_test.iloc[ejemplo_idx]

# Predecir
pred_proba = modelo_rf.predict_proba(ejemplo)[0]
pred_clase = modelo_rf.predict(ejemplo)[0]

print(f"\n📦 EJEMPLO DE PREDICCIÓN:")
print(f"   {'='*60}")
print(f"   Valor real: {'QUIEBRE' if ejemplo_real == 1 else 'NO QUIEBRE'}")
print(f"   Predicción: {'QUIEBRE' if pred_clase == 1 else 'NO QUIEBRE'}")
print(f"   {'='*60}")
print(f"   Probabilidad de NO QUIEBRE: {pred_proba[0]*100:.2f}%")
print(f"   Probabilidad de QUIEBRE:    {pred_proba[1]*100:.2f}%")
print(f"")

if pred_clase == ejemplo_real:
    print("   ✅ Predicción CORRECTA")
else:
    print("   ❌ Predicción INCORRECTA")

# Mostrar features del ejemplo
print(f"\n   Features del ejemplo:")
for feat, val in ejemplo.iloc[0].items():
    if pd.notna(val):
        print(f"   - {feat}: {val}")

# ============================================================================
# RESUMEN FINAL
# ============================================================================
print("\n" + "="*80)
print("🎉 PIPELINE COMPLETADO EXITOSAMENTE")
print("="*80)
print(f"""
📊 RESUMEN EJECUTIVO:

✅ DATOS:
   - Registros de entrenamiento: {len(X_train):,}
   - Registros de test: {len(X_test):,}
   - Features utilizadas: {len(feature_columns)}

✅ MODELO:
   - Algoritmo: Random Forest (100 árboles)
   - Balanceo: SMOTE
   - ROC-AUC: {roc_auc:.4f}
   - Tiempo de entrenamiento: {tiempo_entrenamiento:.2f}s

✅ VALOR DE NEGOCIO:
   - Valor mensual: ${valor_mensual:,.2f} MXN
   - Valor anual: ${valor_anual:,.2f} MXN
   - ROI estimado: {(valor_anual / 100):.0f}x (asumiendo costo operación $100 MXN/mes)

✅ ARCHIVOS GENERADOS:
   - modelo_quiebre_stock_rf.pkl
   - label_encoders.pkl
   - feature_names.txt
   - metricas_modelo.json

🚀 PRÓXIMOS PASOS:
   1. Subir modelo a Snowflake Stage
   2. Crear UDF para inferencia en Snowflake
   3. Programar reentrenamiento con TASKS
   4. Integrar con sistema de reabastecimiento
   5. Implementar monitoring de drift

💡 PARA PRODUCCIÓN:
   - Validación cruzada para hiperparámetros
   - Monitoring de performance en tiempo real
   - A/B testing del modelo
   - Documentación de model card
""")
print("="*80)

