-- =====================================================================
-- DATOS DE INFERENCIA: Semana de nuevos datos para detectar anomalías
-- =====================================================================
/*
PROPÓSITO:
Este script inserta una semana de datos nuevos (no etiquetados) en la tabla
de ventas para simular un escenario real de inferencia donde NO sabemos
si existen anomalías hasta que ejecutamos el modelo de detección.

ESTRUCTURA:
- Las columnas coinciden EXACTAMENTE con la tabla VENTAS_DIARIAS
- Orden de columnas: FECHA, REGION, TIPO_TIENDA, SUCURSAL, SUCURSAL_ID,
  VENTAS_TOTALES, NUM_TRANSACCIONES, TICKET_PROMEDIO, NUM_CLIENTES,
  TEMPERATURA_C, PRECIPITACION_MM, HUMEDAD_PCT, ES_DIA_FESTIVO,
  ES_PROMOCION, ES_EVENTO_ADVERSO, TIPO_EVENTO, DIA_SEMANA,
  ES_FIN_SEMANA, ES_QUINCENA, TIENE_ANOMALIA, TIPO_ANOMALIA

ANOMALÍAS OCULTAS (para validar el modelo):
1. Caída severa en MegaPlaza CDMX Reforma (posible problema operativo)
2. Ticket promedio muy bajo en CompraMax Monterrey San Pedro (problema sistema)
3. Caída en todas las sucursales de la región Sur (evento externo)
4. Pico inusual en Sabor Grill Monterrey Valle (evento especial no reportado)
5. Ticket promedio muy alto en MegaPlaza Cancún (compras turísticas)

PERIODO: Próximos 7 días desde hoy (CURRENT_DATE + 0 a CURRENT_DATE + 6)
REGISTROS: 105 (15 sucursales × 7 días)
*/

-- =====================================================================
-- Contexto actual
-- =====================================================================
USE WAREHOUSE MEGAMART_ANALYTICS_WH;
USE DATABASE MEGAMART_DB;
USE SCHEMA ANALYTICS;

-- =====================================================================
-- Insertar datos de inferencia (semana completa)
-- =====================================================================

-- Crear tabla temporal con fechas de la próxima semana
CREATE OR REPLACE TEMPORARY TABLE TEMP_FECHAS_INFERENCIA AS
SELECT 
    DATEADD(DAY, seq, CURRENT_DATE()) AS FECHA
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY NULL) - 1 AS seq
    FROM TABLE(GENERATOR(ROWCOUNT => 7))
);

