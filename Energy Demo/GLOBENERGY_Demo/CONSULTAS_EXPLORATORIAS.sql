/*
================================================================================
  CONSULTAS EXPLORATORIAS - GLOBENERGY DEMO
================================================================================
  
  Este archivo contiene consultas simples y rápidas para explorar los datos
  de manera interactiva. Ideal para:
  
  - Exploración inicial de datos
  - Demostraciones interactivas
  - Workshops y entrenamientos
  - Quick insights para stakeholders
  
  📝 Instrucciones: Ejecuta cada consulta individualmente (selecciona y Run)
================================================================================
*/

USE ROLE SYSADMIN;
USE WAREHOUSE GLOBENERGY_WH;
USE SCHEMA GLOBENERGY_DB.ENERGIA;

-- ============================================================================
-- 🔍 EXPLORACIÓN BÁSICA
-- ============================================================================

-- ¿Cuántos clientes tenemos y dónde están?
SELECT 
    PAIS,
    REGION,
    COUNT(*) AS TOTAL_CLIENTES,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS PORCENTAJE
FROM GLOBENERGY_DB.ENERGIA.CLIENTES
WHERE ESTADO = 'Activo'
GROUP BY PAIS, REGION
ORDER BY TOTAL_CLIENTES DESC;

-- ¿Qué tipos de energía ofrecemos?
SELECT 
    NOMBRE_TIPO,
    CATEGORIA,
    UNIDAD_MEDIDA,
    PRECIO_BASE_UNITARIO AS PRECIO_USD,
    FACTOR_EMISION_CO2 AS CO2_KG_POR_UNIDAD,
    CASE 
        WHEN FACTOR_EMISION_CO2 = 0 THEN '🌱 Cero Emisiones'
        WHEN FACTOR_EMISION_CO2 < 2 THEN '🟢 Bajas Emisiones'
        WHEN FACTOR_EMISION_CO2 < 6 THEN '🟡 Emisiones Moderadas'
        ELSE '🔴 Altas Emisiones'
    END AS NIVEL_EMISION
FROM GLOBENERGY_DB.ENERGIA.TIPOS_ENERGIA
ORDER BY FACTOR_EMISION_CO2;

-- ¿Cuántos registros de consumo tenemos por mes?
SELECT 
    ANIO,
    MES,
    COUNT(*) AS TOTAL_REGISTROS,
    ROUND(SUM(VOLUMEN_CONSUMIDO), 0) AS VOLUMEN_TOTAL,
    ROUND(SUM(COSTO_TOTAL), 2) AS COSTO_TOTAL_USD
FROM GLOBENERGY_DB.ENERGIA.CONSUMO
GROUP BY ANIO, MES
ORDER BY ANIO DESC, MES DESC
LIMIT 12;

-- ============================================================================
-- 💰 ANÁLISIS DE COSTOS
-- ============================================================================

-- Top 5 clientes con mayor gasto
SELECT 
    cl.NOMBRE_CLIENTE,
    cl.SECTOR,
    cl.PAIS,
    COUNT(DISTINCT c.CONSUMO_ID) AS REGISTROS,
    ROUND(SUM(c.COSTO_TOTAL), 2) AS COSTO_TOTAL_USD,
    ROUND(AVG(c.COSTO_TOTAL), 2) AS COSTO_PROMEDIO_USD
FROM GLOBENERGY_DB.ENERGIA.CONSUMO c
JOIN GLOBENERGY_DB.ENERGIA.CLIENTES cl ON c.CLIENTE_ID = cl.CLIENTE_ID
WHERE cl.ESTADO = 'Activo'
GROUP BY cl.NOMBRE_CLIENTE, cl.SECTOR, cl.PAIS
ORDER BY COSTO_TOTAL_USD DESC
LIMIT 5;

-- ¿Cuánto cuesta cada tipo de energía en promedio?
SELECT 
    te.NOMBRE_TIPO,
    te.CATEGORIA,
    COUNT(c.CONSUMO_ID) AS REGISTROS,
    ROUND(AVG(c.COSTO_TOTAL), 2) AS COSTO_PROMEDIO_USD,
    ROUND(SUM(c.COSTO_TOTAL), 2) AS COSTO_TOTAL_USD,
    te.UNIDAD_MEDIDA
