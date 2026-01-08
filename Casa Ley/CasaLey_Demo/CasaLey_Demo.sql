CREATE OR REPLACE STAGE CASALEY_DB.ANALYTICS.MODEL_STAGE;
-- Ejecutar PUT desde SnowSQL o Snowsight con Client Uploader para subir casaley_semantic_model.yaml al stage:
-- PUT file://<ruta_local>/casaley_semantic_model.yaml @CASALEY_DB.ANALYTICS.MODEL_STAGE AUTO_COMPRESS=FALSE;
-- Sección 0: Historia y Caso de Uso
-- Casa Ley, cadena mexicana de autoservicio, busca acelerar promociones personalizadas y eficiencia de inventarios para su 70 aniversario.
-- Esta demo muestra cómo Snowflake Cortex Analyst y Cortex Search permiten a un Category Manager con experiencia en data engineering medir
-- la respuesta de clientes a promociones omnicanal y anticiparse a quiebres de stock usando datos sintéticos realistas.

-- Sección 1: Configuración de Recursos
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE ROLE CASALEY_ROLE;
GRANT ROLE CASALEY_ROLE TO ROLE SYSADMIN;

CREATE OR REPLACE WAREHOUSE CASALEY_WH
  WAREHOUSE_SIZE = 'XSMALL'
  INITIALLY_SUSPENDED = TRUE
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'Warehouse optimizado para demo de Casa Ley con foco en promociones e inventario';

GRANT USAGE ON WAREHOUSE CASALEY_WH TO ROLE CASALEY_ROLE;

CREATE OR REPLACE DATABASE CASALEY_DB;
GRANT OWNERSHIP ON DATABASE CASALEY_DB TO ROLE CASALEY_ROLE REVOKE CURRENT GRANTS;

CREATE OR REPLACE SCHEMA CASALEY_DB.RAW;
CREATE OR REPLACE SCHEMA CASALEY_DB.ANALYTICS;
GRANT OWNERSHIP ON ALL SCHEMAS IN DATABASE CASALEY_DB TO ROLE CASALEY_ROLE REVOKE CURRENT GRANTS;

USE DATABASE CASALEY_DB;
USE SCHEMA RAW;

CREATE OR REPLACE TABLE DIM_STORE (
  STORE_ID STRING PRIMARY KEY,
  STORE_NAME STRING,
  CITY STRING,
  STATE STRING,
  STORE_FORMAT STRING,
  OPEN_DATE DATE
);

CREATE OR REPLACE TABLE DIM_PRODUCT (
  PRODUCT_ID STRING PRIMARY KEY,
  PRODUCT_NAME STRING,
  CATEGORY STRING,
  SUBCATEGORY STRING,
  BRAND STRING,
  UNIT_COST NUMBER(10,2),
  UNIT_PRICE NUMBER(10,2),
  SHELF_LIFE_DAYS NUMBER(3)
);

CREATE OR REPLACE TABLE DIM_CUSTOMER (
  CUSTOMER_ID STRING PRIMARY KEY,
  CUSTOMER_NAME STRING,
  GENDER STRING,
  AGE_RANGE STRING,
  SEGMENT STRING,
  LOYALTY_TIER STRING,
  HOME_STORE_ID STRING,
  EMAIL STRING
);

CREATE OR REPLACE TABLE DIM_PROMOTION (
  PROMO_ID STRING PRIMARY KEY,
  PROMO_NAME STRING,
  PROMO_TYPE STRING,
  START_DATE DATE,
  END_DATE DATE,
  DISCOUNT_PCT NUMBER(5,2),
  TARGET_SEGMENTS ARRAY,
  CHANNELS ARRAY,
  BUDGET_MXN NUMBER(12,2)
);

CREATE OR REPLACE TABLE FACT_PROMO_TRANSACTIONS (
  TRANSACTION_ID STRING,
  TX_DATE DATE,
  STORE_ID STRING,
  PRODUCT_ID STRING,
  CUSTOMER_ID STRING,
  PROMO_ID STRING,
  QUANTITY NUMBER(6,0),
  GROSS_REVENUE NUMBER(12,2),
  DISCOUNT_VALUE NUMBER(12,2),
  NET_REVENUE NUMBER(12,2),
  CHANNEL STRING,
  MARGIN NUMBER(12,2)
);

