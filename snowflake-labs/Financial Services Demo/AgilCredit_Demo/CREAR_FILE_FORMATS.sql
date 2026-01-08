/*******************************************************************************
 * CREAR FILE FORMATS PARA JSON Y XML
 * 
 * Ejecuta este script PRIMERO antes de intentar leer archivos JSON o XML
 * 
 * Autor: AgilCredit Data Engineering Team
 *******************************************************************************/

-- Usar la base de datos y schema correctos
USE DATABASE AGILCREDIT_DEMO;
USE SCHEMA CORE;
USE WAREHOUSE COMPUTE_WH;

-- =============================================================================
-- PASO 1: CREAR FILE FORMATS
-- =============================================================================

-- FILE FORMAT para JSON arrays
-- STRIP_OUTER_ARRAY = TRUE es crucial para archivos JSON que son arrays [{}, {}]
CREATE OR REPLACE FILE FORMAT JSON_ARRAY_FORMAT
    TYPE = JSON
    STRIP_OUTER_ARRAY = TRUE
    COMMENT = 'Formato para leer archivos JSON que son arrays';

-- FILE FORMAT para XML
CREATE OR REPLACE FILE FORMAT XML_FORMAT
    TYPE = XML
    COMMENT = 'Formato para leer archivos XML';

-- Verificar que se crearon correctamente
SHOW FILE FORMATS LIKE '%FORMAT';

-- =============================================================================
-- PASO 2: CREAR STAGE
-- =============================================================================

-- Stage para almacenar archivos no estructurados
CREATE OR REPLACE STAGE AGILCREDIT_UNSTRUCTURED_DATA
    FILE_FORMAT = JSON_ARRAY_FORMAT  -- Default format para el stage
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage para archivos no estructurados (JSON, XML) de AgilCredit';

-- Verificar que se creó correctamente
SHOW STAGES LIKE 'AGILCREDIT_UNSTRUCTURED_DATA';

-- =============================================================================
-- PASO 3: VERIFICAR
-- =============================================================================

-- Ver información del stage
DESC STAGE AGILCREDIT_UNSTRUCTURED_DATA;

-- Ver información de los file formats
DESC FILE FORMAT JSON_ARRAY_FORMAT;
DESC FILE FORMAT XML_FORMAT;

/*
PRÓXIMOS PASOS:
===============
1. ✅ FILE FORMATs creados
2. ✅ Stage creado
3. ⏭️  Ahora puedes subir archivos al stage usando:
   - SnowSQL: PUT file://./path/to/file @AGILCREDIT_UNSTRUCTURED_DATA/
   - Snowsight UI: Data → Stages → Upload Files
   - Python: cursor.execute("PUT file://...")
4. ⏭️  Luego ejecuta las queries de las secciones 4-7 del script principal
*/



