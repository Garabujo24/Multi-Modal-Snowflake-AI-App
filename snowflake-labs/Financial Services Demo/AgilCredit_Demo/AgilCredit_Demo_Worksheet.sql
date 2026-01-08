/*******************************************************************************
 * AGILCREDIT - DEMO DE SERVICIOS FINANCIEROS
 * 
 * Fintech Mexicana especializada en créditos personales y empresariales
 * con tecnología avanzada de análisis de riesgo, detección de fraude,
 * y cumplimiento regulatorio.
 *
 * Ingeniero de Datos: Demo Completa
 * Fecha: Octubre 2025
 ******************************************************************************/

--------------------------------------------------------------------------------
-- SECCIÓN 0: HISTORIA Y CASO DE USO
--------------------------------------------------------------------------------

/*
AGILCREDIT - La Revolución Fintech en México

AgilCredit nació en 2020 como respuesta a la necesidad de democratizar el acceso
al crédito en México. Fundada por un equipo de expertos en tecnología financiera,
la empresa se especializa en proporcionar créditos personales y empresariales de
manera ágil, transparente y accesible.

MISIÓN:
Brindar soluciones financieras innovadoras que empoderen a individuos y empresas
mexicanas a alcanzar sus metas, utilizando tecnología de punta para evaluar
riesgos de manera justa y prevenir fraudes.

DESAFÍOS PRINCIPALES:
1. ANÁLISIS DE RIESGO CREDITICIO
   - Evaluar la capacidad de pago de solicitantes
   - Definir tasas de interés personalizadas
   - Reducir tasas de morosidad
   
2. DETECCIÓN DE FRAUDE
   - Identificar patrones sospechosos en transacciones
   - Prevenir suplantación de identidad
   - Monitorear comportamientos anómalos
   
3. RENTABILIDAD DE CLIENTES
   - Calcular el valor del tiempo de vida del cliente (LTV)
   - Identificar segmentos más rentables
   - Optimizar estrategias de retención
   
4. CUMPLIMIENTO REGULATORIO
   - Prevención de Lavado de Dinero (PLD)
   - Conoce a tu Cliente (KYC)
   - Reportes a la CNBV y CONDUSEF

SOLUCIÓN CON SNOWFLAKE:
Snowflake permite a AgilCredit centralizar datos estructurados y no estructurados
(contratos PDF, logs JSON, reportes XML) para análisis en tiempo real, machine
learning, y cumplimiento regulatorio automatizado.
*/

--------------------------------------------------------------------------------
-- SECCIÓN 1: CONFIGURACIÓN DE RECURSOS
--------------------------------------------------------------------------------

-- 1.1 Contexto y Rol
USE ROLE ACCOUNTADMIN;

-- 1.2 Crear Warehouse dedicado
CREATE OR REPLACE WAREHOUSE AGILCREDIT_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse para operaciones de AgilCredit - Demo Fintech';

-- 1.3 Crear Database
CREATE OR REPLACE DATABASE AGILCREDIT_DB
    COMMENT = 'Base de datos principal de AgilCredit - Datos de créditos, clientes, transacciones';

-- 1.4 Crear Schemas
CREATE OR REPLACE SCHEMA AGILCREDIT_DB.CORE
    COMMENT = 'Schema principal con datos transaccionales';

CREATE OR REPLACE SCHEMA AGILCREDIT_DB.ANALYTICS
    COMMENT = 'Schema para análisis y modelos derivados';

CREATE OR REPLACE SCHEMA AGILCREDIT_DB.COMPLIANCE
    COMMENT = 'Schema para datos de cumplimiento regulatorio';

CREATE OR REPLACE SCHEMA AGILCREDIT_DB.UNSTRUCTURED
    COMMENT = 'Schema para datos no estructurados (PDFs, JSON, XML)';

-- 1.5 Activar Warehouse y Contexto
USE WAREHOUSE AGILCREDIT_WH;
USE DATABASE AGILCREDIT_DB;
USE SCHEMA CORE;

-- 1.6 Crear Stage para archivos no estructurados
CREATE OR REPLACE STAGE AGILCREDIT_DB.UNSTRUCTURED.DOCUMENTS_STAGE
    COMMENT = 'Stage para PDFs, JSON, XML de documentos y logs';

CREATE OR REPLACE STAGE AGILCREDIT_DB.UNSTRUCTURED.LOGS_STAGE
    COMMENT = 'Stage para logs de transacciones en JSON';

CREATE OR REPLACE STAGE AGILCREDIT_DB.UNSTRUCTURED.REGULATORY_STAGE
    COMMENT = 'Stage para reportes regulatorios en XML';

--------------------------------------------------------------------------------
-- SECCIÓN 2: GENERACIÓN DE DATOS SINTÉTICOS
--------------------------------------------------------------------------------

-- 2.1 TABLA: CLIENTES
CREATE OR REPLACE TABLE AGILCREDIT_DB.CORE.CLIENTES (
    CLIENTE_ID VARCHAR(20) PRIMARY KEY,
    NOMBRE VARCHAR(100),
    APELLIDO_PATERNO VARCHAR(100),
    APELLIDO_MATERNO VARCHAR(100),
    CURP VARCHAR(18),
    RFC VARCHAR(13),
    FECHA_NACIMIENTO DATE,
    EDAD NUMBER(3),
    GENERO VARCHAR(20),
    ESTADO_CIVIL VARCHAR(20),
    NIVEL_EDUCACION VARCHAR(50),
    OCUPACION VARCHAR(100),
    INGRESO_MENSUAL NUMBER(12,2),
    ESTADO VARCHAR(50),
    CIUDAD VARCHAR(100),
    CODIGO_POSTAL VARCHAR(5),
    FECHA_REGISTRO TIMESTAMP_NTZ,
    CANAL_ADQUISICION VARCHAR(50),
    CALIFICACION_BURO NUMBER(3),
    SCORE_RIESGO NUMBER(5,2),
    SEGMENTO_CLIENTE VARCHAR(30),
    ESTATUS VARCHAR(20),
    COMENTARIOS VARCHAR(500)
);

-- 2.2 TABLA: PRODUCTOS CREDITICIOS
CREATE OR REPLACE TABLE AGILCREDIT_DB.CORE.PRODUCTOS (
    PRODUCTO_ID VARCHAR(20) PRIMARY KEY,
    NOMBRE_PRODUCTO VARCHAR(100),
    TIPO_CREDITO VARCHAR(50),
    DESCRIPCION VARCHAR(500),
    MONTO_MINIMO NUMBER(12,2),
    MONTO_MAXIMO NUMBER(12,2),
    PLAZO_MINIMO_MESES NUMBER(3),
    PLAZO_MAXIMO_MESES NUMBER(3),
    TASA_INTERES_MIN NUMBER(5,2),
    TASA_INTERES_MAX NUMBER(5,2),
    COMISION_APERTURA NUMBER(5,2),
    CAT_PROMEDIO NUMBER(5,2),
    SCORE_MINIMO_REQUERIDO NUMBER(3),
    FECHA_CREACION DATE,
    ESTATUS VARCHAR(20)
);

-- 2.3 TABLA: SOLICITUDES DE CRÉDITO
CREATE OR REPLACE TABLE AGILCREDIT_DB.CORE.SOLICITUDES (
    SOLICITUD_ID VARCHAR(20) PRIMARY KEY,
    CLIENTE_ID VARCHAR(20),
    PRODUCTO_ID VARCHAR(20),
    FECHA_SOLICITUD TIMESTAMP_NTZ,
    MONTO_SOLICITADO NUMBER(12,2),
    PLAZO_MESES NUMBER(3),
    PROPOSITO VARCHAR(200),
    TASA_INTERES NUMBER(5,2),
    MONTO_APROBADO NUMBER(12,2),
    ESTATUS_SOLICITUD VARCHAR(30),
    FECHA_DECISION TIMESTAMP_NTZ,
    ANALISTA_ID VARCHAR(20),
    MOTIVO_RECHAZO VARCHAR(200),
    FOREIGN KEY (CLIENTE_ID) REFERENCES CLIENTES(CLIENTE_ID),
    FOREIGN KEY (PRODUCTO_ID) REFERENCES PRODUCTOS(PRODUCTO_ID)
);

