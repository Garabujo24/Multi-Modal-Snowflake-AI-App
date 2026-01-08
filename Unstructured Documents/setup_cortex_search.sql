-- ============================================================================
-- Sección 0: Historia y Caso de Uso
-- ============================================================================
-- Cliente: Unstructured Docs
-- Caso de Uso: Búsqueda semántica de Constancias de Situación Fiscal (SAT)
-- 
-- Este script configura un entorno completo en Snowflake para:
-- 1. Almacenar documentos PDF de constancias fiscales
-- 2. Extraer texto con OCR automático
-- 3. Realizar búsquedas semánticas con Cortex Search
-- 4. Analizar y clasificar documentos fiscales
--
-- Historia:
-- Las constancias de situación fiscal son documentos oficiales emitidos por
-- el SAT (México) que certifican la situación tributaria de los contribuyentes.
-- Este demo muestra cómo Snowflake puede indexar, buscar y analizar estos
-- documentos de forma inteligente usando IA.
-- ============================================================================

-- ============================================================================
-- Sección 1: Configuración de Recursos
-- ============================================================================

-- Configurar contexto
USE ROLE ACCOUNTADMIN;

-- Crear warehouse optimizado para procesamiento de documentos
CREATE OR REPLACE WAREHOUSE UNSTRUCTURED_DOCS_WH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse para procesamiento de documentos no estructurados';

-- Crear base de datos
CREATE OR REPLACE DATABASE UNSTRUCTURED_DOCS_DB
    COMMENT = 'Base de datos para gestión de documentos fiscales';

-- Crear esquema principal
CREATE OR REPLACE SCHEMA UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT
    COMMENT = 'Esquema para constancias de situación fiscal';

-- Usar el warehouse y esquema
USE WAREHOUSE UNSTRUCTURED_DOCS_WH;
USE SCHEMA UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT;

-- Crear formato de archivo para PDFs
CREATE OR REPLACE FILE FORMAT UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.PDF_FORMAT
    TYPE = 'CSV'
    RECORD_DELIMITER = NONE
    FIELD_DELIMITER = NONE;

-- Crear stage interno para almacenar PDFs
CREATE OR REPLACE STAGE UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_STAGE
    FILE_FORMAT = UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.PDF_FORMAT
    COMMENT = 'Stage para constancias de situación fiscal en PDF';

-- Crear tabla para metadatos y contenido de documentos
CREATE OR REPLACE TABLE UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES (
    ID NUMBER AUTOINCREMENT PRIMARY KEY,
    NOMBRE_ARCHIVO VARCHAR(500),
    RFC VARCHAR(13),
    NOMBRE_CONTRIBUYENTE VARCHAR(500),
    TIPO_PERSONA VARCHAR(50),
    REGIMEN_FISCAL VARCHAR(200),
    ESTADO VARCHAR(100),
    MUNICIPIO VARCHAR(100),
    FECHA_CARGA TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    ARCHIVO_PDF BINARY,
    TEXTO_EXTRAIDO VARCHAR,
    METADATA VARIANT,
    EMBEDDINGS_GENERADOS BOOLEAN DEFAULT FALSE,
    COMMENT = 'Tabla principal de constancias fiscales con contenido binario y texto'
);

-- Crear tabla para resultados de extracción de texto
CREATE OR REPLACE TABLE UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TEXTO_DOCUMENTOS (
    ID NUMBER AUTOINCREMENT PRIMARY KEY,
    CONSTANCIA_ID NUMBER,
    TEXTO_COMPLETO VARCHAR,
    SECCION VARCHAR(100),
    PAGINA NUMBER,
    CONFIDENCE_SCORE FLOAT,
    FECHA_EXTRACCION TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (CONSTANCIA_ID) REFERENCES UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES(ID)
);

-- Crear tabla para almacenar chunks de texto para búsqueda semántica
CREATE OR REPLACE TABLE UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CHUNKS_BUSQUEDA (
    ID NUMBER AUTOINCREMENT PRIMARY KEY,
    CONSTANCIA_ID NUMBER,
    CHUNK_TEXT VARCHAR,
    CHUNK_ORDER NUMBER,
    METADATA VARIANT,
    FOREIGN KEY (CONSTANCIA_ID) REFERENCES UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES(ID)
);