-- Generar datos base de inferencia
CREATE OR REPLACE TEMPORARY TABLE TEMP_INFERENCIA_BASE AS
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
    
    -- Ventas base según tipo de tienda
    CASE s.TIPO_TIENDA
        WHEN 'MegaPlaza' THEN 85000
        WHEN 'CompraMax' THEN 120000
        WHEN 'Sabor Grill' THEN 45000
    END AS VENTAS_BASE,
    
    -- Factores estacionales
    (1 + 0.3 * SIN(2 * PI() * DAYOFYEAR(f.FECHA) / 365.0)) AS FACTOR_ESTACIONAL,
    
    -- Efecto día de semana
    CASE 
        WHEN DAYOFWEEK(f.FECHA) IN (1, 7) THEN 1.25
        WHEN DAYOFWEEK(f.FECHA) = 6 THEN 1.15
        ELSE 1.0
    END AS FACTOR_DIA_SEMANA,
    
    -- Efecto quincena
    CASE WHEN DAYOFMONTH(f.FECHA) IN (15, 30, 31) THEN 1.3 ELSE 1.0 END AS FACTOR_QUINCENA,
    
    -- Ruido aleatorio
    (1 + (MOD(ABS(HASH(f.FECHA, s.SUCURSAL_ID)), 30) - 15) / 100.0) AS FACTOR_RUIDO,
    
    -- Tendencia regional
    CASE s.REGION
        WHEN 'Norte' THEN 1.05
        WHEN 'Centro' THEN 1.12
        WHEN 'Sur' THEN 0.98
    END AS FACTOR_REGION,
    
    -- Clima
    ROUND(
        CASE s.REGION
            WHEN 'Norte' THEN 22 + 12 * SIN(2 * PI() * DAYOFYEAR(f.FECHA) / 365.0)
            WHEN 'Centro' THEN 18 + 8 * SIN(2 * PI() * DAYOFYEAR(f.FECHA) / 365.0)
            WHEN 'Sur' THEN 28 + 6 * SIN(2 * PI() * DAYOFYEAR(f.FECHA) / 365.0)
        END + (MOD(ABS(HASH(f.FECHA, s.SUCURSAL_ID, 'temp')), 6) - 3)
    , 1) AS TEMPERATURA_C,
    
    CASE 
        WHEN MONTH(f.FECHA) BETWEEN 6 AND 9 THEN 
            ROUND(MOD(ABS(HASH(f.FECHA, s.SUCURSAL_ID, 'prec_verano')), 35), 1)
        ELSE 
            ROUND(MOD(ABS(HASH(f.FECHA, s.SUCURSAL_ID, 'prec_resto')), 8), 1)
    END AS PRECIPITACION_MM,
    
    CASE 
        WHEN MONTH(f.FECHA) BETWEEN 6 AND 9 THEN 
            60 + MOD(ABS(HASH(f.FECHA, s.SUCURSAL_ID, 'hum_verano')), 30)
        ELSE 
            35 + MOD(ABS(HASH(f.FECHA, s.SUCURSAL_ID, 'hum_resto')), 30)
    END AS HUMEDAD_PCT,
    
    -- Eventos
    CASE 
        WHEN MONTH(f.FECHA) = 1 AND DAY(f.FECHA) = 1 THEN TRUE
        WHEN MONTH(f.FECHA) = 2 AND DAY(f.FECHA) = 14 THEN TRUE
        WHEN MONTH(f.FECHA) = 3 AND DAY(f.FECHA) = 21 THEN TRUE
        WHEN MONTH(f.FECHA) = 5 AND DAY(f.FECHA) = 1 THEN TRUE
        WHEN MONTH(f.FECHA) = 5 AND DAY(f.FECHA) = 10 THEN TRUE
        WHEN MONTH(f.FECHA) = 9 AND DAY(f.FECHA) = 16 THEN TRUE
        WHEN MONTH(f.FECHA) = 11 AND DAY(f.FECHA) = 20 THEN TRUE
        WHEN MONTH(f.FECHA) = 12 AND DAY(f.FECHA) = 12 THEN TRUE
        WHEN MONTH(f.FECHA) = 12 AND DAY(f.FECHA) = 25 THEN TRUE
        ELSE FALSE
    END AS ES_DIA_FESTIVO,
    
    CASE 
        WHEN MOD(HASH(f.FECHA, s.SUCURSAL_ID), 100) < 8 THEN TRUE
        ELSE FALSE
    END AS ES_PROMOCION

FROM TEMP_FECHAS_INFERENCIA f
CROSS JOIN MEGAMART_DB.ANALYTICS.CAT_SUCURSALES s;

-- Calcular ventas y métricas
CREATE OR REPLACE TEMPORARY TABLE TEMP_INFERENCIA_COMPLETA AS
SELECT 
    FECHA,
    REGION,
    TIPO_TIENDA,
    SUCURSAL,
    SUCURSAL_ID,
    
    -- Ventas totales
    ROUND(
        VENTAS_BASE * 
        FACTOR_ESTACIONAL * 
        FACTOR_DIA_SEMANA * 
        FACTOR_QUINCENA * 
        FACTOR_RUIDO *
        FACTOR_REGION *
        CASE WHEN ES_DIA_FESTIVO THEN 1.45 WHEN ES_PROMOCION THEN 1.25 ELSE 1.0 END
    , 2) AS VENTAS_TOTALES,
    
    -- Número de transacciones
    ROUND(
        (VENTAS_BASE / 450) * 
        FACTOR_DIA_SEMANA * 
        (1 + (MOD(ABS(HASH(FECHA, SUCURSAL_ID, 'trans')), 20) - 10) / 100.0) *
        CASE WHEN ES_DIA_FESTIVO THEN 1.35 WHEN ES_PROMOCION THEN 1.28 ELSE 1.0 END
    , 0) AS NUM_TRANSACCIONES,
    
    -- Número de clientes
    ROUND(
        (VENTAS_BASE / 450) * 
        FACTOR_DIA_SEMANA * 
        (0.80 + MOD(ABS(HASH(FECHA, SUCURSAL_ID, 'clientes')), 15) / 100.0)
    , 0) AS NUM_CLIENTES,
    
    TEMPERATURA_C,
    PRECIPITACION_MM,
    HUMEDAD_PCT,
    ES_DIA_FESTIVO,
    ES_PROMOCION,
    FALSE AS ES_EVENTO_ADVERSO,
    NULL AS TIPO_EVENTO,
    DIA_SEMANA,
    ES_FIN_SEMANA,
    ES_QUINCENA,
    
    -- Metadata de anomalías (inicialmente FALSE - no sabemos si hay anomalías)
    FALSE AS TIENE_ANOMALIA,
    NULL AS TIPO_ANOMALIA