-- 2.4 TABLA: CRÉDITOS ACTIVOS
CREATE OR REPLACE TABLE AGILCREDIT_DB.CORE.CREDITOS (
    CREDITO_ID VARCHAR(20) PRIMARY KEY,
    SOLICITUD_ID VARCHAR(20),
    CLIENTE_ID VARCHAR(20),
    PRODUCTO_ID VARCHAR(20),
    FECHA_DESEMBOLSO TIMESTAMP_NTZ,
    MONTO_CREDITO NUMBER(12,2),
    PLAZO_MESES NUMBER(3),
    TASA_INTERES NUMBER(5,2),
    PAGO_MENSUAL NUMBER(12,2),
    SALDO_ACTUAL NUMBER(12,2),
    PAGOS_REALIZADOS NUMBER(3),
    PAGOS_ATRASADOS NUMBER(3),
    DIAS_MORA NUMBER(5),
    ESTATUS_CREDITO VARCHAR(30),
    FECHA_PROXIMO_PAGO DATE,
    FOREIGN KEY (SOLICITUD_ID) REFERENCES SOLICITUDES(SOLICITUD_ID),
    FOREIGN KEY (CLIENTE_ID) REFERENCES CLIENTES(CLIENTE_ID),
    FOREIGN KEY (PRODUCTO_ID) REFERENCES PRODUCTOS(PRODUCTO_ID)
);

-- 2.5 TABLA: TRANSACCIONES
CREATE OR REPLACE TABLE AGILCREDIT_DB.CORE.TRANSACCIONES (
    TRANSACCION_ID VARCHAR(20) PRIMARY KEY,
    CREDITO_ID VARCHAR(20),
    CLIENTE_ID VARCHAR(20),
    FECHA_TRANSACCION TIMESTAMP_NTZ,
    TIPO_TRANSACCION VARCHAR(50),
    MONTO NUMBER(12,2),
    METODO_PAGO VARCHAR(50),
    REFERENCIA VARCHAR(100),
    BANCO_ORIGEN VARCHAR(100),
    CUENTA_ORIGEN VARCHAR(50),
    IP_ADDRESS VARCHAR(45),
    DISPOSITIVO VARCHAR(50),
    UBICACION_GPS VARCHAR(100),
    ESTATUS_TRANSACCION VARCHAR(30),
    FOREIGN KEY (CREDITO_ID) REFERENCES CREDITOS(CREDITO_ID),
    FOREIGN KEY (CLIENTE_ID) REFERENCES CLIENTES(CLIENTE_ID)
);

-- 2.6 TABLA: ALERTAS DE FRAUDE
CREATE OR REPLACE TABLE AGILCREDIT_DB.CORE.ALERTAS_FRAUDE (
    ALERTA_ID VARCHAR(20) PRIMARY KEY,
    TRANSACCION_ID VARCHAR(20),
    CLIENTE_ID VARCHAR(20),
    FECHA_ALERTA TIMESTAMP_NTZ,
    TIPO_ALERTA VARCHAR(100),
    NIVEL_RIESGO VARCHAR(20),
    SCORE_FRAUDE NUMBER(5,2),
    REGLA_ACTIVADA VARCHAR(200),
    DESCRIPCION VARCHAR(500),
    ESTATUS_ALERTA VARCHAR(30),
    ANALISTA_ASIGNADO VARCHAR(50),
    FECHA_RESOLUCION TIMESTAMP_NTZ,
    ACCION_TOMADA VARCHAR(200),
    FOREIGN KEY (TRANSACCION_ID) REFERENCES TRANSACCIONES(TRANSACCION_ID),
    FOREIGN KEY (CLIENTE_ID) REFERENCES CLIENTES(CLIENTE_ID)
);

-- 2.7 TABLA: EVENTOS DE CUMPLIMIENTO (KYC/PLD)
CREATE OR REPLACE TABLE AGILCREDIT_DB.COMPLIANCE.EVENTOS_CUMPLIMIENTO (
    EVENTO_ID VARCHAR(20) PRIMARY KEY,
    CLIENTE_ID VARCHAR(20),
    FECHA_EVENTO TIMESTAMP_NTZ,
    TIPO_EVENTO VARCHAR(100),
    DESCRIPCION VARCHAR(500),
    RESULTADO VARCHAR(50),
    DOCUMENTOS_VALIDADOS ARRAY,
    LISTAS_VERIFICADAS ARRAY,
    OFICIAL_CUMPLIMIENTO VARCHAR(100),
    COMENTARIOS VARCHAR(500),
    FOREIGN KEY (CLIENTE_ID) REFERENCES CORE.CLIENTES(CLIENTE_ID)
);

-- 2.8 TABLA: RENTABILIDAD POR CLIENTE
CREATE OR REPLACE TABLE AGILCREDIT_DB.ANALYTICS.RENTABILIDAD_CLIENTES (
    CLIENTE_ID VARCHAR(20) PRIMARY KEY,
    FECHA_CALCULO DATE,
    INGRESOS_TOTALES NUMBER(12,2),
    INTERESES_COBRADOS NUMBER(12,2),
    COMISIONES_COBRADAS NUMBER(12,2),
    COSTOS_OPERATIVOS NUMBER(12,2),
    COSTOS_RIESGO NUMBER(12,2),
    UTILIDAD_NETA NUMBER(12,2),
    MARGEN_RENTABILIDAD NUMBER(5,2),
    LTV_ESTIMADO NUMBER(12,2),
    CAC NUMBER(12,2),
    RATIO_LTV_CAC NUMBER(5,2),
    SEGMENTO_RENTABILIDAD VARCHAR(30),
    FOREIGN KEY (CLIENTE_ID) REFERENCES CORE.CLIENTES(CLIENTE_ID)
);

-- Insertar Datos Sintéticos

-- 2.9 Generar Productos Crediticios
INSERT INTO PRODUCTOS VALUES
('PROD001', 'Crédito Personal Express', 'Personal', 'Crédito personal de hasta $50,000 con respuesta inmediata', 5000, 50000, 6, 24, 18.00, 35.00, 3.00, 42.50, 600, '2020-01-15', 'ACTIVO'),
('PROD002', 'Crédito PyME Crecimiento', 'Empresarial', 'Financiamiento para pequeñas y medianas empresas', 50000, 500000, 12, 48, 15.00, 28.00, 2.50, 35.80, 650, '2020-03-20', 'ACTIVO'),
('PROD003', 'Crédito Nómina Plus', 'Nómina', 'Crédito de nómina con descuento automático', 10000, 100000, 12, 36, 12.00, 22.00, 1.50, 28.90, 620, '2020-06-10', 'ACTIVO'),
('PROD004', 'Crédito Auto Fácil', 'Automotriz', 'Financiamiento para compra de vehículo nuevo o usado', 80000, 800000, 24, 60, 14.00, 24.00, 2.00, 30.50, 640, '2021-02-05', 'ACTIVO'),
('PROD005', 'Línea de Crédito Flexible', 'Revolvente', 'Línea de crédito revolvente para emergencias', 3000, 30000, 1, 12, 25.00, 45.00, 5.00, 55.20, 580, '2021-08-15', 'ACTIVO');