-- Crear vista para análisis rápido
CREATE OR REPLACE VIEW UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.VW_RESUMEN_CONSTANCIAS AS
SELECT 
    TIPO_PERSONA,
    ESTADO,
    REGIMEN_FISCAL,
    COUNT(*) AS TOTAL_CONSTANCIAS,
    COUNT(CASE WHEN EMBEDDINGS_GENERADOS = TRUE THEN 1 END) AS CON_EMBEDDINGS,
    MIN(FECHA_CARGA) AS PRIMERA_CARGA,
    MAX(FECHA_CARGA) AS ULTIMA_CARGA
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES
GROUP BY TIPO_PERSONA, ESTADO, REGIMEN_FISCAL;

-- ============================================================================
-- Sección 2: Carga de Datos (Instrucciones)
-- ============================================================================

-- PASO 1: Cargar PDFs al stage desde tu máquina local
-- Ejecutar desde SnowSQL o la interfaz web:
-- 
-- PUT file:///ruta/completa/a/output/pdfs/*.pdf @UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_STAGE AUTO_COMPRESS=FALSE;
--
-- Ejemplo en tu caso:
-- PUT file:///Users/gjimenez/Documents/GitHub/Unstructured%20Documents/output/pdfs/*.pdf @CONSTANCIAS_STAGE AUTO_COMPRESS=FALSE;

-- PASO 2: Verificar archivos cargados
LIST @UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_STAGE;

-- PASO 3: Insertar datos sintéticos de las 13 constancias
-- (Ejecutar después de cargar los PDFs al stage)

INSERT INTO UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES 
    (NOMBRE_ARCHIVO, RFC, NOMBRE_CONTRIBUYENTE, TIPO_PERSONA, REGIMEN_FISCAL, ESTADO, MUNICIPIO, METADATA)
