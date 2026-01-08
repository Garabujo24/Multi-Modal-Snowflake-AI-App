import streamlit as st
from snowflake.snowpark.context import get_active_session

# --- Configuración de la Página ---
st.set_page_config(
    page_title="Asistente de Farmapronto",
    page_icon="💊",
    layout="centered"
)

# --- Título y Descripción ---
st.title("💊 Asistente Inteligente de Farmapronto")
st.caption("Utiliza Cortex AI para chatear con tus datos estructurados (Analyst) o buscar en tus documentos (Search).")

# --- Barra Lateral: Selección de Servicio y Modelo ---
st.sidebar.header("⚙️ Configuración")

# 1. Selector de Servicio
service_option = st.sidebar.radio(
    "Elige el servicio a utilizar:",
    ["Analyst (Chat con Datos)", "Search (Chat con Documentos)"],
    captions=[
        "Preguntas sobre ventas, inventario, etc.",
        "Busca información en tus reportes en PDF/TXT."
    ]
)

# 2. Selector de Modelo (solo para Analyst)
AVAILABLE_MODELS = {
    "Llama 3 (8B)": "llama3-8b",
    "Mixtral (8x7B)": "mixtral-8x7b",
    "Snowflake Arctic": "snowflake-arctic",
    "Gemma (7B)": "gemma-7b",
    "Mistral Large": "mistral-large",
}
selected_model_name = st.sidebar.selectbox(
    "Elige un modelo LLM (solo para Analyst):",
    options=list(AVAILABLE_MODELS.keys()),
    disabled=(service_option != "Analyst (Chat con Datos)")
)
selected_model_id = AVAILABLE_MODELS[selected_model_name]


# --- Lógica Principal ---
try:
    session = get_active_session()
except Exception:
    st.error("No se pudo obtener una sesión de Snowflake. Asegúrate de que estás ejecutando esta app dentro de Snowflake.")
    st.stop()

# --- Configuración y Lógica para CORTEX ANALYST ---
if service_option == "Analyst (Chat con Datos)":
    agent_suffix = selected_model_id.upper().replace('-', '_')
    CORTEX_AGENT_NAME = f"FARMAPRONTO_AGENT_{agent_suffix}"
    st.sidebar.info(f"**Agente activo:** `{CORTEX_AGENT_NAME}`")
    with st.sidebar.expander("Instrucciones para Cortex Analyst"):
        st.markdown(f"""
        Crea un Agente de Cortex para cada modelo que quieras usar.
        **Ejemplo para {selected_model_name}:**
        ```sql
        CREATE OR REPLACE CORTEX AGENT {CORTEX_AGENT_NAME}
          MODEL='{selected_model_id}'
          PROMPT='Responde preguntas sobre los datos de Farmapronto usando el modelo semántico @FARMAPRONTO_DB.NEGOCIO.farmapronto_semantic_model'
          COMMENT='Agente para chatear con datos de Farmapronto.';
        ```
        """)

# --- Configuración y Lógica para CORTEX SEARCH ---
else: # service_option == "Search (Chat con Documentos)"
    CORTEX_SEARCH_SERVICE_NAME = "FARMAPRONTO_DOC_SEARCH"
    st.sidebar.info(f"**Servicio de Búsqueda:** `{CORTEX_SEARCH_SERVICE_NAME}`")
    with st.sidebar.expander("Instrucciones para Cortex Search"):
        st.markdown(f"""
        Primero, sube tus archivos (TXT, PDF) a un stage. Ejemplo: `PUT file://*.txt @doc_stage;`

        Luego, crea un servicio de Cortex Search sobre ese stage:
        ```sql
        CREATE OR REPLACE CORTEX SEARCH SERVICE {CORTEX_SEARCH_SERVICE_NAME}
          ON ('@doc_stage')
          MODEL='snowflake-arctic'
          COMMENT='Servicio para buscar en documentos de Farmapronto';
        ```
        """)

# --- Lógica del Chat ---

# Inicializar/reiniciar historial de chat si cambia el servicio
if "service" not in st.session_state or st.session_state.service != service_option:
    st.session_state.service = service_option
    st.session_state.messages = [{"role": "assistant", "content": f"Servicio **{service_option}** activado. ¿En qué puedo ayudarte?"}]
    st.rerun()

# Mostrar mensajes
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Capturar prompt del usuario
if prompt := st.chat_input("Escribe tu pregunta aquí..."):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        message_placeholder = st.empty()
        message_placeholder.markdown("Procesando...")
        
        try:
            safe_prompt = prompt.replace("'", "''")
            
            # --- Enrutamiento de la Petición ---
            if service_option == "Analyst (Chat con Datos)":
                # Llama al Agente de Cortex
                sql_query = f"CALL {CORTEX_AGENT_NAME}('{safe_prompt}')"
                response_df = session.sql(sql_query).collect()
                response = response_df[0][0]
            
            else: # service_option == "Search (Chat con Documentos)"
                # Llama al Servicio de Cortex Search
                sql_query = f"""
                SELECT SNOWFLAKE.CORTEX.COMPLETE(
                    'snowflake-arctic',
                    CONCAT(
                        'Responde a la pregunta basándote en el siguiente contexto:\\n',
                        (SELECT TO_JSON(VECTOR_SEARCH(*, 5)) 
                         FROM TABLE({CORTEX_SEARCH_SERVICE_NAME}('{safe_prompt}'))),
                        '\\nPregunta: ',
                        '{safe_prompt}'
                    )
                )
                """
                response_df = session.sql(sql_query).collect()
                response = response_df[0][0]

            message_placeholder.markdown(response)
            st.session_state.messages.append({"role": "assistant", "content": response})

        except Exception as e:
            error_message = f"Ocurrió un error. Revisa las instrucciones en la barra lateral y asegúrate de que el servicio/agente esté creado correctamente.\n\n**Error:** {e}"
            message_placeholder.error(error_message)
            st.session_state.messages.append({"role": "assistant", "content": error_message})