FROM TEMP_INFERENCIA_BASE;

-- Calcular ticket promedio y asegurar orden de columnas
CREATE OR REPLACE TEMPORARY TABLE TEMP_INFERENCIA_FINAL AS
SELECT 
    FECHA,
    REGION,
    TIPO_TIENDA,
    SUCURSAL,
    SUCURSAL_ID,
    VENTAS_TOTALES,
    NUM_TRANSACCIONES,
    ROUND(VENTAS_TOTALES / NULLIF(NUM_TRANSACCIONES, 0), 2) AS TICKET_PROMEDIO,
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
FROM TEMP_INFERENCIA_COMPLETA;

-- =====================================================================
-- INYECTAR ANOMALÍAS OCULTAS (Para validar el modelo)
-- =====================================================================

-- Anomalía 1: Caída severa en MegaPlaza CDMX Reforma (Día 2 y 3)
-- Causa oculta: Problema con sistema de pagos
UPDATE TEMP_INFERENCIA_FINAL
SET 
    VENTAS_TOTALES = VENTAS_TOTALES * 0.20,
    NUM_TRANSACCIONES = ROUND(NUM_TRANSACCIONES * 0.25, 0),
    TICKET_PROMEDIO = ROUND(VENTAS_TOTALES * 0.20 / NULLIF(ROUND(NUM_TRANSACCIONES * 0.25, 0), 1), 2)
WHERE SUCURSAL = 'MegaPlaza CDMX Reforma'
  AND FECHA BETWEEN DATEADD(DAY, 1, CURRENT_DATE()) 
                AND DATEADD(DAY, 2, CURRENT_DATE());

-- Anomalía 2: Ticket promedio anormalmente bajo en CompraMax Monterrey (Día 3)
-- Causa oculta: Error en sistema de descuentos aplicó 50% extra
UPDATE TEMP_INFERENCIA_FINAL
SET 
    TICKET_PROMEDIO = TICKET_PROMEDIO * 0.45,
    VENTAS_TOTALES = ROUND(TICKET_PROMEDIO * 0.45 * NUM_TRANSACCIONES, 2)
WHERE SUCURSAL = 'CompraMax Monterrey San Pedro'
  AND FECHA = DATEADD(DAY, 2, CURRENT_DATE());

-- Anomalía 3: Caída generalizada región Sur (Día 4 y 5)
-- Causa oculta: Tormenta tropical afectó conectividad
UPDATE TEMP_INFERENCIA_FINAL
SET 
    VENTAS_TOTALES = VENTAS_TOTALES * 0.55,
    NUM_TRANSACCIONES = ROUND(NUM_TRANSACCIONES * 0.60, 0),
    TICKET_PROMEDIO = ROUND(VENTAS_TOTALES * 0.55 / NULLIF(ROUND(NUM_TRANSACCIONES * 0.60, 0), 1), 2),
    PRECIPITACION_MM = 65.0
WHERE REGION = 'Sur'
  AND FECHA BETWEEN DATEADD(DAY, 3, CURRENT_DATE()) 
                AND DATEADD(DAY, 4, CURRENT_DATE());

-- Anomalía 4: Pico inusual en Sabor Grill Monterrey Valle (Día 6)
-- Causa oculta: Evento corporativo no registrado en el sistema
UPDATE TEMP_INFERENCIA_FINAL
SET 
    VENTAS_TOTALES = VENTAS_TOTALES * 2.8,
    NUM_TRANSACCIONES = ROUND(NUM_TRANSACCIONES * 1.9, 0),
    TICKET_PROMEDIO = ROUND(VENTAS_TOTALES * 2.8 / NULLIF(ROUND(NUM_TRANSACCIONES * 1.9, 0), 1), 2)
