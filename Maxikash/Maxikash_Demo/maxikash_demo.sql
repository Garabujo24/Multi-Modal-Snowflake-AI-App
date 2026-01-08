-- Sección 0: Historia y Caso de Uso
-- Maxikash ofrece financiamiento ágil para motocicletas en México, prometiendo aprobación en minutos con solo el INE y alianzas con marcas como Italika, Vento, Bajaj y Honda.
-- En los últimos 12 meses la dirección busca balancear crecimiento, morosidad e incumplimiento, y a la vez vigilar costos operativos para demos y pilotos internos. [Fuente: https://maxikash.mx/]
-- El objetivo de esta demo es mostrar datos sintéticos que permitan analizar:
--   * Colocación mensual de créditos vs. solicitudes.
--   * Morosidad, buckets de atraso e incumplimiento.
--   * Salud de la cartera diferenciada por canal, segmento y distribuidor.
--   * Vigilia FinOps sobre el warehouse X-Small dedicado a la demo.

-- Sección 1: Configuración de Recursos
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE ROLE MAXIKASH_ROLE COMMENT = 'Rol dedicado a la demo analítica de cartera Maxikash';
GRANT ROLE MAXIKASH_ROLE TO ROLE SYSADMIN;

CREATE OR REPLACE WAREHOUSE MAXIKASH_WH
  WITH WAREHOUSE_SIZE = 'XSMALL'
       AUTO_SUSPEND = 60
       AUTO_RESUME = TRUE
       INITIALLY_SUSPENDED = TRUE
       COMMENT = 'Warehouse demo para análisis de cartera y FinOps Maxikash';
GRANT USAGE, OPERATE ON WAREHOUSE MAXIKASH_WH TO ROLE MAXIKASH_ROLE;

CREATE OR REPLACE DATABASE MAXIKASH_DB COMMENT = 'Base de datos demo Snowflake para Maxikash';
GRANT OWNERSHIP ON DATABASE MAXIKASH_DB TO ROLE MAXIKASH_ROLE REVOKE CURRENT GRANTS;

CREATE OR REPLACE SCHEMA MAXIKASH_DB.MAXIKASH_RAW_SCHEMA COMMENT = 'Zona raw con datos sintéticos de clientes y solicitudes';
CREATE OR REPLACE SCHEMA MAXIKASH_DB.MAXIKASH_ANALYTICS_SCHEMA COMMENT = 'Zona analítica con vistas y métricas';
CREATE OR REPLACE SCHEMA MAXIKASH_DB.MAXIKASH_MONITORING_SCHEMA COMMENT = 'Zona de monitoreo FinOps y calidad';

GRANT USAGE ON DATABASE MAXIKASH_DB TO ROLE MAXIKASH_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE MAXIKASH_DB TO ROLE MAXIKASH_ROLE;
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE MAXIKASH_DB TO ROLE MAXIKASH_ROLE;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA MAXIKASH_DB.MAXIKASH_RAW_SCHEMA TO ROLE MAXIKASH_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA MAXIKASH_DB.MAXIKASH_RAW_SCHEMA TO ROLE MAXIKASH_ROLE;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA MAXIKASH_DB.MAXIKASH_MONITORING_SCHEMA TO ROLE MAXIKASH_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA MAXIKASH_DB.MAXIKASH_MONITORING_SCHEMA TO ROLE MAXIKASH_ROLE;

USE ROLE MAXIKASH_ROLE;
USE WAREHOUSE MAXIKASH_WH;
USE DATABASE MAXIKASH_DB;
USE SCHEMA MAXIKASH_RAW_SCHEMA;

CREATE OR REPLACE TABLE MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.CUSTOMER_RAW (
    CUSTOMER_ID NUMBER,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    GENDER STRING,
    AGE NUMBER,
    OCCUPATION STRING,
    MONTHLY_INCOME_MXN NUMBER(10,2),
    STATE STRING,
    CITY STRING,
    REGISTRATION_DATE DATE,
    REFERRED_CHANNEL STRING,
    CUSTOMER_SEGMENT STRING,
    CREDIT_SCORE NUMBER(5,0),
    RISK_SEGMENT STRING,
    DIGITAL_ADOPTION_INDEX NUMBER(5,2),
    NPS_SCORE NUMBER(3,0),
    IS_ACTIVE BOOLEAN
);

CREATE OR REPLACE TABLE MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.APPLICATION_RAW (
    APPLICATION_ID NUMBER,
    CUSTOMER_ID NUMBER,
    APPLICATION_DATE DATE,
    APPLICATION_CHANNEL STRING,
    REQUESTED_AMOUNT_MXN NUMBER(12,2),
    APPROVED_AMOUNT_MXN NUMBER(12,2),
    APPROVAL_STATUS STRING,
    TENOR_WEEKS NUMBER,
    VEHICLE_BRAND STRING,
    VEHICLE_MODEL STRING,
    VEHICLE_PRICE_MXN NUMBER(12,2),
    DOWN_PAYMENT_MXN NUMBER(12,2),
    RISK_SCORE NUMBER(6,2),
    DECISION_TIME_MINUTES NUMBER(6,2),
    REGION STRING,
    CUSTOMER_SEGMENT STRING,
    EXPECTED_DEFAULT_PROB NUMBER(5,2),
    DEBT_TO_INCOME_RATIO NUMBER(5,2),
    PROMO_CODE_APPLIED BOOLEAN
);

CREATE OR REPLACE TABLE MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.LOAN_RAW (
    LOAN_ID NUMBER,
    APPLICATION_ID NUMBER,
    CUSTOMER_ID NUMBER,
    DISBURSEMENT_DATE DATE,
    PRINCIPAL_AMOUNT_MXN NUMBER(12,2),
    INTEREST_RATE_ANNUAL NUMBER(5,2),
    TENOR_WEEKS NUMBER,
    EXPECTED_END_DATE DATE,
    WEEKLY_PAYMENT_EXPECTED_MXN NUMBER(10,2),
    CURRENT_BALANCE_MXN NUMBER(12,2),
    DAYS_PAST_DUE NUMBER,
    LOAN_STATUS STRING,
    MOROSITY_BUCKET STRING,
    PLACEMENT_CHANNEL STRING,
    DEALER_PARTNER STRING,
    PORTFOLIO_SEGMENT STRING,
    INSURANCE_OPT_IN BOOLEAN,
    FIRST_DEFAULT_DATE DATE,
    RESTRUCTURED_FLAG BOOLEAN,
    CHARGE_OFF_FLAG BOOLEAN,
    COLLECTION_STAGE STRING,
    RISK_TIER STRING,
    LAST_PAYMENT_DATE DATE,
    WEEKS_ELAPSED NUMBER,
    PAYMENTS_COMPLETED NUMBER
);

CREATE OR REPLACE TABLE MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.PAYMENT_RAW (
    LOAN_ID NUMBER,
    CUSTOMER_ID NUMBER,
    PAYMENT_DATE DATE,
    EXPECTED_AMOUNT_MXN NUMBER(10,2),
    ACTUAL_AMOUNT_MXN NUMBER(10,2),
    IS_ON_TIME BOOLEAN,
    DAYS_LATE NUMBER,
    PAYMENT_CHANNEL STRING,
    WEEK_NUMBER NUMBER,
    IS_FINAL_PAYMENT BOOLEAN
);

USE SCHEMA MAXIKASH_MONITORING_SCHEMA;

CREATE OR REPLACE TABLE MAXIKASH_DB.MAXIKASH_MONITORING_SCHEMA.WAREHOUSE_COSTS (
    USAGE_MONTH DATE,
    WAREHOUSE_NAME STRING,
    CREDITS_CONSUMED NUMBER(10,2),
    AUTO_SUSPEND_MINUTES NUMBER(10,2),
    AVG_CONCURRENCY NUMBER(5,2),
    STORAGE_GB NUMBER(10,2),
    STORAGE_COST_USD NUMBER(10,2),
    DATA_TRANSFER_USD NUMBER(10,2),
    TOTAL_COST_USD NUMBER(10,2),
    TOTAL_COST_MXN NUMBER(10,2),
    NOTES STRING
);

-- Sección 2: Generación de Datos Sintéticos
USE SCHEMA MAXIKASH_RAW_SCHEMA;

TRUNCATE TABLE MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.CUSTOMER_RAW;

INSERT INTO MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.CUSTOMER_RAW
WITH customer_seed AS (
    SELECT
        1000 + SEQ4() AS customer_id,
        GET(ARRAY_CONSTRUCT('Ana','Luis','María','Carlos','Sofía','Jorge','Lucía','Miguel','Javier','Fernanda','Diego','Daniela','Ernesto','Patricia','Rogelio','Montserrat','Ricardo','Itzel','Alejandro','Valeria'), UNIFORM(0, 20, RANDOM()))::STRING AS first_name,
        GET(ARRAY_CONSTRUCT('García','López','Hernández','Martínez','Rodríguez','Pérez','González','Sánchez','Ramírez','Flores','Cruz','Vargas','Torres','Jiménez','Navarro','Reyes','Contreras','Salazar','Mendoza','Aguilar'), UNIFORM(0, 20, RANDOM()))::STRING AS last_name,
        CASE WHEN UNIFORM(0, 100, RANDOM()) < 48 THEN 'F' ELSE 'M' END AS gender,
        UNIFORM(21, 58, RANDOM()) AS age,
        GET(ARRAY_CONSTRUCT('Repartidor Plataforma','Comerciante Minorista','Mensajero Independiente','Empleado Retail','Técnico de Servicio','Chofer de App','Microempresario','Estudiante Emprendedor'), UNIFORM(0, 8, RANDOM()))::STRING AS occupation,
        ROUND(UNIFORM(650000, 2800000, RANDOM()) / 100, 2) AS monthly_income_mxn,
        GET(ARRAY_CONSTRUCT('Ciudad de México','Estado de México','Jalisco','Nuevo León','Puebla','Veracruz','Yucatán','Querétaro','Guanajuato','Michoacán'), UNIFORM(0, 10, RANDOM()))::STRING AS state_key,
        DATEADD(day, -UNIFORM(0, 540, RANDOM()), CURRENT_DATE()) AS registration_date,
        GET(ARRAY_CONSTRUCT('Campaña Digital','Agencia Aliada','Referido Maxikash','Marketplace','Telemarketing'), UNIFORM(0, 5, RANDOM()))::STRING AS referred_channel,
        GET(ARRAY_CONSTRUCT('Delivery','Uso Productivo','Ride Hailing','Comercio Minorista','Uso Personal Controlado'), UNIFORM(0, 5, RANDOM()))::STRING AS customer_segment,
        ROUND(UNIFORM(5200, 8100, RANDOM()) / 10, 0) AS credit_score,
        ROUND(UNIFORM(620, 950, RANDOM()) / 10, 2) AS digital_adoption_index,
        UNIFORM(-10, 60, RANDOM()) AS nps_score,
        CASE WHEN UNIFORM(0, 100, RANDOM()) < 78 THEN TRUE ELSE FALSE END AS is_active
    FROM TABLE(GENERATOR(ROWCOUNT => 120))
), customer_enriched AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        gender,
        age,
        occupation,
        monthly_income_mxn,
        state_key AS state,
        CASE state_key
            WHEN 'Ciudad de México' THEN GET(ARRAY_CONSTRUCT('Iztapalapa','Benito Juárez','Gustavo A. Madero','Cuauhtémoc','Tlalpan'), UNIFORM(0, 5, RANDOM()))::STRING
            WHEN 'Estado de México' THEN GET(ARRAY_CONSTRUCT('Ecatepec','Naucalpan','Tlalnepantla','Chalco','Nezahualcóyotl'), UNIFORM(0, 5, RANDOM()))::STRING
            WHEN 'Jalisco' THEN GET(ARRAY_CONSTRUCT('Guadalajara','Zapopan','Tlaquepaque','Tlajomulco'), UNIFORM(0, 4, RANDOM()))::STRING
            WHEN 'Nuevo León' THEN GET(ARRAY_CONSTRUCT('Monterrey','San Nicolás','Guadalupe','Apodaca'), UNIFORM(0, 4, RANDOM()))::STRING
            WHEN 'Puebla' THEN GET(ARRAY_CONSTRUCT('Puebla','San Pedro Cholula','Tehuacán','Atlixco'), UNIFORM(0, 4, RANDOM()))::STRING
            WHEN 'Veracruz' THEN GET(ARRAY_CONSTRUCT('Veracruz','Xalapa','Boca del Río','Córdoba'), UNIFORM(0, 4, RANDOM()))::STRING
            WHEN 'Yucatán' THEN GET(ARRAY_CONSTRUCT('Mérida','Progreso','Kanasín','Valladolid'), UNIFORM(0, 4, RANDOM()))::STRING
            WHEN 'Querétaro' THEN GET(ARRAY_CONSTRUCT('Querétaro','San Juan del Río','Corregidora'), UNIFORM(0, 3, RANDOM()))::STRING
            WHEN 'Guanajuato' THEN GET(ARRAY_CONSTRUCT('León','Irapuato','Celaya','Salamanca'), UNIFORM(0, 4, RANDOM()))::STRING
            ELSE GET(ARRAY_CONSTRUCT('Morelia','Uruapan','Zamora','La Piedad'), UNIFORM(0, 4, RANDOM()))::STRING
        END AS city,
        registration_date,
        referred_channel,
        customer_segment,
        credit_score,
        CASE
            WHEN credit_score >= 730 THEN 'Bajo'
            WHEN credit_score BETWEEN 660 AND 729 THEN 'Medio'
            ELSE 'Alto'
        END AS risk_segment,
        digital_adoption_index / 10 AS digital_adoption_index,
        nps_score,
        is_active
    FROM customer_seed
)
SELECT
    customer_id,
    first_name,
    last_name,
    gender,
    age,
    occupation,
    monthly_income_mxn,
    state,
    city,
    registration_date,
    referred_channel,
    customer_segment,
    credit_score,
    risk_segment,
    ROUND(digital_adoption_index, 2) AS digital_adoption_index,
    nps_score,
    is_active
