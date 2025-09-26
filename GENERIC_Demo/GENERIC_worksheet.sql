-- SQL
-- Sección 0: Historia y Caso de Uso
-- Historia: Como equipo de Ingeniería de IA en México, necesitamos habilitar una demo genérica que combine datos estructurados y no estructurados dentro de Snowflake. El objetivo es mostrar cómo Cortex Search y Cortex Analyst responden preguntas de negocio sobre ventas y soporte, mientras un panel FinOps monitorea el costo del uso de modelos LLM.

-- Sección 1: Configuración de Recursos
-- CONFIG: Seleccionar rol y warehouse base
USE ROLE SYSADMIN;
CREATE OR REPLACE WAREHOUSE GENERIC_WH WITH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  INITIALLY_SUSPENDED = TRUE
  AUTO_RESUME = TRUE;
USE WAREHOUSE GENERIC_WH;

-- CONFIG: Crear base de datos y esquemas dedicados a la demo
CREATE OR REPLACE DATABASE GENERIC_DB;
CREATE OR REPLACE SCHEMA GENERIC_DB.RAW;
CREATE OR REPLACE SCHEMA GENERIC_DB.ANALYTICS;
CREATE OR REPLACE SCHEMA GENERIC_DB.CONFIG;

-- CONFIG: Stage para documentación no estructurada (Cortex Search)
CREATE OR REPLACE STAGE GENERIC_DB.RAW.DOCS_STAGE
  DIRECTORY = (ENABLE = TRUE)
  COMMENT = 'Stage genérico para archivos de documentación usada por Cortex Search.';

-- CONFIG: Stage para modelos semánticos de Cortex Analyst
CREATE OR REPLACE STAGE GENERIC_DB.CONFIG.SEMANTIC_STAGE
  DIRECTORY = (ENABLE = TRUE)
  COMMENT = 'Stage genérico con YAML de modelos semánticos para Cortex Analyst.';

-- CONFIG: Tabla con catálogo de modelos LLM permitidos (10 modelos)
CREATE OR REPLACE TABLE GENERIC_DB.CONFIG.ALLOWED_LLM_MODELS AS
SELECT COLUMN1 AS MODEL_NAME
FROM VALUES
  ('claude-3-5-sonnet'),
  ('claude-3-5-haiku'),
  ('mistral-large2'),
  ('reka-flash'),
  ('reka-core'),
  ('llama3.1-405b'),
  ('llama3.1-70b'),
  ('llama3.1-8b'),
  ('nemotron-40b-instruct'),
  ('snowflake-arctic-chat')
  COMMENT 'Catálogo controlado de modelos LLM disponibles para la demo generada.';

-- CONFIG: Tabla de servicios Cortex Search seleccionados
CREATE OR REPLACE TABLE GENERIC_DB.CONFIG.CORTEX_SEARCH_SERVICES (
  SERVICE_NAME STRING,
  DATABASE_NAME STRING,
  SCHEMA_NAME STRING,
  FULL_NAME STRING,
  MAX_RESULTS NUMBER(9,0) DEFAULT 5,
  ACTIVE BOOLEAN DEFAULT TRUE
);

-- CONFIG: Tabla de servicios Cortex Analyst seleccionados
CREATE OR REPLACE TABLE GENERIC_DB.CONFIG.CORTEX_ANALYST_SERVICES (
  SERVICE_NAME STRING,
  DATABASE_NAME STRING,
  SCHEMA_NAME STRING,
  SEMANTIC_FILE STRING,
  ACTIVE BOOLEAN DEFAULT TRUE
);