WHERE SUCURSAL = 'Sabor Grill Monterrey Valle'
  AND FECHA = DATEADD(DAY, 5, CURRENT_DATE());

-- Anomalía 5: Ticket promedio muy alto en MegaPlaza Cancún (Día 5)
-- Causa oculta: Compras turísticas masivas fin de semana largo
UPDATE TEMP_INFERENCIA_FINAL
SET 
    TICKET_PROMEDIO = TICKET_PROMEDIO * 2.2,
    VENTAS_TOTALES = ROUND(TICKET_PROMEDIO * 2.2 * NUM_TRANSACCIONES, 2)
WHERE SUCURSAL = 'MegaPlaza Cancún Plaza Las Américas'
  AND FECHA = DATEADD(DAY, 4, CURRENT_DATE());

-- =====================================================================
-- Insertar datos de inferencia en la tabla principal
-- =====================================================================
-- IMPORTANTE: Columnas en el mismo orden que VENTAS_DIARIAS

INSERT INTO MEGAMART_DB.ANALYTICS.VENTAS_DIARIAS (
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
)
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
FROM TEMP_INFERENCIA_FINAL;

-- =====================================================================
-- Validación: Verificar estructura de columnas
-- =====================================================================

-- Verificar que todas las columnas estén presentes y en el orden correcto
SELECT 
    'Estructura de TEMP_INFERENCIA_FINAL' AS INFO,
    COUNT(*) AS TOTAL_REGISTROS
FROM TEMP_INFERENCIA_FINAL;

-- Mostrar nombres de columnas
DESC TABLE TEMP_INFERENCIA_FINAL;

-- =====================================================================
-- Vista previa de los datos insertados
-- =====================================================================

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
FROM TEMP_INFERENCIA_FINAL
ORDER BY FECHA, REGION, SUCURSAL
LIMIT 20;

-- =====================================================================
-- Ejecutar detección de anomalías en los nuevos datos
-- =====================================================================

-- Ejecutar el modelo de detección sobre TODOS los datos (históricos + nuevos)
-- El modelo detectará automáticamente las anomalías en la semana nueva

