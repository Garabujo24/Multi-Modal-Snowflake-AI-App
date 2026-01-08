-- =====================================================================
-- DATOS DE INFERENCIA - SEMANA SIMPLE
-- =====================================================================
-- Estructura: Exactamente los mismos campos que VENTAS_DIARIAS
-- Periodo: 7 días (próxima semana)
-- Sucursales: 5 sucursales de ejemplo
-- Anomalías: 5 anomalías ocultas (sin etiquetar)
-- =====================================================================

USE WAREHOUSE MEGAMART_ANALYTICS_WH;
USE DATABASE MEGAMART_DB;
USE SCHEMA ANALYTICS;

-- =====================================================================
-- INSERTAR DATOS DE INFERENCIA
-- =====================================================================

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
) VALUES

-- =====================================================================
-- DÍA 1: LUNES - Todo Normal
-- =====================================================================
(DATEADD(DAY, 0, CURRENT_DATE()), 'Norte', 'MegaPlaza', 'MegaPlaza Monterrey Centro', 1, 95420.00, 228, 418.51, 210, 28.5, 0.0, 42, FALSE, FALSE, FALSE, NULL, 2, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 0, CURRENT_DATE()), 'Norte', 'CompraMax', 'CompraMax Monterrey San Pedro', 2, 142850.00, 338, 422.63, 315, 28.2, 0.0, 40, FALSE, FALSE, FALSE, NULL, 2, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 0, CURRENT_DATE()), 'Centro', 'MegaPlaza', 'MegaPlaza CDMX Reforma', 6, 118240.00, 282, 419.43, 260, 21.5, 2.1, 55, FALSE, FALSE, FALSE, NULL, 2, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 0, CURRENT_DATE()), 'Centro', 'CompraMax', 'CompraMax CDMX Polanco', 7, 157630.00, 374, 421.47, 350, 21.8, 1.8, 53, FALSE, FALSE, FALSE, NULL, 2, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 0, CURRENT_DATE()), 'Sur', 'MegaPlaza', 'MegaPlaza Guadalajara Zapopan', 10, 102340.00, 244, 419.43, 225, 29.5, 3.2, 62, FALSE, FALSE, FALSE, NULL, 2, FALSE, FALSE, FALSE, NULL),

-- =====================================================================
-- DÍA 2: MARTES - ANOMALÍA 1: Caída severa en CDMX Reforma
-- =====================================================================
(DATEADD(DAY, 1, CURRENT_DATE()), 'Norte', 'MegaPlaza', 'MegaPlaza Monterrey Centro', 1, 93280.00, 223, 418.30, 205, 27.8, 0.0, 45, FALSE, FALSE, FALSE, NULL, 3, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 1, CURRENT_DATE()), 'Norte', 'CompraMax', 'CompraMax Monterrey San Pedro', 2, 145230.00, 344, 422.18, 320, 27.5, 0.0, 43, FALSE, FALSE, FALSE, NULL, 3, FALSE, FALSE, FALSE, NULL),
-- 🚨 ANOMALÍA: Caída 85% en CDMX Reforma (problema sistema pagos)
(DATEADD(DAY, 1, CURRENT_DATE()), 'Centro', 'MegaPlaza', 'MegaPlaza CDMX Reforma', 6, 17736.00, 56, 316.71, 52, 20.8, 1.5, 58, FALSE, FALSE, FALSE, NULL, 3, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 1, CURRENT_DATE()), 'Centro', 'CompraMax', 'CompraMax CDMX Polanco', 7, 159840.00, 379, 421.74, 355, 20.5, 2.3, 56, FALSE, FALSE, FALSE, NULL, 3, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 1, CURRENT_DATE()), 'Sur', 'MegaPlaza', 'MegaPlaza Guadalajara Zapopan', 10, 104120.00, 248, 419.84, 230, 30.1, 2.8, 60, FALSE, FALSE, FALSE, NULL, 3, FALSE, FALSE, FALSE, NULL),

