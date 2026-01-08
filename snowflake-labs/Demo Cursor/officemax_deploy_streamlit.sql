-- ============================================================================
-- OFFICEMAX MÉXICO - DEPLOY STREAMLIT APP IN SNOWFLAKE
-- Script para desplegar la aplicación Streamlit en Snowflake
-- ============================================================================

USE DATABASE OFFICEMAX_MEXICO;
USE WAREHOUSE OFFICEMAX_CORTEX_WH;
USE SCHEMA CORTEX_SERVICES;

-- ============================================================================
-- PASO 1: CREAR STAGE PARA ARCHIVOS DE LA APLICACIÓN
-- ============================================================================

-- Crear stage interno para archivos de Streamlit
CREATE OR REPLACE STAGE OFFICEMAX_STREAMLIT_STAGE
COMMENT = 'Stage para archivos de la aplicación Streamlit de OfficeMax México';

-- ============================================================================
-- PASO 2: CREAR LA APLICACIÓN STREAMLIT
-- ============================================================================

-- Crear aplicación Streamlit
CREATE OR REPLACE STREAMLIT OFFICEMAX_CORTEX_APP
ROOT_LOCATION = '@OFFICEMAX_STREAMLIT_STAGE'
MAIN_FILE = '/officemax_streamlit_app.py'
QUERY_WAREHOUSE = OFFICEMAX_CORTEX_WH
COMMENT = 'Aplicación OfficeMax México - Cortex AI Platform con Analyst y Search';

-- ============================================================================
-- PASO 3: CONFIGURAR PERMISOS PARA LA APLICACIÓN
-- ============================================================================

-- Otorgar permisos de uso de la aplicación al rol de usuarios Cortex
GRANT USAGE ON STREAMLIT OFFICEMAX_CORTEX_APP TO ROLE OFFICEMAX_CORTEX_USER;

-- Otorgar permisos adicionales necesarios para la aplicación
GRANT USAGE ON WAREHOUSE OFFICEMAX_CORTEX_WH TO ROLE OFFICEMAX_CORTEX_USER;
GRANT USAGE ON DATABASE OFFICEMAX_MEXICO TO ROLE OFFICEMAX_CORTEX_USER;
GRANT USAGE ON SCHEMA RAW_DATA TO ROLE OFFICEMAX_CORTEX_USER;
GRANT USAGE ON SCHEMA ANALYTICS TO ROLE OFFICEMAX_CORTEX_USER;
GRANT USAGE ON SCHEMA CORTEX_SERVICES TO ROLE OFFICEMAX_CORTEX_USER;

-- Permisos específicos para Cortex services
GRANT USAGE ON CORTEX SEARCH SERVICE OFFICEMAX_DOCUMENTS_SEARCH TO ROLE OFFICEMAX_CORTEX_USER;

-- ============================================================================
-- PASO 4: CREAR USUARIO DEMO PARA PRUEBAS
-- ============================================================================

-- Crear usuario demo para probar la aplicación
CREATE OR REPLACE USER OFFICEMAX_DEMO_USER
PASSWORD = '<TU_PASSWORD>'
DEFAULT_ROLE = OFFICEMAX_CORTEX_USER
DEFAULT_WAREHOUSE = OFFICEMAX_CORTEX_WH
DEFAULT_NAMESPACE = 'OFFICEMAX_MEXICO.RAW_DATA'
COMMENT = 'Usuario demo para probar la aplicación OfficeMax Cortex';

-- Otorgar rol al usuario demo
GRANT ROLE OFFICEMAX_CORTEX_USER TO USER OFFICEMAX_DEMO_USER;

-- ============================================================================
-- PASO 5: CONFIGURAR VARIABLES DE ENTORNO Y CONFIGURACIÓN
-- ============================================================================

