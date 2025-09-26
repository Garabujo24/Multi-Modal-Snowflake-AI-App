import streamlit as st
import requests
import pandas as pd
import json
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
import base64
from io import BytesIO

# =================================================================
# CONFIGURACIÓN DE LA PÁGINA Y ESTILOS MONEX
# =================================================================

st.set_page_config(
    page_title="Monex Grupo Financiero - Analytics Hub",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Colores corporativos oficiales de Monex
MONEX_COLORS = {
    'primary': '#1A237E',      # Índigo profundo moderno
    'secondary': '#303F9F',    # Índigo medio elegante
    'tertiary': '#3F51B5',     # Índigo claro dinámico
    'light_blue': '#5C6BC0',   # Índigo suave
    'accent': '#00BCD4',       # Cian vibrante (principal)
    'accent_light': '#26C6DA', # Cian claro brillante
    'accent_dark': '#0097A7',  # Cian oscuro profundo
    'gold': '#FFC107',         # Ámbar dorado premium
    'success': '#4CAF50',      # Verde material moderno
    'warning': '#FF9800',      # Naranja material
    'error': '#F44336',        # Rojo material vibrante
    'info': '#2196F3',         # Azul material brillante
    'purple': '#9C27B0',       # Púrpura material para acentos
    'teal': '#009688',         # Verde azulado elegante
    'gray': '#607D8B',         # Gris azulado moderno
    'light_gray': '#F8F9FA',   # Gris casi blanco
    'dark_gray': '#263238',    # Gris azulado oscuro
    'medium_gray': '#78909C',  # Gris azulado medio
    'white': '#FFFFFF',
    'black': '#000000',
    'background': '#FAFBFC'    # Fondo suave moderno
}

# CSS personalizado con imagen corporativa de Monex
def load_css():
    st.markdown(f"""
    <style>
    /* Importar fuentes de Google */
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
    
    /* Variables CSS para colores Monex */
    :root {{
        --monex-primary: {MONEX_COLORS['primary']};
        --monex-secondary: {MONEX_COLORS['secondary']};
        --monex-tertiary: {MONEX_COLORS['tertiary']};
        --monex-light-blue: {MONEX_COLORS['light_blue']};
        --monex-accent: {MONEX_COLORS['accent']};
        --monex-accent-light: {MONEX_COLORS['accent_light']};
        --monex-accent-dark: {MONEX_COLORS['accent_dark']};
        --monex-gold: {MONEX_COLORS['gold']};
        --monex-warning: {MONEX_COLORS['warning']};
        --monex-error: {MONEX_COLORS['error']};
        --monex-success: {MONEX_COLORS['success']};
        --monex-info: {MONEX_COLORS['info']};
        --monex-purple: {MONEX_COLORS['purple']};
        --monex-teal: {MONEX_COLORS['teal']};
        --monex-gray: {MONEX_COLORS['gray']};
        --monex-light-gray: {MONEX_COLORS['light_gray']};
        --monex-dark-gray: {MONEX_COLORS['dark_gray']};
        --monex-medium-gray: {MONEX_COLORS['medium_gray']};
        --monex-background: {MONEX_COLORS['background']};
    }}
    
    /* Estilos generales */
    .main {{
        font-family: 'Inter', sans-serif;
        background: {MONEX_COLORS['background']};
        color: {MONEX_COLORS['dark_gray']};
    }}
    
    /* Texto general más legible */
    body, .main, .block-container {{
        color: {MONEX_COLORS['dark_gray']} !important;
    }}
    
    /* Streamlit components con mejor contraste */
    .stSelectbox > div > div {{
        background-color: {MONEX_COLORS['white']} !important;
        border: 2px solid {MONEX_COLORS['secondary']} !important;
        color: {MONEX_COLORS['dark_gray']} !important;
    }}
    
    .stTextInput > div > div > input {{
        background-color: {MONEX_COLORS['white']} !important;
        border: 2px solid {MONEX_COLORS['secondary']} !important;
        color: {MONEX_COLORS['dark_gray']} !important;
    }}
    
    .stTextArea > div > div > textarea {{
        background-color: {MONEX_COLORS['white']} !important;
        border: 2px solid {MONEX_COLORS['secondary']} !important;
        color: {MONEX_COLORS['dark_gray']} !important;
    }}
    
    /* Header personalizado de Monex */
    .monex-header {{
        background: linear-gradient(135deg, {MONEX_COLORS['primary']} 0%, {MONEX_COLORS['secondary']} 40%, {MONEX_COLORS['tertiary']} 70%, {MONEX_COLORS['light_blue']} 100%);
        padding: 2rem 2.5rem;
        border-radius: 20px;
        margin-bottom: 2rem;
        box-shadow: 0 12px 40px rgba(26, 35, 126, 0.4), 0 4px 16px rgba(0, 188, 212, 0.2);
        border: 3px solid {MONEX_COLORS['accent']};
        position: relative;
        overflow: hidden;
    }}
    
    .monex-header::before {{
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(45deg, transparent 20%, rgba(0, 188, 212, 0.15) 40%, rgba(255, 255, 255, 0.1) 60%, transparent 80%);
        z-index: 1;
        animation: shimmer 3s ease-in-out infinite;
    }}
    
    @keyframes shimmer {{
        0%, 100% {{ opacity: 0.3; }}
        50% {{ opacity: 0.7; }}
    }}
    
    .monex-logo {{
        display: flex;
        align-items: center;
        gap: 1.5rem;
        margin-bottom: 0;
        position: relative;
        z-index: 2;
    }}
    
    .monex-title {{
        font-size: 3.2rem;
        font-weight: 900;
        margin: 0;
        text-shadow: 3px 3px 8px rgba(0,0,0,0.5);
        letter-spacing: 3px;
        background: linear-gradient(45deg, {MONEX_COLORS['white']} 0%, {MONEX_COLORS['accent_light']} 50%, {MONEX_COLORS['gold']} 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        filter: drop-shadow(0 0 20px rgba(0, 188, 212, 0.6));
        animation: glow 2s ease-in-out infinite alternate;
    }}
    
    @keyframes glow {{
        from {{ filter: drop-shadow(0 0 20px rgba(0, 188, 212, 0.6)); }}
        to {{ filter: drop-shadow(0 0 30px rgba(255, 193, 7, 0.8)); }}
    }}
    
    .monex-subtitle {{
        color: {MONEX_COLORS['white']};
        font-size: 1.4rem;
        font-weight: 600;
        margin: 0.5rem 0 0 0;
        text-shadow: 2px 2px 6px rgba(0,0,0,0.7);
        opacity: 1;
        letter-spacing: 1.2px;
        background: linear-gradient(90deg, {MONEX_COLORS['white']} 30%, {MONEX_COLORS['accent']} 70%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
    }}
    
    /* Métricas personalizadas */
    .metric-card {{
        background: linear-gradient(135deg, {MONEX_COLORS['white']} 0%, rgba(248, 249, 250, 0.9) 100%);
        padding: 1.8rem;
        border-radius: 16px;
        border: 2px solid transparent;
        background-clip: padding-box;
        box-shadow: 0 6px 25px rgba(26, 35, 126, 0.12), 0 2px 8px rgba(0, 188, 212, 0.08);
        margin-bottom: 1.2rem;
        transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
        position: relative;
        overflow: hidden;
    }}
    
    .metric-card::before {{
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, {MONEX_COLORS['accent']} 0%, {MONEX_COLORS['purple']} 50%, {MONEX_COLORS['teal']} 100%);
    }}
    
    .metric-card:hover {{
        transform: translateY(-5px) scale(1.02);
        box-shadow: 0 12px 40px rgba(26, 35, 126, 0.18), 0 6px 16px rgba(0, 188, 212, 0.12);
        border-color: {MONEX_COLORS['accent']};
    }}
    
    .metric-card:hover::before {{
        height: 6px;
        background: linear-gradient(90deg, {MONEX_COLORS['accent_light']} 0%, {MONEX_COLORS['gold']} 50%, {MONEX_COLORS['accent']} 100%);
    }}
    
    .metric-value {{
        font-size: 2.5rem;
        font-weight: 800;
        color: {MONEX_COLORS['primary']};
        margin: 0;
        text-shadow: 1px 1px 2px rgba(0,0,0,0.1);
    }}
    
    .metric-label {{
        font-size: 1rem;
        color: {MONEX_COLORS['dark_gray']};
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        margin-bottom: 0.5rem;
    }}
    
    .metric-delta {{
        font-size: 0.9rem;
        font-weight: 700;
        margin-top: 0.5rem;
        padding: 0.25rem 0.5rem;
        border-radius: 4px;
        display: inline-block;
    }}
    
    .positive {{ 
        color: {MONEX_COLORS['white']};
        background-color: {MONEX_COLORS['success']};
    }}
    .negative {{ 
        color: {MONEX_COLORS['white']};
        background-color: {MONEX_COLORS['error']};
    }}
    
    /* Sidebar personalizado */
    .css-1d391kg {{
        background: linear-gradient(180deg, {MONEX_COLORS['primary']} 0%, {MONEX_COLORS['secondary']} 100%);
    }}
    
    .css-1d391kg .css-1544g2n {{
        color: {MONEX_COLORS['white']} !important;
        font-weight: 600;
    }}
    
    /* Texto del sidebar */
    .css-1d391kg label {{
        color: {MONEX_COLORS['white']} !important;
        font-weight: 600 !important;
    }}
    
    /* Botones personalizados */
    .stButton > button {{
        background: linear-gradient(135deg, {MONEX_COLORS['accent']} 0%, {MONEX_COLORS['accent_light']} 50%, {MONEX_COLORS['accent']} 100%);
        color: {MONEX_COLORS['white']};
        border: none;
        border-radius: 12px;
        padding: 0.9rem 2.5rem;
        font-weight: 700;
        font-size: 1rem;
        transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
        box-shadow: 0 6px 20px rgba(0, 188, 212, 0.3), 0 2px 8px rgba(0, 188, 212, 0.2);
        text-transform: uppercase;
        letter-spacing: 1px;
        position: relative;
        overflow: hidden;
    }}
    
    .stButton > button::before {{
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
        transition: left 0.5s;
    }}
    
    .stButton > button:hover {{
        transform: translateY(-3px) scale(1.05);
        box-shadow: 0 10px 30px rgba(0, 188, 212, 0.4), 0 4px 12px rgba(156, 39, 176, 0.2);
        background: linear-gradient(135deg, {MONEX_COLORS['purple']} 0%, {MONEX_COLORS['accent']} 50%, {MONEX_COLORS['teal']} 100%);
    }}
    
    .stButton > button:hover::before {{
        left: 100%;
    }}
    
    /* Botones primarios especiales */
    .stButton > button[kind="primary"] {{
        background: linear-gradient(135deg, {MONEX_COLORS['primary']} 0%, {MONEX_COLORS['secondary']} 50%, {MONEX_COLORS['tertiary']} 100%);
        box-shadow: 0 6px 20px rgba(26, 35, 126, 0.3), 0 2px 8px rgba(63, 81, 181, 0.2);
        color: {MONEX_COLORS['white']};
        font-weight: 800;
    }}
    
    .stButton > button[kind="primary"]:hover {{
        background: linear-gradient(135deg, {MONEX_COLORS['teal']} 0%, {MONEX_COLORS['accent']} 50%, {MONEX_COLORS['gold']} 100%);
        box-shadow: 0 10px 30px rgba(0, 150, 136, 0.4), 0 4px 12px rgba(255, 193, 7, 0.2);
    }}
    
    /* Chat y resultados */
    .chat-container {{
        background: {MONEX_COLORS['white']};
        padding: 2rem;
        border-radius: 15px;
        border: 3px solid {MONEX_COLORS['secondary']};
        margin-bottom: 1.5rem;
        box-shadow: 0 5px 20px rgba(0, 17, 34, 0.15);
    }}
    
    .search-result {{
        background: {MONEX_COLORS['white']};
        padding: 1.5rem;
        border-radius: 10px;
        border-left: 5px solid {MONEX_COLORS['accent']};
        border: 2px solid {MONEX_COLORS['light_gray']};
        margin-bottom: 1rem;
        box-shadow: 0 3px 12px rgba(245, 124, 0, 0.1);
        transition: all 0.3s ease;
    }}
    
    .search-result:hover {{
        border-left-color: {MONEX_COLORS['accent_dark']};
        border-color: {MONEX_COLORS['accent']};
        transform: translateY(-2px);
        box-shadow: 0 5px 20px rgba(245, 124, 0, 0.2);
    }}
    
    .search-result h4 {{
        color: {MONEX_COLORS['primary']} !important;
        font-weight: 700 !important;
        margin-bottom: 0.5rem !important;
    }}
    
    .search-result p {{
        color: {MONEX_COLORS['dark_gray']} !important;
        font-weight: 500 !important;
    }}
    
    /* Alertas y mensajes */
    .alert-info {{
        background: {MONEX_COLORS['white']};
        border-left: 5px solid {MONEX_COLORS['info']};
        border: 2px solid {MONEX_COLORS['info']};
        padding: 1.5rem;
        border-radius: 10px;
        margin: 1rem 0;
        color: {MONEX_COLORS['primary']};
        font-weight: 600;
        box-shadow: 0 3px 15px rgba(25, 118, 210, 0.15);
    }}
    
    .alert-success {{
        background: {MONEX_COLORS['white']};
        border-left: 5px solid {MONEX_COLORS['success']};
        border: 2px solid {MONEX_COLORS['success']};
        padding: 1.5rem;
        border-radius: 10px;
        margin: 1rem 0;
        color: {MONEX_COLORS['dark_gray']};
        font-weight: 600;
        box-shadow: 0 3px 15px rgba(46, 125, 50, 0.15);
    }}
    
    .alert-warning {{
        background: {MONEX_COLORS['white']};
        border-left: 5px solid {MONEX_COLORS['accent']};
        border: 2px solid {MONEX_COLORS['accent']};
        padding: 1.5rem;
        border-radius: 10px;
        margin: 1rem 0;
        color: {MONEX_COLORS['dark_gray']};
        font-weight: 600;
        box-shadow: 0 3px 15px rgba(245, 124, 0, 0.15);
    }}
    
    .alert-error {{
        background: {MONEX_COLORS['white']};
        border-left: 5px solid {MONEX_COLORS['error']};
        border: 2px solid {MONEX_COLORS['error']};
        padding: 1.5rem;
        border-radius: 10px;
        margin: 1rem 0;
        color: {MONEX_COLORS['dark_gray']};
        font-weight: 600;
        box-shadow: 0 3px 15px rgba(211, 47, 47, 0.15);
    }}
    
    /* Tablas personalizadas */
    .dataframe {{
        border-radius: 10px;
        overflow: hidden;
        box-shadow: 0 4px 20px rgba(0, 17, 34, 0.15);
        border: 2px solid {MONEX_COLORS['light_gray']};
    }}
    
    .dataframe th {{
        background-color: {MONEX_COLORS['secondary']} !important;
        color: {MONEX_COLORS['white']} !important;
        font-weight: 700 !important;
        border: none !important;
    }}
    
    .dataframe td {{
        color: {MONEX_COLORS['dark_gray']} !important;
        font-weight: 500 !important;
        border-bottom: 1px solid {MONEX_COLORS['light_gray']} !important;
    }}
    
    /* Elementos Streamlit mejorados */
    .stMarkdown {{
        color: {MONEX_COLORS['dark_gray']} !important;
    }}
    
    .stSelectbox label, .stTextInput label, .stTextArea label {{
        color: {MONEX_COLORS['dark_gray']} !important;
        font-weight: 600 !important;
        font-size: 1rem !important;
    }}
    
    /* Títulos y headers */
    h1, h2, h3, h4, h5, h6 {{
        color: {MONEX_COLORS['primary']} !important;
        font-weight: 700 !important;
    }}
    
    /* Texto general */
    p, span, div {{
        color: {MONEX_COLORS['dark_gray']} !important;
    }}
    
    /* Footer */
    .monex-footer {{
        text-align: center;
        padding: 2rem;
        color: {MONEX_COLORS['medium_gray']};
        font-size: 1rem;
        font-weight: 500;
        border-top: 3px solid {MONEX_COLORS['secondary']};
        margin-top: 3rem;
        background: {MONEX_COLORS['light_gray']};
    }}
    
    /* Mejorar contraste de elementos Streamlit específicos */
    .stTabs [data-baseweb="tab-list"] {{
        gap: 8px;
    }}
    
    .stTabs [data-baseweb="tab"] {{
        background-color: {MONEX_COLORS['light_gray']};
        color: {MONEX_COLORS['dark_gray']};
        border: 2px solid {MONEX_COLORS['primary']};
        border-radius: 8px;
        font-weight: 600;
    }}
    
    .stTabs [data-baseweb="tab"]:hover {{
        background-color: {MONEX_COLORS['white']};
        border-color: {MONEX_COLORS['accent']};
        color: {MONEX_COLORS['accent']};
    }}
    
    .stTabs [aria-selected="true"] {{
        background-color: {MONEX_COLORS['accent']} !important;
        color: {MONEX_COLORS['white']} !important;
        border-color: {MONEX_COLORS['primary']} !important;
    }}
    </style>
    """, unsafe_allow_html=True)

def create_monex_logo_svg():
    """Crear SVG del logo de Monex"""
    return f"""
    <svg width="60" height="60" viewBox="0 0 60 60" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="60" height="60" rx="12" fill="{MONEX_COLORS['white']}" fill-opacity="0.2"/>
        <path d="M15 20H20L25 35L30 20H35L40 35L45 20H50M15 40H50" stroke="{MONEX_COLORS['white']}" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
        <circle cx="30" cy="15" r="3" fill="{MONEX_COLORS['accent']}"/>
        <text x="30" y="50" text-anchor="middle" fill="{MONEX_COLORS['white']}" font-size="8" font-weight="bold">MONEX</text>
    </svg>
    """

# =================================================================
# CONFIGURACIÓN DE CONEXIÓN Y SESIÓN
# =================================================================

@st.cache_resource
def get_snowflake_session():
    """Obtener sesión de Snowflake"""
    try:
        from snowflake.snowpark.context import get_active_session
        return get_active_session()
    except:
        st.error("❌ No se pudo conectar a Snowflake. Asegúrate de que la aplicación esté ejecutándose en Snowflake.")
        return None

# =================================================================
# FUNCIONES DE CORTEX ANALYST
# =================================================================

def send_analyst_message(prompt: str, session) -> dict:
    """Enviar mensaje a Cortex Analyst usando el REST API"""
    try:
        import _snowflake
        import json
        
        # Configurar la API de Cortex Analyst
        API_ENDPOINT = "/api/v2/cortex/analyst/message"
        API_TIMEOUT = 60000  # 60 segundos
        
        # Preparar el cuerpo de la solicitud
        messages = [{"role": "user", "content": [{"type": "text", "text": prompt}]}]
        request_body = {
            "messages": messages,
            "semantic_model_file": "@MONEX_DB.STAGES.SEMANTIC_MODELS/monex_semantic_model.yaml",
        }
        
        # Enviar solicitud al API de Cortex Analyst
        resp = _snowflake.send_snow_api_request(
            "POST",  # método
            API_ENDPOINT,  # ruta
            {},  # headers
            {},  # parámetros
            request_body,  # cuerpo
            None,  # request_guid
            API_TIMEOUT,  # timeout en milisegundos
        )
        
        # Parsear el contenido de la respuesta
        parsed_content = json.loads(resp["content"])
        
        # Verificar si la respuesta es exitosa
        if resp["status"] < 400:
            return {"success": True, "data": parsed_content}
        else:
            error_msg = f"Error {resp['status']}: {parsed_content.get('message', 'Error desconocido')}"
            return {"success": False, "error": error_msg}
            
    except Exception as e:
        return {"success": False, "error": f"Error al consultar Cortex Analyst: {str(e)}"}

# =================================================================
# FUNCIONES DE CORTEX SEARCH
# =================================================================

def search_documents(query: str, service_name: str, session, limit: int = 5) -> dict:
    """Buscar en documentos usando Cortex Search"""
    try:
        # Limpiar la query de caracteres problemáticos
        clean_query = query.replace('•', '').strip()
        
        # Usar la función correcta de Cortex Search con parámetros SQL
        search_query = """
        SELECT PARSE_JSON(
            SYSTEM$CORTEX_SEARCH_QUERY(?, ?)
        )['results'] as results
        """
        
        # Construir el JSON de búsqueda de forma segura
        search_options = '{"query": "' + clean_query.replace('"', '\\"') + '", "columns": ["TITULO", "CATEGORIA", "FECHA_DOCUMENTO"], "limit": ' + str(limit) + '}'
        
        result = session.sql(search_query, [service_name, search_options]).collect()
        
        if result and result[0]['RESULTS']:
            results_data = result[0]['RESULTS']
            
            # Si results_data es una lista de diccionarios, retornarla directamente
            if isinstance(results_data, list):
                return {"success": True, "data": results_data}
            
            # Si es un string JSON, parsearlo
            elif isinstance(results_data, str):
                try:
                    import json
                    parsed_results = json.loads(results_data)
                    return {"success": True, "data": parsed_results if isinstance(parsed_results, list) else [parsed_results]}
                except:
                    return {"success": True, "data": []}
            
            # Para cualquier otro tipo, convertir a string
            else:
                return {"success": True, "data": [{"TITULO": str(results_data), "CATEGORIA": "N/A", "FECHA_DOCUMENTO": "N/A"}]}
        else:
            return {"success": True, "data": []}
            
    except Exception as e:
        return {"success": False, "error": str(e)}

# =================================================================
# FUNCIONES DE VISUALIZACIÓN
# =================================================================

def create_metric_card(title: str, value: str, delta: str = None, delta_positive: bool = True):
    """Crear tarjeta de métrica personalizada"""
    delta_class = "positive" if delta_positive else "negative" if delta else ""
    delta_symbol = "📈" if delta_positive else "📉" if delta else ""
    
    delta_html = f"""
    <div class="metric-delta {delta_class}">
        {delta_symbol} {delta}
    </div>
    """ if delta else ""
    
    return f"""
    <div class="metric-card">
        <div class="metric-label">{title}</div>
        <div class="metric-value">{value}</div>
        {delta_html}
    </div>
    """

def create_plotly_chart(df: pd.DataFrame, chart_type: str, title: str):
    """Crear gráfico con tema Monex"""
    color_sequence = [MONEX_COLORS['primary'], MONEX_COLORS['secondary'], 
                     MONEX_COLORS['tertiary'], MONEX_COLORS['light_blue'], 
                     MONEX_COLORS['gold'], MONEX_COLORS['accent'], 
                     MONEX_COLORS['warning'], MONEX_COLORS['success']]
    
    if chart_type == "bar":
        fig = px.bar(df, x=df.columns[0], y=df.columns[1], title=title,
                    color_discrete_sequence=color_sequence)
    elif chart_type == "line":
        fig = px.line(df, x=df.columns[0], y=df.columns[1], title=title,
                     color_discrete_sequence=color_sequence)
    elif chart_type == "pie":
        fig = px.pie(df, names=df.columns[0], values=df.columns[1], title=title,
                    color_discrete_sequence=color_sequence)
    
    # Personalizar tema
    fig.update_layout(
        plot_bgcolor=MONEX_COLORS['white'],
        paper_bgcolor=MONEX_COLORS['white'],
        font_family="Inter",
        title_font_size=18,
        title_font_color=MONEX_COLORS['primary'],
        title_font_weight=700,
        showlegend=True,
        legend=dict(
            bgcolor=MONEX_COLORS['white'],
            bordercolor=MONEX_COLORS['secondary'],
            borderwidth=1,
            font=dict(color=MONEX_COLORS['dark_gray'], size=12)
        ),
        xaxis=dict(
            color=MONEX_COLORS['dark_gray'],
            gridcolor=MONEX_COLORS['light_gray'],
            linecolor=MONEX_COLORS['secondary']
        ),
        yaxis=dict(
            color=MONEX_COLORS['dark_gray'],
            gridcolor=MONEX_COLORS['light_gray'],
            linecolor=MONEX_COLORS['secondary']
        )
    )
    
    return fig

# =================================================================
# FUNCIONES DE DATOS Y MÉTRICAS
# =================================================================

@st.cache_data(ttl=300)  # Cache por 5 minutos
def get_dashboard_metrics(_session):
    """Obtener métricas principales del dashboard"""
    try:
        # Total de clientes
        total_clientes = _session.sql("SELECT COUNT(*) as total FROM MONEX_DB.CORE.CLIENTES WHERE ESTATUS = 'ACTIVO'").collect()[0]['TOTAL']
        
        # Volumen de transacciones del mes
        volumen_mes = _session.sql("""
            SELECT COALESCE(SUM(MONTO), 0) as volumen 
            FROM MONEX_DB.CORE.TRANSACCIONES 
            WHERE DATE_TRUNC('MONTH', FECHA_TRANSACCION) = DATE_TRUNC('MONTH', CURRENT_DATE())
            AND ESTADO = 'COMPLETADA'
        """).collect()[0]['VOLUMEN']
        
        # Total inversiones activas
        inversiones_usd = _session.sql("""
            SELECT COALESCE(SUM(VALOR_ACTUAL), 0) as total 
            FROM MONEX_DB.CORE.INVERSIONES 
            WHERE ESTADO = 'ACTIVA' AND MONEDA = 'USD'
        """).collect()[0]['TOTAL']
        
        # Volumen factoraje vigente
        factoraje_vigente = _session.sql("""
            SELECT COALESCE(SUM(MONTO_FACTURA), 0) as total 
            FROM MONEX_DB.CORE.FACTORAJE 
            WHERE ESTADO = 'VIGENTE'
        """).collect()[0]['TOTAL']
        
        return {
            "clientes": f"{total_clientes:,}",
            "volumen_mes": f"${volumen_mes:,.0f}",
            "inversiones_usd": f"${inversiones_usd:,.0f} USD",
            "factoraje": f"${factoraje_vigente:,.0f}"
        }
    except Exception as e:
        st.error(f"Error obteniendo métricas: {e}")
        return {
            "clientes": "N/A",
            "volumen_mes": "N/A",
            "inversiones_usd": "N/A",
            "factoraje": "N/A"
        }

# =================================================================
# INTERFAZ PRINCIPAL
# =================================================================

def main():
    load_css()
    
    # Header de Monex
    st.markdown(f"""
    <div class="monex-header">
        <div class="monex-logo">
            {create_monex_logo_svg()}
            <div>
                <h1 class="monex-title">MONEX</h1>
                <p class="monex-subtitle">Grupo Financiero • Analytics Hub powered by Snowflake Cortex</p>
            </div>
        </div>
    </div>
    """, unsafe_allow_html=True)
    
    # Obtener sesión de Snowflake
    session = get_snowflake_session()
    if not session:
        return
    
    # Sidebar con opciones
    with st.sidebar:
        st.markdown("### 🏦 Servicios Monex")
        
        mode = st.selectbox(
            "Selecciona el tipo de análisis:",
            ["📊 Dashboard Ejecutivo", "🤖 Cortex Analyst", "🔍 Cortex Search", "📈 Análisis Avanzado"]
        )
        
        st.markdown("---")
        st.markdown("### ℹ️ Información")
        st.info("""
        **Cortex Analyst**: Análisis de datos estructurados con IA
        
        **Cortex Search**: Búsqueda inteligente en documentos
        
        **Dashboard**: Métricas clave en tiempo real
        """)
    
    # =================================================================
    # DASHBOARD EJECUTIVO
    # =================================================================
    
    if mode == "📊 Dashboard Ejecutivo":
        st.markdown("## 📊 Dashboard Ejecutivo")
        
        # Métricas principales
        metrics = get_dashboard_metrics(session)
        
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.markdown(create_metric_card("Clientes Activos", metrics["clientes"], "+5.2%"), unsafe_allow_html=True)
        
        with col2:
            st.markdown(create_metric_card("Volumen Mensual", metrics["volumen_mes"], "+12.8%"), unsafe_allow_html=True)
        
        with col3:
            st.markdown(create_metric_card("Inversiones USD", metrics["inversiones_usd"], "+8.4%"), unsafe_allow_html=True)
        
        with col4:
            st.markdown(create_metric_card("Factoraje Vigente", metrics["factoraje"], "+15.6%"), unsafe_allow_html=True)
        
        # Gráficos
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("### 📈 Transacciones por Tipo")
            try:
                df_trans = session.sql("""
                    SELECT TIPO_TRANSACCION, COUNT(*) as CANTIDAD
                    FROM MONEX_DB.CORE.TRANSACCIONES 
                    WHERE FECHA_TRANSACCION >= DATEADD(day, -30, CURRENT_DATE())
                    GROUP BY TIPO_TRANSACCION
                    ORDER BY CANTIDAD DESC
                """).to_pandas()
                
                if not df_trans.empty:
                    fig = create_plotly_chart(df_trans, "pie", "Distribución de Transacciones (30 días)")
                    st.plotly_chart(fig, use_container_width=True)
            except Exception as e:
                st.error(f"Error cargando gráfico: {e}")
        
        with col2:
            st.markdown("### 💰 Rendimiento por Estrategia USD")
            try:
                df_inv = session.sql("""
                    SELECT FONDO_ESTRATEGIA, AVG(RENDIMIENTO_ANUAL) as RENDIMIENTO
                    FROM MONEX_DB.CORE.INVERSIONES 
                    WHERE ESTADO = 'ACTIVA' AND MONEDA = 'USD'
                    GROUP BY FONDO_ESTRATEGIA
                    ORDER BY RENDIMIENTO DESC
                """).to_pandas()
                
                if not df_inv.empty:
                    fig = create_plotly_chart(df_inv, "bar", "Rendimiento Promedio por Estrategia")
                    st.plotly_chart(fig, use_container_width=True)
            except Exception as e:
                st.error(f"Error cargando gráfico: {e}")
    
    # =================================================================
    # CORTEX ANALYST
    # =================================================================
    
    elif mode == "🤖 Cortex Analyst":
        st.markdown("## 🤖 Cortex Analyst - Análisis Inteligente")
        
        st.markdown("""
        <div class="alert-info">
            <strong>💡 Pregunta ejemplos:</strong><br>
            • ¿Cuáles son los ingresos totales por mes?<br>
            • ¿Cuántos clientes tenemos por segmento?<br>
            • ¿Cuál es el rendimiento de las inversiones USD?<br>
            • ¿Qué volumen de factoraje tenemos por empresa deudora?
        </div>
        """, unsafe_allow_html=True)
        
        # Input del usuario
        user_question = st.text_input(
            "💬 Haz tu pregunta sobre los datos de Monex:",
            placeholder="Ej: ¿Cuál es el volumen de transacciones por tipo en los últimos 3 meses?"
        )
        
        if st.button("🚀 Analizar", type="primary") and user_question:
            with st.spinner("🔄 Procesando consulta con Cortex Analyst..."):
                result = send_analyst_message(user_question, session)
                
                if result["success"]:
                    data = result["data"]
                    
                    # Mostrar respuesta
                    if "message" in data and "content" in data["message"]:
                        for content in data["message"]["content"]:
                            if content["type"] == "text":
                                st.markdown(f"""
                                <div class="chat-container">
                                    <h4>🤖 Respuesta de Cortex Analyst:</h4>
                                    <p>{content["text"]}</p>
                                </div>
                                """, unsafe_allow_html=True)
                            
                            elif content["type"] == "sql":
                                st.markdown("### 📋 Consulta SQL Generada:")
                                st.code(content["statement"], language="sql")
                                
                                # Ejecutar consulta y mostrar resultados
                                try:
                                    with st.spinner("⚡ Ejecutando consulta..."):
                                        df_result = session.sql(content["statement"]).to_pandas()
                                        
                                        if not df_result.empty:
                                            st.markdown("### 📊 Resultados:")
                                            st.dataframe(df_result, use_container_width=True)
                                            
                                            # Crear visualización automática
                                            if len(df_result.columns) >= 2 and len(df_result) > 1:
                                                chart_type = "line" if "fecha" in df_result.columns[0].lower() else "bar"
                                                fig = create_plotly_chart(df_result, chart_type, "Visualización de Resultados")
                                                st.plotly_chart(fig, use_container_width=True)
                                        else:
                                            st.info("No se encontraron datos para la consulta.")
                                            
                                except Exception as e:
                                    st.error(f"Error ejecutando consulta: {e}")
                            
                            elif content["type"] == "suggestions":
                                st.markdown("### 💡 Sugerencias:")
                                for suggestion in content["suggestions"]:
                                    if st.button(f"💭 {suggestion}", key=f"sugg_{suggestion}"):
                                        st.rerun()
                else:
                    st.error(f"❌ Error: {result['error']}")
    
    # =================================================================
    # CORTEX SEARCH
    # =================================================================
    
    elif mode == "🔍 Cortex Search":
        st.markdown("## 🔍 Cortex Search - Búsqueda Inteligente")
        
        # Selector de servicio de búsqueda
        search_service = st.selectbox(
            "📂 Selecciona el tipo de documento:",
            [
                "MONEX_DB.DOCUMENTS.MONEX_DOCUMENTS_SEARCH",
                "MONEX_DB.DOCUMENTS.MONEX_CONTRATOS_SEARCH", 
                "MONEX_DB.DOCUMENTS.MONEX_MANUALES_SEARCH"
            ],
            format_func=lambda x: {
                "MONEX_DB.DOCUMENTS.MONEX_DOCUMENTS_SEARCH": "📄 Todos los documentos",
                "MONEX_DB.DOCUMENTS.MONEX_CONTRATOS_SEARCH": "📋 Contratos",
                "MONEX_DB.DOCUMENTS.MONEX_MANUALES_SEARCH": "📖 Manuales y Políticas"
            }[x]
        )
        
        st.markdown("""
        <div class="alert-info">
            <strong>🔍 Búsquedas de ejemplo:</strong><br>
            • "factoraje sin recurso"<br>
            • "inversiones USD private banking"<br>
            • "tipos de cambio procedimientos"<br>
            • "crédito empresarial garantías"
        </div>
        """, unsafe_allow_html=True)
        
        # Input de búsqueda
        search_query = st.text_input(
            "🔎 Buscar en documentos:",
            placeholder="Ej: procedimientos de factoraje"
        )
        
        if st.button("🔍 Buscar", type="primary") and search_query:
            with st.spinner("🔄 Buscando en documentos..."):
                result = search_documents(search_query, search_service, session)
                
                if result["success"]:
                    documents = result["data"]
                    
                    if documents:
                        st.markdown(f"### 📋 Resultados encontrados: {len(documents)}")
                        
                        for i, doc in enumerate(documents):
                            # Verificar si doc es string y necesita parsing
                            if isinstance(doc, str):
                                try:
                                    import json
                                    doc = json.loads(doc)
                                except:
                                    # Si no es JSON válido, usar valores por defecto
                                    doc = {"TITULO": doc[:100] + "...", "CATEGORIA": "N/A", "FECHA_DOCUMENTO": "N/A"}
                            
                            # Asegurar que doc es un diccionario
                            if not isinstance(doc, dict):
                                doc = {"TITULO": str(doc), "CATEGORIA": "N/A", "FECHA_DOCUMENTO": "N/A"}
                            
                            st.markdown(f"""
                            <div class="search-result">
                                <h4>📄 {doc.get('TITULO', 'Sin título')}</h4>
                                <p><strong>Categoría:</strong> {doc.get('CATEGORIA', 'N/A')}</p>
                                <p><strong>Fecha:</strong> {doc.get('FECHA_DOCUMENTO', 'N/A')}</p>
                            </div>
                            """, unsafe_allow_html=True)
                    else:
                        st.info("🔍 No se encontraron documentos relacionados con tu búsqueda.")
                else:
                    st.error(f"❌ Error en la búsqueda: {result['error']}")
    
    # =================================================================
    # ANÁLISIS AVANZADO
    # =================================================================
    
    elif mode == "📈 Análisis Avanzado":
        st.markdown("## 📈 Análisis Avanzado")
        
        tab1, tab2, tab3 = st.tabs(["💱 Cambio de Divisas", "💰 Factoraje", "📊 Private Banking"])
        
        with tab1:
            st.markdown("### 💱 Análisis de Tipos de Cambio USD/MXN")
            try:
                # Últimos 30 días de tipos de cambio
                df_fx = session.sql("""
                    SELECT FECHA, TIPO_CAMBIO_COMPRA, TIPO_CAMBIO_VENTA,
                           VOLUMEN_TRANSACCIONES
                    FROM MONEX_DB.CORE.TIPOS_CAMBIO
                    WHERE MONEDA_ORIGEN = 'USD' AND MONEDA_DESTINO = 'MXN'
                      AND FECHA >= DATEADD(day, -30, CURRENT_DATE())
                    ORDER BY FECHA DESC
                """).to_pandas()
                
                if not df_fx.empty:
                    # Gráfico de tipos de cambio
                    fig = go.Figure()
                    fig.add_trace(go.Scatter(x=df_fx['FECHA'], y=df_fx['TIPO_CAMBIO_COMPRA'], 
                                           name='Compra', line=dict(color=MONEX_COLORS['secondary'])))
                    fig.add_trace(go.Scatter(x=df_fx['FECHA'], y=df_fx['TIPO_CAMBIO_VENTA'], 
                                           name='Venta', line=dict(color=MONEX_COLORS['primary'])))
                    
                    fig.update_layout(title="Evolución Tipos de Cambio USD/MXN (30 días)",
                                    xaxis_title="Fecha", yaxis_title="Tipo de Cambio")
                    st.plotly_chart(fig, use_container_width=True)
                    
                    # Métricas actuales
                    latest = df_fx.iloc[0]
                    col1, col2, col3 = st.columns(3)
                    with col1:
                        st.metric("💵 Compra", f"${latest['TIPO_CAMBIO_COMPRA']:.4f}")
                    with col2:
                        st.metric("💴 Venta", f"${latest['TIPO_CAMBIO_VENTA']:.4f}")
                    with col3:
                        spread = latest['TIPO_CAMBIO_VENTA'] - latest['TIPO_CAMBIO_COMPRA']
                        st.metric("📊 Spread", f"${spread:.4f}")
                        
            except Exception as e:
                st.error(f"Error cargando datos FX: {e}")
        
        with tab2:
            st.markdown("### 💰 Análisis de Factoraje")
            try:
                # Top empresas deudoras
                df_deudoras = session.sql("""
                    SELECT EMPRESA_DEUDORA, 
                           COUNT(*) as OPERACIONES,
                           SUM(MONTO_FACTURA) as VOLUMEN_TOTAL,
                           AVG(TASA_DESCUENTO) as TASA_PROMEDIO
                    FROM MONEX_DB.CORE.FACTORAJE
                    WHERE ESTADO = 'VIGENTE'
                    GROUP BY EMPRESA_DEUDORA
                    ORDER BY VOLUMEN_TOTAL DESC
                    LIMIT 10
                """).to_pandas()
                
                if not df_deudoras.empty:
                    st.markdown("#### 🏢 Top 10 Empresas Deudoras")
                    st.dataframe(df_deudoras, use_container_width=True)
                    
                    # Gráfico de volumen por deudora
                    fig = create_plotly_chart(df_deudoras.head(5), "bar", "Volumen de Factoraje por Empresa")
                    st.plotly_chart(fig, use_container_width=True)
                    
            except Exception as e:
                st.error(f"Error cargando datos de factoraje: {e}")
        
        with tab3:
            st.markdown("### 📊 Private Banking - Inversiones USD")
            try:
                # Rendimiento por estrategia
                df_strategies = session.sql("""
                    SELECT FONDO_ESTRATEGIA,
                           COUNT(*) as NUM_INVERSIONES,
                           SUM(MONTO_INVERTIDO) as CAPITAL_TOTAL,
                           SUM(VALOR_ACTUAL) as VALOR_ACTUAL,
                           AVG(RENDIMIENTO_ANUAL) as RENDIMIENTO_PROMEDIO
                    FROM MONEX_DB.CORE.INVERSIONES
                    WHERE ESTADO = 'ACTIVA' AND MONEDA = 'USD'
                    GROUP BY FONDO_ESTRATEGIA
                    ORDER BY RENDIMIENTO_PROMEDIO DESC
                """).to_pandas()
                
                if not df_strategies.empty:
                    st.markdown("#### 💎 Rendimiento por Estrategia de Inversión")
                    
                    # Formatear números
                    df_display = df_strategies.copy()
                    df_display['CAPITAL_TOTAL'] = df_display['CAPITAL_TOTAL'].apply(lambda x: f"${x:,.0f}")
                    df_display['VALOR_ACTUAL'] = df_display['VALOR_ACTUAL'].apply(lambda x: f"${x:,.0f}")
                    df_display['RENDIMIENTO_PROMEDIO'] = df_display['RENDIMIENTO_PROMEDIO'].apply(lambda x: f"{x:.2f}%")
                    
                    st.dataframe(df_display, use_container_width=True)
                    
                    # Gráfico de rendimientos
                    fig = create_plotly_chart(df_strategies, "bar", "Rendimiento Anual por Estrategia (%)")
                    st.plotly_chart(fig, use_container_width=True)
                    
            except Exception as e:
                st.error(f"Error cargando datos de inversiones: {e}")
    
    # Footer
    st.markdown("""
    <div class="monex-footer">
        <p>🏦 <strong>Monex Grupo Financiero</strong> | Powered by Snowflake Cortex AI</p>
        <p>📞 55-5231-4500 | 🌐 www.monex.com.mx</p>
    </div>
    """, unsafe_allow_html=True)

if __name__ == "__main__":
    main()
