-- ═══════════════════════════════════════════════════════════════════════════
--                        AGILCREDIT - PROCESAMIENTO DE DOCUMENTOS PDF/TXT
--                        Extracción y Análisis de Texto No Estructurado
-- ═══════════════════════════════════════════════════════════════════════════
-- Autor: AgilCredit Data Engineering Team
-- Fecha: Octubre 2025
-- Descripción: Script para cargar documentos PDF/TXT a Snowflake y procesarlos
--              con Snowflake Cortex para análisis de texto
-- ═══════════════════════════════════════════════════════════════════════════

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE AGILCREDIT_WH;
USE DATABASE AGILCREDIT_DB;

-- ═══════════════════════════════════════════════════════════════════════════
-- SECCIÓN 1: CONFIGURACIÓN DE STAGE Y FILE FORMAT
-- ═══════════════════════════════════════════════════════════════════════════

-- Crear schema para documentos si no existe
CREATE SCHEMA IF NOT EXISTS DOCUMENTS;
USE SCHEMA DOCUMENTS;

-- Crear Stage para archivos PDF/TXT
CREATE OR REPLACE STAGE AGILCREDIT_DOCUMENTS
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage para almacenar documentos PDF/TXT de AgilCredit';

-- File Format para archivos de texto
CREATE OR REPLACE FILE FORMAT TEXT_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = NONE
    RECORD_DELIMITER = NONE
    SKIP_HEADER = 0
    FIELD_OPTIONALLY_ENCLOSED_BY = NONE
    TRIM_SPACE = FALSE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ESCAPE = NONE
    ESCAPE_UNENCLOSED_FIELD = NONE
    DATE_FORMAT = 'AUTO'
    TIMESTAMP_FORMAT = 'AUTO'
    NULL_IF = ()
    COMMENT = 'File format para leer archivos de texto completos';

-- ═══════════════════════════════════════════════════════════════════════════
-- SECCIÓN 2: INSTRUCCIONES DE CARGA
-- ═══════════════════════════════════════════════════════════════════════════

/*
OPCIÓN 1: DESDE SNOWSQL (Línea de Comandos)
--------------------------------------------
snowsql -a <tu_cuenta> -u <tu_usuario>

PUT file:///Users/gjimenez/Documents/GitHub/Financial\ Services\ Demo/AgilCredit_Demo/datos_no_estructurados/pdfs/*.txt 
    @AGILCREDIT_DOCUMENTS/pdfs/ 
    AUTO_COMPRESS=FALSE 
    OVERWRITE=TRUE;


OPCIÓN 2: DESDE SNOWSIGHT UI
------------------------------
1. Ir a Data > Databases > AGILCREDIT_DB > DOCUMENTS > Stages
2. Seleccionar AGILCREDIT_DOCUMENTS
3. Click en el botón "+ Files"
4. Arrastrar los archivos .txt desde la carpeta pdfs/
5. Click "Upload"


OPCIÓN 3: DESDE PYTHON (Snowpark)
----------------------------------
from snowflake.snowpark import Session
import os

session = Session.builder.configs({
    "account": "<tu_cuenta>",
    "user": "<tu_usuario>",
    "password": "<tu_password>",
    "role": "ACCOUNTADMIN",
    "warehouse": "AGILCREDIT_WH",
    "database": "AGILCREDIT_DB",
    "schema": "DOCUMENTS"
}).create()

# Subir archivos
directory = "./datos_no_estructurados/pdfs/"
for filename in os.listdir(directory):
    if filename.endswith(".txt"):
        session.file.put(
            f"{directory}{filename}",
            "@AGILCREDIT_DOCUMENTS/pdfs/",
            auto_compress=False,
            overwrite=True
        )
*/

-- ═══════════════════════════════════════════════════════════════════════════
-- SECCIÓN 3: VERIFICAR ARCHIVOS CARGADOS
-- ═══════════════════════════════════════════════════════════════════════════

-- Listar archivos en el stage
LIST @AGILCREDIT_DOCUMENTS/pdfs/;