VALUES
    ('CSF_01_TAS180523KL8.pdf', 'TAS180523KL8', 'TECNOLOGÍA AVANZADA DEL SURESTE SA DE CV', 'Persona Moral', 
     '601 - General de Ley Personas Morales', 'Yucatán', 'Mérida', 
     PARSE_JSON('{"curp": null, "fecha_inicio": "2018-05-23", "cp": "97000"}')),
    
    ('CSF_02_HESM850614J39.pdf', 'HESM850614J39', 'MARÍA GUADALUPE HERNÁNDEZ SÁNCHEZ', 'Persona Física',
     '612 - Personas Físicas con Actividades Empresariales y Profesionales', 'Jalisco', 'Guadalajara',
     PARSE_JSON('{"curp": "HESM850614MDFRNR09", "fecha_inicio": "2010-03-15", "cp": "44160"}')),
    
    ('CSF_03_CAN200815RT6.pdf', 'CAN200815RT6', 'COMERCIALIZADORA DE ALIMENTOS DEL NORTE SA DE CV', 'Persona Moral',
     '601 - General de Ley Personas Morales', 'Nuevo León', 'Monterrey',
     PARSE_JSON('{"curp": null, "fecha_inicio": "2020-08-15", "cp": "66260"}')),
    
    ('CSF_04_GALR920327HG5.pdf', 'GALR920327HG5', 'JOSÉ ROBERTO GARCÍA LÓPEZ', 'Persona Física',
     '626 - Régimen Simplificado de Confianza', 'Ciudad de México', 'Benito Juárez',
     PARSE_JSON('{"curp": "GALR920327HDFRPS06", "fecha_inicio": "2022-01-01", "cp": "03100"}')),
    
    ('CSF_05_CIB150309MN2.pdf', 'CIB150309MN2', 'CONSTRUCTORA INDUSTRIAL BAJÍO SA DE CV', 'Persona Moral',
     '601 - General de Ley Personas Morales', 'Guanajuato', 'León',
     PARSE_JSON('{"curp": null, "fecha_inicio": "2015-03-09", "cp": "37290"}')),
    
    ('CSF_06_MARA881205QT7.pdf', 'MARA881205QT7', 'ANA PATRICIA MARTÍNEZ RODRÍGUEZ', 'Persona Física',
     '605 - Sueldos y Salarios e Ingresos Asimilados a Salarios', 'Puebla', 'Puebla',
     PARSE_JSON('{"curp": "MARA881205MSLRDN02", "fecha_inicio": "2015-06-01", "cp": "72830"}')),
    
    ('CSF_07_SLP190722BC4.pdf', 'SLP190722BC4', 'SERVICIOS LOGÍSTICOS DEL PACÍFICO SA DE CV', 'Persona Moral',
     '601 - General de Ley Personas Morales', 'Sinaloa', 'Culiacán',
     PARSE_JSON('{"curp": null, "fecha_inicio": "2019-07-22", "cp": "80020"}')),
    
    ('CSF_08_RAFC900518KP9.pdf', 'RAFC900518KP9', 'CARLOS EDUARDO RAMÍREZ FERNÁNDEZ', 'Persona Física',
     '612 - Personas Físicas con Actividades Empresariales y Profesionales', 'Querétaro', 'Querétaro',
     PARSE_JSON('{"curp": "RAFC900518HQTMRR04", "fecha_inicio": "2016-08-10", "cp": "76090"}')),
    
    ('CSF_09_DIC170411XY8.pdf', 'DIC170411XY8', 'DESARROLLOS INMOBILIARIOS CANCÚN SA DE CV', 'Persona Moral',
     '601 - General de Ley Personas Morales', 'Quintana Roo', 'Benito Juárez',
     PARSE_JSON('{"curp": null, "fecha_inicio": "2017-04-11", "cp": "77500"}')),
    
    ('CSF_10_TOML870923FM2.pdf', 'TOML870923FM2', 'LAURA ISABEL TORRES MENDOZA', 'Persona Física',
     '621 - Incorporación Fiscal', 'Veracruz', 'Xalapa',
     PARSE_JSON('{"curp": "TOML870923MCSRND08", "fecha_inicio": "2018-09-01", "cp": "91110"}')),
    
    ('CSF_11_MTO140627GH3.pdf', 'MTO140627GH3', 'MANUFACTURAS TEXTILES DE OCCIDENTE SA DE CV', 'Persona Moral',
     '601 - General de Ley Personas Morales', 'Jalisco', 'Tlaquepaque',
     PARSE_JSON('{"curp": null, "fecha_inicio": "2014-06-27", "cp": "45588"}')),
    
    ('CSF_12_LOCF830712MK6.pdf', 'LOCF830712MK6', 'FERNANDO JAVIER LÓPEZ CASTILLO', 'Persona Física',
     '626 - Régimen Simplificado de Confianza', 'San Luis Potosí', 'San Luis Potosí',
     PARSE_JSON('{"curp": "LOCF830712HSLPSR03", "fecha_inicio": "2022-01-01", "cp": "78269"}')),
    
    ('CSF_13_EAS160105PL9.pdf', 'EAS160105PL9', 'EXPORTADORA AGRÍCOLA DE SONORA SA DE CV', 'Persona Moral',
     '601 - General de Ley Personas Morales', 'Sonora', 'Hermosillo',
     PARSE_JSON('{"curp": null, "fecha_inicio": "2016-01-05", "cp": "83190"}'));

-- ============================================================================
-- Sección 3: La Demo - Cortex Search y Análisis
-- ============================================================================

-- 3.1: Simular extracción de texto con Cortex AI
-- En producción, usarías PARSE_DOCUMENT o similar para extraer texto de PDFs

-- Ejemplo de extracción de texto (simulado)
INSERT INTO UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TEXTO_DOCUMENTOS 
    (CONSTANCIA_ID, TEXTO_COMPLETO, SECCION, PAGINA, CONFIDENCE_SCORE)
SELECT 
    ID,
    'CONSTANCIA DE SITUACIÓN FISCAL. RFC: ' || RFC || 
    '. Nombre: ' || NOMBRE_CONTRIBUYENTE || 
    '. Tipo: ' || TIPO_PERSONA || 
    '. Régimen: ' || REGIMEN_FISCAL || 
    '. Domicilio: ' || MUNICIPIO || ', ' || ESTADO || 
    '. Estatus: ACTIVO. ' ||
    'Obligaciones fiscales vigentes según régimen declarado. ' ||
    'Documento emitido por el Servicio de Administración Tributaria.',
    'DATOS_PRINCIPALES',
    1,
    0.95
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES;

-- 3.2: Crear chunks para búsqueda semántica
INSERT INTO UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CHUNKS_BUSQUEDA 
    (CONSTANCIA_ID, CHUNK_TEXT, CHUNK_ORDER, METADATA)
