-- ============================================================================
-- STORED PROCEDURE: Consultar Tipo de Cambio de Banxico
-- Cliente: Unstructured Docs
-- Fuente: API REST de Banco de México (Banxico)
-- Serie: SF43718 - Tipo de Cambio FIX (Pesos por Dólar)
-- API Docs: https://www.banxico.org.mx/SieAPIRest/service/v1/
-- ============================================================================

-- ============================================================================
-- Sección 0: Historia y Caso de Uso
-- ============================================================================
-- 
-- PROPÓSITO:
-- Consultar el tipo de cambio interbancario oficial (FIX) publicado por Banxico
-- y almacenarlo en Snowflake para análisis financieros y conversiones de moneda.
--
-- API DE BANXICO:
-- Banxico proporciona una API REST pública para consultar series económicas.
-- La serie SF43718 corresponde al tipo de cambio FIX (Pesos por Dólar).
-- 
-- NOTA: Para usar la API de Banxico es necesario obtener un token gratuito
-- registrándose en: https://www.banxico.org.mx/SieAPIRest/service/v1/token
--
-- CASO DE USO:
-- - Convertir montos en dólares a pesos en documentos fiscales
-- - Registrar tipo de cambio histórico para auditorías
-- - Análisis de impacto cambiario en operaciones internacionales
--
-- ============================================================================

-- ============================================================================
-- Sección 1: Configuración de Recursos
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE UNSTRUCTURED_DOCS_WH;
USE DATABASE UNSTRUCTURED_DOCS_DB;
USE SCHEMA DOCUMENTOS_SAT;

-- Crear tabla para almacenar tipos de cambio históricos
CREATE TABLE IF NOT EXISTS UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO (
    ID NUMBER AUTOINCREMENT PRIMARY KEY,
    FECHA DATE NOT NULL,
    TIPO_CAMBIO DECIMAL(10, 6) NOT NULL,
    SERIE VARCHAR(20) DEFAULT 'SF43718',
    FUENTE VARCHAR(50) DEFAULT 'Banxico API',
    FECHA_CONSULTA TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    METADATA VARIANT,
    UNIQUE (FECHA, SERIE),
    COMMENT = 'Tipos de cambio históricos del Banco de México'
);

-- Crear tabla para configuración de API
CREATE TABLE IF NOT EXISTS UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONFIG_API_BANXICO (
    ID NUMBER AUTOINCREMENT PRIMARY KEY,
    PARAMETRO VARCHAR(100) UNIQUE NOT NULL,
    VALOR VARCHAR(500),
    DESCRIPCION VARCHAR(500),
    FECHA_ACTUALIZACION TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    COMMENT = 'Configuración para API de Banxico'
);

-- Insertar configuración por defecto
MERGE INTO UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONFIG_API_BANXICO AS target
USING (
    SELECT 
        'API_BASE_URL' AS PARAMETRO,
        'https://www.banxico.org.mx/SieAPIRest/service/v1/series' AS VALOR,
        'URL base de la API REST de Banxico' AS DESCRIPCION
    UNION ALL
    SELECT 
        'SERIE_TIPO_CAMBIO',
        'SF43718',
        'Serie del tipo de cambio FIX (Pesos por Dólar)'
    UNION ALL
    SELECT 
        'TOKEN_API',
        'TU_TOKEN_AQUI',
        'Token de autenticación de Banxico (obtener en https://www.banxico.org.mx/SieAPIRest/service/v1/token)'
    UNION ALL
    SELECT 
        'DIAS_HISTORICO',
        '30',
        'Número de días de historial a consultar'
) AS source
ON target.PARAMETRO = source.PARAMETRO
WHEN NOT MATCHED THEN
    INSERT (PARAMETRO, VALOR, DESCRIPCION)
    VALUES (source.PARAMETRO, source.VALOR, source.DESCRIPCION);

-- ============================================================================
-- Sección 2: Crear External Function (Método 1 - Requiere AWS/Azure)
-- ============================================================================