-- Ver tamaño total
SELECT 
    COUNT(*) as TOTAL_FILES,
    SUM("size") / 1024 as TOTAL_SIZE_KB,
    AVG("size") / 1024 as AVG_SIZE_KB,
    MIN("size") / 1024 as MIN_SIZE_KB,
    MAX("size") / 1024 as MAX_SIZE_KB
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- ═══════════════════════════════════════════════════════════════════════════
-- SECCIÓN 4: CREAR TABLA PARA ALMACENAR DOCUMENTOS
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE TABLE RAW_DOCUMENTS (
    DOCUMENT_ID VARCHAR(50) PRIMARY KEY,
    FILE_NAME VARCHAR(500) NOT NULL,
    FILE_PATH VARCHAR(1000) NOT NULL,
    DOCUMENT_TYPE VARCHAR(100),
    CONTENT_TEXT TEXT,
    FILE_SIZE_BYTES NUMBER,
    LINE_COUNT NUMBER,
    CHAR_COUNT NUMBER,
    UPLOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    LAST_MODIFIED TIMESTAMP_NTZ,
    METADATA VARIANT,
    TAGS ARRAY
) COMMENT = 'Tabla para almacenar contenido completo de documentos PDF/TXT';

-- ═══════════════════════════════════════════════════════════════════════════
-- SECCIÓN 5: CARGAR CONTENIDO DE DOCUMENTOS A LA TABLA
-- ═══════════════════════════════════════════════════════════════════════════

