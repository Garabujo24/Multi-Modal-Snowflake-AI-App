-- =================================================================
-- CONFIGURACIÓN DE CORTEX SEARCH - MONEX GRUPO FINANCIERO
-- =================================================================

USE DATABASE MONEX_DB;
USE SCHEMA DOCUMENTS;
USE WAREHOUSE MONEX_WH;

-- =================================================================
-- CREAR SERVICIOS DE CORTEX SEARCH
-- =================================================================

-- Servicio de búsqueda para documentos generales
CREATE OR REPLACE CORTEX SEARCH SERVICE MONEX_DOCUMENTS_SEARCH
    ON CONTENIDO
    ATTRIBUTES TITULO, TIPO_DOCUMENTO, CATEGORIA, CLIENTE_ID, FECHA_DOCUMENTO
    WAREHOUSE = MONEX_WH
    TARGET_LAG = '1 hour'
    AS (
        SELECT 
            DOCUMENTO_ID,
            TITULO,
            TIPO_DOCUMENTO,
            CATEGORIA,
            CLIENTE_ID,
            CONTENIDO,
            FECHA_DOCUMENTO,
            ESTADO,
            IDIOMA
        FROM CORE.DOCUMENTOS
        WHERE ESTADO = 'ACTIVO'
    );

-- Servicio especializado para contratos
CREATE OR REPLACE CORTEX SEARCH SERVICE MONEX_CONTRATOS_SEARCH
    ON CONTENIDO
    ATTRIBUTES TITULO, CATEGORIA, CLIENTE_ID, FECHA_DOCUMENTO
    WAREHOUSE = MONEX_WH
    TARGET_LAG = '30 minutes'
    AS (
        SELECT 
            DOCUMENTO_ID,
            TITULO,
            TIPO_DOCUMENTO,
            CATEGORIA,
            CLIENTE_ID,
            CONTENIDO,
            FECHA_DOCUMENTO
        FROM CORE.DOCUMENTOS
        WHERE TIPO_DOCUMENTO = 'CONTRATO' 
          AND ESTADO = 'ACTIVO'
    );

-- Servicio para manuales y políticas
CREATE OR REPLACE CORTEX SEARCH SERVICE MONEX_MANUALES_SEARCH
    ON CONTENIDO
    ATTRIBUTES TITULO, CATEGORIA, FECHA_DOCUMENTO
    WAREHOUSE = MONEX_WH
    TARGET_LAG = '1 day'
    AS (
        SELECT 
            DOCUMENTO_ID,
            TITULO,
            TIPO_DOCUMENTO,
            CATEGORIA,
            CONTENIDO,
            FECHA_DOCUMENTO
        FROM CORE.DOCUMENTOS
        WHERE TIPO_DOCUMENTO IN ('MANUAL', 'POLITICA')
          AND ESTADO = 'ACTIVO'
    );

-- =================================================================
-- SUBIR MODELO SEMÁNTICO AL STAGE
-- =================================================================

-- Nota: Este comando se debe ejecutar después de subir el archivo YAML al stage
-- PUT file:///path/to/monex_semantic_model.yaml @MONEX_DB.STAGES.SEMANTIC_MODELS;

-- =================================================================
-- CONFIGURAR PERMISOS PARA CORTEX SEARCH
-- =================================================================

-- Otorgar permisos de uso en los servicios de búsqueda
GRANT USAGE ON CORTEX SEARCH SERVICE MONEX_DOCUMENTS_SEARCH TO ROLE MONEX_APP_ROLE;
GRANT USAGE ON CORTEX SEARCH SERVICE MONEX_CONTRATOS_SEARCH TO ROLE MONEX_APP_ROLE;
GRANT USAGE ON CORTEX SEARCH SERVICE MONEX_MANUALES_SEARCH TO ROLE MONEX_APP_ROLE;

-- Otorgar permisos en la base de datos y esquema
GRANT USAGE ON DATABASE MONEX_DB TO ROLE MONEX_APP_ROLE;
GRANT USAGE ON SCHEMA DOCUMENTS TO ROLE MONEX_APP_ROLE;

-- =================================================================
-- PROBAR LOS SERVICIOS DE CORTEX SEARCH
-- =================================================================

-- Probar búsqueda en documentos generales
SELECT PARSE_JSON(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'MONEX_DB.DOCUMENTS.MONEX_DOCUMENTS_SEARCH',
        '{
            "query": "factoraje sin recurso",
            "columns": ["TITULO", "CATEGORIA", "FECHA_DOCUMENTO"],
            "limit": 3
        }'
    )
)['results'] as results;

-- Probar búsqueda en contratos
SELECT PARSE_JSON(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'MONEX_DB.DOCUMENTS.MONEX_CONTRATOS_SEARCH',
        '{
            "query": "crédito empresarial",
            "columns": ["TITULO", "CLIENTE_ID", "FECHA_DOCUMENTO"],
            "limit": 3
        }'
    )
)['results'] as results;

-- Probar búsqueda en manuales
SELECT PARSE_JSON(
    SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
        'MONEX_DB.DOCUMENTS.MONEX_MANUALES_SEARCH',
        '{
            "query": "tipos de cambio USD",
            "columns": ["TITULO", "CATEGORIA"],
            "limit": 3
        }'
    )
)['results'] as results;

-- =================================================================
-- VERIFICAR ESTADO DE LOS SERVICIOS
-- =================================================================

SHOW CORTEX SEARCH SERVICES IN SCHEMA DOCUMENTS;

-- Ver contenido indexado en el servicio principal
SELECT COUNT(*) as DOCUMENTOS_INDEXADOS
FROM TABLE(CORTEX_SEARCH_DATA_SCAN(
    SERVICE_NAME => 'MONEX_DOCUMENTS_SEARCH'
));

COMMIT;

SELECT 'Servicios de Cortex Search configurados exitosamente!' AS STATUS;

-- =================================================================
-- INSTRUCCIONES PARA SUBIR EL MODELO SEMÁNTICO
-- =================================================================

/*
INSTRUCCIONES PARA COMPLETAR LA CONFIGURACIÓN:

1. Subir el modelo semántico YAML al stage:
   - Ve a Data > Databases > MONEX_DB > STAGES > SEMANTIC_MODELS
   - Haz clic en "+ Files"
   - Sube el archivo monex_semantic_model.yaml

2. Verificar que el archivo se subió correctamente:
   LIST @MONEX_DB.STAGES.SEMANTIC_MODELS;

3. Los servicios de Cortex Search estarán listos en unos minutos
   después de ejecutar este script.

4. Para usar con Cortex Analyst, referencia el modelo como:
   @MONEX_DB.STAGES.SEMANTIC_MODELS/monex_semantic_model.yaml
*/


