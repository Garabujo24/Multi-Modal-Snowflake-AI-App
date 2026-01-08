"""
═══════════════════════════════════════════════════════════════════════════════
                    AGILCREDIT - SNOWFLAKE INTELLIGENCE COSTS DASHBOARD
                    Monitor de Costos de Servicios de IA y Análisis
═══════════════════════════════════════════════════════════════════════════════
Autor: AgilCredit Data Engineering Team
Fecha: Octubre 2025
Descripción: Dashboard interactivo para monitorear costos de Snowflake Intelligence
             incluyendo Cortex Analyst, Cortex Search, AI Services y Warehouses
═══════════════════════════════════════════════════════════════════════════════
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from datetime import datetime, timedelta
from snowflake.snowpark import Session
import json

# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURACIÓN DE LA PÁGINA
# ═══════════════════════════════════════════════════════════════════════════

st.set_page_config(
    page_title="AgilCredit Intelligence Costs",
    page_icon="💰",
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
        margin-bottom: 1rem;
    }
    .metric-card {
        background-color: #F0F9FF;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #3B82F6;
    }
    .warning-box {
        background-color: #FEF3C7;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #F59E0B;
    }
    .success-box {
        background-color: #D1FAE5;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #10B981;
    }
    </style>
""", unsafe_allow_html=True)

# ═══════════════════════════════════════════════════════════════════════════
# FUNCIONES DE CONEXIÓN
# ═══════════════════════════════════════════════════════════════════════════

@st.cache_resource
def create_snowflake_session(config):
    """Crear sesión de Snowflake con parámetros configurables"""
    try:
        connection_params = {
            "account": config["account"],
            "user": config["user"],
            "password": config["password"],
            "role": config.get("role", "ACCOUNTADMIN"),
            "warehouse": config.get("warehouse", "AGILCREDIT_WH"),
            "database": config.get("database", "AGILCREDIT_DB"),
            "schema": config.get("schema", "PUBLIC")
        }
        return Session.builder.configs(connection_params).create()
    except Exception as e:
        st.error(f"Error conectando a Snowflake: {str(e)}")
        return None

