-- ============================================================================
-- SEGUROS CENTINELA - VISTAS SEMÁNTICAS
-- ============================================================================
-- Descripción: Vistas semánticas para análisis y explotación de datos
-- Diseñadas para facilitar reportes, dashboards y consultas ad-hoc
-- ============================================================================

USE DATABASE CENTINELA_DB;
USE WAREHOUSE CENTINELA_WH;

-- Crear schema para vistas semánticas
CREATE OR REPLACE SCHEMA CENTINELA_DB.SEMANTICO
    COMMENT = 'Vistas semánticas para análisis de negocio';

USE SCHEMA CENTINELA_DB.SEMANTICO;

-- ============================================================================
-- VISTA: VW_POLIZAS_COMPLETA
-- Descripción: Vista maestra de todas las pólizas con información consolidada
-- ============================================================================
CREATE OR REPLACE VIEW CENTINELA_DB.SEMANTICO.VW_POLIZAS_COMPLETA AS
SELECT 
    -- Datos de la póliza
    p.poliza_id,
    p.numero_poliza,
    p.tipo_seguro,
    p.estatus AS estatus_poliza,
    p.fecha_emision,
    p.fecha_inicio_vigencia,
    p.fecha_fin_vigencia,
    DATEDIFF(day, p.fecha_inicio_vigencia, p.fecha_fin_vigencia) AS dias_vigencia,
    CASE 
        WHEN p.fecha_fin_vigencia < CURRENT_DATE() THEN 'Vencida'
        WHEN p.fecha_fin_vigencia <= DATEADD(day, 30, CURRENT_DATE()) THEN 'Por Vencer'
        ELSE 'Vigente'
    END AS estado_vigencia,
    p.forma_pago,
    p.conducto_cobro,
    
    -- Primas
    p.prima_neta,
    p.derecho_poliza,
    p.recargo_pago_fraccionado,
    p.iva,
    p.prima_total,
    p.moneda,
    
    -- Datos del cliente
    c.cliente_id,
    c.tipo_persona,
    CASE 
        WHEN c.tipo_persona = 'Fisica' THEN c.nombre || ' ' || c.apellido_paterno || ' ' || COALESCE(c.apellido_materno, '')
        ELSE c.razon_social
    END AS nombre_completo_cliente,
    c.rfc,
    c.email AS email_cliente,
    c.telefono_celular,
    c.estado AS estado_cliente,
    c.municipio AS municipio_cliente,
    c.codigo_postal,
    
    -- Datos del agente
    a.agente_id,
    a.nombre || ' ' || a.apellido_paterno AS nombre_agente,
    a.sucursal,
    a.region,
    a.nivel AS nivel_agente,
    a.comision_porcentaje,
    (p.prima_neta * a.comision_porcentaje / 100) AS comision_estimada,
    
    -- Metadatos
    p.fecha_creacion,
    p.fecha_actualizacion
    
FROM CENTINELA_DB.CORE.POLIZAS p
LEFT JOIN CENTINELA_DB.CORE.CLIENTES c ON p.cliente_id = c.cliente_id
LEFT JOIN CENTINELA_DB.CORE.AGENTES a ON p.agente_id = a.agente_id;

COMMENT ON VIEW CENTINELA_DB.SEMANTICO.VW_POLIZAS_COMPLETA IS 'Vista maestra de todas las pólizas con información consolidada del cliente y agente';

