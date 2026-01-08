-- Sección 0: Historia y Caso de Uso
-- LAPI (Laboratorios Pisa) busca que sus laboratoristas con experiencia en ingeniería de datos puedan optimizar la operación clínica.
-- Este guion muestra cómo medir eficiencia operativa por sucursal, tiempos de entrega de resultados clínicos y consumo de materiales críticos,
-- utilizando Snowflake Cortex Analyst, Cortex Search y métricas FinOps para mantener costos controlados en la nube.

-- Sección 1: Configuración de Recursos
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE ROLE LAPI_ROLE;
GRANT ROLE LAPI_ROLE TO ROLE SYSADMIN;

CREATE OR REPLACE WAREHOUSE LAPI_WH
  WAREHOUSE_SIZE = 'XSMALL'
  INITIALLY_SUSPENDED = TRUE
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'Warehouse para demo LAPI enfocada en eficiencia operativa y consumo de materiales';

GRANT USAGE ON WAREHOUSE LAPI_WH TO ROLE LAPI_ROLE;

CREATE OR REPLACE DATABASE LAPI_DB;
GRANT OWNERSHIP ON DATABASE LAPI_DB TO ROLE LAPI_ROLE REVOKE CURRENT GRANTS;

CREATE OR REPLACE SCHEMA LAPI_DB.RAW;
CREATE OR REPLACE SCHEMA LAPI_DB.ANALYTICS;
GRANT OWNERSHIP ON ALL SCHEMAS IN DATABASE LAPI_DB TO ROLE LAPI_ROLE REVOKE CURRENT GRANTS;

USE DATABASE LAPI_DB;
USE SCHEMA RAW;

CREATE OR REPLACE TABLE DIM_LAB_BRANCH (
  BRANCH_ID STRING PRIMARY KEY,
  BRANCH_NAME STRING,
  CITY STRING,
  STATE STRING,
  SERVICE_MODEL STRING,
  OPEN_DATE DATE
);

CREATE OR REPLACE TABLE DIM_LAB_TEST (
  TEST_ID STRING PRIMARY KEY,
  TEST_NAME STRING,
  TEST_CATEGORY STRING,
  SAMPLE_TYPE STRING,
  NORMAL_RANGE STRING,
  UNIT_COST NUMBER(10,2),
  UNIT_PRICE NUMBER(10,2)
);

CREATE OR REPLACE TABLE DIM_PATIENT (
  PATIENT_ID STRING PRIMARY KEY,
  PATIENT_NAME STRING,
  AGE_RANGE STRING,
  GENDER STRING,
  INSURANCE_TYPE STRING,
  HOME_BRANCH_ID STRING
);

CREATE OR REPLACE TABLE DIM_SUPPLY (
  SUPPLY_ID STRING PRIMARY KEY,
  SUPPLY_NAME STRING,
  SUPPLY_CATEGORY STRING,
  UNIT_OF_MEASURE STRING,
  COST_PER_UNIT NUMBER(10,2),
  SAFETY_STOCK_LEVEL NUMBER(10,2)
);

CREATE OR REPLACE TABLE FACT_TEST_ORDERS (
  ORDER_ID STRING,
  ORDER_DATE DATE,
  BRANCH_ID STRING,
  TEST_ID STRING,
  PATIENT_ID STRING,
  ORDER_CHANNEL STRING,
  PRIORITY_LEVEL STRING,
  RESULT_READY_DATE DATE,
  RESULT_STATUS STRING,
  TURNAROUND_HOURS NUMBER(10,2),
  TOTAL_PRICE NUMBER(10,2)
);

CREATE OR REPLACE TABLE FACT_SUPPLY_USAGE (
  USAGE_ID STRING,
  USAGE_DATE DATE,
  BRANCH_ID STRING,
  TEST_ID STRING,
  SUPPLY_ID STRING,
  QUANTITY_USED NUMBER(10,2),
  COST_INCURRED NUMBER(10,2),
  WASTE_UNITS NUMBER(10,2)
);