-- Crear función helper para leer archivo completo
CREATE OR REPLACE FUNCTION READ_FULL_FILE(stage_path STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
    SELECT $1 FROM @AGILCREDIT_DOCUMENTS || stage_path (FILE_FORMAT => TEXT_FORMAT) LIMIT 1
$$;

-- Template para cargar cada archivo individual
-- Ejecutar este bloque para cada archivo

-- 1. Estado de Cuenta Mensual
INSERT INTO RAW_DOCUMENTS (
    DOCUMENT_ID, 
    FILE_NAME, 
    FILE_PATH, 
    DOCUMENT_TYPE, 
    CONTENT_TEXT,
    FILE_SIZE_BYTES,
    CHAR_COUNT,
    METADATA,
    TAGS
)
SELECT 
    'DOC-EDO-CTA-001',
    'estado_cuenta_mensual.txt',
    '/pdfs/estado_cuenta_mensual.txt',
    'Estado de Cuenta',
    $1::STRING,
    LENGTH($1::STRING),
    LENGTH($1::STRING),
    OBJECT_CONSTRUCT(
        'cliente_id', 'CLI000234',
        'periodo', 'Septiembre 2025',
        'categoria', 'Comunicación Cliente'
    ),
    ARRAY_CONSTRUCT('estado_cuenta', 'comunicacion', 'mensual', 'cliente')
FROM @AGILCREDIT_DOCUMENTS/pdfs/estado_cuenta_mensual.txt 
(FILE_FORMAT => TEXT_FORMAT)
LIMIT 1;

-- 2. Política de Prevención de Lavado de Dinero
INSERT INTO RAW_DOCUMENTS (
    DOCUMENT_ID, 
    FILE_NAME, 
    FILE_PATH, 
    DOCUMENT_TYPE, 
    CONTENT_TEXT,
    FILE_SIZE_BYTES,
    CHAR_COUNT,
    METADATA,
    TAGS
)
SELECT 
    'DOC-POL-PLD-001',
    'politica_prevencion_lavado_dinero.txt',
    '/pdfs/politica_prevencion_lavado_dinero.txt',
    'Política Interna',
    $1::STRING,
    LENGTH($1::STRING),
    LENGTH($1::STRING),
    OBJECT_CONSTRUCT(
        'version', '3.1',
        'fecha_aprobacion', '2025-08-15',
        'categoria', 'Compliance'
    ),
    ARRAY_CONSTRUCT('pld', 'compliance', 'politica', 'regulatorio')
FROM @AGILCREDIT_DOCUMENTS/pdfs/politica_prevencion_lavado_dinero.txt 
(FILE_FORMAT => TEXT_FORMAT)
LIMIT 1;

-- 3. Carta de Aprobación de Crédito
INSERT INTO RAW_DOCUMENTS (
    DOCUMENT_ID, 
    FILE_NAME, 
    FILE_PATH, 
    DOCUMENT_TYPE, 
    CONTENT_TEXT,
    FILE_SIZE_BYTES,
    CHAR_COUNT,
    METADATA,
    TAGS
)
SELECT 
    'DOC-CARTA-APR-001',
    'carta_aprobacion_credito.txt',
    '/pdfs/carta_aprobacion_credito.txt',
    'Carta Aprobación',
    $1::STRING,
    LENGTH($1::STRING),
    LENGTH($1::STRING),
    OBJECT_CONSTRUCT(
        'solicitud_id', 'SOL000892',
        'cliente_id', 'CLI000892',
        'monto_aprobado', 50000.00,
        'categoria', 'Originación'
    ),
    ARRAY_CONSTRUCT('aprobacion', 'credito', 'comunicacion', 'originacion')
FROM @AGILCREDIT_DOCUMENTS/pdfs/carta_aprobacion_credito.txt 
(FILE_FORMAT => TEXT_FORMAT)
LIMIT 1;

-- 4. Manual de Políticas de Crédito
INSERT INTO RAW_DOCUMENTS (
    DOCUMENT_ID, 
    FILE_NAME, 
    FILE_PATH, 
    DOCUMENT_TYPE, 
    CONTENT_TEXT,
    FILE_SIZE_BYTES,
    CHAR_COUNT,
    METADATA,
    TAGS
)
SELECT 
    'DOC-MAN-POL-CRE-001',
    'manual_politicas_credito.txt',
    '/pdfs/manual_politicas_credito.txt',
    'Manual Interno',
    $1::STRING,
    LENGTH($1::STRING),
    LENGTH($1::STRING),
    OBJECT_CONSTRUCT(
        'version', '5.2',
        'fecha', '2025-09-01',
        'clasificacion', 'CONFIDENCIAL',
        'categoria', 'Operaciones'
    ),
    ARRAY_CONSTRUCT('manual', 'politicas', 'credito', 'interno')
FROM @AGILCREDIT_DOCUMENTS/pdfs/manual_politicas_credito.txt 
(FILE_FORMAT => TEXT_FORMAT)
LIMIT 1;

-- 5. Carta de Rechazo de Crédito
INSERT INTO RAW_DOCUMENTS (
    DOCUMENT_ID, 
    FILE_NAME, 
    FILE_PATH, 
    DOCUMENT_TYPE, 
    CONTENT_TEXT,
    FILE_SIZE_BYTES,
    CHAR_COUNT,
    METADATA,
    TAGS
)
SELECT 
    'DOC-CARTA-RCH-001',
    'carta_rechazo_credito.txt',
    '/pdfs/carta_rechazo_credito.txt',
    'Carta Rechazo',
    $1::STRING,
    LENGTH($1::STRING),
    LENGTH($1::STRING),
    OBJECT_CONSTRUCT(
        'solicitud_id', 'SOL001543',
        'categoria', 'Originación'
    ),
    ARRAY_CONSTRUCT('rechazo', 'credito', 'comunicacion')
FROM @AGILCREDIT_DOCUMENTS/pdfs/carta_rechazo_credito.txt 
(FILE_FORMAT => TEXT_FORMAT)
LIMIT 1;

-- 6. Términos y Condiciones App Móvil
INSERT INTO RAW_DOCUMENTS (
    DOCUMENT_ID, 
    FILE_NAME, 
    FILE_PATH, 
    DOCUMENT_TYPE, 
    CONTENT_TEXT,
    FILE_SIZE_BYTES,
    CHAR_COUNT,
    METADATA,
    TAGS
)
SELECT 
    'DOC-TYC-APP-001',
    'terminos_condiciones_app_movil.txt',
    '/pdfs/terminos_condiciones_app_movil.txt',
    'Términos y Condiciones',
    $1::STRING,
    LENGTH($1::STRING),
    LENGTH($1::STRING),
    OBJECT_CONSTRUCT(
        'version', '3.2.1',
        'fecha_actualizacion', '2025-09-01',
        'categoria', 'Legal'
    ),
    ARRAY_CONSTRUCT('terminos', 'app', 'legal', 'digital')
FROM @AGILCREDIT_DOCUMENTS/pdfs/terminos_condiciones_app_movil.txt 
(FILE_FORMAT => TEXT_FORMAT)
LIMIT 1;

-- 7. Notificación de Atraso en Pago
INSERT INTO RAW_DOCUMENTS (
    DOCUMENT_ID, 
    FILE_NAME, 
    FILE_PATH, 
    DOCUMENT_TYPE, 
    CONTENT_TEXT,
    FILE_SIZE_BYTES,
    CHAR_COUNT,
    METADATA,
    TAGS
)
SELECT 
    'DOC-NOT-ATR-001',
    'notificacion_atraso_pago.txt',
    '/pdfs/notificacion_atraso_pago.txt',
    'Notificación Cobranza',
    $1::STRING,
    LENGTH($1::STRING),
    LENGTH($1::STRING),
    OBJECT_CONSTRUCT(
        'credito_id', 'CRE000567',
        'cliente_id', 'CLI000567',
        'dias_atraso', 5,
        'categoria', 'Cobranza'
    ),
    ARRAY_CONSTRUCT('cobranza', 'atraso', 'notificacion', 'mora')
FROM @AGILCREDIT_DOCUMENTS/pdfs/notificacion_atraso_pago.txt 
(FILE_FORMAT => TEXT_FORMAT)
LIMIT 1;

-- 8. Comprobante de Pago
INSERT INTO RAW_DOCUMENTS (
    DOCUMENT_ID, 
    FILE_NAME, 
    FILE_PATH, 
    DOCUMENT_TYPE, 
    CONTENT_TEXT,
    FILE_SIZE_BYTES,
    CHAR_COUNT,
    METADATA,
    TAGS
)
SELECT 
    'DOC-COMP-PAG-001',
    'comprobante_pago.txt',
    '/pdfs/comprobante_pago.txt',
    'Comprobante',
    $1::STRING,
    LENGTH($1::STRING),
    LENGTH($1::STRING),
    OBJECT_CONSTRUCT(
        'folio', 'PAY-2025-ABC-123456',
        'cliente_id', 'CLI000234',
        'monto', 3250.00,
        'categoria', 'Transaccional'
    ),
    ARRAY_CONSTRUCT('comprobante', 'pago', 'transaccion')
FROM @AGILCREDIT_DOCUMENTS/pdfs/comprobante_pago.txt 
(FILE_FORMAT => TEXT_FORMAT)
LIMIT 1;

-- 9. Reporte Ejecutivo Trimestral
INSERT INTO RAW_DOCUMENTS (
    DOCUMENT_ID, 
    FILE_NAME, 
    FILE_PATH, 
    DOCUMENT_TYPE, 
    CONTENT_TEXT,
    FILE_SIZE_BYTES,
    CHAR_COUNT,
    METADATA,
    TAGS
)
SELECT 
    'DOC-REP-EJE-Q3-001',
    'reporte_ejecutivo_trimestral.txt',
    '/pdfs/reporte_ejecutivo_trimestral.txt',
    'Reporte Ejecutivo',
    $1::STRING,
    LENGTH($1::STRING),
    LENGTH($1::STRING),
    OBJECT_CONSTRUCT(
        'periodo', 'Q3 2025',
        'destinatario', 'Consejo de Administración',
        'clasificacion', 'CONFIDENCIAL',
        'categoria', 'Reporting'
    ),
    ARRAY_CONSTRUCT('reporte', 'ejecutivo', 'trimestral', 'confidencial')
FROM @AGILCREDIT_DOCUMENTS/pdfs/reporte_ejecutivo_trimestral.txt 
(FILE_FORMAT => TEXT_FORMAT)
LIMIT 1;

-- 10. Guía de Usuario Plataforma
INSERT INTO RAW_DOCUMENTS (
    DOCUMENT_ID, 
    FILE_NAME, 
    FILE_PATH, 
    DOCUMENT_TYPE, 
    CONTENT_TEXT,
    FILE_SIZE_BYTES,
    CHAR_COUNT,
    METADATA,
    TAGS
)
SELECT 
    'DOC-GUIA-USR-001',
    'guia_usuario_plataforma.txt',
    '/pdfs/guia_usuario_plataforma.txt',
    'Guía Usuario',
    $1::STRING,
    LENGTH($1::STRING),
    LENGTH($1::STRING),
    OBJECT_CONSTRUCT(
        'version', '2.3',
        'fecha', '2025-10-01',
        'categoria', 'Soporte'
    ),
    ARRAY_CONSTRUCT('guia', 'usuario', 'plataforma', 'soporte')
FROM @AGILCREDIT_DOCUMENTS/pdfs/guia_usuario_plataforma.txt 
(FILE_FORMAT => TEXT_FORMAT)
LIMIT 1;

-- 11. Contrato de Crédito Template
INSERT INTO RAW_DOCUMENTS (
    DOCUMENT_ID, 
    FILE_NAME, 
    FILE_PATH, 
    DOCUMENT_TYPE, 
    CONTENT_TEXT,
    FILE_SIZE_BYTES,
    CHAR_COUNT,
    METADATA,
    TAGS
)
SELECT 
    'DOC-CONT-TEMP-001',
    'contrato_credito_template.txt',
    '/pdfs/contrato_credito_template.txt',
    'Contrato Template',
    $1::STRING,
    LENGTH($1::STRING),
    LENGTH($1::STRING),
    OBJECT_CONSTRUCT(
        'tipo', 'Contrato de Crédito Personal',
        'categoria', 'Legal'
    ),
    ARRAY_CONSTRUCT('contrato', 'template', 'legal', 'credito')
FROM @AGILCREDIT_DOCUMENTS/pdfs/contrato_credito_template.txt 
(FILE_FORMAT => TEXT_FORMAT)
LIMIT 1;

-- ═══════════════════════════════════════════════════════════════════════════
-- SECCIÓN 6: VERIFICAR CARGA
-- ═══════════════════════════════════════════════════════════════════════════

-- Ver todos los documentos cargados
SELECT 
    DOCUMENT_ID,
    FILE_NAME,
    DOCUMENT_TYPE,
    FILE_SIZE_BYTES / 1024 as SIZE_KB,
    CHAR_COUNT,
    ARRAY_SIZE(TAGS) as NUM_TAGS,
    UPLOAD_TIMESTAMP
FROM RAW_DOCUMENTS
ORDER BY UPLOAD_TIMESTAMP DESC;

-- Estadísticas por tipo de documento
SELECT 
    DOCUMENT_TYPE,
    COUNT(*) as CANTIDAD,
    AVG(CHAR_COUNT) as PROMEDIO_CARACTERES,
    SUM(FILE_SIZE_BYTES) / 1024 as TOTAL_SIZE_KB
FROM RAW_DOCUMENTS
GROUP BY DOCUMENT_TYPE
ORDER BY CANTIDAD DESC;

-- ═══════════════════════════════════════════════════════════════════════════
-- SECCIÓN 7: PROCESAMIENTO CON SNOWFLAKE CORTEX
-- ═══════════════════════════════════════════════════════════════════════════

-- Crear tabla para almacenar análisis de Cortex
CREATE OR REPLACE TABLE DOCUMENT_ANALYSIS (
    DOCUMENT_ID VARCHAR(50),
    ANALYSIS_TYPE VARCHAR(50),
    ANALYSIS_RESULT VARIANT,
    PROCESSING_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (DOCUMENT_ID) REFERENCES RAW_DOCUMENTS(DOCUMENT_ID)
) COMMENT = 'Resultados de análisis de documentos con Snowflake Cortex';

-- 7.1 RESUMEN AUTOMÁTICO DE DOCUMENTOS
-- Generar resumen de cada documento
INSERT INTO DOCUMENT_ANALYSIS (DOCUMENT_ID, ANALYSIS_TYPE, ANALYSIS_RESULT)
SELECT 
    DOCUMENT_ID,
    'SUMMARY' as ANALYSIS_TYPE,
    OBJECT_CONSTRUCT(
        'summary', SNOWFLAKE.CORTEX.COMPLETE(
            'mixtral-8x7b',
            CONCAT(
                'Resume este documento en máximo 150 palabras, destacando los puntos clave: ',
                SUBSTR(CONTENT_TEXT, 1, 8000)
            )
        ),
        'prompt_tokens', 8000,
        'model_used', 'mixtral-8x7b'
    ) as ANALYSIS_RESULT
FROM RAW_DOCUMENTS
WHERE DOCUMENT_TYPE IN ('Política Interna', 'Manual Interno', 'Reporte Ejecutivo');

-- 7.2 EXTRACCIÓN DE INFORMACIÓN CLAVE
-- Extraer montos, fechas, y datos clave de cartas de crédito
INSERT INTO DOCUMENT_ANALYSIS (DOCUMENT_ID, ANALYSIS_TYPE, ANALYSIS_RESULT)
SELECT 
    DOCUMENT_ID,
    'KEY_EXTRACTION' as ANALYSIS_TYPE,
    OBJECT_CONSTRUCT(
        'extracted_data', SNOWFLAKE.CORTEX.COMPLETE(
            'llama3-70b',
            CONCAT(
                'Extrae y estructura en formato JSON los siguientes datos de este documento: ',
                'monto_aprobado, plazo_meses, tasa_interes, fecha, cliente. ',
                'Documento: ', SUBSTR(CONTENT_TEXT, 1, 5000)
            )
        ),
        'model_used', 'llama3-70b'
    ) as ANALYSIS_RESULT
FROM RAW_DOCUMENTS
WHERE DOCUMENT_TYPE IN ('Carta Aprobación', 'Carta Rechazo');

-- 7.3 ANÁLISIS DE SENTIMIENTO (Para comunicaciones con clientes)
INSERT INTO DOCUMENT_ANALYSIS (DOCUMENT_ID, ANALYSIS_TYPE, ANALYSIS_RESULT)
SELECT 
    DOCUMENT_ID,
    'SENTIMENT' as ANALYSIS_TYPE,
    OBJECT_CONSTRUCT(
        'sentiment_score', SNOWFLAKE.CORTEX.SENTIMENT(SUBSTR(CONTENT_TEXT, 1, 5000)),
        'classification', CASE 
            WHEN SNOWFLAKE.CORTEX.SENTIMENT(SUBSTR(CONTENT_TEXT, 1, 5000)) > 0.3 THEN 'Positivo'
            WHEN SNOWFLAKE.CORTEX.SENTIMENT(SUBSTR(CONTENT_TEXT, 1, 5000)) < -0.3 THEN 'Negativo'
            ELSE 'Neutral'
        END
    ) as ANALYSIS_RESULT
FROM RAW_DOCUMENTS
WHERE DOCUMENT_TYPE IN ('Estado de Cuenta', 'Carta Aprobación', 'Carta Rechazo', 'Notificación Cobranza');

-- 7.4 CLASIFICACIÓN DE DOCUMENTOS
-- Clasificar documentos por categoría usando ML
INSERT INTO DOCUMENT_ANALYSIS (DOCUMENT_ID, ANALYSIS_TYPE, ANALYSIS_RESULT)
SELECT 
    DOCUMENT_ID,
    'CLASSIFICATION' as ANALYSIS_TYPE,
    OBJECT_CONSTRUCT(
        'categories', SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
            SUBSTR(CONTENT_TEXT, 1, 3000),
            ARRAY_CONSTRUCT('Legal', 'Operacional', 'Comunicación Cliente', 'Compliance', 'Financiero')
        )
    ) as ANALYSIS_RESULT