-- NOTA: Este método requiere configurar una API Gateway en AWS o Azure
-- Si no tienes acceso, salta a la Sección 3 para el método alternativo

-- Crear API Integration (ejemplo con AWS)
/*
CREATE OR REPLACE API INTEGRATION BANXICO_API_INTEGRATION
    API_PROVIDER = AWS_API_GATEWAY
    API_AWS_ROLE_ARN = 'arn:aws:iam::tu-cuenta:role/snowflake-api-role'
    ENABLED = TRUE
    API_ALLOWED_PREFIXES = ('https://api.banxico.org.mx/');

-- Crear External Function
CREATE OR REPLACE EXTERNAL FUNCTION CONSULTAR_TIPO_CAMBIO_EXTERNO(
    fecha VARCHAR,
    token VARCHAR
)
RETURNS VARIANT
API_INTEGRATION = BANXICO_API_INTEGRATION
AS 'https://tu-api-gateway.execute-api.region.amazonaws.com/prod/banxico-exchange-rate';
*/

-- ============================================================================
-- Sección 3: Stored Procedure con Python (Método Recomendado)
-- ============================================================================

-- NOTA: Este stored procedure usa Python para hacer la llamada HTTP
-- Requiere que la cuenta de Snowflake tenga habilitado Python UDFs

CREATE OR REPLACE PROCEDURE UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.SP_CONSULTAR_TIPO_CAMBIO_BANXICO(
    FECHA_INICIO VARCHAR,
    FECHA_FIN VARCHAR,
    TOKEN_API VARCHAR
)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('requests', 'snowflake-snowpark-python')
HANDLER = 'consultar_tipo_cambio'
COMMENT = 'Consulta tipo de cambio de Banxico y lo almacena en la tabla TIPO_CAMBIO_BANXICO'
AS
$$
import requests
import json
from datetime import datetime

def consultar_tipo_cambio(session, fecha_inicio, fecha_fin, token_api):
    """
    Consulta el tipo de cambio del Banco de México
    
    Args:
        session: Sesión de Snowflake
        fecha_inicio: Fecha inicial en formato YYYY-MM-DD
        fecha_fin: Fecha final en formato YYYY-MM-DD
        token_api: Token de autenticación de Banxico
    
    Returns:
        Mensaje con el resultado de la operación
    """
    
    try:
        # Validar token
        if token_api == 'TU_TOKEN_AQUI' or not token_api:
            return "ERROR: Debes configurar un token válido de Banxico. Obtén uno en https://www.banxico.org.mx/SieAPIRest/service/v1/token"
        
        # Construir URL de la API
        serie = 'SF43718'  # Tipo de cambio FIX
        base_url = 'https://www.banxico.org.mx/SieAPIRest/service/v1/series'
        url = f"{base_url}/{serie}/datos/{fecha_inicio}/{fecha_fin}"
        
        # Headers con token
        headers = {
            'Bmx-Token': token_api,
            'Accept': 'application/json'
        }
        
        # Hacer petición a la API
        response = requests.get(url, headers=headers, timeout=30)
        
        if response.status_code != 200:
            return f"ERROR: API de Banxico retornó código {response.status_code}. Verifica tu token y las fechas."
        
        # Parsear respuesta JSON
        data = response.json()
        
        if 'bmx' not in data or 'series' not in data['bmx']:
            return "ERROR: Respuesta inesperada de la API de Banxico"
        
        series_data = data['bmx']['series'][0]['datos']
        
        if not series_data:
            return f"ADVERTENCIA: No hay datos disponibles para el periodo {fecha_inicio} a {fecha_fin}"
        
        # Insertar datos en la tabla
        registros_insertados = 0
        registros_actualizados = 0
        
        for dato in series_data:
            fecha = dato['fecha']
            valor = dato['dato']
            
            # Convertir fecha de formato dd/MM/yyyy a yyyy-MM-dd
            fecha_parts = fecha.split('/')
            fecha_sql = f"{fecha_parts[2]}-{fecha_parts[1]}-{fecha_parts[0]}"
            
            # Si el valor es N/E (No Existe), saltar
            if valor == 'N/E':
                continue
            
            tipo_cambio = float(valor)
            
            # Preparar metadata
            metadata = json.dumps({
                'fecha_original': fecha,
                'serie': serie,
                'api_version': 'v1'
            })
            
            # Insert or Update usando MERGE
            merge_sql = f"""
            MERGE INTO UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO AS target
            USING (
                SELECT 
                    '{fecha_sql}'::DATE AS FECHA,
                    {tipo_cambio} AS TIPO_CAMBIO,
                    '{serie}' AS SERIE,
                    'Banxico API' AS FUENTE,
                    CURRENT_TIMESTAMP() AS FECHA_CONSULTA,
                    PARSE_JSON('{metadata}') AS METADATA
            ) AS source
            ON target.FECHA = source.FECHA AND target.SERIE = source.SERIE
            WHEN MATCHED THEN
                UPDATE SET 
                    TIPO_CAMBIO = source.TIPO_CAMBIO,
                    FECHA_CONSULTA = source.FECHA_CONSULTA,
                    METADATA = source.METADATA
            WHEN NOT MATCHED THEN
                INSERT (FECHA, TIPO_CAMBIO, SERIE, FUENTE, FECHA_CONSULTA, METADATA)
                VALUES (source.FECHA, source.TIPO_CAMBIO, source.SERIE, source.FUENTE, 
                        source.FECHA_CONSULTA, source.METADATA)
            """
            
            result = session.sql(merge_sql).collect()
            
            # Contar operaciones
            if result[0][0] == 1:  # Insert
                registros_insertados += 1
            elif result[0][0] == 2:  # Update
                registros_actualizados += 1
        
        # Mensaje de éxito
        mensaje = f"✓ ÉXITO: Procesados {len(series_data)} registros de Banxico. "
        mensaje += f"Insertados: {registros_insertados}, Actualizados: {registros_actualizados}. "
        mensaje += f"Periodo: {fecha_inicio} a {fecha_fin}"
        
        return mensaje
        
    except requests.exceptions.Timeout:
        return "ERROR: Timeout al conectar con la API de Banxico"
    except requests.exceptions.RequestException as e:
        return f"ERROR: Error de conexión con Banxico: {str(e)}"
    except Exception as e:
        return f"ERROR: {str(e)}"
