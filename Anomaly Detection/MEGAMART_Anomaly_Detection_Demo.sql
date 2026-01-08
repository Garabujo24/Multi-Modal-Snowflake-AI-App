-- =====================================================================
-- Sección 0: Historia y Caso de Uso
-- =====================================================================
/*
CLIENTE: Grupo Comercial Control (C Control)
WEB: https://www.ccontrol.com.mx/
INDUSTRIA: Retail - Tiendas Departamentales y Restaurantes

CONTEXTO DEL NEGOCIO:
Grupo Comercial Control es una empresa mexicana con más de 60 años de experiencia,
integrada por:
  - Tiendas Del Sol (desde 1963)
  - Tiendas Woolworth (desde 1997)
  - Restaurantes Noreste Grill (desde 2008)

Con más de 130 sucursales en 26 estados de la República Mexicana, el grupo enfrenta
el reto de monitorear ventas diarias y detectar comportamientos anómalos que puedan
indicar problemas operativos, eventos externos adversos o oportunidades de negocio.

PROBLEMA DE NEGOCIO:
¿Cómo detectar automáticamente anomalías en las ventas diarias considerando:
  1. Múltiples series de tiempo (por región, tipo de tienda, sucursal)
  2. Variables exógenas (clima, eventos adversos, días festivos)
  3. Patrones estacionales y tendencias
  4. Caídas inusuales de ventas y tickets promedio anormales

SOLUCIÓN TÉCNICA:
Utilizamos detección de anomalías basada en Z-Score estadístico con ventanas
móviles de 30 días para identificar patrones anómalos en ventas diarias multi-series,
incorporando variables exógenas como temperatura, precipitación, días festivos y 
eventos adversos. El algoritmo calcula la desviación de cada valor respecto a su
media histórica reciente, generando scores de anomalía interpretables.

ROL: Científico de Datos
TECNOLOGÍA: Snowflake SQL
PERIODO: Último año (365 días)
GRANULARIDAD: Diaria
*/

-- =====================================================================
-- Sección 1: Configuración de Recursos
-- =====================================================================

-- 1.1 Crear Warehouse optimizado para ML
CREATE OR REPLACE WAREHOUSE CCONTROL_ANALYTICS_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse para análisis de anomalías - Grupo Comercial Control';

-- 1.2 Crear Base de Datos
CREATE OR REPLACE DATABASE CCONTROL_DB
  COMMENT = 'Base de datos principal - Grupo Comercial Control';

-- 1.3 Crear Schema
CREATE OR REPLACE SCHEMA CCONTROL_DB.ANALYTICS
  COMMENT = 'Schema para detección de anomalías y ML';

-- 1.4 Usar contexto
USE WAREHOUSE CCONTROL_ANALYTICS_WH;
USE DATABASE CCONTROL_DB;
USE SCHEMA ANALYTICS;

-- 1.5 Crear Roles (opcional pero recomendado)
CREATE OR REPLACE ROLE CCONTROL_DATA_SCIENTIST;
GRANT USAGE ON WAREHOUSE CCONTROL_ANALYTICS_WH TO ROLE CCONTROL_DATA_SCIENTIST;
GRANT USAGE ON DATABASE CCONTROL_DB TO ROLE CCONTROL_DATA_SCIENTIST;
GRANT USAGE ON SCHEMA CCONTROL_DB.ANALYTICS TO ROLE CCONTROL_DATA_SCIENTIST;

-- 1.6 FinOps: Configuración de timeout para control de costos
ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = 3600;
SHOW PARAMETERS LIKE 'STATEMENT_TIMEOUT_IN_SECONDS';

-- 1.7 Crear tabla principal de ventas diarias (multi-series)
CREATE OR REPLACE TABLE CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS (
    FECHA DATE NOT NULL,
    REGION VARCHAR(50) NOT NULL,
    TIPO_TIENDA VARCHAR(50) NOT NULL,
    SUCURSAL VARCHAR(100) NOT NULL,
    SUCURSAL_ID INTEGER NOT NULL,
    
    -- Métricas principales
    VENTAS_TOTALES DECIMAL(12,2) NOT NULL,
    NUM_TRANSACCIONES INTEGER NOT NULL,
    TICKET_PROMEDIO DECIMAL(10,2) NOT NULL,
    NUM_CLIENTES INTEGER NOT NULL,
    
    -- Variables exógenas: Clima
    TEMPERATURA_C DECIMAL(4,1),
    PRECIPITACION_MM DECIMAL(5,1),
    HUMEDAD_PCT INTEGER,
    
    -- Variables exógenas: Eventos
    ES_DIA_FESTIVO BOOLEAN DEFAULT FALSE,
    ES_PROMOCION BOOLEAN DEFAULT FALSE,
    ES_EVENTO_ADVERSO BOOLEAN DEFAULT FALSE,
    TIPO_EVENTO VARCHAR(100),
    
    -- Variables temporales
    DIA_SEMANA INTEGER,
    ES_FIN_SEMANA BOOLEAN,
    ES_QUINCENA BOOLEAN,
    
    -- Metadata
    TIENE_ANOMALIA BOOLEAN DEFAULT FALSE,
    TIPO_ANOMALIA VARCHAR(50),
    
    PRIMARY KEY (FECHA, REGION, TIPO_TIENDA, SUCURSAL)
);

-- 1.8 Crear tabla de catálogo de sucursales
CREATE OR REPLACE TABLE CCONTROL_DB.ANALYTICS.CAT_SUCURSALES (
    SUCURSAL_ID INTEGER PRIMARY KEY,
    SUCURSAL VARCHAR(100) NOT NULL,
    TIPO_TIENDA VARCHAR(50) NOT NULL,
    REGION VARCHAR(50) NOT NULL,
    ESTADO VARCHAR(50) NOT NULL,
    CIUDAD VARCHAR(100) NOT NULL,
    FECHA_APERTURA DATE
);

-- =====================================================================
-- Sección 2: Generación de Datos Sintéticos
-- =====================================================================

