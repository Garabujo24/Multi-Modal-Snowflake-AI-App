-- ============================================================================
-- OFFICEMAX MÉXICO - CONFIGURACIÓN DE CORTEX ANALYST Y CORTEX SEARCH
-- Setup completo de servicios Cortex para análisis inteligente
-- ============================================================================

USE DATABASE OFFICEMAX_MEXICO;
USE WAREHOUSE OFFICEMAX_CORTEX_WH;
USE SCHEMA CORTEX_SERVICES;

-- ============================================================================
-- PASO 1: CONFIGURAR CORTEX ANALYST
-- ============================================================================

-- Crear el modelo semántico para Cortex Analyst
CREATE OR REPLACE CORTEX SEARCH SERVICE OFFICEMAX_ANALYST_MODEL
WAREHOUSE = OFFICEMAX_CORTEX_WH
TARGET_LAG = '2 minutes'
SEMANTIC_MODEL = '
name: officemax_mexico_business_model
description: Modelo semántico para análisis de negocio de OfficeMax México

tables:
  - name: VENTAS_CONSOLIDADAS
    description: Vista consolidada de ventas con información enriquecida
    base_table:
      database: OFFICEMAX_MEXICO
      schema: ANALYTICS
      table: VENTAS_CONSOLIDADAS
    
    dimensions:
      - name: PRODUCTO_ID
        expr: PRODUCTO_ID
        data_type: VARCHAR
        description: Identificador único del producto
        synonyms: ["producto", "artículo", "ítem"]
      
      - name: NOMBRE_PRODUCTO
        expr: NOMBRE_PRODUCTO
        data_type: VARCHAR
        description: Nombre del producto
        synonyms: ["producto", "nombre", "artículo"]
      
      - name: MARCA
        expr: MARCA
        data_type: VARCHAR
        description: Marca del producto
        synonyms: ["marca", "fabricante"]
        sample_values: ["HP", "Dell", "Apple", "BIC", "JanSport"]
      
      - name: CATEGORIA_PADRE
        expr: CATEGORIA_PADRE
        data_type: VARCHAR
        description: Categoría principal del producto
        synonyms: ["categoría", "departamento"]
        sample_values: ["Tecnología", "Papelería", "Material Escolar", "Mobiliario de Oficina"]
      
      - name: CATEGORIA_HIJO
        expr: CATEGORIA_HIJO
        data_type: VARCHAR
        description: Subcategoría específica
        synonyms: ["subcategoría", "tipo"]
      
      - name: CANAL_VENTA
        expr: CANAL_VENTA
        data_type: VARCHAR
        description: Canal de venta utilizado
        synonyms: ["canal", "medio"]
        sample_values: ["TIENDA", "ONLINE", "APP_MOVIL", "TELEFONO"]
      
      - name: TIPO_CLIENTE
        expr: TIPO_CLIENTE
        data_type: VARCHAR
        description: Tipo de cliente
        synonyms: ["tipo cliente", "segmento"]
        sample_values: ["INDIVIDUAL", "EMPRESARIAL", "EDUCATIVO", "GOBIERNO"]
      
      - name: SUCURSAL_ESTADO
        expr: SUCURSAL_ESTADO
        data_type: VARCHAR
        description: Estado donde se realizó la venta
        synonyms: ["estado", "región"]
      
      - name: NOMBRE_SUCURSAL
        expr: NOMBRE_SUCURSAL
        data_type: VARCHAR
        description: Nombre de la sucursal
        synonyms: ["sucursal", "tienda"]
      
      - name: METODO_PAGO
        expr: METODO_PAGO
        data_type: VARCHAR
        description: Método de pago utilizado
        synonyms: ["pago", "forma de pago"]
    
    time_dimensions:
      - name: FECHA_VENTA
        expr: FECHA_VENTA
        data_type: TIMESTAMP
        description: Fecha y hora de la venta
        synonyms: ["fecha", "cuando"]
      
      - name: MES_ANO
        expr: MES_ANO
        data_type: VARCHAR
        description: Mes y año de la venta
        synonyms: ["mes", "período"]
    
    facts:
      - name: CANTIDAD
        expr: CANTIDAD
        data_type: NUMBER
        description: Unidades vendidas
        synonyms: ["cantidad", "unidades", "piezas"]
      
      - name: TOTAL_LINEA
        expr: TOTAL_LINEA
        data_type: NUMBER
        description: Total de la venta
        synonyms: ["total", "ingresos", "venta", "importe"]
      
      - name: MARGEN_BRUTO
        expr: MARGEN_BRUTO
        data_type: NUMBER
        description: Margen bruto de la venta
        synonyms: ["margen", "utilidad", "ganancia"]
      
      - name: DESCUENTO_TOTAL
        expr: DESCUENTO_TOTAL
        data_type: NUMBER
        description: Descuento aplicado
        synonyms: ["descuento", "rebaja"]

