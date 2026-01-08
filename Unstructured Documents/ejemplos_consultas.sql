-- ============================================================================
-- EJEMPLOS DE CONSULTAS - Constancias de Situación Fiscal
-- Cliente: Unstructured Docs
-- Propósito: Consultas rápidas para explorar el dataset
-- ============================================================================

-- NOTA: Ejecutar primero setup_cortex_search.sql para crear las tablas

USE WAREHOUSE UNSTRUCTURED_DOCS_WH;
USE SCHEMA UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT;

-- ============================================================================
-- 1. CONSULTAS BÁSICAS
-- ============================================================================

-- 1.1: Ver todas las constancias
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    TIPO_PERSONA,
    ESTADO
FROM CONSTANCIAS_FISCALES
ORDER BY NOMBRE_CONTRIBUYENTE;

-- 1.2: Buscar por RFC específico
SELECT * 
FROM CONSTANCIAS_FISCALES 
WHERE RFC = 'TAS180523KL8';

-- 1.3: Buscar por nombre (case insensitive)
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    ESTADO,
    REGIMEN_FISCAL
FROM CONSTANCIAS_FISCALES 
WHERE NOMBRE_CONTRIBUYENTE ILIKE '%tecnolog%';

-- 1.4: Ver solo personas físicas
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    ESTADO,
    REGIMEN_FISCAL
FROM CONSTANCIAS_FISCALES 
WHERE TIPO_PERSONA = 'Persona Física'
ORDER BY NOMBRE_CONTRIBUYENTE;

-- 1.5: Ver solo personas morales
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    ESTADO,
    MUNICIPIO
FROM CONSTANCIAS_FISCALES 
WHERE TIPO_PERSONA = 'Persona Moral'
ORDER BY ESTADO;

-- ============================================================================
-- 2. ANÁLISIS POR GEOGRAFÍA
-- ============================================================================

-- 2.1: Distribución por estado
SELECT 
    ESTADO,
    COUNT(*) AS TOTAL_CONSTANCIAS,
    LISTAGG(RFC, ', ') WITHIN GROUP (ORDER BY RFC) AS RFCS
FROM CONSTANCIAS_FISCALES
GROUP BY ESTADO
ORDER BY TOTAL_CONSTANCIAS DESC, ESTADO;

-- 2.2: Contribuyentes en Jalisco
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    MUNICIPIO,
    TIPO_PERSONA
FROM CONSTANCIAS_FISCALES
WHERE ESTADO = 'Jalisco'
ORDER BY TIPO_PERSONA, NOMBRE_CONTRIBUYENTE;

-- 2.3: Distribución por municipio (top 5)
SELECT 
    MUNICIPIO,
    ESTADO,
    COUNT(*) AS TOTAL
FROM CONSTANCIAS_FISCALES
GROUP BY MUNICIPIO, ESTADO
ORDER BY TOTAL DESC
LIMIT 5;

-- 2.4: Estados con personas morales
SELECT DISTINCT
    ESTADO,
    COUNT(*) AS TOTAL_PM
FROM CONSTANCIAS_FISCALES
WHERE TIPO_PERSONA = 'Persona Moral'
GROUP BY ESTADO
ORDER BY TOTAL_PM DESC;

-- ============================================================================
-- 3. ANÁLISIS POR RÉGIMEN FISCAL
-- ============================================================================

-- 3.1: Distribución por régimen
SELECT 
    LEFT(REGIMEN_FISCAL, 3) AS CODIGO,
    REGIMEN_FISCAL,
    COUNT(*) AS TOTAL,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS PORCENTAJE
FROM CONSTANCIAS_FISCALES
GROUP BY LEFT(REGIMEN_FISCAL, 3), REGIMEN_FISCAL
ORDER BY TOTAL DESC;

-- 3.2: Contribuyentes en régimen 601
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    ESTADO
FROM CONSTANCIAS_FISCALES
WHERE REGIMEN_FISCAL LIKE '601%'
ORDER BY ESTADO;

-- 3.3: Contribuyentes en RESICO (626)
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    ESTADO,
    METADATA:fecha_inicio::VARCHAR AS FECHA_INICIO
