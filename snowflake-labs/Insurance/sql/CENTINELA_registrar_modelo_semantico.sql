-- ============================================================================
-- SEGUROS CENTINELA - REGISTRO DE MODELO SEMÁNTICO
-- ============================================================================
-- Descripción: Script para registrar el modelo semántico en Snowflake
-- Para uso con Cortex Analyst
-- ============================================================================

USE DATABASE CENTINELA_DB;
USE WAREHOUSE CENTINELA_WH;

-- ============================================================================
-- PASO 1: Crear stage para almacenar el modelo semántico
-- ============================================================================

CREATE OR REPLACE STAGE CENTINELA_DB.CORE.SEMANTIC_MODEL_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage para almacenar modelos semánticos de Cortex Analyst';

-- ============================================================================
-- PASO 2: Subir el archivo YAML al stage
-- ============================================================================
-- Ejecutar desde SnowSQL o Snowsight:
-- PUT file:///ruta/al/archivo/centinela_semantic_model.yaml @CENTINELA_DB.CORE.SEMANTIC_MODEL_STAGE;

-- O desde la interfaz web, subir el archivo al stage manualmente

-- ============================================================================
-- PASO 3: Verificar que el archivo se subió correctamente
-- ============================================================================

LIST @CENTINELA_DB.CORE.SEMANTIC_MODEL_STAGE;

-- ============================================================================
-- PASO 4: Crear función para consultar con Cortex Analyst
-- ============================================================================

-- Ejemplo de uso de Cortex Analyst con el modelo semántico
-- (Requiere acceso a Cortex habilitado en la cuenta)

/*
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'llama3.1-70b',
    CONCAT(
        'Usando el siguiente modelo semántico, responde la pregunta del usuario.\n\n',
        'Modelo: Seguros Centinela - Sistema de pólizas de seguros\n',
        'Tablas disponibles: polizas, clientes, agentes, vehiculos, polizas_auto, polizas_gmm, planes_gmm, siniestros, pagos\n\n',
        'Pregunta: ¿Cuál es el total de primas por tipo de seguro?'
    )
) AS respuesta;
*/

-- ============================================================================
-- PASO 5: Crear vista consolidada para análisis con IA
-- ============================================================================

CREATE OR REPLACE VIEW CENTINELA_DB.SEMANTICO.VW_DATOS_COMPLETOS_IA AS
SELECT 
    -- Póliza
    p.poliza_id,
    p.numero_poliza,
    p.tipo_seguro,
    p.estatus AS estatus_poliza,
    p.fecha_emision,
    p.fecha_inicio_vigencia,
    p.fecha_fin_vigencia,
    p.forma_pago,
    p.prima_neta,
    p.prima_total,
    
    -- Cliente
    c.cliente_id,
    c.nombre || ' ' || c.apellido_paterno || ' ' || COALESCE(c.apellido_materno, '') AS nombre_cliente,
    c.tipo_persona,
    c.genero,
    c.estado AS estado_cliente,
    c.municipio,
    
    -- Agente
    a.agente_id,
    a.nombre || ' ' || a.apellido_paterno AS nombre_agente,
    a.sucursal,
    a.region,
    a.nivel AS nivel_agente,
    
    -- Auto (si aplica)
    v.marca AS marca_vehiculo,
    v.submarca AS modelo_vehiculo,
    v.anio AS anio_vehiculo,
    v.tipo_vehiculo,
    v.valor_comercial,
    pa.paquete_cobertura,
    pa.suma_asegurada AS suma_asegurada_auto,
    
    -- GMM (si aplica)
    pl.nombre_plan AS plan_gmm,
    pg.tipo_poliza AS tipo_poliza_gmm,
    pg.nivel_hospitalario,
    pg.suma_asegurada AS suma_asegurada_gmm,
    pg.numero_asegurados AS vidas_aseguradas

FROM CENTINELA_DB.CORE.POLIZAS p
LEFT JOIN CENTINELA_DB.CORE.CLIENTES c ON p.cliente_id = c.cliente_id
LEFT JOIN CENTINELA_DB.CORE.AGENTES a ON p.agente_id = a.agente_id
LEFT JOIN CENTINELA_DB.AUTOS.POLIZAS_AUTO pa ON p.poliza_id = pa.poliza_id
LEFT JOIN CENTINELA_DB.AUTOS.VEHICULOS v ON pa.vehiculo_id = v.vehiculo_id
LEFT JOIN CENTINELA_DB.GMM.POLIZAS_GMM pg ON p.poliza_id = pg.poliza_id
LEFT JOIN CENTINELA_DB.GMM.PLANES_GMM pl ON pg.plan_id = pl.plan_id;

COMMENT ON VIEW CENTINELA_DB.SEMANTICO.VW_DATOS_COMPLETOS_IA IS 
'Vista consolidada de todos los datos para análisis con Cortex Analyst';

-- ============================================================================
-- PASO 6: Crear tabla de metadatos del modelo semántico
-- ============================================================================

CREATE OR REPLACE TABLE CENTINELA_DB.CORE.SEMANTIC_MODEL_METADATA (
    modelo_id VARCHAR(50) PRIMARY KEY,
    nombre_modelo VARCHAR(100) NOT NULL,
    version VARCHAR(20) NOT NULL,
    descripcion VARCHAR(500),
    fecha_creacion TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    fecha_actualizacion TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    archivo_yaml VARCHAR(200),
    activo BOOLEAN DEFAULT TRUE
);

INSERT INTO CENTINELA_DB.CORE.SEMANTIC_MODEL_METADATA 
(modelo_id, nombre_modelo, version, descripcion, archivo_yaml)
VALUES (
    'CENTINELA_SM_001',
    'centinela_seguros',
    '1.0',
    'Modelo semántico de Seguros Centinela para análisis de pólizas de automóviles y gastos médicos mayores',
    '@CENTINELA_DB.CORE.SEMANTIC_MODEL_STAGE/centinela_semantic_model.yaml'
);

-- ============================================================================
-- PASO 7: Verificar modelo registrado
-- ============================================================================

SELECT * FROM CENTINELA_DB.CORE.SEMANTIC_MODEL_METADATA;

-- ============================================================================
-- EJEMPLOS DE USO CON CORTEX ANALYST
-- ============================================================================

/*
-- Ejemplo 1: Pregunta simple sobre primas
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'llama3.1-70b',
    'Basándote en una aseguradora con pólizas de auto y GMM, 
     genera una consulta SQL para obtener el total de primas por tipo de seguro.
     Las tablas están en CENTINELA_DB.CORE.POLIZAS con columnas: 
     tipo_seguro (AUTO, GMM), prima_total, estatus.'
);

-- Ejemplo 2: Análisis de agentes
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'llama3.1-70b',
    'Genera SQL para ver el desempeño de agentes de seguros.
     Tablas: CENTINELA_DB.CORE.AGENTES (agente_id, nombre, apellido_paterno, sucursal, region)
     y CENTINELA_DB.CORE.POLIZAS (poliza_id, agente_id, prima_total, estatus).
     Quiero ver cantidad de pólizas y prima total por agente.'
);

-- Ejemplo 3: Vehículos más asegurados
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'llama3.1-70b',
    'SQL para las 10 marcas de vehículos más aseguradas.
     Tablas: CENTINELA_DB.AUTOS.VEHICULOS (vehiculo_id, marca, submarca, valor_comercial)
     JOIN con CENTINELA_DB.AUTOS.POLIZAS_AUTO (vehiculo_id, poliza_id).
     Mostrar marca, cantidad y valor total.'
);
*/

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================