relationships: []

verified_queries:
  - name: ventas_por_categoria
    question: ¿Cuáles son las ventas por categoría?
    sql: |
      SELECT 
        CATEGORIA_PADRE,
        COUNT(*) as TRANSACCIONES,
        SUM(CANTIDAD) as UNIDADES,
        SUM(TOTAL_LINEA) as INGRESOS
      FROM VENTAS_CONSOLIDADAS
      GROUP BY CATEGORIA_PADRE
      ORDER BY INGRESOS DESC
'
COMMENT = 'Modelo semántico de OfficeMax México para Cortex Analyst';

-- ============================================================================
-- PASO 2: CONFIGURAR CORTEX SEARCH PARA DOCUMENTOS
-- ============================================================================

-- Crear servicio de Cortex Search para documentos
CREATE OR REPLACE CORTEX SEARCH SERVICE OFFICEMAX_DOCUMENTS_SEARCH
ON DOCUMENTO_ID
WAREHOUSE = OFFICEMAX_CORTEX_WH
TARGET_LAG = '5 minutes'
AS (
  SELECT 
    DOCUMENTO_ID,
    TITULO || ' ' || CONTENIDO as SEARCH_CONTENT,
    TIPO_DOCUMENTO,
    CATEGORIA,
    AUTOR,
    DEPARTAMENTO,
    TAGS,
    METADATA,
    FECHA_CREACION,
    ACTIVO
  FROM RAW_DATA.DOCUMENTOS
  WHERE ACTIVO = TRUE AND INDICE_BUSQUEDA = TRUE
)
COMMENT = 'Servicio de búsqueda semántica para documentos OfficeMax';

-- ============================================================================
-- PASO 3: CREAR FUNCIONES WRAPPER PARA CORTEX SERVICES
-- ============================================================================

-- Función para consultas a Cortex Analyst
CREATE OR REPLACE FUNCTION CORTEX_SERVICES.QUERY_ANALYST(QUESTION STRING)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
  SELECT SNOWFLAKE.CORTEX.ANALYST(
    'OFFICEMAX_ANALYST_MODEL',
    QUESTION
  )
$$;

-- Función para búsquedas en documentos
CREATE OR REPLACE FUNCTION CORTEX_SERVICES.SEARCH_DOCUMENTS(
  SEARCH_QUERY STRING,
  FILTERS VARIANT DEFAULT NULL,
  LIMIT_RESULTS INTEGER DEFAULT 10
)
RETURNS TABLE(
  DOCUMENTO_ID VARCHAR,
  TITULO VARCHAR,
  TIPO_DOCUMENTO VARCHAR,
  CATEGORIA VARCHAR,
  RELEVANCE_SCORE FLOAT,
  CONTENIDO VARCHAR,
  AUTOR VARCHAR,
  DEPARTAMENTO VARCHAR,
  FECHA_CREACION TIMESTAMP
)
LANGUAGE SQL
AS
$$
  SELECT 
    d.DOCUMENTO_ID,
    d.TITULO,
    d.TIPO_DOCUMENTO,
    d.CATEGORIA,
    cs.SCORE as RELEVANCE_SCORE,
    SUBSTR(d.CONTENIDO, 1, 500) as CONTENIDO,
    d.AUTOR,
    d.DEPARTAMENTO,
    d.FECHA_CREACION
  FROM TABLE(
    CORTEX_SEARCH(
      'OFFICEMAX_DOCUMENTS_SEARCH',
      SEARCH_QUERY,
      COALESCE(FILTERS, OBJECT_CONSTRUCT())
    )
  ) cs
  JOIN RAW_DATA.DOCUMENTOS d ON cs.DOCUMENTO_ID = d.DOCUMENTO_ID
  ORDER BY cs.SCORE DESC
  LIMIT LIMIT_RESULTS
$$;

-- ============================================================================
-- PASO 4: CREAR VISTAS PARA ANÁLISIS COMÚN
-- ============================================================================

