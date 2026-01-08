/*******************************************************************************
 * DEMO AGILCREDIT - EXTRACCIÓN DE DATOS NO ESTRUCTURADOS
 * 
 * Script para procesar archivos JSON y XML usando SNOWFLAKE.CORTEX.PARSE_DOCUMENT
 * 
 * Archivos a procesar:
 * - JSON: perfiles_clientes_detallados.json, transacciones_logs.json
 * - XML: reporte_riesgo_cartera.xml, reporte_cnbv_operaciones_inusuales.xml
 * 
 * Autor: AgilCredit Data Engineering Team
 * Fecha: Octubre 2025
 *******************************************************************************/

-- =============================================================================
-- SECCIÓN 1: CONFIGURACIÓN INICIAL
-- =============================================================================

USE DATABASE AGILCREDIT_DEMO;
USE SCHEMA CORE;
USE WAREHOUSE COMPUTE_WH;

-- =============================================================================
-- SECCIÓN 2: CREAR STAGE PARA ARCHIVOS NO ESTRUCTURADOS
-- =============================================================================

-- Crear FILE FORMAT para JSON arrays
CREATE OR REPLACE FILE FORMAT JSON_ARRAY_FORMAT
    TYPE = JSON
    STRIP_OUTER_ARRAY = TRUE
    COMMENT = 'Formato para leer archivos JSON que son arrays';

-- Crear FILE FORMAT para XML
CREATE OR REPLACE FILE FORMAT XML_FORMAT
    TYPE = XML
    COMMENT = 'Formato para leer archivos XML';

-- Crear stage interno para almacenar archivos
CREATE OR REPLACE STAGE AGILCREDIT_UNSTRUCTURED_DATA
    FILE_FORMAT = JSON_ARRAY_FORMAT
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage para archivos no estructurados (JSON, XML) de AgilCredit';

-- Ver el stage creado
SHOW STAGES LIKE 'AGILCREDIT_UNSTRUCTURED_DATA';
SHOW FILE FORMATS LIKE '%FORMAT';

-- =============================================================================
-- SECCIÓN 3: SUBIR ARCHIVOS AL STAGE
-- =============================================================================

/*
INSTRUCCIONES PARA SUBIR ARCHIVOS:

Opción 1 - Desde SnowSQL:
--------------------------
snowsql -c tu_conexion
USE DATABASE AGILCREDIT_DEMO;
USE SCHEMA CORE;

PUT file://./datos_no_estructurados/json/*.json @AGILCREDIT_UNSTRUCTURED_DATA/json/ AUTO_COMPRESS=FALSE;
PUT file://./datos_no_estructurados/xml/*.xml @AGILCREDIT_UNSTRUCTURED_DATA/xml/ AUTO_COMPRESS=FALSE;

Opción 2 - Desde Snowsight (UI):
---------------------------------
1. Data → Databases → AGILCREDIT_DEMO → CORE → Stages
2. Click en AGILCREDIT_UNSTRUCTURED_DATA
3. Click "+ Files" → Subir los archivos
4. Crear carpetas: json/ y xml/

Opción 3 - Desde Python/Connector:
-----------------------------------
cursor.execute("PUT file://./datos_no_estructurados/json/perfiles_clientes_detallados.json @AGILCREDIT_UNSTRUCTURED_DATA/json/")
*/

-- Verificar archivos subidos
LIST @AGILCREDIT_UNSTRUCTURED_DATA;

-- =============================================================================
-- SECCIÓN 4: PROCESAR ARCHIVOS JSON CON PARSE_DOCUMENT
-- =============================================================================

-- 4.1 Ver contenido RAW del JSON
-- Nota: Con STRIP_OUTER_ARRAY = TRUE, cada elemento del array es una fila
SELECT 
    METADATA$FILENAME as archivo,
    METADATA$FILE_ROW_NUMBER as fila,
    $1 as contenido_raw
FROM @AGILCREDIT_UNSTRUCTURED_DATA/json/perfiles_clientes_detallados.json
    (FILE_FORMAT => JSON_ARRAY_FORMAT)
LIMIT 5;

-- 4.2 Parsear JSON directamente (ya no necesitas PARSE_JSON porque $1 ya es VARIANT)
SELECT 
    METADATA$FILENAME as archivo,
    $1 as documento_parseado,
    $1:cliente_id::STRING as cliente_id_ejemplo