FROM RAW_DOCUMENTS;

-- 7.5 BÚSQUEDA SEMÁNTICA
-- Responder preguntas sobre documentos
INSERT INTO DOCUMENT_ANALYSIS (DOCUMENT_ID, ANALYSIS_TYPE, ANALYSIS_RESULT)
SELECT 
    DOCUMENT_ID,
    'Q&A_PLD' as ANALYSIS_TYPE,
    OBJECT_CONSTRUCT(
        'question', '¿Cuáles son las principales obligaciones de PLD?',
        'answer', SNOWFLAKE.CORTEX.COMPLETE(
            'mixtral-8x7b',
            CONCAT(
                'Basándote en este documento, responde: ¿Cuáles son las principales obligaciones de PLD? ',
                'Documento: ', SUBSTR(CONTENT_TEXT, 1, 10000)
            )
        )
    ) as ANALYSIS_RESULT
FROM RAW_DOCUMENTS
WHERE DOCUMENT_TYPE = 'Política Interna' AND FILE_NAME LIKE '%lavado%';

-- ═══════════════════════════════════════════════════════════════════════════
-- SECCIÓN 8: VISTAS ANALÍTICAS
-- ═══════════════════════════════════════════════════════════════════════════

-- Vista: Resúmenes de Documentos
CREATE OR REPLACE VIEW V_DOCUMENT_SUMMARIES AS
SELECT 
    d.DOCUMENT_ID,
    d.FILE_NAME,
    d.DOCUMENT_TYPE,
    d.CHAR_COUNT,
    a.ANALYSIS_RESULT:summary::STRING as RESUMEN,
    d.UPLOAD_TIMESTAMP,
    a.PROCESSING_TIMESTAMP