FROM customer_enriched;

TRUNCATE TABLE MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.APPLICATION_RAW;

INSERT INTO MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.APPLICATION_RAW
WITH base AS (
    SELECT
        c.CUSTOMER_ID,
        c.CREDIT_SCORE,
        c.STATE,
        c.CUSTOMER_SEGMENT,
        c.MONTHLY_INCOME_MXN,
        c.REFERRED_CHANNEL,
        GET(ARRAY_CONSTRUCT('Marketplace Maxikash','Agencia Afiliada','Campaña Digital','Referido','Telemarketing'), UNIFORM(0, 5, RANDOM()))::STRING AS channel_seed,
        GET(ARRAY_CONSTRUCT('Italika','Vento','Bajaj','Honda','Yamaha','TVS','Galgo'), UNIFORM(0, 7, RANDOM()))::STRING AS brand_seed,
        UNIFORM(1, 4, RANDOM()) AS applications_per_customer
    FROM MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.CUSTOMER_RAW c
), expanded AS (
    SELECT
        CUSTOMER_ID,
        CREDIT_SCORE,
        STATE,
        CUSTOMER_SEGMENT,
        MONTHLY_INCOME_MXN,
        REFERRED_CHANNEL,
        channel_seed,
        brand_seed,
        VALUE::INT AS application_seq
    FROM base,
         LATERAL FLATTEN(INPUT => ARRAY_GENERATE_RANGE(1, applications_per_customer + 1))
), application_seed AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY CUSTOMER_ID, application_seq) AS seq_id,
        CUSTOMER_ID,
        CREDIT_SCORE,
        STATE,
        CUSTOMER_SEGMENT,
        MONTHLY_INCOME_MXN,
        REFERRED_CHANNEL,
        channel_seed,
        brand_seed,
        DATEADD(day, -UNIFORM(0, 364, RANDOM()), CURRENT_DATE()) AS application_date,
        UNIFORM(33000, 89000, RANDOM())::NUMBER(10,0) AS vehicle_price_base,
        UNIFORM(0, 100, RANDOM()) AS decision_random,
        UNIFORM(0, 100, RANDOM()) AS promo_random,
        UNIFORM(45, 140, RANDOM()) AS decision_time_seconds
    FROM expanded
), application_final AS (
    SELECT
        5000 + seq_id AS application_id,
        CUSTOMER_ID,
        application_date,
        channel_seed AS application_channel,
        brand_seed AS vehicle_brand,
        CASE brand_seed
            WHEN 'Italika' THEN GET(ARRAY_CONSTRUCT('FT150','X125','DM200','AT110'), UNIFORM(0, 4, RANDOM()))::STRING
            WHEN 'Vento' THEN GET(ARRAY_CONSTRUCT('Rocketman 250','Phantom 150','Nitrox 200'), UNIFORM(0, 3, RANDOM()))::STRING
            WHEN 'Bajaj' THEN GET(ARRAY_CONSTRUCT('Pulsar 160N','Dominar 250','Boxer 150'), UNIFORM(0, 3, RANDOM()))::STRING
            WHEN 'Honda' THEN GET(ARRAY_CONSTRUCT('CB190R','XR150L','Dio 110'), UNIFORM(0, 3, RANDOM()))::STRING
            WHEN 'Yamaha' THEN GET(ARRAY_CONSTRUCT('FZ25','Xtz 150','Cygnus Ray ZR'), UNIFORM(0, 3, RANDOM()))::STRING
            WHEN 'TVS' THEN GET(ARRAY_CONSTRUCT('RTR 160 4V','HLX 150','Ntorq 125'), UNIFORM(0, 3, RANDOM()))::STRING
            ELSE GET(ARRAY_CONSTRUCT('G1 Cargo','G1 Delivery','G1 Sport'), UNIFORM(0, 3, RANDOM()))::STRING
        END AS vehicle_model,
        vehicle_price_base::NUMBER(12,2) AS vehicle_price_mxn,
        ROUND(vehicle_price_base * (0.18 + (UNIFORM(5, 20, RANDOM()) / 100)), 2) AS down_payment_mxn,
        ROUND(vehicle_price_base * (0.85 + (UNIFORM(0, 16, RANDOM()) / 100)), 2) AS requested_amount_mxn,
        CASE
            WHEN CREDIT_SCORE >= 720 AND decision_random < 82 THEN 'APROBADA'
            WHEN CREDIT_SCORE BETWEEN 660 AND 719 AND decision_random < 68 THEN 'APROBADA'
            WHEN CREDIT_SCORE BETWEEN 600 AND 659 AND decision_random < 48 THEN 'EN_REVISION'
            WHEN decision_random < 90 THEN 'EN_REVISION'
            ELSE 'RECHAZADA'
        END AS approval_status,
        GET(ARRAY_CONSTRUCT(26, 39, 52, 65), UNIFORM(0, 4, RANDOM()))::INT AS tenor_weeks,
        ROUND(ROUND(vehicle_price_base * (0.85 + (UNIFORM(0, 16, RANDOM()) / 100)), 2) * (0.38 + (UNIFORM(0, 10, RANDOM()) / 100)) / NULLIF(MONTHLY_INCOME_MXN, 0), 2) AS debt_to_income_ratio,
        ROUND((CREDIT_SCORE / 10) - UNIFORM(0, 150, RANDOM()), 2) AS risk_score,
        ROUND((100 - CREDIT_SCORE / 10) / 100 + (UNIFORM(0, 12, RANDOM()) / 1000), 2) AS expected_default_prob,
        ROUND(DECISION_TIME_SECONDS / 60, 2) AS decision_time_minutes,
        CASE STATE
            WHEN 'Ciudad de México' THEN 'Centro'
            WHEN 'Estado de México' THEN 'Centro'
            WHEN 'Jalisco' THEN 'Occidente'
            WHEN 'Nuevo León' THEN 'Noreste'
            WHEN 'Puebla' THEN 'Centro-Sur'
            WHEN 'Veracruz' THEN 'Golfo'
            WHEN 'Yucatán' THEN 'Sureste'
            WHEN 'Querétaro' THEN 'Bajío'
            WHEN 'Guanajuato' THEN 'Bajío'
            ELSE 'Occidente'
        END AS region,
        CUSTOMER_SEGMENT,
        CASE WHEN promo_random < 28 THEN TRUE ELSE FALSE END AS promo_code_applied
    FROM application_seed
)
SELECT
    application_id,
    CUSTOMER_ID,
    application_date,
    application_channel,
    requested_amount_mxn,
    CASE
        WHEN approval_status = 'APROBADA' THEN LEAST(requested_amount_mxn, vehicle_price_mxn - down_payment_mxn) * (0.95 + (UNIFORM(0, 8, RANDOM()) / 100))
        ELSE NULL
    END AS approved_amount_mxn,
    approval_status,
    tenor_weeks,
    vehicle_brand,
    vehicle_model,
    vehicle_price_mxn,
    down_payment_mxn,
    risk_score,
    decision_time_minutes,
    region,
    CUSTOMER_SEGMENT,
    expected_default_prob,
    debt_to_income_ratio,
    promo_code_applied