def load_config_from_file():
    """Cargar configuración desde archivo JSON si existe"""
    try:
        with open('snowflake_config.json', 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        return None

def save_config_to_file(config):
    """Guardar configuración a archivo JSON"""
    # No guardar password por seguridad
    config_to_save = {k: v for k, v in config.items() if k != 'password'}
    with open('snowflake_config.json', 'w') as f:
        json.dump(config_to_save, f, indent=2)

# ═══════════════════════════════════════════════════════════════════════════
# FUNCIONES DE CONSULTA DE DATOS
# ═══════════════════════════════════════════════════════════════════════════

@st.cache_data(ttl=300)  # Cache por 5 minutos
def get_cortex_analyst_usage(_session, days=30, username_filter=None):
    """Obtener uso de Cortex Analyst"""
    query = f"""
    SELECT
        DATE_TRUNC('day', start_time) AS usage_date,
        SUM(request_count) AS total_requests,
        SUM(credits) AS analyst_credits,
        username
    FROM snowflake.account_usage.cortex_analyst_usage_history
    WHERE start_time >= DATEADD(day, -{days}, CURRENT_DATE())
    """
    if username_filter:
        query += f" AND username = '{username_filter}'"
    query += """
    GROUP BY DATE_TRUNC('day', start_time), username
    ORDER BY usage_date DESC, analyst_credits DESC
    """
    return _session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def get_ai_services_usage(_session, days=30):
    """Obtener uso de AI Services"""
    query = f"""
    SELECT
        DATE_TRUNC('day', usage_date) as day,
        service_type,
        SUM(credits_used) as credits
    FROM snowflake.account_usage.metering_daily_history
    WHERE service_type = 'AI_SERVICES'
        AND usage_date >= DATEADD(day, -{days}, CURRENT_DATE())
    GROUP BY DATE_TRUNC('day', usage_date), service_type
    ORDER BY day DESC, credits DESC
    """
    return _session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def get_warehouse_usage(_session, warehouse_name, days=30):
    """Obtener uso de Warehouse"""
    query = f"""
    SELECT
        DATE_TRUNC('day', start_time) as usage_date,
        warehouse_name,
        SUM(credits_used_compute) as compute_credits,
        SUM(credits_used_cloud_services) as cloud_credits,
        SUM(credits_used) as total_credits
    FROM snowflake.account_usage.warehouse_metering_history
    WHERE warehouse_name ILIKE '%{warehouse_name}%'
        AND start_time >= DATEADD(day, -{days}, CURRENT_DATE())
    GROUP BY DATE_TRUNC('day', start_time), warehouse_name
    ORDER BY usage_date DESC, total_credits DESC
    """
    return _session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def get_cortex_search_usage(_session, days=30):
    """Obtener uso de Cortex Search"""
    query = f"""
    SELECT
        DATE_TRUNC('day', start_time) AS usage_date,
        service_name,
        database_name,
        schema_name,
        SUM(credits) AS search_credits,
        SUM(credits) * 2 AS cost_usd
    FROM snowflake.account_usage.cortex_search_serving_usage_history
    WHERE start_time >= DATEADD(day, -{days}, CURRENT_DATE())
    GROUP BY DATE_TRUNC('day', start_time), service_name, database_name, schema_name
    ORDER BY usage_date DESC, search_credits DESC
    """
    return _session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def get_complete_intelligence_costs(_session, warehouse_name, days=30):
    """Obtener rollup completo de costos de Intelligence"""
    query = f"""
    WITH analyst_costs AS (
        SELECT
            DATE_TRUNC('day', start_time) AS day,
            'Cortex Analyst (AI requests)' AS component,
            SUM(credits) AS credits
        FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_ANALYST_USAGE_HISTORY
        WHERE start_time >= DATEADD(day, -{days}, CURRENT_DATE())
        GROUP BY 1
    ),
    search_costs AS (
        SELECT
            usage_date AS day,
            'Cortex Search (Serving + Indexing)' AS component,
            SUM(credits) AS credits
        FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_SEARCH_DAILY_USAGE_HISTORY
        WHERE usage_date >= DATEADD(day, -{days}, CURRENT_DATE())
        GROUP BY 1
    ),
    warehouse_costs AS (
        SELECT
            DATE_TRUNC('day', start_time) AS day,
            'Warehouse (Analyst-generated SQL)' AS component,
            SUM(credits_used) AS credits
        FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
        WHERE start_time >= DATEADD(day, -{days}, CURRENT_DATE())
            AND warehouse_name ILIKE '%{warehouse_name}%'
        GROUP BY 1
    )
    SELECT
        day,
        component,
        credits,
        SUM(credits) OVER (PARTITION BY day) AS daily_total_credits
    FROM (
        SELECT * FROM analyst_costs
        UNION ALL
        SELECT * FROM search_costs
        UNION ALL
        SELECT * FROM warehouse_costs
    )
    ORDER BY day DESC, credits DESC
    """
    return _session.sql(query).to_pandas()

# ═══════════════════════════════════════════════════════════════════════════
# SIDEBAR - CONFIGURACIÓN
# ═══════════════════════════════════════════════════════════════════════════

st.sidebar.markdown("## ⚙️ Configuración")

# Intentar cargar configuración guardada
saved_config = load_config_from_file()

# Parámetros de conexión
with st.sidebar.expander("🔐 Conexión Snowflake", expanded=not saved_config):
    account = st.text_input(
        "Account", 
        value=saved_config.get("account", "") if saved_config else "",
        help="Tu cuenta de Snowflake (ej: abc12345.us-east-1)"
    )
    user = st.text_input(
        "Usuario", 
        value=saved_config.get("user", "") if saved_config else ""
    )
    password = st.text_input("Password", type="password")
    role = st.text_input(
        "Role", 
        value=saved_config.get("role", "ACCOUNTADMIN") if saved_config else "ACCOUNTADMIN"
    )
    warehouse = st.text_input(
        "Warehouse", 
        value=saved_config.get("warehouse", "AGILCREDIT_WH") if saved_config else "AGILCREDIT_WH"
    )
    
    if st.button("💾 Guardar Configuración"):
        config = {
            "account": account,
            "user": user,
            "role": role,
            "warehouse": warehouse
        }
        save_config_to_file(config)
        st.success("✅ Configuración guardada")

# Parámetros de análisis
st.sidebar.markdown("---")
st.sidebar.markdown("## 📊 Parámetros de Análisis")

days_back = st.sidebar.slider(
    "Días de histórico",
    min_value=7,
    max_value=90,
    value=30,
    help="Cantidad de días hacia atrás para analizar"
)

credit_cost_usd = st.sidebar.number_input(
    "Costo por crédito (USD)",
    min_value=0.0,
    max_value=10.0,
    value=2.0,
    step=0.1,
    help="Costo en dólares por crédito de Snowflake"
)

# Filtros opcionales
st.sidebar.markdown("---")
st.sidebar.markdown("## 🔍 Filtros")

filter_username = st.sidebar.text_input(
    "Filtrar por usuario (opcional)",
    help="Dejar vacío para ver todos"
)

# Botón de conexión
st.sidebar.markdown("---")
connect_button = st.sidebar.button("🔌 Conectar a Snowflake", type="primary")

# ═══════════════════════════════════════════════════════════════════════════
# MAIN - HEADER
# ═══════════════════════════════════════════════════════════════════════════

st.markdown('<p class="main-header">💰 AgilCredit Intelligence Costs Dashboard</p>', unsafe_allow_html=True)
st.markdown("### Monitoreo de Costos de Snowflake Intelligence Services")

# ═══════════════════════════════════════════════════════════════════════════
# CONEXIÓN Y CARGA DE DATOS
# ═══════════════════════════════════════════════════════════════════════════

if not connect_button and 'session' not in st.session_state:
    st.info("👈 Configura tus credenciales en la barra lateral y haz clic en 'Conectar a Snowflake'")
    st.stop()

if connect_button or 'session' in st.session_state:
    if connect_button:
        with st.spinner("Conectando a Snowflake..."):
            config = {
                "account": account,
                "user": user,
                "password": password,
                "role": role,
                "warehouse": warehouse
            }
            session = create_snowflake_session(config)
            if session:
                st.session_state.session = session
                st.success("✅ Conectado exitosamente")
            else:
                st.error("❌ Error en la conexión. Verifica tus credenciales.")
                st.stop()
    
    session = st.session_state.session
    
    # Cargar datos
    with st.spinner("Cargando datos de uso..."):
        try:
            df_analyst = get_cortex_analyst_usage(session, days_back, filter_username if filter_username else None)
            df_ai_services = get_ai_services_usage(session, days_back)
            df_warehouse = get_warehouse_usage(session, warehouse, days_back)
            df_search = get_cortex_search_usage(session, days_back)
            df_complete = get_complete_intelligence_costs(session, warehouse, days_back)
        except Exception as e:
            st.error(f"Error cargando datos: {str(e)}")
            st.info("Asegúrate de que tu rol tenga acceso a SNOWFLAKE.ACCOUNT_USAGE")
            st.stop()

    # ═══════════════════════════════════════════════════════════════════════
    # TABS PRINCIPALES
    # ═══════════════════════════════════════════════════════════════════════
    
    tab1, tab2, tab3, tab4, tab5 = st.tabs([
        "📈 Overview", 
        "🤖 Cortex Analyst", 
        "🔍 Cortex Search", 
        "🏢 Warehouse", 
        "💸 Consolidado"
    ])
    
    # ═══════════════════════════════════════════════════════════════════════
    # TAB 1: OVERVIEW
    # ═══════════════════════════════════════════════════════════════════════
    
    with tab1:
        st.markdown("## 📊 Resumen General de Costos")
        
        # KPIs principales
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            total_analyst_credits = df_analyst['ANALYST_CREDITS'].sum() if not df_analyst.empty else 0
            st.metric(
                "💬 Cortex Analyst",
                f"{total_analyst_credits:.2f} créditos",
                f"${total_analyst_credits * credit_cost_usd:.2f} USD"
            )
        
        with col2:
            total_warehouse_credits = df_warehouse['TOTAL_CREDITS'].sum() if not df_warehouse.empty else 0
            st.metric(
                "🏢 Warehouse",
                f"{total_warehouse_credits:.2f} créditos",
                f"${total_warehouse_credits * credit_cost_usd:.2f} USD"
            )
        
        with col3:
            total_search_credits = df_search['SEARCH_CREDITS'].sum() if not df_search.empty else 0
            st.metric(
                "🔍 Cortex Search",
                f"{total_search_credits:.2f} créditos",
                f"${total_search_credits * credit_cost_usd:.2f} USD"
            )
        
        with col4:
            total_credits = total_analyst_credits + total_warehouse_credits + total_search_credits
            st.metric(
                "💰 TOTAL",
                f"{total_credits:.2f} créditos",
                f"${total_credits * credit_cost_usd:.2f} USD"
            )
        
        st.markdown("---")
        
        # Gráfico de tendencia consolidado
        if not df_complete.empty:
            st.markdown("### 📈 Tendencia de Costos por Componente")
            
            fig = px.area(
                df_complete,
                x='DAY',
                y='CREDITS',
                color='COMPONENT',
                title=f'Créditos Consumidos - Últimos {days_back} Días',
                labels={'DAY': 'Fecha', 'CREDITS': 'Créditos', 'COMPONENT': 'Componente'}
            )
            fig.update_layout(height=500, hovermode='x unified')
            st.plotly_chart(fig, use_container_width=True)
            
            # Gráfico de distribución
            col1, col2 = st.columns(2)
            
            with col1:
                # Pie chart de distribución
                total_by_component = df_complete.groupby('COMPONENT')['CREDITS'].sum().reset_index()
                fig_pie = px.pie(
                    total_by_component,
                    values='CREDITS',
                    names='COMPONENT',
                    title='Distribución de Costos por Componente',
                    hole=0.4
                )
                st.plotly_chart(fig_pie, use_container_width=True)
            
            with col2:
                # Tabla de resumen
                st.markdown("#### 📋 Resumen por Componente")
                summary = total_by_component.copy()
                summary['COST_USD'] = summary['CREDITS'] * credit_cost_usd
                summary['PERCENTAGE'] = (summary['CREDITS'] / summary['CREDITS'].sum() * 100).round(2)
                summary.columns = ['Componente', 'Créditos', 'Costo USD', '% del Total']
                st.dataframe(
                    summary.style.format({
                        'Créditos': '{:.2f}',
                        'Costo USD': '${:.2f}',
                        '% del Total': '{:.2f}%'
                    }),
                    hide_index=True,
                    use_container_width=True
                )
    
    # ═══════════════════════════════════════════════════════════════════════
    # TAB 2: CORTEX ANALYST
    # ═══════════════════════════════════════════════════════════════════════
    
    with tab2:
        st.markdown("## 🤖 Cortex Analyst - Uso y Costos")
        
        if df_analyst.empty:
            st.warning("No hay datos de Cortex Analyst para el periodo seleccionado")
        else:
            # KPIs
            col1, col2, col3, col4 = st.columns(4)
            
            with col1:
                st.metric(
                    "Total Requests",
                    f"{df_analyst['TOTAL_REQUESTS'].sum():,.0f}"
                )
            
            with col2:
                st.metric(
                    "Total Créditos",
                    f"{df_analyst['ANALYST_CREDITS'].sum():.2f}"
                )
            
            with col3:
                avg_credits_per_request = df_analyst['ANALYST_CREDITS'].sum() / df_analyst['TOTAL_REQUESTS'].sum()
                st.metric(
                    "Créditos por Request",
                    f"{avg_credits_per_request:.4f}"
                )
            
            with col4:
                unique_users = df_analyst['USERNAME'].nunique()
                st.metric(
                    "Usuarios Únicos",
                    f"{unique_users}"
                )
            
            st.markdown("---")
            
            # Gráficos
            col1, col2 = st.columns(2)
            
            with col1:
                # Tendencia de requests
                daily_requests = df_analyst.groupby('USAGE_DATE')['TOTAL_REQUESTS'].sum().reset_index()
                fig = px.line(
                    daily_requests,
                    x='USAGE_DATE',
                    y='TOTAL_REQUESTS',
                    title='Requests Diarios',
                    markers=True
                )
                fig.update_layout(height=400)
                st.plotly_chart(fig, use_container_width=True)
            
            with col2:
                # Tendencia de créditos
                daily_credits = df_analyst.groupby('USAGE_DATE')['ANALYST_CREDITS'].sum().reset_index()
                fig = px.bar(
                    daily_credits,
                    x='USAGE_DATE',
                    y='ANALYST_CREDITS',
                    title='Créditos Consumidos Diarios',
                    color='ANALYST_CREDITS',
                    color_continuous_scale='Blues'
                )
                fig.update_layout(height=400, showlegend=False)
                st.plotly_chart(fig, use_container_width=True)
            
            # Uso por usuario
            st.markdown("### 👥 Uso por Usuario")
            user_summary = df_analyst.groupby('USERNAME').agg({
                'TOTAL_REQUESTS': 'sum',
                'ANALYST_CREDITS': 'sum'
            }).reset_index()
            user_summary['COST_USD'] = user_summary['ANALYST_CREDITS'] * credit_cost_usd
            user_summary['AVG_CREDITS_PER_REQUEST'] = user_summary['ANALYST_CREDITS'] / user_summary['TOTAL_REQUESTS']
            user_summary.columns = ['Usuario', 'Total Requests', 'Total Créditos', 'Costo USD', 'Avg Créditos/Request']
            
            fig = px.bar(
                user_summary,
                x='Usuario',
                y='Total Créditos',
                color='Total Créditos',
                title='Consumo de Créditos por Usuario',
                text='Total Créditos'
            )
            fig.update_traces(texttemplate='%{text:.2f}', textposition='outside')
            st.plotly_chart(fig, use_container_width=True)
            
            st.dataframe(
                user_summary.style.format({
                    'Total Requests': '{:,.0f}',
                    'Total Créditos': '{:.2f}',
                    'Costo USD': '${:.2f}',
                    'Avg Créditos/Request': '{:.4f}'
                }),
                hide_index=True,
                use_container_width=True
            )
    
    # ═══════════════════════════════════════════════════════════════════════
    # TAB 3: CORTEX SEARCH
    # ═══════════════════════════════════════════════════════════════════════
    
    with tab3:
        st.markdown("## 🔍 Cortex Search - Uso y Costos")
        
        if df_search.empty:
            st.info("No hay datos de Cortex Search para el periodo seleccionado")
        else:
            # KPIs
            col1, col2, col3 = st.columns(3)
            
            with col1:
                st.metric(
                    "Total Créditos",
                    f"{df_search['SEARCH_CREDITS'].sum():.2f}"
                )
            
            with col2:
                st.metric(
                    "Costo Estimado USD",
                    f"${df_search['COST_USD'].sum():.2f}"
                )
            
            with col3:
                st.metric(
                    "Servicios Activos",
                    f"{df_search['SERVICE_NAME'].nunique()}"
                )
            
            st.markdown("---")
            
            # Tendencia temporal
            daily_search = df_search.groupby('USAGE_DATE')['SEARCH_CREDITS'].sum().reset_index()
            fig = px.area(
                daily_search,
                x='USAGE_DATE',
                y='SEARCH_CREDITS',
                title='Créditos de Search Diarios',
                labels={'USAGE_DATE': 'Fecha', 'SEARCH_CREDITS': 'Créditos'}
            )
            st.plotly_chart(fig, use_container_width=True)
            
            # Uso por servicio
            service_summary = df_search.groupby('SERVICE_NAME').agg({
                'SEARCH_CREDITS': 'sum',
                'COST_USD': 'sum'
            }).reset_index().sort_values('SEARCH_CREDITS', ascending=False)
            
            col1, col2 = st.columns(2)
            
            with col1:
                fig = px.bar(
                    service_summary,
                    x='SERVICE_NAME',
                    y='SEARCH_CREDITS',
                    title='Créditos por Servicio',
                    color='SEARCH_CREDITS'
                )
                st.plotly_chart(fig, use_container_width=True)
            
            with col2:
                st.markdown("#### 📋 Detalle por Servicio")
                st.dataframe(
                    service_summary.style.format({
                        'SEARCH_CREDITS': '{:.2f}',
                        'COST_USD': '${:.2f}'
                    }),
                    hide_index=True,
                    use_container_width=True
                )
    
    # ═══════════════════════════════════════════════════════════════════════
    # TAB 4: WAREHOUSE
    # ═══════════════════════════════════════════════════════════════════════
    
    with tab4:
        st.markdown("## 🏢 Warehouse - Consumo de Créditos")
        
        if df_warehouse.empty:
            st.warning(f"No hay datos para el warehouse '{warehouse}'")
        else:
            # KPIs
            col1, col2, col3, col4 = st.columns(4)
            
            with col1:
                st.metric(
                    "Compute Credits",
                    f"{df_warehouse['COMPUTE_CREDITS'].sum():.2f}"
                )
            
            with col2:
                st.metric(
                    "Cloud Services",
                    f"{df_warehouse['CLOUD_CREDITS'].sum():.2f}"
                )
            
            with col3:
                st.metric(
                    "Total Credits",
                    f"{df_warehouse['TOTAL_CREDITS'].sum():.2f}"
                )
            
            with col4:
                total_cost = df_warehouse['TOTAL_CREDITS'].sum() * credit_cost_usd
                st.metric(
                    "Costo Total USD",
                    f"${total_cost:.2f}"
                )
            
            st.markdown("---")
            
            # Gráfico de tendencia
            fig = go.Figure()
            fig.add_trace(go.Scatter(
                x=df_warehouse['USAGE_DATE'],
                y=df_warehouse['COMPUTE_CREDITS'],
                name='Compute',
                fill='tonexty',
                mode='lines+markers'
            ))
            fig.add_trace(go.Scatter(
                x=df_warehouse['USAGE_DATE'],
                y=df_warehouse['CLOUD_CREDITS'],
                name='Cloud Services',
                fill='tozeroy',
                mode='lines+markers'
            ))
            fig.update_layout(
                title='Consumo de Créditos por Tipo',
                xaxis_title='Fecha',
                yaxis_title='Créditos',
                hovermode='x unified',
                height=500
            )
            st.plotly_chart(fig, use_container_width=True)
            
            # Distribución
            col1, col2 = st.columns(2)
            
            with col1:
                total_compute = df_warehouse['COMPUTE_CREDITS'].sum()
                total_cloud = df_warehouse['CLOUD_CREDITS'].sum()
                
                fig = go.Figure(data=[go.Pie(
                    labels=['Compute Credits', 'Cloud Services'],
                    values=[total_compute, total_cloud],
                    hole=.3
                )])
                fig.update_layout(title='Distribución de Créditos')
                st.plotly_chart(fig, use_container_width=True)
            
            with col2:
                st.markdown("#### 📊 Estadísticas")
                st.metric("Promedio Diario", f"{df_warehouse['TOTAL_CREDITS'].mean():.2f} créditos")
                st.metric("Día Máximo", f"{df_warehouse['TOTAL_CREDITS'].max():.2f} créditos")
                st.metric("Día Mínimo", f"{df_warehouse['TOTAL_CREDITS'].min():.2f} créditos")
    
    # ═══════════════════════════════════════════════════════════════════════
    # TAB 5: CONSOLIDADO
    # ═══════════════════════════════════════════════════════════════════════
    
    with tab5:
        st.markdown("## 💸 Vista Consolidada de Costos")
        
        if df_complete.empty:
            st.warning("No hay datos consolidados disponibles")
        else:
            # Tabla resumen
            st.markdown("### 📋 Resumen Completo")
            
            summary_by_component = df_complete.groupby('COMPONENT').agg({
                'CREDITS': ['sum', 'mean', 'max']
            }).round(2)
            summary_by_component.columns = ['Total Créditos', 'Promedio Diario', 'Máximo Diario']
            summary_by_component['Costo Total USD'] = summary_by_component['Total Créditos'] * credit_cost_usd
            summary_by_component['% del Total'] = (summary_by_component['Total Créditos'] / summary_by_component['Total Créditos'].sum() * 100).round(2)
            
            st.dataframe(
                summary_by_component.style.format({
                    'Total Créditos': '{:.2f}',
                    'Promedio Diario': '{:.2f}',
                    'Máximo Diario': '{:.2f}',
                    'Costo Total USD': '${:.2f}',
                    '% del Total': '{:.2f}%'
                }),
                use_container_width=True
            )
            
            # Proyección
            st.markdown("---")
            st.markdown("### 📈 Proyección de Costos")
            
            avg_daily_credits = df_complete.groupby('DAY')['DAILY_TOTAL_CREDITS'].first().mean()
            
            col1, col2, col3 = st.columns(3)
            
            with col1:
                monthly_projection = avg_daily_credits * 30
                st.metric(
                    "Proyección Mensual",
                    f"{monthly_projection:.2f} créditos",
                    f"${monthly_projection * credit_cost_usd:.2f} USD"
                )
            
            with col2:
                quarterly_projection = avg_daily_credits * 90
                st.metric(
                    "Proyección Trimestral",
                    f"{quarterly_projection:.2f} créditos",
                    f"${quarterly_projection * credit_cost_usd:.2f} USD"
                )
            
            with col3:
                annual_projection = avg_daily_credits * 365
                st.metric(
                    "Proyección Anual",
                    f"{annual_projection:.2f} créditos",
                    f"${annual_projection * credit_cost_usd:.2f} USD"
                )
            
            # Descargar datos
            st.markdown("---")
            st.markdown("### 💾 Exportar Datos")
            
            csv = df_complete.to_csv(index=False)
            st.download_button(
                label="📥 Descargar Datos Consolidados (CSV)",
                data=csv,
                file_name=f"agilcredit_intelligence_costs_{datetime.now().strftime('%Y%m%d')}.csv",
                mime="text/csv"
            )

# ═══════════════════════════════════════════════════════════════════════════
# FOOTER
# ═══════════════════════════════════════════════════════════════════════════

st.markdown("---")
st.markdown("""
<div style='text-align: center; color: #6B7280;'>
    <p>AgilCredit SOFOM E.N.R. | Dashboard de Costos de Intelligence</p>
    <p style='font-size: 0.8rem;'>Última actualización: {}</p>
</div>
""".format(datetime.now().strftime("%Y-%m-%d %H:%M:%S")), unsafe_allow_html=True)