-- 2.10 Generar Clientes (1000 clientes)
INSERT INTO CLIENTES
WITH NOMBRES AS (
    SELECT ROW_NUMBER() OVER (ORDER BY 1) - 1 as idx, nombre FROM VALUES
    ('Carlos'), ('María'), ('José'), ('Ana'), ('Luis'), ('Carmen'), ('Miguel'), ('Rosa'), ('Juan'), ('Patricia'),
    ('Francisco'), ('Laura'), ('Roberto'), ('Elena'), ('Jorge'), ('Sofía'), ('Ricardo'), ('Isabel'), ('Fernando'), ('Gabriela'),
    ('Alejandro'), ('Diana'), ('Antonio'), ('Mónica'), ('Manuel'), ('Silvia'), ('Pedro'), ('Teresa'), ('Raúl'), ('Claudia')
    AS t(nombre)
),
APELLIDOS_P AS (
    SELECT ROW_NUMBER() OVER (ORDER BY 1) - 1 as idx, apellido FROM VALUES
    ('García'), ('Rodríguez'), ('Martínez'), ('Hernández'), ('López'), ('González'), ('Pérez'), ('Sánchez'), ('Ramírez'), ('Torres'),
    ('Flores'), ('Rivera'), ('Gómez'), ('Díaz'), ('Cruz'), ('Morales'), ('Reyes'), ('Jiménez'), ('Gutiérrez'), ('Ruiz'),
    ('Mendoza'), ('Alvarez'), ('Castillo'), ('Romero'), ('Herrera'), ('Medina'), ('Aguilar'), ('Guerrero'), ('Vega'), ('Vargas')
    AS t(apellido)
),
APELLIDOS_M AS (
    SELECT ROW_NUMBER() OVER (ORDER BY 1) - 1 as idx, apellido FROM VALUES
    ('Moreno'), ('Silva'), ('Castro'), ('Ortiz'), ('Ramos'), ('Núñez'), ('Delgado'), ('Ríos'), ('Campos'), ('Santos'),
    ('Mejía'), ('Luna'), ('Soto'), ('Cabrera'), ('Contreras'), ('Figueroa'), ('Salazar'), ('Cortés'), ('Peña'), ('Velázquez'),
    ('Domínguez'), ('Rojas'), ('Sandoval'), ('Zamora'), ('Ibarra'), ('Pacheco'), ('Parra'), ('Valdez'), ('Lara'), ('Espinosa')
    AS t(apellido)
),
ESTADOS AS (
    SELECT ROW_NUMBER() OVER (ORDER BY 1) - 1 as idx, ciudad, estado FROM VALUES
    ('Ciudad de México', 'CDMX'), ('Guadalajara', 'Jalisco'), ('Monterrey', 'Nuevo León'), 
    ('Puebla', 'Puebla'), ('Tijuana', 'Baja California'), ('León', 'Guanajuato'),
    ('Querétaro', 'Querétaro'), ('Mérida', 'Yucatán'), ('Toluca', 'Estado de México'), ('Aguascalientes', 'Aguascalientes')
    AS t(ciudad, estado)
),
OCUPACIONES AS (
    SELECT ROW_NUMBER() OVER (ORDER BY 1) - 1 as idx, ocupacion, ingreso_base FROM VALUES
    ('Ingeniero', 45000), ('Contador', 35000), ('Médico', 55000), ('Maestro', 28000), ('Abogado', 48000),
    ('Comerciante', 32000), ('Empresario', 65000), ('Administrador', 38000), ('Arquitecto', 42000), ('Diseñador', 30000)
    AS t(ocupacion, ingreso_base)
),
NUMEROS AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY NULL)) - 1 as num
    FROM TABLE(GENERATOR(ROWCOUNT => 1000))
)
SELECT 
    'CLI' || LPAD(num::STRING, 6, '0') as CLIENTE_ID,
    n.nombre as NOMBRE,
    ap.apellido as APELLIDO_PATERNO,
    am.apellido as APELLIDO_MATERNO,
    CONCAT(
        SUBSTR('ABCDEFGHIJKLMNOPQRSTUVWXYZ', MOD(num, 26) + 1, 1),
        SUBSTR('ABCDEFGHIJKLMNOPQRSTUVWXYZ', MOD(num + 3, 26) + 1, 1),
        SUBSTR('ABCDEFGHIJKLMNOPQRSTUVWXYZ', MOD(num + 7, 26) + 1, 1),
        SUBSTR('ABCDEFGHIJKLMNOPQRSTUVWXYZ', MOD(num + 11, 26) + 1, 1),
        LPAD(num::STRING, 6, '0'),
        'H',
        SUBSTR('ABCDEFGHIJKLMNOPQRSTUVWXYZ', MOD(num + 13, 26) + 1, 1),
        LPAD(MOD(num, 100)::STRING, 2, '0')
    ) as CURP,
    CONCAT(
        SUBSTR('ABCDEFGHIJKLMNOPQRSTUVWXYZ', MOD(num, 26) + 1, 1),
        SUBSTR('ABCDEFGHIJKLMNOPQRSTUVWXYZ', MOD(num + 5, 26) + 1, 1),
        SUBSTR('ABCDEFGHIJKLMNOPQRSTUVWXYZ', MOD(num + 9, 26) + 1, 1),
        LPAD(num::STRING, 6, '0'),
        SUBSTR('ABCDEFGHIJKLMNOPQRSTUVWXYZ', MOD(num + 17, 26) + 1, 1),
        LPAD(MOD(num, 10)::STRING, 1, '0')
    ) as RFC,
    DATEADD(day, -(MOD(num, 18250) + 6570), CURRENT_DATE()) as FECHA_NACIMIENTO,
    FLOOR((365.25 * 68 - (MOD(num, 18250) + 6570)) / 365.25) as EDAD,
    CASE WHEN MOD(num, 2) = 0 THEN 'Masculino' ELSE 'Femenino' END as GENERO,
    CASE MOD(num, 4)
        WHEN 0 THEN 'Soltero(a)' 
        WHEN 1 THEN 'Casado(a)' 
        WHEN 2 THEN 'Unión Libre' 
        ELSE 'Divorciado(a)' 
    END as ESTADO_CIVIL,
    CASE MOD(num, 5)
        WHEN 0 THEN 'Secundaria'
        WHEN 1 THEN 'Preparatoria'
        WHEN 2 THEN 'Licenciatura'
        WHEN 3 THEN 'Maestría'
        ELSE 'Técnico'
    END as NIVEL_EDUCACION,
    o.ocupacion as OCUPACION,
    o.ingreso_base * (1 + MOD(num, 100) / 100.0) as INGRESO_MENSUAL,
    e.estado as ESTADO,
    e.ciudad as CIUDAD,
    LPAD(MOD(num, 100000)::STRING, 5, '0') as CODIGO_POSTAL,
    DATEADD(day, -MOD(num, 1825), CURRENT_DATE()) as FECHA_REGISTRO,
    CASE MOD(num, 5)
        WHEN 0 THEN 'Web'
        WHEN 1 THEN 'App Móvil'
        WHEN 2 THEN 'Referido'
        WHEN 3 THEN 'Redes Sociales'
        ELSE 'Sucursal'
    END as CANAL_ADQUISICION,
    550 + MOD(num, 300) as CALIFICACION_BURO,
    ROUND(550 + MOD(num, 300) + (UNIFORM(-20.0::FLOAT, 20.0::FLOAT, RANDOM())), 2) as SCORE_RIESGO,
    CASE 
        WHEN (550 + MOD(num, 300)) >= 750 THEN 'Premium'
        WHEN (550 + MOD(num, 300)) >= 680 THEN 'Oro'
        WHEN (550 + MOD(num, 300)) >= 620 THEN 'Plata'
        ELSE 'Bronce'
    END as SEGMENTO_CLIENTE,
    CASE WHEN MOD(num, 20) = 0 THEN 'INACTIVO' ELSE 'ACTIVO' END as ESTATUS,
    NULL as COMENTARIOS
FROM NUMEROS
JOIN NOMBRES n ON n.idx = MOD(num, 30)
JOIN APELLIDOS_P ap ON ap.idx = MOD(num, 30)
JOIN APELLIDOS_M am ON am.idx = MOD(num, 30)
JOIN ESTADOS e ON e.idx = MOD(num, 10)
JOIN OCUPACIONES o ON o.idx = MOD(num, 10);