FROM @AGILCREDIT_UNSTRUCTURED_DATA/json/perfiles_clientes_detallados.json
    (FILE_FORMAT => JSON_ARRAY_FORMAT)
LIMIT 3;

-- 4.3 Extraer datos estructurados del JSON - Perfiles de Clientes
-- NOTA: Las rutas deben coincidir EXACTAMENTE con la estructura del JSON
CREATE OR REPLACE VIEW CORE.V_PERFILES_CLIENTES_JSON AS
SELECT 
    -- Identificación
    $1:cliente_id::STRING as CLIENTE_ID,
    
    -- Datos Personales
    $1:perfil_completo.datos_personales.nombre_completo::STRING as NOMBRE_COMPLETO,
    $1:perfil_completo.datos_personales.fecha_nacimiento::DATE as FECHA_NACIMIENTO,
    $1:perfil_completo.datos_personales.edad::INT as EDAD,
    $1:perfil_completo.datos_personales.genero::STRING as GENERO,
    $1:perfil_completo.datos_personales.estado_civil::STRING as ESTADO_CIVIL,
    $1:perfil_completo.datos_personales.dependientes_economicos::INT as DEPENDIENTES,
    $1:perfil_completo.datos_personales.nivel_educacion::STRING as EDUCACION,
    $1:perfil_completo.datos_personales.idiomas::ARRAY as IDIOMAS,
    
    -- Contacto
    $1:perfil_completo.contacto.email_principal::STRING as EMAIL,
    $1:perfil_completo.contacto.telefono_movil::STRING as TELEFONO,
    $1:perfil_completo.contacto.preferencia_contacto::STRING as PREFERENCIA_CONTACTO,
    
    -- Domicilio
    $1:perfil_completo.domicilio.calle::STRING as CALLE,
    $1:perfil_completo.domicilio.numero_exterior::STRING as NUM_EXTERIOR,
    $1:perfil_completo.domicilio.colonia::STRING as COLONIA,
    $1:perfil_completo.domicilio.codigo_postal::STRING as CP,
    $1:perfil_completo.domicilio.municipio::STRING as MUNICIPIO,
    $1:perfil_completo.domicilio.estado::STRING as ESTADO,
    $1:perfil_completo.domicilio.antiguedad_domicilio_años::FLOAT as ANTIGUEDAD_DOMICILIO,
    $1:perfil_completo.domicilio.tipo_vivienda::STRING as TIPO_VIVIENDA,
    
    -- Datos Laborales (CORREGIDO: era "empleo" pero el JSON tiene "datos_laborales")
    $1:perfil_completo.datos_laborales.empresa::STRING as EMPRESA,
    $1:perfil_completo.datos_laborales.puesto::STRING as PUESTO,
    $1:perfil_completo.datos_laborales.situacion_laboral::STRING as SITUACION_LABORAL,
    $1:perfil_completo.datos_laborales.tipo_contrato::STRING as TIPO_CONTRATO,
    $1:perfil_completo.datos_laborales.antiguedad_años::FLOAT as ANTIGUEDAD_LABORAL,
    $1:perfil_completo.datos_laborales.ingreso_mensual_bruto::FLOAT as INGRESO_BRUTO,
    $1:perfil_completo.datos_laborales.ingreso_mensual_neto::FLOAT as INGRESO_NETO,
    
    -- Ingresos Adicionales
    $1:perfil_completo.datos_laborales.ingresos_adicionales.bonos_anuales::FLOAT as BONOS_ANUALES,
    $1:perfil_completo.datos_laborales.ingresos_adicionales.rentas::FLOAT as INGRESOS_RENTAS,
    $1:perfil_completo.datos_laborales.ingresos_adicionales.negocios_propios::FLOAT as INGRESOS_NEGOCIOS,
    
    -- Historial Crediticio - Buró
    $1:perfil_completo.historial_crediticio.buro_credito.calificacion::INT as CALIFICACION_BURO,
    $1:perfil_completo.historial_crediticio.buro_credito.num_consultas_12_meses::INT as CONSULTAS_BURO,
    $1:perfil_completo.historial_crediticio.buro_credito.creditos_actuales::INT as CREDITOS_EXTERNOS_ACTIVOS,
    $1:perfil_completo.historial_crediticio.buro_credito.cuentas_morosas::INT as CUENTAS_MOROSAS,
    $1:perfil_completo.historial_crediticio.comportamiento_pago.score_pago::FLOAT as SCORE_PAGO,
    $1:perfil_completo.historial_crediticio.comportamiento_pago.pagos_puntuales_consecutivos::INT as PAGOS_PUNTUALES,
    
    -- Perfil de Riesgo (AQUÍ ESTÁ EL SCORE INTERNO!)
    $1:perfil_completo.perfil_riesgo.score_interno_agilcredit::FLOAT as SCORE_AGILCREDIT,
    $1:perfil_completo.perfil_riesgo.clasificacion_riesgo::STRING as CLASIFICACION_RIESGO,
    $1:perfil_completo.perfil_riesgo.segmento_cliente::STRING as SEGMENTO_CLIENTE,
    $1:perfil_completo.perfil_riesgo.probabilidad_incumplimiento::FLOAT as PROB_INCUMPLIMIENTO,
    $1:perfil_completo.perfil_riesgo.limite_credito_sugerido::FLOAT as LIMITE_CREDITO_SUGERIDO,
    $1:perfil_completo.perfil_riesgo.tasa_interes_sugerida::FLOAT as TASA_INTERES_SUGERIDA,
    
    -- Scoring ML
    $1:perfil_completo.scoring_ml.ltv_estimado::FLOAT as LTV_ESTIMADO,
    $1:perfil_completo.scoring_ml.churn_probability::FLOAT as PROB_CHURN,
    $1:perfil_completo.scoring_ml.cross_sell_score::FLOAT as CROSS_SELL_SCORE,
    $1:perfil_completo.scoring_ml.productos_recomendados::ARRAY as PRODUCTOS_RECOMENDADOS,
    
    -- Información Financiera - Ahorros e Inversiones
    $1:perfil_completo.informacion_financiera.ahorro_inversion.cuenta_ahorro::FLOAT as AHORRO,
    $1:perfil_completo.informacion_financiera.ahorro_inversion.afore::FLOAT as AFORE,
    $1:perfil_completo.informacion_financiera.ahorro_inversion.inversiones::FLOAT as INVERSIONES
    