FROM application_final;

TRUNCATE TABLE MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.LOAN_RAW;

INSERT INTO MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.LOAN_RAW
WITH approved_apps AS (
    SELECT
        a.APPLICATION_ID,
        a.CUSTOMER_ID,
        a.APPLICATION_DATE,
        a.APPROVED_AMOUNT_MXN,
        a.TENOR_WEEKS,
        a.APPLICATION_CHANNEL,
        a.CUSTOMER_SEGMENT,
        a.RISK_SCORE,
        a.EXPECTED_DEFAULT_PROB,
        c.CREDIT_SCORE,
        c.MONTHLY_INCOME_MXN
    FROM MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.APPLICATION_RAW a
    JOIN MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.CUSTOMER_RAW c
      ON a.CUSTOMER_ID = c.CUSTOMER_ID
    WHERE a.APPROVAL_STATUS = 'APROBADA'
), loan_seed AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY APPLICATION_ID) AS seq_id,
        APPLICATION_ID,
        CUSTOMER_ID,
        APPLICATION_DATE,
        COALESCE(APPROVED_AMOUNT_MXN, 0) AS principal_amount_mxn,
        TENOR_WEEKS,
        APPLICATION_CHANNEL,
        CUSTOMER_SEGMENT,
        RISK_SCORE,
        EXPECTED_DEFAULT_PROB,
        CREDIT_SCORE,
        MONTHLY_INCOME_MXN,
        DATEADD(day, UNIFORM(0, 7, RANDOM()), APPLICATION_DATE) AS disbursement_date,
        ROUND(UNIFORM(3200, 4600, RANDOM()) / 100, 2) AS interest_rate_annual,
        UNIFORM(0, 100, RANDOM()) AS status_random
    FROM approved_apps
), loan_final AS (
    SELECT
        8000 + seq_id AS loan_id,
        APPLICATION_ID,
        CUSTOMER_ID,
        disbursement_date,
        principal_amount_mxn,
        interest_rate_annual,
        TENOR_WEEKS,
        DATEADD(week, TENOR_WEEKS, disbursement_date) AS expected_end_date,
        ROUND((principal_amount_mxn * (1 + interest_rate_annual / 100)) / NULLIF(TENOR_WEEKS, 0), 2) AS weekly_payment_expected_mxn,
        APPLICATION_CHANNEL AS placement_channel,
        CUSTOMER_SEGMENT AS portfolio_segment,
        CASE
            WHEN status_random < 58 THEN 'VIGENTE'
            WHEN status_random BETWEEN 58 AND 74 THEN 'MOROSO_30'
            WHEN status_random BETWEEN 75 AND 84 THEN 'MOROSO_60'
            WHEN status_random BETWEEN 85 AND 92 THEN 'REESTRUCTURADO'
            ELSE 'INCUMPLIDO'
        END AS loan_status,
        CASE
            WHEN status_random < 58 THEN 0
            WHEN status_random BETWEEN 58 AND 74 THEN UNIFORM(8, 30, RANDOM())
            WHEN status_random BETWEEN 75 AND 84 THEN UNIFORM(31, 60, RANDOM())
            WHEN status_random BETWEEN 85 AND 92 THEN UNIFORM(20, 50, RANDOM())
            ELSE UNIFORM(75, 180, RANDOM())
        END AS days_past_due,
        CASE WHEN UNIFORM(0, 100, RANDOM()) < 62 THEN TRUE ELSE FALSE END AS insurance_opt_in,
        ROUND(UNIFORM(0, 100, RANDOM()), 2) AS dealer_random,
        credit_score,
        expected_default_prob,
        monthly_income_mxn
    FROM loan_seed
), loan_enriched AS (
    SELECT
        loan_id,
        APPLICATION_ID,
        CUSTOMER_ID,
        disbursement_date,
        principal_amount_mxn,
        interest_rate_annual,
        TENOR_WEEKS,
        expected_end_date,
        weekly_payment_expected_mxn,
        loan_status,
        days_past_due,
        placement_channel,
        portfolio_segment,
        insurance_opt_in,
        CASE
            WHEN dealer_random < 20 THEN 'Mexicash E-commerce'
            WHEN dealer_random < 40 THEN 'Agencia Italika CDMX'
            WHEN dealer_random < 60 THEN 'Distribuidor Vento Bajío'
            WHEN dealer_random < 80 THEN 'Alianza Bajaj Monterrey'
            ELSE 'Dealer Honda Puebla'
        END AS dealer_partner,
        CASE
            WHEN days_past_due = 0 THEN '0-7 días'
            WHEN days_past_due BETWEEN 1 AND 30 THEN '8-30 días'
            WHEN days_past_due BETWEEN 31 AND 60 THEN '31-60 días'
            WHEN days_past_due BETWEEN 61 AND 90 THEN '61-90 días'
            ELSE '90+ días'
        END AS morosity_bucket,
        CASE
            WHEN loan_status = 'VIGENTE' THEN 'Preventivo'
            WHEN loan_status LIKE 'MOROSO%' THEN 'Gestión Temprana'
            WHEN loan_status = 'REESTRUCTURADO' THEN 'Reestructura'
            ELSE 'Cobranza Jurídica'
        END AS collection_stage,
        CASE
            WHEN credit_score >= 730 THEN 'Prime'
            WHEN credit_score BETWEEN 660 AND 729 THEN 'Near-Prime'
            ELSE 'Subprime'
        END AS risk_tier,
        credit_score,
        expected_default_prob,
        monthly_income_mxn
    FROM loan_final
)
SELECT
    loan_id,
    APPLICATION_ID,
    CUSTOMER_ID,
    disbursement_date,
    principal_amount_mxn,
    interest_rate_annual,
    TENOR_WEEKS,
    expected_end_date,
    weekly_payment_expected_mxn,
    GREATEST(0, principal_amount_mxn * (1 + interest_rate_annual / 100) - weekly_payment_expected_mxn * (LEAST(TENOR_WEEKS, DATEDIFF(week, disbursement_date, CURRENT_DATE())) * CASE
        WHEN loan_status = 'VIGENTE' THEN 1
        WHEN loan_status = 'MOROSO_30' THEN 0.82
        WHEN loan_status = 'MOROSO_60' THEN 0.68
        WHEN loan_status = 'REESTRUCTURADO' THEN 0.74
        ELSE 0.35
    END)) AS current_balance_mxn,
    days_past_due,
    loan_status,
    morosity_bucket,
    placement_channel,
    dealer_partner,
    portfolio_segment,
    insurance_opt_in,
    CASE WHEN days_past_due > 0 THEN DATEADD(day, -days_past_due, CURRENT_DATE()) ELSE NULL END AS first_default_date,
    CASE WHEN loan_status = 'REESTRUCTURADO' THEN TRUE ELSE FALSE END AS restructured_flag,
    CASE WHEN loan_status = 'INCUMPLIDO' AND days_past_due > 120 THEN TRUE ELSE FALSE END AS charge_off_flag,
    collection_stage,
    risk_tier,
    CASE WHEN days_past_due = 0 THEN CURRENT_DATE() ELSE DATEADD(day, -GREATEST(days_past_due, 15), CURRENT_DATE()) END AS last_payment_date,
    LEAST(TENOR_WEEKS, DATEDIFF(week, disbursement_date, CURRENT_DATE())) AS weeks_elapsed,
    ROUND(LEAST(TENOR_WEEKS, DATEDIFF(week, disbursement_date, CURRENT_DATE())) * CASE
        WHEN loan_status = 'VIGENTE' THEN 1
        WHEN loan_status = 'MOROSO_30' THEN 0.88
        WHEN loan_status = 'MOROSO_60' THEN 0.73
        WHEN loan_status = 'REESTRUCTURADO' THEN 0.80
        ELSE 0.42
    END, 0) AS payments_completed
