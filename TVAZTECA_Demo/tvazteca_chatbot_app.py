"""
TV AZTECA DIGITAL - CHATBOT CON RAG
===================================
Chatbot inteligente con Retrieval-Augmented Generation (RAG)
Cliente: TV Azteca Digital
Optimizado para Streamlit in Snowflake
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd
import json

# Configuración de la página
st.set_page_config(
    page_title="TV Azteca Digital - Chatbot RAG",
    page_icon="🤖",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Modelos disponibles
MODELS = [
    "mistral-large2",
    "llama3.1-70b", 
    "llama3.1-8b",
    "mixtral-8x7b",
    "llama3-70b",
    "llama3-8b"
]

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
    
    .chat-message {
        padding: 1rem;
        border-radius: 10px;
        margin: 0.5rem 0;
    }
    
    .user-message {
        background: #e3f2fd;
        border-left: 4px solid #1e3c72;
    }
    
    .assistant-message {
        background: #f8f9fa;
        border-left: 4px solid #2a5298;
    }
    
    .context-box {
        background: #fff3e0;
        padding: 1rem;
        border-radius: 8px;
        border-left: 4px solid #ff9800;
        margin: 1rem 0;
    }
</style>
""", unsafe_allow_html=True)

def init_session():
    """Inicializar sesión de Snowpark"""
    try:
        session = get_active_session()
        return session
    except Exception as e:
        st.error(f"Error inicializando sesión: {str(e)}")
        return None

def init_messages():
    """Inicializar mensajes del chat"""
    if st.session_state.get('clear_conversation', False) or "messages" not in st.session_state:
        st.session_state.messages = []
        st.session_state.clear_conversation = False

def check_cortex_search_service():
    """Verificar si el servicio de Cortex Search existe"""
    try:
        # Verificar si existe el servicio específico de TV Azteca
        query = "SELECT SYSTEM$GET_SEARCH_SERVICE_STATUS('tv_azteca_search') as status"
        result = session.sql(query).collect()
        if result:
            status = result[0]['STATUS']
            return True, status
        return False, "Service not found"
    except Exception as e:
        if "Unknown user-defined function" in str(e):
            return False, "CORTEX_NOT_AVAILABLE"
        elif "does not exist" in str(e):
            return False, "SERVICE_NOT_FOUND"
        return False, str(e)

def init_config_options():
    """Configurar opciones en la sidebar"""
    st.sidebar.markdown("### 🤖 Configuración del Chatbot")
    
    # Verificar estado del servicio
    cortex_available, cortex_status = check_cortex_search_service()
    
    if cortex_available and cortex_status == "READY":
        st.sidebar.success("✅ Servicio tv_azteca_search: LISTO")
        search_available = True
    else:
        st.sidebar.error(f"❌ Servicio tv_azteca_search: {cortex_status}")
        search_available = False
        if cortex_status == "CORTEX_NOT_AVAILABLE":
            st.sidebar.info("Cortex Search no está disponible en esta cuenta")
        elif cortex_status == "SERVICE_NOT_FOUND":
            st.sidebar.info("Ejecuta el worksheet SQL para crear el servicio")
    
    # Configuraciones del chat
    st.sidebar.button("🗑️ Limpiar conversación", key="clear_conversation")
    st.sidebar.toggle("🐛 Modo debug", key="debug", value=False)
    st.sidebar.toggle("💭 Usar historial", key="use_chat_history", value=True)
    
    with st.sidebar.expander("⚙️ Opciones avanzadas"):
        st.selectbox("🧠 Modelo:", MODELS, key="model_name", index=0)
        st.number_input(
            "📄 Contexto (chunks):",
            value=5,
            key="num_retrieved_chunks", 
            min_value=1,
            max_value=10,
        )
        st.number_input(
            "💬 Mensajes en historial:",
            value=5,
            key="num_chat_messages",
            min_value=1,
            max_value=10,
        )
    
    # Métricas del servicio
    if search_available:
        st.sidebar.markdown("### 📊 Estadísticas")
        try:
            # Contar documentos disponibles
            doc_count = session.sql("SELECT COUNT(*) as count FROM TVAZTECA_DB.RAW_SCHEMA.CORPORATE_DOCUMENTS").collect()[0]['COUNT']
            st.sidebar.metric("📚 Documentos", doc_count)
            
            # Mostrar departamentos
            departments = session.sql("SELECT DISTINCT DEPARTMENT FROM TVAZTECA_DB.RAW_SCHEMA.CORPORATE_DOCUMENTS").collect()
            st.sidebar.metric("🏢 Departamentos", len(departments))
        except:
            pass
    
    # Debug info
    if st.session_state.get('debug', False):
        with st.sidebar.expander("🔍 Debug - Session State"):
            st.write(st.session_state)
    
    return search_available