CREATE OR REPLACE TABLE LAB_CONTENT (
  DOC_ID STRING,
  TITLE STRING,
  DOC_TYPE STRING,
  DOC_TEXT STRING,
  KEYWORDS ARRAY,
  FINOPS_NOTES STRING
);

COMMENT ON TABLE FACT_TEST_ORDERS IS 'Órdenes de pruebas clínicas con métricas de eficiencia operativa y tiempos de resultado';
COMMENT ON TABLE FACT_SUPPLY_USAGE IS 'Consumo de materiales por prueba y sucursal para monitorear costos y desperdicio';

USE SCHEMA ANALYTICS;

CREATE OR REPLACE VIEW VW_TEST_PERFORMANCE AS
SELECT
  o.ORDER_ID,
  o.ORDER_DATE,
  o.BRANCH_ID,
  b.BRANCH_NAME,
  b.CITY,
  b.STATE,
  o.TEST_ID,
  t.TEST_NAME,
  t.TEST_CATEGORY,
  o.PATIENT_ID,
  p.AGE_RANGE,
  p.GENDER,
  p.INSURANCE_TYPE,
  o.ORDER_CHANNEL,
  o.PRIORITY_LEVEL,
  o.RESULT_READY_DATE,
  o.RESULT_STATUS,
  o.TURNAROUND_HOURS,
  o.TOTAL_PRICE
FROM LAPI_DB.RAW.FACT_TEST_ORDERS o
JOIN LAPI_DB.RAW.DIM_LAB_BRANCH b ON o.BRANCH_ID = b.BRANCH_ID
JOIN LAPI_DB.RAW.DIM_LAB_TEST t ON o.TEST_ID = t.TEST_ID
JOIN LAPI_DB.RAW.DIM_PATIENT p ON o.PATIENT_ID = p.PATIENT_ID;

CREATE OR REPLACE VIEW VW_SUPPLY_MONITOR AS
SELECT
  u.USAGE_ID,
  u.USAGE_DATE,
  u.BRANCH_ID,
  b.BRANCH_NAME,
  u.TEST_ID,
  t.TEST_NAME,
  u.SUPPLY_ID,
  s.SUPPLY_NAME,
  s.SUPPLY_CATEGORY,
  u.QUANTITY_USED,
  u.COST_INCURRED,
  u.WASTE_UNITS,
  s.SAFETY_STOCK_LEVEL,
  (s.SAFETY_STOCK_LEVEL - u.QUANTITY_USED) AS REMAINING_BUFFER
FROM LAPI_DB.RAW.FACT_SUPPLY_USAGE u
JOIN LAPI_DB.RAW.DIM_LAB_BRANCH b ON u.BRANCH_ID = b.BRANCH_ID
JOIN LAPI_DB.RAW.DIM_LAB_TEST t ON u.TEST_ID = t.TEST_ID
JOIN LAPI_DB.RAW.DIM_SUPPLY s ON u.SUPPLY_ID = s.SUPPLY_ID;

CREATE OR REPLACE CORTEX SEARCH SERVICE LAPI_DOCS_SEARCH
ON DOC_TEXT
ATTRIBUTES TITLE, DOC_TYPE, KEYWORDS
WAREHOUSE = LAPI_WH
TARGET_LAG = '1 minute'
AS (
  SELECT
    DOC_ID,
    DOC_TEXT,
    TITLE,
    DOC_TYPE,
    KEYWORDS
  FROM LAPI_DB.RAW.LAB_CONTENT
);

CREATE OR REPLACE STAGE LAPI_DB.ANALYTICS.MODEL_STAGE;
-- Subir YAML con: PUT file://<ruta_local>/lapi_semantic_model.yaml @LAPI_DB.ANALYTICS.MODEL_STAGE AUTO_COMPRESS=FALSE;

GRANT USAGE ON CORTEX SEARCH SERVICE LAPI_DOCS_SEARCH TO ROLE LAPI_ROLE;

-- Sección 2: Generación de Datos Sintéticos
USE SCHEMA RAW;

