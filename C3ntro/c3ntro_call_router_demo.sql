-- =====================================================
-- DEMO DE BUSINESS CALL ROUTER - C3NTRO TELECOM
-- =====================================================
-- Cliente: C3ntro Telecom (https://www.c3ntro.com/)
-- Caso de uso: Análisis de routing de llamadas empresariales
-- Cobertura: México (CDMX, Monterrey, Querétaro) y Houston

-- =====================================================
-- CONFIGURACIÓN INICIAL
-- =====================================================
CREATE DATABASE IF NOT EXISTS C3NTRO_DEMO;
USE DATABASE C3NTRO_DEMO;
CREATE SCHEMA IF NOT EXISTS CALL_ROUTING;
USE SCHEMA CALL_ROUTING;

-- =====================================================
-- TABLA 1: CLIENTES EMPRESARIALES
-- =====================================================
CREATE OR REPLACE TABLE DIM_CLIENTES (
    ID_CLIENTE STRING PRIMARY KEY,
    NOMBRE_EMPRESA STRING,
    INDUSTRIA STRING,
    UBICACION STRING,
    PLAN_SERVICIO STRING,
    FECHA_INICIO_CONTRATO DATE,
    EJECUTIVO_CUENTA STRING,
    ESTATUS STRING
);

-- Insertar clientes dummy basados en casos de éxito reales de C3ntro
INSERT INTO DIM_CLIENTES VALUES
('CLT001', 'Aerolíneas Ejecutivas SA', 'Aviación', 'Ciudad de México', 'Enterprise Premium', '2023-01-15', 'Ana García', 'Activo'),
('CLT002', 'Casa Lumbre Spirits', 'Bebidas y Licores', 'Ciudad de México', 'Enterprise Premium', '2023-03-20', 'Carlos Mendoza', 'Activo'),
('CLT003', 'Little Caesars México (PCSAPI)', 'Restaurantes', 'Monterrey', 'Enterprise Standard', '2023-02-10', 'María López', 'Activo'),
('CLT004', 'Karisma Hotels & Resorts', 'Hospitalidad', 'Querétaro', 'Enterprise Premium', '2023-04-05', 'Roberto Silva', 'Activo'),
('CLT005', 'Grupo Financiero Azteca', 'Servicios Financieros', 'Ciudad de México', 'Enterprise Premium', '2023-01-30', 'Ana García', 'Activo'),
('CLT006', 'Cemex México', 'Construcción', 'Monterrey', 'Enterprise Standard', '2023-05-12', 'Carlos Mendoza', 'Activo'),
('CLT007', 'Liverpool Department Store', 'Retail', 'Ciudad de México', 'Enterprise Premium', '2023-03-08', 'María López', 'Activo'),
('CLT008', 'Grupo Modelo', 'Bebidas', 'Ciudad de México', 'Enterprise Standard', '2023-06-15', 'Roberto Silva', 'Activo'),
('CLT009', 'Pemex Corporativo', 'Energía', 'Ciudad de México', 'Enterprise Premium', '2023-02-28', 'Ana García', 'Activo'),
('CLT010', 'Tecnológico de Monterrey', 'Educación', 'Monterrey', 'Enterprise Standard', '2023-04-20', 'Carlos Mendoza', 'Activo');

-- =====================================================
-- TABLA 2: CONFIGURACIÓN DE RUTAS
-- =====================================================
CREATE OR REPLACE TABLE DIM_RUTAS_CONFIGURADAS (
    ID_RUTA STRING PRIMARY KEY,
    ID_CLIENTE STRING,
    TIPO_RUTA STRING,
    ORIGEN STRING,
    DESTINO STRING,
    PRIORIDAD NUMBER,
    PROTOCOLO STRING,
    CALIDAD_SERVICIO STRING,
    FECHA_CONFIGURACION DATE
);

INSERT INTO DIM_RUTAS_CONFIGURADAS VALUES
('RUT001', 'CLT001', 'SIP Trunk', 'CDMX-DC1', 'Webex Cloud', 1, 'SIP/TLS', 'Premium', '2023-01-20'),
('RUT002', 'CLT001', 'Backup Route', 'CDMX-DC2', 'Webex Cloud', 2, 'SIP/UDP', 'Standard', '2023-01-20'),
('RUT003', 'CLT002', 'Primary Route', 'CDMX-DC1', 'Microsoft Teams', 1, 'SIP/TLS', 'Premium', '2023-03-25'),
('RUT004', 'CLT003', 'Load Balancer', 'MTY-DC1', 'Cloud PBX', 1, 'SIP/TCP', 'Standard', '2023-02-15'),
('RUT005', 'CLT004', 'Redundant Path', 'QRO-DC1', 'Hybrid Cloud', 1, 'SIP/TLS', 'Premium', '2023-04-10'),
('RUT006', 'CLT005', 'Primary Route', 'CDMX-DC1', 'Microsoft Teams', 1, 'SIP/TLS', 'Premium', '2023-02-05'),
('RUT007', 'CLT005', 'Failover Route', 'CDMX-DC2', 'Microsoft Teams', 2, 'SIP/UDP', 'Standard', '2023-02-05'),
('RUT008', 'CLT006', 'Regional Route', 'MTY-DC1', 'Cisco Webex', 1, 'SIP/TCP', 'Standard', '2023-05-17'),
('RUT009', 'CLT007', 'Multi-site Route', 'CDMX-DC1', 'Omnichannel', 1, 'SIP/TLS', 'Premium', '2023-03-13'),
('RUT010', 'CLT008', 'Standard Route', 'CDMX-DC1', 'Traditional PBX', 1, 'SIP/UDP', 'Standard', '2023-06-20');

-- =====================================================
-- TABLA 3: TIPOS DE LLAMADAS
-- =====================================================
CREATE OR REPLACE TABLE DIM_TIPOS_LLAMADA (
    ID_TIPO STRING PRIMARY KEY,
    NOMBRE_TIPO STRING,
    DESCRIPCION STRING,
    TARIFA_BASE_MXN NUMBER(10,4),
    APLICA_DESCUENTO BOOLEAN
);

INSERT INTO DIM_TIPOS_LLAMADA VALUES
('TIP001', 'Local Nacional', 'Llamadas dentro de México', 0.1500, TRUE),
('TIP002', 'Internacional USA', 'Llamadas a Estados Unidos', 0.8500, TRUE),
('TIP003', 'Internacional Mundo', 'Llamadas internacionales', 2.5000, FALSE),
('TIP004', 'Móvil Nacional', 'Llamadas a celulares México', 0.3500, TRUE),
('TIP005', 'Toll Free', 'Números 800 gratuitos', 0.0000, FALSE),
('TIP006', 'Emergency', 'Llamadas de emergencia', 0.0000, FALSE),
('TIP007', 'Interno Corporativo', 'Extensiones internas', 0.0000, FALSE),
('TIP008', 'Video Conferencia', 'Llamadas de video', 0.2500, TRUE),
('TIP009', 'SMS Empresarial', 'Mensajes corporativos', 0.0850, TRUE),
('TIP010', 'IVR Interactivo', 'Sistema de respuesta automática', 0.0500, FALSE);

-- =====================================================
-- TABLA 4: HECHOS DE LLAMADAS DIARIAS
-- =====================================================
CREATE OR REPLACE TABLE FACT_LLAMADAS_DIARIAS (
    ID_LLAMADA STRING PRIMARY KEY,
    ID_CLIENTE STRING,
    ID_RUTA STRING,
    ID_TIPO_LLAMADA STRING,
    FECHA_LLAMADA DATE,
    HORA_INICIO TIME,
    DURACION_SEGUNDOS NUMBER,
    NUMERO_ORIGEN STRING,
    NUMERO_DESTINO STRING,
    CALIDAD_LLAMADA STRING,
    COSTO_MXN NUMBER(10,4),
    EXITOSA BOOLEAN,
    CODIGO_TERMINACION STRING,
    LATENCIA_MS NUMBER,
    JITTER_MS NUMBER,
    PACKET_LOSS_PCT NUMBER(5,2)
);

-- =====================================================
-- TABLA 5: MÉTRICAS DE RENDIMIENTO POR HORA
-- =====================================================
CREATE OR REPLACE TABLE FACT_METRICAS_ROUTING (
    ID_METRICA STRING PRIMARY KEY,
    ID_RUTA STRING,
    FECHA_HORA TIMESTAMP,
    LLAMADAS_INTENTADAS NUMBER,
    LLAMADAS_EXITOSAS NUMBER,
    LLAMADAS_FALLIDAS NUMBER,
    TIEMPO_RESPUESTA_PROMEDIO_MS NUMBER,
    UTILIZACION_ANCHO_BANDA_PCT NUMBER(5,2),
    DISPONIBILIDAD_PCT NUMBER(5,2),
    THROUGHPUT_LLAMADAS_POR_MINUTO NUMBER,
    CPU_UTILIZATION_PCT NUMBER(5,2),
    MEMORIA_UTILIZADA_PCT NUMBER(5,2)
);

-- =====================================================
-- DATOS DUMMY PARA FACT_LLAMADAS_DIARIAS
-- =====================================================
-- Generar llamadas para los últimos 30 días
INSERT INTO FACT_LLAMADAS_DIARIAS 
SELECT 
    'CALL' || LPAD(ROW_NUMBER() OVER (ORDER BY d.fecha, r.ID_RUTA), 8, '0') as ID_LLAMADA,
    r.ID_CLIENTE,
    r.ID_RUTA,
    t.ID_TIPO,
    d.fecha as FECHA_LLAMADA,
    TIME(DATEADD('minute', UNIFORM(480, 1080, RANDOM()), '00:00:00')) as HORA_INICIO,
    UNIFORM(15, 3600, RANDOM()) as DURACION_SEGUNDOS,
    '+52' || UNIFORM(1000000000, 9999999999, RANDOM()) as NUMERO_ORIGEN,
    CASE 
        WHEN t.NOMBRE_TIPO = 'Internacional USA' THEN '+1' || UNIFORM(1000000000, 9999999999, RANDOM())
        WHEN t.NOMBRE_TIPO = 'Internacional Mundo' THEN '+' || UNIFORM(10000000000, 99999999999, RANDOM())
        ELSE '+52' || UNIFORM(1000000000, 9999999999, RANDOM())
    END as NUMERO_DESTINO,
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'Excelente'
        WHEN 2 THEN 'Buena'
        WHEN 3 THEN 'Regular'
        ELSE 'Mala'
    END as CALIDAD_LLAMADA,
    (UNIFORM(15, 3600, RANDOM()) / 60.0) * t.TARIFA_BASE_MXN as COSTO_MXN,
    UNIFORM(0, 100, RANDOM()) > 5 as EXITOSA,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) > 5 THEN '200 OK'
        WHEN UNIFORM(0, 100, RANDOM()) > 80 THEN '486 Busy Here'
        WHEN UNIFORM(0, 100, RANDOM()) > 90 THEN '503 Service Unavailable'
        ELSE '408 Request Timeout'
    END as CODIGO_TERMINACION,
    UNIFORM(50, 300, RANDOM()) as LATENCIA_MS,
    UNIFORM(5, 50, RANDOM()) as JITTER_MS,
    UNIFORM(0, 5, RANDOM()) / 100.0 as PACKET_LOSS_PCT