FROM @AGILCREDIT_UNSTRUCTURED_DATA/json/perfiles_clientes_detallados.json
    (FILE_FORMAT => JSON_ARRAY_FORMAT);

-- Query de prueba
SELECT * FROM CORE.V_PERFILES_CLIENTES_JSON LIMIT 10;

-- 4.4 Análisis: Clientes con mayor ingreso y mejor perfil de riesgo
SELECT 
    CLIENTE_ID,
    NOMBRE_COMPLETO,
    INGRESO_NETO,
    INGRESO_BRUTO,
    SCORE_AGILCREDIT,
    CALIFICACION_BURO,
    CLASIFICACION_RIESGO,
    SEGMENTO_CLIENTE,
    LTV_ESTIMADO,
    EMAIL,
    TELEFONO
FROM CORE.V_PERFILES_CLIENTES_JSON
WHERE INGRESO_NETO > 30000
  AND SCORE_AGILCREDIT > 75
ORDER BY SCORE_AGILCREDIT DESC, INGRESO_NETO DESC
LIMIT 20;

-- 4.5 Análisis: Distribución de clientes por segmento y clasificación de riesgo
SELECT 
    SEGMENTO_CLIENTE,
    CLASIFICACION_RIESGO,
    COUNT(*) as NUM_CLIENTES,
    ROUND(AVG(INGRESO_NETO), 2) as INGRESO_PROMEDIO,
    ROUND(AVG(SCORE_AGILCREDIT), 2) as SCORE_PROMEDIO,
    ROUND(AVG(CALIFICACION_BURO), 2) as BURO_PROMEDIO,
    ROUND(AVG(LTV_ESTIMADO), 2) as LTV_PROMEDIO
FROM CORE.V_PERFILES_CLIENTES_JSON
GROUP BY SEGMENTO_CLIENTE, CLASIFICACION_RIESGO
ORDER BY NUM_CLIENTES DESC;

-- =============================================================================
-- SECCIÓN 5: PROCESAR ARCHIVOS XML CON PARSE_DOCUMENT
-- =============================================================================

-- 5.1 Ver contenido RAW del XML
SELECT 
    METADATA$FILENAME as archivo,
    $1 as contenido_raw
FROM @AGILCREDIT_UNSTRUCTURED_DATA/xml/reporte_riesgo_cartera.xml
    (FILE_FORMAT => XML_FORMAT)
LIMIT 1;