SELECT 
    cf.ID,
    td.TEXTO_COMPLETO,
    1,
    OBJECT_CONSTRUCT(
        'rfc', cf.RFC,
        'tipo_persona', cf.TIPO_PERSONA,
        'estado', cf.ESTADO,
        'regimen', cf.REGIMEN_FISCAL
    )
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES cf
INNER JOIN UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TEXTO_DOCUMENTOS td 
    ON cf.ID = td.CONSTANCIA_ID;

-- 3.3: Crear servicio de Cortex Search
-- NOTA: Cortex Search requiere Enterprise Edition o superior

CREATE OR REPLACE CORTEX SEARCH SERVICE UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.BUSQUEDA_CONSTANCIAS
ON CHUNK_TEXT
WAREHOUSE = UNSTRUCTURED_DOCS_WH
TARGET_LAG = '1 minute'
AS (
    SELECT 
        ID,
        CONSTANCIA_ID,
        CHUNK_TEXT,
        METADATA
    FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CHUNKS_BUSQUEDA
);

-- 3.4: Búsquedas semánticas de ejemplo

-- Búsqueda 1: Encontrar constancias de empresas del sector logístico
SELECT 
    cf.RFC,
    cf.NOMBRE_CONTRIBUYENTE,
    cf.ESTADO,
    cf.REGIMEN_FISCAL
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES cf
WHERE cf.NOMBRE_CONTRIBUYENTE ILIKE '%logistic%' 
   OR cf.NOMBRE_CONTRIBUYENTE ILIKE '%transporte%'
   OR cf.NOMBRE_CONTRIBUYENTE ILIKE '%distribu%';

-- Búsqueda 2: Personas morales en régimen general
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    ESTADO,
    MUNICIPIO
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES
WHERE TIPO_PERSONA = 'Persona Moral'
  AND REGIMEN_FISCAL LIKE '601%'
ORDER BY ESTADO, NOMBRE_CONTRIBUYENTE;

-- Búsqueda 3: Contribuyentes en el Régimen Simplificado de Confianza (RESICO)
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    ESTADO,
    METADATA:fecha_inicio::VARCHAR AS FECHA_INICIO
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES
WHERE REGIMEN_FISCAL LIKE '626%'
ORDER BY RFC;

-- 3.5: Análisis con Cortex AI - Clasificación y extracción de entidades

-- Clasificar industria/sector basado en nombre
SELECT 
    NOMBRE_CONTRIBUYENTE,
    RFC,
    SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
        NOMBRE_CONTRIBUYENTE,
        ['Tecnología', 'Alimentos', 'Construcción', 'Logística', 
         'Inmobiliario', 'Textil', 'Agricultura', 'Servicios Profesionales', 'Otro']
    ) AS SECTOR_CLASIFICADO
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES
WHERE TIPO_PERSONA = 'Persona Moral'
ORDER BY SECTOR_CLASIFICADO;

-- 3.6: Resumen automático de constancias con Cortex AI
SELECT 
    cf.RFC,
    cf.NOMBRE_CONTRIBUYENTE,
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large',
        CONCAT(
            'Resume en una frase el perfil fiscal del siguiente contribuyente: ',
            td.TEXTO_COMPLETO
        )
    ) AS RESUMEN_IA
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES cf
INNER JOIN UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TEXTO_DOCUMENTOS td 
    ON cf.ID = td.CONSTANCIA_ID
LIMIT 5;

-- 3.7: Búsqueda geográfica - Contribuyentes por región
SELECT 
    ESTADO,
    TIPO_PERSONA,
    COUNT(*) AS TOTAL,
    LISTAGG(DISTINCT LEFT(NOMBRE_CONTRIBUYENTE, 30), ', ') 
        WITHIN GROUP (ORDER BY NOMBRE_CONTRIBUYENTE) AS EJEMPLOS
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES
GROUP BY ESTADO, TIPO_PERSONA
ORDER BY ESTADO, TIPO_PERSONA;

-- ============================================================================
-- Sección 4: Queries de Diagnóstico y Validación
-- ============================================================================