CREATE OR REPLACE TABLE FACT_INVENTORY_DAILY (
  INVENTORY_DATE DATE,
  STORE_ID STRING,
  PRODUCT_ID STRING,
  ON_HAND_UNITS NUMBER(8,0),
  SAFETY_STOCK NUMBER(8,0),
  FORECAST_DEMAND NUMBER(8,0),
  REPLENISHMENT_ORDER_UNITS NUMBER(8,0)
);

CREATE OR REPLACE TABLE PROMO_CONTENT (
  PROMO_ID STRING,
  PROMO_TITLE STRING,
  TARGET_SEGMENTS ARRAY,
  PROMO_DESCRIPTION STRING,
  FINOPS_NOTES STRING
);

COMMENT ON TABLE FACT_PROMO_TRANSACTIONS IS 'Transacciones de promociones personalizadas enfocadas en respuesta de clientes y margen';
COMMENT ON TABLE FACT_INVENTORY_DAILY IS 'Inventario diario para monitorear eficiencia de stock por tienda y producto';

USE SCHEMA ANALYTICS;

CREATE OR REPLACE VIEW VW_PROMO_PERFORMANCE AS
SELECT
  f.TRANSACTION_ID,
  f.TX_DATE,
  f.STORE_ID,
  s.STORE_NAME,
  s.CITY,
  f.PRODUCT_ID,
  p.PRODUCT_NAME,
  p.CATEGORY,
  p.SUBCATEGORY,
  f.PROMO_ID,
  pr.PROMO_NAME,
  pr.PROMO_TYPE,
  pr.DISCOUNT_PCT,
  pr.TARGET_SEGMENTS,
  f.CUSTOMER_ID,
  c.SEGMENT,
  c.LOYALTY_TIER,
  f.QUANTITY,
  f.GROSS_REVENUE,
  f.DISCOUNT_VALUE,
  f.NET_REVENUE,
  f.MARGIN,
  f.CHANNEL
FROM CASALEY_DB.RAW.FACT_PROMO_TRANSACTIONS f
JOIN CASALEY_DB.RAW.DIM_STORE s ON f.STORE_ID = s.STORE_ID
JOIN CASALEY_DB.RAW.DIM_PRODUCT p ON f.PRODUCT_ID = p.PRODUCT_ID
JOIN CASALEY_DB.RAW.DIM_CUSTOMER c ON f.CUSTOMER_ID = c.CUSTOMER_ID
LEFT JOIN CASALEY_DB.RAW.DIM_PROMOTION pr ON f.PROMO_ID = pr.PROMO_ID;

CREATE OR REPLACE VIEW VW_INVENTORY_RISK AS
SELECT
  i.INVENTORY_DATE,
  i.STORE_ID,
  s.STORE_NAME,
  i.PRODUCT_ID,
  p.PRODUCT_NAME,
  p.CATEGORY,
  p.SUBCATEGORY,
  i.ON_HAND_UNITS,
  i.SAFETY_STOCK,
  i.FORECAST_DEMAND,
  i.REPLENISHMENT_ORDER_UNITS,
  (i.ON_HAND_UNITS - i.FORECAST_DEMAND) AS DELTA_UNITS,
  CASE WHEN i.ON_HAND_UNITS < i.SAFETY_STOCK THEN 'CRITICO'
       WHEN i.ON_HAND_UNITS < i.FORECAST_DEMAND THEN 'VIGILAR'
       ELSE 'ESTABLE' END AS INVENTORY_STATUS
FROM CASALEY_DB.RAW.FACT_INVENTORY_DAILY i
JOIN CASALEY_DB.RAW.DIM_STORE s ON i.STORE_ID = s.STORE_ID
JOIN CASALEY_DB.RAW.DIM_PRODUCT p ON i.PRODUCT_ID = p.PRODUCT_ID;