$$;

-- ============================================================================
-- Sección 4: Stored Procedure Simplificado (Solo Consulta Actual)
-- ============================================================================

CREATE OR REPLACE PROCEDURE UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.SP_OBTENER_TIPO_CAMBIO_ACTUAL()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('requests', 'snowflake-snowpark-python')
HANDLER = 'obtener_tipo_cambio_actual'
COMMENT = 'Obtiene el tipo de cambio más reciente de Banxico'
AS
$$
import requests
from datetime import datetime, timedelta

def obtener_tipo_cambio_actual(session):
    """
    Obtiene el tipo de cambio del día actual o el más reciente disponible
    """
    
    try:
        # Obtener token de la tabla de configuración
        token_result = session.sql("""
            SELECT VALOR 
            FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONFIG_API_BANXICO 
            WHERE PARAMETRO = 'TOKEN_API'
        """).collect()
        
        if not token_result or token_result[0][0] == 'TU_TOKEN_AQUI':
            return "ERROR: Configura el TOKEN_API en la tabla CONFIG_API_BANXICO"
        
        token = token_result[0][0]
        
        # Obtener fechas (últimos 5 días para asegurar que encontramos datos)
        fecha_fin = datetime.now()
        fecha_inicio = fecha_fin - timedelta(days=5)
        
        fecha_inicio_str = fecha_inicio.strftime('%Y-%m-%d')
        fecha_fin_str = fecha_fin.strftime('%Y-%m-%d')
        
        # Llamar al stored procedure principal
        result = session.call(
            'UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.SP_CONSULTAR_TIPO_CAMBIO_BANXICO',
            fecha_inicio_str,
            fecha_fin_str,
            token
        )
        
        # Obtener el tipo de cambio más reciente
        tc_result = session.sql("""
            SELECT FECHA, TIPO_CAMBIO
            FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO
            ORDER BY FECHA DESC
            LIMIT 1
        """).collect()
        
        if tc_result:
            fecha = tc_result[0][0]
            tipo_cambio = tc_result[0][1]
            return f"Tipo de cambio más reciente: ${tipo_cambio:.6f} MXN/USD al {fecha}"
        else:
            return "No se encontraron datos de tipo de cambio"
            
    except Exception as e:
        return f"ERROR: {str(e)}"