-- Sección 2: Generación de Datos Sintéticos
-- Datos de ventas B2B y tickets de soporte (mínimo 10,000 filas)
CREATE OR REPLACE TABLE GENERIC_DB.RAW.SALES_SUPPORT_EVENTS AS
SELECT
  ROW_NUMBER() OVER (ORDER BY 1) AS EVENT_ID,
  DATEADD('day', UNIFORM(0, 364, RANDOM()), DATE '2024-01-01') AS EVENT_DATE,
  OBJECT_CONSTRUCT(
    'canal', ARRAY_CONSTRUCT('ecommerce','tienda','mayoreo')[UNIFORM(0,2,RANDOM())],
    'segmento_cliente', ARRAY_CONSTRUCT('retail','industrial','gobierno')[UNIFORM(0,2,RANDOM())],
    'region', ARRAY_CONSTRUCT('CDMX','Monterrey','Guadalajara','Merida')[UNIFORM(0,3,RANDOM())]
  ) AS EVENT_METADATA,
  ROUND(UNIFORM(5000, 150000, RANDOM()), 0) AS MXN_REVENUE,
  ROUND(UNIFORM(0, 1, RANDOM()), 2) AS SUPPORT_HOURS,
  CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'VENTA' ELSE 'SOPORTE' END AS EVENT_TYPE,
  CASE WHEN EVENT_TYPE = 'VENTA'
       THEN CONCAT('Orden generada para cliente ', TO_VARCHAR(UNIFORM(1000, 9999, RANDOM())))
       ELSE CONCAT('Ticket resuelto SLA ', TO_VARCHAR(UNIFORM(1, 72, RANDOM())), ' hrs') END AS EVENT_NOTE
FROM TABLE(GENERATOR(ROWCOUNT => 12000));

-- Vista analítica para consumo rápido en Analyst
CREATE OR REPLACE VIEW GENERIC_DB.ANALYTICS.VW_SALES_SUPPORT AS
SELECT
  EVENT_DATE,
  EVENT_METADATA:canal::STRING AS CANAL,
  EVENT_METADATA:segmento_cliente::STRING AS SEGMENTO,
  EVENT_METADATA:region::STRING AS REGION,
  MXN_REVENUE,
  SUPPORT_HOURS,
  EVENT_TYPE,
  EVENT_NOTE
FROM GENERIC_DB.RAW.SALES_SUPPORT_EVENTS;

-- Sección 3: La Demo
-- CONFIG: Seleccionar modelos y servicios activos para el agente
-- El siguiente bloque consolida la configuración de Search y Analyst con los 10 modelos permitidos. 
SELECT 'Modelos LLM configurados' AS DESCRIPCION, ARRAY_AGG(MODEL_NAME) AS MODELOS
FROM GENERIC_DB.CONFIG.ALLOWED_LLM_MODELS;

-- CONFIG: Instrucciones para crear/actualizar servicios Cortex Search activos
-- Ejemplo genérico (ajustar FULL_NAME a los recursos existentes en la cuenta)
MERGE INTO GENERIC_DB.CONFIG.CORTEX_SEARCH_SERVICES tgt
USING (
  SELECT 'GENERIC_SEARCH_PRODUCTO' AS SERVICE_NAME,
         'GENERIC_DB' AS DATABASE_NAME,
         'RAW' AS SCHEMA_NAME,
         'GENERIC_DB.RAW.GENERIC_SEARCH_PRODUCTO' AS FULL_NAME,
         7 AS MAX_RESULTS,
         TRUE AS ACTIVE
) src
ON tgt.SERVICE_NAME = src.SERVICE_NAME
WHEN MATCHED THEN UPDATE SET
  DATABASE_NAME = src.DATABASE_NAME,
  SCHEMA_NAME = src.SCHEMA_NAME,
  FULL_NAME = src.FULL_NAME,
  MAX_RESULTS = src.MAX_RESULTS,
  ACTIVE = src.ACTIVE
WHEN NOT MATCHED THEN INSERT VALUES (src.SERVICE_NAME, src.DATABASE_NAME, src.SCHEMA_NAME, src.FULL_NAME, src.MAX_RESULTS, src.ACTIVE);