FROM CONSTANCIAS_FISCALES
WHERE REGIMEN_FISCAL LIKE '626%';

-- 3.4: Actividad empresarial (612)
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    ESTADO,
    MUNICIPIO
FROM CONSTANCIAS_FISCALES
WHERE REGIMEN_FISCAL LIKE '612%';

-- ============================================================================
-- 4. ANÁLISIS POR TIPO DE CONTRIBUYENTE
-- ============================================================================

-- 4.1: Resumen por tipo
SELECT 
    TIPO_PERSONA,
    COUNT(*) AS TOTAL,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS PORCENTAJE,
    MIN(FECHA_CARGA) AS PRIMERA_CARGA,
    MAX(FECHA_CARGA) AS ULTIMA_CARGA
FROM CONSTANCIAS_FISCALES
GROUP BY TIPO_PERSONA;

-- 4.2: Personas físicas con CURP
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    METADATA:curp::VARCHAR AS CURP,
    ESTADO
FROM CONSTANCIAS_FISCALES
WHERE TIPO_PERSONA = 'Persona Física'
  AND METADATA:curp IS NOT NULL
ORDER BY NOMBRE_CONTRIBUYENTE;

-- 4.3: Comparativa PM vs PF por estado
SELECT 
    ESTADO,
    SUM(CASE WHEN TIPO_PERSONA = 'Persona Moral' THEN 1 ELSE 0 END) AS PERSONAS_MORALES,
    SUM(CASE WHEN TIPO_PERSONA = 'Persona Física' THEN 1 ELSE 0 END) AS PERSONAS_FISICAS,
    COUNT(*) AS TOTAL
FROM CONSTANCIAS_FISCALES
GROUP BY ESTADO
ORDER BY TOTAL DESC;

-- ============================================================================
-- 5. BÚSQUEDAS AVANZADAS CON METADATA
-- ============================================================================

-- 5.1: Contribuyentes con más de 10 años operando
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    METADATA:fecha_inicio::VARCHAR AS FECHA_INICIO,
    DATEDIFF(YEAR, METADATA:fecha_inicio::DATE, CURRENT_DATE()) AS AÑOS_OPERANDO,
    ESTADO
FROM CONSTANCIAS_FISCALES
WHERE DATEDIFF(YEAR, METADATA:fecha_inicio::DATE, CURRENT_DATE()) >= 10
ORDER BY AÑOS_OPERANDO DESC;

-- 5.2: Contribuyentes por código postal
SELECT 
    METADATA:cp::VARCHAR AS CODIGO_POSTAL,
    COUNT(*) AS TOTAL,
    LISTAGG(NOMBRE_CONTRIBUYENTE, '; ') WITHIN GROUP (ORDER BY NOMBRE_CONTRIBUYENTE) AS CONTRIBUYENTES
FROM CONSTANCIAS_FISCALES
GROUP BY METADATA:cp::VARCHAR
ORDER BY TOTAL DESC;

-- 5.3: Búsqueda por correo electrónico (dominio)
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    METADATA
FROM CONSTANCIAS_FISCALES
WHERE METADATA LIKE '%@consultora.mx%'
   OR METADATA LIKE '%@gmail.com%';

-- ============================================================================
-- 6. ANÁLISIS CON CORTEX AI (Requiere Enterprise Edition)
-- ============================================================================

-- 6.1: Clasificar sector económico
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
        NOMBRE_CONTRIBUYENTE,
        ['Tecnología', 'Alimentos', 'Construcción', 'Logística', 
         'Inmobiliario', 'Textil', 'Agricultura', 'Servicios', 'Otro']
    ) AS SECTOR_CLASIFICADO
FROM CONSTANCIAS_FISCALES
WHERE TIPO_PERSONA = 'Persona Moral'
ORDER BY SECTOR_CLASIFICADO;

-- 6.2: Extraer ciudad del domicilio con IA
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    MUNICIPIO AS CIUDAD_REAL,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        METADATA::VARCHAR,
        'What is the city name?'
    ) AS CIUDAD_EXTRAIDA
FROM CONSTANCIAS_FISCALES
LIMIT 5;