FROM loan_enriched;

TRUNCATE TABLE MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.PAYMENT_RAW;

INSERT INTO MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.PAYMENT_RAW
WITH loan_base AS (
    SELECT
        loan_id,
        CUSTOMER_ID,
        disbursement_date,
        TENOR_WEEKS,
        weekly_payment_expected_mxn,
        loan_status,
        days_past_due,
        placement_channel
    FROM MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.LOAN_RAW
), calendar_weeks AS (
    SELECT
        l.loan_id,
        l.CUSTOMER_ID,
        l.disbursement_date,
        l.TENOR_WEEKS,
        l.weekly_payment_expected_mxn,
        l.loan_status,
        l.days_past_due,
        l.placement_channel,
        ROW_NUMBER() OVER (PARTITION BY l.loan_id ORDER BY seq4()) AS week_number
    FROM loan_base l,
         TABLE(GENERATOR(ROWCOUNT => 65))
), bounded_weeks AS (
    SELECT *
    FROM calendar_weeks
    WHERE week_number <= TENOR_WEEKS
)
SELECT
    loan_id,
    CUSTOMER_ID,
    DATEADD(week, week_number - 1, disbursement_date) AS payment_date,
    weekly_payment_expected_mxn AS expected_amount_mxn,
    CASE
        WHEN loan_status = 'INCUMPLIDO' AND week_number > TENOR_WEEKS - 8 THEN ROUND(weekly_payment_expected_mxn * 0.20, 2)
        WHEN loan_status LIKE 'MOROSO%' AND week_number > TENOR_WEEKS - 10 THEN ROUND(weekly_payment_expected_mxn * 0.55, 2)
        WHEN loan_status = 'REESTRUCTURADO' AND week_number > TENOR_WEEKS - 6 THEN ROUND(weekly_payment_expected_mxn * 0.82, 2)
        ELSE ROUND(weekly_payment_expected_mxn * (0.95 + (UNIFORM(0, 8, RANDOM()) / 100)), 2)
    END AS actual_amount_mxn,
    CASE
        WHEN loan_status = 'INCUMPLIDO' AND week_number > TENOR_WEEKS - 8 THEN FALSE
        WHEN loan_status LIKE 'MOROSO%' AND week_number > TENOR_WEEKS - 10 THEN FALSE
        WHEN UNIFORM(0, 100, RANDOM()) < 6 THEN FALSE
        ELSE TRUE
    END AS is_on_time,
    CASE
        WHEN loan_status = 'INCUMPLIDO' AND week_number > TENOR_WEEKS - 8 THEN UNIFORM(45, 120, RANDOM())
        WHEN loan_status LIKE 'MOROSO%' AND week_number > TENOR_WEEKS - 10 THEN UNIFORM(10, 45, RANDOM())
        WHEN UNIFORM(0, 100, RANDOM()) < 6 THEN UNIFORM(1, 9, RANDOM())
        ELSE 0
    END AS days_late,
    GET(ARRAY_CONSTRUCT('Convenio Digital','OXXO Pay','Transferencia SPEI','Domiciliación','Aliado Comercial'), UNIFORM(0, 5, RANDOM()))::STRING AS payment_channel,
    week_number,
    CASE WHEN week_number = TENOR_WEEKS THEN TRUE ELSE FALSE END AS is_final_payment