-- Vista para análisis de tendencias de ventas
CREATE OR REPLACE VIEW ANALYTICS.TENDENCIAS_VENTAS AS
SELECT 
    DATE_TRUNC('month', FECHA_VENTA) as MES,
    CATEGORIA_PADRE,
    CANAL_VENTA,
    COUNT(*) as TRANSACCIONES,
    SUM(CANTIDAD) as UNIDADES_VENDIDAS,
    SUM(TOTAL_LINEA) as INGRESOS_TOTALES,
    SUM(MARGEN_BRUTO) as MARGEN_TOTAL,
    AVG(TOTAL_LINEA) as TICKET_PROMEDIO
FROM ANALYTICS.VENTAS_CONSOLIDADAS
WHERE FECHA_VENTA >= DATEADD('month', -12, CURRENT_DATE())
GROUP BY 
    DATE_TRUNC('month', FECHA_VENTA),
    CATEGORIA_PADRE,
    CANAL_VENTA
ORDER BY MES DESC, INGRESOS_TOTALES DESC;

-- Vista para análisis de performance por sucursal
CREATE OR REPLACE VIEW ANALYTICS.PERFORMANCE_SUCURSALES AS
SELECT 
    SUCURSAL_ID,
    NOMBRE_SUCURSAL,
    SUCURSAL_ESTADO,
    FORMATO_TIENDA,
    DATE_TRUNC('month', FECHA_VENTA) as MES,
    COUNT(*) as TRANSACCIONES,
    COUNT(DISTINCT CLIENTE_ID) as CLIENTES_UNICOS,
    SUM(CANTIDAD) as UNIDADES_VENDIDAS,
    SUM(TOTAL_LINEA) as INGRESOS_TOTALES,
    SUM(MARGEN_BRUTO) as MARGEN_TOTAL,
    AVG(TOTAL_LINEA) as TICKET_PROMEDIO,
    -- Métricas por canal
    SUM(CASE WHEN CANAL_VENTA = 'TIENDA' THEN TOTAL_LINEA ELSE 0 END) as INGRESOS_TIENDA,
    SUM(CASE WHEN CANAL_VENTA = 'ONLINE' THEN TOTAL_LINEA ELSE 0 END) as INGRESOS_ONLINE,
    -- Métrica de eficiencia
    ROUND(SUM(TOTAL_LINEA) / COUNT(*), 2) as EFICIENCIA_TRANSACCIONAL
FROM ANALYTICS.VENTAS_CONSOLIDADAS v
GROUP BY 
    SUCURSAL_ID, NOMBRE_SUCURSAL, SUCURSAL_ESTADO, FORMATO_TIENDA,
    DATE_TRUNC('month', FECHA_VENTA)
ORDER BY MES DESC, INGRESOS_TOTALES DESC;

-- Vista para análisis de productos
CREATE OR REPLACE VIEW ANALYTICS.ANALISIS_PRODUCTOS_DETALLADO AS
SELECT 
    p.PRODUCTO_ID,
    p.NOMBRE_PRODUCTO,
    p.MARCA,
    p.SKU,
    c.CATEGORIA_PADRE,
    c.CATEGORIA_HIJO,
    p.PRECIO_REGULAR,
    p.COSTO_UNITARIO,
    ROUND((p.PRECIO_REGULAR - p.COSTO_UNITARIO) / p.PRECIO_REGULAR * 100, 2) as MARGEN_TEORICO_PCT,
    
    -- Métricas de venta (últimos 90 días)
    COUNT(v.VENTA_ID) as TRANSACCIONES_90D,
    COALESCE(SUM(v.CANTIDAD), 0) as UNIDADES_VENDIDAS_90D,
    COALESCE(SUM(v.TOTAL_LINEA), 0) as INGRESOS_90D,
    COALESCE(AVG(v.PRECIO_UNITARIO), 0) as PRECIO_PROMEDIO_VENTA_90D,
    COALESCE(SUM(v.MARGEN_BRUTO), 0) as MARGEN_REAL_90D,
    
    -- Análisis de canales
    COUNT(CASE WHEN v.CANAL_VENTA = 'TIENDA' THEN 1 END) as VENTAS_TIENDA_90D,
    COUNT(CASE WHEN v.CANAL_VENTA = 'ONLINE' THEN 1 END) as VENTAS_ONLINE_90D,
    COUNT(CASE WHEN v.CANAL_VENTA = 'APP_MOVIL' THEN 1 END) as VENTAS_APP_90D,
    
    -- Inventario total
    COALESCE(SUM(i.STOCK_ACTUAL), 0) as STOCK_TOTAL_SUCURSALES,
    COALESCE(AVG(i.ROTACION_DIAS), 0) as ROTACION_PROMEDIO_DIAS,
    
    -- Clasificación de performance
    CASE 
        WHEN COALESCE(SUM(v.TOTAL_LINEA), 0) > 100000 THEN 'TOP'
        WHEN COALESCE(SUM(v.TOTAL_LINEA), 0) > 50000 THEN 'ALTO'
        WHEN COALESCE(SUM(v.TOTAL_LINEA), 0) > 10000 THEN 'MEDIO'
        WHEN COALESCE(SUM(v.TOTAL_LINEA), 0) > 1000 THEN 'BAJO'
        ELSE 'MINIMO'
    END as PERFORMANCE_CLASIFICACION