CREATE OR REPLACE CORTEX SEARCH SERVICE CASALEY_PROMO_SEARCH
ON SEARCH_TEXT
ATTRIBUTES DOCUMENT_ID, PROMO_ID, PROMO_NAME, CATEGORY, SEGMENT, CHANNEL, CITY, PRODUCT_NAME
WAREHOUSE = CASALEY_WH
TARGET_LAG = '1 minute'
AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY f.TX_DATE DESC, f.TRANSACTION_ID) AS DOCUMENT_ID,
    f.PROMO_ID,
    f.PROMO_NAME,
    f.CATEGORY,
    f.SEGMENT,
    f.CHANNEL,
    f.CITY,
    f.PRODUCT_NAME,
    CONCAT_WS(' ',
      COALESCE(f.PROMO_NAME, ''),
      COALESCE(f.CATEGORY, ''),
      COALESCE(f.SEGMENT, ''),
      COALESCE(f.CHANNEL, ''),
      COALESCE(f.CITY, ''),
      COALESCE(f.PRODUCT_NAME, '')
    ) AS SEARCH_TEXT
  FROM VW_PROMO_PERFORMANCE f
);

GRANT USAGE ON CORTEX SEARCH SERVICE CASALEY_PROMO_SEARCH TO ROLE CASALEY_ROLE;
-- Modelo semántico provisto ahora en YAML: ver archivo CasaLey_Demo/casaley_semantic_model.yaml

-- Sección 2: Generación de Datos Sintéticos
USE SCHEMA RAW;

TRUNCATE TABLE DIM_STORE;
TRUNCATE TABLE DIM_PRODUCT;
TRUNCATE TABLE DIM_CUSTOMER;
TRUNCATE TABLE DIM_PROMOTION;
TRUNCATE TABLE FACT_PROMO_TRANSACTIONS;
TRUNCATE TABLE FACT_INVENTORY_DAILY;
TRUNCATE TABLE PROMO_CONTENT;

INSERT INTO DIM_STORE (STORE_ID, STORE_NAME, CITY, STATE, STORE_FORMAT, OPEN_DATE)
SELECT * FROM VALUES
  ('CL001', 'Casa Ley Culiacán Humaya', 'Culiacán', 'Sinaloa', 'Hipermercado', '2001-03-15'),
  ('CL002', 'Casa Ley Mazatlán Marina', 'Mazatlán', 'Sinaloa', 'Supermercado', '2005-07-22'),
  ('CL003', 'Casa Ley Tijuana Río', 'Tijuana', 'Baja California', 'Hipermercado', '2010-09-10'),
  ('CL004', 'Casa Ley Hermosillo Centro', 'Hermosillo', 'Sonora', 'Supermercado', '2012-11-05'),
  ('CL005', 'Casa Ley La Paz Malecon', 'La Paz', 'Baja California Sur', 'Supermercado', '2015-04-08'),
  ('CL006', 'Casa Ley Mexicali Industrial', 'Mexicali', 'Baja California', 'Bodega', '2018-01-12'),
  ('CL007', 'Casa Ley Guasave Centro', 'Guasave', 'Sinaloa', 'Supermercado', '2016-06-30'),
  ('CL008', 'Casa Ley Los Mochis', 'Los Mochis', 'Sinaloa', 'Hipermercado', '2014-02-19');

INSERT INTO DIM_PRODUCT (PRODUCT_ID, PRODUCT_NAME, CATEGORY, SUBCATEGORY, BRAND, UNIT_COST, UNIT_PRICE, SHELF_LIFE_DAYS)
SELECT
  CONCAT('P', LPAD(SEQ4()::STRING, 4, '0')) AS PRODUCT_ID,
  PRODUCT_NAME,
  CATEGORY,
  SUBCATEGORY,
  BRAND,
  UNIT_COST,
  UNIT_PRICE,
  SHELF_LIFE_DAYS
