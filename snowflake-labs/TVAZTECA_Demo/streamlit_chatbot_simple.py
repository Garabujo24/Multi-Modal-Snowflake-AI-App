"""
TV AZTECA DIGITAL - CHATBOT SIMPLE
==================================
Versión simplificada del chatbot que funciona solo con Snowpark
Sin dependencias de snowflake.core
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session
import json

# Configuración de la página
st.set_page_config(
    page_title="TV Azteca Digital - Chatbot",
    page_icon="🤖",
    layout="wide"
)

# CSS personalizado
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
</style>
""", unsafe_allow_html=True)

# Modelos disponibles (más conservador)
MODELS = [
    "llama3.1-8b",
    "llama3-8b",
    "mistral-7b"
]

def get_session():
    """Obtener sesión de Snowpark"""
    try:
        return get_active_session()
    except:
        return None

def init_messages():
    """Inicializar mensajes del chat"""
    if st.session_state.get('clear_conversation', False) or "messages" not in st.session_state:
        st.session_state.messages = []
        st.session_state.clear_conversation = False

def check_cortex_availability():
    """Verificar disponibilidad de Cortex"""
    session = get_session()
    if not session:
        return False, "No session"
    
    try:
        # Test simple de Cortex Complete
        test_query = """
        SELECT SNOWFLAKE.CORTEX.COMPLETE('llama3-8b', 'Hola') as test
        """
        result = session.sql(test_query).collect()
        return True, "Available"
    except Exception as e:
        return False, str(e)

def check_database_setup():
    """Verificar que la base de datos y tabla existan"""
    session = get_session()
    if not session:
        return False, "No session"
    
    try:
        # Verificar que existe la base de datos
        db_check = session.sql("SHOW DATABASES LIKE 'TVAZTECA_DB'").collect()
        if not db_check:
            return False, "Base de datos TVAZTECA_DB no existe"
        
        # Verificar que existe la tabla
        session.sql("USE DATABASE TVAZTECA_DB").collect()
        session.sql("USE SCHEMA RAW_SCHEMA").collect()
        
        table_check = session.sql("SHOW TABLES LIKE 'CORPORATE_DOCUMENTS'").collect()
        if not table_check:
            return False, "Tabla CORPORATE_DOCUMENTS no existe"
        
        # Verificar que tiene datos
        count_check = session.sql("SELECT COUNT(*) as count FROM CORPORATE_DOCUMENTS").collect()
        if count_check and count_check[0]['COUNT'] > 0:
            return True, f"Tabla con {count_check[0]['COUNT']} registros"
        else:
            return False, "Tabla existe pero está vacía"
            
    except Exception as e:
        return False, f"Error verificando DB: {str(e)}"

def search_documents(query, department_filter=None):
    """Búsqueda básica en documentos"""
    session = get_session()
    if not session:
        return []
    
    try:
        # Asegurar que estamos en el contexto correcto
        session.sql("USE DATABASE TVAZTECA_DB").collect()
        session.sql("USE SCHEMA RAW_SCHEMA").collect()
        
        # Construir WHERE clause
        where_conditions = ["CONTENT_TEXT IS NOT NULL"]
        
        # Agregar filtro de búsqueda
        if query:
            search_terms = query.lower().split()
            text_conditions = []
            for term in search_terms:
                term_clean = term.replace("'", "''")
                text_conditions.append(f"LOWER(CONTENT_TEXT) LIKE '%{term_clean}%'")
            if text_conditions:
                where_conditions.append(f"({' OR '.join(text_conditions)})")
        
        # Agregar filtro de departamento
        if department_filter and department_filter != "Todos":
            where_conditions.append(f"DEPARTMENT = '{department_filter}'")
        
        where_clause = " AND ".join(where_conditions)
        
        search_query = f"""
        SELECT 
            DOCUMENT_NAME,
            DOCUMENT_TYPE,
            DEPARTMENT,
            DOCUMENT_SUMMARY,
            SUBSTR(CONTENT_TEXT, 1, 800) as content_chunk
        FROM CORPORATE_DOCUMENTS
        WHERE {where_clause}
        ORDER BY 
            CASE 
                WHEN LOWER(DOCUMENT_NAME) LIKE '%{query.lower()}%' THEN 1
                WHEN LOWER(DOCUMENT_SUMMARY) LIKE '%{query.lower()}%' THEN 2
                ELSE 3
            END
        LIMIT 3
        """
        
        result_df = session.sql(search_query).to_pandas()
        
        results = []
        for _, row in result_df.iterrows():
            results.append({
                'name': row['DOCUMENT_NAME'],
                'type': row['DOCUMENT_TYPE'],
                'department': row['DEPARTMENT'],
                'summary': row['DOCUMENT_SUMMARY'],
                'content': row['CONTENT_CHUNK']
            })
        
        return results
        
    except Exception as e:
        st.error(f"Error en búsqueda: {str(e)}")
        return []