-- Crear tabla de configuración de la aplicación
CREATE OR REPLACE TABLE CORTEX_SERVICES.APP_CONFIG (
    CONFIG_KEY VARCHAR(100) PRIMARY KEY,
    CONFIG_VALUE VARIANT,
    DESCRIPCION TEXT,
    ACTIVO BOOLEAN DEFAULT TRUE,
    FECHA_ACTUALIZACION TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Insertar configuración inicial
INSERT INTO CORTEX_SERVICES.APP_CONFIG VALUES
('APP_TITLE', '"OfficeMax México - Cortex AI Platform"', 'Título de la aplicación', TRUE, CURRENT_TIMESTAMP()),
('APP_VERSION', '"1.0.0"', 'Versión de la aplicación', TRUE, CURRENT_TIMESTAMP()),
('CORTEX_SEARCH_SERVICE', '"OFFICEMAX_DOCUMENTS_SEARCH"', 'Nombre del servicio Cortex Search', TRUE, CURRENT_TIMESTAMP()),
('CORTEX_ANALYST_MODEL', '"OFFICEMAX_ANALYST_MODEL"', 'Nombre del modelo Cortex Analyst', TRUE, CURRENT_TIMESTAMP()),
('DEFAULT_WAREHOUSE', '"OFFICEMAX_CORTEX_WH"', 'Warehouse por defecto', TRUE, CURRENT_TIMESTAMP()),
('DASHBOARD_REFRESH_MINUTES', '5', 'Minutos de cache para métricas del dashboard', TRUE, CURRENT_TIMESTAMP()),
('MAX_SEARCH_RESULTS', '20', 'Máximo número de resultados en búsquedas', TRUE, CURRENT_TIMESTAMP()),
('COMPANY_COLORS', 
 OBJECT_CONSTRUCT(
   'primary_red', '#E31B24',
   'secondary_blue', '#003B7A',
   'orange_accent', '#FF6B35',
   'green_success', '#28A745'
 ), 
 'Colores corporativos de OfficeMax', TRUE, CURRENT_TIMESTAMP()),
('FEATURED_CATEGORIES', 
 ARRAY_CONSTRUCT('Tecnología', 'Papelería', 'Material Escolar', 'Mobiliario de Oficina'), 
 'Categorías destacadas en la aplicación', TRUE, CURRENT_TIMESTAMP());

-- ============================================================================
-- PASO 6: CREAR FUNCIONES AUXILIARES PARA LA APLICACIÓN
-- ============================================================================

-- Función para obtener configuración de la aplicación
CREATE OR REPLACE FUNCTION CORTEX_SERVICES.GET_APP_CONFIG(CONFIG_KEY VARCHAR)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
  SELECT CONFIG_VALUE 
  FROM CORTEX_SERVICES.APP_CONFIG 
  WHERE CONFIG_KEY = GET_APP_CONFIG.CONFIG_KEY 
    AND ACTIVO = TRUE
$$;

-- Función para obtener métricas de dashboard optimizada
CREATE OR REPLACE FUNCTION CORTEX_SERVICES.GET_DASHBOARD_METRICS()
RETURNS VARIANT
LANGUAGE SQL
AS
$$
  SELECT OBJECT_CONSTRUCT(
    'total_productos', (SELECT COUNT(*) FROM RAW_DATA.PRODUCTOS WHERE ACTIVO = TRUE),
    'total_clientes', (SELECT COUNT(*) FROM RAW_DATA.CLIENTES WHERE ACTIVO = TRUE),
    'total_sucursales', (SELECT COUNT(*) FROM RAW_DATA.SUCURSALES WHERE ACTIVO = TRUE),
    'ventas_mes_actual', (
      SELECT COALESCE(SUM(TOTAL_LINEA), 0) 
      FROM RAW_DATA.VENTAS 
      WHERE DATE_TRUNC('MONTH', FECHA_VENTA) = DATE_TRUNC('MONTH', CURRENT_DATE())
    ),
    'ventas_mes_anterior', (
      SELECT COALESCE(SUM(TOTAL_LINEA), 0) 
      FROM RAW_DATA.VENTAS 
      WHERE DATE_TRUNC('MONTH', FECHA_VENTA) = DATE_TRUNC('MONTH', DATEADD('MONTH', -1, CURRENT_DATE()))
    ),
    'margen_promedio', (
      SELECT COALESCE(AVG(PORCENTAJE_MARGEN), 0) 
      FROM RAW_DATA.VENTAS 
      WHERE FECHA_VENTA >= DATEADD('MONTH', -1, CURRENT_DATE())
    ),
    'productos_bajo_stock', (
      SELECT COUNT(*) 
      FROM RAW_DATA.INVENTARIO i 
      JOIN RAW_DATA.PRODUCTOS p ON i.PRODUCTO_ID = p.PRODUCTO_ID
      WHERE i.STOCK_ACTUAL <= p.STOCK_MINIMO
    ),
    'timestamp_actualizacion', CURRENT_TIMESTAMP()
  )
$$;

-- Función para logging de actividad de usuarios
CREATE OR REPLACE FUNCTION CORTEX_SERVICES.LOG_USER_ACTIVITY(
  ACTION_TYPE VARCHAR,
  ACTION_DETAILS VARIANT DEFAULT NULL
)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
  BEGIN
    INSERT INTO CORTEX_SERVICES.USER_ACTIVITY_LOG 
    VALUES (CURRENT_USER(), CURRENT_TIMESTAMP(), ACTION_TYPE, ACTION_DETAILS);
    RETURN 'Activity logged successfully';
  END;
$$;

-- Crear tabla de log de actividad
CREATE OR REPLACE TABLE CORTEX_SERVICES.USER_ACTIVITY_LOG (
    USER_NAME VARCHAR(100),
    TIMESTAMP_ACTION TIMESTAMP_NTZ,
    ACTION_TYPE VARCHAR(100),
    ACTION_DETAILS VARIANT,
    SESSION_ID VARCHAR(100) DEFAULT CURRENT_SESSION()
);

-- ============================================================================
-- PASO 7: CREAR PROCEDIMIENTOS PARA MANTENIMIENTO
-- ============================================================================

-- Procedimiento para actualizar estadísticas de la aplicación
CREATE OR REPLACE PROCEDURE CORTEX_SERVICES.UPDATE_APP_STATISTICS()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
  -- Actualizar tabla de estadísticas de uso
  CREATE OR REPLACE TABLE CORTEX_SERVICES.APP_USAGE_STATS AS
  SELECT 
    CURRENT_DATE() as FECHA_STATS,
    COUNT(DISTINCT USER_NAME) as USUARIOS_ACTIVOS_HOY,
    COUNT(*) as ACCIONES_TOTALES_HOY,
    COUNT(CASE WHEN ACTION_TYPE = 'CORTEX_SEARCH' THEN 1 END) as BUSQUEDAS_HOY,
    COUNT(CASE WHEN ACTION_TYPE = 'CORTEX_ANALYST' THEN 1 END) as CONSULTAS_ANALYST_HOY,
    COUNT(CASE WHEN ACTION_TYPE = 'DASHBOARD_VIEW' THEN 1 END) as VISTAS_DASHBOARD_HOY
  FROM CORTEX_SERVICES.USER_ACTIVITY_LOG
  WHERE DATE(TIMESTAMP_ACTION) = CURRENT_DATE();
  
  RETURN 'Statistics updated successfully';
END;
$$;

-- Procedimiento para limpiar logs antiguos
CREATE OR REPLACE PROCEDURE CORTEX_SERVICES.CLEANUP_OLD_LOGS(DAYS_TO_KEEP INTEGER DEFAULT 90)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN
  DELETE FROM CORTEX_SERVICES.USER_ACTIVITY_LOG
  WHERE TIMESTAMP_ACTION < DATEADD('day', -DAYS_TO_KEEP, CURRENT_DATE());
  
  RETURN 'Old logs cleaned up successfully';
END;
$$;

-- ============================================================================
-- PASO 8: CONFIGURAR TASKS PARA MANTENIMIENTO AUTOMÁTICO
-- ============================================================================

-- Task para actualizar estadísticas diariamente
CREATE OR REPLACE TASK CORTEX_SERVICES.DAILY_STATS_UPDATE
WAREHOUSE = OFFICEMAX_CORTEX_WH
SCHEDULE = 'USING CRON 0 2 * * * UTC'  -- Diario a las 2:00 AM UTC
COMMENT = 'Actualizar estadísticas de uso de la aplicación diariamente'
AS
CALL CORTEX_SERVICES.UPDATE_APP_STATISTICS();

-- Task para limpieza de logs semanalmente
CREATE OR REPLACE TASK CORTEX_SERVICES.WEEKLY_LOG_CLEANUP
WAREHOUSE = OFFICEMAX_CORTEX_WH
SCHEDULE = 'USING CRON 0 3 * * 0 UTC'  -- Domingos a las 3:00 AM UTC
COMMENT = 'Limpiar logs antiguos semanalmente'
AS
CALL CORTEX_SERVICES.CLEANUP_OLD_LOGS(90);

-- Activar tasks
ALTER TASK CORTEX_SERVICES.DAILY_STATS_UPDATE RESUME;
ALTER TASK CORTEX_SERVICES.WEEKLY_LOG_CLEANUP RESUME;

-- ============================================================================
-- PASO 9: CREAR VISTAS PARA MONITOREO DE LA APLICACIÓN
-- ============================================================================

-- Vista para monitoreo de uso de la aplicación
CREATE OR REPLACE VIEW CORTEX_SERVICES.APP_MONITORING AS
SELECT 
    DATE(TIMESTAMP_ACTION) as FECHA,
    COUNT(DISTINCT USER_NAME) as USUARIOS_UNICOS,
    COUNT(*) as TOTAL_ACCIONES,
    COUNT(CASE WHEN ACTION_TYPE = 'CORTEX_SEARCH' THEN 1 END) as BUSQUEDAS,
    COUNT(CASE WHEN ACTION_TYPE = 'CORTEX_ANALYST' THEN 1 END) as CONSULTAS_ANALYST,
    COUNT(CASE WHEN ACTION_TYPE = 'DASHBOARD_VIEW' THEN 1 END) as VISTAS_DASHBOARD,
    COUNT(CASE WHEN ACTION_TYPE = 'PRODUCT_ANALYSIS' THEN 1 END) as ANALISIS_PRODUCTOS,
    AVG(DATEDIFF('second', LAG(TIMESTAMP_ACTION) OVER (PARTITION BY USER_NAME ORDER BY TIMESTAMP_ACTION), TIMESTAMP_ACTION)) as TIEMPO_PROMEDIO_ENTRE_ACCIONES
FROM CORTEX_SERVICES.USER_ACTIVITY_LOG
GROUP BY DATE(TIMESTAMP_ACTION)
ORDER BY FECHA DESC;

-- Vista para usuarios más activos
CREATE OR REPLACE VIEW CORTEX_SERVICES.TOP_USERS AS
SELECT 
    USER_NAME,
    COUNT(*) as TOTAL_ACCIONES,
    COUNT(DISTINCT DATE(TIMESTAMP_ACTION)) as DIAS_ACTIVO,
    MAX(TIMESTAMP_ACTION) as ULTIMA_ACTIVIDAD,
    ARRAY_AGG(DISTINCT ACTION_TYPE) WITHIN GROUP (ORDER BY ACTION_TYPE) as TIPOS_ACCIONES
FROM CORTEX_SERVICES.USER_ACTIVITY_LOG
WHERE TIMESTAMP_ACTION >= DATEADD('day', -30, CURRENT_DATE())
GROUP BY USER_NAME
ORDER BY TOTAL_ACCIONES DESC;

-- ============================================================================
-- PASO 10: CONFIGURAR ALERTAS Y NOTIFICACIONES
-- ============================================================================

-- Función para verificar salud de la aplicación
CREATE OR REPLACE FUNCTION CORTEX_SERVICES.CHECK_APP_HEALTH()
RETURNS VARIANT
LANGUAGE SQL
AS
$$
  SELECT OBJECT_CONSTRUCT(
    'cortex_search_available', (
      SELECT COUNT(*) > 0 
      FROM INFORMATION_SCHEMA.CORTEX_SEARCH_SERVICES 
      WHERE SERVICE_NAME = 'OFFICEMAX_DOCUMENTS_SEARCH'
    ),
    'data_freshness_hours', (
      SELECT DATEDIFF('hour', MAX(FECHA_VENTA), CURRENT_TIMESTAMP()) 
      FROM RAW_DATA.VENTAS
    ),
    'users_active_today', (
      SELECT COUNT(DISTINCT USER_NAME) 
      FROM CORTEX_SERVICES.USER_ACTIVITY_LOG 
      WHERE DATE(TIMESTAMP_ACTION) = CURRENT_DATE()
    ),
    'errors_today', (
      SELECT COUNT(*) 
      FROM CORTEX_SERVICES.USER_ACTIVITY_LOG 
      WHERE DATE(TIMESTAMP_ACTION) = CURRENT_DATE() 
        AND ACTION_TYPE = 'ERROR'
    ),
    'health_check_timestamp', CURRENT_TIMESTAMP()
  )
$$;

-- ============================================================================
-- PASO 11: DOCUMENTACIÓN Y METADATOS
-- ============================================================================

-- Crear tabla de documentación de la aplicación
CREATE OR REPLACE TABLE CORTEX_SERVICES.APP_DOCUMENTATION (
    DOC_ID VARCHAR(50) PRIMARY KEY,
    TITULO VARCHAR(200),
    CONTENIDO TEXT,
    CATEGORIA VARCHAR(100),
    VERSION VARCHAR(20),
    FECHA_CREACION TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FECHA_ACTUALIZACION TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Insertar documentación inicial
INSERT INTO CORTEX_SERVICES.APP_DOCUMENTATION VALUES
('INSTALL_GUIDE', 'Guía de Instalación', 'Pasos para instalar y configurar la aplicación OfficeMax Cortex...', 'INSTALACION', '1.0', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('USER_MANUAL', 'Manual de Usuario', 'Cómo usar las funcionalidades de Cortex Analyst y Search...', 'USUARIO', '1.0', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('API_REFERENCE', 'Referencia de APIs', 'Documentación de funciones y procedimientos disponibles...', 'TECNICA', '1.0', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('TROUBLESHOOTING', 'Solución de Problemas', 'Problemas comunes y sus soluciones...', 'SOPORTE', '1.0', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- PASO 12: VERIFICACIÓN Y TESTS DEL DEPLOYMENT
-- ============================================================================

-- Test 1: Verificar que todos los objetos fueron creados
SELECT 'Verificando objetos creados...' as TEST_STATUS;

SELECT 
    'STREAMLIT_APP' as OBJECT_TYPE,
    COUNT(*) as COUNT_CREATED
FROM INFORMATION_SCHEMA.STREAMLITS 
WHERE STREAMLIT_NAME = 'OFFICEMAX_CORTEX_APP'

UNION ALL

SELECT 
    'CORTEX_SEARCH_SERVICE' as OBJECT_TYPE,
    COUNT(*) as COUNT_CREATED
FROM INFORMATION_SCHEMA.CORTEX_SEARCH_SERVICES 
WHERE SERVICE_NAME = 'OFFICEMAX_DOCUMENTS_SEARCH'

UNION ALL

SELECT 
    'FUNCTIONS' as OBJECT_TYPE,
    COUNT(*) as COUNT_CREATED
FROM INFORMATION_SCHEMA.FUNCTIONS 
WHERE FUNCTION_SCHEMA = 'CORTEX_SERVICES' 
  AND FUNCTION_NAME LIKE '%APP%'

UNION ALL

SELECT 
    'PROCEDURES' as OBJECT_TYPE,
    COUNT(*) as COUNT_CREATED
FROM INFORMATION_SCHEMA.PROCEDURES 
WHERE PROCEDURE_SCHEMA = 'CORTEX_SERVICES'

UNION ALL

SELECT 
    'TASKS' as OBJECT_TYPE,
    COUNT(*) as COUNT_CREATED
FROM INFORMATION_SCHEMA.TASKS 
WHERE TASK_SCHEMA = 'CORTEX_SERVICES';

-- Test 2: Verificar configuración
SELECT 'Testing configuration...' as TEST_STATUS;

SELECT 
    CONFIG_KEY,
    CONFIG_VALUE,
    ACTIVO
FROM CORTEX_SERVICES.APP_CONFIG
ORDER BY CONFIG_KEY;

-- Test 3: Verificar funciones principales
SELECT 'Testing core functions...' as TEST_STATUS;

SELECT CORTEX_SERVICES.GET_APP_CONFIG('APP_TITLE') as APP_TITLE_TEST;
SELECT CORTEX_SERVICES.GET_DASHBOARD_METRICS() as DASHBOARD_METRICS_TEST;
SELECT CORTEX_SERVICES.CHECK_APP_HEALTH() as HEALTH_CHECK_TEST;

-- ============================================================================
-- FINALIZACIÓN DEL DEPLOYMENT
-- ============================================================================

-- Log del deployment exitoso
INSERT INTO CORTEX_SERVICES.CONFIGURACION_LOG VALUES
('STREAMLIT_APP_DEPLOYED', CURRENT_TIMESTAMP(), 
 OBJECT_CONSTRUCT(
   'app_name', 'OFFICEMAX_CORTEX_APP',
   'version', '1.0.0',
   'warehouse', 'OFFICEMAX_CORTEX_WH',
   'usuario_demo', 'OFFICEMAX_DEMO_USER'
 ), 
 CURRENT_USER(), 'COMPLETADO');

-- Mostrar información de acceso
SELECT 
    '🚀 APLICACIÓN STREAMLIT DESPLEGADA EXITOSAMENTE' as RESULTADO,
    'Aplicación OfficeMax Cortex AI Platform lista para uso' as DETALLE,
    'OFFICEMAX_CORTEX_APP' as NOMBRE_APP,
    'OFFICEMAX_DEMO_USER' as USUARIO_DEMO,
    'OfficeMax2024!' as PASSWORD_DEMO,
    'Accede desde Snowsight > Streamlit > OFFICEMAX_CORTEX_APP' as INSTRUCCIONES_ACCESO,
    CURRENT_TIMESTAMP() as TIMESTAMP_DEPLOYMENT;

-- ============================================================================
-- INSTRUCCIONES POST-DEPLOYMENT
-- ============================================================================

/*
🎉 ¡DEPLOYMENT COMPLETADO EXITOSAMENTE!

📋 SIGUIENTES PASOS:

1. SUBIR ARCHIVO STREAMLIT:
   - Ve a Snowsight > Data > Databases > OFFICEMAX_MEXICO > CORTEX_SERVICES > Stages
   - Selecciona OFFICEMAX_STREAMLIT_STAGE
   - Sube el archivo 'officemax_streamlit_app.py'

2. ACCEDER A LA APLICACIÓN:
   - Ve a Snowsight > Streamlit
   - Busca 'OFFICEMAX_CORTEX_APP'
   - Haz clic para acceder

3. CREDENCIALES DE PRUEBA:
   - Usuario: OFFICEMAX_DEMO_USER
   - Password: OfficeMax2024!
   - Rol: OFFICEMAX_CORTEX_USER

4. FUNCIONALIDADES DISPONIBLES:
   ✅ Dashboard Ejecutivo con métricas en tiempo real
   ✅ Cortex Analyst para consultas en lenguaje natural
   ✅ Cortex Search para búsqueda semántica de documentos
   ✅ Análisis de productos, sucursales y clientes
   ✅ Visualizaciones interactivas con colores OfficeMax

5. MONITOREO:
   - Revisa CORTEX_SERVICES.APP_MONITORING para uso
   - Verifica CORTEX_SERVICES.APP_USAGE_STATS para estadísticas
   - Consulta logs en CORTEX_SERVICES.USER_ACTIVITY_LOG

6. MANTENIMIENTO:
   - Tasks automáticos configurados para estadísticas y limpieza
   - Funciones de salud y monitoreo disponibles
   - Documentación en CORTEX_SERVICES.APP_DOCUMENTATION

🏢 ¡Disfruta tu nueva plataforma OfficeMax Cortex AI!
*/