FROM (
  SELECT COLUMN1 AS PRODUCT_NAME, COLUMN2 AS CATEGORY, COLUMN3 AS SUBCATEGORY, COLUMN4 AS BRAND, COLUMN5::NUMBER(10,2) AS UNIT_COST, COLUMN6::NUMBER(10,2) AS UNIT_PRICE, COLUMN7::NUMBER(3,0) AS SHELF_LIFE_DAYS
  FROM VALUES
    ('Leche entera 1L', 'Lácteos', 'Leche', 'Ley Selecto', 12.50, 18.90, 10),
    ('Yogurt natural 500g', 'Lácteos', 'Yogurt', 'Yoplait', 14.80, 24.50, 15),
    ('Queso panela 400g', 'Lácteos', 'Quesos', 'NocheBuena', 48.00, 68.90, 20),
    ('Manzana Gala kg', 'Frutas y Verduras', 'Frutas', 'Ley Origen', 28.00, 45.50, 7),
    ('Aguacate Hass kg', 'Frutas y Verduras', 'Frutas', 'Ley Origen', 40.00, 69.90, 5),
    ('Tomate saladet kg', 'Frutas y Verduras', 'Verduras', 'Ley Origen', 22.00, 36.90, 6),
    ('Carne molida 90/10 kg', 'Carnes frías y frescas', 'Res', 'Ley Carnes', 98.00, 148.90, 4),
    ('Pechuga de pollo kg', 'Carnes frías y frescas', 'Pollo', 'Bachoco', 72.00, 118.50, 5),
    ('Pan blanco 680g', 'Panadería', 'Pan empacado', 'Bimbo', 24.00, 42.90, 12),
    ('Tortilla de maíz kg', 'Panadería', 'Tortillería', 'Ley Tortillería', 12.00, 19.50, 2),
    ('Detergente 1kg', 'Limpieza', 'Detergentes', 'Ariel', 32.00, 58.90, 365),
    ('Suavizante 1L', 'Limpieza', 'Suavizantes', 'Downy', 29.00, 52.90, 365),
    ('Café molido 250g', 'Abarrotes', 'Café', 'Nescafé', 45.00, 79.90, 120),
    ('Atún en agua 140g', 'Abarrotes', 'Enlatados', 'Dolores', 12.00, 22.50, 540),
    ('Aceite vegetal 900ml', 'Abarrotes', 'Aceites', 'Nutrioli', 35.00, 58.50, 365),
    ('Cereal integral 400g', 'Abarrotes', 'Cereales', 'Kellogg''s', 32.00, 54.90, 365),
    ('Refresco cola 2L', 'Bebidas', 'Refrescos', 'Coca-Cola', 18.00, 32.90, 365),
    ('Agua purificada 1.5L', 'Bebidas', 'Agua', 'Ciel', 6.00, 12.90, 365),
    ('Cerveza lager six', 'Bebidas', 'Cerveza', 'Tecate', 60.00, 109.00, 365),
    ('Botana papas 150g', 'Snacks', 'Papas', 'Sabritas', 8.00, 19.90, 180)
);

INSERT INTO DIM_CUSTOMER (CUSTOMER_ID, CUSTOMER_NAME, GENDER, AGE_RANGE, SEGMENT, LOYALTY_TIER, HOME_STORE_ID, EMAIL)
WITH customer_seeds AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY seq) AS rn,
    RANDOM() AS rand_gender,
    FLOOR(UNIFORM(0, 6, RANDOM())) AS idx_age,
    FLOOR(UNIFORM(0, 5, RANDOM())) AS idx_segment,
    FLOOR(UNIFORM(0, 4, RANDOM())) AS idx_tier,
    FLOOR(UNIFORM(0, 8, RANDOM())) AS idx_store
  FROM (
    SELECT SEQ4() AS seq
    FROM TABLE(GENERATOR(ROWCOUNT => 1200))
  ) seeds
)
SELECT
  CONCAT('C', LPAD(rn::STRING, 5, '0')) AS CUSTOMER_ID,
  CONCAT('Cliente ', rn) AS CUSTOMER_NAME,
  CASE WHEN rand_gender < 0.5 THEN 'F' ELSE 'M' END AS GENDER,
  ARRAY_CONSTRUCT('18-25','26-35','36-45','46-55','56-65','65+')[idx_age]::STRING AS AGE_RANGE,
  ARRAY_CONSTRUCT('Familias saludables','Foodies premium','Comprador de ocasión','Mayorista PyME','Conveniencia rápida')[idx_segment]::STRING AS SEGMENT,
  ARRAY_CONSTRUCT('Bronce','Plata','Oro','Platino')[idx_tier]::STRING AS LOYALTY_TIER,
  ARRAY_CONSTRUCT('CL001','CL002','CL003','CL004','CL005','CL006','CL007','CL008')[idx_store]::STRING AS HOME_STORE_ID,
  CONCAT('cliente', rn, '@casaley-email.mx') AS EMAIL