FROM RAW_DOCUMENTS d
JOIN DOCUMENT_ANALYSIS a ON d.DOCUMENT_ID = a.DOCUMENT_ID
WHERE a.ANALYSIS_TYPE = 'SUMMARY';

-- Vista: Análisis de Sentimiento
CREATE OR REPLACE VIEW V_DOCUMENT_SENTIMENT AS
SELECT 
    d.DOCUMENT_ID,
    d.FILE_NAME,
    d.DOCUMENT_TYPE,
    a.ANALYSIS_RESULT:sentiment_score::FLOAT as SENTIMENT_SCORE,
    a.ANALYSIS_RESULT:classification::STRING as SENTIMENT_CLASS,
    CASE 
        WHEN a.ANALYSIS_RESULT:sentiment_score::FLOAT > 0.5 THEN '😊 Muy Positivo'
        WHEN a.ANALYSIS_RESULT:sentiment_score::FLOAT > 0.2 THEN '🙂 Positivo'
        WHEN a.ANALYSIS_RESULT:sentiment_score::FLOAT > -0.2 THEN '😐 Neutral'
        WHEN a.ANALYSIS_RESULT:sentiment_score::FLOAT > -0.5 THEN '😟 Negativo'
        ELSE '😢 Muy Negativo'
    END as EMOJI_SENTIMENT,
    d.METADATA:cliente_id::STRING as CLIENTE_ID,
    d.UPLOAD_TIMESTAMP