FROM (
    SELECT DATEADD('day', SEQ4(), DATEADD('day', -30, CURRENT_DATE())) as fecha
    FROM TABLE(GENERATOR(ROWCOUNT => 30))
) d
CROSS JOIN DIM_RUTAS_CONFIGURADAS r
CROSS JOIN DIM_TIPOS_LLAMADA t
WHERE UNIFORM(1, 10, RANDOM()) > 3  -- 70% de probabilidad de generar llamada
LIMIT 50000;

-- =====================================================
-- DATOS DUMMY PARA FACT_METRICAS_ROUTING  
-- =====================================================
INSERT INTO FACT_METRICAS_ROUTING
SELECT 
    'MET' || LPAD(ROW_NUMBER() OVER (ORDER BY d.fecha_hora, r.ID_RUTA), 8, '0') as ID_METRICA,
    r.ID_RUTA,
    d.fecha_hora,
    UNIFORM(100, 1000, RANDOM()) as LLAMADAS_INTENTADAS,
    UNIFORM(90, 950, RANDOM()) as LLAMADAS_EXITOSAS,
    UNIFORM(5, 100, RANDOM()) as LLAMADAS_FALLIDAS,
    UNIFORM(80, 250, RANDOM()) as TIEMPO_RESPUESTA_PROMEDIO_MS,
    UNIFORM(30, 85, RANDOM()) as UTILIZACION_ANCHO_BANDA_PCT,
    UNIFORM(95, 100, RANDOM()) as DISPONIBILIDAD_PCT,
    UNIFORM(20, 80, RANDOM()) as THROUGHPUT_LLAMADAS_POR_MINUTO,
    UNIFORM(25, 75, RANDOM()) as CPU_UTILIZATION_PCT,
    UNIFORM(40, 80, RANDOM()) as MEMORIA_UTILIZADA_PCT