FROM customer_seeds;

INSERT INTO DIM_PROMOTION (PROMO_ID, PROMO_NAME, PROMO_TYPE, START_DATE, END_DATE, DISCOUNT_PCT, TARGET_SEGMENTS, CHANNELS, BUDGET_MXN)
WITH promo_seeds AS (
  SELECT ROW_NUMBER() OVER (ORDER BY seq) AS rn
  FROM (
    SELECT SEQ4() AS seq
    FROM TABLE(GENERATOR(ROWCOUNT => 50))
  ) base
)
SELECT
  CONCAT('PR', LPAD(rn::STRING, 3, '0')) AS PROMO_ID,
  ARRAY_CONSTRUCT('Combo saludable Ley','Días Dorados de Cerveza','Canasta Básica Ahorro','Desayunos Express','Noches Parrilleras','Fines de Semana Frescos','Back to School Snacks','Ahorro Mayorista PyME','Promoción Vive Sano','Aniversario Casa Ley')[FLOOR(UNIFORM(0, 10, RANDOM()))]::STRING || ' ' || TO_CHAR(CURRENT_DATE(), 'YYYY') AS PROMO_NAME,
  ARRAY_CONSTRUCT('Descuento directo','Bonificación monedero','2x1','Combo personalizado','Cupon digital')[FLOOR(UNIFORM(0, 5, RANDOM()))]::STRING AS PROMO_TYPE,
  DATEADD('day', FLOOR(UNIFORM(-14, 1, RANDOM())), CURRENT_DATE()) AS START_DATE,
  DATEADD('day', FLOOR(UNIFORM(7, 31, RANDOM())), CURRENT_DATE()) AS END_DATE,
  ROUND(UNIFORM(5, 30, RANDOM())::NUMBER(5,2), 2) AS DISCOUNT_PCT,
  ARRAY_CONSTRUCT('Familias saludables','Foodies premium','Comprador de ocasión','Mayorista PyME','Conveniencia rápida') AS TARGET_SEGMENTS,
  ARRAY_CONSTRUCT('Sucursal','E-commerce','App Privilegia','WhatsApp') AS CHANNELS,
  ROUND(UNIFORM(150000, 500000, RANDOM()), 2) AS BUDGET_MXN
FROM promo_seeds;

INSERT INTO PROMO_CONTENT (PROMO_ID, PROMO_TITLE, TARGET_SEGMENTS, PROMO_DESCRIPTION, FINOPS_NOTES)
SELECT
  p.PROMO_ID,
  p.PROMO_NAME,
  p.TARGET_SEGMENTS,
  CONCAT('Promoción ', p.PROMO_TYPE, ' enfocada en necesidades clave. Prioridad en ', COALESCE(ARRAY_TO_STRING(ARRAY_SLICE(p.CHANNELS,0,2), ', '), 'canales principales'), '.') AS PROMO_DESCRIPTION,
  'Monitorear costo por ticket a través de warehouse CASALEY_WH con créditos diarios limitados a 50.'
FROM DIM_PROMOTION p;

