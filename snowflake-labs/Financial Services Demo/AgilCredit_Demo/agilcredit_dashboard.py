# AgilCredit - Dashboard Analítico Ejecutivo
# Streamlit App para Snowflake
# Compatible con Streamlit in Snowflake

import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta

# Configuración de la página
st.set_page_config(
    page_title="AgilCredit | Dashboard Ejecutivo",
    page_icon="💳",
    layout="wide",
    initial_sidebar_state="expanded"
)

# CSS personalizado
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        font-weight: bold;
        color: #1E3A8A;
        text-align: center;
        padding: 1rem;
    }
    .metric-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 1.5rem;
        border-radius: 10px;
        color: white;
        text-align: center;
    }
    .kpi-value {
        font-size: 2rem;
        font-weight: bold;
    }
    .kpi-label {
        font-size: 0.9rem;
        opacity: 0.9;
    }
    .section-header {
        font-size: 1.5rem;
        font-weight: bold;
        color: #1E3A8A;
        margin-top: 2rem;
        margin-bottom: 1rem;
        border-bottom: 2px solid #667eea;
        padding-bottom: 0.5rem;
    }
    .warning-box {
        background-color: #FEF3C7;
        border-left: 4px solid #F59E0B;
        padding: 1rem;
        border-radius: 5px;
        margin: 1rem 0;
    }
    .success-box {
        background-color: #D1FAE5;
        border-left: 4px solid #10B981;
        padding: 1rem;
        border-radius: 5px;
        margin: 1rem 0;
    }
