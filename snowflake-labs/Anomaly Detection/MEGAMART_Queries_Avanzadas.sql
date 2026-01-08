-- ================================================================================
-- QUERIES AVANZADAS - ANÁLISIS PROFUNDO DE ANOMALÍAS
-- Cliente: Grupo Comercial Control (C Control)
-- Propósito: Análisis adicionales y casos de uso avanzados
-- ================================================================================

USE DATABASE CCONTROL_DB;
USE SCHEMA CCONTROL_SCHEMA;
USE WAREHOUSE CCONTROL_WH;

-- ################################################################################
-- ANÁLISIS 1: Correlación entre Variables Exógenas y Anomalías
-- ################################################################################

-- 1.1 Impacto del Clima en Anomalías de Ventas
WITH ANOMALIAS_CLIMA AS (
    SELECT 
        FECHA,
        TIPO_TIENDA,
        REGION,
        VENTAS_TOTALES,
        TEMPERATURA_C,
        PRECIPITACION_MM,
        
        ANOMALY_DETECTION(VENTAS_TOTALES, TIPO_TIENDA, REGION) 
            OVER (PARTITION BY TIPO_TIENDA, REGION ORDER BY FECHA) AS SCORE_ANOMALIA,
        
        -- Clasificación de temperatura
        CASE 
            WHEN TEMPERATURA_C < 15 THEN 'Frío'
            WHEN TEMPERATURA_C BETWEEN 15 AND 30 THEN 'Templado'
            ELSE 'Calor'
        END AS CLASIFICACION_TEMPERATURA,
        
        -- Clasificación de lluvia
        CASE 
            WHEN PRECIPITACION_MM = 0 THEN 'Sin Lluvia'
            WHEN PRECIPITACION_MM < 10 THEN 'Lluvia Ligera'
            WHEN PRECIPITACION_MM < 30 THEN 'Lluvia Moderada'
            ELSE 'Lluvia Intensa'
        END AS CLASIFICACION_LLUVIA
        
    FROM CCONTROL_SCHEMA.VW_VENTAS_MULTISERIES
)
SELECT 
    CLASIFICACION_TEMPERATURA,
    CLASIFICACION_LLUVIA,
    COUNT(*) AS TOTAL_DIAS,
    
    -- Promedio de ventas por condición climática
    ROUND(AVG(VENTAS_TOTALES), 2) AS PROMEDIO_VENTAS,
    
    -- Conteo de anomalías por severidad
    SUM(CASE WHEN SCORE_ANOMALIA < -2 THEN 1 ELSE 0 END) AS ANOMALIAS_CRITICAS,
    SUM(CASE WHEN SCORE_ANOMALIA BETWEEN -2 AND -1.5 THEN 1 ELSE 0 END) AS ANOMALIAS_MODERADAS,
    
    -- Porcentaje de días anormales
    ROUND(100.0 * SUM(CASE WHEN SCORE_ANOMALIA < -1.5 THEN 1 ELSE 0 END) / COUNT(*), 2) AS PCT_ANOMALIAS,
    
    -- Score promedio
    ROUND(AVG(SCORE_ANOMALIA), 3) AS PROMEDIO_SCORE_ANOMALIA

FROM ANOMALIAS_CLIMA
GROUP BY CLASIFICACION_TEMPERATURA, CLASIFICACION_LLUVIA
ORDER BY PCT_ANOMALIAS DESC;