-- =====================================================================
-- DÍA 3: MIÉRCOLES - ANOMALÍA 1 continúa + ANOMALÍA 2: Ticket bajo Monterrey
-- =====================================================================
-- 🚨 ANOMALÍA 2: Ticket promedio 60% más bajo en Monterrey (error descuentos)
(DATEADD(DAY, 2, CURRENT_DATE()), 'Norte', 'MegaPlaza', 'MegaPlaza Monterrey Centro', 1, 37312.00, 223, 167.32, 205, 28.1, 0.0, 41, FALSE, FALSE, FALSE, NULL, 4, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 2, CURRENT_DATE()), 'Norte', 'CompraMax', 'CompraMax Monterrey San Pedro', 2, 143560.00, 340, 422.24, 318, 28.4, 0.0, 44, FALSE, FALSE, FALSE, NULL, 4, FALSE, FALSE, FALSE, NULL),
-- 🚨 ANOMALÍA 1 continúa
(DATEADD(DAY, 2, CURRENT_DATE()), 'Centro', 'MegaPlaza', 'MegaPlaza CDMX Reforma', 6, 18943.00, 60, 315.72, 55, 21.2, 1.8, 57, FALSE, FALSE, FALSE, NULL, 4, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 2, CURRENT_DATE()), 'Centro', 'CompraMax', 'CompraMax CDMX Polanco', 7, 161250.00, 382, 422.12, 358, 21.0, 2.0, 55, FALSE, FALSE, FALSE, NULL, 4, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 2, CURRENT_DATE()), 'Sur', 'MegaPlaza', 'MegaPlaza Guadalajara Zapopan', 10, 103890.00, 247, 420.53, 228, 29.8, 3.5, 63, FALSE, FALSE, FALSE, NULL, 4, FALSE, FALSE, FALSE, NULL),

-- =====================================================================
-- DÍA 4: JUEVES - ANOMALÍA 3: Caída generalizada región Sur (tormenta)
-- =====================================================================
(DATEADD(DAY, 3, CURRENT_DATE()), 'Norte', 'MegaPlaza', 'MegaPlaza Monterrey Centro', 1, 94820.00, 226, 419.56, 208, 27.5, 0.0, 46, FALSE, FALSE, FALSE, NULL, 5, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 3, CURRENT_DATE()), 'Norte', 'CompraMax', 'CompraMax Monterrey San Pedro', 2, 146720.00, 347, 422.83, 325, 27.2, 0.0, 42, FALSE, FALSE, FALSE, NULL, 5, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 3, CURRENT_DATE()), 'Centro', 'MegaPlaza', 'MegaPlaza CDMX Reforma', 6, 119560.00, 285, 419.51, 263, 22.1, 1.2, 54, FALSE, FALSE, FALSE, NULL, 5, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 3, CURRENT_DATE()), 'Centro', 'CompraMax', 'CompraMax CDMX Polanco', 7, 158940.00, 377, 421.59, 352, 22.3, 1.5, 52, FALSE, FALSE, FALSE, NULL, 5, FALSE, FALSE, FALSE, NULL),
-- 🚨 ANOMALÍA 3: Caída 50% en región Sur (tormenta tropical)
(DATEADD(DAY, 3, CURRENT_DATE()), 'Sur', 'MegaPlaza', 'MegaPlaza Guadalajara Zapopan', 10, 51170.00, 146, 350.48, 135, 28.5, 65.0, 85, FALSE, FALSE, FALSE, NULL, 5, FALSE, FALSE, FALSE, NULL),