FROM GLOBENERGY_DB.ENERGIA.CONSUMO c
JOIN GLOBENERGY_DB.ENERGIA.TIPOS_ENERGIA te ON c.TIPO_ENERGIA_ID = te.TIPO_ENERGIA_ID
GROUP BY te.NOMBRE_TIPO, te.CATEGORIA, te.UNIDAD_MEDIDA
ORDER BY COSTO_TOTAL_USD DESC;

-- Comparativa de costos: Hora Pico vs Hora Normal
SELECT 
    CASE WHEN HORA_PICO THEN 'Hora Pico 🔴' ELSE 'Hora Normal 🟢' END AS TIPO_HORA,
    COUNT(*) AS REGISTROS,
    ROUND(AVG(COSTO_TOTAL), 2) AS COSTO_PROMEDIO_USD,
    ROUND(SUM(COSTO_TOTAL), 2) AS COSTO_TOTAL_USD,
    ROUND((AVG(COSTO_TOTAL) - (SELECT AVG(COSTO_TOTAL) FROM GLOBENERGY_DB.ENERGIA.CONSUMO WHERE HORA_PICO = FALSE)) 
          / (SELECT AVG(COSTO_TOTAL) FROM GLOBENERGY_DB.ENERGIA.CONSUMO WHERE HORA_PICO = FALSE) * 100, 1) AS INCREMENTO_PCT
FROM GLOBENERGY_DB.ENERGIA.CONSUMO
GROUP BY TIPO_HORA
ORDER BY COSTO_PROMEDIO_USD DESC;

-- ============================================================================
-- 🌱 SOSTENIBILIDAD Y EMISIONES
-- ============================================================================

-- Emisiones de CO2 por sector
SELECT 
    cl.SECTOR,
    COUNT(DISTINCT cl.CLIENTE_ID) AS CLIENTES,
    ROUND(SUM(c.EMISION_CO2_KG) / 1000, 2) AS EMISION_TOTAL_TONELADAS,
    ROUND(AVG(c.EMISION_CO2_KG), 2) AS EMISION_PROMEDIO_KG,
    CASE 
        WHEN SUM(c.EMISION_CO2_KG) / 1000 > 100000 THEN '🔴 Alto'
        WHEN SUM(c.EMISION_CO2_KG) / 1000 > 50000 THEN '🟡 Medio'
        ELSE '🟢 Bajo'
    END AS NIVEL_EMISION
FROM GLOBENERGY_DB.ENERGIA.CONSUMO c
JOIN GLOBENERGY_DB.ENERGIA.CLIENTES cl ON c.CLIENTE_ID = cl.CLIENTE_ID
GROUP BY cl.SECTOR
ORDER BY EMISION_TOTAL_TONELADAS DESC;

-- Comparativa: Energías Fósiles vs Renovables
SELECT 
    te.CATEGORIA,
    COUNT(c.CONSUMO_ID) AS REGISTROS,
    ROUND(SUM(c.VOLUMEN_CONSUMIDO), 2) AS VOLUMEN_TOTAL,
    ROUND(SUM(c.COSTO_TOTAL), 2) AS COSTO_TOTAL_USD,
    ROUND(SUM(c.EMISION_CO2_KG) / 1000, 2) AS EMISION_CO2_TONELADAS,
    CASE 
        WHEN te.CATEGORIA = 'Renovable' THEN '🌱 Zero Carbon'
        ELSE '⚡ Con Emisiones'
    END AS TIPO
FROM GLOBENERGY_DB.ENERGIA.CONSUMO c
JOIN GLOBENERGY_DB.ENERGIA.TIPOS_ENERGIA te ON c.TIPO_ENERGIA_ID = te.TIPO_ENERGIA_ID
GROUP BY te.CATEGORIA
ORDER BY EMISION_CO2_TONELADAS DESC;

-- ¿Cuánto CO2 ahorramos si todos migraran a renovables?
WITH EMISION_ACTUAL AS (
    SELECT SUM(EMISION_CO2_KG) / 1000 AS TONELADAS_ACTUAL
    FROM GLOBENERGY_DB.ENERGIA.CONSUMO
),
EMISION_FOSIL AS (
    SELECT SUM(c.EMISION_CO2_KG) / 1000 AS TONELADAS_FOSIL
    FROM GLOBENERGY_DB.ENERGIA.CONSUMO c
    JOIN GLOBENERGY_DB.ENERGIA.TIPOS_ENERGIA te ON c.TIPO_ENERGIA_ID = te.TIPO_ENERGIA_ID
    WHERE te.CATEGORIA IN ('Fósil', 'Híbrida')
)
SELECT 
    ROUND(ea.TONELADAS_ACTUAL, 2) AS EMISION_ACTUAL_TONELADAS,
    ROUND(ef.TONELADAS_FOSIL, 2) AS EMISION_FOSIL_TONELADAS,
    ROUND(ef.TONELADAS_FOSIL, 2) AS AHORRO_POTENCIAL_TONELADAS,
    ROUND((ef.TONELADAS_FOSIL / ea.TONELADAS_ACTUAL) * 100, 1) AS PORCENTAJE_REDUCIBLE,
    '🌱 Migración completa a renovables eliminaría estas emisiones' AS INSIGHT
