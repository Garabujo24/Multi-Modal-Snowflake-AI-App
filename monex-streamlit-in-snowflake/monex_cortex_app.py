"""
MONEX GRUPO FINANCIERO - CORTEX AI PLATFORM
Aplicación Streamlit que integra Cortex Analyst y Cortex Search
"""

import streamlit as st
import snowflake.connector
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import json
from datetime import datetime, timedelta
import base64

# ===== CONFIGURACIÓN DE PÁGINA =====
st.set_page_config(
    page_title="Monex Cortex AI Platform",
    page_icon="🏦",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ===== COLORES CORPORATIVOS MONEX =====
MONEX_COLORS = {
    'primary_blue': '#0064bb',      # Azul principal Monex
    'secondary_blue': '#285b87',    # Azul secundario
    'dark_blue': '#003b6f',         # Azul oscuro
    'light_blue': '#387ebb',        # Azul claro
    'navy': '#00203c',              # Azul marino
    'white': '#ffffff',
    'light_gray': '#f8f9fa',
    'gray': '#6c757d',
    'success': '#28a745',
    'warning': '#ffc107',
    'danger': '#dc3545'
}

# ===== CSS PERSONALIZADO =====
def load_css():
    st.markdown(f"""
    <style>
    /* Variables CSS */
    :root {{
        --monex-primary: {MONEX_COLORS['primary_blue']};
        --monex-secondary: {MONEX_COLORS['secondary_blue']};
        --monex-dark: {MONEX_COLORS['dark_blue']};
        --monex-light: {MONEX_COLORS['light_blue']};
        --monex-navy: {MONEX_COLORS['navy']};
    }}
    
    /* Estilo general */
    .main {{
        background-color: {MONEX_COLORS['light_gray']};
    }}
    
    /* Header personalizado */
    .monex-header {{
        background: linear-gradient(135deg, var(--monex-primary) 0%, var(--monex-secondary) 100%);
        padding: 2rem;
        border-radius: 10px;
        margin-bottom: 2rem;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }}
    
    .monex-logo {{
        color: white;
        font-size: 2.5rem;
        font-weight: bold;
        text-align: center;
        margin: 0;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    }}
    
    .monex-subtitle {{
        color: white;
        font-size: 1.2rem;
        text-align: center;
        margin: 0.5rem 0 0 0;
        opacity: 0.9;
    }}
    
    /* Métricas personalizadas */
    .metric-card {{
        background: white;
        padding: 1.5rem;
        border-radius: 10px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        border-left: 4px solid var(--monex-primary);
        margin-bottom: 1rem;
    }}
    
    .metric-value {{
        font-size: 2rem;
        font-weight: bold;
        color: var(--monex-primary);
        margin: 0;
    }}
    
    .metric-label {{
        font-size: 0.9rem;
        color: var(--monex-secondary);
        margin: 0;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }}
    
    /* Botones */
    .stButton > button {{
        background: linear-gradient(135deg, var(--monex-primary) 0%, var(--monex-light) 100%);
        color: white;
        border: none;
        border-radius: 8px;
        padding: 0.5rem 2rem;
        font-weight: bold;
        transition: all 0.3s ease;
    }}
    
    .stButton > button:hover {{
        background: linear-gradient(135deg, var(--monex-dark) 0%, var(--monex-primary) 100%);
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.2);
    }}
    
    /* Sidebar */
    .css-1d391kg {{
        background-color: var(--monex-navy);
    }}
    
    /* Selectbox */
    .stSelectbox > div > div {{
        border-color: var(--monex-primary);
    }}
    
    /* Tabs */
    .stTabs [data-baseweb="tab-list"] {{
        gap: 2px;
    }}
    
    .stTabs [data-baseweb="tab"] {{
        background-color: white;
        border: 2px solid var(--monex-primary);
        color: var(--monex-primary);
        font-weight: bold;
        border-radius: 8px 8px 0 0;
    }}
    
    .stTabs [aria-selected="true"] {{
        background-color: var(--monex-primary);
        color: white;
    }}
    
    /* Alertas */
    .alert-info {{
        background-color: #e3f2fd;
        border-left: 4px solid var(--monex-primary);
        padding: 1rem;
        border-radius: 4px;
        margin: 1rem 0;
    }}
    
    /* Chat messages */
    .chat-message {{
        background: white;
        padding: 1rem;
        border-radius: 10px;
        margin: 0.5rem 0;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }}
    
    .user-message {{
        background: linear-gradient(135deg, var(--monex-light) 0%, var(--monex-primary) 100%);
        color: white;
        margin-left: 2rem;
    }}
    
    .assistant-message {{
        background: white;
        border-left: 4px solid var(--monex-primary);
        margin-right: 2rem;
    }}
    
    /* Scrollbar personalizado */
    ::-webkit-scrollbar {{
        width: 8px;
        height: 8px;
    }}
    
    ::-webkit-scrollbar-track {{
        background: #f1f1f1;
    }}
    
    ::-webkit-scrollbar-thumb {{
        background: var(--monex-primary);
        border-radius: 4px;
    }}
    
    ::-webkit-scrollbar-thumb:hover {{
        background: var(--monex-dark);
    }}
    
    /* Ocultar elementos de Streamlit */
    #MainMenu {{visibility: hidden;}}
    .stDeployButton {{display:none;}}
    footer {{visibility: hidden;}}
    .stApp > header {{visibility: hidden;}}
    </style>
    """, unsafe_allow_html=True)

# ===== CONEXIÓN A SNOWFLAKE =====
@st.cache_resource
def init_snowflake_connection():
    """Inicializar conexión a Snowflake"""
    try:
        # Cuando se ejecuta en Snowflake, usar la conexión de la sesión actual
        conn = st.connection("snowflake")
        return conn
    except Exception as e:
        try:
            # Fallback para desarrollo local con secrets
            conn = snowflake.connector.connect(
                user=st.secrets["snowflake"]["user"],
                password=st.secrets["snowflake"]["password"],
                account=st.secrets["snowflake"]["account"],
                warehouse=st.secrets["snowflake"]["warehouse"],
                database=st.secrets["snowflake"]["database"],
                schema=st.secrets["snowflake"]["schema"]
            )
            return conn
        except Exception as e2:
            st.error(f"Error conectando a Snowflake: {str(e2)}")
            st.info("💡 **Nota:** Si ejecutas localmente, necesitas configurar secrets.toml")
            st.code('''
# Para desarrollo local - crear archivo .streamlit/secrets.toml:
[snowflake]
user = "tu_usuario"
password = "tu_password"
account = "tu_account"
warehouse = "MONEX_CORTEX_WH"
database = "MONEX_GRUPO_FINANCIERO"
schema = "CORE_BANKING"
            ''')
            return None

# ===== FUNCIONES DE DATOS =====
@st.cache_data(ttl=300)  # Cache por 5 minutos
def execute_query(query):
    """Ejecutar query en Snowflake y retornar DataFrame"""
    conn = init_snowflake_connection()
    if conn is None:
        return pd.DataFrame()
    
    try:
        # Si es una conexión de Streamlit (en Snowflake)
        if hasattr(conn, 'query'):
            df = conn.query(query)
            return df
        else:
            # Si es una conexión directa (desarrollo local)
            df = pd.read_sql(query, conn)
            return df
    except Exception as e:
        st.error(f"Error ejecutando query: {str(e)}")
        return pd.DataFrame()
    finally:
        # Solo cerrar si es conexión directa
        if hasattr(conn, 'close'):
            conn.close()

@st.cache_data(ttl=300)
def get_dashboard_metrics():
    """Obtener métricas para el dashboard"""
    queries = {
        'total_clientes': "SELECT COUNT(*) as total FROM CORE_BANKING.CLIENTES WHERE estatus = 'ACTIVO'",
        'total_contratos': "SELECT COUNT(*) as total FROM CORE_BANKING.CONTRATOS WHERE estatus = 'VIGENTE'",
        'volumen_transacciones': """
            SELECT COALESCE(ROUND(SUM(monto_mxn)/1000000, 2), 0) as total 
            FROM CORE_BANKING.TRANSACCIONES 
            WHERE fecha_transaccion >= CURRENT_DATE() - 30
        """,
        'ingresos_comisiones': """
            SELECT COALESCE(ROUND(SUM(comision + iva)/1000, 2), 0) as total 
            FROM CORE_BANKING.TRANSACCIONES 
            WHERE fecha_transaccion >= CURRENT_DATE() - 30 
            AND estatus = 'PROCESADA'
        """
    }
    
    metrics = {}
    for key, query in queries.items():
        try:
            df = execute_query(query)
            if not df.empty and df.iloc[0, 0] is not None:
                metrics[key] = float(df.iloc[0, 0])
            else:
                metrics[key] = 0.0
        except Exception as e:
            st.warning(f"Error obteniendo métrica {key}: {str(e)}")
            metrics[key] = 0.0
    
    return metrics

def cortex_search(query, filters=None, limit=5):
    """Realizar búsqueda con Cortex Search"""
    try:
        search_params = {
            "limit": limit
        }
        if filters:
            search_params["filters"] = filters
        
        search_query = f"""
        SELECT * FROM TABLE(
            CORTEX_SEARCH(
                'MONEX_DOCUMENTS_SEARCH',
                '{query}',
                '{json.dumps(search_params)}'
            )
        )
        """
        
        df = execute_query(search_query)
        return df.to_dict('records') if not df.empty else []
    
    except Exception as e:
        st.error(f"Error en Cortex Search: {str(e)}")
        return []

def cortex_analyst_query(question):
    """Simular consulta a Cortex Analyst"""
    # Por ahora simularemos respuestas, en producción usarías el API de Cortex Analyst
    responses = {
        "clientes por segmento": {
            "query": "SELECT segmento, COUNT(*) as clientes FROM CORE_BANKING.CLIENTES GROUP BY segmento",
            "description": "Distribución de clientes por segmento de negocio"
        },
        "transacciones mensuales": {
            "query": """SELECT 
                DATE_TRUNC('MONTH', fecha_transaccion) as mes,
                COUNT(*) as transacciones,
                SUM(monto_mxn) as volumen
                FROM CORE_BANKING.TRANSACCIONES 
                WHERE fecha_transaccion >= CURRENT_DATE() - 365
                GROUP BY mes ORDER BY mes DESC""",
            "description": "Volumen de transacciones por mes en el último año"
        },
        "utilización crédito": {
            "query": """SELECT 
                c.segmento,
                ROUND((SUM(ct.saldo_actual) / SUM(ct.monto_autorizado)) * 100, 2) as utilizacion_pct
                FROM CORE_BANKING.CONTRATOS ct
                JOIN CORE_BANKING.CLIENTES c ON ct.cliente_id = c.cliente_id
                JOIN CORE_BANKING.PRODUCTOS p ON ct.producto_id = p.producto_id
                WHERE p.categoria = 'CREDITO' AND ct.estatus = 'VIGENTE'
                GROUP BY c.segmento""",
            "description": "Porcentaje de utilización de líneas de crédito por segmento"
        }
    }
    
    # Buscar respuesta más relevante
    for key, response in responses.items():
        if key.lower() in question.lower():
            return response
    
    return None

# ===== COMPONENTES UI =====
def render_header():
    """Renderizar header de Monex"""
    st.markdown("""
    <div class="monex-header">
        <h1 class="monex-logo">🏦 MONEX GRUPO FINANCIERO</h1>
        <p class="monex-subtitle">Plataforma de Inteligencia Artificial Cortex</p>
    </div>
    """, unsafe_allow_html=True)

def render_metric_card(label, value, format_type="number"):
    """Renderizar tarjeta de métrica"""
    # Manejar valores None o no numéricos
    if value is None:
        value = 0
    
    try:
        value = float(value)
    except (ValueError, TypeError):
        value = 0.0
    
    if format_type == "currency":
        formatted_value = f"${value:,.0f}"
    elif format_type == "millions":
        formatted_value = f"${value:.1f}M"
    elif format_type == "thousands":
        formatted_value = f"${value:.0f}K"
    else:
        formatted_value = f"{value:,.0f}"
    
    st.markdown(f"""
    <div class="metric-card">
        <p class="metric-value">{formatted_value}</p>
        <p class="metric-label">{label}</p>
    </div>
    """, unsafe_allow_html=True)

def render_chart(df, chart_type, title, x_col, y_col):
    """Renderizar gráfico con estilo Monex"""
    if df.empty:
        st.warning("No hay datos disponibles para mostrar")
        return
    
    color_palette = [MONEX_COLORS['primary_blue'], MONEX_COLORS['light_blue'], 
                    MONEX_COLORS['secondary_blue'], MONEX_COLORS['dark_blue']]
    
    if chart_type == "bar":
        fig = px.bar(df, x=x_col, y=y_col, title=title, 
                    color_discrete_sequence=color_palette)
    elif chart_type == "pie":
        fig = px.pie(df, names=x_col, values=y_col, title=title,
                    color_discrete_sequence=color_palette)
    elif chart_type == "line":
        fig = px.line(df, x=x_col, y=y_col, title=title,
                     color_discrete_sequence=color_palette)
    
    fig.update_layout(
        plot_bgcolor='white',
        paper_bgcolor='white',
        font_color=MONEX_COLORS['navy'],
        title_font_size=16,
        title_font_color=MONEX_COLORS['primary_blue']
    )
    
    st.plotly_chart(fig, use_container_width=True)

# ===== PÁGINA PRINCIPAL =====
def main():
    load_css()
    render_header()
    
    # Sidebar
    with st.sidebar:
        st.markdown("### 🎯 Navegación")
        page = st.selectbox(
            "Selecciona una función:",
            ["📊 Dashboard Ejecutivo", "🤖 Cortex Analyst", "🔍 Cortex Search", "📈 Análisis Avanzado"]
        )
        
        st.markdown("---")
        st.markdown("### ℹ️ Información")
        st.info("""
        **Monex Cortex AI Platform**
        
        Plataforma integrada que combina:
        - 🤖 **Cortex Analyst**: Análisis inteligente de datos
        - 🔍 **Cortex Search**: Búsqueda semántica de documentos
        - 📊 **Visualizaciones**: Dashboards interactivos
        """)
    
    # Contenido principal basado en selección
    if page == "📊 Dashboard Ejecutivo":
        dashboard_page()
    elif page == "🤖 Cortex Analyst":
        cortex_analyst_page()
    elif page == "🔍 Cortex Search":
        cortex_search_page()
    elif page == "📈 Análisis Avanzado":
        advanced_analytics_page()

def dashboard_page():
    """Página de dashboard ejecutivo"""
    st.markdown("## 📊 Dashboard Ejecutivo")
    st.markdown("Vista general de métricas clave del negocio")
    
    # Métricas principales
    metrics = get_dashboard_metrics()
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        render_metric_card("Clientes Activos", metrics['total_clientes'])
    
    with col2:
        render_metric_card("Contratos Vigentes", metrics['total_contratos'])
    
    with col3:
        render_metric_card("Volumen 30d", metrics['volumen_transacciones'], "millions")
    
    with col4:
        render_metric_card("Ingresos Comisiones", metrics['ingresos_comisiones'], "thousands")
    
    # Gráficos
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("### Distribución por Segmento")
        df_segmentos = execute_query("""
            SELECT segmento, COUNT(*) as clientes 
            FROM CORE_BANKING.CLIENTES 
            WHERE estatus = 'ACTIVO'
            GROUP BY segmento
        """)
        if not df_segmentos.empty:
            render_chart(df_segmentos, "pie", "Clientes por Segmento", "segmento", "clientes")
    
    with col2:
        st.markdown("### Transacciones por Canal")
        df_canales = execute_query("""
            SELECT canal, COUNT(*) as transacciones 
            FROM CORE_BANKING.TRANSACCIONES 
            WHERE fecha_transaccion >= CURRENT_DATE() - 30
            GROUP BY canal
        """)
        if not df_canales.empty:
            render_chart(df_canales, "bar", "Transacciones por Canal (30d)", "canal", "transacciones")

def cortex_analyst_page():
    """Página de Cortex Analyst"""
    st.markdown("## 🤖 Cortex Analyst")
    st.markdown("Realiza preguntas en lenguaje natural sobre tus datos financieros")
    
    # Input de pregunta
    question = st.text_input(
        "💬 Haz una pregunta sobre los datos:",
        placeholder="Ej: ¿Cuántos clientes tenemos por segmento?",
        help="Puedes preguntar sobre clientes, transacciones, productos, etc."
    )
    
    # Preguntas sugeridas
    st.markdown("### 💡 Preguntas Sugeridas")
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("👥 Clientes por segmento"):
            question = "clientes por segmento"
    
    with col2:
        if st.button("📈 Transacciones mensuales"):
            question = "transacciones mensuales"
    
    with col3:
        if st.button("💳 Utilización crédito"):
            question = "utilización crédito"
    
    if question:
        with st.spinner("🤖 Cortex Analyst está analizando tu pregunta..."):
            response = cortex_analyst_query(question)
            
            if response:
                st.success("✅ Análisis completado")
                
                # Mostrar descripción
                st.markdown(f"**📋 Análisis:** {response['description']}")
                
                # Ejecutar query y mostrar resultados
                df = execute_query(response['query'])
                
                if not df.empty:
                    st.markdown("### 📊 Resultados")
                    st.dataframe(df, use_container_width=True)
                    
                    # Generar gráfico automático si es apropiado
                    if len(df.columns) == 2:
                        col1, col2 = df.columns
                        if df[col2].dtype in ['int64', 'float64']:
                            render_chart(df, "bar", response['description'], col1, col2)
                else:
                    st.warning("No se encontraron datos para esta consulta")
            else:
                st.warning("🤔 No pude entender tu pregunta. Intenta reformularla o usa una de las sugerencias.")

def cortex_search_page():
    """Página de Cortex Search"""
    st.markdown("## 🔍 Cortex Search")
    st.markdown("Busca información en documentos financieros usando búsqueda semántica")
    
    # Input de búsqueda
    search_query = st.text_input(
        "🔍 Busca en documentos:",
        placeholder="Ej: análisis de mercado, política de riesgo, productos de inversión",
        help="La búsqueda es semántica - no necesitas palabras exactas"
    )
    
    # Filtros
    col1, col2, col3 = st.columns(3)
    
    with col1:
        doc_type = st.selectbox(
            "Tipo de documento:",
            ["Todos", "ANALISIS_MERCADO", "REPORTE_SECTORIAL", "POLITICA", "PERFIL_CLIENTE", "MANUAL_PRODUCTO"]
        )
    
    with col2:
        category = st.selectbox(
            "Categoría:",
            ["Todas", "RESEARCH", "NORMATIVIDAD", "CLIENTES", "PRODUCTOS", "CORPORATIVO"]
        )
    
    with col3:
        limit = st.selectbox("Resultados:", [5, 10, 15, 20], index=0)
    
    if search_query:
        with st.spinner("🔍 Buscando en documentos..."):
            # Preparar filtros
            filters = {}
            if doc_type != "Todos":
                filters["tipo_documento"] = doc_type
            if category != "Todas":
                filters["categoria"] = category
            
            # Realizar búsqueda
            results = cortex_search(search_query, filters, limit)
            
            if results:
                st.success(f"✅ Se encontraron {len(results)} documentos relevantes")
                
                for i, doc in enumerate(results):
                    with st.expander(f"📄 {doc.get('titulo', 'Sin título')} (Relevancia: {doc.get('score', 0):.2f})"):
                        col1, col2 = st.columns([3, 1])
                        
                        with col1:
                            st.markdown(f"**Contenido:**")
                            # Mostrar extracto del contenido
                            content = doc.get('contenido', '')
                            if len(content) > 500:
                                content = content[:500] + "..."
                            st.markdown(content)
                        
                        with col2:
                            st.markdown("**Metadatos:**")
                            st.markdown(f"**Tipo:** {doc.get('tipo_documento', 'N/A')}")
                            st.markdown(f"**Categoría:** {doc.get('categoria', 'N/A')}")
                            st.markdown(f"**Autor:** {doc.get('autor', 'N/A')}")
                            if doc.get('tags'):
                                st.markdown(f"**Tags:** {doc.get('tags')}")
            else:
                st.warning("🔍 No se encontraron documentos relevantes. Intenta con otros términos de búsqueda.")
    
    # Búsquedas sugeridas
    st.markdown("### 💡 Búsquedas Sugeridas")
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("📊 Análisis de mercado"):
            st.rerun()
    
    with col2:
        if st.button("⚖️ Políticas de riesgo"):
            st.rerun()
    
    with col3:
        if st.button("💰 Productos financieros"):
            st.rerun()

def advanced_analytics_page():
    """Página de análisis avanzado"""
    st.markdown("## 📈 Análisis Avanzado")
    st.markdown("Análisis detallados y visualizaciones avanzadas")
    
    # Selección de análisis
    analysis_type = st.selectbox(
        "Selecciona tipo de análisis:",
        ["Tendencias Temporales", "Análisis de Rentabilidad", "Segmentación de Clientes", "Análisis de Productos"]
    )
    
    if analysis_type == "Tendencias Temporales":
        st.markdown("### 📈 Tendencias de Transacciones")
        
        df_trends = execute_query("""
            SELECT 
                DATE_TRUNC('WEEK', fecha_transaccion) as semana,
                COUNT(*) as transacciones,
                SUM(monto_mxn) as volumen,
                AVG(monto_mxn) as ticket_promedio
            FROM CORE_BANKING.TRANSACCIONES 
            WHERE fecha_transaccion >= CURRENT_DATE() - 90
            GROUP BY semana
            ORDER BY semana
        """)
        
        if not df_trends.empty:
            fig = go.Figure()
            
            fig.add_trace(go.Scatter(
                x=df_trends['semana'],
                y=df_trends['transacciones'],
                mode='lines+markers',
                name='Número de Transacciones',
                line=dict(color=MONEX_COLORS['primary_blue'])
            ))
            
            fig.add_trace(go.Scatter(
                x=df_trends['semana'],
                y=df_trends['volumen'],
                mode='lines+markers',
                name='Volumen (MXN)',
                yaxis='y2',
                line=dict(color=MONEX_COLORS['light_blue'])
            ))
            
            fig.update_layout(
                title="Tendencias de Transacciones (Últimos 90 días)",
                xaxis_title="Semana",
                yaxis_title="Número de Transacciones",
                yaxis2=dict(
                    title="Volumen (MXN)",
                    overlaying='y',
                    side='right'
                ),
                hovermode='x unified'
            )
            
            st.plotly_chart(fig, use_container_width=True)
    
    elif analysis_type == "Análisis de Rentabilidad":
        st.markdown("### 💰 Análisis de Rentabilidad por Producto")
        
        df_profitability = execute_query("""
            SELECT 
                p.categoria,
                p.nombre_producto,
                COUNT(DISTINCT ct.contrato_id) as contratos,
                SUM(t.comision + t.iva) as ingresos_comisiones,
                AVG(ct.tasa_aplicada) as tasa_promedio
            FROM CORE_BANKING.PRODUCTOS p
            JOIN CORE_BANKING.CONTRATOS ct ON p.producto_id = ct.producto_id
            JOIN CORE_BANKING.TRANSACCIONES t ON ct.contrato_id = t.contrato_id
            WHERE t.fecha_transaccion >= CURRENT_DATE() - 90
            GROUP BY p.categoria, p.nombre_producto
            ORDER BY ingresos_comisiones DESC
        """)
        
        if not df_profitability.empty:
            render_chart(df_profitability.head(10), "bar", 
                        "Top 10 Productos por Ingresos (90d)", 
                        "nombre_producto", "ingresos_comisiones")
            
            st.dataframe(df_profitability, use_container_width=True)

# ===== EJECUTAR APLICACIÓN =====
if __name__ == "__main__":
    main()