INSERT INTO FACT_PROMO_TRANSACTIONS
WITH seeds AS (
  SELECT ROW_NUMBER() OVER (ORDER BY seq) AS rn
  FROM (
    SELECT SEQ4() AS seq
    FROM TABLE(GENERATOR(ROWCOUNT => 7000))
  ) raw
),
base AS (
  SELECT
    CONCAT('TX', LPAD(rn::STRING, 6, '0')) AS TRANSACTION_ID,
    DATEADD('day', -FLOOR(UNIFORM(0, 61, RANDOM())), CURRENT_DATE()) AS TX_DATE,
    store_choice.STORE_ID,
    product_choice.PRODUCT_ID,
    product_choice.UNIT_COST,
    product_choice.UNIT_PRICE,
    customer_choice.CUSTOMER_ID,
    promo_choice.PROMO_ID,
    promo_choice.DISCOUNT_PCT,
    channel_choice.CHANNEL,
    GREATEST(1, ROUND(NORMAL(2, 1.2, RANDOM()))) AS QUANTITY
  FROM seeds
  JOIN LATERAL (
    SELECT ARRAY_CONSTRUCT('CL001','CL002','CL003','CL004','CL005','CL006','CL007','CL008')[FLOOR(UNIFORM(0, 8, RANDOM()))]::STRING AS STORE_ID) store_choice ON TRUE
  JOIN LATERAL (
    SELECT PRODUCT_ID, UNIT_COST, UNIT_PRICE FROM DIM_PRODUCT ORDER BY RANDOM() LIMIT 1) product_choice ON TRUE
  JOIN LATERAL (
    SELECT CUSTOMER_ID FROM DIM_CUSTOMER ORDER BY RANDOM() LIMIT 1) customer_choice ON TRUE
  JOIN LATERAL (
    SELECT PROMO_ID, DISCOUNT_PCT FROM DIM_PROMOTION ORDER BY RANDOM() LIMIT 1) promo_choice ON TRUE
  JOIN LATERAL (
    SELECT ARRAY_CONSTRUCT('Sucursal','E-commerce','App Privilegia','WhatsApp')[FLOOR(UNIFORM(0, 4, RANDOM()))]::STRING AS CHANNEL) channel_choice ON TRUE
)
SELECT
  TRANSACTION_ID,
  TX_DATE,
  STORE_ID,
  PRODUCT_ID,
  CUSTOMER_ID,
  PROMO_ID,
  QUANTITY,
  ROUND(QUANTITY * UNIT_PRICE, 2) AS GROSS_REVENUE,
  ROUND((QUANTITY * UNIT_PRICE) * (DISCOUNT_PCT / 100), 2) AS DISCOUNT_VALUE,
  ROUND((QUANTITY * UNIT_PRICE) - ((QUANTITY * UNIT_PRICE) * (DISCOUNT_PCT / 100)), 2) AS NET_REVENUE,
  CHANNEL,
  ROUND(((QUANTITY * UNIT_PRICE) - ((QUANTITY * UNIT_PRICE) * (DISCOUNT_PCT / 100))) - (QUANTITY * UNIT_COST), 2) AS MARGIN
FROM base;