-- 2.1 Insertar catálogo de sucursales
INSERT INTO CCONTROL_DB.ANALYTICS.CAT_SUCURSALES 
(SUCURSAL_ID, SUCURSAL, TIPO_TIENDA, REGION, ESTADO, CIUDAD, FECHA_APERTURA)
VALUES
    -- Región Norte
    (1, 'Del Sol Monterrey Centro', 'Del Sol', 'Norte', 'Nuevo León', 'Monterrey', '2010-03-15'),
    (2, 'Woolworth Monterrey San Pedro', 'Woolworth', 'Norte', 'Nuevo León', 'San Pedro Garza García', '2015-06-20'),
    (3, 'Noreste Grill Monterrey Valle', 'Noreste Grill', 'Norte', 'Nuevo León', 'Monterrey', '2018-08-10'),
    (4, 'Del Sol Chihuahua', 'Del Sol', 'Norte', 'Chihuahua', 'Chihuahua', '2012-05-12'),
    (5, 'Woolworth Tijuana', 'Woolworth', 'Norte', 'Baja California', 'Tijuana', '2016-09-25'),
    
    -- Región Centro
    (6, 'Del Sol CDMX Reforma', 'Del Sol', 'Centro', 'Ciudad de México', 'CDMX', '2008-01-20'),
    (7, 'Woolworth CDMX Polanco', 'Woolworth', 'Centro', 'Ciudad de México', 'CDMX', '2014-11-15'),
    (8, 'Del Sol Puebla Angelópolis', 'Del Sol', 'Centro', 'Puebla', 'Puebla', '2011-07-08'),
    (9, 'Woolworth Querétaro Centro', 'Woolworth', 'Centro', 'Querétaro', 'Querétaro', '2017-03-22'),
    
    -- Región Sur
    (10, 'Del Sol Guadalajara Zapopan', 'Del Sol', 'Sur', 'Jalisco', 'Zapopan', '2009-04-18'),
    (11, 'Woolworth Guadalajara Centro', 'Woolworth', 'Sur', 'Jalisco', 'Guadalajara', '2013-10-30'),
    (12, 'Noreste Grill Guadalajara', 'Noreste Grill', 'Sur', 'Jalisco', 'Guadalajara', '2019-02-14'),
    (13, 'Del Sol Cancún Plaza Las Américas', 'Del Sol', 'Sur', 'Quintana Roo', 'Cancún', '2016-12-05'),
    (14, 'Woolworth Mérida', 'Woolworth', 'Sur', 'Yucatán', 'Mérida', '2015-08-20'),
    (15, 'Del Sol Oaxaca Centro', 'Del Sol', 'Sur', 'Oaxaca', 'Oaxaca', '2014-06-11');

-- 2.2 Generar fechas para el último año (365 días)
CREATE OR REPLACE TEMPORARY TABLE TEMP_FECHAS AS
SELECT 
    DATEADD(DAY, -seq, CURRENT_DATE()) AS FECHA
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY NULL) - 1 AS seq
    FROM TABLE(GENERATOR(ROWCOUNT => 365))
);

-- 2.3 Generar datos base de ventas diarias (cross join: fechas x sucursales)
CREATE OR REPLACE TEMPORARY TABLE TEMP_VENTAS_BASE AS
SELECT 
    f.FECHA,
    s.REGION,
    s.TIPO_TIENDA,
    s.SUCURSAL,
    s.SUCURSAL_ID,
    
    -- Metadata temporal
    DAYOFWEEK(f.FECHA) AS DIA_SEMANA,
    CASE WHEN DAYOFWEEK(f.FECHA) IN (1, 7) THEN TRUE ELSE FALSE END AS ES_FIN_SEMANA,
    CASE WHEN DAYOFMONTH(f.FECHA) IN (15, 30, 31) THEN TRUE ELSE FALSE END AS ES_QUINCENA,
    
    -- Seed para reproducibilidad
    HASH(f.FECHA, s.SUCURSAL_ID) AS SEED_BASE
FROM TEMP_FECHAS f
CROSS JOIN CCONTROL_DB.ANALYTICS.CAT_SUCURSALES s;

-- 2.4 Generar ventas sintéticas con estacionalidad y tendencia
CREATE OR REPLACE TEMPORARY TABLE TEMP_VENTAS_COMPLETAS AS
SELECT 
    vb.*,
    
    -- Ventas base según tipo de tienda (promedio diario)
    CASE vb.TIPO_TIENDA
        WHEN 'Del Sol' THEN 85000
        WHEN 'Woolworth' THEN 120000
        WHEN 'Noreste Grill' THEN 45000
    END AS VENTAS_BASE,
    
    -- Factores multiplicativos
    -- 1. Estacionalidad mensual (alta en Nov-Dic, baja en Ene-Feb)
    (1 + 0.3 * SIN(2 * PI() * DAYOFYEAR(vb.FECHA) / 365.0)) AS FACTOR_ESTACIONAL,
    
    -- 2. Efecto día de semana (+ en fin de semana)
    CASE 
        WHEN vb.DIA_SEMANA IN (1, 7) THEN 1.25  -- Sábado/Domingo
        WHEN vb.DIA_SEMANA = 6 THEN 1.15        -- Viernes
        ELSE 1.0
    END AS FACTOR_DIA_SEMANA,
    
    -- 3. Efecto quincena (+ en días 15 y fin de mes)
    CASE WHEN vb.ES_QUINCENA THEN 1.3 ELSE 1.0 END AS FACTOR_QUINCENA,
    
    -- 4. Ruido aleatorio (+/- 15%) usando HASH para reproducibilidad
    (1 + (MOD(ABS(HASH(vb.FECHA, vb.SUCURSAL_ID)), 30) - 15) / 100.0) AS FACTOR_RUIDO,
    
    -- 5. Tendencia regional
    CASE vb.REGION
        WHEN 'Norte' THEN 1.05
        WHEN 'Centro' THEN 1.12
        WHEN 'Sur' THEN 0.98
    END AS FACTOR_REGION

FROM TEMP_VENTAS_BASE vb;