def generate_response(query, context_docs, model="llama3-8b"):
    """Generar respuesta usando Cortex Complete"""
    session = get_session()
    if not session:
        return "Error: No se pudo conectar con Snowflake"
    
    # Construir contexto
    context_text = ""
    for i, doc in enumerate(context_docs):
        context_text += f"Documento {i+1} ({doc['department']}):\n{doc['content']}\n\n"
    
    # Crear prompt
    prompt = f"""Eres un asistente especializado en TV Azteca, la segunda televisora más importante de México.

Responde la pregunta del usuario basándote en la información proporcionada. Mantén un tono profesional pero accesible, y responde en español mexicano.

Contexto:
{context_text}

Pregunta: {query}

Respuesta:"""
    
    try:
        # Limpiar prompt para SQL
        clean_prompt = prompt.replace("'", "''").replace('"', '""')
        
        complete_query = f"""
        SELECT SNOWFLAKE.CORTEX.COMPLETE('{model}', '{clean_prompt}') as response
        """
        
        result = session.sql(complete_query).collect()
        if result:
            response = result[0]['RESPONSE']
            return response
        else:
            return "Lo siento, no pude generar una respuesta."
            
    except Exception as e:
        return f"Error generando respuesta: {str(e)}"

def main():
    """Función principal"""
    
    # Header
    st.markdown("""
    <div class="main-header">
        <h1>🤖 TV Azteca Digital - Chatbot Simplificado</h1>
        <p>Asistente especializado en información corporativa</p>
    </div>
    """, unsafe_allow_html=True)
    
    # Verificar sesión
    session = get_session()
    if not session:
        st.error("❌ No se pudo conectar con Snowflake")
        st.stop()
    
    st.success("✅ Conectado con Snowflake")
    
    # Verificar Cortex
    cortex_available, cortex_status = check_cortex_availability()
    if cortex_available:
        st.success("✅ Cortex Complete disponible")
    else:
        st.warning(f"⚠️ Cortex Complete: {cortex_status}")
    
    # Verificar base de datos
    db_available, db_status = check_database_setup()
    if db_available:
        st.success(f"✅ Base de datos: {db_status}")
    else:
        st.error(f"❌ Base de datos: {db_status}")
        
        # Mostrar instrucciones si la DB no está configurada
        if "no existe" in db_status.lower():
            st.info("""
            **📋 Para configurar la base de datos:**
            
            1. Ejecuta el archivo `TVAZTECA_worksheet.sql` completo
            2. Asegúrate de ejecutar todas las secciones:
               - Sección 1: Resource Setup
               - Sección 2: Synthetic Data Generation
            3. Verifica que se crearon los datos correctamente
            """)
            st.stop()
    
    # Configuración en sidebar
    with st.sidebar:
        st.header("⚙️ Configuración")
        
        # Modelo
        model = st.selectbox("🧠 Modelo:", MODELS, index=0)
        
        # Departamento
        departments = ["Todos", "Programación", "Noticias", "Deportes", 
                      "Marketing Digital", "Finanzas", "Tecnología"]
        department = st.selectbox("🏢 Departamento:", departments)
        
        # Limpiar conversación
        if st.button("🗑️ Limpiar chat"):
            st.session_state.clear_conversation = True
            st.rerun()
        
        # Botón de diagnóstico
        st.header("🔧 Diagnóstico")
        if st.button("📊 Verificar datos"):
            with st.spinner("Verificando..."):
                session = get_session()
                if session:
                    try:
                        # Verificar tablas disponibles
                        session.sql("USE DATABASE TVAZTECA_DB").collect()
                        session.sql("USE SCHEMA RAW_SCHEMA").collect()
                        
                        tables = session.sql("SHOW TABLES").collect()
                        st.write("**Tablas disponibles:**")
                        for table in tables:
                            st.write(f"- {table['name']}")
                        
                        # Verificar estructura de la tabla
                        if tables:
                            st.write("**Estructura de CORPORATE_DOCUMENTS:**")
                            try:
                                desc = session.sql("DESC TABLE CORPORATE_DOCUMENTS").collect()
                                for col in desc:
                                    st.write(f"- {col['name']} ({col['type']})")
                            except Exception as e:
                                st.error(f"Error describiendo tabla: {e}")
                        
                        # Verificar muestra de datos
                        try:
                            sample = session.sql("SELECT * FROM CORPORATE_DOCUMENTS LIMIT 1").collect()
                            if sample:
                                st.write("**Muestra de datos encontrada ✅**")
                                st.json(dict(sample[0].asDict()))
                            else:
                                st.warning("**No hay datos en la tabla ⚠️**")
                        except Exception as e:
                            st.error(f"Error consultando datos: {e}")
                            
                    except Exception as e:
                        st.error(f"Error en diagnóstico: {e}")
                else:
                    st.error("No hay sesión activa")
    
    # Inicializar mensajes
    init_messages()
    
    # Mostrar historial
    for message in st.session_state.messages:
        with st.chat_message(message["role"]):
            st.markdown(message["content"])
    
    # Input de chat
    if prompt := st.chat_input("Pregúntame sobre TV Azteca..."):
        # Mostrar mensaje del usuario
        with st.chat_message("user"):
            st.markdown(prompt)
        st.session_state.messages.append({"role": "user", "content": prompt})
        
        # Generar respuesta
        with st.chat_message("assistant"):
            with st.spinner("🤔 Pensando..."):
                # Buscar documentos relevantes
                docs = search_documents(prompt, department if department != "Todos" else None)
                
                # Debug: mostrar información de búsqueda
                st.info(f"🔍 Búsqueda realizada para: '{prompt}'" + 
                       (f" en departamento: {department}" if department != "Todos" else ""))
                
                if docs:
                    st.success(f"✅ Encontrados {len(docs)} documentos relevantes")
                    
                    # Generar respuesta con contexto
                    response = generate_response(prompt, docs, model)
                    
                    # Mostrar respuesta
                    st.markdown(response)
                    
                    # Mostrar fuentes
                    if docs:
                        st.markdown("---")
                        st.markdown("**📚 Fuentes consultadas:**")
                        for i, doc in enumerate(docs):
                            with st.expander(f"📄 {doc['name']} ({doc['department']})"):
                                st.write(f"**Tipo:** {doc['type']}")
                                st.write(f"**Resumen:** {doc['summary']}")
                                st.write(f"**Contenido (primeros 200 chars):** {doc['content'][:200]}...")
                else:
                    st.warning("⚠️ No se encontraron documentos relevantes")
                    
                    # Intentar búsqueda más amplia
                    st.info("Intentando búsqueda sin filtros...")
                    all_docs = search_documents("", None)  # Búsqueda sin filtros
                    
                    if all_docs:
                        st.info(f"📋 Hay {len(all_docs)} documentos disponibles en total")
                        response = f"No encontré información específica sobre '{prompt}', pero tengo acceso a información general de TV Azteca sobre {', '.join([doc['department'] for doc in all_docs[:3]])}. ¿Podrías hacer una pregunta más específica?"
                    else:
                        response = "No hay documentos disponibles en la base de datos. Asegúrate de haber ejecutado el setup completo con TVAZTECA_worksheet.sql"
                    
                    st.markdown(response)
                
        st.session_state.messages.append({"role": "assistant", "content": response})
    
    # Sugerencias iniciales
    if not st.session_state.messages:
        st.markdown("### 💡 Preguntas sugeridas:")
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("""
            **📺 Programación:**
            - ¿Qué programas tiene Azteca UNO?
            - ¿Cuál es el rating de los noticieros?
            - ¿Qué deportes transmite TV Azteca?
            """)
        
        with col2:
            st.markdown("""
            **💼 Corporativo:**
            - ¿Cuáles son los ingresos de TV Azteca?
            - ¿Qué estrategias digitales maneja?
            - ¿Cómo funciona la tecnología de transmisión?
            """)

if __name__ == "__main__":
    main()