def query_cortex_search_service(query, department_filter=None):
    """Consultar el servicio de Cortex Search de TV Azteca"""
    try:
        # Construir filtros si se especifica departamento
        filter_clause = ""
        if department_filter and department_filter != "Todos":
            filter_clause = f", OPTIONS => {{'filter': {{'@eq': {{'department': '{department_filter}'}}}}}}"
        
        search_query = f"""
        SELECT 
            SNOWFLAKE.CORTEX.SEARCH(
                'tv_azteca_search',
                '{query}'{filter_clause}
            ) AS search_results
        """
        
        result = session.sql(search_query).collect()
        if result:
            import json
            search_results = json.loads(result[0]['SEARCH_RESULTS'])
            return search_results.get('results', [])
        return []
        
    except Exception as e:
        st.error(f"Error en búsqueda: {str(e)}")
        return []

def query_fallback_search(query, department_filter=None):
    """Búsqueda fallback usando SQL tradicional"""
    try:
        # Construir condiciones WHERE
        where_conditions = []
        
        # Búsqueda en texto
        search_terms = query.lower().split()
        text_conditions = []
        for term in search_terms:
            text_conditions.append(f"LOWER(CONTENT_TEXT) LIKE '%{term}%'")
        if text_conditions:
            where_conditions.append(f"({' OR '.join(text_conditions)})")
        
        # Filtro de departamento
        if department_filter and department_filter != "Todos":
            where_conditions.append(f"DEPARTMENT = '{department_filter}'")
        
        where_clause = " AND ".join(where_conditions) if where_conditions else "1=1"
        
        fallback_query = f"""
        SELECT 
            DOCUMENT_NAME,
            DOCUMENT_TYPE,
            DEPARTMENT,
            DOCUMENT_SUMMARY,
            SUBSTR(CONTENT_TEXT, 1, 1000) as chunk
        FROM TVAZTECA_DB.RAW_SCHEMA.CORPORATE_DOCUMENTS
        WHERE {where_clause}
        ORDER BY 
            CASE 
                WHEN LOWER(DOCUMENT_NAME) LIKE '%{query.lower()}%' THEN 1
                WHEN LOWER(DOCUMENT_SUMMARY) LIKE '%{query.lower()}%' THEN 2
                ELSE 3
            END
        LIMIT {st.session_state.num_retrieved_chunks}
        """
        
        result_df = session.sql(fallback_query).to_pandas()
        
        # Convertir a formato compatible
        results = []
        for _, row in result_df.iterrows():
            results.append({
                'document_name': row['DOCUMENT_NAME'],
                'document_type': row['DOCUMENT_TYPE'],
                'department': row['DEPARTMENT'],
                'chunk': row['CHUNK']
            })
        
        return results
        
    except Exception as e:
        st.error(f"Error en búsqueda fallback: {str(e)}")
        return []

def get_context_documents(query, department_filter=None):
    """Obtener documentos de contexto usando Cortex Search o fallback"""
    # Verificar si Cortex Search está disponible
    cortex_available, cortex_status = check_cortex_search_service()
    
    if cortex_available and cortex_status == "READY":
        # Usar Cortex Search
        results = query_cortex_search_service(query, department_filter)
        search_method = "🚀 Cortex Search"
    else:
        # Usar búsqueda fallback
        results = query_fallback_search(query, department_filter)
        search_method = "🔍 SQL Search"
    
    # Construir contexto para el prompt
    context_str = ""
    references = []
    
    for i, result in enumerate(results):
        chunk = result.get('chunk', '')
        doc_name = result.get('document_name', 'Documento desconocido')
        department = result.get('department', 'N/A')
        doc_type = result.get('document_type', 'N/A')
        
        context_str += f"Documento {i+1} ({department} - {doc_type}):\n{chunk}\n\n"
        references.append({
            'name': doc_name,
            'department': department,
            'type': doc_type
        })
    
    # Mostrar en debug si está habilitado
    if st.session_state.get('debug', False):
        with st.sidebar.expander(f"📄 Contexto ({search_method})"):
            st.text_area("Documentos de contexto:", context_str, height=300)
            st.json(references)
    
    return context_str, references, search_method