-- 1.2 Eventos Adversos: Análisis de Impacto por Tipo de Tienda
WITH EVENTOS_IMPACTO AS (
    SELECT 
        TIPO_TIENDA,
        EVENTO_ADVERSO,
        VENTAS_TOTALES,
        TICKET_PROMEDIO,
        
        ANOMALY_DETECTION(VENTAS_TOTALES, TIPO_TIENDA) 
            OVER (PARTITION BY TIPO_TIENDA ORDER BY FECHA) AS SCORE_VENTAS,
            
        ANOMALY_DETECTION(TICKET_PROMEDIO, TIPO_TIENDA)
            OVER (PARTITION BY TIPO_TIENDA ORDER BY FECHA) AS SCORE_TICKET
        
    FROM CCONTROL_SCHEMA.VW_VENTAS_MULTISERIES
    WHERE EVENTO_ADVERSO IS NOT NULL
)
SELECT 
    TIPO_TIENDA,
    EVENTO_ADVERSO,
    COUNT(*) AS TOTAL_OCURRENCIAS,
    
    -- Impacto en ventas
    ROUND(AVG(VENTAS_TOTALES), 2) AS PROMEDIO_VENTAS_EVENTO,
    ROUND(AVG(SCORE_VENTAS), 3) AS PROMEDIO_SCORE_VENTAS,
    
    -- Impacto en ticket
    ROUND(AVG(TICKET_PROMEDIO), 2) AS PROMEDIO_TICKET_EVENTO,
    ROUND(AVG(SCORE_TICKET), 3) AS PROMEDIO_SCORE_TICKET,
    
    -- Porcentaje con anomalía crítica
    ROUND(100.0 * SUM(CASE WHEN SCORE_VENTAS < -2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS PCT_ANOMALIA_CRITICA

FROM EVENTOS_IMPACTO
GROUP BY TIPO_TIENDA, EVENTO_ADVERSO
ORDER BY TIPO_TIENDA, TOTAL_OCURRENCIAS DESC;

-- ################################################################################
-- ANÁLISIS 2: Patrones Temporales de Anomalías
-- ################################################################################

-- 2.1 Anomalías por Día de la Semana
WITH ANOMALIAS_DIARIAS AS (
    SELECT 
        DIA_SEMANA,
        TIPO_TIENDA,
        VENTAS_TOTALES,
        
        ANOMALY_DETECTION(VENTAS_TOTALES, TIPO_TIENDA) 
            OVER (PARTITION BY TIPO_TIENDA ORDER BY FECHA) AS SCORE_ANOMALIA
        
    FROM CCONTROL_SCHEMA.VW_VENTAS_MULTISERIES
)
SELECT 
    DIA_SEMANA,
    TIPO_TIENDA,
    COUNT(*) AS TOTAL_DIAS,
    
    ROUND(AVG(VENTAS_TOTALES), 2) AS PROMEDIO_VENTAS,
    
    SUM(CASE WHEN SCORE_ANOMALIA < -1.5 THEN 1 ELSE 0 END) AS DIAS_CON_ANOMALIA,
    
    ROUND(100.0 * SUM(CASE WHEN SCORE_ANOMALIA < -1.5 THEN 1 ELSE 0 END) / COUNT(*), 2) AS PCT_ANOMALIAS,
    
    ROUND(MIN(SCORE_ANOMALIA), 3) AS MIN_SCORE,
    ROUND(MAX(SCORE_ANOMALIA), 3) AS MAX_SCORE,
    ROUND(AVG(SCORE_ANOMALIA), 3) AS AVG_SCORE

FROM ANOMALIAS_DIARIAS
GROUP BY DIA_SEMANA, TIPO_TIENDA
ORDER BY 
    CASE DIA_SEMANA
        WHEN 'Mon' THEN 1
        WHEN 'Tue' THEN 2
        WHEN 'Wed' THEN 3
        WHEN 'Thu' THEN 4
        WHEN 'Fri' THEN 5
        WHEN 'Sat' THEN 6
        WHEN 'Sun' THEN 7
    END,
    TIPO_TIENDA;

-- 2.2 Tendencia Mensual de Anomalías
WITH TENDENCIA_MENSUAL AS (
    SELECT 
        TO_CHAR(FECHA, 'YYYY-MM') AS MES,
        NOMBRE_MES,
        TIPO_TIENDA,
        REGION,
        VENTAS_TOTALES,
        
        ANOMALY_DETECTION(VENTAS_TOTALES, TIPO_TIENDA, REGION) 
            OVER (PARTITION BY TIPO_TIENDA, REGION ORDER BY FECHA) AS SCORE_ANOMALIA
        
    FROM CCONTROL_SCHEMA.VW_VENTAS_MULTISERIES
)
SELECT 
    MES,
    NOMBRE_MES,
    TIPO_TIENDA,
    REGION,
    
    COUNT(*) AS TOTAL_DIAS,
    ROUND(AVG(VENTAS_TOTALES), 2) AS PROMEDIO_VENTAS_MES,
    
    SUM(CASE WHEN SCORE_ANOMALIA < -2 THEN 1 ELSE 0 END) AS ANOMALIAS_CRITICAS,
    SUM(CASE WHEN SCORE_ANOMALIA BETWEEN -2 AND -1.5 THEN 1 ELSE 0 END) AS ANOMALIAS_MODERADAS,
    SUM(CASE WHEN SCORE_ANOMALIA > 2 THEN 1 ELSE 0 END) AS PICOS_EXCEPCIONALES,
    
    ROUND(AVG(SCORE_ANOMALIA), 3) AS PROMEDIO_SCORE

FROM TENDENCIA_MENSUAL
GROUP BY MES, NOMBRE_MES, TIPO_TIENDA, REGION
ORDER BY MES DESC, TIPO_TIENDA, REGION;

-- ################################################################################
-- ANÁLISIS 3: Comparación de Sucursales - Benchmark
-- ################################################################################

-- 3.1 Ranking de Sucursales por Estabilidad (Menos Anomalías)
WITH ESTABILIDAD_SUCURSAL AS (
    SELECT 
        NOMBRE_SUCURSAL,
        TIPO_TIENDA,
        REGION,
        ESTADO,
        VENTAS_TOTALES,
        
        ANOMALY_DETECTION(VENTAS_TOTALES) 
            OVER (PARTITION BY NOMBRE_SUCURSAL ORDER BY FECHA) AS SCORE_ANOMALIA
        
    FROM CCONTROL_SCHEMA.VW_VENTAS_MULTISERIES
)
SELECT 
    NOMBRE_SUCURSAL,
    TIPO_TIENDA,
    REGION,
    ESTADO,
    
    COUNT(*) AS TOTAL_DIAS,
    ROUND(AVG(VENTAS_TOTALES), 2) AS PROMEDIO_VENTAS,
    
    -- Métricas de estabilidad
    SUM(CASE WHEN ABS(SCORE_ANOMALIA) > 2 THEN 1 ELSE 0 END) AS DIAS_INESTABLES,
    ROUND(100.0 * SUM(CASE WHEN ABS(SCORE_ANOMALIA) > 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS PCT_INESTABILIDAD,
    
    -- Desviación estándar de ventas
    ROUND(STDDEV(VENTAS_TOTALES), 2) AS DESV_ESTANDAR_VENTAS,
    
    -- Coeficiente de variación (CV = desv_est / media)
    ROUND(100.0 * STDDEV(VENTAS_TOTALES) / AVG(VENTAS_TOTALES), 2) AS COEF_VARIACION,
    
    -- Ranking (menor inestabilidad = mejor)
    RANK() OVER (PARTITION BY TIPO_TIENDA ORDER BY 
        100.0 * SUM(CASE WHEN ABS(SCORE_ANOMALIA) > 2 THEN 1 ELSE 0 END) / COUNT(*) ASC
    ) AS RANKING_ESTABILIDAD

FROM ESTABILIDAD_SUCURSAL
GROUP BY NOMBRE_SUCURSAL, TIPO_TIENDA, REGION, ESTADO
ORDER BY PCT_INESTABILIDAD ASC, TIPO_TIENDA;

-- 3.2 Comparación Regional: Norte vs Centro vs Sur
WITH COMPARACION_REGIONAL AS (
    SELECT 
        REGION,
        TIPO_TIENDA,
        FECHA,
        VENTAS_TOTALES,
        TEMPERATURA_C,
        
        ANOMALY_DETECTION(VENTAS_TOTALES, REGION, TIPO_TIENDA) 
            OVER (PARTITION BY REGION, TIPO_TIENDA ORDER BY FECHA) AS SCORE_ANOMALIA
        
    FROM CCONTROL_SCHEMA.VW_VENTAS_MULTISERIES
)
SELECT 
    REGION,
    TIPO_TIENDA,
    
    COUNT(*) AS TOTAL_DIAS,
    ROUND(AVG(VENTAS_TOTALES), 2) AS PROMEDIO_VENTAS,
    ROUND(AVG(TEMPERATURA_C), 2) AS TEMPERATURA_PROMEDIO,
    
    -- Anomalías por severidad
    SUM(CASE WHEN SCORE_ANOMALIA < -2.5 THEN 1 ELSE 0 END) AS ANOMALIAS_EXTREMAS,
    SUM(CASE WHEN SCORE_ANOMALIA < -2 THEN 1 ELSE 0 END) AS ANOMALIAS_CRITICAS,
    SUM(CASE WHEN SCORE_ANOMALIA < -1.5 THEN 1 ELSE 0 END) AS ANOMALIAS_MODERADAS,
    
    -- Tasa de anomalías
    ROUND(100.0 * SUM(CASE WHEN SCORE_ANOMALIA < -1.5 THEN 1 ELSE 0 END) / COUNT(*), 2) AS TASA_ANOMALIAS,
    
    -- Scores
    ROUND(MIN(SCORE_ANOMALIA), 3) AS PEOR_SCORE,
    ROUND(AVG(SCORE_ANOMALIA), 3) AS PROMEDIO_SCORE

FROM COMPARACION_REGIONAL
GROUP BY REGION, TIPO_TIENDA
ORDER BY REGION, TIPO_TIENDA;

-- ################################################################################
-- ANÁLISIS 4: Detección de Anomalías Multi-Métrica
-- ################################################################################

-- 4.1 Anomalías Compuestas (Ventas + Ticket + Tráfico)
WITH ANOMALIAS_MULTIPLES AS (
    SELECT 
        FECHA,
        TIPO_TIENDA,
        REGION,
        NOMBRE_SUCURSAL,
        VENTAS_TOTALES,
        TICKET_PROMEDIO,
        NUM_TRANSACCIONES,
        NUM_CLIENTES,
        EVENTO_ADVERSO,
        
        -- Detección en ventas
        ANOMALY_DETECTION(VENTAS_TOTALES, TIPO_TIENDA, REGION) 
            OVER (PARTITION BY TIPO_TIENDA, REGION ORDER BY FECHA) AS SCORE_VENTAS,
        
        -- Detección en ticket
        ANOMALY_DETECTION(TICKET_PROMEDIO, TIPO_TIENDA, REGION)
            OVER (PARTITION BY TIPO_TIENDA, REGION ORDER BY FECHA) AS SCORE_TICKET,
        
        -- Detección en tráfico
        ANOMALY_DETECTION(NUM_CLIENTES, TIPO_TIENDA, REGION)
            OVER (PARTITION BY TIPO_TIENDA, REGION ORDER BY FECHA) AS SCORE_TRAFICO
        
    FROM CCONTROL_SCHEMA.VW_VENTAS_MULTISERIES
)
SELECT 
    FECHA,
    TIPO_TIENDA,
    REGION,
    NOMBRE_SUCURSAL,
    
    -- Valores reales
    ROUND(VENTAS_TOTALES, 2) AS VENTAS,
    ROUND(TICKET_PROMEDIO, 2) AS TICKET,
    NUM_CLIENTES AS CLIENTES,
    
    -- Scores de anomalía
    ROUND(SCORE_VENTAS, 3) AS SCORE_VENTAS,
    ROUND(SCORE_TICKET, 3) AS SCORE_TICKET,
    ROUND(SCORE_TRAFICO, 3) AS SCORE_TRAFICO,
    
    -- Score compuesto (promedio de los 3)
    ROUND((SCORE_VENTAS + SCORE_TICKET + SCORE_TRAFICO) / 3, 3) AS SCORE_COMPUESTO,
    
    -- Clasificación de anomalía
    CASE 
        -- Anomalía triple (las 3 métricas anormales)
        WHEN SCORE_VENTAS < -1.5 AND SCORE_TICKET < -1.5 AND SCORE_TRAFICO < -1.5 
            THEN '🔴 ANOMALÍA TRIPLE - CRÍTICO'
        
        -- Anomalía doble
        WHEN (SCORE_VENTAS < -1.5 AND SCORE_TICKET < -1.5) OR
             (SCORE_VENTAS < -1.5 AND SCORE_TRAFICO < -1.5) OR
             (SCORE_TICKET < -1.5 AND SCORE_TRAFICO < -1.5)
            THEN '🟠 ANOMALÍA DOBLE - ALTO'
        
        -- Anomalía simple pero severa
        WHEN SCORE_VENTAS < -2 OR SCORE_TICKET < -2 OR SCORE_TRAFICO < -2
            THEN '🟡 ANOMALÍA SIMPLE SEVERA'
        
        -- Anomalía simple
        WHEN SCORE_VENTAS < -1.5 OR SCORE_TICKET < -1.5 OR SCORE_TRAFICO < -1.5
            THEN '⚪ ANOMALÍA SIMPLE'
        
        ELSE '✅ NORMAL'
    END AS TIPO_ANOMALIA,
    
    EVENTO_ADVERSO

FROM ANOMALIAS_MULTIPLES
WHERE SCORE_VENTAS < -1.5 OR SCORE_TICKET < -1.5 OR SCORE_TRAFICO < -1.5
ORDER BY SCORE_COMPUESTO ASC, FECHA DESC
LIMIT 100;

-- ################################################################################
-- ANÁLISIS 5: Series de Tiempo - Ventanas Móviles
-- ################################################################################

-- 5.1 Promedio Móvil de 7 Días con Detección de Anomalías
WITH VENTANA_MOVIL AS (
    SELECT 
        FECHA,
        TIPO_TIENDA,
        REGION,
        VENTAS_TOTALES,
        
        -- Promedio móvil de 7 días
        AVG(VENTAS_TOTALES) OVER (
            PARTITION BY TIPO_TIENDA, REGION 
            ORDER BY FECHA 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS PROMEDIO_MOVIL_7D,
        
        -- Desviación estándar móvil
        STDDEV(VENTAS_TOTALES) OVER (
            PARTITION BY TIPO_TIENDA, REGION 
            ORDER BY FECHA 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS DESV_MOVIL_7D,
        
        -- Detección de anomalía
        ANOMALY_DETECTION(VENTAS_TOTALES, TIPO_TIENDA, REGION) 
            OVER (PARTITION BY TIPO_TIENDA, REGION ORDER BY FECHA) AS SCORE_ANOMALIA
        
    FROM CCONTROL_SCHEMA.VW_VENTAS_MULTISERIES
)
SELECT 
    FECHA,
    TIPO_TIENDA,
    REGION,
    ROUND(VENTAS_TOTALES, 2) AS VENTAS_DIA,
    ROUND(PROMEDIO_MOVIL_7D, 2) AS PROMEDIO_7D,
    
    -- Desviación del promedio móvil
    ROUND(VENTAS_TOTALES - PROMEDIO_MOVIL_7D, 2) AS DESVIACION_PROMEDIO,
    
    -- Porcentaje de desviación
    ROUND(100.0 * (VENTAS_TOTALES - PROMEDIO_MOVIL_7D) / NULLIF(PROMEDIO_MOVIL_7D, 0), 2) AS PCT_DESVIACION,
    
    ROUND(DESV_MOVIL_7D, 2) AS DESV_EST_7D,
    ROUND(SCORE_ANOMALIA, 3) AS SCORE_ANOMALIA

FROM VENTANA_MOVIL
WHERE FECHA >= DATEADD(DAY, -90, CURRENT_DATE())
ORDER BY FECHA DESC, TIPO_TIENDA, REGION
LIMIT 200;

-- 5.2 Detección de Cambios de Tendencia (Week-over-Week)
WITH COMPARACION_SEMANAL AS (
    SELECT 
        FECHA,
        TIPO_TIENDA,
        REGION,
        VENTAS_TOTALES,
        
        -- Ventas de la semana anterior
        LAG(VENTAS_TOTALES, 7) OVER (
            PARTITION BY TIPO_TIENDA, REGION 
            ORDER BY FECHA
        ) AS VENTAS_SEMANA_ANTERIOR,
        
        -- Score de anomalía
        ANOMALY_DETECTION(VENTAS_TOTALES, TIPO_TIENDA, REGION) 
            OVER (PARTITION BY TIPO_TIENDA, REGION ORDER BY FECHA) AS SCORE_ANOMALIA
        
    FROM CCONTROL_SCHEMA.VW_VENTAS_MULTISERIES
)
SELECT 
    FECHA,
    TIPO_TIENDA,
    REGION,
    ROUND(VENTAS_TOTALES, 2) AS VENTAS_HOY,
    ROUND(VENTAS_SEMANA_ANTERIOR, 2) AS VENTAS_HACE_7_DIAS,
    
    -- Cambio absoluto
    ROUND(VENTAS_TOTALES - VENTAS_SEMANA_ANTERIOR, 2) AS CAMBIO_WOW,
    
    -- Cambio porcentual
    ROUND(100.0 * (VENTAS_TOTALES - VENTAS_SEMANA_ANTERIOR) / 
        NULLIF(VENTAS_SEMANA_ANTERIOR, 0), 2) AS PCT_CAMBIO_WOW,
    
    ROUND(SCORE_ANOMALIA, 3) AS SCORE_ANOMALIA,
    
    -- Alerta si hay cambio drástico
    CASE 
        WHEN ABS(100.0 * (VENTAS_TOTALES - VENTAS_SEMANA_ANTERIOR) / 
            NULLIF(VENTAS_SEMANA_ANTERIOR, 0)) > 30 
            THEN '⚠️ CAMBIO DRÁSTICO'
        ELSE '✓ Normal'
    END AS ALERTA_CAMBIO

FROM COMPARACION_SEMANAL
WHERE VENTAS_SEMANA_ANTERIOR IS NOT NULL
    AND FECHA >= DATEADD(DAY, -60, CURRENT_DATE())
ORDER BY ABS((VENTAS_TOTALES - VENTAS_SEMANA_ANTERIOR) / NULLIF(VENTAS_SEMANA_ANTERIOR, 0)) DESC
LIMIT 100;

-- ################################################################################
-- ANÁLISIS 6: Exportación para Dashboards
-- ################################################################################

-- 6.1 Dataset Completo para Tableau/Power BI
CREATE OR REPLACE VIEW CCONTROL_SCHEMA.VW_DASHBOARD_ANOMALIAS AS
WITH ANOMALIAS_TODAS AS (
    SELECT 
        V.FECHA,
        V.TIPO_TIENDA,
        V.REGION,
        V.NOMBRE_SUCURSAL,
        V.ESTADO,
        V.VENTAS_TOTALES,
        V.TICKET_PROMEDIO,
        V.NUM_TRANSACCIONES,
        V.NUM_CLIENTES,
        V.TEMPERATURA_C,
        V.PRECIPITACION_MM,
        V.ES_DIA_FESTIVO,
        V.ES_QUINCENA,
        V.ES_FIN_SEMANA,
        V.HAY_PROMOCION,
        V.EVENTO_ADVERSO,
        V.DIA_SEMANA,
        V.NOMBRE_MES,
        
        -- Anomalías
        ANOMALY_DETECTION(V.VENTAS_TOTALES, V.TIPO_TIENDA, V.REGION) 
            OVER (PARTITION BY V.TIPO_TIENDA, V.REGION ORDER BY V.FECHA) AS SCORE_ANOMALIA_VENTAS,
            
        ANOMALY_DETECTION(V.TICKET_PROMEDIO, V.TIPO_TIENDA, V.REGION)
            OVER (PARTITION BY V.TIPO_TIENDA, V.REGION ORDER BY V.FECHA) AS SCORE_ANOMALIA_TICKET,
        
        -- Clasificaciones
        CASE 
            WHEN ANOMALY_DETECTION(V.VENTAS_TOTALES, V.TIPO_TIENDA, V.REGION) 
                OVER (PARTITION BY V.TIPO_TIENDA, V.REGION ORDER BY V.FECHA) < -2 THEN 'Crítica'
            WHEN ANOMALY_DETECTION(V.VENTAS_TOTALES, V.TIPO_TIENDA, V.REGION)
                OVER (PARTITION BY V.TIPO_TIENDA, V.REGION ORDER BY V.FECHA) < -1.5 THEN 'Moderada'
            WHEN ANOMALY_DETECTION(V.VENTAS_TOTALES, V.TIPO_TIENDA, V.REGION)
                OVER (PARTITION BY V.TIPO_TIENDA, V.REGION ORDER BY V.FECHA) > 2 THEN 'Pico'
            ELSE 'Normal'
        END AS CLASIFICACION_ANOMALIA
        
    FROM CCONTROL_SCHEMA.VW_VENTAS_MULTISERIES V
)
SELECT * FROM ANOMALIAS_TODAS;

-- Verificar vista creada
SELECT * FROM CCONTROL_SCHEMA.VW_DASHBOARD_ANOMALIAS
WHERE FECHA >= DATEADD(DAY, -30, CURRENT_DATE())
ORDER BY FECHA DESC, TIPO_TIENDA, REGION
LIMIT 50;

-- ################################################################################
-- ANÁLISIS 7: Alertas y Monitoreo
-- ################################################################################

-- 7.1 Anomalías de las Últimas 24 Horas (Simulación con último día)
SELECT 
    FECHA,
    TIPO_TIENDA,
    REGION,
    NOMBRE_SUCURSAL,
    ROUND(VENTAS_TOTALES, 2) AS VENTAS,
    ROUND(SCORE_ANOMALIA_VENTAS, 3) AS SCORE,
    CLASIFICACION_ANOMALIA AS SEVERIDAD,
    EVENTO_ADVERSO,
    
    -- URL de acción (simulado)
    'https://dashboard.ccontrol.com.mx/anomaly/' || TO_CHAR(FECHA, 'YYYYMMDD') || '/' || NOMBRE_SUCURSAL AS URL_DETALLE

FROM CCONTROL_SCHEMA.VW_DASHBOARD_ANOMALIAS
WHERE FECHA = (SELECT MAX(FECHA) FROM CCONTROL_SCHEMA.VW_DASHBOARD_ANOMALIAS)
    AND CLASIFICACION_ANOMALIA IN ('Crítica', 'Moderada')
ORDER BY SCORE_ANOMALIA_VENTAS ASC;

-- 7.2 Top 10 Sucursales con Más Anomalías (Últimos 30 días)
WITH RANKING_SUCURSALES AS (
    SELECT 
        NOMBRE_SUCURSAL,
        TIPO_TIENDA,
        REGION,
        COUNT(*) AS TOTAL_DIAS,
        SUM(CASE WHEN CLASIFICACION_ANOMALIA = 'Crítica' THEN 1 ELSE 0 END) AS DIAS_CRITICOS,
        SUM(CASE WHEN CLASIFICACION_ANOMALIA = 'Moderada' THEN 1 ELSE 0 END) AS DIAS_MODERADOS,
        ROUND(AVG(VENTAS_TOTALES), 2) AS PROMEDIO_VENTAS,
        ROUND(MIN(SCORE_ANOMALIA_VENTAS), 3) AS PEOR_SCORE
        
    FROM CCONTROL_SCHEMA.VW_DASHBOARD_ANOMALIAS
    WHERE FECHA >= DATEADD(DAY, -30, CURRENT_DATE())
    GROUP BY NOMBRE_SUCURSAL, TIPO_TIENDA, REGION
)
SELECT 
    NOMBRE_SUCURSAL,
    TIPO_TIENDA,
    REGION,
    TOTAL_DIAS,
    DIAS_CRITICOS,
    DIAS_MODERADOS,
    DIAS_CRITICOS + DIAS_MODERADOS AS TOTAL_DIAS_ANORMALES,
    ROUND(100.0 * (DIAS_CRITICOS + DIAS_MODERADOS) / TOTAL_DIAS, 2) AS PCT_DIAS_ANORMALES,
    PROMEDIO_VENTAS,
    PEOR_SCORE,
    RANK() OVER (ORDER BY DIAS_CRITICOS DESC, DIAS_MODERADOS DESC) AS RANKING
    
FROM RANKING_SUCURSALES
ORDER BY RANKING
LIMIT 10;

-- ################################################################################
-- FIN DE QUERIES AVANZADAS
-- ################################################################################

/*
INSTRUCCIONES DE USO:

1. Todas estas queries asumen que ya ejecutaste el script principal 
   (CCONTROL_Anomaly_Detection_Demo.sql)

2. Puedes ejecutar las queries individualmente según tu necesidad de análisis

3. La vista VW_DASHBOARD_ANOMALIAS está lista para conectarse a herramientas de BI

4. Estas queries son ejemplos - puedes modificarlas según tus necesidades específicas

PRÓXIMOS PASOS:
- Crear Snowflake Tasks para ejecutar alertas automáticas
- Integrar con sistemas de notificación (email, Slack, etc.)
- Crear dashboards interactivos en Tableau/Power BI/Streamlit
*/