-- 5.2 Parsear XML - Reporte de Riesgo de Cartera
-- Con FILE_FORMAT => XML_FORMAT, $1 ya es un VARIANT parseado
CREATE OR REPLACE VIEW CORE.V_REPORTE_RIESGO_XML AS
WITH parsed_xml AS (
    SELECT 
        $1 as parsed_doc
    FROM @AGILCREDIT_UNSTRUCTURED_DATA/xml/reporte_riesgo_cartera.xml
        (FILE_FORMAT => XML_FORMAT)
)
SELECT 
    -- Metadata del Reporte
    XMLGET(parsed_doc, 'ReporteRiesgoCartera'):"@" as metadata_raw,
    GET(XMLGET(parsed_doc, 'MetadataReporte'), '$')::STRING as metadata_completa,
    GET(XMLGET(XMLGET(parsed_doc, 'MetadataReporte'), 'TituloReporte'), '$')::STRING as TITULO_REPORTE,
    GET(XMLGET(XMLGET(parsed_doc, 'MetadataReporte'), 'FechaGeneracion'), '$')::DATE as FECHA_GENERACION,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'MetadataReporte'), 'PeriodoAnalisis'), 'Inicio'), '$')::DATE as PERIODO_INICIO,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'MetadataReporte'), 'PeriodoAnalisis'), 'Fin'), '$')::DATE as PERIODO_FIN,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'MetadataReporte'), 'Responsable'), 'Nombre'), '$')::STRING as RESPONSABLE_NOMBRE,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'MetadataReporte'), 'Responsable'), 'Cargo'), '$')::STRING as RESPONSABLE_CARGO,
    
    -- Resumen Ejecutivo - Cartera Total
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'ResumenEjecutivo'), 'CarteraTotal'), 'MontoTotal'), '$')::FLOAT as CARTERA_MONTO_TOTAL,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'ResumenEjecutivo'), 'CarteraTotal'), 'NumeroCreditos'), '$')::INT as CARTERA_NUM_CREDITOS,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'ResumenEjecutivo'), 'CarteraTotal'), 'NumeroClientes'), '$')::INT as CARTERA_NUM_CLIENTES,
    
    -- Indicadores de Riesgo
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'ResumenEjecutivo'), 'IndicadoresRiesgo'), 'IMOR'), '$')::FLOAT as IMOR,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'ResumenEjecutivo'), 'IndicadoresRiesgo'), 'IMORAmpliado'), '$')::FLOAT as IMOR_AMPLIADO,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'ResumenEjecutivo'), 'IndicadoresRiesgo'), 'CarteraVencida'), '$')::FLOAT as CARTERA_VENCIDA,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'ResumenEjecutivo'), 'IndicadoresRiesgo'), 'ReservaPreventivaRequerida'), '$')::FLOAT as RESERVA_REQUERIDA,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'ResumenEjecutivo'), 'IndicadoresRiesgo'), 'ReservaConstituida'), '$')::FLOAT as RESERVA_CONSTITUIDA,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'ResumenEjecutivo'), 'IndicadoresRiesgo'), 'CoberturaMorosidad'), '$')::FLOAT as COBERTURA_MOROSIDAD,
    
    -- XML completo para referencia
    parsed_doc as XML_COMPLETO
    
FROM parsed_xml;

-- Query de prueba
SELECT 
    TITULO_REPORTE,
    FECHA_GENERACION,
    PERIODO_INICIO,
    PERIODO_FIN,
    RESPONSABLE_NOMBRE,
    CARTERA_MONTO_TOTAL,
    CARTERA_NUM_CREDITOS,
    IMOR,
    CARTERA_VENCIDA,
    COBERTURA_MOROSIDAD
FROM CORE.V_REPORTE_RIESGO_XML;

-- 5.3 Extraer detalle de cartera por calificación (del XML anidado)
-- Nota: Esto requiere acceder a elementos repetidos dentro del XML
SELECT 
    GET(XMLGET(XMLGET($1, 'MetadataReporte'), 'FechaGeneracion'), '$')::DATE as FECHA_REPORTE,
    GET(calificacion.value, '$')::STRING as DATOS_CALIFICACION
FROM 
    @AGILCREDIT_UNSTRUCTURED_DATA/xml/reporte_riesgo_cartera.xml
        (FILE_FORMAT => XML_FORMAT),
    LATERAL FLATTEN(input => $1, path => 'ReporteRiesgoCartera.CarteraPorCalificacion.Calificacion') calificacion
