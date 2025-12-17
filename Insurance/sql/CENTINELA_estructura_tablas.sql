-- ============================================================================
-- SEGUROS CENTINELA - ESTRUCTURA DE BASE DE DATOS
-- ============================================================================
-- Empresa: Seguros Centinela S.A. de C.V.
-- Descripción: Aseguradora ficticia especializada en seguros de autos y GMM
-- Autor: Ingeniero de Datos
-- Fecha: 2024
-- ============================================================================

-- ============================================================================
-- SECCIÓN 0: HISTORIA Y CASO DE USO
-- ============================================================================
/*
    SEGUROS CENTINELA S.A. de C.V.
    
    Fundada en 1985, Seguros Centinela es una aseguradora mexicana líder en el
    mercado de seguros personales. Con más de 38 años de experiencia, ofrece
    productos de alta calidad en:
    
    - Seguros de Automóviles (Cobertura Amplia, Limitada, RC)
    - Gastos Médicos Mayores (Individual y Familiar)
    
    Este modelo de datos soporta:
    - Gestión completa de pólizas
    - Administración de clientes y beneficiarios
    - Control de siniestros y reclamaciones
    - Seguimiento de pagos y cobranza
    - Gestión de agentes y comisiones
*/

-- ============================================================================
-- SECCIÓN 1: CONFIGURACIÓN DE RECURSOS
-- ============================================================================

-- Crear base de datos
CREATE OR REPLACE DATABASE CENTINELA_DB
    COMMENT = 'Base de datos principal de Seguros Centinela';

-- Usar la base de datos
USE DATABASE CENTINELA_DB;

-- Crear schemas organizados por dominio
CREATE OR REPLACE SCHEMA CENTINELA_DB.CORE
    COMMENT = 'Tablas principales del negocio';

CREATE OR REPLACE SCHEMA CENTINELA_DB.AUTOS
    COMMENT = 'Datos específicos de seguros de automóviles';

CREATE OR REPLACE SCHEMA CENTINELA_DB.GMM
    COMMENT = 'Datos específicos de Gastos Médicos Mayores';

CREATE OR REPLACE SCHEMA CENTINELA_DB.OPERACIONES
    COMMENT = 'Siniestros, pagos y operaciones';

-- Warehouse para operaciones
CREATE OR REPLACE WAREHOUSE CENTINELA_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse operacional de Seguros Centinela';

USE WAREHOUSE CENTINELA_WH;
USE SCHEMA CENTINELA_DB.CORE;

-- ============================================================================
-- SECCIÓN 2: TABLAS CORE (Núcleo del Negocio)
-- ============================================================================

