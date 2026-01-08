/*
================================================================================
  SCRIPT DE VALIDACIÓN RÁPIDA - GLOBENERGY DEMO
================================================================================
  
  Ejecuta este script DESPUÉS de ejecutar GLOBENERGY_Demo_Completo.sql
  para verificar que todo se haya creado correctamente.
  
  Tiempo estimado: 10-15 segundos
================================================================================
*/

-- Configurar contexto
USE ROLE SYSADMIN;
USE WAREHOUSE GLOBENERGY_WH;
USE SCHEMA GLOBENERGY_DB.ENERGIA;

-- ============================================================================
-- VALIDACIÓN 1: Verificar que todos los recursos existen
-- ============================================================================

SHOW WAREHOUSES LIKE 'GLOBENERGY_WH';
SHOW DATABASES LIKE 'GLOBENERGY_DB';
SHOW SCHEMAS LIKE 'ENERGIA' IN DATABASE GLOBENERGY_DB;
SHOW TABLES IN SCHEMA GLOBENERGY_DB.ENERGIA;
SHOW ROLES LIKE 'GLOBENERGY_ANALISTA';

-- ============================================================================
-- VALIDACIÓN 2: Conteo de registros en todas las tablas
-- ============================================================================

SELECT 
    '✅ RESUMEN DE DATOS' AS STATUS,
    '==================' AS SEPARADOR;

SELECT 'CLIENTES' AS TABLA, COUNT(*) AS TOTAL_REGISTROS, 
       CASE WHEN COUNT(*) = 100 THEN '✅ OK' ELSE '❌ ERROR' END AS STATUS
FROM GLOBENERGY_DB.ENERGIA.CLIENTES
UNION ALL
SELECT 'TIPOS_ENERGIA', COUNT(*), 
       CASE WHEN COUNT(*) = 8 THEN '✅ OK' ELSE '❌ ERROR' END
FROM GLOBENERGY_DB.ENERGIA.TIPOS_ENERGIA
UNION ALL
SELECT 'CONTRATOS', COUNT(*), 
       CASE WHEN COUNT(*) = 200 THEN '✅ OK' ELSE '❌ ERROR' END
FROM GLOBENERGY_DB.ENERGIA.CONTRATOS
UNION ALL
SELECT 'CONSUMO ⭐', COUNT(*), 
       CASE WHEN COUNT(*) = 2000 THEN '✅ OK' ELSE '❌ ERROR' END
FROM GLOBENERGY_DB.ENERGIA.CONSUMO
UNION ALL
SELECT 'EVENTOS_CLIMATICOS', COUNT(*), 
       CASE WHEN COUNT(*) = 50 THEN '✅ OK' ELSE '❌ ERROR' END
FROM GLOBENERGY_DB.ENERGIA.EVENTOS_CLIMATICOS
UNION ALL
SELECT 'PREDICCIONES_DEMANDA', COUNT(*), 
       CASE WHEN COUNT(*) = 300 THEN '✅ OK' ELSE '❌ ERROR' END
FROM GLOBENERGY_DB.ENERGIA.PREDICCIONES_DEMANDA
ORDER BY TABLA;

-- ============================================================================
-- VALIDACIÓN 3: Verificar integridad de datos (sin nulls en campos clave)
-- ============================================================================

SELECT 
    '✅ INTEGRIDAD DE DATOS' AS STATUS,
    '======================' AS SEPARADOR;

SELECT
    'CONSUMO.COSTO_TOTAL' AS CAMPO,
    COUNT(*) AS TOTAL_REGISTROS,
    SUM(CASE WHEN COSTO_TOTAL IS NULL OR COSTO_TOTAL <= 0 THEN 1 ELSE 0 END) AS REGISTROS_INVALIDOS,
    CASE 
        WHEN SUM(CASE WHEN COSTO_TOTAL IS NULL OR COSTO_TOTAL <= 0 THEN 1 ELSE 0 END) = 0 
        THEN '✅ OK' 
        ELSE '❌ ERROR' 
    END AS STATUS
FROM GLOBENERGY_DB.ENERGIA.CONSUMO
UNION ALL
SELECT
    'CONSUMO.EMISION_CO2_KG',
    COUNT(*),
    SUM(CASE WHEN EMISION_CO2_KG IS NULL THEN 1 ELSE 0 END),
    CASE 
        WHEN SUM(CASE WHEN EMISION_CO2_KG IS NULL THEN 1 ELSE 0 END) = 0 
        THEN '✅ OK' 
        ELSE '❌ ERROR' 
    END
FROM GLOBENERGY_DB.ENERGIA.CONSUMO
UNION ALL
SELECT
    'CLIENTES.ESTADO',
    COUNT(*),
    SUM(CASE WHEN ESTADO IS NULL THEN 1 ELSE 0 END),
    CASE 
        WHEN SUM(CASE WHEN ESTADO IS NULL THEN 1 ELSE 0 END) = 0 
        THEN '✅ OK' 
        ELSE '❌ ERROR' 
    END
FROM GLOBENERGY_DB.ENERGIA.CLIENTES;

-- ============================================================================
-- VALIDACIÓN 4: Verificar relaciones entre tablas (Foreign Keys)
-- ============================================================================

SELECT 
    '✅ INTEGRIDAD REFERENCIAL' AS STATUS,
    '==========================' AS SEPARADOR;

SELECT
    'CONSUMO -> CONTRATOS' AS RELACION,
    COUNT(*) AS REGISTROS_HUERFANOS,
    CASE WHEN COUNT(*) = 0 THEN '✅ OK' ELSE '❌ ERROR' END AS STATUS