-- 2.11 Generar Solicitudes de Crédito (2000 solicitudes)
INSERT INTO SOLICITUDES
WITH NUMEROS AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY NULL)) - 1 as num 
    FROM TABLE(GENERATOR(ROWCOUNT => 2000))
),
CLIENTES_LIST AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY CLIENTE_ID) - 1 as idx,
        CLIENTE_ID, 
        SCORE_RIESGO 
    FROM CLIENTES
),
PRODUCTOS_LIST AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY PRODUCTO_ID) - 1 as idx,
        PRODUCTO_ID, 
        MONTO_MINIMO, 
        MONTO_MAXIMO, 
        PLAZO_MINIMO_MESES, 
        PLAZO_MAXIMO_MESES, 
        TASA_INTERES_MIN, 
        TASA_INTERES_MAX, 
        SCORE_MINIMO_REQUERIDO 
    FROM PRODUCTOS
)
SELECT 
    'SOL' || LPAD(num::STRING, 6, '0') as SOLICITUD_ID,
    c.CLIENTE_ID,
    p.PRODUCTO_ID,
    DATEADD(day, -MOD(num, 730), CURRENT_DATE()) as FECHA_SOLICITUD,
    ROUND(p.MONTO_MINIMO + (UNIFORM(0.0::FLOAT, 1.0::FLOAT, RANDOM()) * (p.MONTO_MAXIMO - p.MONTO_MINIMO)), 2) as MONTO_SOLICITADO,
    p.PLAZO_MINIMO_MESES + MOD(num, (p.PLAZO_MAXIMO_MESES - p.PLAZO_MINIMO_MESES + 1)) as PLAZO_MESES,
    CASE MOD(num, 10)
        WHEN 0 THEN 'Consolidación de deudas'
        WHEN 1 THEN 'Mejoras al hogar'
        WHEN 2 THEN 'Compra de vehículo'
        WHEN 3 THEN 'Gastos médicos'
        WHEN 4 THEN 'Educación'
        WHEN 5 THEN 'Capital de trabajo'
        WHEN 6 THEN 'Expansión de negocio'
        WHEN 7 THEN 'Inventario'
        WHEN 8 THEN 'Emergencia'
        ELSE 'Otros gastos'
    END as PROPOSITO,
    ROUND(p.TASA_INTERES_MIN + (UNIFORM(0.0::FLOAT, 1.0::FLOAT, RANDOM()) * (p.TASA_INTERES_MAX - p.TASA_INTERES_MIN)), 2) as TASA_INTERES,
    CASE 
        WHEN c.SCORE_RIESGO >= p.SCORE_MINIMO_REQUERIDO AND MOD(num, 10) < 7 
        THEN ROUND(p.MONTO_MINIMO + (UNIFORM(0.0::FLOAT, 1.0::FLOAT, RANDOM()) * (p.MONTO_MAXIMO - p.MONTO_MINIMO)), 2)
        ELSE 0
    END as MONTO_APROBADO,
    CASE 
        WHEN c.SCORE_RIESGO >= p.SCORE_MINIMO_REQUERIDO AND MOD(num, 10) < 7 THEN 'APROBADA'
        WHEN MOD(num, 10) = 7 THEN 'EN_REVISION'
        WHEN MOD(num, 10) = 8 THEN 'PENDIENTE_DOCUMENTOS'
        ELSE 'RECHAZADA'
    END as ESTATUS_SOLICITUD,
    DATEADD(hour, 24 + MOD(num, 96), DATEADD(day, -MOD(num, 730), CURRENT_DATE())) as FECHA_DECISION,
    'ANA' || LPAD((MOD(num, 20) + 1)::STRING, 3, '0') as ANALISTA_ID,
    CASE 
        WHEN c.SCORE_RIESGO < p.SCORE_MINIMO_REQUERIDO THEN 'Score de crédito insuficiente'
        WHEN MOD(num, 10) = 9 THEN 'Capacidad de pago insuficiente'
        ELSE NULL
    END as MOTIVO_RECHAZO
FROM NUMEROS
JOIN CLIENTES_LIST c ON c.idx = MOD(num, 1000)
JOIN PRODUCTOS_LIST p ON p.idx = MOD(num, 5);

-- 2.12 Generar Créditos Activos (1200 créditos de solicitudes aprobadas)
INSERT INTO CREDITOS
WITH SOLICITUDES_APROBADAS AS (
    SELECT 
        s.*,
        ROW_NUMBER() OVER (ORDER BY s.FECHA_SOLICITUD) as rn
    FROM SOLICITUDES s
    WHERE s.ESTATUS_SOLICITUD = 'APROBADA'
    LIMIT 1200
)
SELECT 
    'CRE' || LPAD(rn::STRING, 6, '0') as CREDITO_ID,
    SOLICITUD_ID,
    CLIENTE_ID,
    PRODUCTO_ID,
    DATEADD(day, 7, FECHA_DECISION) as FECHA_DESEMBOLSO,
    MONTO_APROBADO as MONTO_CREDITO,
    PLAZO_MESES,
    TASA_INTERES,
    -- Calcular pago mensual (fórmula de amortización)
    ROUND(MONTO_APROBADO * (TASA_INTERES/100/12) * POWER(1 + (TASA_INTERES/100/12), PLAZO_MESES) / 
          (POWER(1 + (TASA_INTERES/100/12), PLAZO_MESES) - 1), 2) as PAGO_MENSUAL,
    -- Saldo actual (simulando pagos realizados)
    ROUND(MONTO_APROBADO * (1 - (LEAST(MOD(rn, PLAZO_MESES), PLAZO_MESES) / PLAZO_MESES::FLOAT)), 2) as SALDO_ACTUAL,
    LEAST(MOD(rn, PLAZO_MESES), PLAZO_MESES) as PAGOS_REALIZADOS,
    CASE WHEN MOD(rn, 15) = 0 THEN FLOOR(UNIFORM(0, 3, RANDOM())) ELSE 0 END as PAGOS_ATRASADOS,
    CASE WHEN MOD(rn, 15) = 0 THEN FLOOR(UNIFORM(0, 60, RANDOM())) ELSE 0 END as DIAS_MORA,
    CASE 
        WHEN MOD(rn, 15) = 0 AND FLOOR(UNIFORM(0, 60, RANDOM())) > 90 THEN 'VENCIDO'
        WHEN MOD(rn, 15) = 0 THEN 'MORA'
        WHEN MOD(rn, PLAZO_MESES) >= PLAZO_MESES THEN 'LIQUIDADO'
        ELSE 'VIGENTE'
    END as ESTATUS_CREDITO,
    DATEADD(month, 1, CURRENT_DATE()) as FECHA_PROXIMO_PAGO
FROM SOLICITUDES_APROBADAS;

-- 2.13 Generar Transacciones (10,000 transacciones)
INSERT INTO TRANSACCIONES
WITH CREDITOS_LIST AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY CREDITO_ID) - 1 as idx,
        CREDITO_ID, 
        CLIENTE_ID, 
        PAGO_MENSUAL, 
        FECHA_DESEMBOLSO, 
        PLAZO_MESES
    FROM CREDITOS
),
NUMEROS AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY NULL)) - 1 as num 
    FROM TABLE(GENERATOR(ROWCOUNT => 10000))
),
BANCOS AS (
    SELECT ROW_NUMBER() OVER (ORDER BY 1) - 1 as idx, banco FROM VALUES
    ('BBVA México'), ('Citibanamex'), ('Santander México'), ('Banorte'), ('HSBC México'),
    ('Scotiabank'), ('Inbursa'), ('Banco Azteca'), ('BanBajío'), ('Banco del Bajío')
    AS t(banco)
)
SELECT 
    'TXN' || LPAD(num::STRING, 7, '0') as TRANSACCION_ID,
    c.CREDITO_ID,
    c.CLIENTE_ID,
    DATEADD(hour, MOD(num, 720), c.FECHA_DESEMBOLSO) as FECHA_TRANSACCION,
    CASE MOD(num, 10)
        WHEN 0 THEN 'DESEMBOLSO'
        WHEN 1 THEN 'PAGO_MENSUAL'
        WHEN 2 THEN 'PAGO_ANTICIPADO'
        WHEN 3 THEN 'PAGO_PARCIAL'
        WHEN 4 THEN 'CARGO_COMISION'
        WHEN 5 THEN 'CARGO_MORA'
        WHEN 6 THEN 'PAGO_TOTAL'
        WHEN 7 THEN 'AJUSTE'
        WHEN 8 THEN 'REEMBOLSO'
        ELSE 'OTROS'
    END as TIPO_TRANSACCION,
    CASE MOD(num, 10)
        WHEN 0 THEN c.PAGO_MENSUAL * c.PLAZO_MESES
        ELSE ROUND(c.PAGO_MENSUAL * (0.5 + UNIFORM(0.0::FLOAT, 1.5::FLOAT, RANDOM())), 2)
    END as MONTO,
    CASE MOD(num, 6)
        WHEN 0 THEN 'TRANSFERENCIA_SPEI'
        WHEN 1 THEN 'TARJETA_DEBITO'
        WHEN 2 THEN 'TARJETA_CREDITO'
        WHEN 3 THEN 'DOMICILIACION'
        WHEN 4 THEN 'EFECTIVO'
        ELSE 'CHEQUE'
    END as METODO_PAGO,
    'REF' || LPAD(MOD(num + 7, 9999999999)::STRING, 10, '0') as REFERENCIA,
    b.banco as BANCO_ORIGEN,
    LPAD(MOD(num, 10000000000)::STRING, 18, '0') as CUENTA_ORIGEN,
    CONCAT(
        MOD(num, 256)::STRING, '.', 
        MOD(num + 7, 256)::STRING, '.', 
        MOD(num + 13, 256)::STRING, '.', 
        MOD(num + 19, 256)::STRING
    ) as IP_ADDRESS,
    CASE MOD(num, 5)
        WHEN 0 THEN 'iPhone'
        WHEN 1 THEN 'Android'
        WHEN 2 THEN 'Web Desktop'
        WHEN 3 THEN 'iPad'
        ELSE 'Android Tablet'
    END as DISPOSITIVO,
    CONCAT(
        ROUND(19.0 + (UNIFORM(0.0::FLOAT, 2.5::FLOAT, RANDOM())), 6)::STRING, ', ', 
        ROUND(-99.0 + (UNIFORM(0.0::FLOAT, 2.5::FLOAT, RANDOM())), 6)::STRING
    ) as UBICACION_GPS,
    CASE 
        WHEN MOD(num, 50) = 0 THEN 'FALLIDA'
        WHEN MOD(num, 30) = 0 THEN 'PENDIENTE'
        ELSE 'EXITOSA'
    END as ESTATUS_TRANSACCION