-- 2.5 Calcular métricas principales
CREATE OR REPLACE TEMPORARY TABLE TEMP_VENTAS_METRICAS AS
SELECT 
    vc.*,
    
    -- Ventas totales (aplicando todos los factores)
    ROUND(
        vc.VENTAS_BASE * 
        vc.FACTOR_ESTACIONAL * 
        vc.FACTOR_DIA_SEMANA * 
        vc.FACTOR_QUINCENA * 
        vc.FACTOR_RUIDO *
        vc.FACTOR_REGION
    , 2) AS VENTAS_TOTALES_CALC,
    
    -- Número de transacciones (basado en ventas)
    ROUND(
        (vc.VENTAS_BASE / 450) * 
        vc.FACTOR_DIA_SEMANA * 
        (1 + (MOD(ABS(HASH(vc.FECHA, vc.SUCURSAL_ID, 'trans')), 20) - 10) / 100.0)
    , 0) AS NUM_TRANSACCIONES_CALC,
    
    -- Número de clientes (80-95% de transacciones)
    ROUND(
        (vc.VENTAS_BASE / 450) * 
        vc.FACTOR_DIA_SEMANA * 
        (0.80 + MOD(ABS(HASH(vc.FECHA, vc.SUCURSAL_ID, 'clientes')), 15) / 100.0)
    , 0) AS NUM_CLIENTES_CALC

FROM TEMP_VENTAS_COMPLETAS vc;

-- 2.6 Agregar variables exógenas: CLIMA
CREATE OR REPLACE TEMPORARY TABLE TEMP_VENTAS_CLIMA AS
SELECT 
    vm.*,
    
    -- Temperatura (varía por región y estacionalidad)
    ROUND(
        CASE vm.REGION
            WHEN 'Norte' THEN 22 + 12 * SIN(2 * PI() * DAYOFYEAR(vm.FECHA) / 365.0)
            WHEN 'Centro' THEN 18 + 8 * SIN(2 * PI() * DAYOFYEAR(vm.FECHA) / 365.0)
            WHEN 'Sur' THEN 28 + 6 * SIN(2 * PI() * DAYOFYEAR(vm.FECHA) / 365.0)
        END + (MOD(ABS(HASH(vm.FECHA, vm.SUCURSAL_ID, 'temp')), 6) - 3)
    , 1) AS TEMPERATURA_C,
    
    -- Precipitación (más alta en verano)
    CASE 
        WHEN MONTH(vm.FECHA) BETWEEN 6 AND 9 THEN 
            ROUND(MOD(ABS(HASH(vm.FECHA, vm.SUCURSAL_ID, 'prec_verano')), 35), 1)
        ELSE 
            ROUND(MOD(ABS(HASH(vm.FECHA, vm.SUCURSAL_ID, 'prec_resto')), 8), 1)
    END AS PRECIPITACION_MM,
    
    -- Humedad (correlacionada con precipitación)
    CASE 
        WHEN MONTH(vm.FECHA) BETWEEN 6 AND 9 THEN 
            60 + MOD(ABS(HASH(vm.FECHA, vm.SUCURSAL_ID, 'hum_verano')), 30)
        ELSE 
            35 + MOD(ABS(HASH(vm.FECHA, vm.SUCURSAL_ID, 'hum_resto')), 30)
    END AS HUMEDAD_PCT

FROM TEMP_VENTAS_METRICAS vm;

-- 2.7 Agregar variables exógenas: EVENTOS
CREATE OR REPLACE TEMPORARY TABLE TEMP_VENTAS_EVENTOS AS
SELECT 
    vc.*,
    
    -- Días festivos mexicanos importantes (2024-2025)
    CASE 
        WHEN MONTH(vc.FECHA) = 1 AND DAY(vc.FECHA) = 1 THEN TRUE  -- Año Nuevo
        WHEN MONTH(vc.FECHA) = 2 AND DAY(vc.FECHA) = 14 THEN TRUE -- San Valentín
        WHEN MONTH(vc.FECHA) = 3 AND DAY(vc.FECHA) = 21 THEN TRUE -- Benito Juárez
        WHEN MONTH(vc.FECHA) = 5 AND DAY(vc.FECHA) = 1 THEN TRUE  -- Día del Trabajo
        WHEN MONTH(vc.FECHA) = 5 AND DAY(vc.FECHA) = 10 THEN TRUE -- Día de las Madres
        WHEN MONTH(vc.FECHA) = 9 AND DAY(vc.FECHA) = 16 THEN TRUE -- Independencia
        WHEN MONTH(vc.FECHA) = 11 AND DAY(vc.FECHA) = 20 THEN TRUE -- Revolución
        WHEN MONTH(vc.FECHA) = 12 AND DAY(vc.FECHA) = 12 THEN TRUE -- Guadalupe
        WHEN MONTH(vc.FECHA) = 12 AND DAY(vc.FECHA) = 25 THEN TRUE -- Navidad
        ELSE FALSE
    END AS ES_DIA_FESTIVO,
    
    -- Promociones (días aleatorios, ~8% de los días)
    CASE 
        WHEN MOD(HASH(vc.FECHA, vc.SUCURSAL_ID), 100) < 8 THEN TRUE
        ELSE FALSE
    END AS ES_PROMOCION,
    
    -- Eventos adversos inicialmente en FALSE (los agregaremos específicamente)
    FALSE AS ES_EVENTO_ADVERSO,
    NULL AS TIPO_EVENTO

FROM TEMP_VENTAS_CLIMA vc;

-- 2.8 Calcular ticket promedio
CREATE OR REPLACE TEMPORARY TABLE TEMP_VENTAS_FINAL_BASE AS
SELECT 
    ve.FECHA,
    ve.REGION,
    ve.TIPO_TIENDA,
    ve.SUCURSAL,
    ve.SUCURSAL_ID,
    
    -- Ajustar ventas por eventos
    CASE 
        WHEN ve.ES_DIA_FESTIVO THEN ROUND(ve.VENTAS_TOTALES_CALC * 1.45, 2)
        WHEN ve.ES_PROMOCION THEN ROUND(ve.VENTAS_TOTALES_CALC * 1.25, 2)
        ELSE ve.VENTAS_TOTALES_CALC
    END AS VENTAS_TOTALES,
    
    -- Ajustar transacciones por eventos
    CASE 
        WHEN ve.ES_DIA_FESTIVO THEN ROUND(ve.NUM_TRANSACCIONES_CALC * 1.35, 0)
        WHEN ve.ES_PROMOCION THEN ROUND(ve.NUM_TRANSACCIONES_CALC * 1.28, 0)
        ELSE ve.NUM_TRANSACCIONES_CALC
    END AS NUM_TRANSACCIONES,
    
    ve.NUM_CLIENTES_CALC AS NUM_CLIENTES,
    
    -- Variables exógenas
    ve.TEMPERATURA_C,
    ve.PRECIPITACION_MM,
    ve.HUMEDAD_PCT,
    ve.ES_DIA_FESTIVO,
    ve.ES_PROMOCION,
    ve.ES_EVENTO_ADVERSO,
    ve.TIPO_EVENTO,
    
    -- Variables temporales
    ve.DIA_SEMANA,
    ve.ES_FIN_SEMANA,
    ve.ES_QUINCENA,
    
    -- Metadata
    FALSE AS TIENE_ANOMALIA,
    NULL AS TIPO_ANOMALIA