FROM GLOBENERGY_DB.ENERGIA.CONSUMO c
LEFT JOIN GLOBENERGY_DB.ENERGIA.CONTRATOS co ON c.CONTRATO_ID = co.CONTRATO_ID
WHERE co.CONTRATO_ID IS NULL
UNION ALL
SELECT
    'CONSUMO -> CLIENTES',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ OK' ELSE '❌ ERROR' END
FROM GLOBENERGY_DB.ENERGIA.CONSUMO c
LEFT JOIN GLOBENERGY_DB.ENERGIA.CLIENTES cl ON c.CLIENTE_ID = cl.CLIENTE_ID
WHERE cl.CLIENTE_ID IS NULL
UNION ALL
SELECT
    'CONTRATOS -> CLIENTES',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅ OK' ELSE '❌ ERROR' END
FROM GLOBENERGY_DB.ENERGIA.CONTRATOS co
LEFT JOIN GLOBENERGY_DB.ENERGIA.CLIENTES cl ON co.CLIENTE_ID = cl.CLIENTE_ID
WHERE cl.CLIENTE_ID IS NULL;

-- ============================================================================
-- VALIDACIÓN 5: KPIs Principales (Quick Sanity Check)
-- ============================================================================

SELECT 
    '✅ KPIs PRINCIPALES' AS STATUS,
    '===================' AS SEPARADOR;

SELECT
    'Total Clientes Activos' AS KPI,
    COUNT(*)::VARCHAR AS VALOR,
    '✅' AS STATUS
FROM GLOBENERGY_DB.ENERGIA.CLIENTES
WHERE ESTADO = 'Activo'
UNION ALL
SELECT
    'Total Contratos Activos',
    COUNT(*)::VARCHAR,
    '✅'
FROM GLOBENERGY_DB.ENERGIA.CONTRATOS
WHERE ESTADO_CONTRATO = 'Activo'
UNION ALL
SELECT
    'Costo Total Facturado (USD)',
    TO_VARCHAR(ROUND(SUM(COSTO_TOTAL), 2)),
    CASE WHEN SUM(COSTO_TOTAL) > 0 THEN '✅' ELSE '❌' END
FROM GLOBENERGY_DB.ENERGIA.CONSUMO
UNION ALL
SELECT
    'Emisiones CO2 (Toneladas)',
    TO_VARCHAR(ROUND(SUM(EMISION_CO2_KG) / 1000, 2)),
    CASE WHEN SUM(EMISION_CO2_KG) > 0 THEN '✅' ELSE '❌' END
FROM GLOBENERGY_DB.ENERGIA.CONSUMO
UNION ALL
SELECT
    'Eficiencia Promedio (%)',
    TO_VARCHAR(ROUND(AVG(EFICIENCIA_ENERGETICA), 2)),
    CASE WHEN AVG(EFICIENCIA_ENERGETICA) BETWEEN 65 AND 98 THEN '✅' ELSE '❌' END
FROM GLOBENERGY_DB.ENERGIA.CONSUMO;

-- ============================================================================
-- VALIDACIÓN 6: Distribución de datos por sector
-- ============================================================================

SELECT 
    '✅ DISTRIBUCIÓN POR SECTOR' AS STATUS,
    '===========================' AS SEPARADOR;

SELECT
    SECTOR,
    COUNT(*) AS TOTAL_CLIENTES,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS PORCENTAJE,
    '✅' AS STATUS
FROM GLOBENERGY_DB.ENERGIA.CLIENTES
GROUP BY SECTOR
ORDER BY TOTAL_CLIENTES DESC;

-- ============================================================================
-- VALIDACIÓN 7: Tipos de energía disponibles
-- ============================================================================

SELECT 
    '✅ TIPOS DE ENERGÍA' AS STATUS,
    '====================' AS SEPARADOR;

SELECT
    NOMBRE_TIPO,
    CATEGORIA,
    UNIDAD_MEDIDA,
    PRECIO_BASE_UNITARIO,
    CASE WHEN FACTOR_EMISION_CO2 = 0 THEN '🌱 Renovable' ELSE '⚡ Fósil/Híbrida' END AS TIPO,
    '✅' AS STATUS
FROM GLOBENERGY_DB.ENERGIA.TIPOS_ENERGIA
ORDER BY CATEGORIA, NOMBRE_TIPO;

-- ============================================================================
-- ✅ RESULTADO ESPERADO
-- ============================================================================

SELECT 
    '🎉 VALIDACIÓN COMPLETA' AS MENSAJE,
    CASE 
        WHEN (SELECT COUNT(*) FROM GLOBENERGY_DB.ENERGIA.CONSUMO) = 2000
        THEN '✅ La demo de GLOBENERGY está lista para usar'
        ELSE '❌ Hay problemas - revisar resultados anteriores'
    END AS STATUS;

/*
================================================================================
  📊 INTERPRETACIÓN DE RESULTADOS
================================================================================

  ✅ OK    = Todo funciona correctamente
  ❌ ERROR = Hay un problema que debe revisarse

  Si TODOS los checks muestran ✅, la demo está lista para:
  - Ejecutar las 15 consultas de demostración (Sección 3 del script principal)
  - Importar el modelo semántico YAML
  - Crear dashboards y visualizaciones
  - Presentar a clientes o stakeholders

  Si hay ❌, revisar:
  1. ¿Se ejecutó completamente GLOBENERGY_Demo_Completo.sql?
  2. ¿Hubo errores durante la inserción de datos?
  3. ¿Se tienen permisos adecuados en Snowflake?

================================================================================
*/

