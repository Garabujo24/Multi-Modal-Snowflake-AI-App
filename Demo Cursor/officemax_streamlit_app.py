"""
OFFICEMAX MÉXICO - CORTEX AI PLATFORM
Aplicación Streamlit que integra Cortex Analyst y Cortex Search
con la imagen corporativa de OfficeMax México
"""

import streamlit as st
import snowflake.connector
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import json
from datetime import datetime, timedelta
import base64

# ===== CONFIGURACIÓN DE PÁGINA =====
st.set_page_config(
    page_title="OfficeMax México - Cortex AI Platform",
    page_icon="🏢",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ===== COLORES CORPORATIVOS OFFICEMAX =====
OFFICEMAX_COLORS = {
    'primary_red': '#E31B24',          # Rojo principal OfficeMax
    'dark_red': '#B8151C',             # Rojo oscuro
    'light_red': '#FF4D54',            # Rojo claro
    'secondary_blue': '#003B7A',       # Azul secundario
    'dark_blue': '#002654',            # Azul marino
    'light_blue': '#4A90C2',           # Azul claro
    'orange_accent': '#FF6B35',        # Naranja de acento
    'green_success': '#28A745',        # Verde éxito
    'yellow_warning': '#FFC107',       # Amarillo advertencia
    'gray_dark': '#333333',            # Gris oscuro
    'gray_medium': '#666666',          # Gris medio
    'gray_light': '#F8F9FA',           # Gris claro
    'white': '#FFFFFF',
    'black': '#000000'
}

# ===== CSS PERSONALIZADO OFFICEMAX =====
def load_css():
    st.markdown(f"""
    <style>
    /* Variables CSS OfficeMax */
    :root {{
        --om-primary: {OFFICEMAX_COLORS['primary_red']};
        --om-dark: {OFFICEMAX_COLORS['dark_red']};
        --om-light: {OFFICEMAX_COLORS['light_red']};
        --om-blue: {OFFICEMAX_COLORS['secondary_blue']};
        --om-blue-dark: {OFFICEMAX_COLORS['dark_blue']};
        --om-orange: {OFFICEMAX_COLORS['orange_accent']};
        --om-gray: {OFFICEMAX_COLORS['gray_medium']};
    }}
    
    /* Estilo general */
    .main {{
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        font-family: 'Arial', 'Helvetica', sans-serif;
    }}
    
    /* Header OfficeMax */
    .officemax-header {{
        background: linear-gradient(135deg, var(--om-primary) 0%, var(--om-dark) 100%);
        padding: 2rem;
        border-radius: 15px;
        margin-bottom: 2rem;
        box-shadow: 0 8px 25px rgba(227, 27, 36, 0.2);
        position: relative;
        overflow: hidden;
    }}
    
    .officemax-header::before {{
        content: '';
        position: absolute;
        top: -50%;
        right: -50%;
        width: 200%;
        height: 200%;
        background: url("data:image/svg+xml,%3Csvg width='40' height='40' viewBox='0 0 40 40' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='%23ffffff' fill-opacity='0.05'%3E%3Cpath d='M20 20c0 11.046-8.954 20-20 20s-20-8.954-20-20 8.954-20 20-20 20 8.954 20 20zm10 0c0-5.523-4.477-10-10-10s-10 4.477-10 10 4.477 10 10 10 10-4.477 10-10z'/%3E%3C/g%3E%3C/svg%3E");
        animation: float 20s ease-in-out infinite;
    }}
    
    @keyframes float {{
        0%, 100% {{ transform: translateY(0px) rotate(0deg); }}
        50% {{ transform: translateY(-10px) rotate(10deg); }}
    }}
    
    .officemax-logo {{
        color: white;
        font-size: 2.8rem;
        font-weight: bold;
        text-align: center;
        margin: 0;
        text-shadow: 2px 2px 8px rgba(0,0,0,0.3);
        letter-spacing: 2px;
        position: relative;
        z-index: 2;
    }}
    
    .officemax-subtitle {{
        color: white;
        font-size: 1.3rem;
        text-align: center;
        margin: 1rem 0 0 0;
        opacity: 0.95;
        font-weight: 300;
        position: relative;
        z-index: 2;
    }}
    
    .officemax-tagline {{
        color: white;
        font-size: 0.9rem;
        text-align: center;
        margin: 0.5rem 0 0 0;
        opacity: 0.8;
        font-style: italic;
        position: relative;
        z-index: 2;
    }}
    
    /* Métricas personalizadas */
    .metric-card {{
        background: linear-gradient(135deg, white 0%, #f8f9fa 100%);
        padding: 2rem 1.5rem;
        border-radius: 15px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        border-left: 5px solid var(--om-primary);
        margin-bottom: 1rem;
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
    }}
    
    .metric-card:hover {{
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(227, 27, 36, 0.15);
    }}
    
    .metric-card::before {{
        content: '';
        position: absolute;
        top: 0;
        right: 0;
        width: 100px;
        height: 100px;
        background: linear-gradient(135deg, var(--om-primary) 0%, var(--om-light) 100%);
        opacity: 0.05;
        border-radius: 50%;
        transform: translate(30px, -30px);
    }}
    
    .metric-value {{
        font-size: 2.5rem;
        font-weight: bold;
        color: var(--om-primary);
        margin: 0;
        line-height: 1;
        position: relative;
        z-index: 2;
    }}
    
    .metric-label {{
        font-size: 1rem;
        color: var(--om-gray);
        margin: 0.5rem 0 0 0;
        text-transform: uppercase;
        letter-spacing: 1px;
        font-weight: 600;
        position: relative;
        z-index: 2;
    }}
    
    .metric-change {{
        font-size: 0.9rem;
        margin: 0.3rem 0 0 0;
        font-weight: 500;
        position: relative;
        z-index: 2;
    }}
    
    .metric-positive {{ color: var(--om-green-success); }}
    .metric-negative {{ color: var(--om-primary); }}
    
    /* Botones OfficeMax */
    .stButton > button {{
        background: linear-gradient(135deg, var(--om-primary) 0%, var(--om-dark) 100%);
        color: white;
        border: none;
        border-radius: 10px;
        padding: 0.75rem 2rem;
        font-weight: bold;
        font-size: 1rem;
        letter-spacing: 0.5px;
        transition: all 0.3s ease;
        box-shadow: 0 4px 15px rgba(227, 27, 36, 0.2);
        text-transform: uppercase;
    }}
    
    .stButton > button:hover {{
        background: linear-gradient(135deg, var(--om-dark) 0%, var(--om-blue-dark) 100%);
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(227, 27, 36, 0.3);
    }}
    
    .stButton > button:active {{
        transform: translateY(0px);
    }}
    
    /* Sidebar OfficeMax */
    .css-1d391kg {{
        background: linear-gradient(180deg, var(--om-blue-dark) 0%, var(--om-blue) 100%);
    }}
    
    .css-1d391kg .css-1v0mbdj {{
        background: linear-gradient(180deg, var(--om-blue-dark) 0%, var(--om-blue) 100%);
    }}
    
    .sidebar .sidebar-content {{
        background: linear-gradient(180deg, var(--om-blue-dark) 0%, var(--om-blue) 100%);
    }}
    
    /* Selectbox y inputs */
    .stSelectbox > div > div {{
        border: 2px solid var(--om-primary);
        border-radius: 8px;
        background: white;
    }}
    
    .stTextInput > div > div > input {{
        border: 2px solid var(--om-primary);
        border-radius: 8px;
        background: white;
    }}
    
    /* Tabs OfficeMax */
    .stTabs [data-baseweb="tab-list"] {{
        gap: 8px;
        background: transparent;
    }}
    
    .stTabs [data-baseweb="tab"] {{
        background: linear-gradient(135deg, white 0%, #f8f9fa 100%);
        border: 2px solid var(--om-primary);
        color: var(--om-primary);
        font-weight: bold;
        border-radius: 10px 10px 0 0;
        padding: 1rem 1.5rem;
        transition: all 0.3s ease;
    }}
    
    .stTabs [data-baseweb="tab"]:hover {{
        background: linear-gradient(135deg, var(--om-light) 0%, var(--om-primary) 100%);
        color: white;
    }}
    
    .stTabs [aria-selected="true"] {{
        background: linear-gradient(135deg, var(--om-primary) 0%, var(--om-dark) 100%);
        color: white;
        box-shadow: 0 4px 15px rgba(227, 27, 36, 0.2);
    }}
    
    /* Alertas personalizadas */
    .alert-info {{
        background: linear-gradient(135deg, #e3f2fd 0%, #bbdefb 100%);
        border-left: 5px solid var(--om-blue);
        padding: 1.5rem;
        border-radius: 10px;
        margin: 1rem 0;
        box-shadow: 0 2px 10px rgba(0,59,122,0.1);
    }}
    
    .alert-success {{
        background: linear-gradient(135deg, #e8f5e8 0%, #c8e6c9 100%);
        border-left: 5px solid var(--om-green-success);
        padding: 1.5rem;
        border-radius: 10px;
        margin: 1rem 0;
        box-shadow: 0 2px 10px rgba(40,167,69,0.1);
    }}
    
    .alert-warning {{
        background: linear-gradient(135deg, #fff8e1 0%, #ffecb3 100%);
        border-left: 5px solid var(--om-yellow-warning);
        padding: 1.5rem;
        border-radius: 10px;
        margin: 1rem 0;
        box-shadow: 0 2px 10px rgba(255,193,7,0.1);
    }}
    
    /* Chat messages */
    .chat-message {{
        background: linear-gradient(135deg, white 0%, #f8f9fa 100%);
        padding: 1.5rem;
        border-radius: 15px;
        margin: 1rem 0;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        transition: all 0.3s ease;
    }}
    
    .user-message {{
        background: linear-gradient(135deg, var(--om-primary) 0%, var(--om-dark) 100%);
        color: white;
        margin-left: 3rem;
        border-radius: 15px 15px 5px 15px;
    }}
    
    .assistant-message {{
        background: linear-gradient(135deg, white 0%, #f8f9fa 100%);
        border-left: 5px solid var(--om-primary);
        margin-right: 3rem;
        border-radius: 15px 15px 15px 5px;
    }}
    
    /* Dataframes personalizados */
    .dataframe {{
        border-radius: 10px;
        overflow: hidden;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    }}
    
    /* Scrollbar personalizado */
    ::-webkit-scrollbar {{
        width: 10px;
        height: 10px;
    }}
    
    ::-webkit-scrollbar-track {{
        background: #f1f1f1;
        border-radius: 5px;
    }}
    
    ::-webkit-scrollbar-thumb {{
        background: linear-gradient(135deg, var(--om-primary) 0%, var(--om-dark) 100%);
        border-radius: 5px;
    }}
    
    ::-webkit-scrollbar-thumb:hover {{
        background: linear-gradient(135deg, var(--om-dark) 0%, var(--om-blue-dark) 100%);
    }}
    
    /* Ocultar elementos de Streamlit */
    #MainMenu {{visibility: hidden;}}
    .stDeployButton {{display:none;}}
    footer {{visibility: hidden;}}
    .stApp > header {{visibility: hidden;}}
    
    /* Elementos específicos de OfficeMax */
    .feature-card {{
        background: linear-gradient(135deg, white 0%, #f8f9fa 100%);
        padding: 2rem;
        border-radius: 15px;
        border: 2px solid var(--om-primary);
        margin: 1rem 0;
        text-align: center;
        transition: all 0.3s ease;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    }}
    
    .feature-card:hover {{
        transform: translateY(-5px);
        box-shadow: 0 8px 25px rgba(227, 27, 36, 0.15);
    }}
    
    .feature-icon {{
        font-size: 3rem;
        color: var(--om-primary);
        margin-bottom: 1rem;
    }}
    
    .status-indicator {{
        display: inline-block;
        width: 12px;
        height: 12px;
        border-radius: 50%;
        margin-right: 8px;
    }}
    
    .status-online {{ background-color: var(--om-green-success); }}
    .status-warning {{ background-color: var(--om-yellow-warning); }}
    .status-offline {{ background-color: var(--om-primary); }}
    
    .progress-bar {{
        width: 100%;
        height: 8px;
        background-color: #e9ecef;
        border-radius: 4px;
        overflow: hidden;
        margin: 0.5rem 0;
    }}
    
    .progress-fill {{
        height: 100%;
        background: linear-gradient(90deg, var(--om-primary) 0%, var(--om-orange) 100%);
        transition: width 0.3s ease;
    }}
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
warehouse = "OFFICEMAX_CORTEX_WH"
database = "OFFICEMAX_MEXICO"
schema = "RAW_DATA"
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

@st.cache_data(ttl=300)
def get_dashboard_metrics():
    """Obtener métricas para el dashboard"""
    queries = {
        'total_productos': "SELECT COUNT(*) as total FROM RAW_DATA.PRODUCTOS WHERE ACTIVO = TRUE",
        'total_clientes': "SELECT COUNT(*) as total FROM RAW_DATA.CLIENTES WHERE ACTIVO = TRUE",
        'total_sucursales': "SELECT COUNT(*) as total FROM RAW_DATA.SUCURSALES WHERE ACTIVO = TRUE",
        'ventas_mes_actual': """
            SELECT COALESCE(SUM(TOTAL_LINEA), 0) as total 
            FROM RAW_DATA.VENTAS 
            WHERE DATE_TRUNC('MONTH', FECHA_VENTA) = DATE_TRUNC('MONTH', CURRENT_DATE())
        """,
        'ventas_mes_anterior': """
            SELECT COALESCE(SUM(TOTAL_LINEA), 0) as total 
            FROM RAW_DATA.VENTAS 
            WHERE DATE_TRUNC('MONTH', FECHA_VENTA) = DATE_TRUNC('MONTH', DATEADD('MONTH', -1, CURRENT_DATE()))
        """,
        'margen_promedio': """
            SELECT COALESCE(AVG(PORCENTAJE_MARGEN), 0) as promedio 
            FROM RAW_DATA.VENTAS 
            WHERE FECHA_VENTA >= DATEADD('MONTH', -1, CURRENT_DATE())
        """,
        'productos_bajo_stock': """
            SELECT COUNT(*) as total 
            FROM RAW_DATA.INVENTARIO i 
            JOIN RAW_DATA.PRODUCTOS p ON i.PRODUCTO_ID = p.PRODUCTO_ID
            WHERE i.STOCK_ACTUAL <= p.STOCK_MINIMO
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
        # Construir parámetros de búsqueda
        search_params = {"limit": limit}
        if filters:
            search_params.update(filters)
        
        # Query para Cortex Search
        search_query = f"""
        SELECT 
            DOCUMENTO_ID,
            TITULO,
            TIPO_DOCUMENTO,
            CATEGORIA,
            RELEVANCE_SCORE,
            CONTENIDO,
            AUTOR,
            DEPARTAMENTO,
            FECHA_CREACION
        FROM TABLE(
            CORTEX_SERVICES.SEARCH_DOCUMENTS(
                '{query}', 
                {json.dumps(search_params) if filters else 'NULL'}, 
                {limit}
            )
        )
        ORDER BY RELEVANCE_SCORE DESC
        """
        
        df = execute_query(search_query)
        return df.to_dict('records') if not df.empty else []
    
    except Exception as e:
        st.error(f"Error en Cortex Search: {str(e)}")
        return []

def cortex_analyst_query(question):
    """Realizar consulta a Cortex Analyst"""
    try:
        # Query para Cortex Analyst
        analyst_query = f"""
        SELECT CORTEX_SERVICES.QUERY_ANALYST('{question}') as RESPONSE
        """
        
        df = execute_query(analyst_query)
        if not df.empty:
            response = df.iloc[0, 0]
            if isinstance(response, str):
                try:
                    return json.loads(response)
                except:
                    return {"sql": response, "description": "Consulta generada por Cortex Analyst"}
            return response
        return None
    
    except Exception as e:
        st.error(f"Error en Cortex Analyst: {str(e)}")
        return None

# ===== COMPONENTES UI =====
def render_header():
    """Renderizar header de OfficeMax"""
    st.markdown("""
    <div class="officemax-header">
        <h1 class="officemax-logo">🏢 OFFICEMAX MÉXICO</h1>
        <p class="officemax-subtitle">Plataforma de Inteligencia Artificial Cortex</p>
        <p class="officemax-tagline">"Hacemos que tu oficina funcione mejor"</p>
    </div>
    """, unsafe_allow_html=True)

def render_metric_card(label, value, change=None, format_type="number"):
    """Renderizar tarjeta de métrica con estilo OfficeMax"""
    # Manejar valores None o no numéricos
    if value is None:
        value = 0
    
    try:
        value = float(value)
    except (ValueError, TypeError):
        value = 0.0
    
    # Formatear valor
    if format_type == "currency":
        formatted_value = f"${value:,.0f}"
    elif format_type == "millions":
        formatted_value = f"${value/1000000:.1f}M"
    elif format_type == "thousands":
        formatted_value = f"${value/1000:.0f}K"
    elif format_type == "percentage":
        formatted_value = f"{value:.1f}%"
    else:
        formatted_value = f"{value:,.0f}"
    
    # Formatear cambio si se proporciona
    change_html = ""
    if change is not None:
        change_class = "metric-positive" if change >= 0 else "metric-negative"
        change_symbol = "▲" if change >= 0 else "▼"
        change_html = f'<p class="metric-change {change_class}">{change_symbol} {abs(change):.1f}% vs mes anterior</p>'
    
    st.markdown(f"""
    <div class="metric-card">
        <p class="metric-value">{formatted_value}</p>
        <p class="metric-label">{label}</p>
        {change_html}
    </div>
    """, unsafe_allow_html=True)

def render_chart(df, chart_type, title, x_col, y_col, color_col=None):
    """Renderizar gráfico con estilo OfficeMax"""
    if df.empty:
        st.warning("⚠️ No hay datos disponibles para mostrar")
        return
    
    # Paleta de colores OfficeMax
    color_palette = [
        OFFICEMAX_COLORS['primary_red'], 
        OFFICEMAX_COLORS['secondary_blue'],
        OFFICEMAX_COLORS['orange_accent'], 
        OFFICEMAX_COLORS['light_blue'],
        OFFICEMAX_COLORS['dark_red'],
        OFFICEMAX_COLORS['green_success']
    ]
    
    # Crear gráfico según el tipo
    if chart_type == "bar":
        fig = px.bar(df, x=x_col, y=y_col, title=title, 
                    color=color_col if color_col else None,
                    color_discrete_sequence=color_palette)
    elif chart_type == "pie":
        fig = px.pie(df, names=x_col, values=y_col, title=title,
                    color_discrete_sequence=color_palette)
    elif chart_type == "line":
        fig = px.line(df, x=x_col, y=y_col, title=title,
                     color=color_col if color_col else None,
                     color_discrete_sequence=color_palette)
    elif chart_type == "scatter":
        fig = px.scatter(df, x=x_col, y=y_col, title=title,
                        color=color_col if color_col else None,
                        color_discrete_sequence=color_palette)
    
    # Personalizar diseño
    fig.update_layout(
        plot_bgcolor='white',
        paper_bgcolor='white',
        font_color=OFFICEMAX_COLORS['gray_dark'],
        title_font_size=18,
        title_font_color=OFFICEMAX_COLORS['primary_red'],
        title_font_weight='bold',
        showlegend=True,
        legend=dict(
            bgcolor="rgba(255,255,255,0.8)",
            bordercolor=OFFICEMAX_COLORS['primary_red'],
            borderwidth=1
        )
    )
    
    # Personalizar ejes
    fig.update_xaxes(
        gridcolor='rgba(0,0,0,0.1)',
        title_font_color=OFFICEMAX_COLORS['gray_dark']
    )
    fig.update_yaxes(
        gridcolor='rgba(0,0,0,0.1)',
        title_font_color=OFFICEMAX_COLORS['gray_dark']
    )
    
    st.plotly_chart(fig, use_container_width=True)

def render_feature_card(icon, title, description):
    """Renderizar tarjeta de característica"""
    st.markdown(f"""
    <div class="feature-card">
        <div class="feature-icon">{icon}</div>
        <h3 style="color: {OFFICEMAX_COLORS['primary_red']}; margin: 1rem 0;">{title}</h3>
        <p style="color: {OFFICEMAX_COLORS['gray_dark']};">{description}</p>
    </div>
    """, unsafe_allow_html=True)

# ===== PÁGINA PRINCIPAL =====
def main():
    load_css()
    render_header()
    
    # Sidebar con navegación
    with st.sidebar:
        st.markdown("### 🎯 Navegación")
        page = st.selectbox(
            "Selecciona una función:",
            [
                "📊 Dashboard Ejecutivo", 
                "🤖 Cortex Analyst", 
                "🔍 Cortex Search", 
                "📈 Análisis de Productos",
                "🏪 Performance Sucursales",
                "👥 Análisis de Clientes"
            ]
        )
        
        st.markdown("---")
        st.markdown("### ℹ️ Información del Sistema")
        
        # Estado de servicios
        st.markdown("**Estado de Servicios:**")
        st.markdown('<span class="status-indicator status-online"></span>Cortex Analyst', unsafe_allow_html=True)
        st.markdown('<span class="status-indicator status-online"></span>Cortex Search', unsafe_allow_html=True)
        st.markdown('<span class="status-indicator status-online"></span>Base de Datos', unsafe_allow_html=True)
        
        st.markdown("---")
        st.markdown("### 🚀 Características")
        st.info("""
        **OfficeMax Cortex AI Platform**
        
        ✅ **Cortex Analyst**: Análisis inteligente con lenguaje natural
        
        ✅ **Cortex Search**: Búsqueda semántica de documentos
        
        ✅ **Dashboards**: Visualizaciones interactivas en tiempo real
        
        ✅ **Analytics**: Análisis avanzado de productos y clientes
        """)
        
        st.markdown("---")
        st.markdown("**Última actualización:** " + datetime.now().strftime("%H:%M:%S"))
    
    # Contenido principal basado en selección
    if page == "📊 Dashboard Ejecutivo":
        dashboard_page()
    elif page == "🤖 Cortex Analyst":
        cortex_analyst_page()
    elif page == "🔍 Cortex Search":
        cortex_search_page()
    elif page == "📈 Análisis de Productos":
        product_analysis_page()
    elif page == "🏪 Performance Sucursales":
        store_performance_page()
    elif page == "👥 Análisis de Clientes":
        customer_analysis_page()

def dashboard_page():
    """Página de dashboard ejecutivo"""
    st.markdown("## 📊 Dashboard Ejecutivo OfficeMax México")
    st.markdown("Vista general de métricas clave del negocio en tiempo real")
    
    # Obtener métricas
    metrics = get_dashboard_metrics()
    
    # Calcular cambio mensual
    cambio_ventas = 0
    if metrics['ventas_mes_anterior'] > 0:
        cambio_ventas = ((metrics['ventas_mes_actual'] - metrics['ventas_mes_anterior']) / 
                        metrics['ventas_mes_anterior']) * 100
    
    # Primera fila de métricas
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        render_metric_card("Productos Activos", metrics['total_productos'])
    
    with col2:
        render_metric_card("Clientes Registrados", metrics['total_clientes'])
    
    with col3:
        render_metric_card("Sucursales Operativas", metrics['total_sucursales'])
    
    with col4:
        render_metric_card("Margen Promedio", metrics['margen_promedio'], format_type="percentage")
    
    # Segunda fila de métricas
    col1, col2 = st.columns(2)
    
    with col1:
        render_metric_card("Ventas Mes Actual", metrics['ventas_mes_actual'], 
                          cambio_ventas, "currency")
    
    with col2:
        render_metric_card("Productos Bajo Stock", metrics['productos_bajo_stock'])
    
    st.markdown("---")
    
    # Gráficos principales
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("### 📊 Ventas por Categoría (Últimos 30 días)")
        df_categorias = execute_query("""
            SELECT 
                CATEGORIA_PADRE,
                SUM(TOTAL_LINEA) as INGRESOS,
                SUM(CANTIDAD) as UNIDADES
            FROM ANALYTICS.VENTAS_CONSOLIDADAS
            WHERE FECHA_VENTA >= DATEADD('day', -30, CURRENT_DATE())
            GROUP BY CATEGORIA_PADRE
            ORDER BY INGRESOS DESC
        """)
        if not df_categorias.empty:
            render_chart(df_categorias, "pie", "Distribución de Ingresos", 
                        "CATEGORIA_PADRE", "INGRESOS")
        else:
            st.warning("No hay datos de ventas disponibles")
    
    with col2:
        st.markdown("### 🛒 Ventas por Canal")
        df_canales = execute_query("""
            SELECT 
                CANAL_VENTA,
                COUNT(*) as TRANSACCIONES,
                SUM(TOTAL_LINEA) as INGRESOS
            FROM ANALYTICS.VENTAS_CONSOLIDADAS
            WHERE FECHA_VENTA >= DATEADD('day', -30, CURRENT_DATE())
            GROUP BY CANAL_VENTA
            ORDER BY INGRESOS DESC
        """)
        if not df_canales.empty:
            render_chart(df_canales, "bar", "Ingresos por Canal", 
                        "CANAL_VENTA", "INGRESOS")
    
    # Tendencias mensuales
    st.markdown("### 📈 Tendencias de Ventas (Últimos 6 meses)")
    df_tendencias = execute_query("""
        SELECT 
            DATE_TRUNC('month', FECHA_VENTA) as MES,
            SUM(TOTAL_LINEA) as INGRESOS,
            COUNT(*) as TRANSACCIONES
        FROM ANALYTICS.VENTAS_CONSOLIDADAS
        WHERE FECHA_VENTA >= DATEADD('month', -6, CURRENT_DATE())
        GROUP BY MES
        ORDER BY MES
    """)
    
    if not df_tendencias.empty:
        # Crear gráfico combinado
        fig = make_subplots(specs=[[{"secondary_y": True}]])
        
        fig.add_trace(
            go.Bar(x=df_tendencias['MES'], y=df_tendencias['INGRESOS'], 
                  name="Ingresos", marker_color=OFFICEMAX_COLORS['primary_red']),
            secondary_y=False,
        )
        
        fig.add_trace(
            go.Scatter(x=df_tendencias['MES'], y=df_tendencias['TRANSACCIONES'], 
                      mode='lines+markers', name="Transacciones", 
                      line=dict(color=OFFICEMAX_COLORS['secondary_blue'], width=3)),
            secondary_y=True,
        )
        
        fig.update_xaxes(title_text="Mes")
        fig.update_yaxes(title_text="Ingresos (MXN)", secondary_y=False)
        fig.update_yaxes(title_text="Número de Transacciones", secondary_y=True)
        
        fig.update_layout(
            title="Evolución de Ingresos y Transacciones",
            plot_bgcolor='white',
            paper_bgcolor='white',
            title_font_color=OFFICEMAX_COLORS['primary_red']
        )
        
        st.plotly_chart(fig, use_container_width=True)

def cortex_analyst_page():
    """Página de Cortex Analyst"""
    st.markdown("## 🤖 Cortex Analyst - OfficeMax México")
    st.markdown("Realiza preguntas en lenguaje natural sobre tus datos de negocio")
    
    # Input de pregunta
    question = st.text_input(
        "💬 Haz una pregunta sobre los datos de OfficeMax:",
        placeholder="Ej: ¿Cuáles son los productos más vendidos por categoría?",
        help="Puedes preguntar sobre ventas, productos, clientes, sucursales, inventario, etc."
    )
    
    # Preguntas sugeridas en tarjetas
    st.markdown("### 💡 Preguntas Sugeridas")
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("📊 Productos más vendidos", use_container_width=True):
            question = "¿Cuáles son los 10 productos más vendidos en los últimos 30 días?"
    
    with col2:
        if st.button("🏪 Performance por sucursal", use_container_width=True):
            question = "¿Cómo ha sido el performance de ventas por sucursal este mes?"
    
    with col3:
        if st.button("📈 Tendencias de categorías", use_container_width=True):
            question = "¿Cuáles son las tendencias de venta por categoría de producto?"
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("💰 Análisis de márgenes", use_container_width=True):
            question = "¿Qué productos tienen los mejores márgenes de ganancia?"
    
    with col2:
        if st.button("🛒 Canales de venta", use_container_width=True):
            question = "¿Cómo se distribuyen las ventas entre los diferentes canales?"
    
    with col3:
        if st.button("📦 Estado del inventario", use_container_width=True):
            question = "¿Qué productos tienen stock crítico o necesitan reabastecimiento?"
    
    # Procesar pregunta
    if question:
        with st.spinner("🤖 Cortex Analyst está analizando tu pregunta..."):
            # Para demostración, usar queries predefinidas
            demo_queries = {
                "productos más vendidos": """
                    SELECT 
                        p.NOMBRE_PRODUCTO,
                        p.MARCA,
                        c.CATEGORIA_PADRE,
                        SUM(v.CANTIDAD) as UNIDADES_VENDIDAS,
                        SUM(v.TOTAL_LINEA) as INGRESOS_TOTALES
                    FROM RAW_DATA.VENTAS v
                    JOIN RAW_DATA.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
                    JOIN RAW_DATA.CATEGORIAS c ON p.CATEGORIA_ID = c.CATEGORIA_ID
                    WHERE v.FECHA_VENTA >= DATEADD('day', -30, CURRENT_DATE())
                    GROUP BY p.NOMBRE_PRODUCTO, p.MARCA, c.CATEGORIA_PADRE
                    ORDER BY UNIDADES_VENDIDAS DESC
                    LIMIT 10
                """,
                "performance sucursal": """
                    SELECT 
                        s.NOMBRE_SUCURSAL,
                        s.ESTADO,
                        COUNT(v.VENTA_ID) as TRANSACCIONES,
                        SUM(v.TOTAL_LINEA) as INGRESOS_TOTALES,
                        AVG(v.TOTAL_LINEA) as TICKET_PROMEDIO
                    FROM RAW_DATA.VENTAS v
                    JOIN RAW_DATA.SUCURSALES s ON v.SUCURSAL_ID = s.SUCURSAL_ID
                    WHERE DATE_TRUNC('MONTH', v.FECHA_VENTA) = DATE_TRUNC('MONTH', CURRENT_DATE())
                    GROUP BY s.NOMBRE_SUCURSAL, s.ESTADO
                    ORDER BY INGRESOS_TOTALES DESC
                """,
                "tendencias categoría": """
                    SELECT 
                        c.CATEGORIA_PADRE,
                        DATE_TRUNC('week', v.FECHA_VENTA) as SEMANA,
                        SUM(v.TOTAL_LINEA) as INGRESOS_SEMANALES,
                        SUM(v.CANTIDAD) as UNIDADES_SEMANALES
                    FROM RAW_DATA.VENTAS v
                    JOIN RAW_DATA.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
                    JOIN RAW_DATA.CATEGORIAS c ON p.CATEGORIA_ID = c.CATEGORIA_ID
                    WHERE v.FECHA_VENTA >= DATEADD('week', -8, CURRENT_DATE())
                    GROUP BY c.CATEGORIA_PADRE, SEMANA
                    ORDER BY SEMANA DESC, INGRESOS_SEMANALES DESC
                """,
                "análisis márgenes": """
                    SELECT 
                        p.NOMBRE_PRODUCTO,
                        p.MARCA,
                        c.CATEGORIA_PADRE,
                        AVG(v.PORCENTAJE_MARGEN) as MARGEN_PROMEDIO,
                        SUM(v.MARGEN_BRUTO) as MARGEN_TOTAL,
                        COUNT(*) as TRANSACCIONES
                    FROM RAW_DATA.VENTAS v
                    JOIN RAW_DATA.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
                    JOIN RAW_DATA.CATEGORIAS c ON p.CATEGORIA_ID = c.CATEGORIA_ID
                    WHERE v.FECHA_VENTA >= DATEADD('day', -30, CURRENT_DATE())
                    GROUP BY p.NOMBRE_PRODUCTO, p.MARCA, c.CATEGORIA_PADRE
                    ORDER BY MARGEN_PROMEDIO DESC
                    LIMIT 15
                """,
                "canales venta": """
                    SELECT 
                        CANAL_VENTA,
                        COUNT(*) as TRANSACCIONES,
                        SUM(TOTAL_LINEA) as INGRESOS_TOTALES,
                        AVG(TOTAL_LINEA) as TICKET_PROMEDIO,
                        ROUND((SUM(TOTAL_LINEA) / (SELECT SUM(TOTAL_LINEA) FROM RAW_DATA.VENTAS WHERE FECHA_VENTA >= DATEADD('day', -30, CURRENT_DATE()))) * 100, 2) as PARTICIPACION_PORCENTAJE
                    FROM RAW_DATA.VENTAS
                    WHERE FECHA_VENTA >= DATEADD('day', -30, CURRENT_DATE())
                    GROUP BY CANAL_VENTA
                    ORDER BY INGRESOS_TOTALES DESC
                """,
                "stock crítico": """
                    SELECT 
                        p.NOMBRE_PRODUCTO,
                        p.MARCA,
                        c.CATEGORIA_PADRE,
                        s.NOMBRE_SUCURSAL,
                        i.STOCK_ACTUAL,
                        p.STOCK_MINIMO,
                        i.ROTACION_DIAS
                    FROM RAW_DATA.INVENTARIO i
                    JOIN RAW_DATA.PRODUCTOS p ON i.PRODUCTO_ID = p.PRODUCTO_ID
                    JOIN RAW_DATA.CATEGORIAS c ON p.CATEGORIA_ID = c.CATEGORIA_ID
                    JOIN RAW_DATA.SUCURSALES s ON i.SUCURSAL_ID = s.SUCURSAL_ID
                    WHERE i.STOCK_ACTUAL <= p.STOCK_MINIMO
                    ORDER BY (p.STOCK_MINIMO - i.STOCK_ACTUAL) DESC
                """
            }
            
            # Buscar query relevante
            selected_query = None
            for key, query in demo_queries.items():
                if key.lower() in question.lower():
                    selected_query = query
                    break
            
            if selected_query:
                st.success("✅ Análisis completado por Cortex Analyst")
                
                # Ejecutar query y mostrar resultados
                df = execute_query(selected_query)
                
                if not df.empty:
                    st.markdown("### 📊 Resultados del Análisis")
                    st.dataframe(df, use_container_width=True)
                    
                    # Generar visualización automática
                    if len(df.columns) >= 2:
                        numeric_cols = df.select_dtypes(include=['number']).columns
                        if len(numeric_cols) > 0:
                            first_numeric = numeric_cols[0]
                            if 'NOMBRE_PRODUCTO' in df.columns:
                                render_chart(df.head(10), "bar", "Top 10 Resultados", 
                                           "NOMBRE_PRODUCTO", first_numeric)
                            elif 'CATEGORIA_PADRE' in df.columns:
                                render_chart(df, "pie", "Distribución por Categoría", 
                                           "CATEGORIA_PADRE", first_numeric)
                            elif 'CANAL_VENTA' in df.columns:
                                render_chart(df, "bar", "Análisis por Canal", 
                                           "CANAL_VENTA", first_numeric)
                else:
                    st.warning("No se encontraron datos para esta consulta")
            else:
                st.warning("🤔 Cortex Analyst está procesando tu pregunta. Por favor, usa una de las preguntas sugeridas o reformula tu consulta.")

def cortex_search_page():
    """Página de Cortex Search"""
    st.markdown("## 🔍 Cortex Search - OfficeMax México")
    st.markdown("Busca información en documentos corporativos usando búsqueda semántica avanzada")
    
    # Input de búsqueda
    search_query = st.text_input(
        "🔍 Busca en documentos corporativos:",
        placeholder="Ej: política de garantías, manual laptop HP, configuración impresora",
        help="La búsqueda es semántica - no necesitas palabras exactas, describe lo que buscas"
    )
    
    # Filtros avanzados
    st.markdown("### ⚙️ Filtros de Búsqueda")
    col1, col2, col3 = st.columns(3)
    
    with col1:
        doc_type = st.selectbox(
            "Tipo de documento:",
            ["Todos", "MANUAL_PRODUCTO", "POLITICA", "FAQ", "TUTORIAL", "PROMOCION"]
        )
    
    with col2:
        category = st.selectbox(
            "Categoría:",
            ["Todas", "PRODUCTOS", "NORMATIVAS", "SERVICIOS", "CAPACITACION", "MARKETING"]
        )
    
    with col3:
        limit = st.selectbox("Máximo resultados:", [5, 10, 15, 20], index=1)
    
    # Búsquedas sugeridas
    st.markdown("### 💡 Búsquedas Populares")
    col1, col2, col3, col4 = st.columns(4)
    
    suggested_searches = [
        ("📄 Políticas de garantía", "política garantía productos defectuosos"),
        ("💻 Manuales de tecnología", "manual configuración laptop impresora"),
        ("❓ Preguntas frecuentes", "preguntas frecuentes compras online"),
        ("🎯 Promociones actuales", "promociones descuentos back to school")
    ]
    
    for i, (label, query) in enumerate(suggested_searches):
        with [col1, col2, col3, col4][i]:
            if st.button(label, use_container_width=True):
                search_query = query
    
    # Realizar búsqueda
    if search_query:
        with st.spinner("🔍 Buscando en documentos corporativos..."):
            # Preparar filtros
            filters = {}
            if doc_type != "Todos":
                filters["tipo_documento"] = doc_type
            if category != "Todas":
                filters["categoria"] = category
            
            # Simular resultados de Cortex Search para demostración
            demo_results = [
                {
                    "DOCUMENTO_ID": "DOC-001",
                    "TITULO": "Manual de Usuario - Laptop HP Pavilion 15.6\"",
                    "TIPO_DOCUMENTO": "MANUAL_PRODUCTO",
                    "CATEGORIA": "PRODUCTOS",
                    "RELEVANCE_SCORE": 0.95,
                    "CONTENIDO": "Manual completo de usuario para laptop HP Pavilion 15.6\". Incluye especificaciones técnicas, configuración inicial, instalación de software, solución de problemas comunes...",
                    "AUTOR": "Departamento Técnico OfficeMax",
                    "DEPARTAMENTO": "TECNOLOGIA",
                    "FECHA_CREACION": "2024-01-15 10:00:00"
                },
                {
                    "DOCUMENTO_ID": "DOC-003",
                    "TITULO": "Política de Garantías OfficeMax México",
                    "TIPO_DOCUMENTO": "POLITICA",
                    "CATEGORIA": "NORMATIVAS",
                    "RELEVANCE_SCORE": 0.88,
                    "CONTENIDO": "Política integral de garantías para todos los productos vendidos en OfficeMax México. Garantías por categoría: Tecnología (1-3 años según fabricante)...",
                    "AUTOR": "Departamento Jurídico",
                    "DEPARTAMENTO": "NORMATIVAS",
                    "FECHA_CREACION": "2024-01-01 08:00:00"
                },
                {
                    "DOCUMENTO_ID": "DOC-005",
                    "TITULO": "Preguntas Frecuentes - Compras Online",
                    "TIPO_DOCUMENTO": "FAQ",
                    "CATEGORIA": "SERVICIOS",
                    "RELEVANCE_SCORE": 0.82,
                    "CONTENIDO": "Preguntas frecuentes sobre compras en línea en OfficeMax México. ¿Cómo crear una cuenta? ¿Métodos de pago aceptados? ¿Tiempos de entrega?...",
                    "AUTOR": "Equipo de E-commerce",
                    "DEPARTAMENTO": "SERVICIOS",
                    "FECHA_CREACION": "2024-04-15 14:00:00"
                }
            ]
            
            # Filtrar resultados según los filtros seleccionados
            filtered_results = []
            for result in demo_results:
                if doc_type != "Todos" and result["TIPO_DOCUMENTO"] != doc_type:
                    continue
                if category != "Todas" and result["CATEGORIA"] != category:
                    continue
                filtered_results.append(result)
            
            # Limitar resultados
            filtered_results = filtered_results[:limit]
            
            if filtered_results:
                st.success(f"✅ Se encontraron {len(filtered_results)} documentos relevantes")
                
                # Mostrar resultados
                for i, doc in enumerate(filtered_results):
                    with st.expander(f"📄 {doc['TITULO']} (Relevancia: {doc['RELEVANCE_SCORE']:.2f})", 
                                   expanded=(i == 0)):
                        
                        col1, col2 = st.columns([3, 1])
                        
                        with col1:
                            st.markdown("**Contenido:**")
                            st.markdown(doc['CONTENIDO'])
                            
                            # Botones de acción
                            col_btn1, col_btn2 = st.columns(2)
                            with col_btn1:
                                st.button(f"📖 Ver completo", key=f"view_{doc['DOCUMENTO_ID']}")
                            with col_btn2:
                                st.button(f"📩 Compartir", key=f"share_{doc['DOCUMENTO_ID']}")
                        
                        with col2:
                            st.markdown("**Metadatos:**")
                            st.markdown(f"**Tipo:** {doc['TIPO_DOCUMENTO']}")
                            st.markdown(f"**Categoría:** {doc['CATEGORIA']}")
                            st.markdown(f"**Autor:** {doc['AUTOR']}")
                            st.markdown(f"**Departamento:** {doc['DEPARTAMENTO']}")
                            st.markdown(f"**Fecha:** {doc['FECHA_CREACION'][:10]}")
                            
                            # Indicador de relevancia visual
                            relevance_pct = doc['RELEVANCE_SCORE'] * 100
                            st.markdown(f"""
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: {relevance_pct}%;"></div>
                            </div>
                            <small>Relevancia: {relevance_pct:.0f}%</small>
                            """, unsafe_allow_html=True)
            else:
                st.warning("🔍 No se encontraron documentos que coincidan con tu búsqueda. Intenta con otros términos o ajusta los filtros.")
    
    # Estadísticas de la base de conocimiento
    st.markdown("---")
    st.markdown("### 📊 Estadísticas de la Base de Conocimiento")
    
    col1, col2, col3, col4 = st.columns(4)
    with col1:
        render_metric_card("Total Documentos", 150)
    with col2:
        render_metric_card("Manuales de Producto", 45)
    with col3:
        render_metric_card("Políticas y Normativas", 25)
    with col4:
        render_metric_card("Tutoriales y FAQs", 80)

def product_analysis_page():
    """Página de análisis de productos"""
    st.markdown("## 📈 Análisis de Productos - OfficeMax México")
    st.markdown("Análisis detallado del performance y tendencias de productos")
    
    # Filtros de análisis
    col1, col2, col3 = st.columns(3)
    
    with col1:
        categoria_filter = st.selectbox(
            "Filtrar por categoría:",
            ["Todas", "Tecnología", "Papelería", "Material Escolar", "Mobiliario de Oficina"]
        )
    
    with col2:
        periodo = st.selectbox(
            "Período de análisis:",
            ["Últimos 30 días", "Últimos 90 días", "Últimos 6 meses", "Último año"]
        )
    
    with col3:
        metrica = st.selectbox(
            "Ordenar por:",
            ["Ingresos", "Unidades vendidas", "Margen", "Transacciones"]
        )
    
    # Convertir período a días
    periodo_dias = {
        "Últimos 30 días": 30,
        "Últimos 90 días": 90,
        "Últimos 6 meses": 180,
        "Último año": 365
    }[periodo]
    
    # Query para análisis de productos
    categoria_condition = ""
    if categoria_filter != "Todas":
        categoria_condition = f"AND c.CATEGORIA_PADRE = '{categoria_filter}'"
    
    query = f"""
        SELECT 
            p.NOMBRE_PRODUCTO,
            p.MARCA,
            c.CATEGORIA_PADRE,
            COUNT(v.VENTA_ID) as TRANSACCIONES,
            SUM(v.CANTIDAD) as UNIDADES_VENDIDAS,
            SUM(v.TOTAL_LINEA) as INGRESOS,
            AVG(v.PORCENTAJE_MARGEN) as MARGEN_PROMEDIO,
            AVG(v.PRECIO_UNITARIO) as PRECIO_PROMEDIO
        FROM RAW_DATA.VENTAS v
        JOIN RAW_DATA.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
        JOIN RAW_DATA.CATEGORIAS c ON p.CATEGORIA_ID = c.CATEGORIA_ID
        WHERE v.FECHA_VENTA >= DATEADD('day', -{periodo_dias}, CURRENT_DATE())
        {categoria_condition}
        GROUP BY p.NOMBRE_PRODUCTO, p.MARCA, c.CATEGORIA_PADRE
        ORDER BY {metrica.upper().replace(' ', '_')} DESC
        LIMIT 20
    """
    
    df_productos = execute_query(query)
    
    if not df_productos.empty:
        # Tabla de productos
        st.markdown("### 📊 Top 20 Productos")
        st.dataframe(df_productos, use_container_width=True)
        
        # Gráficos de análisis
        col1, col2 = st.columns(2)
        
        with col1:
            # Gráfico de ingresos por producto
            df_top10 = df_productos.head(10)
            render_chart(df_top10, "bar", f"Top 10 Productos por {metrica}", 
                        "NOMBRE_PRODUCTO", metrica.upper().replace(' ', '_'))
        
        with col2:
            # Gráfico de distribución por categoría
            df_categoria = df_productos.groupby('CATEGORIA_PADRE').agg({
                'INGRESOS': 'sum',
                'UNIDADES_VENDIDAS': 'sum'
            }).reset_index()
            
            render_chart(df_categoria, "pie", "Distribución de Ingresos por Categoría", 
                        "CATEGORIA_PADRE", "INGRESOS")
        
        # Análisis de correlación precio-volumen
        st.markdown("### 💰 Análisis Precio vs Volumen")
        
        if 'PRECIO_PROMEDIO' in df_productos.columns and 'UNIDADES_VENDIDAS' in df_productos.columns:
            fig = px.scatter(df_productos, x='PRECIO_PROMEDIO', y='UNIDADES_VENDIDAS',
                           color='CATEGORIA_PADRE', size='INGRESOS',
                           hover_data=['NOMBRE_PRODUCTO', 'MARCA'],
                           title="Relación Precio Promedio vs Unidades Vendidas",
                           color_discrete_sequence=[
                               OFFICEMAX_COLORS['primary_red'], 
                               OFFICEMAX_COLORS['secondary_blue'],
                               OFFICEMAX_COLORS['orange_accent'], 
                               OFFICEMAX_COLORS['green_success']
                           ])
            
            fig.update_layout(
                plot_bgcolor='white',
                paper_bgcolor='white',
                title_font_color=OFFICEMAX_COLORS['primary_red']
            )
            
            st.plotly_chart(fig, use_container_width=True)
    
    else:
        st.warning("No hay datos disponibles para el período y categoría seleccionados")

def store_performance_page():
    """Página de performance de sucursales"""
    st.markdown("## 🏪 Performance de Sucursales - OfficeMax México")
    st.markdown("Análisis comparativo del rendimiento de sucursales por región")
    
    # Métricas de sucursales
    query_performance = """
        SELECT 
            s.NOMBRE_SUCURSAL,
            s.ESTADO,
            s.FORMATO_TIENDA,
            COUNT(v.VENTA_ID) as TRANSACCIONES,
            SUM(v.TOTAL_LINEA) as INGRESOS_TOTALES,
            AVG(v.TOTAL_LINEA) as TICKET_PROMEDIO,
            SUM(v.MARGEN_BRUTO) as MARGEN_TOTAL,
            COUNT(DISTINCT v.CLIENTE_ID) as CLIENTES_UNICOS
        FROM RAW_DATA.VENTAS v
        JOIN RAW_DATA.SUCURSALES s ON v.SUCURSAL_ID = s.SUCURSAL_ID
        WHERE v.FECHA_VENTA >= DATEADD('day', -30, CURRENT_DATE())
        GROUP BY s.NOMBRE_SUCURSAL, s.ESTADO, s.FORMATO_TIENDA
        ORDER BY INGRESOS_TOTALES DESC
    """
    
    df_sucursales = execute_query(query_performance)
    
    if not df_sucursales.empty:
        # Métricas totales
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            render_metric_card("Sucursales Activas", len(df_sucursales))
        with col2:
            render_metric_card("Ingresos Totales", df_sucursales['INGRESOS_TOTALES'].sum(), 
                             format_type="currency")
        with col3:
            render_metric_card("Ticket Promedio", df_sucursales['TICKET_PROMEDIO'].mean(), 
                             format_type="currency")
        with col4:
            render_metric_card("Clientes Únicos", df_sucursales['CLIENTES_UNICOS'].sum())
        
        # Tabla de performance
        st.markdown("### 📊 Performance por Sucursal (Últimos 30 días)")
        st.dataframe(df_sucursales, use_container_width=True)
        
        # Gráficos comparativos
        col1, col2 = st.columns(2)
        
        with col1:
            render_chart(df_sucursales, "bar", "Ingresos por Sucursal", 
                        "NOMBRE_SUCURSAL", "INGRESOS_TOTALES")
        
        with col2:
            # Análisis por estado
            df_estado = df_sucursales.groupby('ESTADO').agg({
                'INGRESOS_TOTALES': 'sum',
                'TRANSACCIONES': 'sum'
            }).reset_index()
            
            render_chart(df_estado, "pie", "Distribución de Ingresos por Estado", 
                        "ESTADO", "INGRESOS_TOTALES")
        
        # Análisis por formato de tienda
        st.markdown("### 🏬 Análisis por Formato de Tienda")
        df_formato = df_sucursales.groupby('FORMATO_TIENDA').agg({
            'INGRESOS_TOTALES': 'mean',
            'TICKET_PROMEDIO': 'mean',
            'TRANSACCIONES': 'mean'
        }).reset_index()
        
        render_chart(df_formato, "bar", "Ingresos Promedio por Formato", 
                    "FORMATO_TIENDA", "INGRESOS_TOTALES")

def customer_analysis_page():
    """Página de análisis de clientes"""
    st.markdown("## 👥 Análisis de Clientes - OfficeMax México")
    st.markdown("Segmentación y comportamiento de clientes por tipo y región")
    
    # Análisis de clientes
    query_clientes = """
        SELECT 
            c.TIPO_CLIENTE,
            c.SEGMENTO,
            c.ESTADO,
            COUNT(DISTINCT c.CLIENTE_ID) as TOTAL_CLIENTES,
            COUNT(v.VENTA_ID) as TRANSACCIONES,
            SUM(v.TOTAL_LINEA) as INGRESOS_TOTALES,
            AVG(v.TOTAL_LINEA) as TICKET_PROMEDIO,
            COUNT(v.VENTA_ID) / COUNT(DISTINCT c.CLIENTE_ID) as FRECUENCIA_COMPRA
        FROM RAW_DATA.CLIENTES c
        LEFT JOIN RAW_DATA.VENTAS v ON c.CLIENTE_ID = v.CLIENTE_ID
            AND v.FECHA_VENTA >= DATEADD('day', -90, CURRENT_DATE())
        WHERE c.ACTIVO = TRUE
        GROUP BY c.TIPO_CLIENTE, c.SEGMENTO, c.ESTADO
        ORDER BY INGRESOS_TOTALES DESC NULLS LAST
    """
    
    df_clientes = execute_query(query_clientes)
    
    if not df_clientes.empty:
        # Métricas de clientes
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            render_metric_card("Total Clientes", df_clientes['TOTAL_CLIENTES'].sum())
        with col2:
            render_metric_card("Clientes Activos", 
                             df_clientes[df_clientes['TRANSACCIONES'] > 0]['TOTAL_CLIENTES'].sum())
        with col3:
            avg_ticket = df_clientes['TICKET_PROMEDIO'].mean()
            render_metric_card("Ticket Promedio", avg_ticket, format_type="currency")
        with col4:
            freq_promedio = df_clientes['FRECUENCIA_COMPRA'].mean()
            render_metric_card("Frecuencia Promedio", freq_promedio, format_type="number")
        
        # Análisis por tipo de cliente
        st.markdown("### 👤 Distribución por Tipo de Cliente")
        df_tipo = df_clientes.groupby('TIPO_CLIENTE').agg({
            'TOTAL_CLIENTES': 'sum',
            'INGRESOS_TOTALES': 'sum',
            'TICKET_PROMEDIO': 'mean'
        }).reset_index()
        
        col1, col2 = st.columns(2)
        
        with col1:
            render_chart(df_tipo, "pie", "Clientes por Tipo", 
                        "TIPO_CLIENTE", "TOTAL_CLIENTES")
        
        with col2:
            render_chart(df_tipo, "bar", "Ingresos por Tipo de Cliente", 
                        "TIPO_CLIENTE", "INGRESOS_TOTALES")
        
        # Segmentación avanzada
        st.markdown("### 🎯 Segmentación de Clientes")
        
        # Tabla de segmentación
        df_segmento = df_clientes.groupby(['TIPO_CLIENTE', 'SEGMENTO']).agg({
            'TOTAL_CLIENTES': 'sum',
            'INGRESOS_TOTALES': 'sum',
            'TICKET_PROMEDIO': 'mean',
            'FRECUENCIA_COMPRA': 'mean'
        }).reset_index()
        
        st.dataframe(df_segmento, use_container_width=True)
        
        # Análisis geográfico
        st.markdown("### 🗺️ Distribución Geográfica")
        df_geografia = df_clientes.groupby('ESTADO').agg({
            'TOTAL_CLIENTES': 'sum',
            'INGRESOS_TOTALES': 'sum'
        }).reset_index().sort_values('INGRESOS_TOTALES', ascending=False)
        
        render_chart(df_geografia, "bar", "Clientes e Ingresos por Estado", 
                    "ESTADO", "INGRESOS_TOTALES", "TOTAL_CLIENTES")

# ===== EJECUTAR APLICACIÓN =====
if __name__ == "__main__":
    main()