FROM NUMEROS
JOIN CREDITOS_LIST c ON c.idx = MOD(num, 1200)
JOIN BANCOS b ON b.idx = MOD(num, 10);

-- 2.14 Generar Alertas de Fraude (200 alertas)
INSERT INTO ALERTAS_FRAUDE
WITH TRANSACCIONES_SOSPECHOSAS AS (
    SELECT 
        TRANSACCION_ID,
        CLIENTE_ID,
        FECHA_TRANSACCION,
        MONTO,
        METODO_PAGO,
        IP_ADDRESS,
        DISPOSITIVO,
        ROW_NUMBER() OVER (ORDER BY FECHA_TRANSACCION DESC) as rn
    FROM TRANSACCIONES
    WHERE UNIFORM(0.0::FLOAT, 100.0::FLOAT, RANDOM()) < 2 -- 2% de transacciones generan alertas
    LIMIT 200
)
SELECT 
    'ALT' || LPAD(rn::STRING, 6, '0') as ALERTA_ID,
    TRANSACCION_ID,
    CLIENTE_ID,
    DATEADD(minute, 5, FECHA_TRANSACCION) as FECHA_ALERTA,
    CASE MOD(rn, 8)
        WHEN 0 THEN 'Transacción duplicada'
        WHEN 1 THEN 'Monto inusual'
        WHEN 2 THEN 'Ubicación geográfica sospechosa'
        WHEN 3 THEN 'Dispositivo no reconocido'
        WHEN 4 THEN 'Múltiples intentos fallidos'
        WHEN 5 THEN 'Cambio de IP frecuente'
        WHEN 6 THEN 'Horario inusual'
        ELSE 'Patrón de comportamiento anómalo'
    END as TIPO_ALERTA,
    CASE 
        WHEN MOD(rn, 3) = 0 THEN 'ALTO'
        WHEN MOD(rn, 3) = 1 THEN 'MEDIO'
        ELSE 'BAJO'
    END as NIVEL_RIESGO,
    ROUND(60 + UNIFORM(0.0::FLOAT, 40.0::FLOAT, RANDOM()), 2) as SCORE_FRAUDE,
    'REGLA_FRAUDE_' || LPAD(MOD(rn, 25)::STRING, 3, '0') as REGLA_ACTIVADA,
    'Alerta generada automáticamente por el sistema de detección de fraude' as DESCRIPCION,
    CASE MOD(rn, 5)
        WHEN 0 THEN 'NUEVA'
        WHEN 1 THEN 'EN_REVISION'
        WHEN 2 THEN 'CONFIRMADO_FRAUDE'
        WHEN 3 THEN 'FALSO_POSITIVO'
        ELSE 'CERRADA'
    END as ESTATUS_ALERTA,
    'ANALISTA_FRAUDE_' || LPAD((MOD(rn, 10) + 1)::STRING, 2, '0') as ANALISTA_ASIGNADO,
    CASE 
        WHEN MOD(rn, 5) IN (2, 3, 4) THEN DATEADD(hour, 24 + MOD(rn, 72), FECHA_TRANSACCION)
        ELSE NULL
    END as FECHA_RESOLUCION,
    CASE MOD(rn, 5)
        WHEN 2 THEN 'Cuenta bloqueada - fraude confirmado'
        WHEN 3 THEN 'Sin acción - falso positivo'
        WHEN 4 THEN 'Contacto con cliente - transacción legítima'
        ELSE NULL
    END as ACCION_TOMADA
FROM TRANSACCIONES_SOSPECHOSAS;

-- 2.15 Generar Eventos de Cumplimiento (1500 eventos)
INSERT INTO COMPLIANCE.EVENTOS_CUMPLIMIENTO
WITH CLIENTES_LIST AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY CLIENTE_ID) - 1 as idx,
        CLIENTE_ID, 
        FECHA_REGISTRO 
    FROM CLIENTES
),
NUMEROS AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY NULL)) - 1 as num 
    FROM TABLE(GENERATOR(ROWCOUNT => 1500))
)
SELECT 
    'EVT' || LPAD(num::STRING, 6, '0') as EVENTO_ID,
    c.CLIENTE_ID,
    DATEADD(day, MOD(num, 365), c.FECHA_REGISTRO) as FECHA_EVENTO,
    CASE MOD(num, 6)
        WHEN 0 THEN 'Verificación KYC inicial'
        WHEN 1 THEN 'Actualización de documentos'
        WHEN 2 THEN 'Revisión de listas PLD'
        WHEN 3 THEN 'Validación de identidad'
        WHEN 4 THEN 'Verificación de domicilio'
        ELSE 'Monitoreo continuo'
    END as TIPO_EVENTO,
    'Evento de cumplimiento regulatorio generado automáticamente' as DESCRIPCION,
    CASE 
        WHEN MOD(num, 20) = 0 THEN 'RECHAZADO'
        WHEN MOD(num, 15) = 0 THEN 'PENDIENTE'
        ELSE 'APROBADO'
    END as RESULTADO,
    ARRAY_CONSTRUCT(
        'INE', 'Comprobante domicilio', 'RFC', 
        CASE WHEN MOD(num, 2) = 0 THEN 'CURP' END,
        CASE WHEN MOD(num, 3) = 0 THEN 'Estado de cuenta' END
    ) as DOCUMENTOS_VALIDADOS,
    ARRAY_CONSTRUCT(
        'OFAC', 'PEP', 'Lista bloqueados CNBV',
        CASE WHEN MOD(num, 2) = 0 THEN 'Interpol' END
    ) as LISTAS_VERIFICADAS,
    'OFICIAL_CUMPLIMIENTO_' || LPAD((MOD(num, 15) + 1)::STRING, 2, '0') as OFICIAL_CUMPLIMIENTO,
    CASE 
        WHEN MOD(num, 20) = 0 THEN 'Documentos insuficientes o ilegibles'
        WHEN MOD(num, 15) = 0 THEN 'Pendiente de validación adicional'
        ELSE 'Cumplimiento verificado exitosamente'
    END as COMENTARIOS
FROM NUMEROS
JOIN CLIENTES_LIST c ON c.idx = MOD(num, 1000);

-- 2.16 Generar Rentabilidad por Cliente
INSERT INTO ANALYTICS.RENTABILIDAD_CLIENTES
WITH CLIENTES_CON_CREDITOS AS (
    SELECT 
        c.CLIENTE_ID,
        SUM(CASE WHEN t.TIPO_TRANSACCION IN ('PAGO_MENSUAL', 'PAGO_ANTICIPADO', 'PAGO_TOTAL') THEN t.MONTO ELSE 0 END) as total_pagos,
        COUNT(DISTINCT cr.CREDITO_ID) as num_creditos,
        AVG(cr.TASA_INTERES) as tasa_promedio
    FROM CORE.CLIENTES c
    LEFT JOIN CORE.CREDITOS cr ON c.CLIENTE_ID = cr.CLIENTE_ID
    LEFT JOIN CORE.TRANSACCIONES t ON cr.CREDITO_ID = t.CREDITO_ID
    GROUP BY c.CLIENTE_ID
)
SELECT 
    c.CLIENTE_ID,
    CURRENT_DATE() as FECHA_CALCULO,
    COALESCE(cc.total_pagos, 0) as INGRESOS_TOTALES,
    ROUND(COALESCE(cc.total_pagos, 0) * 0.65, 2) as INTERESES_COBRADOS,
    ROUND(COALESCE(cc.total_pagos, 0) * 0.15, 2) as COMISIONES_COBRADAS,
    ROUND(COALESCE(cc.total_pagos, 0) * 0.25, 2) as COSTOS_OPERATIVOS,
    ROUND(COALESCE(cc.total_pagos, 0) * 0.18, 2) as COSTOS_RIESGO,
    ROUND(COALESCE(cc.total_pagos, 0) * 0.37, 2) as UTILIDAD_NETA,
    ROUND((COALESCE(cc.total_pagos, 0) * 0.37) / NULLIF(COALESCE(cc.total_pagos, 0), 0) * 100, 2) as MARGEN_RENTABILIDAD,
    ROUND(COALESCE(cc.total_pagos, 0) * (cc.num_creditos * 1.5), 2) as LTV_ESTIMADO,
    ROUND(2500 + UNIFORM(0.0::FLOAT, 2000.0::FLOAT, RANDOM()), 2) as CAC,
    ROUND((COALESCE(cc.total_pagos, 0) * (cc.num_creditos * 1.5)) / (2500 + UNIFORM(0.0::FLOAT, 2000.0::FLOAT, RANDOM())), 2) as RATIO_LTV_CAC,
    CASE 
        WHEN COALESCE(cc.total_pagos, 0) > 100000 THEN 'Alto Valor'
        WHEN COALESCE(cc.total_pagos, 0) > 50000 THEN 'Medio Valor'
        WHEN COALESCE(cc.total_pagos, 0) > 10000 THEN 'Valor Estándar'
        ELSE 'Bajo Valor'
    END as SEGMENTO_RENTABILIDAD