-- -----------------------------------------------------------------------------
-- TABLA: AGENTES - Fuerza de ventas
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.CORE.AGENTES (
    agente_id               VARCHAR(10)     PRIMARY KEY,
    nombre                  VARCHAR(100)    NOT NULL,
    apellido_paterno        VARCHAR(100)    NOT NULL,
    apellido_materno        VARCHAR(100),
    email                   VARCHAR(150)    NOT NULL,
    telefono                VARCHAR(15),
    fecha_ingreso           DATE            NOT NULL,
    sucursal                VARCHAR(50)     NOT NULL,
    region                  VARCHAR(50)     NOT NULL,
    nivel                   VARCHAR(20)     DEFAULT 'Junior',  -- Junior, Senior, Ejecutivo
    comision_porcentaje     DECIMAL(5,2)    DEFAULT 10.00,
    activo                  BOOLEAN         DEFAULT TRUE,
    fecha_creacion          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    fecha_actualizacion     TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Catálogo de agentes de ventas de la aseguradora';

-- -----------------------------------------------------------------------------
-- TABLA: CLIENTES - Asegurados/Contratantes
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.CORE.CLIENTES (
    cliente_id              VARCHAR(15)     PRIMARY KEY,
    tipo_persona            VARCHAR(10)     NOT NULL,  -- Fisica, Moral
    nombre                  VARCHAR(100)    NOT NULL,
    apellido_paterno        VARCHAR(100),
    apellido_materno        VARCHAR(100),
    razon_social            VARCHAR(200),
    rfc                     VARCHAR(13)     NOT NULL UNIQUE,
    curp                    VARCHAR(18),
    fecha_nacimiento        DATE,
    genero                  VARCHAR(1),     -- M, F
    estado_civil            VARCHAR(20),
    email                   VARCHAR(150),
    telefono_celular        VARCHAR(15),
    telefono_fijo           VARCHAR(15),
    calle                   VARCHAR(200),
    numero_exterior         VARCHAR(20),
    numero_interior         VARCHAR(20),
    colonia                 VARCHAR(100),
    codigo_postal           VARCHAR(5),
    municipio               VARCHAR(100),
    estado                  VARCHAR(50),
    pais                    VARCHAR(50)     DEFAULT 'México',
    fecha_alta              DATE            DEFAULT CURRENT_DATE(),
    agente_id               VARCHAR(10)     REFERENCES CENTINELA_DB.CORE.AGENTES(agente_id),
    activo                  BOOLEAN         DEFAULT TRUE,
    fecha_creacion          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    fecha_actualizacion     TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Catálogo maestro de clientes/asegurados';

-- -----------------------------------------------------------------------------
-- TABLA: POLIZAS - Tabla maestra de pólizas
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.CORE.POLIZAS (
    poliza_id               VARCHAR(20)     PRIMARY KEY,
    numero_poliza           VARCHAR(20)     NOT NULL UNIQUE,
    tipo_seguro             VARCHAR(10)     NOT NULL,  -- AUTO, GMM
    cliente_id              VARCHAR(15)     NOT NULL REFERENCES CENTINELA_DB.CORE.CLIENTES(cliente_id),
    agente_id               VARCHAR(10)     REFERENCES CENTINELA_DB.CORE.AGENTES(agente_id),
    fecha_emision           DATE            NOT NULL,
    fecha_inicio_vigencia   DATE            NOT NULL,
    fecha_fin_vigencia      DATE            NOT NULL,
    estatus                 VARCHAR(20)     DEFAULT 'Vigente',  -- Vigente, Cancelada, Vencida, Suspendida
    forma_pago              VARCHAR(20)     NOT NULL,  -- Anual, Semestral, Trimestral, Mensual
    prima_neta              DECIMAL(12,2)   NOT NULL,
    derecho_poliza          DECIMAL(10,2)   DEFAULT 0,
    recargo_pago_fraccionado DECIMAL(10,2)  DEFAULT 0,
    iva                     DECIMAL(10,2)   NOT NULL,
    prima_total             DECIMAL(12,2)   NOT NULL,
    moneda                  VARCHAR(3)      DEFAULT 'MXN',
    conducto_cobro          VARCHAR(50),    -- Domiciliación, Depósito, Tarjeta, Efectivo
    fecha_creacion          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    fecha_actualizacion     TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Tabla maestra de todas las pólizas emitidas';

-- ============================================================================
-- SECCIÓN 3: TABLAS DE SEGUROS DE AUTOMÓVILES
-- ============================================================================

USE SCHEMA CENTINELA_DB.AUTOS;

-- -----------------------------------------------------------------------------
-- TABLA: VEHICULOS - Catálogo de vehículos asegurados
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.AUTOS.VEHICULOS (
    vehiculo_id             VARCHAR(15)     PRIMARY KEY,
    cliente_id              VARCHAR(15)     NOT NULL REFERENCES CENTINELA_DB.CORE.CLIENTES(cliente_id),
    marca                   VARCHAR(50)     NOT NULL,
    submarca                VARCHAR(50)     NOT NULL,
    modelo                  VARCHAR(100)    NOT NULL,
    anio                    INTEGER         NOT NULL,
    version                 VARCHAR(100),
    numero_serie            VARCHAR(20)     NOT NULL UNIQUE,
    numero_motor            VARCHAR(20),
    placas                  VARCHAR(10),
    color                   VARCHAR(30),
    tipo_vehiculo           VARCHAR(30),    -- Sedan, SUV, Pickup, Deportivo
    numero_puertas          INTEGER,
    transmision             VARCHAR(15),    -- Manual, Automatica
    combustible             VARCHAR(20),    -- Gasolina, Diesel, Hibrido, Electrico
    valor_factura           DECIMAL(12,2),
    valor_comercial         DECIMAL(12,2),
    uso_vehiculo            VARCHAR(30),    -- Particular, Comercial, Servicio Publico
    fecha_creacion          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Catálogo de vehículos asegurados';

-- -----------------------------------------------------------------------------
-- TABLA: COBERTURAS_AUTO - Catálogo de coberturas disponibles
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.AUTOS.COBERTURAS_AUTO (
    cobertura_id            VARCHAR(10)     PRIMARY KEY,
    nombre_cobertura        VARCHAR(100)    NOT NULL,
    descripcion             VARCHAR(500),
    tipo_cobertura          VARCHAR(30),    -- Básica, Amplia, Premium
    suma_asegurada_default  DECIMAL(12,2),
    deducible_porcentaje    DECIMAL(5,2),
    activa                  BOOLEAN         DEFAULT TRUE
)
COMMENT = 'Catálogo de coberturas para seguros de automóviles';

-- -----------------------------------------------------------------------------
-- TABLA: POLIZAS_AUTO - Detalle de pólizas de automóviles
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.AUTOS.POLIZAS_AUTO (
    poliza_auto_id          VARCHAR(20)     PRIMARY KEY,
    poliza_id               VARCHAR(20)     NOT NULL REFERENCES CENTINELA_DB.CORE.POLIZAS(poliza_id),
    vehiculo_id             VARCHAR(15)     NOT NULL REFERENCES CENTINELA_DB.AUTOS.VEHICULOS(vehiculo_id),
    paquete_cobertura       VARCHAR(30)     NOT NULL,  -- Amplia, Limitada, RC
    suma_asegurada          DECIMAL(12,2)   NOT NULL,
    deducible_dm            DECIMAL(5,2),   -- Daños Materiales %
    deducible_robo          DECIMAL(5,2),   -- Robo Total %
    cobertura_rc            DECIMAL(12,2),  -- Responsabilidad Civil
    cobertura_gm            DECIMAL(12,2),  -- Gastos Médicos Ocupantes
    cobertura_al            DECIMAL(12,2),  -- Asistencia Legal
    cobertura_av            DECIMAL(12,2),  -- Asistencia Vial
    conductor_habitual      VARCHAR(150),
    edad_conductor          INTEGER,
    anios_experiencia       INTEGER,
    zona_circulacion        VARCHAR(50),    -- CDMX, Zona Metro, Interior
    historial_siniestros    INTEGER         DEFAULT 0,
    descuento_aplicado      DECIMAL(5,2)    DEFAULT 0,
    fecha_creacion          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Detalle específico de pólizas de automóviles';

-- -----------------------------------------------------------------------------
-- TABLA: COBERTURA_POLIZA_AUTO - Relación póliza-coberturas
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.AUTOS.COBERTURA_POLIZA_AUTO (
    id                      INTEGER         AUTOINCREMENT PRIMARY KEY,
    poliza_auto_id          VARCHAR(20)     NOT NULL REFERENCES CENTINELA_DB.AUTOS.POLIZAS_AUTO(poliza_auto_id),
    cobertura_id            VARCHAR(10)     NOT NULL REFERENCES CENTINELA_DB.AUTOS.COBERTURAS_AUTO(cobertura_id),
    suma_asegurada          DECIMAL(12,2),
    deducible               DECIMAL(12,2),
    prima_cobertura         DECIMAL(10,2),
    aplica                  BOOLEAN         DEFAULT TRUE
)
COMMENT = 'Relación entre pólizas de auto y sus coberturas contratadas';

-- ============================================================================
-- SECCIÓN 4: TABLAS DE GASTOS MÉDICOS MAYORES (GMM)
-- ============================================================================

USE SCHEMA CENTINELA_DB.GMM;

-- -----------------------------------------------------------------------------
-- TABLA: PLANES_GMM - Catálogo de planes médicos
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.GMM.PLANES_GMM (
    plan_id                 VARCHAR(10)     PRIMARY KEY,
    nombre_plan             VARCHAR(100)    NOT NULL,
    descripcion             VARCHAR(500),
    nivel_hospital          VARCHAR(20),    -- Estandar, Ejecutivo, Premium
    suma_asegurada          DECIMAL(15,2)   NOT NULL,
    deducible               DECIMAL(10,2)   NOT NULL,
    coaseguro_porcentaje    DECIMAL(5,2)    DEFAULT 10,
    tope_coaseguro          DECIMAL(12,2),
    cobertura_internacional BOOLEAN         DEFAULT FALSE,
    activo                  BOOLEAN         DEFAULT TRUE
)
COMMENT = 'Catálogo de planes de Gastos Médicos Mayores';

-- -----------------------------------------------------------------------------
-- TABLA: COBERTURAS_GMM - Coberturas médicas disponibles
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.GMM.COBERTURAS_GMM (
    cobertura_id            VARCHAR(10)     PRIMARY KEY,
    nombre_cobertura        VARCHAR(100)    NOT NULL,
    descripcion             VARCHAR(500),
    tipo                    VARCHAR(30),    -- Basica, Adicional
    suma_asegurada_default  DECIMAL(12,2),
    periodo_espera_dias     INTEGER         DEFAULT 0,
    activa                  BOOLEAN         DEFAULT TRUE
)
COMMENT = 'Catálogo de coberturas para GMM';

-- -----------------------------------------------------------------------------
-- TABLA: ASEGURADOS_GMM - Personas cubiertas en póliza GMM
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.GMM.ASEGURADOS_GMM (
    asegurado_id            VARCHAR(15)     PRIMARY KEY,
    poliza_gmm_id           VARCHAR(20)     NOT NULL,
    parentesco              VARCHAR(20)     NOT NULL,  -- Titular, Conyuge, Hijo, Dependiente
    nombre                  VARCHAR(100)    NOT NULL,
    apellido_paterno        VARCHAR(100)    NOT NULL,
    apellido_materno        VARCHAR(100),
    fecha_nacimiento        DATE            NOT NULL,
    genero                  VARCHAR(1)      NOT NULL,
    curp                    VARCHAR(18),
    peso_kg                 DECIMAL(5,2),
    estatura_cm             DECIMAL(5,2),
    ocupacion               VARCHAR(100),
    deportes_riesgo         BOOLEAN         DEFAULT FALSE,
    fumador                 BOOLEAN         DEFAULT FALSE,
    enfermedades_preexistentes VARCHAR(500),
    prima_individual        DECIMAL(10,2),
    activo                  BOOLEAN         DEFAULT TRUE,
    fecha_creacion          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Personas aseguradas dentro de cada póliza GMM';

-- -----------------------------------------------------------------------------
-- TABLA: POLIZAS_GMM - Detalle de pólizas de GMM
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.GMM.POLIZAS_GMM (
    poliza_gmm_id           VARCHAR(20)     PRIMARY KEY,
    poliza_id               VARCHAR(20)     NOT NULL REFERENCES CENTINELA_DB.CORE.POLIZAS(poliza_id),
    plan_id                 VARCHAR(10)     NOT NULL REFERENCES CENTINELA_DB.GMM.PLANES_GMM(plan_id),
    tipo_poliza             VARCHAR(20)     NOT NULL,  -- Individual, Familiar
    suma_asegurada          DECIMAL(15,2)   NOT NULL,
    deducible               DECIMAL(10,2)   NOT NULL,
    coaseguro_porcentaje    DECIMAL(5,2)    NOT NULL,
    tope_coaseguro          DECIMAL(12,2),
    nivel_hospitalario      VARCHAR(20),    -- Estandar, Ejecutivo, Premium
    cobertura_internacional BOOLEAN         DEFAULT FALSE,
    cobertura_dental        BOOLEAN         DEFAULT FALSE,
    cobertura_vision        BOOLEAN         DEFAULT FALSE,
    cobertura_maternidad    BOOLEAN         DEFAULT FALSE,
    red_medica              VARCHAR(50),    -- Red Amplia, Red Selecta
    zona_cobertura          VARCHAR(50),    -- Nacional, Internacional
    numero_asegurados       INTEGER         DEFAULT 1,
    edad_promedio           DECIMAL(5,2),
    fecha_creacion          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Detalle específico de pólizas de Gastos Médicos Mayores';

-- Agregar FK después de crear la tabla
ALTER TABLE CENTINELA_DB.GMM.ASEGURADOS_GMM 
ADD CONSTRAINT fk_asegurados_poliza 
FOREIGN KEY (poliza_gmm_id) REFERENCES CENTINELA_DB.GMM.POLIZAS_GMM(poliza_gmm_id);

-- -----------------------------------------------------------------------------
-- TABLA: COBERTURA_POLIZA_GMM - Relación póliza-coberturas GMM
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.GMM.COBERTURA_POLIZA_GMM (
    id                      INTEGER         AUTOINCREMENT PRIMARY KEY,
    poliza_gmm_id           VARCHAR(20)     NOT NULL REFERENCES CENTINELA_DB.GMM.POLIZAS_GMM(poliza_gmm_id),
    cobertura_id            VARCHAR(10)     NOT NULL REFERENCES CENTINELA_DB.GMM.COBERTURAS_GMM(cobertura_id),
    suma_asegurada          DECIMAL(12,2),
    periodo_espera_dias     INTEGER,
    aplica                  BOOLEAN         DEFAULT TRUE
)
COMMENT = 'Relación entre pólizas GMM y sus coberturas contratadas';

-- ============================================================================
-- SECCIÓN 5: TABLAS DE OPERACIONES
-- ============================================================================

USE SCHEMA CENTINELA_DB.OPERACIONES;

-- -----------------------------------------------------------------------------
-- TABLA: SINIESTROS - Registro de reclamaciones
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.OPERACIONES.SINIESTROS (
    siniestro_id            VARCHAR(20)     PRIMARY KEY,
    numero_siniestro        VARCHAR(20)     NOT NULL UNIQUE,
    poliza_id               VARCHAR(20)     NOT NULL REFERENCES CENTINELA_DB.CORE.POLIZAS(poliza_id),
    tipo_seguro             VARCHAR(10)     NOT NULL,  -- AUTO, GMM
    fecha_siniestro         TIMESTAMP_NTZ   NOT NULL,
    fecha_reporte           TIMESTAMP_NTZ   NOT NULL,
    descripcion             VARCHAR(1000),
    lugar_siniestro         VARCHAR(300),
    estatus                 VARCHAR(30)     DEFAULT 'Reportado',  -- Reportado, En Proceso, Dictaminado, Pagado, Rechazado
    monto_reclamado         DECIMAL(12,2),
    monto_dictaminado       DECIMAL(12,2),
    monto_pagado            DECIMAL(12,2),
    deducible_aplicado      DECIMAL(12,2),
    fecha_dictamen          DATE,
    fecha_pago              DATE,
    ajustador_id            VARCHAR(10),
    observaciones           VARCHAR(500),
    fecha_creacion          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    fecha_actualizacion     TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Registro de siniestros y reclamaciones';

-- -----------------------------------------------------------------------------
-- TABLA: SINIESTROS_AUTO - Detalle de siniestros de autos
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.OPERACIONES.SINIESTROS_AUTO (
    siniestro_auto_id       VARCHAR(20)     PRIMARY KEY,
    siniestro_id            VARCHAR(20)     NOT NULL REFERENCES CENTINELA_DB.OPERACIONES.SINIESTROS(siniestro_id),
    vehiculo_id             VARCHAR(15)     NOT NULL,
    tipo_siniestro          VARCHAR(30),    -- Colision, Robo Total, Robo Parcial, Daños Terceros
    danios_descripcion      VARCHAR(500),
    hubo_lesionados         BOOLEAN         DEFAULT FALSE,
    numero_lesionados       INTEGER         DEFAULT 0,
    intervencion_autoridad  BOOLEAN         DEFAULT FALSE,
    numero_reporte_vial     VARCHAR(30),
    taller_asignado         VARCHAR(100),
    grua_utilizada          BOOLEAN         DEFAULT FALSE,
    perdida_total           BOOLEAN         DEFAULT FALSE
)
COMMENT = 'Detalle específico de siniestros de automóviles';

-- -----------------------------------------------------------------------------
-- TABLA: SINIESTROS_GMM - Detalle de siniestros GMM
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.OPERACIONES.SINIESTROS_GMM (
    siniestro_gmm_id        VARCHAR(20)     PRIMARY KEY,
    siniestro_id            VARCHAR(20)     NOT NULL REFERENCES CENTINELA_DB.OPERACIONES.SINIESTROS(siniestro_id),
    asegurado_id            VARCHAR(15)     NOT NULL,
    padecimiento            VARCHAR(200),
    tipo_atencion           VARCHAR(30),    -- Consulta, Urgencia, Hospitalizacion, Cirugia
    hospital_clinica        VARCHAR(150),
    medico_tratante         VARCHAR(150),
    dias_hospitalizacion    INTEGER         DEFAULT 0,
    requirio_cirugia        BOOLEAN         DEFAULT FALSE,
    tipo_cirugia            VARCHAR(100),
    fecha_ingreso_hospital  DATE,
    fecha_alta_hospital     DATE,
    diagnostico_cie10       VARCHAR(10),    -- Código CIE-10
    carta_autorizacion      BOOLEAN         DEFAULT FALSE
)
COMMENT = 'Detalle específico de siniestros de GMM';

-- -----------------------------------------------------------------------------
-- TABLA: PAGOS - Historial de pagos de primas
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.OPERACIONES.PAGOS (
    pago_id                 VARCHAR(20)     PRIMARY KEY,
    poliza_id               VARCHAR(20)     NOT NULL REFERENCES CENTINELA_DB.CORE.POLIZAS(poliza_id),
    numero_recibo           VARCHAR(20)     NOT NULL,
    numero_pago             INTEGER         NOT NULL,  -- 1, 2, 3... según forma de pago
    total_pagos             INTEGER         NOT NULL,  -- Total de pagos en el año
    fecha_vencimiento       DATE            NOT NULL,
    fecha_pago              DATE,
    monto_pago              DECIMAL(12,2)   NOT NULL,
    monto_pagado            DECIMAL(12,2),
    estatus                 VARCHAR(20)     DEFAULT 'Pendiente',  -- Pendiente, Pagado, Vencido, Cancelado
    forma_pago              VARCHAR(30),    -- Tarjeta, Transferencia, Efectivo, Domiciliacion
    referencia_pago         VARCHAR(50),
    fecha_creacion          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Control de pagos de primas de pólizas';

-- -----------------------------------------------------------------------------
-- TABLA: RENOVACIONES - Historial de renovaciones
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TABLE CENTINELA_DB.OPERACIONES.RENOVACIONES (
    renovacion_id           VARCHAR(20)     PRIMARY KEY,
    poliza_anterior_id      VARCHAR(20)     NOT NULL,
    poliza_nueva_id         VARCHAR(20)     NOT NULL,
    fecha_renovacion        DATE            NOT NULL,
    prima_anterior          DECIMAL(12,2),
    prima_nueva             DECIMAL(12,2),
    variacion_porcentaje    DECIMAL(5,2),
    motivo_variacion        VARCHAR(200),
    renovacion_automatica   BOOLEAN         DEFAULT FALSE,
    fecha_creacion          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Historial de renovaciones de pólizas';

-- ============================================================================
-- SECCIÓN 6: ÍNDICES Y OPTIMIZACIÓN
-- ============================================================================

-- Índices para búsquedas frecuentes
-- Nota: Snowflake crea automáticamente clustering en micro-partitions,
-- pero podemos definir cluster keys para optimizar

ALTER TABLE CENTINELA_DB.CORE.POLIZAS CLUSTER BY (tipo_seguro, estatus);
ALTER TABLE CENTINELA_DB.CORE.CLIENTES CLUSTER BY (estado, activo);
ALTER TABLE CENTINELA_DB.OPERACIONES.SINIESTROS CLUSTER BY (tipo_seguro, estatus, fecha_siniestro);
ALTER TABLE CENTINELA_DB.OPERACIONES.PAGOS CLUSTER BY (estatus, fecha_vencimiento);

-- ============================================================================
-- SECCIÓN 7: QUERIES DE DIAGNÓSTICO Y VALIDACIÓN
-- ============================================================================

-- Verificar estructura de tablas
SELECT table_catalog, table_schema, table_name, row_count, bytes
FROM CENTINELA_DB.INFORMATION_SCHEMA.TABLES
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY table_schema, table_name;

-- Verificar relaciones (Foreign Keys)
SELECT 
    tc.table_schema,
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM CENTINELA_DB.INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_schema, tc.table_name;

-- ============================================================================
-- SECCIÓN 8: FINOPS - GESTIÓN DE RECURSOS
-- ============================================================================

-- Verificar estado del warehouse
SHOW WAREHOUSES LIKE 'CENTINELA_WH';

-- Suspender warehouse cuando no se use
-- ALTER WAREHOUSE CENTINELA_WH SUSPEND;

-- Verificar timeout de statements
SHOW PARAMETERS LIKE 'STATEMENT_TIMEOUT_IN_SECONDS' IN WAREHOUSE CENTINELA_WH;

-- Monitorear uso de créditos (últimas 24 horas)
SELECT 
    warehouse_name,
    SUM(credits_used) as creditos_consumidos,
    SUM(credits_used_compute) as creditos_computo,
    SUM(credits_used_cloud_services) as creditos_cloud
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE warehouse_name = 'CENTINELA_WH'
AND start_time >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
GROUP BY warehouse_name;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================