TRUNCATE TABLE DIM_LAB_BRANCH;
TRUNCATE TABLE DIM_LAB_TEST;
TRUNCATE TABLE DIM_PATIENT;
TRUNCATE TABLE DIM_SUPPLY;
TRUNCATE TABLE FACT_TEST_ORDERS;
TRUNCATE TABLE FACT_SUPPLY_USAGE;
TRUNCATE TABLE LAB_CONTENT;

INSERT INTO DIM_LAB_BRANCH (BRANCH_ID, BRANCH_NAME, CITY, STATE, SERVICE_MODEL, OPEN_DATE)
SELECT * FROM VALUES
  ('LP001', 'LAPI Matriz Guadalajara', 'Guadalajara', 'Jalisco', 'Hospitalario', '2000-05-10'),
  ('LP002', 'LAPI CDMX Reforma', 'Ciudad de México', 'CDMX', 'Clínica ambulatoria', '2005-09-18'),
  ('LP003', 'LAPI Monterrey San Pedro', 'San Pedro Garza García', 'Nuevo León', 'Corporativo ocupacional', '2010-02-02'),
  ('LP004', 'LAPI Mérida Norte', 'Mérida', 'Yucatán', 'Clínica ambulatoria', '2015-07-21'),
  ('LP005', 'LAPI Tijuana Zona Río', 'Tijuana', 'Baja California', 'Hospitalario', '2017-11-14'),
  ('LP006', 'LAPI Querétaro Centro', 'Querétaro', 'Querétaro', 'Clínica ambulatoria', '2019-03-07');

INSERT INTO DIM_LAB_TEST (TEST_ID, TEST_NAME, TEST_CATEGORY, SAMPLE_TYPE, NORMAL_RANGE, UNIT_COST, UNIT_PRICE)
SELECT COLUMN1, COLUMN2, COLUMN3, COLUMN4, COLUMN5, COLUMN6::NUMBER(10,2), COLUMN7::NUMBER(10,2)
FROM VALUES
  ('LT001', 'Biometría Hemática', 'Hematología', 'Sangre', '4.0-10.0 K/µL', 70, 180),
  ('LT002', 'Química Sanguínea 35', 'Bioquímica', 'Sangre', 'Ver panel', 120, 320),
  ('LT003', 'Perfil de Tiroides', 'Endocrinología', 'Sangre', 'TSH 0.4-4.0 µIU/mL', 95, 260),
  ('LT004', 'Prueba PCR SARS-CoV-2', 'Microbiología', 'Hisopo nasofaríngeo', 'Negativo', 110, 450),
  ('LT005', 'Cultivo de Orina', 'Microbiología', 'Orina', 'Sin crecimiento', 80, 220),
  ('LT006', 'Panel Toxicológico 10', 'Toxicología', 'Orina', 'Negativo', 150, 380),
  ('LT007', 'Hemoglobina Glicosilada', 'Endocrinología', 'Sangre', '4.0-5.6 %', 60, 210),
  ('LT008', 'Perfil Lipídico', 'Cardiometabolismo', 'Sangre', 'COL < 200 mg/dL', 82, 240);

INSERT INTO DIM_PATIENT (PATIENT_ID, PATIENT_NAME, AGE_RANGE, GENDER, INSURANCE_TYPE, HOME_BRANCH_ID)
SELECT
  CONCAT('PT', LPAD(ROW_NUMBER() OVER (ORDER BY seq)::STRING, 5, '0')),
  CONCAT('Paciente ', ROW_NUMBER() OVER (ORDER BY seq)),
  ARRAY_CONSTRUCT('0-12','13-25','26-40','41-55','56-70','71+') [FLOOR(UNIFORM(0,6,RANDOM()))]::STRING,
  ARRAY_CONSTRUCT('F','M') [FLOOR(UNIFORM(0,2,RANDOM()))]::STRING,
  ARRAY_CONSTRUCT('Privado','Seguro social','Convenio empresarial','Sin seguro') [FLOOR(UNIFORM(0,4,RANDOM()))]::STRING,
  ARRAY_CONSTRUCT('LP001','LP002','LP003','LP004','LP005','LP006') [FLOOR(UNIFORM(0,6,RANDOM()))]::STRING