-- ============================================================================
-- VISTA: VW_POLIZAS_AUTO_DETALLE
-- Descripción: Vista detallada de pólizas de automóviles
-- ============================================================================
CREATE OR REPLACE VIEW CENTINELA_DB.SEMANTICO.VW_POLIZAS_AUTO_DETALLE AS
SELECT 
    -- Póliza
    p.poliza_id,
    p.numero_poliza,
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
    c.rfc,
    c.estado AS estado_cliente,
    
    -- Agente
    a.nombre || ' ' || a.apellido_paterno AS nombre_agente,
    a.sucursal,
    a.region,
    
    -- Detalle Auto
    pa.poliza_auto_id,
    pa.paquete_cobertura,
    pa.suma_asegurada,
    pa.deducible_dm AS deducible_danios_materiales_pct,
    pa.deducible_robo AS deducible_robo_pct,
    pa.cobertura_rc AS limite_responsabilidad_civil,
    pa.cobertura_gm AS limite_gastos_medicos,
    pa.conductor_habitual,
    pa.edad_conductor,
    pa.anios_experiencia AS experiencia_conductor,
    pa.zona_circulacion,
    pa.historial_siniestros,
    pa.descuento_aplicado AS descuento_pct,
    
    -- Vehículo
    v.vehiculo_id,
    v.marca,
    v.submarca,
    v.modelo,
    v.anio AS anio_vehiculo,
    v.numero_serie,
    v.placas,
    v.color,
    v.tipo_vehiculo,
    v.transmision,
    v.combustible,
    v.valor_factura,
    v.valor_comercial,
    v.uso_vehiculo,
    
    -- Métricas calculadas
    (pa.suma_asegurada * pa.deducible_dm / 100) AS deducible_dm_monto,
    (pa.suma_asegurada * pa.deducible_robo / 100) AS deducible_robo_monto,
    (v.valor_factura - v.valor_comercial) AS depreciacion,
    ROUND(((v.valor_factura - v.valor_comercial) / v.valor_factura) * 100, 2) AS depreciacion_pct

FROM CENTINELA_DB.CORE.POLIZAS p
INNER JOIN CENTINELA_DB.AUTOS.POLIZAS_AUTO pa ON p.poliza_id = pa.poliza_id
INNER JOIN CENTINELA_DB.AUTOS.VEHICULOS v ON pa.vehiculo_id = v.vehiculo_id
LEFT JOIN CENTINELA_DB.CORE.CLIENTES c ON p.cliente_id = c.cliente_id
LEFT JOIN CENTINELA_DB.CORE.AGENTES a ON p.agente_id = a.agente_id
WHERE p.tipo_seguro = 'AUTO';

COMMENT ON VIEW CENTINELA_DB.SEMANTICO.VW_POLIZAS_AUTO_DETALLE IS 'Vista detallada de pólizas de automóviles con información del vehículo y coberturas';

-- ============================================================================
-- VISTA: VW_POLIZAS_GMM_DETALLE
-- Descripción: Vista detallada de pólizas de Gastos Médicos Mayores
-- ============================================================================
CREATE OR REPLACE VIEW CENTINELA_DB.SEMANTICO.VW_POLIZAS_GMM_DETALLE AS
SELECT 
    -- Póliza
    p.poliza_id,
    p.numero_poliza,
    p.estatus AS estatus_poliza,
    p.fecha_emision,
    p.fecha_inicio_vigencia,
    p.fecha_fin_vigencia,
    p.forma_pago,
    p.prima_neta,
    p.prima_total,
    
    -- Cliente/Contratante
    c.cliente_id,
    c.nombre || ' ' || c.apellido_paterno || ' ' || COALESCE(c.apellido_materno, '') AS nombre_contratante,
    c.rfc,
    c.estado AS estado_cliente,
    
    -- Agente
    a.nombre || ' ' || a.apellido_paterno AS nombre_agente,
    a.sucursal,
    a.region,
    
    -- Detalle GMM
    pg.poliza_gmm_id,
    pg.tipo_poliza,
    pg.suma_asegurada,
    pg.deducible,
    pg.coaseguro_porcentaje,
    pg.tope_coaseguro,
    pg.nivel_hospitalario,
    pg.cobertura_internacional,
    pg.cobertura_dental,
    pg.cobertura_vision,
    pg.cobertura_maternidad,
    pg.red_medica,
    pg.zona_cobertura,
    pg.numero_asegurados,
    pg.edad_promedio,
    
    -- Plan
    pl.plan_id,
    pl.nombre_plan,
    pl.descripcion AS descripcion_plan,
    
    -- Métricas calculadas
    (p.prima_total / pg.numero_asegurados) AS prima_por_asegurado,
    CASE 
        WHEN pg.cobertura_internacional THEN 'Internacional'
        ELSE 'Nacional'
    END AS alcance_geografico,
    CASE 
        WHEN pg.cobertura_dental AND pg.cobertura_vision AND pg.cobertura_maternidad THEN 'Completo'
        WHEN pg.cobertura_dental OR pg.cobertura_vision OR pg.cobertura_maternidad THEN 'Parcial'
        ELSE 'Básico'
    END AS nivel_coberturas_adicionales