LIMIT 10;

-- =============================================================================
-- SECCIÓN 6: PROCESAR LOGS DE TRANSACCIONES (JSON Array)
-- =============================================================================

-- 6.1 Extraer transacciones individuales del JSON array
CREATE OR REPLACE VIEW CORE.V_TRANSACCIONES_LOGS_JSON AS
WITH parsed_logs AS (
    SELECT 
        $1 as transaccion
    FROM @AGILCREDIT_UNSTRUCTURED_DATA/json/transacciones_logs.json
        (FILE_FORMAT => JSON_ARRAY_FORMAT)
)
SELECT 
    transaccion:transaction_id::STRING as TRANSACTION_ID,
    transaccion:credito_id::STRING as CREDITO_ID,
    transaccion:cliente_id::STRING as CLIENTE_ID,
    transaccion:timestamp::TIMESTAMP_NTZ as TIMESTAMP,
    transaccion:tipo_transaccion::STRING as TIPO_TRANSACCION,
    transaccion:monto::FLOAT as MONTO,
    transaccion:metodo_pago::STRING as METODO_PAGO,
    transaccion:referencia::STRING as REFERENCIA,
    transaccion:estatus::STRING as ESTATUS,
    transaccion:ip_address::STRING as IP_ADDRESS,
    transaccion:device_info.type::STRING as DEVICE_TYPE,
    transaccion:device_info.os::STRING as DEVICE_OS,
    transaccion:device_info.browser::STRING as DEVICE_BROWSER,
    transaccion:location.latitude::FLOAT as LATITUD,
    transaccion:location.longitude::FLOAT as LONGITUD,
    transaccion:location.city::STRING as CIUDAD,
    transaccion:location.state::STRING as ESTADO,
    transaccion:processing_details.duration_ms::INT as DURACION_MS,
    transaccion:processing_details.retry_count::INT as RETRY_COUNT,
    transaccion:fraud_check.score::FLOAT as FRAUD_SCORE,
    transaccion:fraud_check.flags::ARRAY as FRAUD_FLAGS,
    transaccion:fraud_check.risk_level::STRING as FRAUD_RISK_LEVEL
FROM parsed_logs;

-- Query de prueba
SELECT * FROM CORE.V_TRANSACCIONES_LOGS_JSON LIMIT 20;

-- 6.2 Análisis: Transacciones con alto score de fraude
SELECT 
    TRANSACTION_ID,
    CLIENTE_ID,
    TIMESTAMP,
    TIPO_TRANSACCION,
    MONTO,
    FRAUD_SCORE,
    FRAUD_RISK_LEVEL,
    FRAUD_FLAGS,
    IP_ADDRESS,
    DEVICE_TYPE,
    CIUDAD,
    ESTADO
FROM CORE.V_TRANSACCIONES_LOGS_JSON
WHERE FRAUD_SCORE > 70
ORDER BY FRAUD_SCORE DESC, TIMESTAMP DESC
LIMIT 50;

-- 6.3 Análisis: Distribución de transacciones por dispositivo
SELECT 
    DEVICE_TYPE,
    DEVICE_OS,
    COUNT(*) as NUM_TRANSACCIONES,
    ROUND(SUM(MONTO), 2) as MONTO_TOTAL,
    ROUND(AVG(MONTO), 2) as MONTO_PROMEDIO,
    ROUND(AVG(FRAUD_SCORE), 2) as FRAUD_SCORE_PROMEDIO
FROM CORE.V_TRANSACCIONES_LOGS_JSON
GROUP BY DEVICE_TYPE, DEVICE_OS
ORDER BY NUM_TRANSACCIONES DESC;

-- =============================================================================
-- SECCIÓN 7: PROCESAR REPORTE CNBV (XML Regulatorio)
-- =============================================================================