FROM TEMP_VENTAS_EVENTOS ve;

-- Calcular ticket promedio
CREATE OR REPLACE TEMPORARY TABLE TEMP_VENTAS_CON_TICKET AS
SELECT 
    vf.*,
    ROUND(vf.VENTAS_TOTALES / NULLIF(vf.NUM_TRANSACCIONES, 0), 2) AS TICKET_PROMEDIO
FROM TEMP_VENTAS_FINAL_BASE vf;

-- 2.9 Insertar datos base en la tabla principal
INSERT INTO CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS
SELECT 
    FECHA,
    REGION,
    TIPO_TIENDA,
    SUCURSAL,
    SUCURSAL_ID,
    VENTAS_TOTALES,
    NUM_TRANSACCIONES,
    TICKET_PROMEDIO,
    NUM_CLIENTES,
    TEMPERATURA_C,
    PRECIPITACION_MM,
    HUMEDAD_PCT,
    ES_DIA_FESTIVO,
    ES_PROMOCION,
    ES_EVENTO_ADVERSO,
    TIPO_EVENTO,
    DIA_SEMANA,
    ES_FIN_SEMANA,
    ES_QUINCENA,
    TIENE_ANOMALIA,
    TIPO_ANOMALIA
FROM TEMP_VENTAS_CON_TICKET;

-- 2.10 Insertar ANOMALÍAS SINTÉTICAS - Caídas de Ventas
-- Anomalía 1: Evento climático extremo (Huracán en Cancún)
UPDATE CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS
SET 
    VENTAS_TOTALES = VENTAS_TOTALES * 0.25,
    NUM_TRANSACCIONES = ROUND(NUM_TRANSACCIONES * 0.30, 0),
    TICKET_PROMEDIO = ROUND(VENTAS_TOTALES * 0.25 / NULLIF(ROUND(NUM_TRANSACCIONES * 0.30, 0), 1), 2),
    PRECIPITACION_MM = 85.5,
    ES_EVENTO_ADVERSO = TRUE,
    TIPO_EVENTO = 'Huracán - Cierre temporal',
    TIENE_ANOMALIA = TRUE,
    TIPO_ANOMALIA = 'Caída de ventas - Clima extremo'
WHERE SUCURSAL = 'Del Sol Cancún Plaza Las Américas'
  AND FECHA BETWEEN DATEADD(DAY, -60, CURRENT_DATE()) 
                AND DATEADD(DAY, -57, CURRENT_DATE());

-- Anomalía 2: Problema operativo (Falla eléctrica en CDMX)
UPDATE CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS
SET 
    VENTAS_TOTALES = VENTAS_TOTALES * 0.15,
    NUM_TRANSACCIONES = ROUND(NUM_TRANSACCIONES * 0.18, 0),
    TICKET_PROMEDIO = ROUND(VENTAS_TOTALES * 0.15 / NULLIF(ROUND(NUM_TRANSACCIONES * 0.18, 0), 1), 2),
    ES_EVENTO_ADVERSO = TRUE,
    TIPO_EVENTO = 'Falla eléctrica - Cierre de 6 horas',
    TIENE_ANOMALIA = TRUE,
    TIPO_ANOMALIA = 'Caída de ventas - Operativo'
WHERE SUCURSAL IN ('Del Sol CDMX Reforma', 'Woolworth CDMX Polanco')
  AND FECHA = DATEADD(DAY, -90, CURRENT_DATE());

-- Anomalía 3: Construcción cercana (Obras viales en Monterrey)
UPDATE CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS
SET 
    VENTAS_TOTALES = VENTAS_TOTALES * 0.65,
    NUM_TRANSACCIONES = ROUND(NUM_TRANSACCIONES * 0.70, 0),
    TICKET_PROMEDIO = ROUND(VENTAS_TOTALES * 0.65 / NULLIF(ROUND(NUM_TRANSACCIONES * 0.70, 0), 1), 2),
    ES_EVENTO_ADVERSO = TRUE,
    TIPO_EVENTO = 'Obras viales - Acceso restringido',
    TIENE_ANOMALIA = TRUE,
    TIPO_ANOMALIA = 'Caída de ventas - Infraestructura'
WHERE SUCURSAL = 'Del Sol Monterrey Centro'
  AND FECHA BETWEEN DATEADD(DAY, -120, CURRENT_DATE()) 
                AND DATEADD(DAY, -105, CURRENT_DATE());

-- Anomalía 4: Ticket promedio anormalmente bajo (Problema en sistema de cobro)
UPDATE CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS
SET 
    TICKET_PROMEDIO = TICKET_PROMEDIO * 0.55,
    VENTAS_TOTALES = ROUND(TICKET_PROMEDIO * 0.55 * NUM_TRANSACCIONES, 2),
    ES_EVENTO_ADVERSO = TRUE,
    TIPO_EVENTO = 'Error sistema POS - Transacciones incompletas',
    TIENE_ANOMALIA = TRUE,
    TIPO_ANOMALIA = 'Ticket promedio anormalmente bajo'
WHERE SUCURSAL IN ('Woolworth Guadalajara Centro', 'Noreste Grill Guadalajara')
  AND FECHA BETWEEN DATEADD(DAY, -45, CURRENT_DATE()) 
                AND DATEADD(DAY, -43, CURRENT_DATE());

-- Anomalía 5: Caída generalizada en región Norte (Evento de seguridad)
UPDATE CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS
SET 
    VENTAS_TOTALES = VENTAS_TOTALES * 0.50,
    NUM_TRANSACCIONES = ROUND(NUM_TRANSACCIONES * 0.55, 0),
    TICKET_PROMEDIO = ROUND(VENTAS_TOTALES * 0.50 / NULLIF(ROUND(NUM_TRANSACCIONES * 0.55, 0), 1), 2),
    ES_EVENTO_ADVERSO = TRUE,
    TIPO_EVENTO = 'Alerta de seguridad regional',
    TIENE_ANOMALIA = TRUE,
    TIPO_ANOMALIA = 'Caída de ventas - Seguridad'
