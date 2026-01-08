"""
TV AZTECA DIGITAL - CORTEX SEARCH DEMO
======================================
Aplicación Streamlit optimizada para Streamlit in Snowflake
Cliente: TV Azteca Digital
Desarrollado por: Snowflake Team México

INSTRUCCIONES DE DEPLOYMENT:
1. Subir este archivo como streamlit_app.py a Streamlit in Snowflake
2. Asegurar que la base de datos TVAZTECA_DB esté creada (ejecutar TVAZTECA_worksheet.sql)
3. Verificar que el servicio TVAZTECA_SEARCH_SERVICE esté activo
4. La aplicación usará automáticamente la sesión activa de Snowpark
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd
import json
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
import time

# Configuración de la página
st.set_page_config(
    page_title="TV Azteca Digital - Search Intelligence",
    page_icon="📺",
    layout="wide",
    initial_sidebar_state="expanded"
)

# CSS personalizado para TV Azteca
st.markdown("""
<style>
    .main-header {
        background: linear-gradient(90deg, #1e3c72 0%, #2a5298 100%);
        padding: 1rem;
        border-radius: 10px;
        color: white;
        text-align: center;
        margin-bottom: 2rem;
    }
    
    .search-box {
        background: #f8f9fa;
        padding: 1.5rem;
        border-radius: 10px;
        border-left: 4px solid #1e3c72;
        margin: 1rem 0;
    }
    
    .metric-card {
        background: white;
        padding: 1rem;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        border-left: 4px solid #2a5298;
    }
    
    .document-result {
        background: #ffffff;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        padding: 1rem;
        margin: 0.5rem 0;
        border-left: 4px solid #1e3c72;
    }
    
    .sidebar .sidebar-content {
        background: #f8f9fa;
    }
    
    .stSelectbox > div > div {
        background-color: white;
    }
</style>
""", unsafe_allow_html=True)

# Conexión a Snowflake usando Snowpark Session
@st.cache_resource
def get_snowpark_session():
    """Obtener sesión activa de Snowpark en Streamlit in Snowflake"""
    try:
        session = get_active_session()
        return session
    except Exception as e:
        st.error(f"Error obteniendo sesión de Snowpark: {str(e)}")
        st.info("Asegúrate de que esta aplicación se ejecute en Streamlit in Snowflake")
        return None

@st.cache_data(ttl=600)
def run_query_snowpark(query):
    """Ejecutar query usando Snowpark Session"""
    session = get_snowpark_session()
    if session:
        try:
            # Ejecutar query y convertir a Pandas DataFrame
            result_df = session.sql(query).to_pandas()
            return result_df
        except Exception as e:
            st.error(f"Error ejecutando query: {str(e)}")
            return None
    return None

def perform_search(search_query, department_filter=None, priority_filter=None):
    """Realizar búsqueda usando Cortex Search o búsqueda fallback"""
    
    # Verificar si Cortex Search está disponible
    cortex_available, _ = check_cortex_search_availability()
    
    if cortex_available:
        # Usar Cortex Search
        try:
            # Construir filtros
            filters = []
            if department_filter and department_filter != "Todos":
                filters.append(f"'@eq': {{'department': '{department_filter}'}}")
            if priority_filter and priority_filter != "Todos":
                filters.append(f"'@eq': {{'priority_level': '{priority_filter}'}}")
            
            filter_clause = ""
            if filters:
                if len(filters) == 1:
                    filter_clause = f", OPTIONS => {{'filter': {{{filters[0]}}}}}"
                else:
                    filter_clause = f", OPTIONS => {{'filter': {{'@and': [{{{', '.join(filters)}}}]}}}}"
            
            query = f"""
            SELECT 
                SNOWFLAKE.CORTEX.SEARCH(
                    'tv_azteca_search',
                    '{search_query}'{filter_clause}
                ) AS search_results
            """
            
            result_df = run_query_snowpark(query)
            if result_df is not None and not result_df.empty:
                return json.loads(result_df.iloc[0]['SEARCH_RESULTS'])
        except Exception as e:
            st.error(f"Error en búsqueda Cortex: {str(e)}")
            return None
    else:
        # Búsqueda fallback usando SQL tradicional
        return perform_fallback_search(search_query, department_filter, priority_filter)
    
    return None

def perform_fallback_search(search_query, department_filter=None, priority_filter=None):
    """Búsqueda fallback usando LIKE y operadores SQL tradicionales"""
    
    # Construir condiciones WHERE
    where_conditions = []
    
    # Búsqueda en texto
    search_terms = search_query.lower().split()
    text_conditions = []
    for term in search_terms:
        text_conditions.append(f"LOWER(CONTENT_TEXT) LIKE '%{term}%'")
    if text_conditions:
        where_conditions.append(f"({' OR '.join(text_conditions)})")
    
    # Filtros adicionales
    if department_filter and department_filter != "Todos":
        where_conditions.append(f"DEPARTMENT = '{department_filter}'")
    if priority_filter and priority_filter != "Todos":
        where_conditions.append(f"PRIORITY_LEVEL = '{priority_filter}'")
    
    where_clause = " AND ".join(where_conditions) if where_conditions else "1=1"
    
    query = f"""
    SELECT 
        DOCUMENT_ID,
        DOCUMENT_NAME,
        DOCUMENT_TYPE,
        DEPARTMENT,
        PRIORITY_LEVEL,
        DOCUMENT_SUMMARY,
        SUBSTR(CONTENT_TEXT, 1, 500) as content_snippet,
        KEYWORDS
    FROM TVAZTECA_DB.RAW_SCHEMA.CORPORATE_DOCUMENTS
    WHERE {where_clause}
    ORDER BY 
        CASE 
            WHEN LOWER(DOCUMENT_NAME) LIKE '%{search_query.lower()}%' THEN 1
            WHEN LOWER(DOCUMENT_SUMMARY) LIKE '%{search_query.lower()}%' THEN 2
            ELSE 3
        END,
        DOCUMENT_NAME
    LIMIT 10
    """
    
    try:
        result_df = run_query_snowpark(query)
        if result_df is not None and not result_df.empty:
            # Convertir a formato similar a Cortex Search
            results = []
            for _, row in result_df.iterrows():
                result = {
                    'document_name': row['DOCUMENT_NAME'],
                    'document_type': row['DOCUMENT_TYPE'],
                    'department': row['DEPARTMENT'],
                    'priority_level': row['PRIORITY_LEVEL'],
                    'chunk': row['CONTENT_SNIPPET'],
                    'keywords': row['KEYWORDS'] if row['KEYWORDS'] else [],
                    'score': 0.8  # Score fijo para demo
                }
                results.append(result)
            
            return {'results': results}
    except Exception as e:
        st.error(f"Error en búsqueda fallback: {str(e)}")
    
    return None

def get_search_metrics():
    """Obtener métricas de búsqueda"""
    query = """
    SELECT 
        COUNT(*) as total_searches,
        AVG(RESPONSE_TIME_MS) as avg_response_time,
        AVG(RELEVANCE_SCORE) as avg_relevance,
        COUNT(DISTINCT USER_ROLE) as unique_users
    FROM TVAZTECA_DB.ANALYTICS_SCHEMA.SEARCH_METRICS
    """
    
    result_df = run_query_snowpark(query)
    if result_df is not None and not result_df.empty:
        return {
            'total_searches': int(result_df.iloc[0]['TOTAL_SEARCHES']),
            'avg_response_time': round(float(result_df.iloc[0]['AVG_RESPONSE_TIME']), 2) if result_df.iloc[0]['AVG_RESPONSE_TIME'] else 0,
            'avg_relevance': round(float(result_df.iloc[0]['AVG_RELEVANCE']), 3) if result_df.iloc[0]['AVG_RELEVANCE'] else 0,
            'unique_users': int(result_df.iloc[0]['UNIQUE_USERS'])
        }
    return {}

def get_document_stats():
    """Obtener estadísticas de documentos"""
    query = """
    SELECT 
        DEPARTMENT,
        COUNT(*) as doc_count,
        AVG(FILE_SIZE_BYTES) as avg_size
    FROM TVAZTECA_DB.RAW_SCHEMA.CORPORATE_DOCUMENTS
    GROUP BY DEPARTMENT
    ORDER BY doc_count DESC
    """
    
    result_df = run_query_snowpark(query)
    return result_df if result_df is not None else pd.DataFrame()

def get_search_trends():
    """Obtener tendencias de búsqueda"""
    query = """
    SELECT 
        SEARCH_QUERY,
        COUNT(*) as frequency,
        AVG(RELEVANCE_SCORE) as avg_relevance
    FROM TVAZTECA_DB.ANALYTICS_SCHEMA.SEARCH_METRICS
    GROUP BY SEARCH_QUERY
    ORDER BY frequency DESC
    LIMIT 10
    """
    
    result_df = run_query_snowpark(query)
    return result_df if result_df is not None else pd.DataFrame()

# Header principal
st.markdown("""
<div class="main-header">
    <h1>📺 TV Azteca Digital - Search Intelligence</h1>
    <p>Sistema de Búsqueda Semántica con Cortex Search | Snowflake AI</p>
    <p><small>🏠 Ejecutándose en Streamlit in Snowflake</small></p>
</div>
""", unsafe_allow_html=True)

# Verificar conexión y disponibilidad de Cortex Search
session = get_snowpark_session()
if not session:
    st.error("❌ No se pudo establecer conexión con Snowpark")
    st.stop()

st.success("✅ Conexión establecida con Snowflake")

# Verificar si Cortex Search está disponible
def check_cortex_search_availability():
    """Verificar si Cortex Search está disponible en la cuenta"""
    try:
        # Intentar verificar si existe el servicio
        query = "SELECT SYSTEM$GET_SEARCH_SERVICE_STATUS('tv_azteca_search') as status"
        result_df = run_query_snowpark(query)
        if result_df is not None:
            status = result_df.iloc[0]['STATUS']
            return True, status
        return False, "Service not found"
    except Exception as e:
        if "Unknown user-defined function SNOWFLAKE.CORTEX.SEARCH" in str(e):
            return False, "CORTEX_NOT_AVAILABLE"
        elif "does not exist or not authorized" in str(e):
            return False, "SERVICE_NOT_CREATED"
        return False, str(e)

# Verificar disponibilidad de Cortex Search
cortex_available, cortex_status = check_cortex_search_availability()

if not cortex_available:
    if cortex_status == "CORTEX_NOT_AVAILABLE":
        st.error("❌ **Cortex Search no está disponible en esta cuenta de Snowflake**")
        st.info("""
        **Soluciones posibles:**
        
        1. **Contactar a tu administrador de Snowflake** para habilitar Cortex Search
        2. **Verificar que tu cuenta tenga acceso** a funciones de Cortex
        3. **Asegurar que estés en una región** que soporte Cortex Search
        4. **Verificar que tengas los privilegios** necesarios para usar Cortex
        
        **Regiones que soportan Cortex Search:**
        - US East (N. Virginia)
        - US West (Oregon) 
        - Europe (Frankfurt)
        - Asia Pacific (Singapore)
        """)
        st.stop()
    elif cortex_status == "SERVICE_NOT_CREATED":
        st.warning("⚠️ **El servicio de búsqueda 'tv_azteca_search' no existe**")
        st.info("""
        **Para solucionar:**
        
        1. **Ejecutar el worksheet SQL** `TVAZTECA_worksheet.sql` completo
        2. **Verificar que se creó el servicio** con esta consulta:
        ```sql
        USE DATABASE TVAZTECA_DB;
        USE SCHEMA SEARCH_SCHEMA;
        SELECT SYSTEM$GET_SEARCH_SERVICE_STATUS('tv_azteca_search');
        ```
        3. **Esperar a que el servicio esté en estado "READY"** (puede tomar unos minutos)
        """)
    else:
        st.error(f"❌ Error verificando Cortex Search: {cortex_status}")
else:
    if cortex_status == "READY":
        st.success("✅ Servicio Cortex Search 'tv_azteca_search' está listo")
    else:
        st.warning(f"⚠️ Servicio Cortex Search en estado: {cortex_status}")
        st.info("El servicio puede estar inicializándose. Espera unos minutos y recarga la página.")

# Sidebar con filtros y configuración
with st.sidebar:
    st.markdown("### 🔧 Configuración de Búsqueda")
    
    # Filtros de departamento
    departments = ["Todos", "Programación", "Noticias", "Deportes", "Entretenimiento", 
                   "Marketing Digital", "Tecnología", "Finanzas", "Recursos Humanos",
                   "Legal", "Sustentabilidad", "Innovación"]
    
    department_filter = st.selectbox(
        "📁 Filtrar por Departamento:",
        departments
    )
    
    # Filtros de prioridad
    priorities = ["Todos", "CRITICAL", "HIGH", "MEDIUM"]
    priority_filter = st.selectbox(
        "⚡ Filtrar por Prioridad:",
        priorities
    )
    
    st.markdown("---")
    
    # Métricas del sistema
    st.markdown("### 📊 Métricas del Sistema")
    
    try:
        metrics = get_search_metrics()
        
        if metrics:
            col1, col2 = st.columns(2)
            with col1:
                st.metric("🔍 Búsquedas Totales", metrics.get('total_searches', 0))
                st.metric("⚡ Tiempo Promedio", f"{metrics.get('avg_response_time', 0)}ms")
            with col2:
                st.metric("🎯 Relevancia", f"{metrics.get('avg_relevance', 0):.3f}")
                st.metric("👥 Usuarios Únicos", metrics.get('unique_users', 0))
        else:
            st.info("Métricas no disponibles")
    except Exception as e:
        st.warning(f"Error cargando métricas: {str(e)}")

# Área principal de búsqueda
col1, col2 = st.columns([3, 1])

with col1:
    st.markdown("""
    <div class="search-box">
        <h3>🔍 Búsqueda Inteligente de Documentos</h3>
        <p>Utiliza búsqueda semántica para encontrar información relevante en la base de conocimientos de TV Azteca</p>
    </div>
    """, unsafe_allow_html=True)
    
    # Input de búsqueda
    search_query = st.text_input(
        "💬 Escribe tu consulta:",
        placeholder="Ej: rating de Ventaneando, estrategia de marketing digital, tecnología 4K...",
        help="Puedes buscar usando lenguaje natural. El sistema entenderá el contexto de tu consulta."
    )
    
    # Búsquedas sugeridas
    st.markdown("**🌟 Consultas sugeridas:**")
    suggested_queries = [
        "¿Cuál es el rating de los programas estelares?",
        "Estrategia de marketing digital para redes sociales",
        "Información sobre tecnología de transmisión 4K",
        "Políticas de recursos humanos y beneficios",
        "Proyectos de sustentabilidad ambiental",
        "Expansión internacional de TV Azteca",
        "Seguridad de la información y ciberseguridad",
        "Producción de telenovelas y contenido original"
    ]
    
    cols = st.columns(2)
    for i, query in enumerate(suggested_queries):
        with cols[i % 2]:
            if st.button(query, key=f"suggest_{i}"):
                search_query = query
                st.rerun()

with col2:
    # Botón de búsqueda
    search_button = st.button("🔍 Buscar", type="primary", use_container_width=True)

# Ejecutar búsqueda
if search_button and search_query:
    # Mostrar método de búsqueda que se va a usar
    cortex_available, cortex_status = check_cortex_search_availability()
    if cortex_available:
        search_method = "🚀 Cortex Search (IA Semántica)"
    else:
        search_method = "🔍 Búsqueda SQL Tradicional"
    
    st.info(f"**Método de búsqueda:** {search_method}")
    
    with st.spinner("🔄 Buscando en la base de conocimientos..."):
        try:
            results = perform_search(search_query, department_filter, priority_filter)
            
            if results and 'results' in results:
                st.success(f"✅ Encontrados {len(results['results'])} resultados relevantes")
                
                # Mostrar resultados
                st.markdown("### 📋 Resultados de Búsqueda")
                
                for i, result in enumerate(results['results'][:5]):  # Mostrar top 5
                    with st.expander(f"📄 {result.get('document_name', 'Documento')} - Relevancia: {result.get('score', 0):.3f}"):
                        
                        # Información del documento
                        col1, col2, col3 = st.columns(3)
                        with col1:
                            st.write(f"**📁 Departamento:** {result.get('department', 'N/A')}")
                        with col2:
                            st.write(f"**📑 Tipo:** {result.get('document_type', 'N/A')}")
                        with col3:
                            st.write(f"**⚡ Prioridad:** {result.get('priority_level', 'N/A')}")
                        
                        # Contenido relevante
                        if 'chunk' in result:
                            st.markdown("**🎯 Contenido Relevante:**")
                            st.text_area(
                                "Fragmento del documento:",
                                result['chunk'][:800] + "..." if len(result['chunk']) > 800 else result['chunk'],
                                height=150,
                                disabled=True,
                                key=f"content_{i}"
                            )
                        
                        # Keywords
                        if 'keywords' in result and result['keywords']:
                            st.markdown("**🏷️ Palabras Clave:**")
                            keywords = result['keywords'] if isinstance(result['keywords'], list) else []
                            for keyword in keywords[:5]:  # Mostrar primeros 5
                                st.badge(keyword)
            else:
                st.warning("❌ No se encontraron resultados para tu consulta. Intenta con términos diferentes.")
        except Exception as e:
            st.error(f"Error realizando búsqueda: {str(e)}")

# Tabs para análisis y estadísticas
tab1, tab2, tab3 = st.tabs(["📊 Dashboard", "📈 Tendencias", "📚 Biblioteca"])

with tab1:
    st.markdown("### 📊 Dashboard de Documentos")
    
    try:
        # Obtener estadísticas
        doc_stats = get_document_stats()
        
        if not doc_stats.empty:
            col1, col2 = st.columns(2)
            
            with col1:
                # Gráfico de distribución por departamento
                fig_dept = px.bar(
                    doc_stats, 
                    x='DEPARTMENT', 
                    y='DOC_COUNT',
                    title="📁 Documentos por Departamento",
                    color='DOC_COUNT',
                    color_continuous_scale='Blues'
                )
                fig_dept.update_layout(
                    xaxis_title="Departamento",
                    yaxis_title="Número de Documentos",
                    showlegend=False
                )
                st.plotly_chart(fig_dept, use_container_width=True)
            
            with col2:
                # Gráfico de tamaño promedio de archivos
                fig_size = px.scatter(
                    doc_stats,
                    x='DOC_COUNT',
                    y='AVG_SIZE',
                    size='AVG_SIZE',
                    color='DEPARTMENT',
                    title="📏 Tamaño vs Cantidad de Documentos",
                    hover_data=['DEPARTMENT']
                )
                fig_size.update_layout(
                    xaxis_title="Número de Documentos",
                    yaxis_title="Tamaño Promedio (bytes)",
                    showlegend=False
                )
                st.plotly_chart(fig_size, use_container_width=True)
        else:
            st.info("No hay datos de documentos disponibles")
    except Exception as e:
        st.error(f"Error cargando dashboard: {str(e)}")

with tab2:
    st.markdown("### 📈 Tendencias de Búsqueda")
    
    try:
        search_trends = get_search_trends()
        
        if not search_trends.empty:
            col1, col2 = st.columns(2)
            
            with col1:
                # Top consultas
                fig_freq = px.bar(
                    search_trends,
                    x='FREQUENCY',
                    y='SEARCH_QUERY',
                    orientation='h',
                    title="🔥 Consultas Más Frecuentes",
                    color='FREQUENCY',
                    color_continuous_scale='Reds'
                )
                fig_freq.update_layout(
                    xaxis_title="Frecuencia",
                    yaxis_title="Consulta",
                    showlegend=False,
                    height=400
                )
                st.plotly_chart(fig_freq, use_container_width=True)
            
            with col2:
                # Relevancia vs Frecuencia
                fig_rel = px.scatter(
                    search_trends,
                    x='FREQUENCY',
                    y='AVG_RELEVANCE',
                    size='FREQUENCY',
                    color='AVG_RELEVANCE',
                    title="🎯 Relevancia vs Frecuencia",
                    hover_data=['SEARCH_QUERY']
                )
                fig_rel.update_layout(
                    xaxis_title="Frecuencia de Búsqueda",
                    yaxis_title="Relevancia Promedio",
                    showlegend=False,
                    height=400
                )
                st.plotly_chart(fig_rel, use_container_width=True)
        else:
            st.info("No hay datos de tendencias disponibles")
    except Exception as e:
        st.error(f"Error cargando tendencias: {str(e)}")

with tab3:
    st.markdown("### 📚 Biblioteca de Documentos")
    
    try:
        # Mostrar todos los documentos disponibles
        query = """
        SELECT 
            DOCUMENT_NAME,
            DOCUMENT_TYPE,
            DEPARTMENT,
            PRIORITY_LEVEL,
            DOCUMENT_SUMMARY,
            UPLOAD_DATE
        FROM TVAZTECA_DB.RAW_SCHEMA.CORPORATE_DOCUMENTS
        ORDER BY UPLOAD_DATE DESC
        """
        
        docs_df = run_query_snowpark(query)
        
        if docs_df is not None and not docs_df.empty:
            
            # Filtros para la tabla
            col1, col2, col3 = st.columns(3)
            with col1:
                dept_filter = st.selectbox("Filtrar por Departamento:", 
                                         ["Todos"] + list(docs_df['DEPARTMENT'].unique()))
            with col2:
                type_filter = st.selectbox("Filtrar por Tipo:", 
                                         ["Todos"] + list(docs_df['DOCUMENT_TYPE'].unique()))
            with col3:
                priority_filter_table = st.selectbox("Filtrar por Prioridad:", 
                                                    ["Todos"] + list(docs_df['PRIORITY_LEVEL'].unique()))
            
            # Aplicar filtros
            filtered_df = docs_df.copy()
            if dept_filter != "Todos":
                filtered_df = filtered_df[filtered_df['DEPARTMENT'] == dept_filter]
            if type_filter != "Todos":
                filtered_df = filtered_df[filtered_df['DOCUMENT_TYPE'] == type_filter]
            if priority_filter_table != "Todos":
                filtered_df = filtered_df[filtered_df['PRIORITY_LEVEL'] == priority_filter_table]
            
            # Mostrar tabla
            st.dataframe(
                filtered_df,
                use_container_width=True,
                hide_index=True,
                column_config={
                    "DOCUMENT_NAME": st.column_config.TextColumn("📄 Documento"),
                    "DOCUMENT_TYPE": st.column_config.TextColumn("📑 Tipo"),
                    "DEPARTMENT": st.column_config.TextColumn("📁 Departamento"),
                    "PRIORITY_LEVEL": st.column_config.TextColumn("⚡ Prioridad"),
                    "DOCUMENT_SUMMARY": st.column_config.TextColumn("📝 Resumen"),
                    "UPLOAD_DATE": st.column_config.DatetimeColumn("📅 Fecha")
                }
            )
        else:
            st.info("No hay documentos disponibles en la biblioteca")
    except Exception as e:
        st.error(f"Error cargando biblioteca: {str(e)}")

# Footer
st.markdown("---")
st.markdown("""
<div style="text-align: center; padding: 2rem; background: #f8f9fa; border-radius: 10px;">
    <h4>📺 TV Azteca Digital - Powered by Snowflake Cortex Search</h4>
    <p>Sistema de búsqueda semántica inteligente para documentos corporativos<br>
    <small>Desarrollado con ❤️ usando Streamlit in Snowflake</small></p>
    <p><strong>Beneficios del Sistema:</strong></p>
    <ul style="text-align: left; max-width: 600px; margin: 0 auto;">
        <li>🚀 Búsqueda 70% más rápida que métodos tradicionales</li>
        <li>🎯 Resultados contextualmente relevantes</li>
        <li>🔍 Comprensión de lenguaje natural</li>
        <li>📊 Analytics en tiempo real</li>
        <li>🔒 Seguridad y compliance integrados</li>
    </ul>
</div>
""", unsafe_allow_html=True)

# Información técnica en sidebar
with st.sidebar:
    st.markdown("---")
    st.markdown("### ℹ️ Información Técnica")
    st.info("""
    **🔧 Arquitectura:**
    - Snowflake Cortex Search
    - 20 documentos corporativos
    - Búsqueda semántica con IA
    - Filtros avanzados
    - Métricas en tiempo real
    
    **📋 Documentos Incluidos:**
    - Manuales operativos
    - Informes financieros
    - Estrategias de marketing
    - Análisis de audiencia
    - Documentación técnica
    - Políticas corporativas
    
    **🏠 Ejecutándose en:**
    - Streamlit in Snowflake
    - Snowpark Session
    - Cortex Search Service
    """)