FROM bounded_weeks;

SET MAXIKASH_BASE_MONTH = DATE_TRUNC('month', DATEADD(month, -11, CURRENT_DATE()));
SET MAXIKASH_MXN_PER_USD = 17.10;

TRUNCATE TABLE MAXIKASH_DB.MAXIKASH_MONITORING_SCHEMA.WAREHOUSE_COSTS;

INSERT INTO MAXIKASH_DB.MAXIKASH_MONITORING_SCHEMA.WAREHOUSE_COSTS
WITH months AS (
    SELECT
        DATEADD(month, VALUE::INT, $MAXIKASH_BASE_MONTH) AS usage_month,
        VALUE::INT AS month_index
    FROM TABLE(FLATTEN(INPUT => ARRAY_GENERATE_RANGE(0, 12)))
), costs AS (
    SELECT
        usage_month,
        month_index,
        (UNIFORM(1280, 1880, RANDOM()) / 10) + (month_index * 0.6) AS credits_consumed,
        45 + month_index * 0.5 AS auto_suspend_minutes,
        ROUND(0.8 + (month_index * 0.02), 2) AS avg_concurrency,
        (UNIFORM(420, 640, RANDOM()) / 10) + (month_index * 0.8) AS storage_gb,
        (UNIFORM(800, 1200, RANDOM()) / 10) AS storage_cost_usd,
        (UNIFORM(220, 420, RANDOM()) / 10) AS data_transfer_usd
    FROM months
)
SELECT
    usage_month,
    'MAXIKASH_WH' AS warehouse_name,
    ROUND(credits_consumed, 2) AS credits_consumed,
    ROUND(auto_suspend_minutes, 2) AS auto_suspend_minutes,
    avg_concurrency,
    ROUND(storage_gb, 2) AS storage_gb,
    ROUND(storage_cost_usd, 2) AS storage_cost_usd,
    ROUND(data_transfer_usd, 2) AS data_transfer_usd,
    ROUND((credits_consumed * 2) + storage_cost_usd + data_transfer_usd, 2) AS total_cost_usd,
    ROUND(((credits_consumed * 2) + storage_cost_usd + data_transfer_usd) * $MAXIKASH_MXN_PER_USD, 2) AS total_cost_mxn,
    CASE
        WHEN month_index = 0 THEN 'Arranque del piloto con campañas digitales'
        WHEN month_index BETWEEN 4 AND 6 THEN 'Expansión a agencias aliadas'
        WHEN month_index BETWEEN 7 AND 9 THEN 'Temporada alta de repartidores'
        ELSE 'Optimización FinOps y tuning de auto-suspend'
    END AS notes