WHERE REGION = 'Norte'
  AND FECHA BETWEEN DATEADD(DAY, -180, CURRENT_DATE()) 
                AND DATEADD(DAY, -178, CURRENT_DATE());

-- Anomalía 6: Ticket promedio inusualmente alto (Compras de temporada navideña)
UPDATE CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS
SET 
    TICKET_PROMEDIO = TICKET_PROMEDIO * 1.85,
    VENTAS_TOTALES = ROUND(TICKET_PROMEDIO * 1.85 * NUM_TRANSACCIONES, 2),
    TIPO_ANOMALIA = 'Ticket promedio inusualmente alto'
WHERE TIPO_TIENDA = 'Woolworth'
  AND MONTH(FECHA) = 12
  AND DAY(FECHA) BETWEEN 20 AND 24;

-- =====================================================================
-- Sección 3: La Demo - Detección de Anomalías con Snowflake
-- =====================================================================

-- 3.1 VISTA PREPARADA: Datos para modelo de anomalías
CREATE OR REPLACE VIEW CCONTROL_DB.ANALYTICS.VW_VENTAS_PARA_MODELO AS
SELECT 
    FECHA,
    REGION,
    TIPO_TIENDA,
    SUCURSAL,
    SUCURSAL_ID,
    VENTAS_TOTALES,
    NUM_TRANSACCIONES,
    TICKET_PROMEDIO,
    NUM_CLIENTES,
    
    -- Variables exógenas normalizadas
    TEMPERATURA_C,
    PRECIPITACION_MM,
    HUMEDAD_PCT / 100.0 AS HUMEDAD_DECIMAL,
    
    -- Variables binarias
    IFF(ES_DIA_FESTIVO, 1, 0) AS FLAG_FESTIVO,
    IFF(ES_PROMOCION, 1, 0) AS FLAG_PROMOCION,
    IFF(ES_FIN_SEMANA, 1, 0) AS FLAG_FIN_SEMANA,
    IFF(ES_QUINCENA, 1, 0) AS FLAG_QUINCENA,
    
    -- Variables cíclicas (para capturar estacionalidad)
    SIN(2 * PI() * DAYOFYEAR(FECHA) / 365.0) AS SIN_DIA_ANIO,
    COS(2 * PI() * DAYOFYEAR(FECHA) / 365.0) AS COS_DIA_ANIO,
    SIN(2 * PI() * DIA_SEMANA / 7.0) AS SIN_DIA_SEMANA,
    COS(2 * PI() * DIA_SEMANA / 7.0) AS COS_DIA_SEMANA,
    
    -- Metadata
    TIENE_ANOMALIA,
    TIPO_ANOMALIA,
    TIPO_EVENTO
    
FROM CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS
ORDER BY FECHA, REGION, TIPO_TIENDA, SUCURSAL;

-- 3.2 DETECCIÓN DE ANOMALÍAS: Ventas Totales (Multi-Series)
-- Usamos Z-Score para detectar anomalías por sucursal
CREATE OR REPLACE TABLE CCONTROL_DB.ANALYTICS.RESULTADO_ANOMALIAS_VENTAS AS
WITH ESTADISTICAS_BASE AS (
    SELECT 
        FECHA,
        REGION,
        TIPO_TIENDA,
        SUCURSAL,
        SUCURSAL_ID,
        VENTAS_TOTALES AS VALOR_REAL,
        
        -- Calcular media móvil y desviación estándar por sucursal
        AVG(VENTAS_TOTALES) OVER (
            PARTITION BY SUCURSAL 
            ORDER BY FECHA 
            ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING
        ) AS MEDIA_MOVIL_30D,
        
        STDDEV(VENTAS_TOTALES) OVER (
            PARTITION BY SUCURSAL 
            ORDER BY FECHA 
            ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING
        ) AS STDDEV_MOVIL_30D,
        
        -- También calculamos estadísticas globales de toda la serie por sucursal
        AVG(VENTAS_TOTALES) OVER (PARTITION BY SUCURSAL) AS MEDIA_GLOBAL,
        STDDEV(VENTAS_TOTALES) OVER (PARTITION BY SUCURSAL) AS STDDEV_GLOBAL,
        
        TIENE_ANOMALIA AS ANOMALIA_REAL,
        TIPO_ANOMALIA AS TIPO_ANOMALIA_REAL,
        TIPO_EVENTO,
        TEMPERATURA_C,
        PRECIPITACION_MM,
        FLAG_FESTIVO,
        FLAG_PROMOCION
        
    FROM CCONTROL_DB.ANALYTICS.VW_VENTAS_PARA_MODELO
),
ANOMALIAS_CALCULADAS AS (
    SELECT 
        FECHA,
        REGION,
        TIPO_TIENDA,
        SUCURSAL,
        SUCURSAL_ID,
        VALOR_REAL,
        MEDIA_MOVIL_30D,
        STDDEV_MOVIL_30D,
        MEDIA_GLOBAL,
        STDDEV_GLOBAL,
        ANOMALIA_REAL,
        TIPO_ANOMALIA_REAL,
        TIPO_EVENTO,
        TEMPERATURA_C,
        PRECIPITACION_MM,
        FLAG_FESTIVO,
        FLAG_PROMOCION,
        
        -- Z-Score usando ventana móvil de 30 días (prioriza patrones recientes)
        CASE 
            WHEN STDDEV_MOVIL_30D > 0 THEN 
                ABS((VALOR_REAL - MEDIA_MOVIL_30D) / STDDEV_MOVIL_30D)
            WHEN STDDEV_GLOBAL > 0 THEN
                ABS((VALOR_REAL - MEDIA_GLOBAL) / STDDEV_GLOBAL)
            ELSE 0
        END AS ANOMALY_SCORE
    FROM ESTADISTICAS_BASE
)
SELECT 
    FECHA,
    REGION,
    TIPO_TIENDA,
    SUCURSAL,
    SUCURSAL_ID,
    VALOR_REAL,
    ROUND(ANOMALY_SCORE, 4) AS ANOMALY_SCORE,
    ROUND(MEDIA_MOVIL_30D, 2) AS MEDIA_ESPERADA,
    ROUND(STDDEV_MOVIL_30D, 2) AS DESVIACION_ESTANDAR,
    
    -- Clasificación de anomalía basada en Z-Score
    CASE 
        WHEN ANOMALY_SCORE > 3.0 THEN 'Anomalía Alta'      -- >99.7% de confianza
        WHEN ANOMALY_SCORE > 2.5 THEN 'Anomalía Media'     -- >98.8% de confianza
        WHEN ANOMALY_SCORE > 2.0 THEN 'Anomalía Baja'      -- >95.4% de confianza
        ELSE 'Normal'
    END AS CLASIFICACION_ANOMALIA,
    
    -- Dirección de la anomalía
    CASE 
        WHEN VALOR_REAL > MEDIA_MOVIL_30D AND ANOMALY_SCORE > 2.0 THEN 'Pico inusual'
        WHEN VALOR_REAL < MEDIA_MOVIL_30D AND ANOMALY_SCORE > 2.0 THEN 'Caída inusual'
        ELSE 'Normal'
    END AS DIRECCION_ANOMALIA,
    
    ANOMALIA_REAL,
    TIPO_ANOMALIA_REAL,
    TIPO_EVENTO,
    TEMPERATURA_C,
    PRECIPITACION_MM,
    FLAG_FESTIVO AS ES_DIA_FESTIVO,
    FLAG_PROMOCION AS ES_PROMOCION
    