FROM CORE.CLIENTES c
LEFT JOIN CLIENTES_CON_CREDITOS cc ON c.CLIENTE_ID = cc.CLIENTE_ID;

--------------------------------------------------------------------------------
-- SECCIÓN 3: LA DEMO - CONSULTAS DE ANÁLISIS Y VALOR
--------------------------------------------------------------------------------

/*
En esta sección demostramos el valor de Snowflake para AgilCredit a través
de consultas analíticas que responden preguntas clave del negocio.
*/

-- ============================================================================
-- 3.1 ANÁLISIS DE RIESGO CREDITICIO
-- ============================================================================

-- Vista: Matriz de Riesgo por Segmento
CREATE OR REPLACE VIEW ANALYTICS.V_MATRIZ_RIESGO AS
WITH RIESGO_POR_CLIENTE AS (
    SELECT 
        c.CLIENTE_ID,
        c.SEGMENTO_CLIENTE,
        c.CALIFICACION_BURO,
        c.SCORE_RIESGO,
        c.INGRESO_MENSUAL,
        COUNT(DISTINCT cr.CREDITO_ID) as TOTAL_CREDITOS,
        SUM(cr.MONTO_CREDITO) as EXPOSICION_TOTAL,
        SUM(cr.SALDO_ACTUAL) as SALDO_PENDIENTE,
        AVG(cr.DIAS_MORA) as PROMEDIO_DIAS_MORA,
        SUM(CASE WHEN cr.ESTATUS_CREDITO IN ('MORA', 'VENCIDO') THEN 1 ELSE 0 END) as CREDITOS_PROBLEMATICOS
    FROM CLIENTES c
    LEFT JOIN CREDITOS cr ON c.CLIENTE_ID = cr.CLIENTE_ID
    GROUP BY 1,2,3,4,5
)
SELECT 
    SEGMENTO_CLIENTE,
    COUNT(DISTINCT CLIENTE_ID) as TOTAL_CLIENTES,
    ROUND(AVG(CALIFICACION_BURO), 0) as SCORE_BURO_PROMEDIO,
    ROUND(AVG(SCORE_RIESGO), 2) as SCORE_RIESGO_PROMEDIO,
    ROUND(SUM(EXPOSICION_TOTAL), 2) as EXPOSICION_TOTAL_SEGMENTO,
    ROUND(SUM(SALDO_PENDIENTE), 2) as SALDO_PENDIENTE_TOTAL,
    ROUND(AVG(PROMEDIO_DIAS_MORA), 1) as DIAS_MORA_PROMEDIO,
    ROUND(SUM(CREDITOS_PROBLEMATICOS) * 100.0 / NULLIF(SUM(TOTAL_CREDITOS), 0), 2) as TASA_MOROSIDAD_PCT,
    ROUND(SUM(CREDITOS_PROBLEMATICOS) * 100.0 / NULLIF(COUNT(DISTINCT CLIENTE_ID), 0), 2) as CLIENTES_PROBLEMATICOS_PCT
FROM RIESGO_POR_CLIENTE
GROUP BY SEGMENTO_CLIENTE
ORDER BY EXPOSICION_TOTAL_SEGMENTO DESC;

-- Consulta: Top 20 Clientes de Mayor Riesgo
SELECT 
    c.CLIENTE_ID,
    c.NOMBRE || ' ' || c.APELLIDO_PATERNO || ' ' || c.APELLIDO_MATERNO as NOMBRE_COMPLETO,
    c.CALIFICACION_BURO,
    c.SCORE_RIESGO,
    c.SEGMENTO_CLIENTE,
    COUNT(DISTINCT cr.CREDITO_ID) as CREDITOS_ACTIVOS,
    SUM(cr.SALDO_ACTUAL) as SALDO_TOTAL,
    MAX(cr.DIAS_MORA) as MAX_DIAS_MORA,
    SUM(CASE WHEN cr.ESTATUS_CREDITO = 'VENCIDO' THEN 1 ELSE 0 END) as CREDITOS_VENCIDOS,
    COUNT(DISTINCT af.ALERTA_ID) as ALERTAS_FRAUDE
FROM CLIENTES c
JOIN CREDITOS cr ON c.CLIENTE_ID = cr.CLIENTE_ID
LEFT JOIN ALERTAS_FRAUDE af ON c.CLIENTE_ID = af.CLIENTE_ID
WHERE cr.ESTATUS_CREDITO IN ('VIGENTE', 'MORA', 'VENCIDO')
GROUP BY 1,2,3,4,5
HAVING SUM(cr.SALDO_ACTUAL) > 0
ORDER BY 
    CREDITOS_VENCIDOS DESC,
    MAX_DIAS_MORA DESC,
    SALDO_TOTAL DESC
LIMIT 20;

-- ============================================================================
-- 3.2 DETECCIÓN DE FRAUDE
-- ============================================================================

-- Vista: Dashboard de Fraude
CREATE OR REPLACE VIEW ANALYTICS.V_DASHBOARD_FRAUDE AS
SELECT 
    DATE_TRUNC('day', af.FECHA_ALERTA) as FECHA,
    af.TIPO_ALERTA,
    af.NIVEL_RIESGO,
    COUNT(DISTINCT af.ALERTA_ID) as TOTAL_ALERTAS,
    COUNT(DISTINCT af.CLIENTE_ID) as CLIENTES_AFECTADOS,
    COUNT(DISTINCT af.TRANSACCION_ID) as TRANSACCIONES_INVOLUCRADAS,
    ROUND(AVG(af.SCORE_FRAUDE), 2) as SCORE_FRAUDE_PROMEDIO,
    SUM(CASE WHEN af.ESTATUS_ALERTA = 'CONFIRMADO_FRAUDE' THEN 1 ELSE 0 END) as FRAUDES_CONFIRMADOS,
    SUM(CASE WHEN af.ESTATUS_ALERTA = 'FALSO_POSITIVO' THEN 1 ELSE 0 END) as FALSOS_POSITIVOS,
    SUM(CASE WHEN af.ESTATUS_ALERTA IN ('NUEVA', 'EN_REVISION') THEN 1 ELSE 0 END) as ALERTAS_PENDIENTES,
    ROUND(SUM(CASE WHEN af.ESTATUS_ALERTA = 'CONFIRMADO_FRAUDE' THEN 1 ELSE 0 END) * 100.0 / 
          NULLIF(COUNT(af.ALERTA_ID), 0), 2) as TASA_CONFIRMACION_PCT
FROM ALERTAS_FRAUDE af
GROUP BY 1,2,3
ORDER BY FECHA DESC, TOTAL_ALERTAS DESC;

-- Consulta: Análisis de Patrones de Fraude por Dispositivo y Método de Pago
SELECT 
    t.DISPOSITIVO,
    t.METODO_PAGO,
    COUNT(DISTINCT t.TRANSACCION_ID) as TOTAL_TRANSACCIONES,
    COUNT(DISTINCT af.ALERTA_ID) as ALERTAS_GENERADAS,
    ROUND(COUNT(DISTINCT af.ALERTA_ID) * 100.0 / NULLIF(COUNT(DISTINCT t.TRANSACCION_ID), 0), 2) as TASA_ALERTA_PCT,
    COUNT(DISTINCT CASE WHEN af.ESTATUS_ALERTA = 'CONFIRMADO_FRAUDE' THEN af.ALERTA_ID END) as FRAUDES_CONFIRMADOS,
    ROUND(SUM(CASE WHEN af.ESTATUS_ALERTA = 'CONFIRMADO_FRAUDE' THEN t.MONTO ELSE 0 END), 2) as MONTO_FRAUDE_TOTAL,
    ROUND(AVG(CASE WHEN af.ALERTA_ID IS NOT NULL THEN af.SCORE_FRAUDE END), 2) as SCORE_FRAUDE_PROMEDIO