FROM EMISION_ACTUAL ea, EMISION_FOSIL ef;

-- ============================================================================
-- 📊 ANÁLISIS POR SECTOR
-- ============================================================================

-- Perfil completo por sector
SELECT 
    cl.SECTOR,
    COUNT(DISTINCT cl.CLIENTE_ID) AS TOTAL_CLIENTES,
    COUNT(c.CONSUMO_ID) AS REGISTROS_CONSUMO,
    ROUND(AVG(c.VOLUMEN_CONSUMIDO), 2) AS CONSUMO_PROMEDIO,
    ROUND(SUM(c.COSTO_TOTAL), 2) AS COSTO_TOTAL_USD,
    ROUND(AVG(c.EFICIENCIA_ENERGETICA), 1) AS EFICIENCIA_PROMEDIO_PCT,
    ROUND(SUM(c.EMISION_CO2_KG) / 1000, 2) AS EMISION_CO2_TONELADAS
FROM GLOBENERGY_DB.ENERGIA.CONSUMO c
JOIN GLOBENERGY_DB.ENERGIA.CLIENTES cl ON c.CLIENTE_ID = cl.CLIENTE_ID
WHERE cl.ESTADO = 'Activo'
GROUP BY cl.SECTOR
ORDER BY COSTO_TOTAL_USD DESC;

-- ¿Qué sectores son más eficientes energéticamente?
SELECT 
    cl.SECTOR,
    ROUND(AVG(c.EFICIENCIA_ENERGETICA), 2) AS EFICIENCIA_PROMEDIO_PCT,
    COUNT(*) AS REGISTROS,
    CASE 
        WHEN AVG(c.EFICIENCIA_ENERGETICA) >= 85 THEN '🏆 Excelente'
        WHEN AVG(c.EFICIENCIA_ENERGETICA) >= 75 THEN '🟢 Bueno'
        WHEN AVG(c.EFICIENCIA_ENERGETICA) >= 65 THEN '🟡 Regular'
        ELSE '🔴 Necesita Mejora'
    END AS CALIFICACION
FROM GLOBENERGY_DB.ENERGIA.CONSUMO c
JOIN GLOBENERGY_DB.ENERGIA.CLIENTES cl ON c.CLIENTE_ID = cl.CLIENTE_ID
GROUP BY cl.SECTOR
ORDER BY EFICIENCIA_PROMEDIO_PCT DESC;

-- ============================================================================
-- 🌡️ IMPACTO DE TEMPERATURA EN CONSUMO
-- ============================================================================

-- Correlación temperatura vs consumo
SELECT 
    CASE 
        WHEN TEMPERATURA_PROMEDIO_C < 0 THEN '🥶 Bajo Cero (< 0°C)'
        WHEN TEMPERATURA_PROMEDIO_C < 10 THEN '❄️ Frío (0-10°C)'
        WHEN TEMPERATURA_PROMEDIO_C < 20 THEN '🌤️ Templado (10-20°C)'
        WHEN TEMPERATURA_PROMEDIO_C < 30 THEN '☀️ Cálido (20-30°C)'
        ELSE '🔥 Calor Extremo (>30°C)'
    END AS RANGO_TEMPERATURA,
    COUNT(*) AS REGISTROS,
    ROUND(AVG(VOLUMEN_CONSUMIDO), 2) AS CONSUMO_PROMEDIO,
    ROUND(AVG(COSTO_TOTAL), 2) AS COSTO_PROMEDIO_USD,
    ROUND(AVG(TEMPERATURA_PROMEDIO_C), 1) AS TEMP_PROMEDIO_C
FROM GLOBENERGY_DB.ENERGIA.CONSUMO
GROUP BY RANGO_TEMPERATURA
ORDER BY TEMP_PROMEDIO_C;