FROM ANOMALIAS_CALCULADAS
WHERE ANOMALY_SCORE > 2.0  -- Solo anomalías significativas (>95% confianza)
ORDER BY ANOMALY_SCORE DESC, FECHA DESC;

-- 3.3 DETECCIÓN DE ANOMALÍAS: Ticket Promedio (Multi-Series)
CREATE OR REPLACE TABLE CCONTROL_DB.ANALYTICS.RESULTADO_ANOMALIAS_TICKET AS
WITH ESTADISTICAS_BASE AS (
    SELECT 
        FECHA,
        REGION,
        TIPO_TIENDA,
        SUCURSAL,
        SUCURSAL_ID,
        TICKET_PROMEDIO AS VALOR_REAL,
        
        -- Calcular media móvil y desviación estándar por sucursal
        AVG(TICKET_PROMEDIO) OVER (
            PARTITION BY SUCURSAL 
            ORDER BY FECHA 
            ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING
        ) AS MEDIA_MOVIL_30D,
        
        STDDEV(TICKET_PROMEDIO) OVER (
            PARTITION BY SUCURSAL 
            ORDER BY FECHA 
            ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING
        ) AS STDDEV_MOVIL_30D,
        
        -- También calculamos estadísticas globales de toda la serie por sucursal
        AVG(TICKET_PROMEDIO) OVER (PARTITION BY SUCURSAL) AS MEDIA_GLOBAL,
        STDDEV(TICKET_PROMEDIO) OVER (PARTITION BY SUCURSAL) AS STDDEV_GLOBAL,
        
        TIENE_ANOMALIA AS ANOMALIA_REAL,
        TIPO_ANOMALIA AS TIPO_ANOMALIA_REAL,
        TIPO_EVENTO,
        TEMPERATURA_C,
        PRECIPITACION_MM
        
    FROM CCONTROL_DB.ANALYTICS.VW_VENTAS_PARA_MODELO
),
ANOMALIAS_CALCULADAS AS (
    SELECT 
        FECHA,
        REGION,
        TIPO_TIENDA,
        SUCURSAL,
        SUCURSAL_ID,
        VALOR_REAL,
        MEDIA_MOVIL_30D,
        STDDEV_MOVIL_30D,
        MEDIA_GLOBAL,
        STDDEV_GLOBAL,
        ANOMALIA_REAL,
        TIPO_ANOMALIA_REAL,
        TIPO_EVENTO,
        TEMPERATURA_C,
        PRECIPITACION_MM,
        
        -- Z-Score usando ventana móvil de 30 días
        CASE 
            WHEN STDDEV_MOVIL_30D > 0 THEN 
                ABS((VALOR_REAL - MEDIA_MOVIL_30D) / STDDEV_MOVIL_30D)
            WHEN STDDEV_GLOBAL > 0 THEN
                ABS((VALOR_REAL - MEDIA_GLOBAL) / STDDEV_GLOBAL)
            ELSE 0
        END AS ANOMALY_SCORE
    FROM ESTADISTICAS_BASE
)
SELECT 
    FECHA,
    REGION,
    TIPO_TIENDA,
    SUCURSAL,
    SUCURSAL_ID,
    VALOR_REAL,
    ROUND(ANOMALY_SCORE, 4) AS ANOMALY_SCORE,
    ROUND(MEDIA_MOVIL_30D, 2) AS MEDIA_ESPERADA,
    ROUND(STDDEV_MOVIL_30D, 2) AS DESVIACION_ESTANDAR,
    
    -- Clasificación de anomalía basada en Z-Score
    CASE 
        WHEN ANOMALY_SCORE > 3.0 THEN 'Anomalía Alta'      -- >99.7% de confianza
        WHEN ANOMALY_SCORE > 2.5 THEN 'Anomalía Media'     -- >98.8% de confianza
        WHEN ANOMALY_SCORE > 2.0 THEN 'Anomalía Baja'      -- >95.4% de confianza
        ELSE 'Normal'
    END AS CLASIFICACION_ANOMALIA,
    
    -- Dirección de la anomalía
    CASE 
        WHEN VALOR_REAL > MEDIA_MOVIL_30D AND ANOMALY_SCORE > 2.0 THEN 'Ticket inusualmente alto'
        WHEN VALOR_REAL < MEDIA_MOVIL_30D AND ANOMALY_SCORE > 2.0 THEN 'Ticket inusualmente bajo'
        ELSE 'Normal'
    END AS DIRECCION_ANOMALIA,
    
    ANOMALIA_REAL,
    TIPO_ANOMALIA_REAL,
    TIPO_EVENTO,
    TEMPERATURA_C,
    PRECIPITACION_MM
    
FROM ANOMALIAS_CALCULADAS
WHERE ANOMALY_SCORE > 2.0  -- Solo anomalías significativas (>95% confianza)
ORDER BY ANOMALY_SCORE DESC, FECHA DESC;

