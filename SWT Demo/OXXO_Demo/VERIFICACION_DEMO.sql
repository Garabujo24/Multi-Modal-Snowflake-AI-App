-- ============================================================================
-- 🔍 SCRIPT DE VERIFICACIÓN - OXXO Demo
-- ============================================================================
-- Ejecutar DESPUÉS de completar OXXO_ML_DEMO.sql para verificar que todo
-- esté correctamente configurado.
-- ============================================================================

USE ROLE OXXO_DATA_SCIENTIST;
USE WAREHOUSE OXXO_ML_WH;
USE DATABASE OXXO_DEMO_DB;
USE SCHEMA RETAIL;

-- ============================================================================
-- 1. VERIFICAR OBJETOS CREADOS
-- ============================================================================

SELECT '✅ VERIFICANDO OBJETOS CREADOS...' AS STATUS;

-- 1.1 Warehouse
SHOW WAREHOUSES LIKE 'OXXO_ML_WH';

SELECT 
    NAME,
    STATE,
    SIZE,
    AUTO_SUSPEND,
    COMMENT
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- 1.2 Database y Schema
SHOW DATABASES LIKE 'OXXO_DEMO_DB';
SHOW SCHEMAS IN DATABASE OXXO_DEMO_DB;

-- 1.3 Tablas
SHOW TABLES IN SCHEMA OXXO_DEMO_DB.RETAIL;

SELECT 
    'Tablas creadas:' AS INFO,
    COUNT(*) AS CANTIDAD
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- ============================================================================
-- 2. VERIFICAR DATOS EN TABLAS
-- ============================================================================

SELECT '✅ VERIFICANDO DATOS EN TABLAS...' AS STATUS;

-- 2.1 Productos
SELECT 
    'PRODUCTOS' AS TABLA,
    COUNT(*) AS TOTAL_REGISTROS,
    COUNT(DISTINCT CATEGORIA) AS CATEGORIAS_UNICAS,
    MIN(PRECIO_UNITARIO) AS PRECIO_MIN,
    MAX(PRECIO_UNITARIO) AS PRECIO_MAX,
    ROUND(AVG(PRECIO_UNITARIO), 2) AS PRECIO_PROMEDIO
FROM PRODUCTOS;

-- Verificar que tengamos productos de alta rotación
SELECT 
    ROTACION,
    COUNT(*) AS CANTIDAD
FROM PRODUCTOS
GROUP BY ROTACION
ORDER BY CANTIDAD DESC;

-- 2.2 Tiendas
SELECT 
    'TIENDAS' AS TABLA,
    COUNT(*) AS TOTAL_REGISTROS,
    COUNT(DISTINCT CIUDAD) AS CIUDADES_UNICAS,
    COUNT(DISTINCT ESTADO) AS ESTADOS_UNICOS
FROM TIENDAS;

-- Distribución por ciudad
SELECT 
    CIUDAD,
    COUNT(*) AS NUM_TIENDAS,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS PORCENTAJE
FROM TIENDAS
GROUP BY CIUDAD
ORDER BY NUM_TIENDAS DESC
LIMIT 5;

-- 2.3 Ventas Históricas (tabla principal)
SELECT 
    'VENTAS_HISTORICAS' AS TABLA,
    COUNT(*) AS TOTAL_REGISTROS,
    MIN(FECHA) AS FECHA_MIN,
    MAX(FECHA) AS FECHA_MAX,
    DATEDIFF(day, MIN(FECHA), MAX(FECHA)) AS DIAS_DE_HISTORIA
FROM VENTAS_HISTORICAS;

-- ============================================================================
-- 3. VERIFICAR CALIDAD DE DATOS
-- ============================================================================

SELECT '✅ VERIFICANDO CALIDAD DE DATOS...' AS STATUS;

-- 3.1 Verificar clases desbalanceadas (debe ser ~90/10)
SELECT 
    '📊 Distribución de Clases' AS METRICA,
    QUIEBRE_STOCK,
    COUNT(*) AS CANTIDAD,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS PORCENTAJE