FROM (
  SELECT SEQ4() AS seq
  FROM TABLE(GENERATOR(ROWCOUNT => 1500))
);

INSERT INTO DIM_SUPPLY (SUPPLY_ID, SUPPLY_NAME, SUPPLY_CATEGORY, UNIT_OF_MEASURE, COST_PER_UNIT, SAFETY_STOCK_LEVEL)
SELECT COLUMN1, COLUMN2, COLUMN3, COLUMN4, COLUMN5::NUMBER(10,2), COLUMN6::NUMBER(10,2)
FROM VALUES
  ('SP001', 'Hisopos nasofaríngeos', 'Recolección', 'Pieza', 3.50, 500),
  ('SP002', 'Reactivo PCR Master Mix', 'Reactivos', 'mL', 8.20, 1200),
  ('SP003', 'Tubos vacutainer EDTA', 'Consumibles', 'Pieza', 2.10, 1500),
  ('SP004', 'Guantes nitrilo talla M', 'Protección personal', 'Par', 1.85, 2000),
  ('SP005', 'Cartuchos analizador hematología', 'Reactivos', 'Cartucho', 25.00, 300),
  ('SP006', 'Panel toxicológico rápido', 'Test rápido', 'Pieza', 12.00, 400),
  ('SP007', 'Gas CO2 cilindro', 'Gases médicos', 'm3', 45.00, 50),
  ('SP008', 'Bata desechable', 'Protección personal', 'Pieza', 4.20, 1000);

INSERT INTO FACT_TEST_ORDERS (
  ORDER_ID,
  ORDER_DATE,
  BRANCH_ID,
  TEST_ID,
  PATIENT_ID,
  ORDER_CHANNEL,
  PRIORITY_LEVEL,
  RESULT_READY_DATE,
  RESULT_STATUS,
  TURNAROUND_HOURS,
  TOTAL_PRICE
)
WITH test_seed AS (
  SELECT ROW_NUMBER() OVER (ORDER BY seq) AS rn
  FROM (
    SELECT SEQ4() AS seq
    FROM TABLE(GENERATOR(ROWCOUNT => 9000))
  ) base
),
randomized AS (
  SELECT
    CONCAT('ORD', LPAD(rn::STRING, 6, '0')) AS order_id,
    DATEADD('day', -FLOOR(UNIFORM(0, 90, RANDOM())), CURRENT_DATE()) AS order_date,
    branch_choice.branch_id,
    test_choice.test_id,
    test_choice.unit_price,
    patient_choice.patient_id,
    channel_choice.order_channel,
    priority_choice.priority_level,
    FLOOR(UNIFORM(1, 72, RANDOM())) AS turnaround_hours,
    ARRAY_CONSTRUCT('COMPLETO','EN PROCESO','REQUIERE REPETIR')[FLOOR(UNIFORM(0,3,RANDOM()))]::STRING AS result_status
  FROM test_seed
  JOIN LATERAL (
    SELECT BRANCH_ID FROM DIM_LAB_BRANCH ORDER BY RANDOM() LIMIT 1
  ) branch_choice ON TRUE
  JOIN LATERAL (
    SELECT TEST_ID, UNIT_PRICE FROM DIM_LAB_TEST ORDER BY RANDOM() LIMIT 1
  ) test_choice ON TRUE
  JOIN LATERAL (
    SELECT PATIENT_ID FROM DIM_PATIENT ORDER BY RANDOM() LIMIT 1
  ) patient_choice ON TRUE
  JOIN LATERAL (
    SELECT ARRAY_CONSTRUCT('Sucursal','Portal empresas','App LAPI','Toma domicilio','Hospital aliado','Convenio aseguradora')[FLOOR(UNIFORM(0,6,RANDOM()))]::STRING AS ORDER_CHANNEL
  ) channel_choice ON TRUE
  JOIN LATERAL (
    SELECT ARRAY_CONSTRUCT('Alta','Media','Baja')[FLOOR(UNIFORM(0,3,RANDOM()))]::STRING AS PRIORITY_LEVEL
  ) priority_choice ON TRUE
)
SELECT
  order_id,
  order_date,
  branch_id,
  test_id,
  patient_id,
  order_channel,
  priority_level,
  DATEADD('hour', turnaround_hours, order_date) AS result_ready_date,
  result_status,
  turnaround_hours,
  unit_price AS total_price