-- 7.1 Crear vista del reporte CNBV
CREATE OR REPLACE VIEW COMPLIANCE.V_REPORTE_CNBV_XML AS
WITH parsed_xml AS (
    SELECT 
        $1 as parsed_doc
    FROM @AGILCREDIT_UNSTRUCTURED_DATA/xml/reporte_cnbv_operaciones_inusuales.xml
        (FILE_FORMAT => XML_FORMAT)
)
SELECT 
    -- Metadata
    GET(XMLGET(XMLGET(parsed_doc, 'MetadataReporte'), 'NumeroReporte'), '$')::STRING as NUMERO_REPORTE,
    GET(XMLGET(XMLGET(parsed_doc, 'MetadataReporte'), 'TipoReporte'), '$')::STRING as TIPO_REPORTE,
    GET(XMLGET(XMLGET(parsed_doc, 'MetadataReporte'), 'FechaPresentacion'), '$')::DATE as FECHA_PRESENTACION,
    GET(XMLGET(XMLGET(parsed_doc, 'MetadataReporte'), 'PeriodoReporte'), '$')::STRING as PERIODO_REPORTE,
    
    -- Institución
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'InstitucionReportante'), 'DatosInstitucion'), 'RazonSocial'), '$')::STRING as RAZON_SOCIAL,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'InstitucionReportante'), 'DatosInstitucion'), 'RFC'), '$')::STRING as RFC_INSTITUCION,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'InstitucionReportante'), 'DatosInstitucion'), 'ClaveINEGI'), '$')::STRING as CLAVE_INEGI,
    
    -- Responsable
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'InstitucionReportante'), 'Responsable'), 'Nombre'), '$')::STRING as RESPONSABLE_NOMBRE,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'InstitucionReportante'), 'Responsable'), 'Cargo'), '$')::STRING as RESPONSABLE_CARGO,
    GET(XMLGET(XMLGET(XMLGET(parsed_doc, 'InstitucionReportante'), 'Responsable'), 'Email'), '$')::STRING as RESPONSABLE_EMAIL,
    
    -- Resumen
    GET(XMLGET(XMLGET(parsed_doc, 'ResumenEjecutivo'), 'TotalOperacionesReportadas'), '$')::INT as TOTAL_OPERACIONES,
    GET(XMLGET(XMLGET(parsed_doc, 'ResumenEjecutivo'), 'MontoTotalOperaciones'), '$')::FLOAT as MONTO_TOTAL_OPERACIONES,
    GET(XMLGET(XMLGET(parsed_doc, 'ResumenEjecutivo'), 'ClientesInvolucrados'), '$')::INT as CLIENTES_INVOLUCRADOS,
    
    -- XML completo
    parsed_doc as XML_COMPLETO
    
FROM parsed_xml;

-- Query de prueba
SELECT * FROM COMPLIANCE.V_REPORTE_CNBV_XML;

-- =============================================================================
-- SECCIÓN 8: INTEGRACIÓN CON DATOS ESTRUCTURADOS
-- =============================================================================

-- 8.1 Comparar datos estructurados vs JSON
SELECT 
    c.CLIENTE_ID,
    c.NOMBRE_COMPLETO as NOMBRE_TABLA,
    j.NOMBRE_COMPLETO as NOMBRE_JSON,
    c.INGRESO_MENSUAL as INGRESO_TABLA,
    j.INGRESO_NETO as INGRESO_JSON,
    c.SCORE_RIESGO as SCORE_TABLA,
    j.SCORE_AGILCREDIT as SCORE_JSON,
    c.SEGMENTO_CLIENTE as SEGMENTO_TABLA,
    j.SEGMENTO_CLIENTE as SEGMENTO_JSON
FROM CORE.CLIENTES c
INNER JOIN CORE.V_PERFILES_CLIENTES_JSON j 
    ON c.CLIENTE_ID = j.CLIENTE_ID
LIMIT 20;

-- 8.2 Enriquecer clientes con información adicional del JSON
CREATE OR REPLACE VIEW ANALYTICS.V_CLIENTES_ENRIQUECIDOS AS
SELECT 
    c.*,
    j.DEPENDIENTES,
    j.TIPO_VIVIENDA,
    j.ANTIGUEDAD_DOMICILIO,
    j.EMPRESA,
    j.PUESTO,
    j.SITUACION_LABORAL,
    j.TIPO_CONTRATO,
    j.ANTIGUEDAD_LABORAL,
    j.INGRESO_BRUTO,
    j.INGRESO_NETO,
    j.BONOS_ANUALES,
    j.INGRESOS_RENTAS,
    j.INGRESOS_NEGOCIOS,
    j.CREDITOS_EXTERNOS_ACTIVOS,
    j.CUENTAS_MOROSAS,
    j.CONSULTAS_BURO,
    j.SCORE_PAGO,
    j.CLASIFICACION_RIESGO,
    j.PROB_INCUMPLIMIENTO,
    j.LIMITE_CREDITO_SUGERIDO,
    j.TASA_INTERES_SUGERIDA,
    j.PROB_CHURN,
    j.CROSS_SELL_SCORE,
    j.LTV_ESTIMADO as LTV_JSON,
    j.AHORRO,
    j.AFORE,
    j.INVERSIONES