-- 4.1: Verificar carga de datos
SELECT 
    'Constancias cargadas' AS METRICA,
    COUNT(*) AS VALOR
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES
UNION ALL
SELECT 
    'Textos extraídos' AS METRICA,
    COUNT(*) AS VALOR
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TEXTO_DOCUMENTOS
UNION ALL
SELECT 
    'Chunks para búsqueda' AS METRICA,
    COUNT(*) AS VALOR
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CHUNKS_BUSQUEDA;

-- 4.2: Distribución por tipo de persona
SELECT 
    TIPO_PERSONA,
    COUNT(*) AS TOTAL,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS PORCENTAJE
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES
GROUP BY TIPO_PERSONA
ORDER BY TOTAL DESC;

-- 4.3: Distribución por régimen fiscal
SELECT 
    LEFT(REGIMEN_FISCAL, 3) AS CODIGO_REGIMEN,
    REGIMEN_FISCAL,
    COUNT(*) AS TOTAL
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES
GROUP BY LEFT(REGIMEN_FISCAL, 3), REGIMEN_FISCAL
ORDER BY TOTAL DESC;

-- 4.4: Distribución geográfica
SELECT 
    ESTADO,
    COUNT(*) AS TOTAL_CONSTANCIAS,
    COUNT(CASE WHEN TIPO_PERSONA = 'Persona Moral' THEN 1 END) AS PERSONAS_MORALES,
    COUNT(CASE WHEN TIPO_PERSONA = 'Persona Física' THEN 1 END) AS PERSONAS_FISICAS
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES
GROUP BY ESTADO
ORDER BY TOTAL_CONSTANCIAS DESC;

-- 4.5: Validar integridad de datos
SELECT 
    'RFCs nulos' AS VALIDACION,
    COUNT(*) AS CASOS
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES
WHERE RFC IS NULL
UNION ALL
SELECT 
    'Nombres vacíos' AS VALIDACION,
    COUNT(*) AS CASOS
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES
WHERE NOMBRE_CONTRIBUYENTE IS NULL OR NOMBRE_CONTRIBUYENTE = ''
UNION ALL
SELECT 
    'Estados nulos' AS VALIDACION,
    COUNT(*) AS CASOS
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES
WHERE ESTADO IS NULL
UNION ALL
SELECT 
    'Régimen fiscal nulo' AS VALIDACION,
    COUNT(*) AS CASOS
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES
WHERE REGIMEN_FISCAL IS NULL;

-- 4.6: Vista resumen ejecutivo
SELECT * FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.VW_RESUMEN_CONSTANCIAS;

-- 4.7: Verificar parámetros de timeout (FinOps)
SHOW PARAMETERS LIKE 'STATEMENT_TIMEOUT_IN_SECONDS' IN WAREHOUSE UNSTRUCTURED_DOCS_WH;

-- 4.8: Calcular costo estimado de procesamiento
SELECT 
    'Warehouse usado' AS RECURSO,
    'UNSTRUCTURED_DOCS_WH' AS NOMBRE,
    'MEDIUM' AS TAMAÑO,
    '2 créditos/hora' AS COSTO_ESTIMADO
UNION ALL
SELECT 
    'Almacenamiento estimado',
    'CONSTANCIAS_FISCALES',
    CONCAT(ROUND(SUM(LENGTH(NOMBRE_CONTRIBUYENTE) + LENGTH(IFNULL(TEXTO_EXTRAIDO, '')) / 1024.0 / 1024.0), 2), ' MB'),
    'Incluido en plan'
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONSTANCIAS_FISCALES;

-- ============================================================================
-- NOTAS FINALES Y PRÓXIMOS PASOS
-- ============================================================================

-- 1. Cargar los PDFs físicos al stage usando PUT (ver Sección 2)
-- 2. Implementar extracción real de texto con PARSE_DOCUMENT si está disponible
-- 3. Configurar Cortex Search para búsquedas semánticas avanzadas
-- 4. Crear dashboards en Streamlit para visualizar las constancias
-- 5. Implementar validaciones automáticas de RFCs con funciones UDF
-- 6. Agregar auditoría de acceso a documentos sensibles

-- Para más información sobre Cortex Search:
-- https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search

-- ============================================================================
-- *** DOCUMENTO GENERADO PARA FINES DEMOSTRATIVOS ***
-- Cliente: Unstructured Docs
-- Fecha: Octubre 2025
-- ============================================================================