def get_chat_history():
    """Obtener historial de chat limitado"""
    if not st.session_state.get('use_chat_history', True):
        return []
    
    start_index = max(
        0, len(st.session_state.messages) - st.session_state.num_chat_messages
    )
    return st.session_state.messages[start_index:len(st.session_state.messages) - 1]

def complete_with_cortex(model, prompt):
    """Generar respuesta usando Cortex Complete con SQL"""
    try:
        # Limpiar el prompt para SQL
        clean_prompt = prompt.replace("'", "''").replace("\\", "\\\\")
        
        # Usar SQL para llamar Cortex Complete
        sql_query = f"""
        SELECT SNOWFLAKE.CORTEX.COMPLETE('{model}', '{clean_prompt}') as response
        """
        
        result = session.sql(sql_query).collect()
        if result:
            response = result[0]['RESPONSE']
            return response.replace("$", "\\$")
        else:
            return "Lo siento, no pude generar una respuesta."
            
    except Exception as e:
        st.error(f"Error generando respuesta: {str(e)}")
        return "Lo siento, no pude generar una respuesta en este momento."

def make_chat_history_summary(chat_history, question):
    """Crear resumen del historial de chat para contexto extendido"""
    if not chat_history:
        return question
    
    # Convertir historial a texto
    history_text = ""
    for msg in chat_history:
        role = "Usuario" if msg["role"] == "user" else "Asistente"
        history_text += f"{role}: {msg['content']}\n"
    
    prompt = f"""
    [INST]
    Basándote en el historial de chat y la pregunta actual, genera una consulta que extienda 
    la pregunta con el contexto del historial. La consulta debe ser en lenguaje natural y 
    enfocada en información de TV Azteca.
    
    Responde solo con la consulta mejorada, sin explicaciones.

    <historial_chat>
    {history_text}
    </historial_chat>
    
    <pregunta_actual>
    {question}
    </pregunta_actual>
    [/INST]
    """

    summary = complete_with_cortex(st.session_state.model_name, prompt)
    
    if st.session_state.get('debug', False):
        st.sidebar.text_area("🔄 Consulta extendida:", summary, height=100)
    
    return summary

def create_prompt(user_question, department_filter=None):
    """Crear prompt para el modelo incluyendo contexto y historial"""
    
    # Procesar historial si está habilitado
    if st.session_state.get('use_chat_history', True):
        chat_history = get_chat_history()
        if chat_history:
            enhanced_question = make_chat_history_summary(chat_history, user_question)
        else:
            enhanced_question = user_question
    else:
        enhanced_question = user_question
        chat_history = []
    
    # Obtener contexto de documentos
    context_str, references, search_method = get_context_documents(enhanced_question, department_filter)
    
    # Convertir historial a texto para el prompt
    history_text = ""
    if chat_history:
        for msg in chat_history:
            role = "Usuario" if msg["role"] == "user" else "Asistente"
            history_text += f"{role}: {msg['content']}\n"
    
    # Crear prompt específico para TV Azteca
    prompt = f"""
    [INST]
    Eres un asistente especializado en TV Azteca, la segunda televisora más importante de México. 
    Tienes acceso a información corporativa interna de TV Azteca incluyendo programación, 
    audiencias, estrategias, finanzas, tecnología y operaciones.

    Cuando un usuario te haga una pregunta, utiliza el contexto proporcionado entre las etiquetas 
    <contexto> y </contexto>, junto con el historial de chat entre <historial> y </historial> 
    para proporcionar una respuesta precisa y relevante.

    INSTRUCCIONES:
    - Responde en español mexicano profesional
    - Sé específico sobre TV Azteca (canales, programas, métricas, etc.)
    - Si la pregunta no puede responderse con el contexto, di "No tengo información suficiente"
    - Usa datos concretos cuando estén disponibles (ratings, ingresos, etc.)
    - Mantén un tono profesional pero accesible

    <historial>
    {history_text}
    </historial>

    <contexto>
    {context_str}
    </contexto>

    <pregunta>
    {user_question}
    </pregunta>
    [/INST]

    Respuesta:
    """
    
    return prompt, references, search_method