-- ============================================================================
-- 🌪️ EVENTOS CLIMÁTICOS Y SU IMPACTO
-- ============================================================================

-- Resumen de eventos climáticos por tipo
SELECT 
    TIPO_EVENTO,
    COUNT(*) AS TOTAL_EVENTOS,
    ROUND(AVG(DURACION_DIAS), 1) AS DURACION_PROMEDIO_DIAS,
    SUM(CLIENTES_AFECTADOS) AS TOTAL_CLIENTES_AFECTADOS,
    ROUND(SUM(PERDIDA_SUMINISTRO_HORAS), 1) AS TOTAL_HORAS_PERDIDAS,
    ROUND(SUM(COSTO_MITIGACION), 2) AS COSTO_TOTAL_MITIGACION_USD,
    CASE 
        WHEN COUNT(*) > 10 THEN '🔴 Frecuente'
        WHEN COUNT(*) > 5 THEN '🟡 Moderado'
        ELSE '🟢 Bajo'
    END AS FRECUENCIA
FROM GLOBENERGY_DB.ENERGIA.EVENTOS_CLIMATICOS
GROUP BY TIPO_EVENTO
ORDER BY TOTAL_CLIENTES_AFECTADOS DESC;

-- Eventos climáticos más costosos
SELECT 
    EVENTO_ID,
    TIPO_EVENTO,
    SEVERIDAD,
    PAIS,
    REGION,
    FECHA_INICIO,
    DURACION_DIAS,
    CLIENTES_AFECTADOS,
    ROUND(PERDIDA_SUMINISTRO_HORAS, 1) AS HORAS_PERDIDAS,
    ROUND(COSTO_MITIGACION, 2) AS COSTO_MITIGACION_USD,
    CASE 
        WHEN COSTO_MITIGACION > 400000 THEN '🔴 Crítico'
        WHEN COSTO_MITIGACION > 200000 THEN '🟡 Alto'
        ELSE '🟢 Moderado'
    END AS NIVEL_IMPACTO
FROM GLOBENERGY_DB.ENERGIA.EVENTOS_CLIMATICOS
ORDER BY COSTO_MITIGACION DESC
LIMIT 10;

-- ¿Qué regiones son más vulnerables a eventos climáticos?
SELECT 
    REGION,
    COUNT(*) AS TOTAL_EVENTOS,
    SUM(CLIENTES_AFECTADOS) AS CLIENTES_AFECTADOS,
    ROUND(AVG(DURACION_DIAS), 1) AS DURACION_PROMEDIO_DIAS,
    ROUND(SUM(COSTO_MITIGACION), 2) AS COSTO_TOTAL_USD,
    CASE 
        WHEN COUNT(*) > 15 THEN '🔴 Alto Riesgo'
        WHEN COUNT(*) > 10 THEN '🟡 Riesgo Medio'
        ELSE '🟢 Riesgo Bajo'
    END AS NIVEL_RIESGO
FROM GLOBENERGY_DB.ENERGIA.EVENTOS_CLIMATICOS
GROUP BY REGION
ORDER BY TOTAL_EVENTOS DESC;

-- ============================================================================
-- 🔮 PREDICCIONES DE DEMANDA
-- ============================================================================

-- ¿Qué tan precisas son nuestras predicciones?
SELECT 
    te.NOMBRE_TIPO,
    te.CATEGORIA,
    COUNT(pd.PREDICCION_ID) AS TOTAL_PREDICCIONES,
    ROUND(AVG(pd.CONFIANZA_MODELO), 1) AS CONFIANZA_PROMEDIO_PCT,
    ROUND(AVG(ABS(pd.ERROR_PORCENTUAL)), 1) AS ERROR_PROMEDIO_PCT,
    ROUND(100 - AVG(ABS(pd.ERROR_PORCENTUAL)), 1) AS PRECISION_PCT,
    CASE 
        WHEN AVG(ABS(pd.ERROR_PORCENTUAL)) < 5 THEN '🏆 Excelente'
        WHEN AVG(ABS(pd.ERROR_PORCENTUAL)) < 10 THEN '🟢 Bueno'
        WHEN AVG(ABS(pd.ERROR_PORCENTUAL)) < 15 THEN '🟡 Regular'
        ELSE '🔴 Necesita Mejora'
    END AS CALIDAD_MODELO