FROM costs;

-- Sección 3: La Demo
-- 3.1 Embudo de solicitudes vs. colocación en los últimos 12 meses
SELECT
    DATE_TRUNC('month', application_date) AS mes,
    COUNT(*) AS solicitudes_total,
    COUNT_IF(approval_status = 'APROBADA') AS solicitudes_aprobadas,
    COUNT_IF(approval_status = 'EN_REVISION') AS solicitudes_en_revision,
    COUNT_IF(approval_status = 'RECHAZADA') AS solicitudes_rechazadas,
    ROUND(COUNT_IF(approval_status = 'APROBADA') / NULLIF(COUNT(*), 0) * 100, 2) AS tasa_aprobacion_pct,
    ROUND(SUM(approved_amount_mxn) / 1000000, 2) AS montos_aprobados_mn,
    ROUND(SUM(requested_amount_mxn) / 1000000, 2) AS montos_solicitados_mn
FROM MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.APPLICATION_RAW
WHERE application_date >= DATEADD(month, -11, DATE_TRUNC('month', CURRENT_DATE()))
GROUP BY 1
ORDER BY 1;

-- 3.2 Indicadores de morosidad e incumplimiento por bucket
SELECT
    morosity_bucket,
    COUNT(*) AS cuentas,
    ROUND(SUM(principal_amount_mxn) / 1000000, 2) AS saldo_principal_mn,
    ROUND(SUM(current_balance_mxn) / 1000000, 2) AS saldo_actual_mn,
    ROUND(AVG(days_past_due), 1) AS dias_promedio_atraso,
    ROUND(AVG(CASE WHEN loan_status = 'INCUMPLIDO' THEN 1 ELSE 0 END) * 100, 2) AS porc_incumplido