def format_references(references):
    """Formatear referencias de documentos"""
    if not references:
        return ""
    
    markdown_table = "\n\n##### 📚 Referencias\n\n| Documento | Departamento | Tipo |\n|-----------|--------------|------|\n"
    for ref in references:
        markdown_table += f"| {ref['name']} | {ref['department']} | {ref['type']} |\n"
    
    return markdown_table

def main():
    """Función principal del chatbot"""
    
    # Header
    st.markdown("""
    <div class="main-header">
        <h1>🤖 TV Azteca Digital - Chatbot Inteligente</h1>
        <p>Asistente con RAG especializado en información corporativa de TV Azteca</p>
    </div>
    """, unsafe_allow_html=True)
    
    # Inicializar sesión globalmente
    global session
    session = init_session()
    if not session:
        st.error("❌ No se pudo inicializar la sesión de Snowflake")
        st.stop()
    
    # Inicializar configuraciones
    search_available = init_config_options()
    init_messages()
    
    # Filtro de departamento
    departments = ["Todos", "Programación", "Noticias", "Deportes", "Entretenimiento", 
                   "Marketing Digital", "Tecnología", "Finanzas", "Recursos Humanos",
                   "Legal", "Sustentabilidad", "Innovación"]
    
    department_filter = st.selectbox(
        "🏢 Filtrar por departamento:",
        departments,
        help="Limitar búsqueda a documentos de un departamento específico"
    )
    
    # Configurar iconos
    icons = {"assistant": "🤖", "user": "👤"}
    
    # Mostrar historial de mensajes
    for message in st.session_state.messages:
        with st.chat_message(message["role"], avatar=icons[message["role"]]):
            st.markdown(message["content"])
    
    # Input del chat
    disable_chat = not search_available
    
    if disable_chat:
        st.warning("⚠️ El servicio de búsqueda no está disponible. Ejecuta el worksheet SQL para configurar el demo.")
    
    if question := st.chat_input("Pregúntame sobre TV Azteca...", disabled=disable_chat):
        # Agregar mensaje del usuario
        st.session_state.messages.append({"role": "user", "content": question})
        
        # Mostrar mensaje del usuario
        with st.chat_message("user", avatar=icons["user"]):
            st.markdown(question.replace("$", "\\$"))
        
        # Generar respuesta del asistente
        with st.chat_message("assistant", avatar=icons["assistant"]):
            message_placeholder = st.empty()
            
            with st.spinner("🧠 Analizando información de TV Azteca..."):
                # Limpiar comillas para evitar errores SQL
                clean_question = question.replace("'", "").replace('"', '')
                
                # Crear prompt con contexto
                prompt, references, search_method = create_prompt(clean_question, department_filter)
                
                # Generar respuesta
                generated_response = complete_with_cortex(
                    st.session_state.model_name, prompt
                )
                
                # Formatear referencias
                references_table = format_references(references)
                
                # Mostrar método de búsqueda usado
                method_info = f"\n\n*Búsqueda realizada con: {search_method}*"
                
                # Mostrar respuesta completa
                full_response = generated_response + references_table + method_info
                message_placeholder.markdown(full_response)
        
        # Guardar respuesta en historial
        st.session_state.messages.append(
            {"role": "assistant", "content": full_response}
        )

    # Sugerencias de preguntas
    if not st.session_state.messages:
        st.markdown("### 💡 Preguntas sugeridas:")
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("""
            **📺 Programación:**
            - ¿Cuál es el rating de Ventaneando?
            - ¿Qué programas transmite Azteca UNO?
            - ¿Cuáles son los horarios estelares?
            
            **💰 Finanzas:**
            - ¿Cuáles son los ingresos de TV Azteca?
            - ¿Cómo ha crecido el negocio digital?
            - ¿Cuál es el EBITDA de la empresa?
            """)
        
        with col2:
            st.markdown("""
            **🎯 Marketing:**
            - ¿Cuál es la estrategia de redes sociales?
            - ¿Cuántos seguidores tiene TV Azteca?
            - ¿Qué campañas digitales están activas?
            
            **🔧 Tecnología:**
            - ¿Qué tecnología usa TV Azteca para transmitir?
            - ¿Cómo funciona la infraestructura 4K?
            - ¿Qué proyectos de innovación hay?
            """)

if __name__ == "__main__":
    main()