FROM GLOBENERGY_DB.ENERGIA.PREDICCIONES_DEMANDA pd
JOIN GLOBENERGY_DB.ENERGIA.TIPOS_ENERGIA te ON pd.TIPO_ENERGIA_ID = te.TIPO_ENERGIA_ID
GROUP BY te.NOMBRE_TIPO, te.CATEGORIA
ORDER BY PRECISION_PCT DESC;

-- Predicciones con mayor desviación (alertas)
SELECT 
    pd.PREDICCION_ID,
    cl.NOMBRE_CLIENTE,
    te.NOMBRE_TIPO,
    pd.FECHA_PREDICCION,
    ROUND(pd.VOLUMEN_PREDICHO, 2) AS PREDICHO,
    ROUND(pd.VOLUMEN_REAL, 2) AS REAL,
    ROUND(pd.ERROR_PORCENTUAL, 1) AS ERROR_PCT,
    CASE 
        WHEN pd.ERROR_PORCENTUAL > 0 THEN '📈 Subestimado'
        ELSE '📉 Sobrestimado'
    END AS TIPO_ERROR,
    CASE 
        WHEN ABS(pd.ERROR_PORCENTUAL) > 20 THEN '🔴 Crítico'
        WHEN ABS(pd.ERROR_PORCENTUAL) > 10 THEN '🟡 Alerta'
        ELSE '🟢 OK'
    END AS NIVEL_ALERTA
FROM GLOBENERGY_DB.ENERGIA.PREDICCIONES_DEMANDA pd
JOIN GLOBENERGY_DB.ENERGIA.CLIENTES cl ON pd.CLIENTE_ID = cl.CLIENTE_ID
JOIN GLOBENERGY_DB.ENERGIA.TIPOS_ENERGIA te ON pd.TIPO_ENERGIA_ID = te.TIPO_ENERGIA_ID
WHERE ABS(pd.ERROR_PORCENTUAL) > 10
ORDER BY ABS(pd.ERROR_PORCENTUAL) DESC
LIMIT 10;

-- ============================================================================
-- 📋 GESTIÓN DE CONTRATOS
-- ============================================================================

-- Contratos próximos a vencer (próximos 90 días)
SELECT 
    co.CONTRATO_ID,
    cl.NOMBRE_CLIENTE,
    cl.SECTOR,
    te.NOMBRE_TIPO,
    co.TIPO_CONTRATO,
    co.FECHA_FIN,
    DATEDIFF(DAY, CURRENT_DATE(), co.FECHA_FIN) AS DIAS_PARA_VENCER,
    ROUND(co.PRECIO_UNITARIO, 4) AS PRECIO_UNITARIO,
    CASE 
        WHEN co.ENERGIA_RENOVABLE THEN '🌱 Renovable'
        ELSE '⚡ Convencional'
    END AS TIPO_ENERGIA,
    CASE 
        WHEN DATEDIFF(DAY, CURRENT_DATE(), co.FECHA_FIN) <= 30 THEN '🔴 Urgente'
        WHEN DATEDIFF(DAY, CURRENT_DATE(), co.FECHA_FIN) <= 60 THEN '🟡 Prioritario'
        ELSE '🟢 Planificado'
    END AS PRIORIDAD
FROM GLOBENERGY_DB.ENERGIA.CONTRATOS co
JOIN GLOBENERGY_DB.ENERGIA.CLIENTES cl ON co.CLIENTE_ID = cl.CLIENTE_ID
JOIN GLOBENERGY_DB.ENERGIA.TIPOS_ENERGIA te ON co.TIPO_ENERGIA_ID = te.TIPO_ENERGIA_ID
WHERE co.ESTADO_CONTRATO = 'Activo'
  AND DATEDIFF(DAY, CURRENT_DATE(), co.FECHA_FIN) BETWEEN 0 AND 90
ORDER BY DIAS_PARA_VENCER;

-- Distribución de contratos por tipo
SELECT 
    co.TIPO_CONTRATO,
    COUNT(*) AS TOTAL_CONTRATOS,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS PORCENTAJE,
    SUM(CASE WHEN co.ESTADO_CONTRATO = 'Activo' THEN 1 ELSE 0 END) AS ACTIVOS,
    SUM(CASE WHEN co.ENERGIA_RENOVABLE THEN 1 ELSE 0 END) AS RENOVABLES,
    ROUND(AVG(co.PRECIO_UNITARIO), 4) AS PRECIO_PROMEDIO
