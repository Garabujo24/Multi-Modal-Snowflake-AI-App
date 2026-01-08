"""
================================================================================
VISUALIZACIÓN INTERACTIVA DE ANOMALÍAS - GRUPO COMERCIAL CONTROL
Cliente: C Control / Grupo Comercial DSW
Tecnología: Streamlit + Snowflake + Plotly
Propósito: Dashboard interactivo para análisis de anomalías en tiempo real
================================================================================
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import snowflake.connector
from datetime import datetime, timedelta

# ================================================================================
# CONFIGURACIÓN DE LA PÁGINA
# ================================================================================

st.set_page_config(
    page_title="C Control - Detección de Anomalías",
    page_icon="🔍",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ================================================================================
# FUNCIONES DE CONEXIÓN A SNOWFLAKE
# ================================================================================

@st.cache_resource
def get_snowflake_connection():
    """
    Establece conexión con Snowflake.
    NOTA: Configurar credenciales en secrets.toml o variables de entorno
    """
    try:
        conn = snowflake.connector.connect(
            user=st.secrets["snowflake"]["user"],
            password=st.secrets["snowflake"]["password"],
            account=st.secrets["snowflake"]["account"],
            warehouse="CCONTROL_WH",
            database="CCONTROL_DB",
            schema="CCONTROL_SCHEMA"
        )
        return conn
    except Exception as e:
        st.error(f"Error conectando a Snowflake: {e}")
        return None

@st.cache_data(ttl=300)  # Cache por 5 minutos
def ejecutar_query(query):
    """Ejecuta query en Snowflake y retorna DataFrame"""
    conn = get_snowflake_connection()
    if conn:
        try:
            df = pd.read_sql(query, conn)
            return df
        except Exception as e:
            st.error(f"Error ejecutando query: {e}")
            return None
    return None

# ================================================================================
# QUERIES DE SNOWFLAKE
# ================================================================================

QUERY_DASHBOARD = """
SELECT 
    FECHA,
    TIPO_TIENDA,
    REGION,
    NOMBRE_SUCURSAL,
    ESTADO,
    VENTAS_TOTALES,
    TICKET_PROMEDIO,
    NUM_TRANSACCIONES,
    NUM_CLIENTES,
    TEMPERATURA_C,
    PRECIPITACION_MM,
    ES_DIA_FESTIVO,
    ES_FIN_SEMANA,
    HAY_PROMOCION,
    EVENTO_ADVERSO,
    SCORE_ANOMALIA_VENTAS,
    SCORE_ANOMALIA_TICKET,
    CLASIFICACION_ANOMALIA
FROM CCONTROL_SCHEMA.VW_DASHBOARD_ANOMALIAS
WHERE FECHA >= DATEADD(DAY, -90, CURRENT_DATE())
ORDER BY FECHA DESC, TIPO_TIENDA, REGION
"""

QUERY_RESUMEN = """
SELECT 
    TIPO_TIENDA,
    REGION,
    COUNT(*) AS TOTAL_DIAS,
    SUM(CASE WHEN CLASIFICACION_ANOMALIA = 'Crítica' THEN 1 ELSE 0 END) AS ANOMALIAS_CRITICAS,
    SUM(CASE WHEN CLASIFICACION_ANOMALIA = 'Moderada' THEN 1 ELSE 0 END) AS ANOMALIAS_MODERADAS,
    ROUND(AVG(VENTAS_TOTALES), 2) AS PROMEDIO_VENTAS