FROM VENTAS_HISTORICAS
GROUP BY QUIEBRE_STOCK
ORDER BY QUIEBRE_STOCK;

-- 3.2 Verificar datos faltantes (NULLs)
SELECT 
    'INVENTARIO_INICIAL' AS CAMPO,
    COUNT(*) AS TOTAL,
    SUM(CASE WHEN INVENTARIO_INICIAL IS NULL THEN 1 ELSE 0 END) AS NULOS,
    ROUND(SUM(CASE WHEN INVENTARIO_INICIAL IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS PORCENTAJE_NULOS,
    CASE 
        WHEN ROUND(SUM(CASE WHEN INVENTARIO_INICIAL IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) BETWEEN 4 AND 6 
        THEN '✅ OK (esperado ~5%)'
        ELSE '⚠️ Fuera de rango esperado'
    END AS STATUS
FROM VENTAS_HISTORICAS
UNION ALL
SELECT
    'TEMPERATURA_CELSIUS',
    COUNT(*),
    SUM(CASE WHEN TEMPERATURA_CELSIUS IS NULL THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN TEMPERATURA_CELSIUS IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2),
    CASE 
        WHEN ROUND(SUM(CASE WHEN TEMPERATURA_CELSIUS IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) BETWEEN 13 AND 17 
        THEN '✅ OK (esperado ~15%)'
        ELSE '⚠️ Fuera de rango esperado'
    END
FROM VENTAS_HISTORICAS
UNION ALL
SELECT
    'TIENE_PROMOCION',
    COUNT(*),
    SUM(CASE WHEN TIENE_PROMOCION IS NULL OR TIENE_PROMOCION = '' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN TIENE_PROMOCION IS NULL OR TIENE_PROMOCION = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2),
    CASE 
        WHEN ROUND(SUM(CASE WHEN TIENE_PROMOCION IS NULL OR TIENE_PROMOCION = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) BETWEEN 8 AND 12 
        THEN '✅ OK (esperado ~10%)'
        ELSE '⚠️ Fuera de rango esperado'
    END
FROM VENTAS_HISTORICAS;

-- 3.3 Verificar distribución de ventas (no debe tener valores absurdos)
SELECT 
    '📈 Estadísticas de Ventas' AS METRICA,
    MIN(UNIDADES_VENDIDAS) AS MIN_VENTAS,
    ROUND(AVG(UNIDADES_VENDIDAS), 2) AS PROMEDIO_VENTAS,
    MEDIAN(UNIDADES_VENDIDAS) AS MEDIANA_VENTAS,
    MAX(UNIDADES_VENDIDAS) AS MAX_VENTAS,
    STDDEV(UNIDADES_VENDIDAS) AS DESVIACION_STD
FROM VENTAS_HISTORICAS;

-- ============================================================================
-- 4. VERIFICAR TABLAS DE FEATURES
-- ============================================================================

SELECT '✅ VERIFICANDO TABLAS DE FEATURES...' AS STATUS;

-- 4.1 Features de Clasificación
SELECT 
    'FEATURES_CLASIFICACION' AS TABLA,
    COUNT(*) AS TOTAL_REGISTROS,
    COUNT(*) FILTER (WHERE FECHA < '2025-09-15') AS REGISTROS_VALIDOS
FROM FEATURES_CLASIFICACION;

-- Verificar que no haya muchos NULLs después de imputación
SELECT 
    'Nulos en Features (después de imputación)' AS CHECK_TYPE,
    SUM(CASE WHEN INVENTARIO_INICIAL IS NULL THEN 1 ELSE 0 END) AS NULOS_INVENTARIO,
    SUM(CASE WHEN TEMPERATURA_CELSIUS IS NULL THEN 1 ELSE 0 END) AS NULOS_TEMPERATURA,
    CASE 
        WHEN SUM(CASE WHEN INVENTARIO_INICIAL IS NULL THEN 1 ELSE 0 END) = 0 
         AND SUM(CASE WHEN TEMPERATURA_CELSIUS IS NULL THEN 1 ELSE 0 END) = 0
        THEN '✅ Imputación exitosa'
        ELSE '⚠️ Revise imputación'
    END AS STATUS
FROM FEATURES_CLASIFICACION;

-- 4.2 Train/Test Split
SELECT 
    'Train/Test Split' AS METRICA,
    COUNT(*) FILTER (WHERE FECHA < '2025-09-01') AS TRAIN_RECORDS,
    COUNT(*) FILTER (WHERE FECHA >= '2025-09-01') AS TEST_RECORDS,
    ROUND(COUNT(*) FILTER (WHERE FECHA < '2025-09-01') * 100.0 / COUNT(*), 1) AS TRAIN_PERCENTAGE,
    CASE 
        WHEN ROUND(COUNT(*) FILTER (WHERE FECHA < '2025-09-01') * 100.0 / COUNT(*), 1) BETWEEN 70 AND 85
        THEN '✅ Split apropiado'
        ELSE '⚠️ Revisar split'
    END AS STATUS
FROM FEATURES_CLASIFICACION;

-- 4.3 Features de Forecasting
SELECT 
    'FEATURES_FORECASTING' AS TABLA,
    COUNT(*) AS TOTAL_REGISTROS,
    COUNT(DISTINCT FECHA) AS DIAS_UNICOS,
    MIN(FECHA) AS FECHA_INICIO,
    MAX(FECHA) AS FECHA_FIN
FROM FEATURES_FORECASTING;

-- ============================================================================
-- 5. VERIFICAR VISTAS
-- ============================================================================

SELECT '✅ VERIFICANDO VISTAS...' AS STATUS;

-- 5.1 Vista enriquecida
SELECT 
    'V_VENTAS_ENRIQUECIDAS' AS VISTA,
    COUNT(*) AS TOTAL_REGISTROS,
    COUNT(DISTINCT PRODUCTO_NOMBRE) AS PRODUCTOS_UNICOS,
    COUNT(DISTINCT CODIGO_TIENDA) AS TIENDAS_UNICAS
FROM V_VENTAS_ENRIQUECIDAS;

-- Muestra de datos
SELECT * FROM V_VENTAS_ENRIQUECIDAS LIMIT 5;

-- ============================================================================
-- 6. ANÁLISIS DE NEGOCIO BÁSICO
-- ============================================================================

SELECT '✅ ANÁLISIS DE NEGOCIO...' AS STATUS;

-- 6.1 Productos con mayor riesgo de quiebre
SELECT 
    '🚨 Top 5 Productos con Mayor Tasa de Quiebre' AS ANALISIS,
    p.NOMBRE AS PRODUCTO,
    p.CATEGORIA,
    COUNT(*) AS TOTAL_VENTAS,
    SUM(v.QUIEBRE_STOCK::INT) AS NUM_QUIEBRES,
    ROUND(SUM(v.QUIEBRE_STOCK::INT) * 100.0 / COUNT(*), 2) AS TASA_QUIEBRE_PCT
FROM VENTAS_HISTORICAS v
JOIN PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
GROUP BY p.NOMBRE, p.CATEGORIA
HAVING COUNT(*) >= 100  -- Mínimo 100 ventas para ser estadísticamente significativo
ORDER BY TASA_QUIEBRE_PCT DESC
LIMIT 5;

-- 6.2 Ciudades con más quiebres
SELECT 
    '🗺️ Top 5 Ciudades con Más Quiebres' AS ANALISIS,
    t.CIUDAD,
    COUNT(*) AS TOTAL_VENTAS,
    SUM(v.QUIEBRE_STOCK::INT) AS NUM_QUIEBRES,
    ROUND(SUM(v.QUIEBRE_STOCK::INT) * 100.0 / COUNT(*), 2) AS TASA_QUIEBRE_PCT
FROM VENTAS_HISTORICAS v
JOIN TIENDAS t ON v.TIENDA_ID = t.TIENDA_ID
GROUP BY t.CIUDAD
ORDER BY NUM_QUIEBRES DESC
LIMIT 5;

-- 6.3 Día de la semana con más quiebres
SELECT 
    '📅 Quiebres por Día de la Semana' AS ANALISIS,
    DIA_SEMANA,
    COUNT(*) AS TOTAL_VENTAS,
    SUM(QUIEBRE_STOCK::INT) AS NUM_QUIEBRES,
    ROUND(SUM(QUIEBRE_STOCK::INT) * 100.0 / COUNT(*), 2) AS TASA_QUIEBRE_PCT
FROM VENTAS_HISTORICAS
GROUP BY DIA_SEMANA
ORDER BY 
    CASE DIA_SEMANA
        WHEN 'Lunes' THEN 1
        WHEN 'Martes' THEN 2
        WHEN 'Miércoles' THEN 3
        WHEN 'Jueves' THEN 4
        WHEN 'Viernes' THEN 5
        WHEN 'Sábado' THEN 6
        WHEN 'Domingo' THEN 7
    END;

-- 6.4 Impacto de temperatura en ventas de bebidas
SELECT 
    '🌡️ Correlación Temperatura vs Ventas (Bebidas)' AS ANALISIS,
    CASE 
        WHEN v.TEMPERATURA_CELSIUS < 20 THEN 'Frío (<20°C)'
        WHEN v.TEMPERATURA_CELSIUS BETWEEN 20 AND 28 THEN 'Templado (20-28°C)'
        ELSE 'Calor (>28°C)'
    END AS RANGO_TEMPERATURA,
    COUNT(*) AS NUM_TRANSACCIONES,
    ROUND(AVG(v.UNIDADES_VENDIDAS), 2) AS PROMEDIO_VENTAS,
    ROUND(SUM(v.UNIDADES_VENDIDAS * v.PRECIO_DIA), 2) AS INGRESOS_TOTALES
FROM VENTAS_HISTORICAS v
JOIN PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
WHERE p.CATEGORIA = 'Bebidas'
  AND v.TEMPERATURA_CELSIUS IS NOT NULL
GROUP BY 
    CASE 
        WHEN v.TEMPERATURA_CELSIUS < 20 THEN 'Frío (<20°C)'
        WHEN v.TEMPERATURA_CELSIUS BETWEEN 20 AND 28 THEN 'Templado (20-28°C)'
        ELSE 'Calor (>28°C)'
    END
ORDER BY PROMEDIO_VENTAS DESC;

-- ============================================================================
-- 7. MÉTRICAS PARA PRESENTACIÓN
-- ============================================================================

SELECT '✅ MÉTRICAS CLAVE PARA PRESENTACIÓN...' AS STATUS;

SELECT 
    'RESUMEN EJECUTIVO' AS SECCION,
    
    -- Datos
    (SELECT COUNT(*) FROM PRODUCTOS) AS TOTAL_PRODUCTOS,
    (SELECT COUNT(*) FROM TIENDAS) AS TOTAL_TIENDAS,
    (SELECT COUNT(*) FROM VENTAS_HISTORICAS) AS TOTAL_TRANSACCIONES,
    
    -- Desbalanceo de clases
    (SELECT ROUND(AVG(CASE WHEN QUIEBRE_STOCK THEN 1 ELSE 0 END) * 100, 2) FROM VENTAS_HISTORICAS) AS PORCENTAJE_QUIEBRES,
    
    -- Datos faltantes
    (SELECT ROUND(AVG(CASE WHEN TEMPERATURA_CELSIUS IS NULL THEN 1 ELSE 0 END) * 100, 2) FROM VENTAS_HISTORICAS) AS PORCENTAJE_NULOS_TEMPERATURA,
    
    -- Features
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'FEATURES_CLASIFICACION') AS NUM_FEATURES_CLASIFICACION,
    
    -- Valor de negocio (estimado)
    (SELECT ROUND(SUM(UNIDADES_VENDIDAS * PRECIO_DIA), 2) FROM VENTAS_HISTORICAS) AS INGRESOS_TOTALES_HISTORICOS
;

-- ============================================================================
-- 8. VERIFICACIÓN FINAL
-- ============================================================================

SELECT '✅ VERIFICACIÓN FINAL...' AS STATUS;

-- Contar objetos totales creados
SELECT 
    'RESUMEN DE OBJETOS' AS TIPO,
    
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
     WHERE TABLE_SCHEMA = 'RETAIL' AND TABLE_TYPE = 'BASE TABLE') AS NUM_TABLAS,
    
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.VIEWS 
     WHERE TABLE_SCHEMA = 'RETAIL') AS NUM_VISTAS,
    
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = 'RETAIL') AS NUM_COLUMNAS_TOTALES;

-- Estado del Warehouse
SELECT 
    'WAREHOUSE STATUS' AS TIPO,
    SYSTEM$GET_WAREHOUSE_STATE('OXXO_ML_WH') AS ESTADO;

-- Resumen de tamaños
SELECT 
    TABLE_NAME,
    ROW_COUNT,
    ROUND(BYTES / (1024*1024), 2) AS SIZE_MB
FROM INFORMATION_SCHEMA.TABLE_STORAGE_METRICS
WHERE TABLE_CATALOG = 'OXXO_DEMO_DB'
  AND TABLE_SCHEMA = 'RETAIL'
ORDER BY BYTES DESC;

-- ============================================================================
-- 9. MENSAJE FINAL
-- ============================================================================

SELECT 
    '🎉 VERIFICACIÓN COMPLETA' AS STATUS,
    '✅ El demo está listo para ejecutarse' AS MENSAJE,
    'Ahora puedes proceder con oxxo_ml_pipeline.py' AS SIGUIENTE_PASO;

-- ============================================================================
-- NOTAS ADICIONALES
-- ============================================================================

/*
📋 CHECKLIST POST-VERIFICACIÓN:

✅ Todos los objetos existen (warehouse, database, schema, tablas, vistas)
✅ 50,000 registros en VENTAS_HISTORICAS
✅ Clases desbalanceadas: ~90% sin quiebre, ~10% con quiebre
✅ Datos faltantes: ~15% temperatura, ~10% promoción, ~5% inventario
✅ Features preparadas correctamente
✅ Train/Test split apropiado (~80/20)
✅ Vista enriquecida funcional

🚀 PRÓXIMOS PASOS:
1. Ejecutar oxxo_ml_pipeline.py en Snowflake Notebook o localmente
2. Verificar que los modelos entrenen correctamente
3. Revisar métricas de performance (ROC-AUC, MAE, etc.)
4. (Opcional) Desplegar Streamlit app
5. Presentar demo en evento

💡 TIPS PARA LA PRESENTACIÓN:
- Destaca el desbalanceo de clases y cómo SMOTE lo resuelve
- Enfatiza que NO se mueven datos (todo en Snowflake)
- Muestra el valor de negocio ($1M+ USD/año)
- Compara costos: $3 USD/mes vs $1000+ en arquitectura tradicional
- Menciona escalabilidad: de 500 a 21,000 tiendas sin cambios de código

⚠️ TROUBLESHOOTING:
- Si hay errores de permisos: Verificar grants del ROLE
- Si falta alguna tabla: Re-ejecutar sección correspondiente de OXXO_ML_DEMO.sql
- Si los porcentajes de nulos no coinciden: Revisar RANDOM seed en el INSERT

📞 SOPORTE:
- Documentación Snowpark: https://docs.snowflake.com/en/developer-guide/snowpark
- Snowflake Community: https://community.snowflake.com
*/