FROM CENTINELA_DB.CORE.POLIZAS p
INNER JOIN CENTINELA_DB.GMM.POLIZAS_GMM pg ON p.poliza_id = pg.poliza_id
INNER JOIN CENTINELA_DB.GMM.PLANES_GMM pl ON pg.plan_id = pl.plan_id
LEFT JOIN CENTINELA_DB.CORE.CLIENTES c ON p.cliente_id = c.cliente_id
LEFT JOIN CENTINELA_DB.CORE.AGENTES a ON p.agente_id = a.agente_id
WHERE p.tipo_seguro = 'GMM';

COMMENT ON VIEW CENTINELA_DB.SEMANTICO.VW_POLIZAS_GMM_DETALLE IS 'Vista detallada de pólizas de GMM con información del plan y coberturas';

-- ============================================================================
-- VISTA: VW_DASHBOARD_VENTAS
-- Descripción: Vista resumida para dashboard de ventas
-- ============================================================================
CREATE OR REPLACE VIEW CENTINELA_DB.SEMANTICO.VW_DASHBOARD_VENTAS AS
SELECT 
    DATE_TRUNC('month', p.fecha_emision) AS mes_emision,
    p.tipo_seguro,
    a.region,
    a.sucursal,
    a.nombre || ' ' || a.apellido_paterno AS nombre_agente,
    p.forma_pago,
    
    -- Conteos
    COUNT(DISTINCT p.poliza_id) AS numero_polizas,
    COUNT(DISTINCT p.cliente_id) AS numero_clientes,
    
    -- Primas
    SUM(p.prima_neta) AS prima_neta_total,
    SUM(p.prima_total) AS prima_total,
    AVG(p.prima_total) AS prima_promedio,
    MIN(p.prima_total) AS prima_minima,
    MAX(p.prima_total) AS prima_maxima,
    
    -- Comisiones
    SUM(p.prima_neta * a.comision_porcentaje / 100) AS comisiones_totales

FROM CENTINELA_DB.CORE.POLIZAS p
LEFT JOIN CENTINELA_DB.CORE.AGENTES a ON p.agente_id = a.agente_id
WHERE p.estatus = 'Vigente'
GROUP BY 
    DATE_TRUNC('month', p.fecha_emision),
    p.tipo_seguro,
    a.region,
    a.sucursal,
    a.nombre || ' ' || a.apellido_paterno,
    p.forma_pago;

COMMENT ON VIEW CENTINELA_DB.SEMANTICO.VW_DASHBOARD_VENTAS IS 'Vista resumida para dashboards de ventas por período, tipo de seguro y agente';

-- ============================================================================
-- VISTA: VW_CARTERA_VEHICULOS
-- Descripción: Vista de la cartera de vehículos asegurados
-- ============================================================================
CREATE OR REPLACE VIEW CENTINELA_DB.SEMANTICO.VW_CARTERA_VEHICULOS AS
SELECT 
    v.marca,
    v.submarca,
    v.anio AS anio_modelo,
    v.tipo_vehiculo,
    v.combustible,
    v.uso_vehiculo,
    pa.paquete_cobertura,
    pa.zona_circulacion,
    
    -- Conteos
    COUNT(DISTINCT v.vehiculo_id) AS total_vehiculos,
    
    -- Valores
    SUM(v.valor_comercial) AS valor_comercial_total,
    AVG(v.valor_comercial) AS valor_comercial_promedio,
    SUM(pa.suma_asegurada) AS suma_asegurada_total,
    
    -- Primas
    SUM(p.prima_total) AS prima_total,
    AVG(p.prima_total) AS prima_promedio,
    
    -- Siniestralidad
    SUM(pa.historial_siniestros) AS total_siniestros_historicos,
    AVG(pa.historial_siniestros) AS siniestros_promedio