-- 3.4 ANÁLISIS AGREGADO: Top anomalías detectadas
CREATE OR REPLACE VIEW CCONTROL_DB.ANALYTICS.VW_TOP_ANOMALIAS AS
SELECT 
    FECHA,
    REGION,
    TIPO_TIENDA,
    SUCURSAL,
    'Ventas Totales' AS METRICA,
    ANOMALY_SCORE,
    CLASIFICACION_ANOMALIA,
    DIRECCION_ANOMALIA,
    VALOR_REAL,
    MEDIA_ESPERADA,
    DESVIACION_ESTANDAR,
    ANOMALIA_REAL,
    TIPO_ANOMALIA_REAL,
    TIPO_EVENTO
FROM CCONTROL_DB.ANALYTICS.RESULTADO_ANOMALIAS_VENTAS

UNION ALL

SELECT 
    FECHA,
    REGION,
    TIPO_TIENDA,
    SUCURSAL,
    'Ticket Promedio' AS METRICA,
    ANOMALY_SCORE,
    CLASIFICACION_ANOMALIA,
    DIRECCION_ANOMALIA,
    VALOR_REAL,
    MEDIA_ESPERADA,
    DESVIACION_ESTANDAR,
    ANOMALIA_REAL,
    TIPO_ANOMALIA_REAL,
    TIPO_EVENTO
FROM CCONTROL_DB.ANALYTICS.RESULTADO_ANOMALIAS_TICKET

ORDER BY ANOMALY_SCORE DESC;

-- 3.5 DASHBOARD: Resumen ejecutivo de anomalías por región
SELECT 
    REGION,
    COUNT(*) AS TOTAL_ANOMALIAS,
    SUM(CASE WHEN CLASIFICACION_ANOMALIA = 'Anomalía Alta' THEN 1 ELSE 0 END) AS ANOMALIAS_ALTAS,
    SUM(CASE WHEN CLASIFICACION_ANOMALIA = 'Anomalía Media' THEN 1 ELSE 0 END) AS ANOMALIAS_MEDIAS,
    SUM(CASE WHEN CLASIFICACION_ANOMALIA = 'Anomalía Baja' THEN 1 ELSE 0 END) AS ANOMALIAS_BAJAS,
    ROUND(AVG(ANOMALY_SCORE), 2) AS ANOMALY_SCORE_PROMEDIO
FROM CCONTROL_DB.ANALYTICS.VW_TOP_ANOMALIAS
GROUP BY REGION
ORDER BY TOTAL_ANOMALIAS DESC;

-- 3.6 DASHBOARD: Resumen por tipo de tienda
SELECT 
    TIPO_TIENDA,
    COUNT(*) AS TOTAL_ANOMALIAS,
    ROUND(AVG(ANOMALY_SCORE), 2) AS ANOMALY_SCORE_PROMEDIO,
    COUNT(DISTINCT SUCURSAL) AS SUCURSALES_AFECTADAS
FROM CCONTROL_DB.ANALYTICS.VW_TOP_ANOMALIAS
GROUP BY TIPO_TIENDA
ORDER BY TOTAL_ANOMALIAS DESC;

-- 3.7 ANÁLISIS: Correlación entre anomalías y eventos adversos
SELECT 
    TIPO_EVENTO,
    COUNT(*) AS FRECUENCIA,
    ROUND(AVG(ANOMALY_SCORE), 2) AS ANOMALY_SCORE_PROMEDIO,
    ROUND(AVG(VALOR_REAL), 2) AS VALOR_PROMEDIO
FROM CCONTROL_DB.ANALYTICS.VW_TOP_ANOMALIAS
WHERE TIPO_EVENTO IS NOT NULL
GROUP BY TIPO_EVENTO
ORDER BY FRECUENCIA DESC;

-- 3.8 ANÁLISIS: Timeline de anomalías (últimos 180 días)
SELECT 
    DATE_TRUNC('WEEK', FECHA) AS SEMANA,
    COUNT(*) AS TOTAL_ANOMALIAS,
    COUNT(DISTINCT SUCURSAL) AS SUCURSALES_AFECTADAS,
    ROUND(AVG(ANOMALY_SCORE), 2) AS ANOMALY_SCORE_PROMEDIO
FROM CCONTROL_DB.ANALYTICS.VW_TOP_ANOMALIAS
WHERE FECHA >= DATEADD(DAY, -180, CURRENT_DATE())
GROUP BY SEMANA
ORDER BY SEMANA DESC;

-- =====================================================================
-- Sección 4: Queries de Diagnóstico y Validación
-- =====================================================================

-- 4.1 Validación: Conteo de registros totales
SELECT 
    'Total de registros' AS METRICA,
    COUNT(*) AS VALOR
FROM CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS

UNION ALL

SELECT 
    'Registros con anomalías sintéticas' AS METRICA,
    COUNT(*) AS VALOR
FROM CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS
WHERE TIENE_ANOMALIA = TRUE

UNION ALL

SELECT 
    'Anomalías detectadas (Ventas)' AS METRICA,
    COUNT(*) AS VALOR
FROM CCONTROL_DB.ANALYTICS.RESULTADO_ANOMALIAS_VENTAS

UNION ALL

SELECT 
    'Anomalías detectadas (Ticket)' AS METRICA,
    COUNT(*) AS VALOR
FROM CCONTROL_DB.ANALYTICS.RESULTADO_ANOMALIAS_TICKET;

-- 4.2 Validación: Rangos de datos
SELECT 
    'Ventas Totales' AS METRICA,
    ROUND(MIN(VENTAS_TOTALES), 2) AS MIN_VALOR,
    ROUND(AVG(VENTAS_TOTALES), 2) AS PROMEDIO,
    ROUND(MAX(VENTAS_TOTALES), 2) AS MAX_VALOR,
    ROUND(STDDEV(VENTAS_TOTALES), 2) AS DESV_ESTANDAR
FROM CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS

UNION ALL

SELECT 
    'Ticket Promedio' AS METRICA,
    ROUND(MIN(TICKET_PROMEDIO), 2) AS MIN_VALOR,
    ROUND(AVG(TICKET_PROMEDIO), 2) AS PROMEDIO,
    ROUND(MAX(TICKET_PROMEDIO), 2) AS MAX_VALOR,
    ROUND(STDDEV(TICKET_PROMEDIO), 2) AS DESV_ESTANDAR