-- =====================================================================
-- DÍA 5: VIERNES - ANOMALÍA 3 continúa + ANOMALÍA 4: Pico en ventas
-- =====================================================================
-- 🚨 ANOMALÍA 4: Pico inusual en MegaPlaza Monterrey (evento corporativo)
(DATEADD(DAY, 4, CURRENT_DATE()), 'Norte', 'MegaPlaza', 'MegaPlaza Monterrey Centro', 1, 238550.00, 385, 619.61, 356, 28.8, 0.0, 40, FALSE, FALSE, FALSE, NULL, 6, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 4, CURRENT_DATE()), 'Norte', 'CompraMax', 'CompraMax Monterrey San Pedro', 2, 168945.00, 399, 423.42, 373, 28.5, 0.0, 38, FALSE, TRUE, FALSE, NULL, 6, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 4, CURRENT_DATE()), 'Centro', 'MegaPlaza', 'MegaPlaza CDMX Reforma', 6, 120840.00, 288, 419.58, 266, 21.7, 2.5, 56, FALSE, FALSE, FALSE, NULL, 6, FALSE, FALSE, FALSE, NULL),
(DATEADD(DAY, 4, CURRENT_DATE()), 'Centro', 'CompraMax', 'CompraMax CDMX Polanco', 7, 160320.00, 380, 421.89, 355, 21.5, 2.1, 54, FALSE, FALSE, FALSE, NULL, 6, FALSE, FALSE, FALSE, NULL),
-- 🚨 ANOMALÍA 3 continúa
(DATEADD(DAY, 4, CURRENT_DATE()), 'Sur', 'MegaPlaza', 'MegaPlaza Guadalajara Zapopan', 10, 49860.00, 142, 351.13, 131, 29.2, 65.0, 88, FALSE, FALSE, FALSE, NULL, 6, FALSE, FALSE, FALSE, NULL),

-- =====================================================================
-- DÍA 6: SÁBADO - ANOMALÍA 5: Ticket promedio muy alto
-- =====================================================================
(DATEADD(DAY, 5, CURRENT_DATE()), 'Norte', 'MegaPlaza', 'MegaPlaza Monterrey Centro', 1, 119275.00, 284, 420.12, 262, 27.9, 0.0, 43, FALSE, FALSE, FALSE, NULL, 7, TRUE, FALSE, FALSE, NULL),
-- 🚨 ANOMALÍA 5: Ticket promedio +150% (compras turísticas masivas)
(DATEADD(DAY, 5, CURRENT_DATE()), 'Norte', 'CompraMax', 'CompraMax Monterrey San Pedro', 2, 358475.00, 342, 1048.10, 320, 28.0, 0.0, 45, FALSE, FALSE, FALSE, NULL, 7, TRUE, FALSE, FALSE, NULL),
(DATEADD(DAY, 5, CURRENT_DATE()), 'Centro', 'MegaPlaza', 'MegaPlaza CDMX Reforma', 6, 148800.00, 354, 420.34, 328, 22.5, 1.8, 51, FALSE, FALSE, FALSE, NULL, 7, TRUE, FALSE, FALSE, NULL),
(DATEADD(DAY, 5, CURRENT_DATE()), 'Centro', 'CompraMax', 'CompraMax CDMX Polanco', 7, 197550.00, 468, 422.12, 438, 22.0, 2.2, 53, FALSE, FALSE, FALSE, NULL, 7, TRUE, FALSE, FALSE, NULL),
(DATEADD(DAY, 5, CURRENT_DATE()), 'Sur', 'MegaPlaza', 'MegaPlaza Guadalajara Zapopan', 10, 127925.00, 305, 419.43, 282, 30.5, 4.2, 65, FALSE, FALSE, FALSE, NULL, 7, TRUE, FALSE, FALSE, NULL),