-- CONFIG: Registrar servicios Analyst basados en YAML alojado en el stage
MERGE INTO GENERIC_DB.CONFIG.CORTEX_ANALYST_SERVICES tgt
USING (
  SELECT 'GENERIC_ANALYST_SALES' AS SERVICE_NAME,
         'GENERIC_DB' AS DATABASE_NAME,
         'ANALYTICS' AS SCHEMA_NAME,
         'SEMANTIC_MODELS/ventas_soporte.yaml' AS SEMANTIC_FILE,
         TRUE AS ACTIVE
) src
ON tgt.SERVICE_NAME = src.SERVICE_NAME
WHEN MATCHED THEN UPDATE SET
  DATABASE_NAME = src.DATABASE_NAME,
  SCHEMA_NAME = src.SCHEMA_NAME,
  SEMANTIC_FILE = src.SEMANTIC_FILE,
  ACTIVE = src.ACTIVE
WHEN NOT MATCHED THEN INSERT VALUES (src.SERVICE_NAME, src.DATABASE_NAME, src.SCHEMA_NAME, src.SEMANTIC_FILE, src.ACTIVE);

-- DEMO: Consultar servicios Search activos (usado por la app para tool_resources)
SELECT *
FROM GENERIC_DB.CONFIG.CORTEX_SEARCH_SERVICES
WHERE ACTIVE;

-- DEMO: Consultar servicios Analyst activos (usado por la app para tool_resources)
SELECT *
FROM GENERIC_DB.CONFIG.CORTEX_ANALYST_SERVICES
WHERE ACTIVE;

-- DEMO: Ejemplo de consulta para Analyst sobre vista estructurada
SELECT SEGMENTO, SUM(MXN_REVENUE) AS REVENUE_TOTAL
FROM GENERIC_DB.ANALYTICS.VW_SALES_SUPPORT
GROUP BY SEGMENTO
ORDER BY REVENUE_TOTAL DESC;

-- DEMO: Resumen de volumetría para Search (prepara metadata para enriquecimiento)
SELECT REGION, COUNT(*) AS TOTAL_EVENTOS, SUM(MXN_REVENUE) AS MXN_REVENUE
FROM GENERIC_DB.ANALYTICS.VW_SALES_SUPPORT
WHERE EVENT_TYPE = 'VENTA'
GROUP BY REGION
ORDER BY TOTAL_EVENTOS DESC;

-- FinOps: Panel de costos para vigilar uso de LLM y warehouse
-- CONFIG: Consulta costo de warehouse dedicado a la demo
SELECT
  START_TIME::DATE AS FECHA,
  WAREHOUSE_NAME,
  SUM(CREDITS_USED) AS CREDITS_CONSUMIDOS
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE WAREHOUSE_NAME = 'GENERIC_WH'
  AND START_TIME >= DATEADD('day', -30, CURRENT_TIMESTAMP())
GROUP BY 1,2
ORDER BY 1;

-- CONFIG: Estimación de costos por ejecuciones LLM (si la cuenta tiene habilitada la vista)
SELECT
  QUERY_START_TIME::DATE AS FECHA,
  MODEL_NAME,
  SUM(CREDITS_USED_CLOUD_SERVICES) AS CREDITS_LLM
FROM SNOWFLAKE.ACCOUNT_USAGE.ML_MODEL_USAGE
WHERE MODEL_NAME IN (SELECT MODEL_NAME FROM GENERIC_DB.CONFIG.ALLOWED_LLM_MODELS)
  AND QUERY_START_TIME >= DATEADD('day', -30, CURRENT_TIMESTAMP())
GROUP BY 1,2
ORDER BY 1, CREDITS_LLM DESC;

-- FinOps: Indicador resumido para mostrar en dashboard (últimos 7 días)
SELECT
  'LLM_LAST_7_DAYS' AS METRICA,
  COALESCE(SUM(CREDITS_LLM), 0) AS TOTAL_CREDITOS
FROM (
  SELECT
    QUERY_START_TIME::DATE AS FECHA,
    SUM(CREDITS_USED_CLOUD_SERVICES) AS CREDITS_LLM
  FROM SNOWFLAKE.ACCOUNT_USAGE.ML_MODEL_USAGE
  WHERE MODEL_NAME IN (SELECT MODEL_NAME FROM GENERIC_DB.CONFIG.ALLOWED_LLM_MODELS)
    AND QUERY_START_TIME >= DATEADD('day', -7, CURRENT_TIMESTAMP())
  GROUP BY 1
);



