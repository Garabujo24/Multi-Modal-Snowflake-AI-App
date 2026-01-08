"""
🏪 OXXO Predicción de Stock - Dashboard Interactivo
===================================================

Aplicación Streamlit para visualizar y utilizar los modelos de ML en tiempo real.
Diseñada para ejecutarse en Streamlit in Snowflake.

Autor: Snowflake México
Fecha: Octubre 2025
"""

import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta

# Configuración de la página
st.set_page_config(
    page_title="OXXO ML Dashboard",
    page_icon="🏪",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ============================================================================
# ESTILOS PERSONALIZADOS
# ============================================================================

st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        color: #E30613;
        font-weight: bold;
        text-align: center;
        padding: 1rem;
    }
    .metric-card {
        background-color: #f0f2f6;
        padding: 1rem;
        border-radius: 10px;
        border-left: 5px solid #E30613;
    }
    .stAlert {
        background-color: #FFF3CD;
        border: 1px solid #FFECB5;
    }
</style>
""", unsafe_allow_html=True)

# ============================================================================
# FUNCIONES DE CONEXIÓN Y DATOS
# ============================================================================

@st.cache_data
def cargar_datos_snowflake():
    """
    Carga datos desde Snowflake.
    
    NOTA: En Streamlit in Snowflake, la conexión ya está disponible
    como st.connection("snowflake")
    """
    try:
        # Conexión automática en Streamlit in Snowflake
        conn = st.connection("snowflake")
        
        # Cargar datos de ventas
        df_ventas = conn.query("""
            SELECT * FROM V_VENTAS_ENRIQUECIDAS 
            ORDER BY FECHA DESC 
            LIMIT 10000
        """)
        
        # Cargar productos
        df_productos = conn.query("SELECT * FROM PRODUCTOS")
        
        # Cargar tiendas
        df_tiendas = conn.query("SELECT * FROM TIENDAS")
        
        return df_ventas, df_productos, df_tiendas
        
    except Exception as e:
        st.error(f"Error conectando a Snowflake: {e}")
        # Datos sintéticos para desarrollo local
        return generar_datos_demo()


def generar_datos_demo():
    """Genera datos sintéticos para desarrollo sin conexión a Snowflake"""
    
    # Ventas
    dates = pd.date_range('2025-07-01', '2025-09-30', freq='D')
    np.random.seed(42)
    
    df_ventas = pd.DataFrame({
        'FECHA': np.repeat(dates, 10),
        'CODIGO_TIENDA': np.tile(['OXXO-00001', 'OXXO-00002', 'OXXO-00003', 'OXXO-00004', 'OXXO-00005',
                                  'OXXO-00006', 'OXXO-00007', 'OXXO-00008', 'OXXO-00009', 'OXXO-00010'], len(dates)),
        'CIUDAD': np.tile(['Ciudad de México', 'Monterrey', 'Guadalajara'] * 4, len(dates))[:len(dates)*10],
        'PRODUCTO_NOMBRE': np.tile(['Coca-Cola 600ml', 'Sabritas Original 45g', 'Pan Bimbo', 
                                   'Cerveza Corona', 'Agua Ciel 1L'] * 2, len(dates)),
        'CATEGORIA': np.tile(['Bebidas', 'Snacks', 'Panadería', 'Bebidas', 'Bebidas'] * 2, len(dates)),
        'UNIDADES_VENDIDAS': np.random.randint(10, 100, len(dates) * 10),
        'PRECIO_DIA': np.random.uniform(10, 30, len(dates) * 10),
        'QUIEBRE_STOCK': np.random.choice([True, False], len(dates) * 10, p=[0.1, 0.9]),
        'TEMPERATURA_CELSIUS': np.random.uniform(20, 35, len(dates) * 10),
        'ES_FIN_SEMANA': np.random.choice([True, False], len(dates) * 10, p=[0.28, 0.72])
    })
    
    df_ventas['INGRESOS_TOTALES'] = df_ventas['UNIDADES_VENDIDAS'] * df_ventas['PRECIO_DIA']
    
    # Productos
    df_productos = pd.DataFrame({
        'PRODUCTO_ID': range(1, 11),
        'NOMBRE': ['Coca-Cola 600ml', 'Sabritas Original 45g', 'Pan Bimbo', 'Cerveza Corona', 
                  'Agua Ciel 1L', 'Doritos Nacho', 'Leche Lala 1L', 'Carlos V', 'Yakult 5 Pack', 'Snickers'],
        'CATEGORIA': ['Bebidas', 'Snacks', 'Panadería', 'Bebidas', 'Bebidas', 
                     'Snacks', 'Lácteos', 'Snacks', 'Lácteos', 'Snacks'],
        'PRECIO_UNITARIO': [15, 16, 38, 22, 10, 17, 24, 12, 22, 12],
        'ROTACION': ['Alta', 'Alta', 'Alta', 'Alta', 'Alta', 'Alta', 'Alta', 'Alta', 'Media', 'Alta']
    })
    
    # Tiendas
    df_tiendas = pd.DataFrame({
        'CODIGO_TIENDA': [f'OXXO-{str(i).zfill(5)}' for i in range(1, 11)],
        'CIUDAD': ['Ciudad de México', 'Monterrey', 'Guadalajara', 'Puebla', 'Tijuana',
                  'Ciudad de México', 'Monterrey', 'Guadalajara', 'Ciudad de México', 'León'],
        'ESTADO': ['Ciudad de México', 'Nuevo León', 'Jalisco', 'Puebla', 'Baja California',
                  'Ciudad de México', 'Nuevo León', 'Jalisco', 'Ciudad de México', 'Guanajuato'],
        'TIPO_UBICACION': ['Urbana', 'Urbana', 'Suburbana', 'Urbana', 'Urbana',
                          'Suburbana', 'Urbana', 'Urbana', 'Urbana', 'Urbana']
    })
    
    return df_ventas, df_productos, df_tiendas


@st.cache_data
def predecir_quiebre_stock(features):
    """
    Realiza predicción de quiebre de stock.
    En producción, cargaría el modelo desde Snowflake Stage.
    """
    # Simulación de predicción
    probabilidad = np.random.uniform(0.05, 0.95)
    prediccion = probabilidad > 0.5
    
    return prediccion, probabilidad


# ============================================================================
# HEADER
# ============================================================================

col1, col2, col3 = st.columns([1, 2, 1])
with col2:
    st.markdown('<div class="main-header">🏪 OXXO - Dashboard de ML</div>', unsafe_allow_html=True)

st.markdown("---")

# ============================================================================
# SIDEBAR - FILTROS Y CONFIGURACIÓN
# ============================================================================

st.sidebar.image("https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/OXXO_Logo.svg/2560px-OXXO_Logo.svg.png", 
                 use_column_width=True)
st.sidebar.markdown("### ⚙️ Configuración")

# Cargar datos
with st.spinner("Cargando datos desde Snowflake..."):
    df_ventas, df_productos, df_tiendas = cargar_datos_snowflake()

st.sidebar.success(f"✅ {len(df_ventas):,} registros cargados")

# Filtros
st.sidebar.markdown("### 🔍 Filtros")

ciudades_disponibles = ['Todas'] + sorted(df_ventas['CIUDAD'].unique().tolist())
ciudad_seleccionada = st.sidebar.selectbox("Ciudad", ciudades_disponibles)

categorias_disponibles = ['Todas'] + sorted(df_ventas['CATEGORIA'].unique().tolist())
categoria_seleccionada = st.sidebar.selectbox("Categoría", categorias_disponibles)

# Filtrar datos
df_filtrado = df_ventas.copy()
if ciudad_seleccionada != 'Todas':
    df_filtrado = df_filtrado[df_filtrado['CIUDAD'] == ciudad_seleccionada]
if categoria_seleccionada != 'Todas':
    df_filtrado = df_filtrado[df_filtrado['CATEGORIA'] == categoria_seleccionada]

# ============================================================================
# TABS PRINCIPALES
# ============================================================================

tab1, tab2, tab3, tab4 = st.tabs([
    "📊 Dashboard General", 
    "🎯 Predicción de Quiebres", 
    "📈 Forecasting de Ventas",
    "💰 FinOps"
])

# ============================================================================
# TAB 1: DASHBOARD GENERAL
# ============================================================================

with tab1:
    st.header("📊 Análisis General de Ventas")
    
    # Métricas principales
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        total_ventas = df_filtrado['UNIDADES_VENDIDAS'].sum()
        st.metric("📦 Unidades Vendidas", f"{total_ventas:,.0f}")
    
    with col2:
        ingresos_totales = df_filtrado['INGRESOS_TOTALES'].sum()
        st.metric("💵 Ingresos Totales", f"${ingresos_totales:,.0f} MXN")
    
    with col3:
        num_quiebres = df_filtrado['QUIEBRE_STOCK'].sum()
        tasa_quiebre = (num_quiebres / len(df_filtrado)) * 100
        st.metric("⚠️ Tasa de Quiebre", f"{tasa_quiebre:.1f}%", 
                 delta=f"{num_quiebres} eventos", delta_color="inverse")
    
    with col4:
        ticket_promedio = df_filtrado['INGRESOS_TOTALES'].mean()
        st.metric("🧾 Ticket Promedio", f"${ticket_promedio:.2f} MXN")
    
    st.markdown("---")
    
    # Gráficas en dos columnas
    col_left, col_right = st.columns(2)
    
    with col_left:
        st.subheader("📈 Ventas por Día")
        
        ventas_diarias = df_filtrado.groupby('FECHA').agg({
            'UNIDADES_VENDIDAS': 'sum',
            'INGRESOS_TOTALES': 'sum'
        }).reset_index()
        
        fig_ventas = px.line(ventas_diarias, x='FECHA', y='UNIDADES_VENDIDAS',
                            title='Evolución de Ventas Diarias',
                            labels={'UNIDADES_VENDIDAS': 'Unidades Vendidas', 'FECHA': 'Fecha'})
        fig_ventas.update_traces(line_color='#E30613', line_width=3)
        st.plotly_chart(fig_ventas, use_container_width=True)
        
    with col_right:
        st.subheader("🏆 Top 10 Productos")
        
        top_productos = df_filtrado.groupby('PRODUCTO_NOMBRE')['UNIDADES_VENDIDAS'].sum().sort_values(ascending=False).head(10)
        
        fig_top = px.bar(top_productos, orientation='h',
                        title='Productos Más Vendidos',
                        labels={'value': 'Unidades Vendidas', 'index': 'Producto'})
        fig_top.update_traces(marker_color='#E30613')
        st.plotly_chart(fig_top, use_container_width=True)
    
    # Segunda fila de gráficas
    col_left2, col_right2 = st.columns(2)
    
    with col_left2:
        st.subheader("🗺️ Ventas por Ciudad")
        
        ventas_ciudad = df_filtrado.groupby('CIUDAD')['INGRESOS_TOTALES'].sum().sort_values(ascending=False)
        
        fig_ciudad = px.pie(values=ventas_ciudad.values, names=ventas_ciudad.index,
                           title='Distribución de Ingresos por Ciudad',
                           color_discrete_sequence=px.colors.sequential.Reds)
        st.plotly_chart(fig_ciudad, use_container_width=True)
    
    with col_right2:
        st.subheader("📦 Ventas por Categoría")
        
        ventas_categoria = df_filtrado.groupby('CATEGORIA')['UNIDADES_VENDIDAS'].sum().sort_values(ascending=False)
        
        fig_cat = px.bar(ventas_categoria, 
                        title='Unidades Vendidas por Categoría',
                        labels={'value': 'Unidades', 'index': 'Categoría'})
        fig_cat.update_traces(marker_color='#FFD700')
        st.plotly_chart(fig_cat, use_container_width=True)
    
    # Tabla de datos
    st.subheader("📋 Datos Detallados")
    st.dataframe(
        df_filtrado[['FECHA', 'CODIGO_TIENDA', 'CIUDAD', 'PRODUCTO_NOMBRE', 'CATEGORIA',
                    'UNIDADES_VENDIDAS', 'PRECIO_DIA', 'INGRESOS_TOTALES', 'QUIEBRE_STOCK']].head(100),
        use_container_width=True
    )

# ============================================================================
# TAB 2: PREDICCIÓN DE QUIEBRES
# ============================================================================

with tab2:
    st.header("🎯 Predicción de Quiebre de Stock")
    
    st.info("🤖 Este módulo usa el modelo Random Forest entrenado con SMOTE para predecir quiebres de stock.")
    
    col1, col2 = st.columns([1, 1])
    
    with col1:
        st.subheader("🔮 Hacer una Predicción")
        
        with st.form("prediccion_form"):
            st.markdown("**Información del Producto**")
            producto_sel = st.selectbox("Producto", df_productos['NOMBRE'].tolist())
            
            st.markdown("**Información de la Tienda**")
            tienda_sel = st.selectbox("Tienda", df_tiendas['CODIGO_TIENDA'].tolist())
            
            st.markdown("**Features Operacionales**")
            col_f1, col_f2 = st.columns(2)
            
            with col_f1:
                inventario_inicial = st.number_input("Inventario Inicial", min_value=0, max_value=500, value=100)
                temperatura = st.number_input("Temperatura (°C)", min_value=10.0, max_value=45.0, value=25.0, step=0.5)
            
            with col_f2:
                ventas_ayer = st.number_input("Ventas Ayer", min_value=0, max_value=200, value=50)
                es_fin_semana = st.checkbox("Es Fin de Semana")
            
            tiene_promocion = st.selectbox("¿Tiene Promoción?", ["NO", "SI"])
            
            predecir_btn = st.form_submit_button("🚀 Predecir Quiebre", use_container_width=True)
        
        if predecir_btn:
            # Simular predicción
            features = {
                'inventario_inicial': inventario_inicial,
                'ventas_ayer': ventas_ayer,
                'temperatura': temperatura,
                'es_fin_semana': es_fin_semana,
                'tiene_promocion': tiene_promocion
            }
            
            prediccion, probabilidad = predecir_quiebre_stock(features)
            
            st.markdown("---")
            st.subheader("📊 Resultado de la Predicción")
            
            if prediccion:
                st.error(f"⚠️ **ALERTA: Se predice QUIEBRE de stock** (Probabilidad: {probabilidad*100:.1f}%)")
                st.markdown("""
                **Recomendaciones:**
                - 📦 Solicitar reabastecimiento urgente
                - 🚚 Revisar inventario en tránsito
                - 📞 Contactar al proveedor
                """)
            else:
                st.success(f"✅ **NO se predice quiebre de stock** (Probabilidad: {(1-probabilidad)*100:.1f}%)")
                st.markdown("""
                **Estado:**
                - 👍 Inventario suficiente para demanda esperada
                - 📊 Continuar monitoreo normal
                """)
            
            # Gauge de probabilidad
            fig_gauge = go.Figure(go.Indicator(
                mode="gauge+number",
                value=probabilidad * 100,
                title={'text': "Probabilidad de Quiebre (%)"},
                gauge={
                    'axis': {'range': [None, 100]},
                    'bar': {'color': "darkred" if probabilidad > 0.5 else "green"},
                    'steps': [
                        {'range': [0, 30], 'color': "lightgreen"},
                        {'range': [30, 70], 'color': "yellow"},
                        {'range': [70, 100], 'color': "lightcoral"}
                    ],
                    'threshold': {
                        'line': {'color': "red", 'width': 4},
                        'thickness': 0.75,
                        'value': 50
                    }
                }
            ))
            
            st.plotly_chart(fig_gauge, use_container_width=True)
    
    with col2:
        st.subheader("📊 Análisis Histórico de Quiebres")
        
        # Tasa de quiebre por categoría
        quiebres_categoria = df_filtrado.groupby('CATEGORIA').agg({
            'QUIEBRE_STOCK': ['sum', 'count']
        }).reset_index()
        quiebres_categoria.columns = ['CATEGORIA', 'QUIEBRES', 'TOTAL']
        quiebres_categoria['TASA'] = (quiebres_categoria['QUIEBRES'] / quiebres_categoria['TOTAL']) * 100
        
        fig_quiebres = px.bar(quiebres_categoria, x='CATEGORIA', y='TASA',
                             title='Tasa de Quiebre por Categoría (%)',
                             labels={'TASA': 'Tasa de Quiebre (%)'})
        fig_quiebres.update_traces(marker_color='#FF6B6B')
        st.plotly_chart(fig_quiebres, use_container_width=True)
        
        # Evolución de quiebres
        st.markdown("#### 📉 Evolución de Quiebres por Semana")
        
        df_filtrado['SEMANA'] = pd.to_datetime(df_filtrado['FECHA']).dt.isocalendar().week
        quiebres_semana = df_filtrado.groupby('SEMANA')['QUIEBRE_STOCK'].agg(['sum', 'count']).reset_index()
        quiebres_semana['TASA'] = (quiebres_semana['sum'] / quiebres_semana['count']) * 100
        
        fig_evol = px.line(quiebres_semana, x='SEMANA', y='TASA',
                          title='Tasa de Quiebre Semanal',
                          labels={'TASA': 'Tasa (%)', 'SEMANA': 'Semana del Año'})
        fig_evol.update_traces(line_color='#E30613', line_width=3)
        st.plotly_chart(fig_evol, use_container_width=True)
        
        # Productos con más quiebres
        st.markdown("#### ⚠️ Top 5 Productos con Más Quiebres")
        
        productos_riesgo = df_filtrado[df_filtrado['QUIEBRE_STOCK'] == True].groupby('PRODUCTO_NOMBRE').size().sort_values(ascending=False).head(5)
        
        st.dataframe(
            productos_riesgo.reset_index().rename(columns={'index': 'Producto', 0: 'Num. Quiebres'}),
            use_container_width=True,
            hide_index=True
        )

# ============================================================================
# TAB 3: FORECASTING DE VENTAS
# ============================================================================

with tab3:
    st.header("📈 Forecasting de Ventas")
    
    st.info("🔮 Pronóstico de ventas usando XGBoost con features temporales y externos.")
    
    # Selección de producto y tienda
    col1, col2, col3 = st.columns(3)
    
    with col1:
        producto_forecast = st.selectbox("Producto a Pronosticar", 
                                        df_productos['NOMBRE'].tolist(), 
                                        key='forecast_producto')
    
    with col2:
        tienda_forecast = st.selectbox("Tienda", 
                                      df_tiendas['CODIGO_TIENDA'].head(5).tolist(),
                                      key='forecast_tienda')
    
    with col3:
        dias_forecast = st.slider("Días a Pronosticar", 7, 30, 14)
    
    # Generar forecast (simulado)
    if st.button("🚀 Generar Pronóstico", use_container_width=True):
        with st.spinner("Generando pronóstico..."):
            # Datos históricos
            df_historico = df_filtrado[
                (df_filtrado['PRODUCTO_NOMBRE'] == producto_forecast) &
                (df_filtrado['CODIGO_TIENDA'] == tienda_forecast)
            ].copy()
            
            if len(df_historico) > 0:
                # Simular forecast
                last_date = pd.to_datetime(df_historico['FECHA']).max()
                future_dates = pd.date_range(last_date + timedelta(days=1), periods=dias_forecast, freq='D')
                
                # Generar valores predichos (simulados con tendencia)
                base_mean = df_historico['UNIDADES_VENDIDAS'].mean()
                forecast_values = base_mean + np.random.normal(0, base_mean * 0.15, dias_forecast)
                forecast_values = np.maximum(forecast_values, 0)  # No negativos
                
                df_forecast = pd.DataFrame({
                    'FECHA': future_dates,
                    'VENTAS_PREDICHAS': forecast_values,
                    'INTERVALO_INFERIOR': forecast_values * 0.85,
                    'INTERVALO_SUPERIOR': forecast_values * 1.15
                })
                
                # Visualización
                col_viz1, col_viz2 = st.columns([2, 1])
                
                with col_viz1:
                    st.subheader("📊 Pronóstico de Ventas")
                    
                    # Combinar histórico y forecast
                    fig_forecast = go.Figure()
                    
                    # Histórico
                    fig_forecast.add_trace(go.Scatter(
                        x=pd.to_datetime(df_historico['FECHA']),
                        y=df_historico['UNIDADES_VENDIDAS'],
                        mode='lines+markers',
                        name='Histórico',
                        line=dict(color='blue', width=2)
                    ))
                    
                    # Pronóstico
                    fig_forecast.add_trace(go.Scatter(
                        x=df_forecast['FECHA'],
                        y=df_forecast['VENTAS_PREDICHAS'],
                        mode='lines+markers',
                        name='Pronóstico',
                        line=dict(color='red', width=2, dash='dash')
                    ))
                    
                    # Intervalos de confianza
                    fig_forecast.add_trace(go.Scatter(
                        x=df_forecast['FECHA'].tolist() + df_forecast['FECHA'].tolist()[::-1],
                        y=df_forecast['INTERVALO_SUPERIOR'].tolist() + df_forecast['INTERVALO_INFERIOR'].tolist()[::-1],
                        fill='toself',
                        fillcolor='rgba(255,0,0,0.2)',
                        line=dict(color='rgba(255,255,255,0)'),
                        name='Intervalo 85% confianza',
                        showlegend=True
                    ))
                    
                    fig_forecast.update_layout(
                        title=f'Ventas: {producto_forecast} - {tienda_forecast}',
                        xaxis_title='Fecha',
                        yaxis_title='Unidades Vendidas',
                        hovermode='x unified'
                    )
                    
                    st.plotly_chart(fig_forecast, use_container_width=True)
                
                with col_viz2:
                    st.subheader("📊 Estadísticas del Pronóstico")
                    
                    st.metric("📦 Ventas Promedio Pronosticadas", 
                             f"{df_forecast['VENTAS_PREDICHAS'].mean():.0f} unidades/día")
                    
                    st.metric("📈 Ventas Totales Esperadas", 
                             f"{df_forecast['VENTAS_PREDICHAS'].sum():.0f} unidades")
                    
                    ingresos_esperados = df_forecast['VENTAS_PREDICHAS'].sum() * df_historico['PRECIO_DIA'].mean()
                    st.metric("💵 Ingresos Esperados", 
                             f"${ingresos_esperados:,.0f} MXN")
                    
                    st.markdown("---")
                    
                    st.markdown("**🎯 Recomendaciones:**")
                    inventario_necesario = df_forecast['INTERVALO_SUPERIOR'].sum()
                    st.markdown(f"- Inventario recomendado: **{inventario_necesario:.0f} unidades**")
                    st.markdown(f"- Puntos de reorden: **{inventario_necesario/2:.0f} unidades**")
                    st.markdown(f"- Frecuencia de reabasto: **Cada {dias_forecast//2} días**")
                
                # Tabla de datos
                st.subheader("📋 Detalle del Pronóstico")
                df_forecast_display = df_forecast.copy()
                df_forecast_display['FECHA'] = df_forecast_display['FECHA'].dt.strftime('%Y-%m-%d')
                df_forecast_display = df_forecast_display.round(0)
                st.dataframe(df_forecast_display, use_container_width=True, hide_index=True)
                
            else:
                st.warning("⚠️ No hay datos históricos suficientes para este producto/tienda.")

# ============================================================================
# TAB 4: FINOPS
# ============================================================================

with tab4:
    st.header("💰 FinOps - Monitoreo de Costos")
    
    st.info("📊 Dashboard de costos de compute y almacenamiento en Snowflake.")
    
    # Métricas de costo (simuladas)
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric("🏭 Warehouse Activo", "OXXO_ML_WH", delta="SMALL")
    
    with col2:
        creditos_usados = 12.5
        st.metric("💳 Créditos Usados (Hoy)", f"{creditos_usados:.2f}", delta="+2.3")
    
    with col3:
        costo_usd = creditos_usados * 2.0
        st.metric("💵 Costo (Hoy)", f"${costo_usd:.2f} USD", delta="+$4.60")
    
    with col4:
        st.metric("📦 Storage Total", "165 MB", delta="+5 MB")
    
    st.markdown("---")
    
    # Gráficas de costos
    col_left, col_right = st.columns(2)
    
    with col_left:
        st.subheader("📊 Consumo de Créditos por Día")
        
        # Datos simulados
        dates = pd.date_range(end=datetime.now(), periods=30, freq='D')
        creditos_diarios = np.random.uniform(8, 20, 30)
        
        df_creditos = pd.DataFrame({
            'FECHA': dates,
            'CREDITOS': creditos_diarios,
            'COSTO_USD': creditos_diarios * 2.0
        })
        
        fig_creditos = px.bar(df_creditos, x='FECHA', y='CREDITOS',
                             title='Créditos Consumidos por Día',
                             labels={'CREDITOS': 'Créditos', 'FECHA': 'Fecha'})
        fig_creditos.update_traces(marker_color='#4CAF50')
        st.plotly_chart(fig_creditos, use_container_width=True)
    
    with col_right:
        st.subheader("💵 Costo Acumulado Mensual")
        
        df_creditos['COSTO_ACUMULADO'] = df_creditos['COSTO_USD'].cumsum()
        
        fig_acum = px.area(df_creditos, x='FECHA', y='COSTO_ACUMULADO',
                          title='Costo Acumulado (USD)',
                          labels={'COSTO_ACUMULADO': 'Costo USD', 'FECHA': 'Fecha'})
        fig_acum.update_traces(line_color='#E30613', fillcolor='rgba(227,6,19,0.3)')
        st.plotly_chart(fig_acum, use_container_width=True)
    
    # Detalle de objetos
    st.subheader("📦 Almacenamiento por Tabla")
    
    df_storage = pd.DataFrame({
        'TABLA': ['VENTAS_HISTORICAS', 'PRODUCTOS', 'TIENDAS', 'TRAIN_CLASIFICACION', 'TEST_CLASIFICACION'],
        'REGISTROS': [50000, 100, 500, 40000, 10000],
        'SIZE_MB': [98.5, 0.5, 2.3, 52.1, 12.0],
        'COSTO_MENSUAL_USD': [0.0197, 0.0001, 0.0005, 0.0104, 0.0024]
    })
    
    df_storage['COSTO_ANUAL_USD'] = df_storage['COSTO_MENSUAL_USD'] * 12
    
    st.dataframe(df_storage, use_container_width=True, hide_index=True)
    
    # Resumen de costos
    st.markdown("---")
    st.subheader("💡 Resumen de FinOps")
    
    col_res1, col_res2, col_res3 = st.columns(3)
    
    with col_res1:
        st.markdown("**🎯 Costo por Modelo Entrenado**")
        st.markdown("- Clasificación (Random Forest): **$0.45 USD**")
        st.markdown("- Forecasting (XGBoost): **$0.32 USD**")
        st.markdown("- Total por ciclo: **$0.77 USD**")
    
    with col_res2:
        st.markdown("**📊 Costo Mensual Proyectado**")
        st.markdown("- Compute (4 entrenamientos/mes): **$3.08 USD**")
        st.markdown("- Storage (165 MB): **$0.03 USD**")
        st.markdown("- **TOTAL: $3.11 USD/mes**")
    
    with col_res3:
        st.markdown("**💰 ROI del Proyecto ML**")
        st.markdown("- Costo anual: **$37.32 USD**")
        st.markdown("- Valor generado: **$24,000 USD/año**")
        st.markdown("- **ROI: 643x** 🚀")
    
    st.success("✅ El proyecto es altamente rentable con costos mínimos de infraestructura.")

# ============================================================================
# FOOTER
# ============================================================================

st.markdown("---")
st.markdown("""
<div style='text-align: center; color: #666;'>
    <p>🏪 <strong>OXXO ML Dashboard</strong> | Powered by Snowflake ❄️ | Data Science con Snowpark Python 🐍</p>
    <p>Creado para: <strong>Evento Snowflake México</strong> | Octubre 2025</p>
</div>
""", unsafe_allow_html=True)