FROM GLOBENERGY_DB.ENERGIA.CONTRATOS co
GROUP BY co.TIPO_CONTRATO
ORDER BY TOTAL_CONTRATOS DESC;

-- ============================================================================
-- 📈 TENDENCIAS TEMPORALES
-- ============================================================================

-- Consumo por trimestre
SELECT 
    ANIO,
    TRIMESTRE,
    CASE TRIMESTRE
        WHEN 1 THEN 'Q1 (Ene-Mar)'
        WHEN 2 THEN 'Q2 (Abr-Jun)'
        WHEN 3 THEN 'Q3 (Jul-Sep)'
        ELSE 'Q4 (Oct-Dic)'
    END AS TRIMESTRE_NOMBRE,
    COUNT(*) AS REGISTROS,
    ROUND(SUM(VOLUMEN_CONSUMIDO), 0) AS VOLUMEN_TOTAL,
    ROUND(SUM(COSTO_TOTAL), 2) AS COSTO_TOTAL_USD,
    ROUND(SUM(EMISION_CO2_KG) / 1000, 2) AS EMISION_CO2_TONELADAS
FROM GLOBENERGY_DB.ENERGIA.CONSUMO
GROUP BY ANIO, TRIMESTRE
ORDER BY ANIO DESC, TRIMESTRE DESC;

-- ============================================================================
-- 💡 INSIGHTS RÁPIDOS
-- ============================================================================

-- Dashboard Ejecutivo - Vista 360°
SELECT 
    '📊 RESUMEN EJECUTIVO GLOBENERGY' AS CATEGORIA,
    '================================' AS SEPARADOR;

SELECT 'Total Clientes' AS METRICA, COUNT(*)::VARCHAR AS VALOR, '👥' AS ICONO
FROM GLOBENERGY_DB.ENERGIA.CLIENTES WHERE ESTADO = 'Activo'
UNION ALL
SELECT 'Países Atendidos', COUNT(DISTINCT PAIS)::VARCHAR, '🌍'
FROM GLOBENERGY_DB.ENERGIA.CLIENTES
UNION ALL
SELECT 'Contratos Activos', COUNT(*)::VARCHAR, '📋'
FROM GLOBENERGY_DB.ENERGIA.CONTRATOS WHERE ESTADO_CONTRATO = 'Activo'
UNION ALL
SELECT 'Registros de Consumo', COUNT(*)::VARCHAR, '⚡'
FROM GLOBENERGY_DB.ENERGIA.CONSUMO
UNION ALL
SELECT 'Facturación Total (USD)', TO_VARCHAR(ROUND(SUM(COSTO_TOTAL), 0)), '💰'
FROM GLOBENERGY_DB.ENERGIA.CONSUMO
UNION ALL
SELECT 'Emisiones CO2 (Toneladas)', TO_VARCHAR(ROUND(SUM(EMISION_CO2_KG)/1000, 0)), '🌱'
FROM GLOBENERGY_DB.ENERGIA.CONSUMO
UNION ALL
SELECT 'Eficiencia Promedio (%)', TO_VARCHAR(ROUND(AVG(EFICIENCIA_ENERGETICA), 1)), '📈'
FROM GLOBENERGY_DB.ENERGIA.CONSUMO
UNION ALL
SELECT 'Eventos Climáticos', COUNT(*)::VARCHAR, '🌪️'
FROM GLOBENERGY_DB.ENERGIA.EVENTOS_CLIMATICOS
UNION ALL
SELECT 'Precisión Predicciones (%)', TO_VARCHAR(ROUND(100 - AVG(ABS(ERROR_PORCENTUAL)), 1)), '🔮'
FROM GLOBENERGY_DB.ENERGIA.PREDICCIONES_DEMANDA;

/*
================================================================================
  🎉 FIN DE CONSULTAS EXPLORATORIAS
================================================================================

  💡 TIPS PARA DEMOS:
  
  1. Comienza con la vista "Dashboard Ejecutivo" (última consulta)
  2. Muestra la distribución geográfica de clientes
  3. Compara Energías Fósiles vs Renovables
  4. Demuestra el impacto de eventos climáticos
  5. Finaliza con precisión de predicciones ML
  
  📊 HERRAMIENTAS RECOMENDADAS:
  - Snowsight (nativo en Snowflake)
  - Tableau / Power BI
  - Streamlit (para apps interactivas)
  - Grafana (para dashboards en tiempo real)

================================================================================
*/