FROM randomized;

INSERT INTO FACT_SUPPLY_USAGE (
  USAGE_ID,
  USAGE_DATE,
  BRANCH_ID,
  TEST_ID,
  SUPPLY_ID,
  QUANTITY_USED,
  COST_INCURRED,
  WASTE_UNITS
)
WITH branch_map AS (
  SELECT BRANCH_ID, ROW_NUMBER() OVER (ORDER BY BRANCH_ID) - 1 AS idx
  FROM DIM_LAB_BRANCH
),
test_map AS (
  SELECT TEST_ID, ROW_NUMBER() OVER (ORDER BY TEST_ID) - 1 AS idx
  FROM DIM_LAB_TEST
),
supply_map AS (
  SELECT SUPPLY_ID, COST_PER_UNIT, ROW_NUMBER() OVER (ORDER BY SUPPLY_ID) - 1 AS idx
  FROM DIM_SUPPLY
),
constants AS (
  SELECT
    (SELECT COUNT(*) FROM branch_map) AS branch_cnt,
    (SELECT COUNT(*) FROM test_map)   AS test_cnt,
    (SELECT COUNT(*) FROM supply_map) AS supply_cnt
),
seed AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY seq) AS rn,
    ROW_NUMBER() OVER (ORDER BY seq) - 1 AS idx_zero
  FROM (
    SELECT SEQ4() AS seq
    FROM TABLE(GENERATOR(ROWCOUNT => 6000))
  ) g
)
SELECT
  CONCAT('SUP', LPAD(seed.rn::STRING, 6, '0')) AS USAGE_ID,
  DATEADD('day', -MOD(seed.idx_zero, 90), CURRENT_DATE()) AS USAGE_DATE,
  branch_map.BRANCH_ID,
  test_map.TEST_ID,
  supply_map.SUPPLY_ID,
  10 + MOD(seed.idx_zero, 16) AS QUANTITY_USED,
  ROUND((10 + MOD(seed.idx_zero, 16)) * supply_map.COST_PER_UNIT, 2) AS COST_INCURRED,
  ROUND((10 + MOD(seed.idx_zero, 16)) * (0.02 + (MOD(seed.idx_zero, 5) * 0.01)), 2) AS WASTE_UNITS
FROM seed
CROSS JOIN constants
JOIN branch_map ON branch_map.idx = MOD(seed.idx_zero, constants.branch_cnt)
JOIN test_map   ON test_map.idx   = MOD(seed.idx_zero + 3, constants.test_cnt)
JOIN supply_map ON supply_map.idx = MOD(seed.idx_zero + 5, constants.supply_cnt);

INSERT INTO LAB_CONTENT (DOC_ID, TITLE, DOC_TYPE, DOC_TEXT, KEYWORDS, FINOPS_NOTES)
SELECT
  DOC_ID,
  TITLE,
  DOC_TYPE,
  DOC_TEXT,
  ARRAY_CONSTRUCT(KEYWORD_1, KEYWORD_2, KEYWORD_3),
  FINOPS_NOTES
FROM (
  SELECT 'DOC001' AS DOC_ID, 'Protocolo Biometria Hematica LP001' AS TITLE, 'Procedimiento' AS DOC_TYPE,
         'Detalle paso a paso de preparacion de muestra, calibracion y entrega de resultados en LP001.' AS DOC_TEXT,
         'hematologia' AS KEYWORD_1, 'calibracion' AS KEYWORD_2, 'tiempo_entrega' AS KEYWORD_3,
         'Validar creditos diarios de LAPI_WH, objetivo < 45 creditos.' AS FINOPS_NOTES
  UNION ALL
  SELECT 'DOC002', 'Checklist Cadena Fria PCR', 'Checklist',
         'Requisitos de logistica en cadena fria para reactivos PCR y almacenamiento temporal.',
         'PCR', 'cadena_fria', 'logistica',
         'Programar warehouse a auto-suspend 60 seg en procesamiento masivo.'
  UNION ALL
  SELECT 'DOC003', 'Plan FinOps Materiales Reactivos', 'Reporte',
         'Resumen de consumo vs presupuesto mensual de reactivos criticos.',
         'finops', 'reactivos', 'consumo',
         'Auditar wastage semanalmente; objetivo desperdicio < 7%.'
) data;