FROM CENTINELA_DB.AUTOS.VEHICULOS v
INNER JOIN CENTINELA_DB.AUTOS.POLIZAS_AUTO pa ON v.vehiculo_id = pa.vehiculo_id
INNER JOIN CENTINELA_DB.CORE.POLIZAS p ON pa.poliza_id = p.poliza_id
WHERE p.estatus = 'Vigente'
GROUP BY 
    v.marca,
    v.submarca,
    v.anio,
    v.tipo_vehiculo,
    v.combustible,
    v.uso_vehiculo,
    pa.paquete_cobertura,
    pa.zona_circulacion;

COMMENT ON VIEW CENTINELA_DB.SEMANTICO.VW_CARTERA_VEHICULOS IS 'Vista analítica de la cartera de vehículos asegurados por marca, modelo y características';

-- ============================================================================
-- VISTA: VW_CARTERA_GMM
-- Descripción: Vista de la cartera de asegurados en GMM
-- ============================================================================
CREATE OR REPLACE VIEW CENTINELA_DB.SEMANTICO.VW_CARTERA_GMM AS
SELECT 
    pl.nombre_plan,
    pg.nivel_hospitalario,
    pg.tipo_poliza,
    pg.red_medica,
    pg.zona_cobertura,
    
    -- Coberturas adicionales
    CASE WHEN pg.cobertura_internacional THEN 'Sí' ELSE 'No' END AS con_internacional,
    CASE WHEN pg.cobertura_dental THEN 'Sí' ELSE 'No' END AS con_dental,
    CASE WHEN pg.cobertura_vision THEN 'Sí' ELSE 'No' END AS con_vision,
    CASE WHEN pg.cobertura_maternidad THEN 'Sí' ELSE 'No' END AS con_maternidad,
    
    -- Conteos
    COUNT(DISTINCT pg.poliza_gmm_id) AS total_polizas,
    SUM(pg.numero_asegurados) AS total_asegurados,
    
    -- Montos
    SUM(pg.suma_asegurada) AS suma_asegurada_total,
    AVG(pg.deducible) AS deducible_promedio,
    
    -- Primas
    SUM(p.prima_total) AS prima_total,
    AVG(p.prima_total) AS prima_promedio_poliza,
    SUM(p.prima_total) / NULLIF(SUM(pg.numero_asegurados), 0) AS prima_por_asegurado,
    
    -- Demografía
    AVG(pg.edad_promedio) AS edad_promedio_cartera

FROM CENTINELA_DB.GMM.POLIZAS_GMM pg
INNER JOIN CENTINELA_DB.GMM.PLANES_GMM pl ON pg.plan_id = pl.plan_id
INNER JOIN CENTINELA_DB.CORE.POLIZAS p ON pg.poliza_id = p.poliza_id
WHERE p.estatus = 'Vigente'
GROUP BY 
    pl.nombre_plan,
    pg.nivel_hospitalario,
    pg.tipo_poliza,
    pg.red_medica,
    pg.zona_cobertura,
    pg.cobertura_internacional,
    pg.cobertura_dental,
    pg.cobertura_vision,
    pg.cobertura_maternidad;

COMMENT ON VIEW CENTINELA_DB.SEMANTICO.VW_CARTERA_GMM IS 'Vista analítica de la cartera de GMM por plan, nivel y coberturas';