INSERT INTO CASALEY_DB.RAW.FACT_PROMO_TRANSACTIONS (
  TRANSACTION_ID,
  TX_DATE,
  STORE_ID,
  PRODUCT_ID,
  CUSTOMER_ID,
  PROMO_ID,
  QUANTITY,
  GROSS_REVENUE,
  DISCOUNT_VALUE,
  NET_REVENUE,
  CHANNEL,
  MARGIN
)
WITH canales AS (
  SELECT COLUMN1 AS canal
  FROM VALUES
    ('Self-checkout en tienda'),
    ('Call center Ley Contigo'),
    ('Tienda móvil regional'),
    ('Marketplace aliado'),
    ('Gasolinera asociada'),
    ('Programa empresarial'),
    ('App de reparto'),
    ('Venta institucional')
),
base AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY seq) AS rn,
    DATEADD('day', -FLOOR(UNIFORM(0, 30, RANDOM())), CURRENT_DATE()) AS tx_date,
    store_choice.store_id,
    product_choice.product_id,
    product_choice.unit_cost,
    product_choice.unit_price,
    customer_choice.customer_id,
    promo_choice.promo_id,
    promo_choice.discount_pct,
    canal_choice.canal
  FROM (
    SELECT SEQ4() AS seq
    FROM TABLE(GENERATOR(ROWCOUNT => 100))
  ) seeds
  JOIN LATERAL (
    SELECT store_id FROM DIM_STORE ORDER BY RANDOM() LIMIT 1
  ) store_choice ON TRUE
  JOIN LATERAL (
    SELECT product_id, unit_cost, unit_price FROM DIM_PRODUCT ORDER BY RANDOM() LIMIT 1
  ) product_choice ON TRUE
  JOIN LATERAL (
    SELECT customer_id FROM DIM_CUSTOMER ORDER BY RANDOM() LIMIT 1
  ) customer_choice ON TRUE
  JOIN LATERAL (
    SELECT promo_id, discount_pct FROM DIM_PROMOTION ORDER BY RANDOM() LIMIT 1
  ) promo_choice ON TRUE
  JOIN LATERAL (
    SELECT canal FROM canales ORDER BY RANDOM() LIMIT 1
  ) canal_choice ON TRUE
)
SELECT
  CONCAT('TX_EXTRA_', LPAD(base.rn::STRING, 5, '0')) AS TRANSACTION_ID,
  base.tx_date,
  base.store_id,
  base.product_id,
  base.customer_id,
  base.promo_id,
  GREATEST(1, ROUND(NORMAL(2, 1, RANDOM()))) AS quantity,
  ROUND(quantity * base.unit_price, 2) AS gross_revenue,
  ROUND(gross_revenue * (base.discount_pct / 100), 2) AS discount_value,
  ROUND(gross_revenue - discount_value, 2) AS net_revenue,
  base.canal AS channel,
  ROUND(net_revenue - (quantity * base.unit_cost), 2) AS margin
FROM base;

INSERT INTO FACT_INVENTORY_DAILY
SELECT
  DATEADD('day', -UNIFORM(0, 14, RANDOM()), CURRENT_DATE()) AS INVENTORY_DATE,
  store_id,
  product_id,
  ON_HAND_UNITS,
  SAFETY_STOCK,
  FORECAST_DEMAND,
  REPLENISHMENT_ORDER_UNITS
FROM (
  SELECT
    stores.STORE_ID AS store_id,
    products.PRODUCT_ID AS product_id,
    GREATEST(0, ROUND(NORMAL(250, 80, RANDOM()))) AS ON_HAND_UNITS,
    GREATEST(50, ROUND(NORMAL(200, 40, RANDOM()))) AS SAFETY_STOCK,
    GREATEST(80, ROUND(NORMAL(220, 60, RANDOM()))) AS FORECAST_DEMAND,
    GREATEST(0, ROUND(NORMAL(180, 70, RANDOM()))) AS REPLENISHMENT_ORDER_UNITS
  FROM DIM_STORE stores
  CROSS JOIN (SELECT PRODUCT_ID FROM DIM_PRODUCT ORDER BY RANDOM() LIMIT 12) products
  LIMIT 3000
) base;