$$;

-- ============================================================================
-- Sección 5: Funciones Auxiliares
-- ============================================================================

-- Función para obtener el tipo de cambio de una fecha específica
CREATE OR REPLACE FUNCTION UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.FN_OBTENER_TIPO_CAMBIO(
    FECHA_CONSULTA DATE
)
RETURNS DECIMAL(10, 6)
COMMENT = 'Retorna el tipo de cambio de una fecha específica'
AS
$$
    SELECT TIPO_CAMBIO
    FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO
    WHERE FECHA = FECHA_CONSULTA
    AND SERIE = 'SF43718'
    ORDER BY FECHA_CONSULTA DESC
    LIMIT 1
$$;

-- Función para convertir USD a MXN
CREATE OR REPLACE FUNCTION UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.FN_CONVERTIR_USD_A_MXN(
    MONTO_USD DECIMAL(18, 2),
    FECHA_CONVERSION DATE
)
RETURNS DECIMAL(18, 2)
COMMENT = 'Convierte un monto en dólares a pesos mexicanos usando el tipo de cambio de la fecha'
AS
$$
    SELECT MONTO_USD * UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.FN_OBTENER_TIPO_CAMBIO(FECHA_CONVERSION)
$$;

-- Función para convertir MXN a USD
CREATE OR REPLACE FUNCTION UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.FN_CONVERTIR_MXN_A_USD(
    MONTO_MXN DECIMAL(18, 2),
    FECHA_CONVERSION DATE
)
RETURNS DECIMAL(18, 2)
COMMENT = 'Convierte un monto en pesos mexicanos a dólares usando el tipo de cambio de la fecha'
AS
$$
    SELECT MONTO_MXN / UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.FN_OBTENER_TIPO_CAMBIO(FECHA_CONVERSION)
$$;

-- ============================================================================
-- Sección 6: Vistas Útiles
-- ============================================================================

-- Vista con los tipos de cambio del último mes
CREATE OR REPLACE VIEW UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.VW_TIPO_CAMBIO_RECIENTE AS
SELECT 
    FECHA,
    TIPO_CAMBIO,
    TIPO_CAMBIO - LAG(TIPO_CAMBIO) OVER (ORDER BY FECHA) AS VARIACION_DIARIA,
    ROUND(
        ((TIPO_CAMBIO - LAG(TIPO_CAMBIO) OVER (ORDER BY FECHA)) / 
        LAG(TIPO_CAMBIO) OVER (ORDER BY FECHA)) * 100, 
        4
    ) AS VARIACION_PORCENTUAL,
    FECHA_CONSULTA,
    DATEDIFF(DAY, FECHA, CURRENT_DATE()) AS DIAS_ANTIGUO
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO
WHERE FECHA >= DATEADD(MONTH, -1, CURRENT_DATE())
ORDER BY FECHA DESC;

-- Vista con estadísticas mensuales
CREATE OR REPLACE VIEW UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.VW_TIPO_CAMBIO_ESTADISTICAS AS
SELECT 
    DATE_TRUNC('MONTH', FECHA) AS MES,
    COUNT(*) AS DIAS_CON_DATO,
    MIN(TIPO_CAMBIO) AS TC_MINIMO,
    MAX(TIPO_CAMBIO) AS TC_MAXIMO,
    AVG(TIPO_CAMBIO) AS TC_PROMEDIO,
    STDDEV(TIPO_CAMBIO) AS TC_DESVIACION_STD,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TIPO_CAMBIO) AS TC_MEDIANA
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO
GROUP BY DATE_TRUNC('MONTH', FECHA)
ORDER BY MES DESC;