-- 6.3: Generar resumen con IA
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-7b',
        CONCAT(
            'Resume en 20 palabras: Empresa/Persona llamada ',
            NOMBRE_CONTRIBUYENTE,
            ' ubicada en ',
            ESTADO,
            ' con régimen fiscal ',
            REGIMEN_FISCAL
        )
    ) AS RESUMEN_IA
FROM CONSTANCIAS_FISCALES
WHERE TIPO_PERSONA = 'Persona Moral'
LIMIT 3;

-- ============================================================================
-- 7. BÚSQUEDAS POR PATRÓN DE NOMBRE
-- ============================================================================

-- 7.1: Buscar empresas "SA DE CV"
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    ESTADO
FROM CONSTANCIAS_FISCALES
WHERE NOMBRE_CONTRIBUYENTE ILIKE '%SA DE CV%'
ORDER BY NOMBRE_CONTRIBUYENTE;

-- 7.2: Buscar por palabra clave en nombre
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    ESTADO,
    TIPO_PERSONA
FROM CONSTANCIAS_FISCALES
WHERE NOMBRE_CONTRIBUYENTE ILIKE '%servicios%'
   OR NOMBRE_CONTRIBUYENTE ILIKE '%comercializadora%'
   OR NOMBRE_CONTRIBUYENTE ILIKE '%desarrollos%'
ORDER BY NOMBRE_CONTRIBUYENTE;

-- 7.3: Buscar apellidos comunes (personas físicas)
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    ESTADO
FROM CONSTANCIAS_FISCALES
WHERE TIPO_PERSONA = 'Persona Física'
  AND (NOMBRE_CONTRIBUYENTE ILIKE '%GARCÍA%'
    OR NOMBRE_CONTRIBUYENTE ILIKE '%HERNÁNDEZ%'
    OR NOMBRE_CONTRIBUYENTE ILIKE '%MARTÍNEZ%'
    OR NOMBRE_CONTRIBUYENTE ILIKE '%LÓPEZ%')
ORDER BY NOMBRE_CONTRIBUYENTE;

-- ============================================================================
-- 8. REPORTES Y VISTAS AGREGADAS
-- ============================================================================

-- 8.1: Reporte ejecutivo completo
SELECT 
    'Total Constancias' AS METRICA,
    COUNT(*)::VARCHAR AS VALOR
FROM CONSTANCIAS_FISCALES
UNION ALL
SELECT 
    'Personas Morales',
    COUNT(*)::VARCHAR
FROM CONSTANCIAS_FISCALES
WHERE TIPO_PERSONA = 'Persona Moral'
UNION ALL
SELECT 
    'Personas Físicas',
    COUNT(*)::VARCHAR
FROM CONSTANCIAS_FISCALES
WHERE TIPO_PERSONA = 'Persona Física'
UNION ALL
SELECT 
    'Estados Representados',
    COUNT(DISTINCT ESTADO)::VARCHAR
FROM CONSTANCIAS_FISCALES
UNION ALL
SELECT 
    'Regímenes Distintos',
    COUNT(DISTINCT LEFT(REGIMEN_FISCAL, 3))::VARCHAR
FROM CONSTANCIAS_FISCALES;

-- 8.2: Vista resumen por estado y régimen
SELECT 
    ESTADO,
    LEFT(REGIMEN_FISCAL, 3) AS CODIGO_REGIMEN,
    COUNT(*) AS TOTAL,
    LISTAGG(RFC, ', ') WITHIN GROUP (ORDER BY RFC) AS RFCS
FROM CONSTANCIAS_FISCALES
GROUP BY ESTADO, LEFT(REGIMEN_FISCAL, 3)
ORDER BY ESTADO, CODIGO_REGIMEN;

-- 8.3: Matriz tipo de persona x régimen
SELECT 
    TIPO_PERSONA,
    SUM(CASE WHEN REGIMEN_FISCAL LIKE '601%' THEN 1 ELSE 0 END) AS REG_601,
    SUM(CASE WHEN REGIMEN_FISCAL LIKE '605%' THEN 1 ELSE 0 END) AS REG_605,
    SUM(CASE WHEN REGIMEN_FISCAL LIKE '612%' THEN 1 ELSE 0 END) AS REG_612,
    SUM(CASE WHEN REGIMEN_FISCAL LIKE '621%' THEN 1 ELSE 0 END) AS REG_621,
    SUM(CASE WHEN REGIMEN_FISCAL LIKE '626%' THEN 1 ELSE 0 END) AS REG_626,
    COUNT(*) AS TOTAL