FROM RAW_DOCUMENTS d
JOIN DOCUMENT_ANALYSIS a ON d.DOCUMENT_ID = a.DOCUMENT_ID
WHERE a.ANALYSIS_TYPE = 'SENTIMENT';

-- Vista: Búsqueda de Documentos por Tags
CREATE OR REPLACE VIEW V_DOCUMENT_SEARCH AS
SELECT 
    DOCUMENT_ID,
    FILE_NAME,
    DOCUMENT_TYPE,
    CHAR_COUNT / 1000 as SIZE_K_CHARS,
    t.VALUE::STRING as TAG,
    METADATA,
    UPLOAD_TIMESTAMP
FROM RAW_DOCUMENTS,
LATERAL FLATTEN(input => TAGS) t;

-- Vista: Documentos por Cliente
CREATE OR REPLACE VIEW V_DOCUMENTS_BY_CLIENT AS
SELECT 
    METADATA:cliente_id::STRING as CLIENTE_ID,
    COUNT(*) as NUM_DOCUMENTOS,
    LISTAGG(DOCUMENT_TYPE, ', ') as TIPOS_DOCUMENTOS,
    SUM(CHAR_COUNT) as TOTAL_CARACTERES,
    MIN(UPLOAD_TIMESTAMP) as PRIMER_DOCUMENTO,
    MAX(UPLOAD_TIMESTAMP) as ULTIMO_DOCUMENTO