FROM (
    SELECT DATEADD('hour', SEQ4(), DATEADD('day', -7, CURRENT_TIMESTAMP())) as fecha_hora
    FROM TABLE(GENERATOR(ROWCOUNT => 168))  -- 7 días * 24 horas
) d
CROSS JOIN DIM_RUTAS_CONFIGURADAS r;

-- =====================================================
-- VISTAS ANALÍTICAS PARA LA DEMO
-- =====================================================

-- Vista 1: Resumen de tráfico por cliente
CREATE OR REPLACE VIEW VW_TRAFICO_POR_CLIENTE AS
SELECT 
    c.NOMBRE_EMPRESA,
    c.PLAN_SERVICIO,
    c.UBICACION,
    COUNT(f.ID_LLAMADA) as TOTAL_LLAMADAS,
    SUM(f.DURACION_SEGUNDOS) / 3600.0 as HORAS_TOTALES,
    SUM(f.COSTO_MXN) as FACTURACION_TOTAL_MXN,
    AVG(f.LATENCIA_MS) as LATENCIA_PROMEDIO_MS,
    AVG(f.PACKET_LOSS_PCT) as PACKET_LOSS_PROMEDIO_PCT,
    (SUM(CASE WHEN f.EXITOSA THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as SUCCESS_RATE_PCT
FROM DIM_CLIENTES c
JOIN FACT_LLAMADAS_DIARIAS f ON c.ID_CLIENTE = f.ID_CLIENTE
WHERE f.FECHA_LLAMADA >= DATEADD('day', -30, CURRENT_DATE())
GROUP BY c.NOMBRE_EMPRESA, c.PLAN_SERVICIO, c.UBICACION
ORDER BY FACTURACION_TOTAL_MXN DESC;

-- Vista 2: Análisis de calidad por ruta
CREATE OR REPLACE VIEW VW_CALIDAD_POR_RUTA AS
SELECT 
    r.ID_RUTA,
    r.TIPO_RUTA,
    r.ORIGEN,
    r.DESTINO,
    r.CALIDAD_SERVICIO,
    c.NOMBRE_EMPRESA,
    AVG(m.DISPONIBILIDAD_PCT) as DISPONIBILIDAD_PROMEDIO,
    AVG(m.TIEMPO_RESPUESTA_PROMEDIO_MS) as LATENCIA_PROMEDIO,
    AVG(m.UTILIZACION_ANCHO_BANDA_PCT) as UTILIZACION_BANDWIDTH,
    AVG(m.CPU_UTILIZATION_PCT) as CPU_UTILIZATION,
    COUNT(DISTINCT m.FECHA_HORA) as MEDICIONES_TOMADAS
FROM DIM_RUTAS_CONFIGURADAS r
JOIN DIM_CLIENTES c ON r.ID_CLIENTE = c.ID_CLIENTE
JOIN FACT_METRICAS_ROUTING m ON r.ID_RUTA = m.ID_RUTA
WHERE m.FECHA_HORA >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY r.ID_RUTA, r.TIPO_RUTA, r.ORIGEN, r.DESTINO, r.CALIDAD_SERVICIO, c.NOMBRE_EMPRESA
ORDER BY DISPONIBILIDAD_PROMEDIO DESC;

-- Vista 3: Análisis financiero por tipo de llamada
CREATE OR REPLACE VIEW VW_REVENUE_POR_TIPO_LLAMADA AS
SELECT 
    t.NOMBRE_TIPO,
    t.TARIFA_BASE_MXN,
    COUNT(f.ID_LLAMADA) as TOTAL_LLAMADAS,
    SUM(f.DURACION_SEGUNDOS) / 60.0 as MINUTOS_TOTALES,
    SUM(f.COSTO_MXN) as REVENUE_TOTAL_MXN,
    AVG(f.COSTO_MXN) as COSTO_PROMEDIO_POR_LLAMADA,
    (SUM(CASE WHEN f.EXITOSA THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as SUCCESS_RATE_PCT
FROM DIM_TIPOS_LLAMADA t
JOIN FACT_LLAMADAS_DIARIAS f ON t.ID_TIPO = f.ID_TIPO_LLAMADA
WHERE f.FECHA_LLAMADA >= DATEADD('day', -30, CURRENT_DATE())
GROUP BY t.NOMBRE_TIPO, t.TARIFA_BASE_MXN
ORDER BY REVENUE_TOTAL_MXN DESC;

-- Vista 4: Dashboard ejecutivo
CREATE OR REPLACE VIEW VW_DASHBOARD_EJECUTIVO AS
SELECT 
    'Métricas Generales' as CATEGORIA,
    'Total de Clientes Activos' as METRICA,
    COUNT(DISTINCT c.ID_CLIENTE)::STRING as VALOR
FROM DIM_CLIENTES c
WHERE c.ESTATUS = 'Activo'

UNION ALL

SELECT 
    'Métricas Generales' as CATEGORIA,
    'Llamadas Procesadas (30 días)' as METRICA,
    COUNT(f.ID_LLAMADA)::STRING as VALOR
FROM FACT_LLAMADAS_DIARIAS f
WHERE f.FECHA_LLAMADA >= DATEADD('day', -30, CURRENT_DATE())

UNION ALL

SELECT 
    'Métricas Financieras' as CATEGORIA,
    'Revenue Total MXN (30 días)' as METRICA,
    '$' || TO_CHAR(ROUND(SUM(f.COSTO_MXN), 2), '999,999,999.99') as VALOR
FROM FACT_LLAMADAS_DIARIAS f
WHERE f.FECHA_LLAMADA >= DATEADD('day', -30, CURRENT_DATE())

UNION ALL

SELECT 
    'Métricas de Calidad' as CATEGORIA,
    'Success Rate Promedio %' as METRICA,
    TO_CHAR(ROUND(AVG(CASE WHEN f.EXITOSA THEN 100 ELSE 0 END), 2), '999.99') || '%' as VALOR
FROM FACT_LLAMADAS_DIARIAS f
WHERE f.FECHA_LLAMADA >= DATEADD('day', -30, CURRENT_DATE())

UNION ALL

SELECT 
    'Métricas de Performance' as CATEGORIA,
    'Latencia Promedio (ms)' as METRICA,
    TO_CHAR(ROUND(AVG(f.LATENCIA_MS), 2), '999.99') as VALOR
FROM FACT_LLAMADAS_DIARIAS f
WHERE f.FECHA_LLAMADA >= DATEADD('day', -30, CURRENT_DATE());

-- =====================================================
-- QUERIES DE EJEMPLO PARA LA DEMO
-- =====================================================

-- Query 1: Top 5 clientes por facturación
SELECT * FROM VW_TRAFICO_POR_CLIENTE LIMIT 5;

-- Query 2: Análisis de calidad de servicio
SELECT * FROM VW_CALIDAD_POR_RUTA 
WHERE DISPONIBILIDAD_PROMEDIO > 99.0
ORDER BY LATENCIA_PROMEDIO;

-- Query 3: Revenue por tipo de llamada
SELECT * FROM VW_REVENUE_POR_TIPO_LLAMADA;

-- Query 4: Dashboard ejecutivo
SELECT * FROM VW_DASHBOARD_EJECUTIVO;

-- Query 5: Análisis de tendencias por día
SELECT 
    f.FECHA_LLAMADA,
    COUNT(*) as LLAMADAS_DIA,
    SUM(f.COSTO_MXN) as REVENUE_DIA,
    AVG(f.LATENCIA_MS) as LATENCIA_PROMEDIO
FROM FACT_LLAMADAS_DIARIAS f
WHERE f.FECHA_LLAMADA >= DATEADD('day', -7, CURRENT_DATE())
GROUP BY f.FECHA_LLAMADA
ORDER BY f.FECHA_LLAMADA DESC;

COMMIT;