FROM RAW_DATA.PRODUCTOS p
LEFT JOIN RAW_DATA.CATEGORIAS c ON p.CATEGORIA_ID = c.CATEGORIA_ID
LEFT JOIN RAW_DATA.VENTAS v ON p.PRODUCTO_ID = v.PRODUCTO_ID 
    AND v.FECHA_VENTA >= DATEADD('day', -90, CURRENT_DATE())
LEFT JOIN RAW_DATA.INVENTARIO i ON p.PRODUCTO_ID = i.PRODUCTO_ID
WHERE p.ACTIVO = TRUE
GROUP BY 
    p.PRODUCTO_ID, p.NOMBRE_PRODUCTO, p.MARCA, p.SKU,
    c.CATEGORIA_PADRE, c.CATEGORIA_HIJO, p.PRECIO_REGULAR, p.COSTO_UNITARIO
ORDER BY INGRESOS_90D DESC NULLS LAST;

-- ============================================================================
-- PASO 5: CREAR STORED PROCEDURES PARA OPERACIONES COMUNES
-- ============================================================================

-- Procedimiento para análisis de temporada
CREATE OR REPLACE PROCEDURE CORTEX_SERVICES.ANALIZAR_TEMPORADA(
    FECHA_INICIO DATE,
    FECHA_FIN DATE,
    CATEGORIA_FILTRO VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    CATEGORIA VARCHAR,
    MARCA VARCHAR,
    PRODUCTO VARCHAR,
    UNIDADES_VENDIDAS NUMBER,
    INGRESOS_TOTALES NUMBER,
    MARGEN_BRUTO NUMBER,
    PARTICIPACION_CATEGORIA FLOAT
)
LANGUAGE SQL
AS
$$
DECLARE
    categoria_condition STRING DEFAULT '';