FROM MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.LOAN_RAW
GROUP BY morosity_bucket
ORDER BY CASE
    WHEN morosity_bucket = '0-7 días' THEN 0
    WHEN morosity_bucket = '8-30 días' THEN 1
    WHEN morosity_bucket = '31-60 días' THEN 2
    WHEN morosity_bucket = '61-90 días' THEN 3
    ELSE 4
END;

-- 3.3 Salud de cartera por canal y segmento con métricas de morosidad
SELECT
    placement_channel,
    portfolio_segment,
    COUNT(*) AS cuentas,
    ROUND(SUM(principal_amount_mxn) / 1000000, 2) AS principal_mn,
    ROUND(SUM(current_balance_mxn) / 1000000, 2) AS saldo_actual_mn,
    ROUND(AVG(days_past_due), 1) AS dias_atraso_promedio,
    ROUND(COUNT_IF(loan_status LIKE 'MOROSO%') / NULLIF(COUNT(*),0) * 100, 2) AS morosidad_pct,
    ROUND(COUNT_IF(loan_status = 'INCUMPLIDO') / NULLIF(COUNT(*),0) * 100, 2) AS incumplimiento_pct
FROM MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.LOAN_RAW
GROUP BY placement_channel, portfolio_segment
ORDER BY principal_mn DESC;

-- 3.4 Cohorte de cobranza: pagos recibidos vs. esperados
SELECT
    DATE_TRUNC('month', payment_date) AS mes_pago,
    ROUND(SUM(expected_amount_mxn), 2) AS cobro_planeado_mxn,
    ROUND(SUM(actual_amount_mxn), 2) AS cobro_real_mxn,
    ROUND((SUM(actual_amount_mxn) / NULLIF(SUM(expected_amount_mxn), 0)) * 100, 2) AS desempeno_pct,
    ROUND(AVG(days_late), 1) AS dias_atraso_promedio
FROM MAXIKASH_DB.MAXIKASH_RAW_SCHEMA.PAYMENT_RAW
WHERE payment_date >= DATEADD(month, -11, DATE_TRUNC('month', CURRENT_DATE()))
GROUP BY 1
ORDER BY 1;

-- 3.5 Tablero FinOps: costo mensual del warehouse demo
SELECT
    usage_month,
    credits_consumed,
    total_cost_usd,
    total_cost_mxn,
    auto_suspend_minutes,
    avg_concurrency,
    notes
FROM MAXIKASH_DB.MAXIKASH_MONITORING_SCHEMA.WAREHOUSE_COSTS
ORDER BY usage_month;