FROM CCONTROL_SCHEMA.VW_DASHBOARD_ANOMALIAS
WHERE FECHA >= DATEADD(DAY, -90, CURRENT_DATE())
GROUP BY TIPO_TIENDA, REGION
ORDER BY ANOMALIAS_CRITICAS DESC
"""

# ================================================================================
# INTERFAZ PRINCIPAL
# ================================================================================

def main():
    # Header
    st.title("🔍 Detección de Anomalías en Ventas Retail")
    st.markdown("### Grupo Comercial Control - Dashboard de Monitoreo")
    st.markdown("---")
    
    # Sidebar - Filtros
    st.sidebar.header("🎛️ Filtros de Análisis")
    
    # Cargar datos
    with st.spinner("Cargando datos de Snowflake..."):
        df_principal = ejecutar_query(QUERY_DASHBOARD)
        df_resumen = ejecutar_query(QUERY_RESUMEN)
    
    if df_principal is None or df_resumen is None:
        st.error("❌ No se pudieron cargar los datos. Verifica la conexión a Snowflake.")
        st.info("""
        **Para usar este dashboard:**
        1. Configura tu archivo `.streamlit/secrets.toml`:
        ```toml
        [snowflake]
        user = "TU_USUARIO"
        password = "TU_PASSWORD"
        account = "TU_CUENTA"
        ```
        2. Asegúrate de que el script SQL principal ya se haya ejecutado en Snowflake
        3. Recarga esta página
        """)
        return
    
    # Conversión de tipos
    df_principal['FECHA'] = pd.to_datetime(df_principal['FECHA'])
    
    # Filtros en sidebar
    tipos_tienda = ['Todas'] + sorted(df_principal['TIPO_TIENDA'].unique().tolist())
    regiones = ['Todas'] + sorted(df_principal['REGION'].unique().tolist())
    
    tipo_seleccionado = st.sidebar.selectbox("🏬 Tipo de Tienda", tipos_tienda)
    region_seleccionada = st.sidebar.selectbox("🗺️ Región", regiones)
    
    fecha_min = df_principal['FECHA'].min().date()
    fecha_max = df_principal['FECHA'].max().date()
    
    rango_fechas = st.sidebar.date_input(
        "📅 Rango de Fechas",
        value=(fecha_max - timedelta(days=30), fecha_max),
        min_value=fecha_min,
        max_value=fecha_max
    )
    
    solo_anomalias = st.sidebar.checkbox("⚠️ Mostrar solo anomalías", value=False)
    
    # Aplicar filtros
    df_filtrado = df_principal.copy()
    
    if tipo_seleccionado != 'Todas':
        df_filtrado = df_filtrado[df_filtrado['TIPO_TIENDA'] == tipo_seleccionado]
    
    if region_seleccionada != 'Todas':
        df_filtrado = df_filtrado[df_filtrado['REGION'] == region_seleccionada]
    
    if len(rango_fechas) == 2:
        df_filtrado = df_filtrado[
            (df_filtrado['FECHA'].dt.date >= rango_fechas[0]) &
            (df_filtrado['FECHA'].dt.date <= rango_fechas[1])
        ]
    
    if solo_anomalias:
        df_filtrado = df_filtrado[
            df_filtrado['CLASIFICACION_ANOMALIA'].isin(['Crítica', 'Moderada'])
        ]
    
    # ============================================================================
    # SECCIÓN 1: KPIs PRINCIPALES
    # ============================================================================
    
    st.markdown("## 📊 KPIs Principales")
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        total_anomalias_criticas = len(df_filtrado[df_filtrado['CLASIFICACION_ANOMALIA'] == 'Crítica'])
        st.metric(
            label="🔴 Anomalías Críticas",
            value=total_anomalias_criticas,
            delta=f"{(total_anomalias_criticas/len(df_filtrado)*100):.1f}% del total"
        )
    
    with col2:
        total_anomalias_moderadas = len(df_filtrado[df_filtrado['CLASIFICACION_ANOMALIA'] == 'Moderada'])
        st.metric(
            label="🟠 Anomalías Moderadas",
            value=total_anomalias_moderadas,
            delta=f"{(total_anomalias_moderadas/len(df_filtrado)*100):.1f}% del total"
        )
    
    with col3:
        promedio_ventas = df_filtrado['VENTAS_TOTALES'].mean()
        st.metric(
            label="💰 Ventas Promedio",
            value=f"${promedio_ventas:,.0f}",
            delta=None
        )
    
    with col4:
        ticket_promedio = df_filtrado['TICKET_PROMEDIO'].mean()
        st.metric(
            label="🎫 Ticket Promedio",
            value=f"${ticket_promedio:,.0f}",
            delta=None
        )
    
    st.markdown("---")
    
    # ============================================================================
    # SECCIÓN 2: GRÁFICA PRINCIPAL - SERIES DE TIEMPO
    # ============================================================================
    
    st.markdown("## 📈 Series de Tiempo - Ventas y Anomalías")
    
    # Crear gráfica con plotly
    fig_serie_tiempo = go.Figure()
    
    # Agrupar por fecha para visualización limpia
    df_agrupado = df_filtrado.groupby(['FECHA', 'TIPO_TIENDA']).agg({
        'VENTAS_TOTALES': 'sum',
        'SCORE_ANOMALIA_VENTAS': 'mean',
        'CLASIFICACION_ANOMALIA': lambda x: 'Crítica' if 'Crítica' in x.values else ('Moderada' if 'Moderada' in x.values else 'Normal')
    }).reset_index()
    
    # Agregar líneas por tipo de tienda
    for tipo in df_agrupado['TIPO_TIENDA'].unique():
        df_tipo = df_agrupado[df_agrupado['TIPO_TIENDA'] == tipo]
        
        fig_serie_tiempo.add_trace(go.Scatter(
            x=df_tipo['FECHA'],
            y=df_tipo['VENTAS_TOTALES'],
            mode='lines+markers',
            name=tipo,
            line=dict(width=2),
            marker=dict(
                size=8,
                color=df_tipo['SCORE_ANOMALIA_VENTAS'],
                colorscale='RdYlGn',
                reversescale=True,
                showscale=True,
                colorbar=dict(title="Score Anomalía")
            ),
            hovertemplate='<b>%{x}</b><br>Ventas: $%{y:,.0f}<extra></extra>'
        ))
    
    fig_serie_tiempo.update_layout(
        title="Ventas Totales Diarias por Tipo de Tienda",
        xaxis_title="Fecha",
        yaxis_title="Ventas Totales (MXN)",
        hovermode='x unified',
        height=500
    )
    
    st.plotly_chart(fig_serie_tiempo, use_container_width=True)
    
    # ============================================================================
    # SECCIÓN 3: ANÁLISIS POR REGIÓN Y TIPO DE TIENDA
    # ============================================================================
    
    st.markdown("## 🗺️ Análisis por Región y Tipo de Tienda")
    
    col_izq, col_der = st.columns(2)
    
    with col_izq:
        # Gráfica de barras: Anomalías por región
        df_region = df_filtrado.groupby('REGION').agg({
            'CLASIFICACION_ANOMALIA': lambda x: (x.isin(['Crítica', 'Moderada'])).sum(),
            'VENTAS_TOTALES': 'mean'
        }).reset_index()
        df_region.columns = ['REGION', 'TOTAL_ANOMALIAS', 'PROMEDIO_VENTAS']
        
        fig_region = px.bar(
            df_region,
            x='REGION',
            y='TOTAL_ANOMALIAS',
            color='PROMEDIO_VENTAS',
            title="Total de Anomalías por Región",
            labels={'TOTAL_ANOMALIAS': 'Número de Anomalías', 'PROMEDIO_VENTAS': 'Ventas Promedio'},
            color_continuous_scale='Blues'
        )
        st.plotly_chart(fig_region, use_container_width=True)
    
    with col_der:
        # Gráfica de pie: Distribución de anomalías por tipo
        df_clasificacion = df_filtrado['CLASIFICACION_ANOMALIA'].value_counts().reset_index()
        df_clasificacion.columns = ['CLASIFICACION', 'CANTIDAD']
        
        colores = {
            'Crítica': '#e74c3c',
            'Moderada': '#f39c12',
            'Normal': '#2ecc71',
            'Pico': '#3498db'
        }
        
        fig_pie = px.pie(
            df_clasificacion,
            values='CANTIDAD',
            names='CLASIFICACION',
            title="Distribución de Clasificación de Días",
            color='CLASIFICACION',
            color_discrete_map=colores
        )
        st.plotly_chart(fig_pie, use_container_width=True)
    
    # ============================================================================
    # SECCIÓN 4: VARIABLES EXÓGENAS
    # ============================================================================
    
    st.markdown("## 🌡️ Impacto de Variables Exógenas")
    
    col1, col2 = st.columns(2)
    
    with col1:
        # Correlación temperatura vs ventas
        fig_temp = px.scatter(
            df_filtrado,
            x='TEMPERATURA_C',
            y='VENTAS_TOTALES',
            color='CLASIFICACION_ANOMALIA',
            title="Temperatura vs Ventas",
            labels={'TEMPERATURA_C': 'Temperatura (°C)', 'VENTAS_TOTALES': 'Ventas (MXN)'},
            color_discrete_map=colores,
            trendline="ols"
        )
        st.plotly_chart(fig_temp, use_container_width=True)
    
    with col2:
        # Correlación precipitación vs ventas
        fig_precip = px.scatter(
            df_filtrado,
            x='PRECIPITACION_MM',
            y='VENTAS_TOTALES',
            color='CLASIFICACION_ANOMALIA',
            title="Precipitación vs Ventas",
            labels={'PRECIPITACION_MM': 'Precipitación (mm)', 'VENTAS_TOTALES': 'Ventas (MXN)'},
            color_discrete_map=colores,
            trendline="ols"
        )
        st.plotly_chart(fig_precip, use_container_width=True)
    
    # ============================================================================
    # SECCIÓN 5: TABLA DE ANOMALÍAS DETECTADAS
    # ============================================================================
    
    st.markdown("## 📋 Detalle de Anomalías Detectadas")
    
    # Filtrar solo anomalías
    df_anomalias = df_filtrado[
        df_filtrado['CLASIFICACION_ANOMALIA'].isin(['Crítica', 'Moderada'])
    ].sort_values('SCORE_ANOMALIA_VENTAS').head(50)
    
    # Formatear para visualización
    df_display = df_anomalias[[
        'FECHA', 'TIPO_TIENDA', 'REGION', 'NOMBRE_SUCURSAL',
        'VENTAS_TOTALES', 'TICKET_PROMEDIO', 'SCORE_ANOMALIA_VENTAS',
        'CLASIFICACION_ANOMALIA', 'EVENTO_ADVERSO'
    ]].copy()
    
    df_display['VENTAS_TOTALES'] = df_display['VENTAS_TOTALES'].apply(lambda x: f"${x:,.0f}")
    df_display['TICKET_PROMEDIO'] = df_display['TICKET_PROMEDIO'].apply(lambda x: f"${x:,.0f}")
    df_display['SCORE_ANOMALIA_VENTAS'] = df_display['SCORE_ANOMALIA_VENTAS'].apply(lambda x: f"{x:.3f}")
    
    st.dataframe(df_display, use_container_width=True, height=400)
    
    # ============================================================================
    # SECCIÓN 6: EXPORTACIÓN Y DESCARGAS
    # ============================================================================
    
    st.markdown("---")
    st.markdown("## 💾 Exportación de Datos")
    
    col1, col2 = st.columns(2)
    
    with col1:
        # Botón de descarga CSV
        csv = df_filtrado.to_csv(index=False).encode('utf-8')
        st.download_button(
            label="📥 Descargar datos filtrados (CSV)",
            data=csv,
            file_name=f"ccontrol_anomalias_{datetime.now().strftime('%Y%m%d')}.csv",
            mime="text/csv"
        )
    
    with col2:
        # Estadísticas generales
        st.info(f"""
        **Resumen de datos:**
        - Total de registros: {len(df_filtrado):,}
        - Rango de fechas: {df_filtrado['FECHA'].min().date()} a {df_filtrado['FECHA'].max().date()}
        - Sucursales únicas: {df_filtrado['NOMBRE_SUCURSAL'].nunique()}
        """)
    
    # Footer
    st.markdown("---")
    st.markdown("""
    <div style='text-align: center'>
        <p>🏢 <b>Grupo Comercial Control</b> | Detección de Anomalías con Snowflake</p>
        <p style='font-size: 0.8em;'>Dashboard desarrollado con Streamlit + Plotly</p>
    </div>
    """, unsafe_allow_html=True)

# ================================================================================
# EJECUCIÓN
# ================================================================================

if __name__ == "__main__":
    main()