-- ============================================================================
-- Sección 7: Ejemplos de Uso
-- ============================================================================

-- PASO 1: Configurar tu token de Banxico
-- Obtén un token gratuito en: https://www.banxico.org.mx/SieAPIRest/service/v1/token

/*
UPDATE UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONFIG_API_BANXICO
SET VALOR = 'tu_token_real_aqui',
    FECHA_ACTUALIZACION = CURRENT_TIMESTAMP()
WHERE PARAMETRO = 'TOKEN_API';
*/

-- PASO 2: Consultar tipos de cambio históricos (últimos 30 días)
/*
CALL UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.SP_CONSULTAR_TIPO_CAMBIO_BANXICO(
    '2025-10-01',  -- Fecha inicio
    '2025-10-30',  -- Fecha fin
    (SELECT VALOR FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONFIG_API_BANXICO WHERE PARAMETRO = 'TOKEN_API')
);
*/

-- PASO 3: Obtener tipo de cambio actual
/*
CALL UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.SP_OBTENER_TIPO_CAMBIO_ACTUAL();
*/

-- PASO 4: Consultar tipos de cambio almacenados
/*
SELECT 
    FECHA,
    TIPO_CAMBIO,
    CONCAT('$', TIPO_CAMBIO, ' MXN por USD') AS FORMATO_LEGIBLE,
    FECHA_CONSULTA
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO
ORDER BY FECHA DESC
LIMIT 10;
*/

-- PASO 5: Ver estadísticas recientes
/*
SELECT * FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.VW_TIPO_CAMBIO_RECIENTE;
*/

-- PASO 6: Usar funciones de conversión
/*
-- Convertir $1000 USD a MXN usando el tipo de cambio de hoy
SELECT UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.FN_CONVERTIR_USD_A_MXN(1000, CURRENT_DATE());

-- Convertir $20,000 MXN a USD
SELECT UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.FN_CONVERTIR_MXN_A_USD(20000, CURRENT_DATE());
*/

-- PASO 7: Ejemplo de uso con documentos
/*
-- Agregar tipo de cambio a recibos con montos en USD
SELECT 
    NOMBRE_ARCHIVO,
    MONTO_USD,
    FECHA_DOCUMENTO,
    UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.FN_OBTENER_TIPO_CAMBIO(FECHA_DOCUMENTO) AS TIPO_CAMBIO,
    UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.FN_CONVERTIR_USD_A_MXN(MONTO_USD, FECHA_DOCUMENTO) AS MONTO_MXN
FROM DOCUMENTOS_CON_USD;
*/

-- ============================================================================
-- Sección 8: Queries de Diagnóstico y Monitoreo
-- ============================================================================

-- Verificar última actualización
SELECT 
    'Último tipo de cambio' AS METRICA,
    MAX(FECHA)::VARCHAR AS VALOR,
    DATEDIFF(DAY, MAX(FECHA), CURRENT_DATE())::VARCHAR || ' días' AS ANTIGUEDAD
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO
UNION ALL
SELECT 
    'Total de registros',
    COUNT(*)::VARCHAR,
    ''
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO
UNION ALL
SELECT 
    'Rango de fechas',
    CONCAT(MIN(FECHA), ' a ', MAX(FECHA)),
    ''
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO;

-- Ver configuración actual
SELECT * FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.CONFIG_API_BANXICO;