-- ============================================================================
-- VISTA: VW_KPI_EJECUTIVO
-- Descripción: KPIs ejecutivos de la aseguradora
-- ============================================================================
CREATE OR REPLACE VIEW CENTINELA_DB.SEMANTICO.VW_KPI_EJECUTIVO AS
SELECT 
    -- Métricas generales
    (SELECT COUNT(*) FROM CENTINELA_DB.CORE.POLIZAS WHERE estatus = 'Vigente') AS polizas_vigentes,
    (SELECT COUNT(*) FROM CENTINELA_DB.CORE.POLIZAS WHERE tipo_seguro = 'AUTO' AND estatus = 'Vigente') AS polizas_auto_vigentes,
    (SELECT COUNT(*) FROM CENTINELA_DB.CORE.POLIZAS WHERE tipo_seguro = 'GMM' AND estatus = 'Vigente') AS polizas_gmm_vigentes,
    (SELECT COUNT(DISTINCT cliente_id) FROM CENTINELA_DB.CORE.POLIZAS WHERE estatus = 'Vigente') AS clientes_activos,
    
    -- Primas
    (SELECT SUM(prima_total) FROM CENTINELA_DB.CORE.POLIZAS WHERE estatus = 'Vigente') AS prima_total_cartera,
    (SELECT SUM(prima_total) FROM CENTINELA_DB.CORE.POLIZAS WHERE tipo_seguro = 'AUTO' AND estatus = 'Vigente') AS prima_total_auto,
    (SELECT SUM(prima_total) FROM CENTINELA_DB.CORE.POLIZAS WHERE tipo_seguro = 'GMM' AND estatus = 'Vigente') AS prima_total_gmm,
    (SELECT AVG(prima_total) FROM CENTINELA_DB.CORE.POLIZAS WHERE estatus = 'Vigente') AS prima_promedio,
    
    -- Vehículos
    (SELECT COUNT(*) FROM CENTINELA_DB.AUTOS.VEHICULOS) AS total_vehiculos_asegurados,
    (SELECT SUM(valor_comercial) FROM CENTINELA_DB.AUTOS.VEHICULOS v 
     INNER JOIN CENTINELA_DB.AUTOS.POLIZAS_AUTO pa ON v.vehiculo_id = pa.vehiculo_id
     INNER JOIN CENTINELA_DB.CORE.POLIZAS p ON pa.poliza_id = p.poliza_id 
     WHERE p.estatus = 'Vigente') AS valor_comercial_flota,
    
    -- GMM
    (SELECT SUM(numero_asegurados) FROM CENTINELA_DB.GMM.POLIZAS_GMM pg
     INNER JOIN CENTINELA_DB.CORE.POLIZAS p ON pg.poliza_id = p.poliza_id 
     WHERE p.estatus = 'Vigente') AS total_vidas_aseguradas,
    (SELECT SUM(suma_asegurada) FROM CENTINELA_DB.GMM.POLIZAS_GMM pg
     INNER JOIN CENTINELA_DB.CORE.POLIZAS p ON pg.poliza_id = p.poliza_id 
     WHERE p.estatus = 'Vigente') AS suma_asegurada_gmm_total,
    
    -- Agentes
    (SELECT COUNT(*) FROM CENTINELA_DB.CORE.AGENTES WHERE activo = TRUE) AS agentes_activos,
    
    -- Renovaciones (placeholder)
    (SELECT COUNT(*) FROM CENTINELA_DB.CORE.POLIZAS 
     WHERE fecha_fin_vigencia BETWEEN CURRENT_DATE() AND DATEADD(day, 30, CURRENT_DATE())
     AND estatus = 'Vigente') AS polizas_por_renovar_30_dias,
     
    -- Timestamp
    CURRENT_TIMESTAMP() AS fecha_calculo;

COMMENT ON VIEW CENTINELA_DB.SEMANTICO.VW_KPI_EJECUTIVO IS 'KPIs ejecutivos consolidados de la aseguradora';