-- 1. Recrear tabla de anomalías de ventas
CREATE OR REPLACE TABLE MEGAMART_DB.ANALYTICS.RESULTADO_ANOMALIAS_VENTAS AS
WITH ESTADISTICAS_BASE AS (
    SELECT 
        FECHA,
        REGION,
        TIPO_TIENDA,
        SUCURSAL,
        SUCURSAL_ID,
        VENTAS_TOTALES AS VALOR_REAL,
        
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
        
        AVG(VENTAS_TOTALES) OVER (PARTITION BY SUCURSAL) AS MEDIA_GLOBAL,
        STDDEV(VENTAS_TOTALES) OVER (PARTITION BY SUCURSAL) AS STDDEV_GLOBAL,
        
        TIENE_ANOMALIA AS ANOMALIA_REAL,
        TIPO_ANOMALIA AS TIPO_ANOMALIA_REAL,
        TIPO_EVENTO,
        TEMPERATURA_C,
        PRECIPITACION_MM,
        FLAG_FESTIVO,
        FLAG_PROMOCION
        
    FROM MEGAMART_DB.ANALYTICS.VW_VENTAS_PARA_MODELO
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
    
    CASE 
        WHEN ANOMALY_SCORE > 3.0 THEN 'Anomalía Alta'
        WHEN ANOMALY_SCORE > 2.5 THEN 'Anomalía Media'
        WHEN ANOMALY_SCORE > 2.0 THEN 'Anomalía Baja'
        ELSE 'Normal'
    END AS CLASIFICACION_ANOMALIA,
    
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
WHERE ANOMALY_SCORE > 2.0
ORDER BY ANOMALY_SCORE DESC, FECHA DESC;

-- 2. Ver las anomalías detectadas en la semana de inferencia
SELECT 
    FECHA,
    SUCURSAL,
    REGION,
    VALOR_REAL AS VENTAS_REALES,
    MEDIA_ESPERADA AS VENTAS_ESPERADAS,
    ANOMALY_SCORE AS Z_SCORE,
    CLASIFICACION_ANOMALIA,
    DIRECCION_ANOMALIA,
    TIPO_EVENTO
FROM MEGAMART_DB.ANALYTICS.RESULTADO_ANOMALIAS_VENTAS
WHERE FECHA >= CURRENT_DATE()  -- Solo datos de inferencia
ORDER BY ANOMALY_SCORE DESC;

-- =====================================================================
-- Resumen de anomalías detectadas en la semana de inferencia
-- =====================================================================

SELECT 
    DATE(FECHA) AS DIA,
    COUNT(DISTINCT SUCURSAL) AS SUCURSALES_CON_ANOMALIAS,
    ROUND(AVG(ANOMALY_SCORE), 2) AS Z_SCORE_PROMEDIO,
    ROUND(AVG(VALOR_REAL), 2) AS VENTAS_PROMEDIO_ANOMALAS,
    LISTAGG(DISTINCT CLASIFICACION_ANOMALIA, ', ') AS TIPOS_DETECTADOS
FROM MEGAMART_DB.ANALYTICS.RESULTADO_ANOMALIAS_VENTAS
WHERE FECHA >= CURRENT_DATE()
GROUP BY DATE(FECHA)
ORDER BY DIA;

-- =====================================================================
-- Comparación: Anomalías históricas vs nuevas detectadas
-- =====================================================================

SELECT 
    CASE 
        WHEN FECHA < CURRENT_DATE() THEN 'Datos Históricos'
        ELSE 'Datos Inferencia (Nuevos)'
    END AS TIPO_DATOS,
    COUNT(*) AS TOTAL_ANOMALIAS,
    ROUND(AVG(ANOMALY_SCORE), 2) AS Z_SCORE_PROMEDIO,
    COUNT(DISTINCT SUCURSAL) AS SUCURSALES_AFECTADAS
FROM MEGAMART_DB.ANALYTICS.RESULTADO_ANOMALIAS_VENTAS
GROUP BY CASE WHEN FECHA < CURRENT_DATE() THEN 'Datos Históricos' ELSE 'Datos Inferencia (Nuevos)' END
ORDER BY TIPO_DATOS;

-- =====================================================================
-- Validación Final: Verificar que los datos se insertaron correctamente
-- =====================================================================

-- Contar registros en la tabla principal
SELECT 
    'Total registros en VENTAS_DIARIAS' AS METRICA,
    COUNT(*) AS VALOR
FROM MEGAMART_DB.ANALYTICS.VENTAS_DIARIAS

UNION ALL

SELECT 
    'Registros de inferencia insertados' AS METRICA,
    COUNT(*) AS VALOR
FROM MEGAMART_DB.ANALYTICS.VENTAS_DIARIAS
WHERE FECHA >= CURRENT_DATE()

UNION ALL

SELECT 
    'Registros históricos' AS METRICA,
    COUNT(*) AS VALOR
FROM MEGAMART_DB.ANALYTICS.VENTAS_DIARIAS
WHERE FECHA < CURRENT_DATE();

-- Verificar estructura de columnas (21 columnas esperadas)
DESC TABLE MEGAMART_DB.ANALYTICS.VENTAS_DIARIAS;

-- =====================================================================
-- FIN DEL SCRIPT DE INFERENCIA
-- =====================================================================
/*
ANOMALÍAS OCULTAS INSERTADAS (PARA VALIDACIÓN):

1. MegaPlaza CDMX Reforma (Días +1, +2):
   - Caída del 80% en ventas
   - Esperado: Z-Score > 3.0 (Anomalía Alta)

2. CompraMax Monterrey San Pedro (Día +3):
   - Ticket promedio 55% más bajo
   - Esperado: Z-Score > 2.5 (Anomalía Media)

3. Región Sur completa (Días +4, +5):
   - Caída del 45% en ventas
   - Esperado: Z-Score > 2.5 en todas las sucursales

4. Sabor Grill Monterrey Valle (Día +6):
   - Pico del 180% en ventas
   - Esperado: Z-Score > 3.0 (Anomalía Alta)

5. MegaPlaza Cancún (Día +5):
   - Ticket promedio 120% más alto
   - Esperado: Z-Score > 2.5 (Anomalía Media)

INSTRUCCIONES DE USO:
1. Ejecutar este script completo
2. Revisar las anomalías detectadas en la última query
3. Validar que el modelo detectó las 5 anomalías ocultas
4. Analizar falsos positivos/negativos
*/