-- =====================================================================
-- DÍA 7: DOMINGO - Todo vuelve a la normalidad
-- =====================================================================
(DATEADD(DAY, 6, CURRENT_DATE()), 'Norte', 'MegaPlaza', 'MegaPlaza Monterrey Centro', 1, 121850.00, 290, 420.17, 268, 28.3, 0.0, 41, FALSE, FALSE, FALSE, NULL, 1, TRUE, FALSE, FALSE, NULL),
(DATEADD(DAY, 6, CURRENT_DATE()), 'Norte', 'CompraMax', 'CompraMax Monterrey San Pedro', 2, 181575.00, 430, 422.27, 402, 28.7, 0.0, 39, FALSE, FALSE, FALSE, NULL, 1, TRUE, FALSE, FALSE, NULL),
(DATEADD(DAY, 6, CURRENT_DATE()), 'Centro', 'MegaPlaza', 'MegaPlaza CDMX Reforma', 6, 150240.00, 358, 419.66, 331, 21.9, 2.2, 55, FALSE, FALSE, FALSE, NULL, 1, TRUE, FALSE, FALSE, NULL),
(DATEADD(DAY, 6, CURRENT_DATE()), 'Centro', 'CompraMax', 'CompraMax CDMX Polanco', 7, 199620.00, 473, 422.03, 442, 22.2, 1.9, 52, FALSE, FALSE, FALSE, NULL, 1, TRUE, FALSE, FALSE, NULL),
(DATEADD(DAY, 6, CURRENT_DATE()), 'Sur', 'MegaPlaza', 'MegaPlaza Guadalajara Zapopan', 10, 129350.00, 308, 420.13, 285, 29.9, 3.8, 64, FALSE, FALSE, FALSE, NULL, 1, TRUE, FALSE, FALSE, NULL);

-- =====================================================================
-- VERIFICAR DATOS INSERTADOS
-- =====================================================================

SELECT 
    'Datos de inferencia insertados correctamente' AS STATUS,
    COUNT(*) AS TOTAL_REGISTROS
FROM MEGAMART_DB.ANALYTICS.VENTAS_DIARIAS
WHERE FECHA >= CURRENT_DATE()
  AND FECHA < DATEADD(DAY, 7, CURRENT_DATE());

-- Ver resumen por día
SELECT 
    FECHA,
    COUNT(DISTINCT SUCURSAL) AS SUCURSALES,
    ROUND(AVG(VENTAS_TOTALES), 2) AS VENTAS_PROMEDIO,
    ROUND(AVG(TICKET_PROMEDIO), 2) AS TICKET_PROMEDIO_AVG,
    ROUND(MIN(VENTAS_TOTALES), 2) AS VENTAS_MIN,
    ROUND(MAX(VENTAS_TOTALES), 2) AS VENTAS_MAX
FROM MEGAMART_DB.ANALYTICS.VENTAS_DIARIAS
WHERE FECHA >= CURRENT_DATE()
  AND FECHA < DATEADD(DAY, 7, CURRENT_DATE())
GROUP BY FECHA
ORDER BY FECHA;

-- =====================================================================
-- EJECUTAR DETECCIÓN DE ANOMALÍAS
-- =====================================================================
-- Nota: Ejecutar el script principal de detección después de insertar estos datos
-- Las anomalías ocultas deberían ser detectadas automáticamente por el modelo Z-Score

/*
ANOMALÍAS OCULTAS INSERTADAS:

1. Día 2: MegaPlaza CDMX Reforma
   - Caída del 85% en ventas ($118,240 → $17,736)
   - Esperado: Z-Score > 4.0 (Anomalía Alta)

2. Día 3: MegaPlaza Monterrey Centro  
   - Ticket promedio 60% más bajo ($418 → $167)
   - Esperado: Z-Score > 3.5 (Anomalía Alta)

3. Días 4-5: MegaPlaza Guadalajara (Sur)
   - Caída del 50% en ventas por tormenta
   - Esperado: Z-Score > 3.0 (Anomalía Alta)

4. Día 5: MegaPlaza Monterrey Centro
   - Pico del 150% en ventas ($95,000 → $238,550)
   - Esperado: Z-Score > 3.5 (Anomalía Alta)

5. Día 6: CompraMax Monterrey San Pedro
   - Ticket promedio +150% ($422 → $1,048)
   - Esperado: Z-Score > 4.0 (Anomalía Alta)

TOTAL: 35 registros (5 sucursales × 7 días)
ANOMALÍAS: 5 anomalías no etiquetadas para validar detección
*/