FROM TRANSACCIONES t
LEFT JOIN ALERTAS_FRAUDE af ON t.TRANSACCION_ID = af.TRANSACCION_ID
GROUP BY 1,2
HAVING COUNT(DISTINCT af.ALERTA_ID) > 0
ORDER BY FRAUDES_CONFIRMADOS DESC, TASA_ALERTA_PCT DESC;

-- ============================================================================
-- 3.3 RENTABILIDAD DE CLIENTES
-- ============================================================================

-- Vista: Análisis LTV/CAC por Segmento
CREATE OR REPLACE VIEW ANALYTICS.V_RENTABILIDAD_SEGMENTOS AS
SELECT 
    c.SEGMENTO_CLIENTE,
    r.SEGMENTO_RENTABILIDAD,
    COUNT(DISTINCT c.CLIENTE_ID) as TOTAL_CLIENTES,
    ROUND(SUM(r.INGRESOS_TOTALES), 2) as INGRESOS_TOTALES,
    ROUND(SUM(r.INTERESES_COBRADOS), 2) as INTERESES_TOTALES,
    ROUND(SUM(r.COMISIONES_COBRADAS), 2) as COMISIONES_TOTALES,
    ROUND(SUM(r.UTILIDAD_NETA), 2) as UTILIDAD_NETA_TOTAL,
    ROUND(AVG(r.MARGEN_RENTABILIDAD), 2) as MARGEN_PROMEDIO_PCT,
    ROUND(AVG(r.LTV_ESTIMADO), 2) as LTV_PROMEDIO,
    ROUND(AVG(r.CAC), 2) as CAC_PROMEDIO,
    ROUND(AVG(r.RATIO_LTV_CAC), 2) as RATIO_LTV_CAC_PROMEDIO,
    ROUND(SUM(r.UTILIDAD_NETA) / NULLIF(COUNT(DISTINCT c.CLIENTE_ID), 0), 2) as UTILIDAD_POR_CLIENTE
FROM CLIENTES c
JOIN RENTABILIDAD_CLIENTES r ON c.CLIENTE_ID = r.CLIENTE_ID
GROUP BY 1,2
ORDER BY UTILIDAD_NETA_TOTAL DESC;

-- Consulta: Top 50 Clientes Más Rentables
SELECT 
    c.CLIENTE_ID,
    c.NOMBRE || ' ' || c.APELLIDO_PATERNO as NOMBRE_COMPLETO,
    c.SEGMENTO_CLIENTE,
    c.ESTADO,
    c.OCUPACION,
    c.INGRESO_MENSUAL,
    r.INGRESOS_TOTALES,
    r.UTILIDAD_NETA,
    r.MARGEN_RENTABILIDAD,
    r.LTV_ESTIMADO,
    r.CAC,
    r.RATIO_LTV_CAC,
    r.SEGMENTO_RENTABILIDAD,
    COUNT(DISTINCT cr.CREDITO_ID) as TOTAL_CREDITOS,
    DATEDIFF(month, c.FECHA_REGISTRO, CURRENT_DATE()) as MESES_COMO_CLIENTE
FROM CLIENTES c
JOIN RENTABILIDAD_CLIENTES r ON c.CLIENTE_ID = r.CLIENTE_ID
LEFT JOIN CREDITOS cr ON c.CLIENTE_ID = cr.CLIENTE_ID
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
ORDER BY r.UTILIDAD_NETA DESC
LIMIT 50;

-- ============================================================================
-- 3.4 CUMPLIMIENTO REGULATORIO
-- ============================================================================

-- Vista: Status de Cumplimiento KYC/PLD
CREATE OR REPLACE VIEW COMPLIANCE.V_STATUS_CUMPLIMIENTO AS
SELECT 
    c.CLIENTE_ID,
    c.NOMBRE || ' ' || c.APELLIDO_PATERNO || ' ' || c.APELLIDO_MATERNO as NOMBRE_COMPLETO,
    c.RFC,
    c.FECHA_REGISTRO,
    COUNT(DISTINCT ec.EVENTO_ID) as EVENTOS_CUMPLIMIENTO,
    MAX(ec.FECHA_EVENTO) as ULTIMA_VERIFICACION,
    DATEDIFF(day, MAX(ec.FECHA_EVENTO), CURRENT_DATE()) as DIAS_DESDE_VERIFICACION,
    SUM(CASE WHEN ec.RESULTADO = 'APROBADO' THEN 1 ELSE 0 END) as VERIFICACIONES_APROBADAS,
    SUM(CASE WHEN ec.RESULTADO = 'RECHAZADO' THEN 1 ELSE 0 END) as VERIFICACIONES_RECHAZADAS,
    SUM(CASE WHEN ec.RESULTADO = 'PENDIENTE' THEN 1 ELSE 0 END) as VERIFICACIONES_PENDIENTES,
    CASE 
        WHEN SUM(CASE WHEN ec.RESULTADO = 'PENDIENTE' THEN 1 ELSE 0 END) > 0 THEN 'PENDIENTE'
        WHEN DATEDIFF(day, MAX(ec.FECHA_EVENTO), CURRENT_DATE()) > 365 THEN 'REQUIERE_ACTUALIZACION'
        WHEN SUM(CASE WHEN ec.RESULTADO = 'RECHAZADO' THEN 1 ELSE 0 END) > 0 THEN 'INCOMPLETO'
        ELSE 'CUMPLE'
    END as STATUS_CUMPLIMIENTO,
    COUNT(DISTINCT cr.CREDITO_ID) as CREDITOS_ACTIVOS,
    SUM(cr.SALDO_ACTUAL) as EXPOSICION_TOTAL
FROM CLIENTES c
LEFT JOIN EVENTOS_CUMPLIMIENTO ec ON c.CLIENTE_ID = ec.CLIENTE_ID
LEFT JOIN CREDITOS cr ON c.CLIENTE_ID = cr.CLIENTE_ID AND cr.ESTATUS_CREDITO IN ('VIGENTE', 'MORA')
GROUP BY 1,2,3,4
ORDER BY EXPOSICION_TOTAL DESC;

-- Consulta: Reporte de Clientes que Requieren Actualización KYC
SELECT 
    CLIENTE_ID,
    NOMBRE_COMPLETO,
    RFC,
    FECHA_REGISTRO,
    ULTIMA_VERIFICACION,
    DIAS_DESDE_VERIFICACION,
    STATUS_CUMPLIMIENTO,
    CREDITOS_ACTIVOS,
    EXPOSICION_TOTAL,
    CASE 
        WHEN DIAS_DESDE_VERIFICACION > 730 THEN 'URGENTE'
        WHEN DIAS_DESDE_VERIFICACION > 365 THEN 'ALTA'
        ELSE 'MEDIA'
    END as PRIORIDAD
FROM COMPLIANCE.V_STATUS_CUMPLIMIENTO
WHERE STATUS_CUMPLIMIENTO IN ('REQUIERE_ACTUALIZACION', 'PENDIENTE', 'INCOMPLETO')
    AND CREDITOS_ACTIVOS > 0
ORDER BY 
    CASE WHEN DIAS_DESDE_VERIFICACION > 730 THEN 1
         WHEN DIAS_DESDE_VERIFICACION > 365 THEN 2
         ELSE 3 END,
    EXPOSICION_TOTAL DESC;

-- ============================================================================
-- 3.5 DASHBOARD EJECUTIVO - KPIs PRINCIPALES
-- ============================================================================