FROM RAW_DOCUMENTS
WHERE METADATA:cliente_id IS NOT NULL
GROUP BY METADATA:cliente_id;

-- ═══════════════════════════════════════════════════════════════════════════
-- SECCIÓN 9: QUERIES DE EJEMPLO PARA ANÁLISIS
-- ═══════════════════════════════════════════════════════════════════════════

-- 9.1 Ver resúmenes de documentos largos
SELECT 
    FILE_NAME,
    DOCUMENT_TYPE,
    RESUMEN
FROM V_DOCUMENT_SUMMARIES
ORDER BY CHAR_COUNT DESC;

-- 9.2 Análisis de sentimiento en comunicaciones
SELECT 
    FILE_NAME,
    SENTIMENT_CLASS,
    EMOJI_SENTIMENT,
    SENTIMENT_SCORE,
    CLIENTE_ID
FROM V_DOCUMENT_SENTIMENT
ORDER BY SENTIMENT_SCORE;

-- 9.3 Buscar documentos por palabra clave
SELECT 
    DOCUMENT_ID,
    FILE_NAME,
    DOCUMENT_TYPE,
    TAG
FROM V_DOCUMENT_SEARCH
WHERE TAG LIKE '%compliance%'
ORDER BY FILE_NAME;

-- 9.4 Documentos relacionados con un cliente específico
SELECT 
    d.DOCUMENT_ID,
    d.FILE_NAME,
    d.DOCUMENT_TYPE,
    d.METADATA:cliente_id::STRING as CLIENTE_ID,
    d.METADATA:credito_id::STRING as CREDITO_ID,
    s.SENTIMENT_CLASS,
    d.UPLOAD_TIMESTAMP
FROM RAW_DOCUMENTS d
LEFT JOIN V_DOCUMENT_SENTIMENT s ON d.DOCUMENT_ID = s.DOCUMENT_ID
WHERE d.METADATA:cliente_id = 'CLI000234'
ORDER BY d.UPLOAD_TIMESTAMP;

-- 9.5 Extraer información estructurada de cartas de crédito
SELECT 
    d.FILE_NAME,
    d.DOCUMENT_TYPE,
    a.ANALYSIS_RESULT:extracted_data::STRING as DATOS_EXTRAIDOS,
    d.METADATA
FROM RAW_DOCUMENTS d
JOIN DOCUMENT_ANALYSIS a ON d.DOCUMENT_ID = a.DOCUMENT_ID
WHERE a.ANALYSIS_TYPE = 'KEY_EXTRACTION';

-- 9.6 Búsqueda de texto completo en documentos
SELECT 
    DOCUMENT_ID,
    FILE_NAME,
    DOCUMENT_TYPE,
    SUBSTRING(CONTENT_TEXT, 
              POSITION('CONDUSEF' IN UPPER(CONTENT_TEXT)) - 100,
              300) as CONTEXTO
FROM RAW_DOCUMENTS
WHERE UPPER(CONTENT_TEXT) LIKE '%CONDUSEF%';