-- Sección 3: La Demo
USE SCHEMA ANALYTICS;

-- 3.1 Eficiencia operativa: Tiempo promedio de entrega por sucursal y tipo de prueba
SELECT
  b.BRANCH_NAME,
  t.TEST_CATEGORY,
  DATE_TRUNC('week', o.ORDER_DATE) AS semana,
  AVG(o.TURNAROUND_HOURS) AS horas_promedio,
  COUNT(*) AS pruebas_realizadas
FROM VW_TEST_PERFORMANCE o
JOIN LAPI_DB.RAW.DIM_LAB_TEST t ON o.TEST_ID = t.TEST_ID
JOIN LAPI_DB.RAW.DIM_LAB_BRANCH b ON o.BRANCH_ID = b.BRANCH_ID
WHERE o.RESULT_STATUS = 'COMPLETO'
GROUP BY b.BRANCH_NAME, t.TEST_CATEGORY, DATE_TRUNC('week', o.ORDER_DATE)
ORDER BY horas_promedio ASC;

-- 3.2 Resultados clínicos pendientes: Visibilidad por prioridad y canal
SELECT
  o.ORDER_CHANNEL,
  o.PRIORITY_LEVEL,
  COUNT(*) AS pruebas_pendientes,
  AVG(o.TURNAROUND_HOURS) AS horas_promedio
FROM VW_TEST_PERFORMANCE o
WHERE o.RESULT_STATUS <> 'COMPLETO'
GROUP BY o.ORDER_CHANNEL, o.PRIORITY_LEVEL
ORDER BY pruebas_pendientes DESC;

-- 3.3 Consumo de materiales vs stock de seguridad
SELECT
  s.SUPPLY_NAME,
  b.BRANCH_NAME,
  DATE_TRUNC('week', u.USAGE_DATE) AS semana,
  SUM(u.QUANTITY_USED) AS unidades_consumidas,
  SUM(u.WASTE_UNITS) AS desperdicio,
  AVG(u.REMAINING_BUFFER) AS buffer_promedio
FROM VW_SUPPLY_MONITOR u
JOIN LAPI_DB.RAW.DIM_SUPPLY s ON u.SUPPLY_ID = s.SUPPLY_ID
JOIN LAPI_DB.RAW.DIM_LAB_BRANCH b ON u.BRANCH_ID = b.BRANCH_ID
GROUP BY s.SUPPLY_NAME, b.BRANCH_NAME, DATE_TRUNC('week', u.USAGE_DATE)
ORDER BY desperdicio DESC;

-- 3.4 FinOps: crédito estimado por hora del warehouse
SELECT
  DATE_TRUNC('hour', START_TIME) AS hora,
  SUM(CREDITS_USED_CLOUD_SERVICES) AS creditos_usados
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE WAREHOUSE_NAME = 'LAPI_WH'
  AND START_TIME >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY DATE_TRUNC('hour', START_TIME)
ORDER BY hora DESC;

-- 3.5 Cortex Analyst demo (tras crear modelo desde YAML)
-- CALL CORTEX.ANALYST.ASK(
--   'LAPI_ANALYST_MODEL',
--   '¿Qué sucursales tuvieron mayor desperdicio de materiales en pruebas PCR en la última semana?'
-- );

-- 3.6 Cortex Search demo
SELECT
  result.*
FROM TABLE(
  CORTEX.SEARCH('LAPI_DOCS_SEARCH', 'protocolo entrega resultados hematologia')
) AS result
LIMIT 5;