FROM CONSTANCIAS_FISCALES
GROUP BY TIPO_PERSONA;

-- ============================================================================
-- 9. VALIDACIÓN DE DATOS
-- ============================================================================

-- 9.1: Verificar RFCs únicos
SELECT 
    RFC,
    COUNT(*) AS VECES
FROM CONSTANCIAS_FISCALES
GROUP BY RFC
HAVING COUNT(*) > 1;

-- 9.2: Verificar integridad de campos
SELECT 
    'RFCs completos' AS VALIDACION,
    COUNT(*) AS TOTAL,
    SUM(CASE WHEN RFC IS NULL OR LENGTH(RFC) < 12 THEN 1 ELSE 0 END) AS ERRORES
FROM CONSTANCIAS_FISCALES
UNION ALL
SELECT 
    'Nombres completos',
    COUNT(*),
    SUM(CASE WHEN NOMBRE_CONTRIBUYENTE IS NULL OR NOMBRE_CONTRIBUYENTE = '' THEN 1 ELSE 0 END)
FROM CONSTANCIAS_FISCALES
UNION ALL
SELECT 
    'Estados válidos',
    COUNT(*),
    SUM(CASE WHEN ESTADO IS NULL THEN 1 ELSE 0 END)
FROM CONSTANCIAS_FISCALES;

-- 9.3: Verificar formato de RFC
SELECT 
    RFC,
    NOMBRE_CONTRIBUYENTE,
    LENGTH(RFC) AS LONG_RFC,
    CASE 
        WHEN LENGTH(RFC) = 12 THEN 'Persona Moral'
        WHEN LENGTH(RFC) = 13 THEN 'Persona Física'
        ELSE 'Formato incorrecto'
    END AS TIPO_RFC_VALIDADO,
    TIPO_PERSONA AS TIPO_REGISTRADO
FROM CONSTANCIAS_FISCALES
ORDER BY RFC;

-- ============================================================================
-- 10. QUERIES PARA DEMO / PRESENTACIÓN
-- ============================================================================

-- 10.1: Top 5 estados con más constancias
SELECT 
    ESTADO,
    COUNT(*) AS TOTAL,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM CONSTANCIAS_FISCALES), 2) AS PORCENTAJE
FROM CONSTANCIAS_FISCALES
GROUP BY ESTADO
ORDER BY TOTAL DESC
LIMIT 5;

-- 10.2: Empresas más antiguas
SELECT 
    NOMBRE_CONTRIBUYENTE,
    RFC,
    METADATA:fecha_inicio::VARCHAR AS FECHA_INICIO,
    DATEDIFF(YEAR, METADATA:fecha_inicio::DATE, CURRENT_DATE()) AS AÑOS,
    ESTADO
FROM CONSTANCIAS_FISCALES
WHERE TIPO_PERSONA = 'Persona Moral'
ORDER BY METADATA:fecha_inicio::DATE
LIMIT 5;

-- 10.3: Diversidad geográfica
SELECT 
    COUNT(DISTINCT ESTADO) AS ESTADOS_DISTINTOS,
    COUNT(DISTINCT MUNICIPIO) AS MUNICIPIOS_DISTINTOS,
    COUNT(*) AS TOTAL_CONSTANCIAS,
    ROUND(COUNT(DISTINCT ESTADO) * 100.0 / 32, 2) AS COBERTURA_NACIONAL_PCT
FROM CONSTANCIAS_FISCALES;

-- ============================================================================
-- NOTAS FINALES
-- ============================================================================

-- Estas consultas están diseñadas para:
-- 1. Explorar el dataset de forma interactiva
-- 2. Validar la calidad de los datos
-- 3. Preparar demos y presentaciones
-- 4. Probar capacidades de Cortex AI
-- 5. Generar reportes ejecutivos

-- Para más información:
-- - README.md: Documentación completa
-- - GUIA_RAPIDA.md: Inicio rápido
-- - setup_cortex_search.sql: Configuración completa

-- ============================================================================