FROM CORE.CLIENTES c
LEFT JOIN CORE.V_PERFILES_CLIENTES_JSON j 
    ON c.CLIENTE_ID = j.CLIENTE_ID;

-- 8.3 Cruzar transacciones logs con alertas de fraude
SELECT 
    t.TRANSACTION_ID,
    t.CLIENTE_ID,
    t.CREDITO_ID,
    t.TIMESTAMP,
    t.TIPO_TRANSACCION,
    t.MONTO,
    t.FRAUD_SCORE as SCORE_LOG,
    t.FRAUD_RISK_LEVEL as RISK_LOG,
    a.ALERTA_ID,
    a.SCORE_FRAUDE as SCORE_ALERTA,
    a.NIVEL_RIESGO as RISK_ALERTA,
    a.DESCRIPCION,
    a.ESTATUS_ALERTA
FROM CORE.V_TRANSACCIONES_LOGS_JSON t
INNER JOIN CORE.TRANSACCIONES trans
    ON t.TRANSACTION_ID = trans.REFERENCIA
INNER JOIN CORE.ALERTAS_FRAUDE a
    ON trans.TRANSACCION_ID = a.TRANSACCION_ID
WHERE t.FRAUD_SCORE > 50
ORDER BY t.FRAUD_SCORE DESC
LIMIT 50;

-- =============================================================================
-- SECCIÓN 9: QUERIES DE ANÁLISIS AVANZADO
-- =============================================================================

-- 9.1 Clientes de alto valor con datos enriquecidos
SELECT 
    e.CLIENTE_ID,
    e.NOMBRE_COMPLETO,
    e.SEGMENTO_CLIENTE,
    e.INGRESO_MENSUAL as INGRESO_TABLA,
    e.INGRESO_NETO as INGRESO_JSON,
    e.SCORE_RIESGO,
    e.CLASIFICACION_RIESGO,
    e.EMPRESA,
    e.PUESTO,
    e.ANTIGUEDAD_LABORAL,
    e.LTV_JSON,
    e.PROB_CHURN,
    e.CROSS_SELL_SCORE,
    COUNT(cr.CREDITO_ID) as NUM_CREDITOS,
    ROUND(SUM(cr.SALDO_ACTUAL), 2) as EXPOSICION_TOTAL
FROM ANALYTICS.V_CLIENTES_ENRIQUECIDOS e
LEFT JOIN CORE.CREDITOS cr ON e.CLIENTE_ID = cr.CLIENTE_ID
WHERE e.INGRESO_NETO > 30000
  AND e.PROB_CHURN < 30  -- Probabilidad en porcentaje
  AND e.CLASIFICACION_RIESGO IN ('Bajo', 'Medio')
GROUP BY 
    e.CLIENTE_ID, e.NOMBRE_COMPLETO, e.SEGMENTO_CLIENTE, 
    e.INGRESO_MENSUAL, e.INGRESO_NETO, e.SCORE_RIESGO, e.CLASIFICACION_RIESGO,
    e.EMPRESA, e.PUESTO, e.ANTIGUEDAD_LABORAL, e.LTV_JSON,
    e.PROB_CHURN, e.CROSS_SELL_SCORE
ORDER BY EXPOSICION_TOTAL DESC
LIMIT 30;

-- 9.2 Comparativa de indicadores: XML vs datos transaccionales
SELECT 
    'Reporte XML' as FUENTE,
    x.CARTERA_MONTO_TOTAL as CARTERA_TOTAL,
    x.CARTERA_NUM_CREDITOS as NUM_CREDITOS,
    x.IMOR as TASA_MOROSIDAD,
    x.CARTERA_VENCIDA as CARTERA_VENCIDA
FROM CORE.V_REPORTE_RIESGO_XML x

UNION ALL

SELECT 
    'Datos Transaccionales' as FUENTE,
    ROUND(SUM(SALDO_ACTUAL), 2) as CARTERA_TOTAL,
    COUNT(*) as NUM_CREDITOS,
    ROUND(
        SUM(CASE WHEN ESTATUS_CREDITO IN ('MORA', 'VENCIDO') THEN SALDO_ACTUAL ELSE 0 END) * 100.0 
        / NULLIF(SUM(SALDO_ACTUAL), 0), 
        2
    ) as TASA_MOROSIDAD,
    ROUND(SUM(CASE WHEN ESTATUS_CREDITO IN ('MORA', 'VENCIDO') THEN SALDO_ACTUAL ELSE 0 END), 2) as CARTERA_VENCIDA