-- Vista: KPIs Ejecutivos
CREATE OR REPLACE VIEW ANALYTICS.V_KPIS_EJECUTIVOS AS
WITH METRICAS_BASE AS (
    SELECT 
        -- Clientes
        COUNT(DISTINCT c.CLIENTE_ID) as total_clientes,
        COUNT(DISTINCT CASE WHEN c.ESTATUS = 'ACTIVO' THEN c.CLIENTE_ID END) as clientes_activos,
        
        -- Créditos
        COUNT(DISTINCT cr.CREDITO_ID) as total_creditos,
        COUNT(DISTINCT CASE WHEN cr.ESTATUS_CREDITO = 'VIGENTE' THEN cr.CREDITO_ID END) as creditos_vigentes,
        SUM(cr.MONTO_CREDITO) as monto_total_desembolsado,
        SUM(cr.SALDO_ACTUAL) as cartera_total,
        
        -- Morosidad
        COUNT(DISTINCT CASE WHEN cr.ESTATUS_CREDITO IN ('MORA', 'VENCIDO') THEN cr.CREDITO_ID END) as creditos_morosos,
        SUM(CASE WHEN cr.ESTATUS_CREDITO IN ('MORA', 'VENCIDO') THEN cr.SALDO_ACTUAL ELSE 0 END) as cartera_vencida,
        
        -- Transacciones
        COUNT(DISTINCT t.TRANSACCION_ID) as total_transacciones,
        SUM(t.MONTO) as volumen_transacciones,
        
        -- Fraude
        COUNT(DISTINCT af.ALERTA_ID) as total_alertas_fraude,
        COUNT(DISTINCT CASE WHEN af.ESTATUS_ALERTA = 'CONFIRMADO_FRAUDE' THEN af.ALERTA_ID END) as fraudes_confirmados,
        
        -- Rentabilidad
        SUM(r.UTILIDAD_NETA) as utilidad_neta_total,
        AVG(r.RATIO_LTV_CAC) as ratio_ltv_cac_promedio
        
    FROM CLIENTES c
    LEFT JOIN CREDITOS cr ON c.CLIENTE_ID = cr.CLIENTE_ID
    LEFT JOIN TRANSACCIONES t ON cr.CREDITO_ID = t.CREDITO_ID
    LEFT JOIN ALERTAS_FRAUDE af ON t.TRANSACCION_ID = af.TRANSACCION_ID
    LEFT JOIN RENTABILIDAD_CLIENTES r ON c.CLIENTE_ID = r.CLIENTE_ID
)
SELECT 
    -- Clientes
    total_clientes as "Total Clientes",
    clientes_activos as "Clientes Activos",
    ROUND(clientes_activos * 100.0 / NULLIF(total_clientes, 0), 2) as "% Clientes Activos",
    
    -- Cartera
    ROUND(monto_total_desembolsado, 2) as "Monto Total Desembolsado",
    ROUND(cartera_total, 2) as "Cartera Total",
    ROUND(cartera_vencida, 2) as "Cartera Vencida",
    ROUND(cartera_vencida * 100.0 / NULLIF(cartera_total, 0), 2) as "% Morosidad (IMOR)",
    
    -- Créditos
    total_creditos as "Total Créditos",
    creditos_vigentes as "Créditos Vigentes",
    creditos_morosos as "Créditos en Mora",
    
    -- Transacciones
    total_transacciones as "Total Transacciones",
    ROUND(volumen_transacciones, 2) as "Volumen Transacciones",
    ROUND(volumen_transacciones / NULLIF(total_transacciones, 0), 2) as "Ticket Promedio",
    
    -- Fraude
    total_alertas_fraude as "Alertas de Fraude",
    fraudes_confirmados as "Fraudes Confirmados",
    ROUND(fraudes_confirmados * 100.0 / NULLIF(total_alertas_fraude, 0), 2) as "% Tasa Confirmación Fraude",
    
    -- Rentabilidad
    ROUND(utilidad_neta_total, 2) as "Utilidad Neta Total",
    ROUND(utilidad_neta_total / NULLIF(clientes_activos, 0), 2) as "Utilidad por Cliente",
    ROUND(ratio_ltv_cac_promedio, 2) as "Ratio LTV/CAC Promedio"
    
FROM METRICAS_BASE;

-- Consultar KPIs Ejecutivos
SELECT * FROM ANALYTICS.V_KPIS_EJECUTIVOS;

-- ============================================================================
-- 3.6 ANÁLISIS DE COSTOS (FinOps)
-- ============================================================================

-- Vista: Monitoreo de Costos de Warehouse
CREATE OR REPLACE VIEW ANALYTICS.V_COSTOS_WAREHOUSE AS
SELECT 
    WAREHOUSE_NAME,
    START_TIME,
    END_TIME,
    CREDITS_USED,
    ROUND(CREDITS_USED * 2.5, 2) as COSTO_USD_ESTIMADO, -- Asumiendo $2.5 USD por crédito
    EXECUTION_STATUS,
    QUERY_ID,
    QUERY_TYPE,
    TOTAL_ELAPSED_TIME / 1000 as SEGUNDOS_EJECUCION
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METRICSHISTORY
WHERE WAREHOUSE_NAME = 'AGILCREDIT_WH'
    AND START_TIME >= DATEADD(day, -30, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC;

-- Consulta: Resumen de Costos por Día
SELECT 
    DATE_TRUNC('day', START_TIME) as FECHA,
    COUNT(DISTINCT QUERY_ID) as TOTAL_CONSULTAS,
    ROUND(SUM(CREDITS_USED), 4) as CREDITOS_USADOS,
    ROUND(SUM(CREDITS_USED) * 2.5, 2) as COSTO_USD_ESTIMADO,
    ROUND(AVG(TOTAL_ELAPSED_TIME) / 1000, 2) as TIEMPO_PROMEDIO_SEG
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE WAREHOUSE_NAME = 'AGILCREDIT_WH'
    AND START_TIME >= DATEADD(day, -30, CURRENT_TIMESTAMP())
GROUP BY 1
ORDER BY 1 DESC;

/*******************************************************************************
 * FIN DEL WORKSHEET - AGILCREDIT DEMO
 * 
 * RESUMEN:
 * - 1,000 clientes sintéticos
 * - 5 productos crediticios
 * - 2,000 solicitudes
 * - 1,200 créditos activos
 * - 10,000 transacciones
 * - 200 alertas de fraude
 * - 1,500 eventos de cumplimiento
 * 
 * CASOS DE USO CUBIERTOS:
 * ✓ Análisis de Riesgo Crediticio
 * ✓ Detección de Fraude
 * ✓ Rentabilidad de Clientes
 * ✓ Cumplimiento Regulatorio (KYC/PLD)
 * ✓ Dashboard Ejecutivo con KPIs
 * ✓ Monitoreo de Costos (FinOps)
 ******************************************************************************/

-- ============================================================================
-- SECCIÓN 4: QUERIES DE DIAGNÓSTICO (Ejecutar para verificar datos)
-- ============================================================================

-- 4.1 Verificar conteos de todas las tablas
SELECT 'CLIENTES' as TABLA, COUNT(*) as REGISTROS FROM CORE.CLIENTES
UNION ALL
SELECT 'PRODUCTOS', COUNT(*) FROM CORE.PRODUCTOS
UNION ALL
SELECT 'SOLICITUDES', COUNT(*) FROM CORE.SOLICITUDES
UNION ALL
SELECT 'CREDITOS', COUNT(*) FROM CORE.CREDITOS
UNION ALL
SELECT 'TRANSACCIONES', COUNT(*) FROM CORE.TRANSACCIONES
UNION ALL
SELECT 'ALERTAS_FRAUDE', COUNT(*) FROM CORE.ALERTAS_FRAUDE
UNION ALL
SELECT 'EVENTOS_CUMPLIMIENTO', COUNT(*) FROM COMPLIANCE.EVENTOS_CUMPLIMIENTO
UNION ALL
SELECT 'RENTABILIDAD_CLIENTES', COUNT(*) FROM ANALYTICS.RENTABILIDAD_CLIENTES;

-- 4.2 Verificar distribución de scores en CLIENTES
SELECT 
    MIN(CALIFICACION_BURO) as MIN_BURO,
    MAX(CALIFICACION_BURO) as MAX_BURO,
    ROUND(AVG(CALIFICACION_BURO), 2) as AVG_BURO,
    MIN(SCORE_RIESGO) as MIN_SCORE,
    MAX(SCORE_RIESGO) as MAX_SCORE,
    ROUND(AVG(SCORE_RIESGO), 2) as AVG_SCORE
FROM CORE.CLIENTES;

-- 4.3 Verificar estatus de solicitudes
SELECT 
    ESTATUS_SOLICITUD,
    COUNT(*) as CANTIDAD,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as PORCENTAJE
FROM CORE.SOLICITUDES
GROUP BY ESTATUS_SOLICITUD
ORDER BY CANTIDAD DESC;

-- 4.4 Verificar si hay solicitudes aprobadas que cumplan criterios
SELECT 
    s.SOLICITUD_ID,
    s.CLIENTE_ID,
    s.ESTATUS_SOLICITUD,
    c.SCORE_RIESGO,
    p.SCORE_MINIMO_REQUERIDO,
    CASE WHEN c.SCORE_RIESGO >= p.SCORE_MINIMO_REQUERIDO THEN 'SÍ CALIFICA' ELSE 'NO CALIFICA' END as CALIFICA
FROM CORE.SOLICITUDES s
JOIN CORE.CLIENTES c ON s.CLIENTE_ID = c.CLIENTE_ID
JOIN CORE.PRODUCTOS p ON s.PRODUCTO_ID = p.PRODUCTO_ID
WHERE s.ESTATUS_SOLICITUD = 'APROBADA'
LIMIT 10;

