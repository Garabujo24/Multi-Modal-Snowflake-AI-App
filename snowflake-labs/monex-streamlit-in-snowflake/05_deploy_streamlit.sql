-- =================================================================
-- DESPLIEGUE DE APLICACIÓN STREAMLIT - MONEX GRUPO FINANCIERO
-- =================================================================

USE DATABASE MONEX_DB;
USE WAREHOUSE MONEX_WH;
USE ROLE MONEX_APP_ROLE;

-- =================================================================
-- CREAR APLICACIÓN STREAMLIT
-- =================================================================

CREATE OR REPLACE STREAMLIT MONEX_ANALYTICS_APP
    ROOT_LOCATION = '@MONEX_DB.STAGES.STREAMLIT_APP'
    MAIN_FILE = 'monex_app.py'
    QUERY_WAREHOUSE = MONEX_WH
    TITLE = 'Monex Grupo Financiero - Analytics Hub'
    COMMENT = 'Aplicación de análisis financiero con Cortex Analyst y Cortex Search';

-- =================================================================
-- OTORGAR PERMISOS
-- =================================================================

-- Permisos para el rol de la aplicación
GRANT USAGE ON STREAMLIT MONEX_ANALYTICS_APP TO ROLE MONEX_APP_ROLE;

-- Permisos adicionales para Cortex
GRANT USAGE ON DATABASE MONEX_DB TO ROLE MONEX_APP_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE MONEX_DB TO ROLE MONEX_APP_ROLE;
GRANT SELECT ON ALL TABLES IN DATABASE MONEX_DB TO ROLE MONEX_APP_ROLE;
GRANT SELECT ON ALL VIEWS IN DATABASE MONEX_DB TO ROLE MONEX_APP_ROLE;

-- Permisos específicos para Cortex Search
GRANT USAGE ON CORTEX SEARCH SERVICE MONEX_DB.DOCUMENTS.MONEX_DOCUMENTS_SEARCH TO ROLE MONEX_APP_ROLE;
GRANT USAGE ON CORTEX SEARCH SERVICE MONEX_DB.DOCUMENTS.MONEX_CONTRATOS_SEARCH TO ROLE MONEX_APP_ROLE;
GRANT USAGE ON CORTEX SEARCH SERVICE MONEX_DB.DOCUMENTS.MONEX_MANUALES_SEARCH TO ROLE MONEX_APP_ROLE;

-- Permisos para stages
GRANT READ ON STAGE MONEX_DB.STAGES.SEMANTIC_MODELS TO ROLE MONEX_APP_ROLE;
GRANT READ, WRITE ON STAGE MONEX_DB.STAGES.STREAMLIT_APP TO ROLE MONEX_APP_ROLE;

-- Otorgar el rol al usuario actual y PUBLIC para acceso
GRANT ROLE MONEX_APP_ROLE TO ROLE PUBLIC;

-- =================================================================
-- VERIFICAR CONFIGURACIÓN
-- =================================================================

-- Mostrar información de la aplicación
DESCRIBE STREAMLIT MONEX_ANALYTICS_APP;

-- Verificar servicios de Cortex Search
SHOW CORTEX SEARCH SERVICES IN DATABASE MONEX_DB;

-- Verificar stages
LIST @MONEX_DB.STAGES.SEMANTIC_MODELS;
LIST @MONEX_DB.STAGES.STREAMLIT_APP;

-- =================================================================
-- INFORMACIÓN FINAL
-- =================================================================

SELECT 'Aplicación Streamlit desplegada exitosamente!' AS STATUS,
       'MONEX_ANALYTICS_APP' AS APP_NAME,
       'Accede desde: Data > Streamlit Apps > MONEX_ANALYTICS_APP' AS ACCESO;

-- =================================================================
-- INSTRUCCIONES POST-DESPLIEGUE
-- =================================================================

/*
INSTRUCCIONES PARA COMPLETAR EL DESPLIEGUE:

1. SUBIR ARCHIVOS:
   a) Subir monex_semantic_model.yaml:
      - Ve a Data > Databases > MONEX_DB > STAGES > SEMANTIC_MODELS
      - Haz clic en "+ Files" y sube monex_semantic_model.yaml
   
   b) Subir monex_app.py:
      - Ve a Data > Databases > MONEX_DB > STAGES > STREAMLIT_APP
      - Haz clic en "+ Files" y sube monex_app.py

2. VERIFICAR SERVICIOS:
   - Los servicios de Cortex Search deben estar en estado "READY"
   - Puedes verificar con: SHOW CORTEX SEARCH SERVICES;

3. ACCEDER A LA APLICACIÓN:
   - Ve a Data > Streamlit Apps
   - Busca "MONEX_ANALYTICS_APP"
   - Haz clic para abrir la aplicación

4. PROBAR FUNCIONALIDADES:
   - Dashboard Ejecutivo: Métricas en tiempo real
   - Cortex Analyst: Preguntas en lenguaje natural
   - Cortex Search: Búsqueda en documentos
   - Análisis Avanzado: Reportes especializados

5. EJEMPLOS DE USO:

   CORTEX ANALYST:
   - "¿Cuáles son los ingresos totales por mes?"
   - "¿Cuántos clientes tenemos por segmento?"
   - "¿Cuál es el rendimiento de las inversiones USD?"
   
   CORTEX SEARCH:
   - "factoraje sin recurso"
   - "inversiones USD private banking"
   - "procedimientos cambio divisas"

6. SOLUCIÓN DE PROBLEMAS:
   - Si hay errores de permisos: Verificar roles y grants
   - Si Cortex Analyst no responde: Verificar que el modelo YAML esté subido
   - Si Cortex Search no funciona: Verificar que los servicios estén READY

¡La aplicación está lista para usar!
*/