-- 9.7 Estadísticas de análisis realizados
SELECT 
    ANALYSIS_TYPE,
    COUNT(*) as TOTAL_ANALISIS,
    MIN(PROCESSING_TIMESTAMP) as PRIMER_ANALISIS,
    MAX(PROCESSING_TIMESTAMP) as ULTIMO_ANALISIS
FROM DOCUMENT_ANALYSIS
GROUP BY ANALYSIS_TYPE;

-- ═══════════════════════════════════════════════════════════════════════════
-- SECCIÓN 10: INTEGRACIÓN CON DATOS ESTRUCTURADOS
-- ═══════════════════════════════════════════════════════════════════════════

-- Vista: Clientes con sus documentos y sentimiento
CREATE OR REPLACE VIEW V_CLIENTES_CON_DOCUMENTOS AS
SELECT 
    c.CLIENTE_ID,
    c.NOMBRE,
    c.APELLIDO_PATERNO,
    c.SCORE_RIESGO,
    c.SEGMENTO_CLIENTE,
    d.NUM_DOCUMENTOS,
    d.TIPOS_DOCUMENTOS,
    AVG(s.SENTIMENT_SCORE) as SENTIMENT_PROMEDIO,
    CASE 
        WHEN AVG(s.SENTIMENT_SCORE) > 0.2 THEN 'Cliente Satisfecho'
        WHEN AVG(s.SENTIMENT_SCORE) < -0.2 THEN 'Cliente Insatisfecho'
        ELSE 'Neutro'
    END as NIVEL_SATISFACCION
FROM CORE.CLIENTES c
LEFT JOIN V_DOCUMENTS_BY_CLIENT d ON c.CLIENTE_ID = d.CLIENTE_ID
LEFT JOIN V_DOCUMENT_SENTIMENT s ON s.CLIENTE_ID = c.CLIENTE_ID
GROUP BY c.CLIENTE_ID, c.NOMBRE, c.APELLIDO_PATERNO, c.SCORE_RIESGO, 
         c.SEGMENTO_CLIENTE, d.NUM_DOCUMENTOS, d.TIPOS_DOCUMENTOS;

-- Vista: Timeline de comunicaciones por cliente
CREATE OR REPLACE VIEW V_TIMELINE_COMUNICACIONES AS
SELECT 
    rd.METADATA:cliente_id::STRING as CLIENTE_ID,
    rd.DOCUMENT_TYPE as TIPO_COMUNICACION,
    rd.UPLOAD_TIMESTAMP as FECHA,
    vs.SENTIMENT_CLASS as TONO,
    SUBSTR(rd.CONTENT_TEXT, 1, 200) as EXTRACTO
FROM RAW_DOCUMENTS rd
LEFT JOIN V_DOCUMENT_SENTIMENT vs ON rd.DOCUMENT_ID = vs.DOCUMENT_ID
WHERE rd.METADATA:cliente_id IS NOT NULL
ORDER BY rd.METADATA:cliente_id, rd.UPLOAD_TIMESTAMP;

-- ═══════════════════════════════════════════════════════════════════════════
-- SECCIÓN 11: LIMPIEZA (Opcional)
-- ═══════════════════════════════════════════════════════════════════════════

/*
-- Eliminar análisis antiguos
DELETE FROM DOCUMENT_ANALYSIS WHERE PROCESSING_TIMESTAMP < DATEADD(month, -6, CURRENT_TIMESTAMP());

-- Truncar y recargar
TRUNCATE TABLE RAW_DOCUMENTS;
TRUNCATE TABLE DOCUMENT_ANALYSIS;

-- Eliminar stage
REMOVE @AGILCREDIT_DOCUMENTS/pdfs/;
*/

-- ═══════════════════════════════════════════════════════════════════════════
-- FIN DEL SCRIPT
-- ═══════════════════════════════════════════════════════════════════════════

-- Resumen Final
SELECT 
    'TOTAL DOCUMENTOS CARGADOS' as METRICA,
    COUNT(*) as VALOR
FROM RAW_DOCUMENTS
UNION ALL
SELECT 
    'TOTAL ANÁLISIS REALIZADOS',
    COUNT(*)
FROM DOCUMENT_ANALYSIS
UNION ALL
SELECT 
    'TAMAÑO TOTAL (KB)',
    SUM(FILE_SIZE_BYTES) / 1024
FROM RAW_DOCUMENTS;

-- ═══════════════════════════════════════════════════════════════════════════
--                           ¡SCRIPT COMPLETADO!
-- ═══════════════════════════════════════════════════════════════════════════