-- ============================================================================
-- VISTA: VW_ANALISIS_AGENTES
-- Descripción: Análisis de desempeño de agentes
-- ============================================================================
CREATE OR REPLACE VIEW CENTINELA_DB.SEMANTICO.VW_ANALISIS_AGENTES AS
SELECT 
    a.agente_id,
    a.nombre || ' ' || a.apellido_paterno || ' ' || COALESCE(a.apellido_materno, '') AS nombre_completo,
    a.sucursal,
    a.region,
    a.nivel,
    a.fecha_ingreso,
    DATEDIFF(month, a.fecha_ingreso, CURRENT_DATE()) AS antiguedad_meses,
    a.comision_porcentaje,
    
    -- Métricas de pólizas
    COUNT(DISTINCT p.poliza_id) AS total_polizas,
    COUNT(DISTINCT CASE WHEN p.tipo_seguro = 'AUTO' THEN p.poliza_id END) AS polizas_auto,
    COUNT(DISTINCT CASE WHEN p.tipo_seguro = 'GMM' THEN p.poliza_id END) AS polizas_gmm,
    COUNT(DISTINCT p.cliente_id) AS total_clientes,
    
    -- Primas y comisiones
    SUM(p.prima_neta) AS prima_neta_total,
    SUM(p.prima_total) AS prima_total,
    AVG(p.prima_total) AS ticket_promedio,
    SUM(p.prima_neta * a.comision_porcentaje / 100) AS comisiones_generadas,
    
    -- Productividad
    COUNT(DISTINCT p.poliza_id) / NULLIF(DATEDIFF(month, a.fecha_ingreso, CURRENT_DATE()), 0) AS polizas_por_mes

FROM CENTINELA_DB.CORE.AGENTES a
LEFT JOIN CENTINELA_DB.CORE.POLIZAS p ON a.agente_id = p.agente_id AND p.estatus = 'Vigente'
WHERE a.activo = TRUE
GROUP BY 
    a.agente_id,
    a.nombre,
    a.apellido_paterno,
    a.apellido_materno,
    a.sucursal,
    a.region,
    a.nivel,
    a.fecha_ingreso,
    a.comision_porcentaje;

COMMENT ON VIEW CENTINELA_DB.SEMANTICO.VW_ANALISIS_AGENTES IS 'Vista de análisis de desempeño y productividad de agentes';

-- ============================================================================
-- VISTA: VW_RENOVACIONES_PENDIENTES
-- Descripción: Pólizas próximas a vencer para gestión de renovaciones
-- ============================================================================
CREATE OR REPLACE VIEW CENTINELA_DB.SEMANTICO.VW_RENOVACIONES_PENDIENTES AS
SELECT 
    p.poliza_id,
    p.numero_poliza,
    p.tipo_seguro,
    p.fecha_fin_vigencia,
    DATEDIFF(day, CURRENT_DATE(), p.fecha_fin_vigencia) AS dias_para_vencimiento,
    CASE 
        WHEN DATEDIFF(day, CURRENT_DATE(), p.fecha_fin_vigencia) <= 7 THEN 'Crítico'
        WHEN DATEDIFF(day, CURRENT_DATE(), p.fecha_fin_vigencia) <= 15 THEN 'Urgente'
        WHEN DATEDIFF(day, CURRENT_DATE(), p.fecha_fin_vigencia) <= 30 THEN 'Próximo'
        ELSE 'Programado'
    END AS prioridad_renovacion,
    p.prima_total AS prima_actual,
    p.forma_pago,
    
    -- Cliente
    c.cliente_id,
    c.nombre || ' ' || c.apellido_paterno AS nombre_cliente,
    c.email AS email_cliente,
    c.telefono_celular,
    
    -- Agente
    a.agente_id,
    a.nombre || ' ' || a.apellido_paterno AS nombre_agente,
    a.email AS email_agente,
    a.sucursal

FROM CENTINELA_DB.CORE.POLIZAS p
INNER JOIN CENTINELA_DB.CORE.CLIENTES c ON p.cliente_id = c.cliente_id
LEFT JOIN CENTINELA_DB.CORE.AGENTES a ON p.agente_id = a.agente_id
WHERE p.estatus = 'Vigente'
AND p.fecha_fin_vigencia >= CURRENT_DATE()
AND p.fecha_fin_vigencia <= DATEADD(day, 60, CURRENT_DATE())
ORDER BY dias_para_vencimiento ASC;

COMMENT ON VIEW CENTINELA_DB.SEMANTICO.VW_RENOVACIONES_PENDIENTES IS 'Vista de pólizas próximas a vencer para gestión de renovaciones';

-- ============================================================================
-- VALIDACIÓN: Verificar vistas creadas
-- ============================================================================
SELECT 
    table_schema,
    table_name,
    table_type,
    comment
FROM CENTINELA_DB.INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'SEMANTICO'
AND table_type = 'VIEW'
ORDER BY table_name;