INSERT INTO PROMO_CONTENT (PROMO_ID, PROMO_TITLE, TARGET_SEGMENTS, PROMO_DESCRIPTION, FINOPS_NOTES)
SELECT
  CONCAT('INSIGHT_', ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS PROMO_ID,
  'Insight FinOps ' || ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
  ARRAY_CONSTRUCT('FinOps'),
  'Recordatorio para revisar créditos diarios del warehouse X-Small y ajustar auto-suspend a 60 segundos para contener costos.',
  'Alertar si el uso diario supera 40 créditos; usar QUERY_HISTORY para auditoría.'
FROM TABLE(GENERATOR(ROWCOUNT => 5));

-- Sección 3: La Demo
USE SCHEMA ANALYTICS;

-- 3.1 Consulta: Promociones personalizadas de alto desempeño por segmento y canal
SELECT
  pr.PROMO_NAME,
  c.SEGMENT,
  f.CHANNEL,
  DATE_TRUNC('week', f.TX_DATE) AS semana,
  SUM(f.NET_REVENUE) AS ingresos_netos,
  AVG(f.MARGIN) AS margen_promedio,
  SUM(f.QUANTITY) AS unidades_vendidas,
  COUNT(DISTINCT f.CUSTOMER_ID) AS clientes_unicos
FROM VW_PROMO_PERFORMANCE f
JOIN CASALEY_DB.RAW.DIM_PROMOTION pr ON f.PROMO_ID = pr.PROMO_ID
JOIN CASALEY_DB.RAW.DIM_CUSTOMER c ON f.CUSTOMER_ID = c.CUSTOMER_ID
GROUP BY pr.PROMO_NAME, c.SEGMENT, f.CHANNEL, DATE_TRUNC('week', f.TX_DATE)
ORDER BY ingresos_netos DESC
LIMIT 20;

-- 3.2 Consulta: Riesgo de inventario por tienda y producto con umbrales FinOps
SELECT
  r.INVENTORY_DATE,
  r.STORE_NAME,
  r.PRODUCT_NAME,
  r.CATEGORY,
  r.ON_HAND_UNITS,
  r.SAFETY_STOCK,
  r.FORECAST_DEMAND,
  r.DELTA_UNITS,
  r.INVENTORY_STATUS,
  CASE WHEN r.DELTA_UNITS < 0 THEN 'Priorizar reabasto en próximos 2 días' ELSE 'Sin acción inmediata' END AS RECOMENDACION
FROM VW_INVENTORY_RISK r
WHERE r.INVENTORY_STATUS <> 'ESTABLE'
ORDER BY r.DELTA_UNITS ASC
LIMIT 50;

-- 3.3 Consulta: Costo por ticket promocional vs margen (FinOps aplicado)
SELECT
  DATE_TRUNC('day', f.TX_DATE) AS fecha,
  SUM(f.NET_REVENUE) AS ingresos_netos,
  SUM(f.MARGIN) AS margen_total,
  SUM(f.DISCOUNT_VALUE) AS incentivos,
  ROUND(SUM(f.DISCOUNT_VALUE) / NULLIF(SUM(f.QUANTITY),0), 2) AS costo_por_unidad,
  ROUND(SUM(f.MARGIN) / NULLIF(SUM(f.DISCOUNT_VALUE),0), 2) AS retorno_por_peso_invertido
FROM CASALEY_DB.RAW.FACT_PROMO_TRANSACTIONS f
GROUP BY DATE_TRUNC('day', f.TX_DATE)
ORDER BY fecha DESC
LIMIT 30;

-- 3.4 Llamada demo a Cortex Analyst
CALL CORTEX.ANALYST.ASK(
  'CASALEY_ANALYST_MODEL',
  '¿Qué promociones generaron mayor margen neto para el segmento Foodies premium en la última semana?'
);

-- 3.5 Llamada demo a Cortex Search
SELECT
  *
FROM CORTEX.SEARCH(
  'CASALEY_PROMO_SEARCH',
  'Promociones enfocadas a Mayorista PyME con canales digitales'
) LIMIT 5;

-- 3.6 Métrica de inventario crítico con alerta económica
SELECT
  r.STORE_NAME,
  r.PRODUCT_NAME,
  COUNT(*) AS dias_riesgo,
  AVG(r.FORECAST_DEMAND - r.ON_HAND_UNITS) AS promedio_quiebre,
  SUM(r.REPLENISHMENT_ORDER_UNITS) AS pedidos_programados,
  SUM(r.REPLENISHMENT_ORDER_UNITS * p.UNIT_COST) AS costo_estimado_reabasto
FROM VW_INVENTORY_RISK r
JOIN CASALEY_DB.RAW.DIM_PRODUCT p ON r.PRODUCT_ID = p.PRODUCT_ID
WHERE r.INVENTORY_STATUS = 'CRITICO'
GROUP BY r.STORE_NAME, r.PRODUCT_NAME
ORDER BY costo_estimado_reabasto DESC
LIMIT 20;

-- 3.7 Insight FinOps: seguimiento de créditos (ejemplo de consulta operativa)
SELECT
  DATE_TRUNC('hour', START_TIME) AS hora,
  SUM(CREDITS_USED_CLOUD_SERVICES) AS creditos_usados
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE WAREHOUSE_NAME = 'CASALEY_WH'
  AND START_TIME >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY DATE_TRUNC('hour', START_TIME)
ORDER BY hora DESC;