BEGIN
    IF (CATEGORIA_FILTRO IS NOT NULL) THEN
        categoria_condition := ' AND CATEGORIA_PADRE = ''' || CATEGORIA_FILTRO || '''';
    END IF;
    
    LET query STRING := '
    WITH ventas_temporada AS (
        SELECT 
            CATEGORIA_PADRE as CATEGORIA,
            MARCA,
            NOMBRE_PRODUCTO as PRODUCTO,
            SUM(CANTIDAD) as UNIDADES_VENDIDAS,
            SUM(TOTAL_LINEA) as INGRESOS_TOTALES,
            SUM(MARGEN_BRUTO) as MARGEN_BRUTO
        FROM ANALYTICS.VENTAS_CONSOLIDADAS
        WHERE FECHA_VENTA BETWEEN ''' || FECHA_INICIO || ''' AND ''' || FECHA_FIN || '''' ||
        categoria_condition || '
        GROUP BY CATEGORIA_PADRE, MARCA, NOMBRE_PRODUCTO
    ),
    totales_categoria AS (
        SELECT 
            CATEGORIA,
            SUM(INGRESOS_TOTALES) as TOTAL_CATEGORIA
        FROM ventas_temporada
        GROUP BY CATEGORIA
    )
    SELECT 
        vt.CATEGORIA,
        vt.MARCA,
        vt.PRODUCTO,
        vt.UNIDADES_VENDIDAS,
        vt.INGRESOS_TOTALES,
        vt.MARGEN_BRUTO,
        ROUND((vt.INGRESOS_TOTALES / tc.TOTAL_CATEGORIA) * 100, 2) as PARTICIPACION_CATEGORIA
    FROM ventas_temporada vt
    JOIN totales_categoria tc ON vt.CATEGORIA = tc.CATEGORIA
    ORDER BY vt.CATEGORIA, vt.INGRESOS_TOTALES DESC';
    
    RETURN TABLE(RESULTSET(EXECUTE IMMEDIATE :query));
END;
$$;

-- Procedimiento para análisis de clientes
CREATE OR REPLACE PROCEDURE CORTEX_SERVICES.ANALIZAR_CLIENTES_TOP(
    LIMITE INTEGER DEFAULT 50,
    TIPO_CLIENTE_FILTRO VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    CLIENTE_ID VARCHAR,
    CLIENTE_NOMBRE VARCHAR,
    TIPO_CLIENTE VARCHAR,
    ESTADO VARCHAR,
    TRANSACCIONES NUMBER,
    TOTAL_COMPRAS NUMBER,
    TICKET_PROMEDIO NUMBER,
    ULTIMA_COMPRA DATE,
    FRECUENCIA_DIAS NUMBER
)
LANGUAGE SQL
AS
$$
DECLARE
    tipo_condition STRING DEFAULT '';
BEGIN
    IF (TIPO_CLIENTE_FILTRO IS NOT NULL) THEN
        tipo_condition := ' AND v.TIPO_CLIENTE = ''' || TIPO_CLIENTE_FILTRO || '''';
    END IF;
    
    LET query STRING := '
    SELECT 
        c.CLIENTE_ID,
        c.NOMBRE_COMPLETO as CLIENTE_NOMBRE,
        c.TIPO_CLIENTE,
        c.ESTADO,
        COUNT(v.VENTA_ID) as TRANSACCIONES,
        SUM(v.TOTAL_LINEA) as TOTAL_COMPRAS,
        ROUND(AVG(v.TOTAL_LINEA), 2) as TICKET_PROMEDIO,
        MAX(v.FECHA_SOLO) as ULTIMA_COMPRA,
        ROUND(DATEDIFF(day, MIN(v.FECHA_SOLO), MAX(v.FECHA_SOLO)) / 
              GREATEST(COUNT(DISTINCT v.FECHA_SOLO) - 1, 1), 1) as FRECUENCIA_DIAS
    FROM RAW_DATA.CLIENTES c
    JOIN RAW_DATA.VENTAS v ON c.CLIENTE_ID = v.CLIENTE_ID
    WHERE c.ACTIVO = TRUE 
    AND v.FECHA_VENTA >= DATEADD(month, -12, CURRENT_DATE())' ||
    tipo_condition || '
    GROUP BY c.CLIENTE_ID, c.NOMBRE_COMPLETO, c.TIPO_CLIENTE, c.ESTADO
    ORDER BY TOTAL_COMPRAS DESC
    LIMIT ' || LIMITE;
    
    RETURN TABLE(RESULTSET(EXECUTE IMMEDIATE :query));
END;
$$;

-- ============================================================================
-- PASO 6: CONFIGURAR PERMISOS Y ROLES
-- ============================================================================

-- Crear rol específico para usuarios de Cortex
CREATE OR REPLACE ROLE OFFICEMAX_CORTEX_USER;

-- Otorgar permisos básicos
GRANT USAGE ON WAREHOUSE OFFICEMAX_CORTEX_WH TO ROLE OFFICEMAX_CORTEX_USER;
GRANT USAGE ON DATABASE OFFICEMAX_MEXICO TO ROLE OFFICEMAX_CORTEX_USER;
GRANT USAGE ON SCHEMA RAW_DATA TO ROLE OFFICEMAX_CORTEX_USER;
GRANT USAGE ON SCHEMA ANALYTICS TO ROLE OFFICEMAX_CORTEX_USER;
GRANT USAGE ON SCHEMA CORTEX_SERVICES TO ROLE OFFICEMAX_CORTEX_USER;

-- Permisos de lectura en datos
GRANT SELECT ON ALL TABLES IN SCHEMA RAW_DATA TO ROLE OFFICEMAX_CORTEX_USER;
GRANT SELECT ON ALL VIEWS IN SCHEMA ANALYTICS TO ROLE OFFICEMAX_CORTEX_USER;

-- Permisos para usar servicios Cortex
GRANT USAGE ON CORTEX SEARCH SERVICE OFFICEMAX_DOCUMENTS_SEARCH TO ROLE OFFICEMAX_CORTEX_USER;
GRANT USAGE ON CORTEX SEARCH SERVICE OFFICEMAX_ANALYST_MODEL TO ROLE OFFICEMAX_CORTEX_USER;

-- Permisos para funciones y procedimientos
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA CORTEX_SERVICES TO ROLE OFFICEMAX_CORTEX_USER;
GRANT USAGE ON ALL PROCEDURES IN SCHEMA CORTEX_SERVICES TO ROLE OFFICEMAX_CORTEX_USER;

-- Permisos futuros
GRANT SELECT ON FUTURE TABLES IN SCHEMA RAW_DATA TO ROLE OFFICEMAX_CORTEX_USER;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA ANALYTICS TO ROLE OFFICEMAX_CORTEX_USER;

-- ============================================================================
-- PASO 7: TESTS DE CONFIGURACIÓN
-- ============================================================================

-- Test 1: Verificar que el servicio de búsqueda funciona
SELECT 'Testing Cortex Search...' as STATUS;

SELECT 
    DOCUMENTO_ID,
    TITULO,
    RELEVANCE_SCORE
FROM TABLE(CORTEX_SERVICES.SEARCH_DOCUMENTS('laptop HP tecnología', NULL, 3))
ORDER BY RELEVANCE_SCORE DESC;

-- Test 2: Verificar vistas analíticas
SELECT 'Testing Analytics Views...' as STATUS;

SELECT 
    MES,
    CATEGORIA_PADRE,
    SUM(INGRESOS_TOTALES) as INGRESOS
FROM ANALYTICS.TENDENCIAS_VENTAS
WHERE MES >= DATEADD('month', -3, CURRENT_DATE())
GROUP BY MES, CATEGORIA_PADRE
ORDER BY MES DESC, INGRESOS DESC
LIMIT 10;

-- Test 3: Verificar procedimientos
SELECT 'Testing Stored Procedures...' as STATUS;

CALL CORTEX_SERVICES.ANALIZAR_TEMPORADA(
    DATEADD('month', -1, CURRENT_DATE()),
    CURRENT_DATE(),
    'Tecnología'
);

-- ============================================================================
-- FINALIZACIÓN
-- ============================================================================

-- Crear tabla de configuración para tracking
CREATE OR REPLACE TABLE CORTEX_SERVICES.CONFIGURACION_LOG (
    EVENTO VARCHAR(200),
    TIMESTAMP_EVENTO TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    DETALLES VARIANT,
    USUARIO VARCHAR(100) DEFAULT CURRENT_USER(),
    ESTADO VARCHAR(50) DEFAULT 'COMPLETADO'
);

-- Log del setup
INSERT INTO CORTEX_SERVICES.CONFIGURACION_LOG VALUES
('CORTEX_SEARCH_SETUP', CURRENT_TIMESTAMP(), 
 OBJECT_CONSTRUCT('servicio', 'OFFICEMAX_DOCUMENTS_SEARCH', 'warehouse', 'OFFICEMAX_CORTEX_WH'), 
 CURRENT_USER(), 'COMPLETADO'),
('CORTEX_ANALYST_SETUP', CURRENT_TIMESTAMP(), 
 OBJECT_CONSTRUCT('modelo', 'OFFICEMAX_ANALYST_MODEL', 'tablas', 6), 
 CURRENT_USER(), 'COMPLETADO'),
('VISTAS_ANALITICAS_SETUP', CURRENT_TIMESTAMP(), 
 OBJECT_CONSTRUCT('vistas_creadas', 3, 'procedimientos', 2), 
 CURRENT_USER(), 'COMPLETADO'),
('PERMISOS_SETUP', CURRENT_TIMESTAMP(), 
 OBJECT_CONSTRUCT('rol', 'OFFICEMAX_CORTEX_USER', 'permisos_otorgados', 'TRUE'), 
 CURRENT_USER(), 'COMPLETADO');

-- Mensaje final
SELECT 
    '🤖 CORTEX SERVICES CONFIGURADOS EXITOSAMENTE' as RESULTADO,
    'Cortex Analyst y Cortex Search listos para uso' as DETALLE,
    (SELECT COUNT(*) FROM CORTEX_SERVICES.CONFIGURACION_LOG) as EVENTOS_LOG,
    CURRENT_TIMESTAMP() as TIMESTAMP_COMPLETION;