FROM CORE.CREDITOS
WHERE ESTATUS_CREDITO IN ('VIGENTE', 'MORA', 'VENCIDO');

-- 9.3 Análisis de patrones de fraude por ubicación geográfica
SELECT 
    t.ESTADO,
    t.CIUDAD,
    COUNT(*) as NUM_TRANSACCIONES,
    ROUND(SUM(t.MONTO), 2) as MONTO_TOTAL,
    ROUND(AVG(t.FRAUD_SCORE), 2) as FRAUD_SCORE_PROMEDIO,
    SUM(CASE WHEN t.FRAUD_RISK_LEVEL = 'ALTO' THEN 1 ELSE 0 END) as TRANSACCIONES_ALTO_RIESGO,
    ROUND(
        SUM(CASE WHEN t.FRAUD_RISK_LEVEL = 'ALTO' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) as PCT_ALTO_RIESGO
FROM CORE.V_TRANSACCIONES_LOGS_JSON t
GROUP BY t.ESTADO, t.CIUDAD
HAVING COUNT(*) >= 5
ORDER BY PCT_ALTO_RIESGO DESC, FRAUD_SCORE_PROMEDIO DESC
LIMIT 20;

-- =============================================================================
-- SECCIÓN 10: EXPORTAR DATOS PARSEADOS A TABLAS PERMANENTES (OPCIONAL)
-- =============================================================================

-- 10.1 Materializar vista de perfiles como tabla
CREATE OR REPLACE TABLE CORE.PERFILES_CLIENTES_JSON AS
SELECT * FROM CORE.V_PERFILES_CLIENTES_JSON;

-- 10.2 Materializar logs de transacciones
CREATE OR REPLACE TABLE CORE.TRANSACCIONES_LOGS_JSON AS
SELECT * FROM CORE.V_TRANSACCIONES_LOGS_JSON;

-- Verificar conteos
SELECT 'PERFILES_JSON' as TABLA, COUNT(*) as REGISTROS FROM CORE.PERFILES_CLIENTES_JSON
UNION ALL
SELECT 'TRANSACCIONES_LOGS_JSON', COUNT(*) FROM CORE.TRANSACCIONES_LOGS_JSON;

-- =============================================================================
-- FIN DEL SCRIPT
-- =============================================================================

/*
RESUMEN DE FUNCIONES Y FILE FORMATS UTILIZADOS:
================================================

FILE FORMATS:
-------------
1. JSON_ARRAY_FORMAT (TYPE=JSON, STRIP_OUTER_ARRAY=TRUE)
   - Para archivos JSON que son arrays: [{...}, {...}]
   - Convierte cada elemento del array en una fila
   - $1 ya es un VARIANT parseado, NO necesitas PARSE_JSON()

2. XML_FORMAT (TYPE=XML)
   - Para archivos XML
   - $1 ya es un VARIANT parseado, NO necesitas PARSE_XML()

FUNCIONES DE EXTRACCIÓN:
------------------------
1. Para JSON:
   - $1:ruta.al.campo::TIPO - Notación de punto para extraer valores
   - LATERAL FLATTEN(input => $1:array_field) - Para expandir arrays anidados

2. Para XML:
   - XMLGET(xml, 'ElementoNombre') - Extraer elemento XML por nombre
   - GET(elemento, '$') - Extraer el valor de texto del elemento
   - ::STRING, ::INT, ::FLOAT, ::DATE - Casting explícito de tipos

IMPORTANTE:
-----------
❌ NO uses: PARSE_JSON($1) o PARSE_XML($1)
✅ USA: FILE_FORMAT => (JSON_ARRAY_FORMAT o XML_FORMAT)
   Cuando usas el FILE FORMAT correcto, $1 ya es un VARIANT parseado!

PRÓXIMOS PASOS:
===============
1. Subir los archivos al stage con PUT o Snowsight UI
2. Ejecutar sección 2 para crear FILE FORMATs y Stage
3. Ejecutar secciones 4-7 para crear las vistas
4. Explorar los datos con las queries de análisis
5. Integrar con el modelo semántico si es necesario
*/