</style>
""", unsafe_allow_html=True)

# Obtener sesión de Snowflake
@st.cache_resource
def get_snowflake_session():
    return get_active_session()

session = get_snowflake_session()

# Header principal
st.markdown('<div class="main-header">💳 AgilCredit | Dashboard Ejecutivo</div>', unsafe_allow_html=True)
st.markdown("**Fintech Mexicana** | Análisis Integral de Riesgo, Fraude, Rentabilidad y Cumplimiento")

# Sidebar con filtros
st.sidebar.image("https://via.placeholder.com/200x80/667eea/FFFFFF?text=AgilCredit", use_column_width=True)
st.sidebar.markdown("### 📊 Filtros y Configuración")

# Selector de vista
vista = st.sidebar.selectbox(
    "Selecciona Vista:",
    ["📈 Dashboard Ejecutivo", "⚠️ Análisis de Riesgo", "🔍 Detección de Fraude", 
     "💰 Rentabilidad", "✅ Cumplimiento Regulatorio", "📍 Análisis Geográfico"]
)

# Selector de periodo
periodo = st.sidebar.selectbox(
    "Periodo de Análisis:",
    ["Último Mes", "Últimos 3 Meses", "Últimos 6 Meses", "Último Año", "Todo el Historial"]
)

# Función para ejecutar queries
def ejecutar_query(query):
    try:
        return session.sql(query).to_pandas()
    except Exception as e:
        st.error(f"Error al ejecutar query: {str(e)}")
        return pd.DataFrame()

# ============================================================================
# VISTA: DASHBOARD EJECUTIVO
# ============================================================================
if vista == "📈 Dashboard Ejecutivo":
    st.markdown('<div class="section-header">Indicadores Clave de Desempeño (KPIs)</div>', unsafe_allow_html=True)
    
    # Query para KPIs principales
    kpis_query = """
    SELECT 
        COUNT(DISTINCT c.CLIENTE_ID) as total_clientes,
        COUNT(DISTINCT CASE WHEN c.ESTATUS = 'ACTIVO' THEN c.CLIENTE_ID END) as clientes_activos,
        COUNT(DISTINCT cr.CREDITO_ID) as total_creditos,
        SUM(cr.MONTO_CREDITO) as monto_desembolsado,
        SUM(cr.SALDO_ACTUAL) as cartera_total,
        SUM(CASE WHEN cr.ESTATUS_CREDITO IN ('MORA', 'VENCIDO') THEN cr.SALDO_ACTUAL ELSE 0 END) as cartera_vencida,
        COUNT(DISTINCT t.TRANSACCION_ID) as total_transacciones,
        SUM(t.MONTO) as volumen_transacciones,
        COUNT(DISTINCT af.ALERTA_ID) as alertas_fraude,
        SUM(r.UTILIDAD_NETA) as utilidad_total
    FROM AGILCREDIT_DB.CORE.CLIENTES c
    LEFT JOIN AGILCREDIT_DB.CORE.CREDITOS cr ON c.CLIENTE_ID = cr.CLIENTE_ID
    LEFT JOIN AGILCREDIT_DB.CORE.TRANSACCIONES t ON cr.CREDITO_ID = t.CREDITO_ID
    LEFT JOIN AGILCREDIT_DB.CORE.ALERTAS_FRAUDE af ON t.TRANSACCION_ID = af.TRANSACCION_ID
    LEFT JOIN AGILCREDIT_DB.ANALYTICS.RENTABILIDAD_CLIENTES r ON c.CLIENTE_ID = r.CLIENTE_ID
    """
    
    kpis = ejecutar_query(kpis_query)
    
    if not kpis.empty:
        # Row 1: KPIs principales
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric(
                "👥 Clientes Totales",
                f"{int(kpis['TOTAL_CLIENTES'].iloc[0]):,}",
                f"{int(kpis['CLIENTES_ACTIVOS'].iloc[0]):,} activos"
            )
        
        with col2:
            cartera = kpis['CARTERA_TOTAL'].iloc[0] or 0
            st.metric(
                "💼 Cartera Total",
                f"${cartera:,.0f}",
                f"{int(kpis['TOTAL_CREDITOS'].iloc[0]):,} créditos"
            )
        
        with col3:
            cartera_vencida = kpis['CARTERA_VENCIDA'].iloc[0] or 0
            imor = (cartera_vencida / cartera * 100) if cartera > 0 else 0
            st.metric(
                "📊 IMOR (Morosidad)",
                f"{imor:.2f}%",
                f"${cartera_vencida:,.0f}",
                delta_color="inverse"
            )
        
        with col4:
            utilidad = kpis['UTILIDAD_TOTAL'].iloc[0] or 0
            st.metric(
                "💰 Utilidad Neta",
                f"${utilidad:,.0f}",
                "Total acumulada"
            )
        
        # Row 2: KPIs secundarios
        col5, col6, col7, col8 = st.columns(4)
        
        with col5:
            transacciones = int(kpis['TOTAL_TRANSACCIONES'].iloc[0] or 0)
            st.metric("🔄 Transacciones", f"{transacciones:,}")
        
        with col6:
            volumen = kpis['VOLUMEN_TRANSACCIONES'].iloc[0] or 0
            st.metric("💵 Volumen", f"${volumen:,.0f}")
        
        with col7:
            alertas = int(kpis['ALERTAS_FRAUDE'].iloc[0] or 0)
            st.metric("🚨 Alertas Fraude", f"{alertas:,}")
        
        with col8:
            desembolsado = kpis['MONTO_DESEMBOLSADO'].iloc[0] or 0
            st.metric("📤 Desembolsado", f"${desembolsado:,.0f}")
    
    st.markdown("---")
    
    # Gráficas principales
    col_izq, col_der = st.columns(2)
    
    with col_izq:
        st.markdown("### 📈 Evolución de Originación")
        
        originacion_query = """
        SELECT 
            DATE_TRUNC('month', FECHA_DESEMBOLSO) as mes,
            COUNT(DISTINCT CREDITO_ID) as total_creditos,
            SUM(MONTO_CREDITO) as monto_total
        FROM AGILCREDIT_DB.CORE.CREDITOS
        WHERE FECHA_DESEMBOLSO >= DATEADD(month, -12, CURRENT_DATE())
        GROUP BY mes
        ORDER BY mes
        """
        
        df_orig = ejecutar_query(originacion_query)
        if not df_orig.empty:
            fig_orig = go.Figure()
            fig_orig.add_trace(go.Bar(
                x=df_orig['MES'],
                y=df_orig['TOTAL_CREDITOS'],
                name='Número de Créditos',
                marker_color='#667eea'
            ))
            fig_orig.update_layout(
                title="Créditos Otorgados por Mes",
                xaxis_title="Mes",
                yaxis_title="Cantidad",
                hovermode='x unified'
            )
            st.plotly_chart(fig_orig, use_container_width=True)
    
    with col_der:
        st.markdown("### 🎯 Segmentación de Clientes")
        
        segmentacion_query = """
        SELECT 
            SEGMENTO_CLIENTE,
            COUNT(DISTINCT CLIENTE_ID) as total
        FROM AGILCREDIT_DB.CORE.CLIENTES
        GROUP BY SEGMENTO_CLIENTE
        ORDER BY total DESC
        """
        
        df_seg = ejecutar_query(segmentacion_query)
        if not df_seg.empty:
            fig_seg = px.pie(
                df_seg,
                values='TOTAL',
                names='SEGMENTO_CLIENTE',
                title='Distribución por Segmento',
                color_discrete_sequence=px.colors.sequential.Purples_r
            )
            st.plotly_chart(fig_seg, use_container_width=True)

# ============================================================================
# VISTA: ANÁLISIS DE RIESGO
# ============================================================================
elif vista == "⚠️ Análisis de Riesgo":
    st.markdown('<div class="section-header">Análisis de Riesgo Crediticio</div>', unsafe_allow_html=True)
    
    # Matriz de riesgo
    riesgo_query = """
    SELECT * FROM AGILCREDIT_DB.ANALYTICS.V_MATRIZ_RIESGO
    """
    
    df_riesgo = ejecutar_query(riesgo_query)
    
    if not df_riesgo.empty:
        st.markdown("### 📊 Matriz de Riesgo por Segmento")
        st.dataframe(
            df_riesgo.style.background_gradient(subset=['TASA_MOROSIDAD_PCT'], cmap='RdYlGn_r'),
            use_container_width=True
        )
        
        # Gráfica de exposición vs morosidad
        col1, col2 = st.columns(2)
        
        with col1:
            fig_exp = px.bar(
                df_riesgo,
                x='SEGMENTO_CLIENTE',
                y='EXPOSICION_TOTAL_SEGMENTO',
                title='Exposición por Segmento',
                color='TASA_MOROSIDAD_PCT',
                color_continuous_scale='RdYlGn_r'
            )
            st.plotly_chart(fig_exp, use_container_width=True)
        
        with col2:
            fig_mora = px.bar(
                df_riesgo,
                x='SEGMENTO_CLIENTE',
                y='TASA_MOROSIDAD_PCT',
                title='Tasa de Morosidad por Segmento (%)',
                color='TASA_MOROSIDAD_PCT',
                color_continuous_scale='RdYlGn_r'
            )
            st.plotly_chart(fig_mora, use_container_width=True)
    
    st.markdown("---")
    
    # Top clientes de mayor riesgo
    st.markdown("### 🚨 Top 20 Clientes de Mayor Riesgo")
    
    riesgo_clientes_query = """
    SELECT 
        c.CLIENTE_ID,
        c.NOMBRE || ' ' || c.APELLIDO_PATERNO as NOMBRE_COMPLETO,
        c.SEGMENTO_CLIENTE,
        c.CALIFICACION_BURO,
        COUNT(DISTINCT cr.CREDITO_ID) as CREDITOS_ACTIVOS,
        SUM(cr.SALDO_ACTUAL) as SALDO_TOTAL,
        MAX(cr.DIAS_MORA) as MAX_DIAS_MORA,
        SUM(CASE WHEN cr.ESTATUS_CREDITO = 'VENCIDO' THEN 1 ELSE 0 END) as CREDITOS_VENCIDOS
    FROM AGILCREDIT_DB.CORE.CLIENTES c
    JOIN AGILCREDIT_DB.CORE.CREDITOS cr ON c.CLIENTE_ID = cr.CLIENTE_ID
    WHERE cr.ESTATUS_CREDITO IN ('VIGENTE', 'MORA', 'VENCIDO')
    GROUP BY 1,2,3,4
    HAVING SUM(cr.SALDO_ACTUAL) > 0
    ORDER BY CREDITOS_VENCIDOS DESC, MAX_DIAS_MORA DESC
    LIMIT 20
    """
    
    df_riesgo_clientes = ejecutar_query(riesgo_clientes_query)
    if not df_riesgo_clientes.empty:
        st.dataframe(df_riesgo_clientes, use_container_width=True)

# ============================================================================
# VISTA: DETECCIÓN DE FRAUDE
# ============================================================================
elif vista == "🔍 Detección de Fraude":
    st.markdown('<div class="section-header">Sistema de Detección de Fraude</div>', unsafe_allow_html=True)
    
    # KPIs de fraude
    fraude_kpis_query = """
    SELECT 
        COUNT(DISTINCT ALERTA_ID) as total_alertas,
        COUNT(DISTINCT CASE WHEN ESTATUS_ALERTA IN ('NUEVA', 'EN_REVISION') THEN ALERTA_ID END) as alertas_activas,
        COUNT(DISTINCT CASE WHEN ESTATUS_ALERTA = 'CONFIRMADO_FRAUDE' THEN ALERTA_ID END) as fraudes_confirmados,
        COUNT(DISTINCT CASE WHEN ESTATUS_ALERTA = 'FALSO_POSITIVO' THEN ALERTA_ID END) as falsos_positivos,
        AVG(SCORE_FRAUDE) as score_promedio
    FROM AGILCREDIT_DB.CORE.ALERTAS_FRAUDE
    """
    
    kpis_fraude = ejecutar_query(fraude_kpis_query)
    
    if not kpis_fraude.empty:
        col1, col2, col3, col4, col5 = st.columns(5)
        
        with col1:
            st.metric("🚨 Total Alertas", f"{int(kpis_fraude['TOTAL_ALERTAS'].iloc[0]):,}")
        with col2:
            st.metric("⏳ Activas", f"{int(kpis_fraude['ALERTAS_ACTIVAS'].iloc[0]):,}")
        with col3:
            confirmados = int(kpis_fraude['FRAUDES_CONFIRMADOS'].iloc[0])
            st.metric("✅ Confirmados", f"{confirmados:,}", delta_color="inverse")
        with col4:
            falsos = int(kpis_fraude['FALSOS_POSITIVOS'].iloc[0])
            st.metric("❌ Falsos Positivos", f"{falsos:,}")
        with col5:
            score = kpis_fraude['SCORE_PROMEDIO'].iloc[0]
            st.metric("📊 Score Promedio", f"{score:.1f}")
    
    st.markdown("---")
    
    # Dashboard de fraude
    fraude_dashboard_query = """
    SELECT 
        TIPO_ALERTA,
        NIVEL_RIESGO,
        COUNT(DISTINCT ALERTA_ID) as TOTAL_ALERTAS,
        COUNT(DISTINCT CLIENTE_ID) as CLIENTES_AFECTADOS,
        AVG(SCORE_FRAUDE) as SCORE_PROMEDIO,
        SUM(CASE WHEN ESTATUS_ALERTA = 'CONFIRMADO_FRAUDE' THEN 1 ELSE 0 END) as FRAUDES_CONFIRMADOS
    FROM AGILCREDIT_DB.CORE.ALERTAS_FRAUDE
    GROUP BY TIPO_ALERTA, NIVEL_RIESGO
    ORDER BY TOTAL_ALERTAS DESC
    """
    
    df_fraude = ejecutar_query(fraude_dashboard_query)
    
    if not df_fraude.empty:
        col_izq, col_der = st.columns(2)
        
        with col_izq:
            st.markdown("### 🎯 Alertas por Tipo")
            fig_tipo = px.bar(
                df_fraude.groupby('TIPO_ALERTA')['TOTAL_ALERTAS'].sum().reset_index(),
                x='TIPO_ALERTA',
                y='TOTAL_ALERTAS',
                color='TOTAL_ALERTAS',
                color_continuous_scale='Reds'
            )
            fig_tipo.update_layout(showlegend=False, xaxis_tickangle=-45)
            st.plotly_chart(fig_tipo, use_container_width=True)
        
        with col_der:
            st.markdown("### ⚠️ Distribución por Nivel de Riesgo")
            fig_nivel = px.pie(
                df_fraude.groupby('NIVEL_RIESGO')['TOTAL_ALERTAS'].sum().reset_index(),
                values='TOTAL_ALERTAS',
                names='NIVEL_RIESGO',
                color='NIVEL_RIESGO',
                color_discrete_map={'ALTO': '#DC2626', 'MEDIO': '#F59E0B', 'BAJO': '#10B981'}
            )
            st.plotly_chart(fig_nivel, use_container_width=True)
        
        st.markdown("### 📋 Detalle de Alertas por Tipo y Nivel")
        st.dataframe(df_fraude, use_container_width=True)

# ============================================================================
# VISTA: RENTABILIDAD
# ============================================================================
elif vista == "💰 Rentabilidad":
    st.markdown('<div class="section-header">Análisis de Rentabilidad de Clientes</div>', unsafe_allow_html=True)
    
    # Rentabilidad por segmento
    rent_segmento_query = """
    SELECT * FROM AGILCREDIT_DB.ANALYTICS.V_RENTABILIDAD_SEGMENTOS
    ORDER BY UTILIDAD_NETA_TOTAL DESC
    """
    
    df_rent = ejecutar_query(rent_segmento_query)
    
    if not df_rent.empty:
        st.markdown("### 📊 Rentabilidad por Segmento")
        
        # Métricas principales
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("💵 Ingresos Totales", f"${df_rent['INGRESOS_TOTALES'].sum():,.0f}")
        with col2:
            st.metric("💰 Utilidad Neta", f"${df_rent['UTILIDAD_NETA_TOTAL'].sum():,.0f}")
        with col3:
            st.metric("📈 LTV Promedio", f"${df_rent['LTV_PROMEDIO'].mean():,.0f}")
        with col4:
            st.metric("🎯 Ratio LTV/CAC", f"{df_rent['RATIO_LTV_CAC_PROMEDIO'].mean():.2f}x")
        
        st.markdown("---")
        
        # Tabla de rentabilidad
        st.dataframe(
            df_rent.style.background_gradient(subset=['UTILIDAD_NETA_TOTAL'], cmap='Greens'),
            use_container_width=True
        )
        
        # Gráficas
        col_izq, col_der = st.columns(2)
        
        with col_izq:
            fig_util = px.bar(
                df_rent,
                x='SEGMENTO_CLIENTE',
                y='UTILIDAD_NETA_TOTAL',
                color='SEGMENTO_RENTABILIDAD',
                title='Utilidad Neta por Segmento'
            )
            st.plotly_chart(fig_util, use_container_width=True)
        
        with col_der:
            fig_ltv = px.scatter(
                df_rent,
                x='CAC_PROMEDIO',
                y='LTV_PROMEDIO',
                size='TOTAL_CLIENTES',
                color='SEGMENTO_CLIENTE',
                title='LTV vs CAC',
                labels={'CAC_PROMEDIO': 'CAC', 'LTV_PROMEDIO': 'LTV'}
            )
            # Línea de referencia LTV/CAC = 3
            fig_ltv.add_trace(go.Scatter(
                x=[0, df_rent['CAC_PROMEDIO'].max()],
                y=[0, df_rent['CAC_PROMEDIO'].max() * 3],
                mode='lines',
                name='LTV/CAC = 3.0 (objetivo)',
                line=dict(dash='dash', color='red')
            ))
            st.plotly_chart(fig_ltv, use_container_width=True)
    
    st.markdown("---")
    
    # Top clientes rentables
    st.markdown("### 🏆 Top 20 Clientes Más Rentables")
    
    top_clientes_query = """
    SELECT 
        c.CLIENTE_ID,
        c.NOMBRE || ' ' || c.APELLIDO_PATERNO as NOMBRE_COMPLETO,
        c.SEGMENTO_CLIENTE,
        r.INGRESOS_TOTALES,
        r.UTILIDAD_NETA,
        r.LTV_ESTIMADO,
        r.RATIO_LTV_CAC,
        r.SEGMENTO_RENTABILIDAD
    FROM AGILCREDIT_DB.CORE.CLIENTES c
    JOIN AGILCREDIT_DB.ANALYTICS.RENTABILIDAD_CLIENTES r ON c.CLIENTE_ID = r.CLIENTE_ID
    ORDER BY r.UTILIDAD_NETA DESC
    LIMIT 20
    """
    
    df_top = ejecutar_query(top_clientes_query)
    if not df_top.empty:
        st.dataframe(df_top, use_container_width=True)

# ============================================================================
# VISTA: CUMPLIMIENTO REGULATORIO
# ============================================================================
elif vista == "✅ Cumplimiento Regulatorio":
    st.markdown('<div class="section-header">Cumplimiento Regulatorio (KYC/PLD)</div>', unsafe_allow_html=True)
    
    # Status de cumplimiento
    cumplimiento_query = """
    SELECT 
        c.SEGMENTO_CLIENTE,
        COUNT(DISTINCT c.CLIENTE_ID) as TOTAL_CLIENTES,
        COUNT(DISTINCT CASE WHEN ec.RESULTADO = 'PENDIENTE' THEN c.CLIENTE_ID END) as PENDIENTES,
        COUNT(DISTINCT CASE WHEN ec.RESULTADO = 'RECHAZADO' THEN c.CLIENTE_ID END) as RECHAZADOS,
        COUNT(DISTINCT CASE WHEN DATEDIFF(day, MAX(ec.FECHA_EVENTO), CURRENT_DATE()) > 365 
              THEN c.CLIENTE_ID END) as REQUIERE_ACTUALIZACION,
        COUNT(DISTINCT CASE WHEN ec.RESULTADO = 'APROBADO' 
              AND DATEDIFF(day, MAX(ec.FECHA_EVENTO), CURRENT_DATE()) <= 365
              THEN c.CLIENTE_ID END) as CUMPLE
    FROM AGILCREDIT_DB.CORE.CLIENTES c
    LEFT JOIN AGILCREDIT_DB.COMPLIANCE.EVENTOS_CUMPLIMIENTO ec ON c.CLIENTE_ID = ec.CLIENTE_ID
    GROUP BY c.SEGMENTO_CLIENTE
    ORDER BY TOTAL_CLIENTES DESC
    """
    
    df_cumple = ejecutar_query(cumplimiento_query)
    
    if not df_cumple.empty:
        # Métricas generales
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("✅ Cumple", f"{df_cumple['CUMPLE'].sum():,}")
        with col2:
            pendientes = df_cumple['PENDIENTES'].sum()
            st.metric("⏳ Pendientes", f"{pendientes:,}", delta_color="off")
        with col3:
            requiere = df_cumple['REQUIERE_ACTUALIZACION'].sum()
            st.metric("🔄 Requiere Actualización", f"{requiere:,}", delta_color="inverse")
        with col4:
            rechazados = df_cumple['RECHAZADOS'].sum()
            st.metric("❌ Rechazados", f"{rechazados:,}", delta_color="inverse")
        
        st.markdown("---")
        
        # Tabla de status por segmento
        st.markdown("### 📊 Status de Cumplimiento por Segmento")
        st.dataframe(df_cumple, use_container_width=True)
        
        # Gráficas
        col_izq, col_der = st.columns(2)
        
        with col_izq:
            # Gráfica de cumplimiento
            df_cumple_melt = df_cumple.melt(
                id_vars=['SEGMENTO_CLIENTE'],
                value_vars=['CUMPLE', 'PENDIENTES', 'REQUIERE_ACTUALIZACION', 'RECHAZADOS'],
                var_name='STATUS',
                value_name='CANTIDAD'
            )
            
            fig_cumple = px.bar(
                df_cumple_melt,
                x='SEGMENTO_CLIENTE',
                y='CANTIDAD',
                color='STATUS',
                title='Status de Cumplimiento por Segmento',
                barmode='stack'
            )
            st.plotly_chart(fig_cumple, use_container_width=True)
        
        with col_der:
            # Porcentaje de cumplimiento
            df_cumple['PCT_CUMPLE'] = (df_cumple['CUMPLE'] / df_cumple['TOTAL_CLIENTES'] * 100).round(2)
            
            fig_pct = px.bar(
                df_cumple,
                x='SEGMENTO_CLIENTE',
                y='PCT_CUMPLE',
                title='Porcentaje de Cumplimiento por Segmento (%)',
                color='PCT_CUMPLE',
                color_continuous_scale='Greens'
            )
            st.plotly_chart(fig_pct, use_container_width=True)
    
    # Alertas de cumplimiento
    if requiere > 0:
        st.markdown('<div class="warning-box">⚠️ <strong>Atención:</strong> Hay {} clientes que requieren actualización de KYC (más de 365 días desde última verificación)</div>'.format(requiere), unsafe_allow_html=True)
    
    if pendientes > 0:
        st.markdown('<div class="warning-box">⏳ <strong>Pendiente:</strong> Hay {} clientes con eventos de cumplimiento pendientes de revisión</div>'.format(pendientes), unsafe_allow_html=True)

# ============================================================================
# VISTA: ANÁLISIS GEOGRÁFICO
# ============================================================================
elif vista == "📍 Análisis Geográfico":
    st.markdown('<div class="section-header">Concentración Geográfica de Cartera</div>', unsafe_allow_html=True)
    
    geo_query = """
    SELECT 
        c.ESTADO,
        c.CIUDAD,
        COUNT(DISTINCT c.CLIENTE_ID) as TOTAL_CLIENTES,
        COUNT(DISTINCT cr.CREDITO_ID) as TOTAL_CREDITOS,
        SUM(cr.SALDO_ACTUAL) as EXPOSICION_TOTAL,
        AVG(c.SCORE_RIESGO) as SCORE_RIESGO_PROMEDIO,
        COUNT(DISTINCT CASE WHEN cr.ESTATUS_CREDITO IN ('MORA', 'VENCIDO') 
              THEN cr.CREDITO_ID END) as CREDITOS_MOROSOS
    FROM AGILCREDIT_DB.CORE.CLIENTES c
    LEFT JOIN AGILCREDIT_DB.CORE.CREDITOS cr ON c.CLIENTE_ID = cr.CLIENTE_ID
    WHERE cr.ESTATUS_CREDITO IN ('VIGENTE', 'MORA', 'VENCIDO')
    GROUP BY c.ESTADO, c.CIUDAD
    ORDER BY EXPOSICION_TOTAL DESC
    LIMIT 20
    """
    
    df_geo = ejecutar_query(geo_query)
    
    if not df_geo.empty:
        df_geo['TASA_MOROSIDAD'] = (df_geo['CREDITOS_MOROSOS'] / df_geo['TOTAL_CREDITOS'] * 100).round(2)
        df_geo['PCT_CARTERA'] = (df_geo['EXPOSICION_TOTAL'] / df_geo['EXPOSICION_TOTAL'].sum() * 100).round(2)
        
        # Top estados
        st.markdown("### 🗺️ Top 20 Ubicaciones por Exposición")
        st.dataframe(
            df_geo.style.background_gradient(subset=['EXPOSICION_TOTAL'], cmap='Blues'),
            use_container_width=True
        )
        
        # Gráficas
        col_izq, col_der = st.columns(2)
        
        with col_izq:
            fig_exp_geo = px.bar(
                df_geo.head(10),
                x='CIUDAD',
                y='EXPOSICION_TOTAL',
                color='TASA_MOROSIDAD',
                title='Top 10 Ciudades por Exposición',
                color_continuous_scale='RdYlGn_r'
            )
            fig_exp_geo.update_layout(xaxis_tickangle=-45)
            st.plotly_chart(fig_exp_geo, use_container_width=True)
        
        with col_der:
            fig_treemap = px.treemap(
                df_geo.head(15),
                path=['ESTADO', 'CIUDAD'],
                values='EXPOSICION_TOTAL',
                color='TASA_MOROSIDAD',
                title='Distribución Geográfica de Cartera',
                color_continuous_scale='RdYlGn_r'
            )
            st.plotly_chart(fig_treemap, use_container_width=True)
        
        # Scatter plot: Exposición vs Morosidad
        st.markdown("### 📊 Exposición vs Tasa de Morosidad por Ciudad")
        fig_scatter = px.scatter(
            df_geo,
            x='EXPOSICION_TOTAL',
            y='TASA_MOROSIDAD',
            size='TOTAL_CLIENTES',
            color='ESTADO',
            hover_data=['CIUDAD'],
            title='Relación entre Exposición y Morosidad'
        )
        st.plotly_chart(fig_scatter, use_container_width=True)

# Footer
st.markdown("---")
st.markdown("""
<div style='text-align: center; color: #6B7280; padding: 1rem;'>
    <strong>AgilCredit S.A.P.I. de C.V. SOFOM E.N.R.</strong> | 
    Dashboard Analítico Ejecutivo | 
    Datos actualizados: {} | 
    Powered by Snowflake ❄️
</div>
""".format(datetime.now().strftime("%Y-%m-%d %H:%M")), unsafe_allow_html=True)