-- Tendencia del tipo de cambio (últimos 7 días)
SELECT 
    FECHA,
    TIPO_CAMBIO,
    ROUND(AVG(TIPO_CAMBIO) OVER (ORDER BY FECHA ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 6) AS PROMEDIO_MOVIL_3D,
    CASE 
        WHEN TIPO_CAMBIO > LAG(TIPO_CAMBIO) OVER (ORDER BY FECHA) THEN '↑ Subió'
        WHEN TIPO_CAMBIO < LAG(TIPO_CAMBIO) OVER (ORDER BY FECHA) THEN '↓ Bajó'
        ELSE '= Igual'
    END AS TENDENCIA
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO
WHERE FECHA >= DATEADD(DAY, -7, CURRENT_DATE())
ORDER BY FECHA DESC;

-- Validar integridad de datos
SELECT 
    'Registros duplicados' AS VALIDACION,
    COUNT(*) AS CASOS
FROM (
    SELECT FECHA, SERIE, COUNT(*) as cnt
    FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO
    GROUP BY FECHA, SERIE
    HAVING COUNT(*) > 1
)
UNION ALL
SELECT 
    'Registros con tipo de cambio nulo',
    COUNT(*)
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO
WHERE TIPO_CAMBIO IS NULL
UNION ALL
SELECT 
    'Registros con tipo de cambio inválido (< 10 o > 30)',
    COUNT(*)
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO
WHERE TIPO_CAMBIO < 10 OR TIPO_CAMBIO > 30;

-- ============================================================================
-- Sección 9: Automatización (Tasks)
-- ============================================================================

-- Crear task para actualización diaria automática
/*
CREATE OR REPLACE TASK UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TASK_ACTUALIZAR_TIPO_CAMBIO
    WAREHOUSE = UNSTRUCTURED_DOCS_WH
    SCHEDULE = 'USING CRON 0 18 * * * America/Mexico_City'  -- 6 PM hora de México
    COMMENT = 'Actualiza el tipo de cambio diariamente a las 6 PM'
AS
    CALL UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.SP_OBTENER_TIPO_CAMBIO_ACTUAL();

-- Activar el task
ALTER TASK UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TASK_ACTUALIZAR_TIPO_CAMBIO RESUME;

-- Para pausar el task:
-- ALTER TASK UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TASK_ACTUALIZAR_TIPO_CAMBIO SUSPEND;

-- Ver estado del task:
SHOW TASKS LIKE 'TASK_ACTUALIZAR_TIPO_CAMBIO' IN SCHEMA UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT;
*/

-- ============================================================================
-- Sección 10: FinOps - Gestión de Costos
-- ============================================================================

-- Verificar uso del warehouse
SHOW PARAMETERS LIKE 'STATEMENT_TIMEOUT_IN_SECONDS' IN WAREHOUSE UNSTRUCTURED_DOCS_WH;

-- Estimar costo de consultas a la API
SELECT 
    'Llamadas mensuales estimadas' AS METRICA,
    '~30 (1 por día)' AS VALOR,
    'API de Banxico es gratuita' AS COSTO
UNION ALL
SELECT 
    'Almacenamiento (por 1 año)',
    CONCAT(COUNT(*) * 100, ' bytes aprox'),
    'Despreciable (< 1 MB)'
FROM UNSTRUCTURED_DOCS_DB.DOCUMENTOS_SAT.TIPO_CAMBIO_BANXICO;

-- ============================================================================
-- NOTAS FINALES
-- ============================================================================

-- 1. IMPORTANTE: Obtén tu token gratuito de Banxico:
--    https://www.banxico.org.mx/SieAPIRest/service/v1/token

-- 2. La API de Banxico tiene límite de 1000 peticiones por día (más que suficiente)

-- 3. El tipo de cambio FIX se publica después de las 12:00 del día siguiente

-- 4. Para producción, considera:
--    - Implementar retry logic en caso de errores de API
--    - Agregar logging más detallado
--    - Crear alertas si el tipo de cambio no se actualiza

-- 5. Referencia oficial de la API:
--    https://www.banxico.org.mx/SieAPIRest/service/v1/doc/introduccion

-- ============================================================================
-- RECURSOS ADICIONALES
-- ============================================================================

-- Series adicionales disponibles en Banxico:
-- SF43718 - Tipo de Cambio FIX (Pesos por Dólar)
-- SF46410 - Tipo de Cambio Promedio (Pesos por Dólar)
-- SF60632 - TIIE 28 días
-- SF43783 - Tasa de fondeo bancario
-- 
-- Documentación completa:
-- https://www.banxico.org.mx/SieAPIRest/service/v1/doc/catalogoSeries

-- ============================================================================