FROM CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS

UNION ALL

SELECT 
    'Temperatura (°C)' AS METRICA,
    ROUND(MIN(TEMPERATURA_C), 2) AS MIN_VALOR,
    ROUND(AVG(TEMPERATURA_C), 2) AS PROMEDIO,
    ROUND(MAX(TEMPERATURA_C), 2) AS MAX_VALOR,
    ROUND(STDDEV(TEMPERATURA_C), 2) AS DESV_ESTANDAR
FROM CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS;

-- 4.3 Validación: Distribución de ventas por tipo de tienda
SELECT 
    TIPO_TIENDA,
    COUNT(*) AS TOTAL_DIAS,
    COUNT(DISTINCT SUCURSAL) AS NUM_SUCURSALES,
    ROUND(AVG(VENTAS_TOTALES), 2) AS VENTAS_PROMEDIO,
    ROUND(AVG(TICKET_PROMEDIO), 2) AS TICKET_PROMEDIO_AVG,
    ROUND(AVG(NUM_TRANSACCIONES), 0) AS TRANSACCIONES_PROMEDIO
FROM CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS
GROUP BY TIPO_TIENDA
ORDER BY VENTAS_PROMEDIO DESC;

-- 4.4 Validación: Verificar cobertura temporal
SELECT 
    MIN(FECHA) AS FECHA_INICIO,
    MAX(FECHA) AS FECHA_FIN,
    DATEDIFF(DAY, MIN(FECHA), MAX(FECHA)) + 1 AS DIAS_TOTALES,
    COUNT(DISTINCT FECHA) AS DIAS_UNICOS,
    COUNT(DISTINCT SUCURSAL) AS SUCURSALES_TOTALES
FROM CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS;

-- 4.5 Validación: Anomalías sintéticas vs detectadas
SELECT 
    v.FECHA,
    v.SUCURSAL,
    v.TIPO_ANOMALIA AS ANOMALIA_SINTETICA,
    rv.CLASIFICACION_ANOMALIA AS ANOMALIA_DETECTADA_VENTAS,
    rv.ANOMALY_SCORE AS SCORE_VENTAS,
    rt.CLASIFICACION_ANOMALIA AS ANOMALIA_DETECTADA_TICKET,
    rt.ANOMALY_SCORE AS SCORE_TICKET
FROM CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS v
LEFT JOIN CCONTROL_DB.ANALYTICS.RESULTADO_ANOMALIAS_VENTAS rv
    ON v.FECHA = rv.FECHA AND v.SUCURSAL = rv.SUCURSAL
LEFT JOIN CCONTROL_DB.ANALYTICS.RESULTADO_ANOMALIAS_TICKET rt
    ON v.FECHA = rt.FECHA AND v.SUCURSAL = rt.SUCURSAL
WHERE v.TIENE_ANOMALIA = TRUE
ORDER BY v.FECHA DESC, v.SUCURSAL;

-- 4.6 Diagnóstico: Efectividad de detección
SELECT 
    'Anomalías sintéticas totales' AS CATEGORIA,
    COUNT(DISTINCT CONCAT(FECHA, SUCURSAL)) AS CANTIDAD
FROM CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS
WHERE TIENE_ANOMALIA = TRUE

UNION ALL

SELECT 
    'Anomalías detectadas correctamente' AS CATEGORIA,
    COUNT(DISTINCT CONCAT(v.FECHA, v.SUCURSAL)) AS CANTIDAD
FROM CCONTROL_DB.ANALYTICS.VENTAS_DIARIAS v
INNER JOIN CCONTROL_DB.ANALYTICS.RESULTADO_ANOMALIAS_VENTAS rv
    ON v.FECHA = rv.FECHA AND v.SUCURSAL = rv.SUCURSAL
WHERE v.TIENE_ANOMALIA = TRUE AND rv.ANOMALY_SCORE > 2.0;

-- 4.7 FinOps: Costo estimado de la consulta
SELECT 
    'Warehouse utilizado' AS PARAMETRO,
    CURRENT_WAREHOUSE() AS VALOR
UNION ALL
SELECT 
    'Tamaño del warehouse' AS PARAMETRO,
    (SELECT VALUE FROM TABLE(RESULT_SCAN(LAST_QUERY_ID(-2))) 
     WHERE "property" = 'SIZE') AS VALOR;

-- 4.8 Query final: Vista completa para exploración
SELECT * 
FROM CCONTROL_DB.ANALYTICS.VW_TOP_ANOMALIAS
ORDER BY ANOMALY_SCORE DESC
LIMIT 50;

-- =====================================================================
-- FIN DEL SCRIPT
-- =====================================================================
/*
RESULTADOS ESPERADOS:
1. Base de datos completa con 15 sucursales x 365 días = 5,475 registros
2. Multi-series de tiempo por región (Norte, Centro, Sur) y tipo de tienda
3. Variables exógenas: clima (temperatura, precipitación) y eventos
4. ~6 tipos de anomalías sintéticas insertadas
5. Detección automática de anomalías usando Z-Score con ventanas móviles de 30 días
6. Dashboards y vistas para análisis ejecutivo

METODOLOGÍA DE DETECCIÓN:
- Se utiliza Z-Score estadístico: z = (valor - media) / desviación_estándar
- Ventana móvil de 30 días para adaptarse a tendencias recientes
- Umbrales de detección:
  * Z-Score > 3.0: Anomalía Alta (>99.7% confianza)
  * Z-Score > 2.5: Anomalía Media (>98.8% confianza)
  * Z-Score > 2.0: Anomalía Baja (>95.4% confianza)
- Análisis multi-series independiente por sucursal

PRÓXIMOS PASOS:
1. Visualizar resultados en Snowsight o herramienta de BI
2. Ajustar umbrales de detección según necesidad del negocio
3. Integrar alertas automáticas para anomalías en tiempo real
4. Expandir modelo con más variables exógenas (inventario, competencia)
5. Implementar modelos de ML más avanzados (ARIMA, Prophet, Isolation Forest)

COSTO ESTIMADO:
- Warehouse XSMALL con auto-suspend 60s
- Ejecución completa: ~2-3 minutos
- Costo aproximado: < $0.10 USD por ejecución completa

CONTACTO:
Para consultas o personalizaciones, contactar al equipo de Data Science.
*/
