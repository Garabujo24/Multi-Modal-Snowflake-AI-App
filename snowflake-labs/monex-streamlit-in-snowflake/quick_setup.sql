-- =================================================================
-- INSTALACIÓN RÁPIDA COMPLETA - MONEX GRUPO FINANCIERO
-- Sistema completo con Cortex Analyst y Cortex Search
-- =================================================================

-- IMPORTANTE: Ejecutar cada sección paso a paso para verificar que no haya errores

-- =================================================================
-- PASO 1: CONFIGURACIÓN INICIAL
-- =================================================================

USE ROLE ACCOUNTADMIN;

-- Crear warehouse
CREATE OR REPLACE WAREHOUSE MONEX_WH WITH
    WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    COMMENT = 'Warehouse para aplicaciones Monex Cortex';

-- Crear base de datos y esquemas
CREATE OR REPLACE DATABASE MONEX_DB
    COMMENT = 'Base de datos principal para Monex Grupo Financiero';

CREATE OR REPLACE SCHEMA MONEX_DB.CORE
    COMMENT = 'Esquema principal con datos operativos';

CREATE OR REPLACE SCHEMA MONEX_DB.ANALYTICS
    COMMENT = 'Esquema para vistas analíticas y métricas';

CREATE OR REPLACE SCHEMA MONEX_DB.DOCUMENTS
    COMMENT = 'Esquema para documentos y servicios de búsqueda';

CREATE OR REPLACE SCHEMA MONEX_DB.STAGES
    COMMENT = 'Esquema para stages y archivos';

USE DATABASE MONEX_DB;
USE SCHEMA CORE;
USE WAREHOUSE MONEX_WH;

-- =================================================================
-- PASO 2: CREAR TABLAS
-- =================================================================

-- Tabla de Clientes
CREATE OR REPLACE TABLE CLIENTES (
    CLIENTE_ID VARCHAR(20) PRIMARY KEY,
    NOMBRE VARCHAR(200) NOT NULL,
    TIPO_CLIENTE VARCHAR(20) NOT NULL,
    RFC VARCHAR(13),
    TELEFONO VARCHAR(15),
    EMAIL VARCHAR(100),
    CIUDAD VARCHAR(50),
    ESTADO VARCHAR(50),
    PAIS VARCHAR(50) DEFAULT 'MÉXICO',
    FECHA_ALTA DATE NOT NULL,
    ESTATUS VARCHAR(20) DEFAULT 'ACTIVO',
    SEGMENTO VARCHAR(30),
    FECHA_CREACION TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    FECHA_ACTUALIZACION TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Tabla de Productos
CREATE OR REPLACE TABLE PRODUCTOS (
    PRODUCTO_ID VARCHAR(20) PRIMARY KEY,
    NOMBRE_PRODUCTO VARCHAR(100) NOT NULL,
    CATEGORIA VARCHAR(50) NOT NULL,
    SUBCATEGORIA VARCHAR(50),
    MONEDA VARCHAR(3) DEFAULT 'MXN',
    TASA_INTERES DECIMAL(8,4),
    COMISION DECIMAL(8,4),
    MONTO_MINIMO DECIMAL(15,2),
    MONTO_MAXIMO DECIMAL(15,2),
    DESCRIPCION VARCHAR(500),
    ESTATUS VARCHAR(20) DEFAULT 'ACTIVO',
    FECHA_CREACION TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Tabla de Transacciones
CREATE OR REPLACE TABLE TRANSACCIONES (
    TRANSACCION_ID VARCHAR(30) PRIMARY KEY,
    CLIENTE_ID VARCHAR(20) NOT NULL,
    PRODUCTO_ID VARCHAR(20) NOT NULL,
    TIPO_TRANSACCION VARCHAR(30) NOT NULL,
    MONTO DECIMAL(15,2) NOT NULL,
    MONEDA VARCHAR(3) NOT NULL,
    FECHA_TRANSACCION TIMESTAMP NOT NULL,
    ESTADO VARCHAR(20) DEFAULT 'COMPLETADA',
    CANAL VARCHAR(20),
    SUCURSAL VARCHAR(50),
    DESCRIPCION VARCHAR(200),
    COMISION DECIMAL(10,2) DEFAULT 0,
    FECHA_CREACION TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    FOREIGN KEY (CLIENTE_ID) REFERENCES CLIENTES(CLIENTE_ID),
    FOREIGN KEY (PRODUCTO_ID) REFERENCES PRODUCTOS(PRODUCTO_ID)
);

-- Tabla de Inversiones
CREATE OR REPLACE TABLE INVERSIONES (
    INVERSION_ID VARCHAR(30) PRIMARY KEY,
    CLIENTE_ID VARCHAR(20) NOT NULL,
    FONDO_ESTRATEGIA VARCHAR(50) NOT NULL,
    MONTO_INVERTIDO DECIMAL(15,2) NOT NULL,
    MONEDA VARCHAR(3) NOT NULL,
    FECHA_INVERSION DATE NOT NULL,
    FECHA_VENCIMIENTO DATE,
    RENDIMIENTO_ANUAL DECIMAL(8,4),
    VALOR_ACTUAL DECIMAL(15,2),
    ESTADO VARCHAR(20) DEFAULT 'ACTIVA',
    NOTAS VARCHAR(300),
    FECHA_CREACION TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    FOREIGN KEY (CLIENTE_ID) REFERENCES CLIENTES(CLIENTE_ID)
);

-- Tabla de Tipos de Cambio
CREATE OR REPLACE TABLE TIPOS_CAMBIO (
    FECHA DATE NOT NULL,
    MONEDA_ORIGEN VARCHAR(3) NOT NULL,
    MONEDA_DESTINO VARCHAR(3) NOT NULL,
    TIPO_CAMBIO_COMPRA DECIMAL(10,6) NOT NULL,
    TIPO_CAMBIO_VENTA DECIMAL(10,6) NOT NULL,
    VOLUMEN_TRANSACCIONES DECIMAL(15,2) DEFAULT 0,
    FECHA_ACTUALIZACION TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    PRIMARY KEY (FECHA, MONEDA_ORIGEN, MONEDA_DESTINO)
);

-- Tabla de Factoraje
CREATE OR REPLACE TABLE FACTORAJE (
    FACTORAJE_ID VARCHAR(30) PRIMARY KEY,
    CLIENTE_ID VARCHAR(20) NOT NULL,
    NUMERO_FACTURA VARCHAR(50) NOT NULL,
    EMPRESA_DEUDORA VARCHAR(200) NOT NULL,
    MONTO_FACTURA DECIMAL(15,2) NOT NULL,
    MONTO_ADELANTO DECIMAL(15,2) NOT NULL,
    FECHA_FACTURA DATE NOT NULL,
    FECHA_VENCIMIENTO DATE NOT NULL,
    FECHA_OPERACION DATE NOT NULL,
    TASA_DESCUENTO DECIMAL(8,4) NOT NULL,
    COMISION DECIMAL(8,4) NOT NULL,
    ESTADO VARCHAR(20) DEFAULT 'VIGENTE',
    TIPO_FACTORAJE VARCHAR(20) DEFAULT 'SIN_RECURSO',
    FECHA_CREACION TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    FOREIGN KEY (CLIENTE_ID) REFERENCES CLIENTES(CLIENTE_ID)
);

-- Tabla de Documentos
CREATE OR REPLACE TABLE DOCUMENTOS (
    DOCUMENTO_ID VARCHAR(30) PRIMARY KEY,
    CLIENTE_ID VARCHAR(20),
    TITULO VARCHAR(200) NOT NULL,
    TIPO_DOCUMENTO VARCHAR(50) NOT NULL,
    CATEGORIA VARCHAR(50),
    CONTENIDO TEXT NOT NULL,
    FECHA_DOCUMENTO DATE NOT NULL,
    ESTADO VARCHAR(20) DEFAULT 'ACTIVO',
    IDIOMA VARCHAR(10) DEFAULT 'ES',
    FECHA_CREACION TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    FOREIGN KEY (CLIENTE_ID) REFERENCES CLIENTES(CLIENTE_ID)
);

-- Habilitar change tracking para Cortex Search
ALTER TABLE DOCUMENTOS SET CHANGE_TRACKING = TRUE;

-- =================================================================
-- PASO 3: INSERTAR DATOS DE PRODUCTOS
-- =================================================================

INSERT INTO PRODUCTOS VALUES
('CRED_CORP_001', 'Crédito Simple Empresarial', 'CREDITO', 'EMPRESARIAL', 'MXN', 12.5000, 1.5000, 100000.00, 50000000.00, 'Crédito para capital de trabajo empresarial', 'ACTIVO', CURRENT_TIMESTAMP()),
('CRED_CORP_002', 'Línea de Crédito Revolvente', 'CREDITO', 'CORPORATIVO', 'MXN', 14.0000, 2.0000, 500000.00, 100000000.00, 'Línea de crédito flexible para grandes empresas', 'ACTIVO', CURRENT_TIMESTAMP()),
('CRED_USD_001', 'Crédito USD Corporativo', 'CREDITO', 'CORPORATIVO', 'USD', 8.5000, 1.0000, 50000.00, 10000000.00, 'Financiamiento en dólares para empresas', 'ACTIVO', CURRENT_TIMESTAMP()),
('FACT_001', 'Factoraje Sin Recurso', 'FACTORAJE', 'SIN_RECURSO', 'MXN', 15.0000, 2.5000, 50000.00, 25000000.00, 'Factoraje sin recurso para empresas', 'ACTIVO', CURRENT_TIMESTAMP()),
('FACT_002', 'Factoraje Electrónico', 'FACTORAJE', 'ELECTRONICO', 'MXN', 14.5000, 2.0000, 25000.00, 15000000.00, 'Factoraje digital y ágil', 'ACTIVO', CURRENT_TIMESTAMP()),
('FACT_CAD_001', 'Cadenas Productivas NAFIN', 'FACTORAJE', 'CADENA_PRODUCTIVA', 'MXN', 12.0000, 1.5000, 10000.00, 5000000.00, 'Factoraje para cadenas productivas NAFIN', 'ACTIVO', CURRENT_TIMESTAMP()),
('INV_USD_001', 'USD Fixed Income', 'INVERSION', 'RENTA_FIJA', 'USD', 4.7000, 0.5000, 10000.00, 10000000.00, 'Estrategia conservadora en renta fija USD', 'ACTIVO', CURRENT_TIMESTAMP()),
('INV_USD_002', 'Global Equity', 'INVERSION', 'ACCIONES', 'USD', 12.8200, 1.0000, 25000.00, 25000000.00, 'Estrategia global en mercados accionarios', 'ACTIVO', CURRENT_TIMESTAMP()),
('INV_USD_003', 'Conservative Global Strategy', 'INVERSION', 'CONSERVADORA', 'USD', 6.6800, 0.7500, 15000.00, 15000000.00, 'Estrategia conservadora global', 'ACTIVO', CURRENT_TIMESTAMP()),
('INV_USD_004', 'Moderate Global Strategy', 'INVERSION', 'MODERADA', 'USD', 8.5800, 0.8500, 20000.00, 20000000.00, 'Estrategia moderada global', 'ACTIVO', CURRENT_TIMESTAMP()),
('INV_USD_005', 'Aggressive Global Strategy', 'INVERSION', 'AGRESIVA', 'USD', 10.6300, 1.2000, 30000.00, 30000000.00, 'Estrategia agresiva para mayor rendimiento', 'ACTIVO', CURRENT_TIMESTAMP()),
('FONDO_MXN_001', 'Fondo Monex Renta Fija', 'INVERSION', 'RENTA_FIJA', 'MXN', 9.2500, 1.0000, 5000.00, 5000000.00, 'Fondo de inversión en instrumentos de renta fija', 'ACTIVO', CURRENT_TIMESTAMP()),
('FONDO_MXN_002', 'Fondo Monex Mercado Dinero', 'INVERSION', 'MERCADO_DINERO', 'MXN', 7.8000, 0.5000, 1000.00, 1000000.00, 'Inversión líquida en mercado de dinero', 'ACTIVO', CURRENT_TIMESTAMP()),
('FX_001', 'Compra-Venta USD/MXN', 'CAMBIO_DIVISAS', 'SPOT', 'MXN', 0.0000, 0.0100, 100.00, 10000000.00, 'Operaciones de cambio USD/MXN al contado', 'ACTIVO', CURRENT_TIMESTAMP()),
('FX_002', 'Forward USD/MXN', 'CAMBIO_DIVISAS', 'FORWARD', 'USD', 0.0000, 0.0200, 1000.00, 50000000.00, 'Contratos forward para cobertura cambiaria', 'ACTIVO', CURRENT_TIMESTAMP()),
('CTA_CORP_001', 'Cuenta Empresarial MXN', 'CUENTA', 'EMPRESARIAL', 'MXN', 2.5000, 500.00, 0.00, 999999999.99, 'Cuenta corriente para empresas', 'ACTIVO', CURRENT_TIMESTAMP()),
('CTA_USD_001', 'Cuenta USD Empresarial', 'CUENTA', 'EMPRESARIAL', 'USD', 1.2000, 25.00, 0.00, 999999999.99, 'Cuenta en dólares para empresas', 'ACTIVO', CURRENT_TIMESTAMP()),
('CTA_PRIV_001', 'Cuenta Private Banking', 'CUENTA', 'PRIVATE', 'MXN', 3.0000, 1000.00, 50000.00, 999999999.99, 'Cuenta exclusiva para private banking', 'ACTIVO', CURRENT_TIMESTAMP());

-- =================================================================
-- PASO 4: INSERTAR CLIENTES
-- =================================================================

INSERT INTO CLIENTES VALUES
-- Clientes Corporativos
('CORP_001', 'Grupo Televisa S.A.B. de C.V.', 'CORPORATIVO', 'GTE870724AB1', '55-1234-5678', 'contacto@televisa.com.mx', 'Ciudad de México', 'CDMX', 'MÉXICO', '2020-01-15', 'ACTIVO', 'EMPRESARIAL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CORP_002', 'América Móvil S.A.B. de C.V.', 'CORPORATIVO', 'AMX010101AA1', '55-2345-6789', 'info@americamovil.com', 'Ciudad de México', 'CDMX', 'MÉXICO', '2019-03-20', 'ACTIVO', 'EMPRESARIAL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CORP_003', 'Femsa Comercio S.A. de C.V.', 'CORPORATIVO', 'FCO870101BB2', '81-3456-7890', 'contacto@oxxo.com', 'Monterrey', 'Nuevo León', 'MÉXICO', '2018-07-10', 'ACTIVO', 'EMPRESARIAL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CORP_004', 'Bimbo S.A.B. de C.V.', 'CORPORATIVO', 'BIM450101CC3', '55-4567-8901', 'info@grupobimbo.com', 'Ciudad de México', 'CDMX', 'MÉXICO', '2017-11-25', 'ACTIVO', 'EMPRESARIAL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CORP_005', 'Cemex S.A.B. de C.V.', 'CORPORATIVO', 'CMX901010DD4', '81-5678-9012', 'contacto@cemex.com', 'Monterrey', 'Nuevo León', 'MÉXICO', '2019-09-12', 'ACTIVO', 'EMPRESARIAL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CORP_006', 'Walmart de México S.A.B. de C.V.', 'CORPORATIVO', 'WMX520101EE5', '55-6789-0123', 'info@walmart.com.mx', 'Ciudad de México', 'CDMX', 'MÉXICO', '2020-05-08', 'ACTIVO', 'EMPRESARIAL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CORP_007', 'Banco Santander México S.A.', 'CORPORATIVO', 'BSM710101FF6', '55-7890-1234', 'corporativo@santander.com.mx', 'Ciudad de México', 'CDMX', 'MÉXICO', '2018-02-14', 'ACTIVO', 'EMPRESARIAL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('CORP_008', 'Peñoles Industrias S.A.B. de C.V.', 'CORPORATIVO', 'PIN890101GG7', '55-8901-2345', 'info@penoles.com.mx', 'Ciudad de México', 'CDMX', 'MÉXICO', '2019-12-03', 'ACTIVO', 'EMPRESARIAL', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
-- Clientes PYME
('PYME_001', 'Distribuidora El Águila S.A. de C.V.', 'CORPORATIVO', 'DEA950101HH8', '33-1111-2222', 'ventas@elaguiladist.com', 'Guadalajara', 'Jalisco', 'MÉXICO', '2021-04-18', 'ACTIVO', 'PYME', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PYME_002', 'Constructora Norte S.A. de C.V.', 'CORPORATIVO', 'CNO960101II9', '81-2222-3333', 'info@constructoranorte.mx', 'Monterrey', 'Nuevo León', 'MÉXICO', '2020-08-22', 'ACTIVO', 'PYME', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PYME_003', 'Textiles del Bajío S.A. de C.V.', 'CORPORATIVO', 'TDB970101JJ0', '46-3333-4444', 'contacto@textilesbajio.com', 'León', 'Guanajuato', 'MÉXICO', '2022-01-10', 'ACTIVO', 'PYME', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PYME_004', 'Servicios Logísticos Maya S.A.', 'CORPORATIVO', 'SLM980101KK1', '99-4444-5555', 'logistica@mayaservices.mx', 'Mérida', 'Yucatán', 'MÉXICO', '2021-11-15', 'ACTIVO', 'PYME', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PYME_005', 'Alimentos Procesados del Centro', 'CORPORATIVO', 'APC990101LL2', '22-5555-6666', 'ventas@alimentoscentro.com', 'Puebla', 'Puebla', 'MÉXICO', '2020-06-30', 'ACTIVO', 'PYME', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
-- Clientes Private Banking
('PRIV_001', 'Roberto González Martínez', 'PRIVADO', 'GOMR800515MM3', '55-1000-2000', 'roberto.gonzalez@email.com', 'Ciudad de México', 'CDMX', 'MÉXICO', '2019-01-20', 'ACTIVO', 'PREMIUM', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PRIV_002', 'María Elena Rodríguez López', 'PRIVADO', 'ROLM750820NN4', '33-2000-3000', 'maria.rodriguez@email.com', 'Guadalajara', 'Jalisco', 'MÉXICO', '2018-05-15', 'ACTIVO', 'PREMIUM', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PRIV_003', 'Carlos Alberto Fernández Silva', 'PRIVADO', 'FESC821010OO5', '81-3000-4000', 'carlos.fernandez@email.com', 'Monterrey', 'Nuevo León', 'MÉXICO', '2020-03-08', 'ACTIVO', 'PREMIUM', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PRIV_004', 'Ana Patricia Jiménez Torres', 'PRIVADO', 'JITA770625PP6', '55-4000-5000', 'ana.jimenez@email.com', 'Ciudad de México', 'CDMX', 'MÉXICO', '2019-09-12', 'ACTIVO', 'PREMIUM', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PRIV_005', 'Fernando Alejandro Morales Díaz', 'PRIVADO', 'MODF850318QQ7', '81-5000-6000', 'fernando.morales@email.com', 'Monterrey', 'Nuevo León', 'MÉXICO', '2021-07-25', 'ACTIVO', 'PREMIUM', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
-- Clientes Individuales
('IND_001', 'Juan Carlos Pérez García', 'INDIVIDUAL', 'PEGJ900420RR8', '55-6000-7000', 'juan.perez@email.com', 'Ciudad de México', 'CDMX', 'MÉXICO', '2022-02-14', 'ACTIVO', 'MASIVO', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('IND_002', 'Laura Sofía Hernández Ruiz', 'INDIVIDUAL', 'HERL850812SS9', '33-7000-8000', 'laura.hernandez@email.com', 'Guadalajara', 'Jalisco', 'MÉXICO', '2021-08-20', 'ACTIVO', 'MASIVO', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('IND_003', 'Miguel Ángel López Mendoza', 'INDIVIDUAL', 'LOMM780925TT0', '81-8000-9000', 'miguel.lopez@email.com', 'Monterrey', 'Nuevo León', 'MÉXICO', '2022-05-10', 'ACTIVO', 'MASIVO', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- =================================================================
-- PASO 5: INSERTAR TIPOS DE CAMBIO (90 días)
-- =================================================================

INSERT INTO TIPOS_CAMBIO 
WITH RANDOMS_TC AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY NULL) AS RN,
        RANDOM() AS R1,
        RANDOM() AS R2
    FROM TABLE(GENERATOR(ROWCOUNT => 90))
),
FECHAS AS (
    SELECT 
        DATEADD(day, -RN + 1, CURRENT_DATE()) AS FECHA,
        (18.50 + ((MOD(ABS(COALESCE(R1, 0.5) * 200)::INT, 200) / 100.0) - 1))::DECIMAL(10,6) AS TIPO_BASE,
        R2
    FROM RANDOMS_TC
)
SELECT 
    FECHA,
    'USD' AS MONEDA_ORIGEN,
    'MXN' AS MONEDA_DESTINO,
    (TIPO_BASE - 0.10)::DECIMAL(10,6) AS TIPO_CAMBIO_COMPRA,
    (TIPO_BASE + 0.10)::DECIMAL(10,6) AS TIPO_CAMBIO_VENTA,
    (MOD(ABS(COALESCE(R2, 0.5) * 5000000)::INT, 5000000) + 1000000)::DECIMAL(15,2) AS VOLUMEN_TRANSACCIONES,
    CURRENT_TIMESTAMP() AS FECHA_ACTUALIZACION
FROM FECHAS;

-- =================================================================
-- PASO 6: INSERTAR TRANSACCIONES (5000 registros)
-- =================================================================

INSERT INTO TRANSACCIONES
WITH RANDOMS AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY NULL) AS RN,
        RANDOM() AS R1,
        RANDOM() AS R2,
        RANDOM() AS R3,
        RANDOM() AS R4,
        RANDOM() AS R5,
        RANDOM() AS R6,
        RANDOM() AS R7,
        RANDOM() AS R8
    FROM TABLE(GENERATOR(ROWCOUNT => 5000))
),
DATOS_TRANS AS (
    SELECT 
        'TXN_' || LPAD(COALESCE(RN, 1), 8, '0') AS TRANSACCION_ID,
        COALESCE((ARRAY_CONSTRUCT('CORP_001','CORP_002','CORP_003','CORP_004','CORP_005','CORP_006','CORP_007','CORP_008',
                        'PYME_001','PYME_002','PYME_003','PYME_004','PYME_005',
                        'PRIV_001','PRIV_002','PRIV_003','PRIV_004','PRIV_005',
                        'IND_001','IND_002','IND_003'))[GREATEST(1, LEAST(21, MOD(ABS(COALESCE(R1, 0.5) * 1000000)::INT, 21) + 1))]::VARCHAR, 'CORP_001') AS CLIENTE_ID,
        COALESCE((ARRAY_CONSTRUCT('CRED_CORP_001','FACT_001','INV_USD_001','INV_USD_002','FONDO_MXN_001','FX_001','CTA_CORP_001'))[GREATEST(1, LEAST(7, MOD(ABS(COALESCE(R2, 0.5) * 1000000)::INT, 7) + 1))]::VARCHAR, 'CRED_CORP_001') AS PRODUCTO_ID,
        COALESCE((ARRAY_CONSTRUCT('DEPOSITO','RETIRO','TRANSFERENCIA','INVERSION','CAMBIO_FX'))[GREATEST(1, LEAST(5, MOD(ABS(COALESCE(R3, 0.5) * 1000000)::INT, 5) + 1))]::VARCHAR, 'DEPOSITO') AS TIPO_TRANSACCION,
        COALESCE(CASE 
            WHEN MOD(ABS(COALESCE(R4, 0.3) * 100)::INT, 100) < 30 THEN (MOD(ABS(COALESCE(R5, 0.5) * 49000)::INT, 49000) + 1000)::DECIMAL(15,2)
            WHEN MOD(ABS(COALESCE(R4, 0.3) * 100)::INT, 100) < 70 THEN (MOD(ABS(COALESCE(R5, 0.5) * 450000)::INT, 450000) + 50000)::DECIMAL(15,2)
            ELSE (MOD(ABS(COALESCE(R5, 0.5) * 4500000)::INT, 4500000) + 500000)::DECIMAL(15,2)
        END, 1000.00) AS MONTO,
        COALESCE((ARRAY_CONSTRUCT('MXN','USD'))[GREATEST(1, LEAST(2, MOD(ABS(COALESCE(R6, 0.5) * 1000000)::INT, 2) + 1))]::VARCHAR, 'MXN') AS MONEDA,
        COALESCE(DATEADD(hour, MOD(ABS(COALESCE(R8, 0.5) * 24)::INT, 24), 
            DATEADD(day, -MOD(ABS(COALESCE(R7, 0.5) * 365)::INT, 365), CURRENT_DATE())
        ), CURRENT_TIMESTAMP()) AS FECHA_TRANSACCION,
        'COMPLETADA' AS ESTADO,
        COALESCE((ARRAY_CONSTRUCT('DIGITAL','SUCURSAL','TELEFONO'))[GREATEST(1, LEAST(3, MOD(ABS(COALESCE(R7, 0.5) * 1000000)::INT, 3) + 1))]::VARCHAR, 'DIGITAL') AS CANAL,
        COALESCE(CASE 
            WHEN MOD(ABS(COALESCE(R8, 0.5) * 100)::INT, 100) < 40 THEN 'SUCURSAL_CDMX_CENTRO'
            WHEN MOD(ABS(COALESCE(R8, 0.5) * 100)::INT, 100) < 60 THEN 'SUCURSAL_MTY_CENTRO'  
            WHEN MOD(ABS(COALESCE(R8, 0.5) * 100)::INT, 100) < 80 THEN 'SUCURSAL_GDL_CENTRO'
            ELSE 'DIGITAL_PLATFORM'
        END, 'DIGITAL_PLATFORM') AS SUCURSAL
    FROM RANDOMS
)
SELECT 
    TRANSACCION_ID,
    CLIENTE_ID,
    PRODUCTO_ID,
    TIPO_TRANSACCION,
    MONTO,
    MONEDA,
    FECHA_TRANSACCION,
    ESTADO,
    CANAL,
    SUCURSAL,
    CASE TIPO_TRANSACCION
        WHEN 'CAMBIO_FX' THEN 'Operación de cambio de divisas'
        WHEN 'INVERSION' THEN 'Inversión en fondo administrado'
        WHEN 'DEPOSITO' THEN 'Depósito a cuenta'
        WHEN 'RETIRO' THEN 'Retiro de efectivo'
        ELSE 'Transferencia bancaria'
    END AS DESCRIPCION,
    (MONTO * 0.002)::DECIMAL(10,2) AS COMISION,
    CURRENT_TIMESTAMP() AS FECHA_CREACION
FROM DATOS_TRANS;

-- =================================================================
-- PASO 7: INSERTAR INVERSIONES
-- =================================================================

INSERT INTO INVERSIONES
WITH RANDOMS_INV AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY NULL) AS RN,
        RANDOM() AS R1,
        RANDOM() AS R2,
        RANDOM() AS R3,
        RANDOM() AS R4
    FROM TABLE(GENERATOR(ROWCOUNT => 200))
),
DATOS_INV AS (
    SELECT 
        'INV_' || LPAD(COALESCE(RN, 1), 8, '0') AS INVERSION_ID,
        COALESCE((ARRAY_CONSTRUCT('PRIV_001','PRIV_002','PRIV_003','PRIV_004','PRIV_005',
                        'CORP_001','CORP_002','CORP_003'))[GREATEST(1, LEAST(8, MOD(ABS(COALESCE(R1, 0.5) * 1000000)::INT, 8) + 1))]::VARCHAR, 'PRIV_001') AS CLIENTE_ID,
        COALESCE((ARRAY_CONSTRUCT('USD_FIXED_INCOME','GLOBAL_EQUITY','CONSERVATIVE','MODERATE','AGGRESSIVE'))[GREATEST(1, LEAST(5, MOD(ABS(COALESCE(R2, 0.5) * 1000000)::INT, 5) + 1))]::VARCHAR, 'USD_FIXED_INCOME') AS FONDO_ESTRATEGIA,
        COALESCE(CASE 
            WHEN MOD(ABS(COALESCE(R3, 0.3) * 100)::INT, 100) < 30 THEN (MOD(ABS(COALESCE(R4, 0.5) * 90000)::INT, 90000) + 10000)::DECIMAL(15,2)
            WHEN MOD(ABS(COALESCE(R3, 0.3) * 100)::INT, 100) < 70 THEN (MOD(ABS(COALESCE(R4, 0.5) * 900000)::INT, 900000) + 100000)::DECIMAL(15,2)
            ELSE (MOD(ABS(COALESCE(R4, 0.5) * 9000000)::INT, 9000000) + 1000000)::DECIMAL(15,2)
        END, 10000.00) AS MONTO_INVERTIDO,
        'USD' AS MONEDA,
        COALESCE(DATEADD(day, -MOD(ABS(COALESCE(R4, 0.5) * 540)::INT, 540), CURRENT_DATE()), CURRENT_DATE()) AS FECHA_INVERSION,
        -- Calcular rendimiento aquí donde tenemos acceso a R3
        COALESCE((CASE 
            WHEN (ARRAY_CONSTRUCT('USD_FIXED_INCOME','GLOBAL_EQUITY','CONSERVATIVE','MODERATE','AGGRESSIVE'))[GREATEST(1, LEAST(5, MOD(ABS(COALESCE(R2, 0.5) * 1000000)::INT, 5) + 1))]::VARCHAR = 'USD_FIXED_INCOME' THEN 4.70
            WHEN (ARRAY_CONSTRUCT('USD_FIXED_INCOME','GLOBAL_EQUITY','CONSERVATIVE','MODERATE','AGGRESSIVE'))[GREATEST(1, LEAST(5, MOD(ABS(COALESCE(R2, 0.5) * 1000000)::INT, 5) + 1))]::VARCHAR = 'GLOBAL_EQUITY' THEN 12.82
            WHEN (ARRAY_CONSTRUCT('USD_FIXED_INCOME','GLOBAL_EQUITY','CONSERVATIVE','MODERATE','AGGRESSIVE'))[GREATEST(1, LEAST(5, MOD(ABS(COALESCE(R2, 0.5) * 1000000)::INT, 5) + 1))]::VARCHAR = 'CONSERVATIVE' THEN 6.68
            WHEN (ARRAY_CONSTRUCT('USD_FIXED_INCOME','GLOBAL_EQUITY','CONSERVATIVE','MODERATE','AGGRESSIVE'))[GREATEST(1, LEAST(5, MOD(ABS(COALESCE(R2, 0.5) * 1000000)::INT, 5) + 1))]::VARCHAR = 'MODERATE' THEN 8.58
            WHEN (ARRAY_CONSTRUCT('USD_FIXED_INCOME','GLOBAL_EQUITY','CONSERVATIVE','MODERATE','AGGRESSIVE'))[GREATEST(1, LEAST(5, MOD(ABS(COALESCE(R2, 0.5) * 1000000)::INT, 5) + 1))]::VARCHAR = 'AGGRESSIVE' THEN 10.63
            ELSE 4.70
        END + ((MOD(ABS(COALESCE(R3, 0.5) * 200)::INT, 200) - 100) / 100.0)), 4.70) AS RENDIMIENTO_ANUAL_CALC
    FROM RANDOMS_INV
)
SELECT 
    INVERSION_ID,
    CLIENTE_ID,
    FONDO_ESTRATEGIA,
    MONTO_INVERTIDO,
    MONEDA,
    FECHA_INVERSION,
    DATEADD(year, 1, FECHA_INVERSION) AS FECHA_VENCIMIENTO,
    RENDIMIENTO_ANUAL_CALC AS RENDIMIENTO_ANUAL,
    MONTO_INVERTIDO * (1 + (DATEDIFF(day, FECHA_INVERSION, CURRENT_DATE()) / 365.0) * 
        (RENDIMIENTO_ANUAL_CALC / 100.0)
    ) AS VALOR_ACTUAL,
    'ACTIVA' AS ESTADO,
    'Inversión gestionada por Monex Private Banking' AS NOTAS,
    CURRENT_TIMESTAMP() AS FECHA_CREACION
FROM DATOS_INV;

-- =================================================================
-- PASO 8: INSERTAR FACTORAJE
-- =================================================================

INSERT INTO FACTORAJE
WITH RANDOMS_FACT AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY NULL) AS RN,
        RANDOM() AS R1,
        RANDOM() AS R2,
        RANDOM() AS R3,
        RANDOM() AS R4,
        RANDOM() AS R5,
        RANDOM() AS R6
    FROM TABLE(GENERATOR(ROWCOUNT => 300))
),
DATOS_FACT AS (
    SELECT 
        'FACT_' || LPAD(COALESCE(RN, 1), 8, '0') AS FACTORAJE_ID,
        COALESCE((ARRAY_CONSTRUCT('CORP_001','CORP_002','CORP_003','CORP_004','CORP_005',
                        'PYME_001','PYME_002','PYME_003','PYME_004','PYME_005'))[GREATEST(1, LEAST(10, MOD(ABS(COALESCE(R1, 0.5) * 1000000)::INT, 10) + 1))]::VARCHAR, 'CORP_001') AS CLIENTE_ID,
        'FAC' || LPAD((MOD(ABS(COALESCE(R2, 0.5) * 899999)::INT, 899999) + 100000), 6, '0') AS NUMERO_FACTURA,
        COALESCE((ARRAY_CONSTRUCT('Liverpool S.A.B. de C.V.','El Palacio de Hierro S.A.',
                        'Soriana S.A.B. de C.V.','Chedraui S.A.B. de C.V.',
                        'Office Depot de México S.A.','Home Depot México S.A.',
                        'Costco de México S.A.','Sam''s Club México S.A.'))[GREATEST(1, LEAST(8, MOD(ABS(COALESCE(R3, 0.5) * 1000000)::INT, 8) + 1))]::VARCHAR, 'Liverpool S.A.B. de C.V.') AS EMPRESA_DEUDORA,
        COALESCE((MOD(ABS(COALESCE(R4, 0.5) * 1900000)::INT, 1900000) + 100000)::DECIMAL(15,2), 100000.00) AS MONTO_FACTURA,
        COALESCE(DATEADD(day, -MOD(ABS(COALESCE(R5, 0.5) * 180)::INT, 180), CURRENT_DATE()), CURRENT_DATE()) AS FECHA_FACTURA,
        COALESCE(((MOD(ABS(COALESCE(R6, 0.5) * 600)::INT, 600) / 100.0) + 12.0)::DECIMAL(8,4), 12.0) AS TASA_DESCUENTO,
        R5,
        R6
    FROM RANDOMS_FACT
)
SELECT 
    FACTORAJE_ID,
    CLIENTE_ID,
    NUMERO_FACTURA,
    EMPRESA_DEUDORA,
    MONTO_FACTURA,
    (MONTO_FACTURA * 0.85)::DECIMAL(15,2) AS MONTO_ADELANTO,
    FECHA_FACTURA,
    DATEADD(day, (MOD(ABS(COALESCE(R6, 0.5) * 60)::INT, 60) + 30), FECHA_FACTURA) AS FECHA_VENCIMIENTO,
    FECHA_FACTURA AS FECHA_OPERACION,
    TASA_DESCUENTO,
    2.5 AS COMISION,
    CASE 
        WHEN FECHA_FACTURA > DATEADD(day, -90, CURRENT_DATE()) THEN 'VIGENTE'
        WHEN MOD(ABS(COALESCE(R5, 0.5) * 100)::INT, 100) < 10 THEN 'VENCIDO'
        ELSE 'COBRADO'
    END AS ESTADO,
    'SIN_RECURSO' AS TIPO_FACTORAJE,
    CURRENT_TIMESTAMP() AS FECHA_CREACION
FROM DATOS_FACT;

-- =================================================================
-- PASO 9: INSERTAR DOCUMENTOS PARA CORTEX SEARCH
-- =================================================================

INSERT INTO DOCUMENTOS VALUES
('DOC_001', NULL, 'Manual de Operaciones de Factoraje', 'MANUAL', 'FACTORAJE', 
'Manual de Operaciones de Factoraje - Monex Grupo Financiero

El factoraje es una herramienta financiera que permite a las empresas obtener liquidez inmediata mediante la cesión de sus cuentas por cobrar. En Monex, ofrecemos dos modalidades principales:

1. FACTORAJE SIN RECURSO: La empresa cedente transfiere completamente el riesgo crediticio al factor.
2. FACTORAJE CON RECURSO: La empresa cedente mantiene el riesgo crediticio.

PROCESO DE EVALUACIÓN:
- Historial crediticio del cedente y deudor
- Antigüedad y relación comercial
- Sector económico y estabilidad
- Documentación legal completa

TASAS Y COMISIONES:
- Tasa de descuento: Entre 12% y 18% anual
- Comisión de estudio: 1.5% a 2.5%
- Comisión de cobranza: 1% del monto

CADENAS PRODUCTIVAS NAFIN:
Programa especial para proveedores de grandes empresas con tasas preferenciales desde 12% y proceso simplificado.',
'2024-01-15', 'ACTIVO', 'ES', CURRENT_TIMESTAMP()),

('DOC_002', NULL, 'Guía de Inversiones USD Private Banking', 'MANUAL', 'INVERSION', 
'Guía de Estrategias de Inversión USD - Monex Private Banking

ESTRATEGIAS DISPONIBLES:

1. USD FIXED INCOME: Rendimiento histórico 4.70% anual, perfil conservador, inversión mínima USD $10,000
2. GLOBAL EQUITY: Rendimiento histórico 12.82% anual, perfil agresivo, inversión mínima USD $25,000
3. CONSERVATIVE GLOBAL: 80% renta fija + 20% variable, rendimiento 6.68%, inversión mínima USD $15,000
4. MODERATE GLOBAL: 60% renta fija + 40% variable, rendimiento 8.58%, inversión mínima USD $20,000
5. AGGRESSIVE GLOBAL: 40% renta fija + 60% variable, rendimiento 10.63%, inversión mínima USD $30,000

PROCESO DE INVERSIÓN:
1. Evaluación de perfil de riesgo
2. Definición de objetivos financieros
3. Selección de estrategia apropiada
4. Firma de contratos
5. Transferencia de recursos
6. Monitoreo continuo',
'2024-02-01', 'ACTIVO', 'ES', CURRENT_TIMESTAMP()),

('DOC_003', NULL, 'Procedimientos de Cambio de Divisas', 'MANUAL', 'CAMBIO_DIVISAS', 
'Manual de Operaciones de Cambio de Divisas - Monex

Monex es una de las casas de cambio más importantes de México, especializada en operaciones USD/MXN.

PRODUCTOS DISPONIBLES:
1. OPERACIONES SPOT: Liquidación T+0 o T+2, monto mínimo USD $100
2. CONTRATOS FORWARD: Plazo 1 día hasta 1 año, monto mínimo USD $1,000
3. OPCIONES FINANCIERAS: Call y Put sobre USD/MXN

LÍMITES OPERATIVOS:
- Persona física: USD $10,000 diarios
- Persona moral: USD $100,000 diarios

HORARIOS DE OPERACIÓN:
- Lunes a viernes: 8:00 AM - 5:00 PM
- Mesa de Cambios: 55-5231-4500 ext. 2580',
'2024-03-01', 'ACTIVO', 'ES', CURRENT_TIMESTAMP()),

('DOC_004', 'CORP_001', 'Contrato de Crédito Simple - Grupo Televisa', 'CONTRATO', 'CREDITO',
'CONTRATO DE CRÉDITO SIMPLE
Monex Grupo Financiero S.A. de C.V.

ACREDITANTE: Monex Grupo Financiero S.A. de C.V.
ACREDITADO: Grupo Televisa S.A.B. de C.V.
MONTO: $50,000,000.00 MXN
PLAZO: 24 meses
TASA: TIIE 28 días + 3.5% anual

GARANTÍAS:
- Aval de los principales accionistas
- Garantía fiduciaria sobre flujos futuros
- Seguro de vida por el monto total

COMISIONES:
- Comisión por apertura: 1.5%
- Comisión por no disposición: 0.5% mensual
- Comisión por pago anticipado: 2%

Fecha: 15 de enero de 2024',
'2024-01-15', 'ACTIVO', 'ES', CURRENT_TIMESTAMP()),

('DOC_005', 'PRIV_001', 'Contrato de Inversión Private Banking - Roberto González', 'CONTRATO', 'INVERSION',
'CONTRATO DE PRESTACIÓN DE SERVICIOS DE INVERSIÓN
Monex Private Banking

CLIENTE: Roberto González Martínez
ESTRATEGIA: Moderate Global Strategy
MONTO INICIAL: USD $500,000

COMPOSICIÓN OBJETIVO:
- 60% Renta Fija USD
- 40% Renta Variable Global

COMISIONES:
- Comisión de administración: 0.85% anual
- Sin comisión por entrada o salida después de 6 meses

REPORTERÍA:
- Estado de cuenta mensual
- Reporte de performance trimestral
- Reunión de revisión semestral

Fecha: 20 de enero de 2024',
'2024-01-20', 'ACTIVO', 'ES', CURRENT_TIMESTAMP());

-- =================================================================
-- PASO 10: CREAR STAGES
-- =================================================================

CREATE OR REPLACE STAGE STAGES.SEMANTIC_MODELS
    COMMENT = 'Stage para modelos semánticos YAML';

CREATE OR REPLACE STAGE STAGES.STREAMLIT_APP
    COMMENT = 'Stage para aplicación Streamlit';

-- =================================================================
-- PASO 11: CONFIGURAR CORTEX SEARCH
-- =================================================================

USE SCHEMA DOCUMENTS;

-- Servicio principal de documentos
CREATE OR REPLACE CORTEX SEARCH SERVICE MONEX_DOCUMENTS_SEARCH
    ON CONTENIDO
    ATTRIBUTES TITULO, TIPO_DOCUMENTO, CATEGORIA, CLIENTE_ID, FECHA_DOCUMENTO
    WAREHOUSE = MONEX_WH
    TARGET_LAG = '1 hour'
    AS (
        SELECT 
            DOCUMENTO_ID,
            TITULO,
            TIPO_DOCUMENTO,
            CATEGORIA,
            CLIENTE_ID,
            CONTENIDO,
            FECHA_DOCUMENTO,
            ESTADO,
            IDIOMA
        FROM CORE.DOCUMENTOS
        WHERE ESTADO = 'ACTIVO'
    );

-- Servicio para contratos
CREATE OR REPLACE CORTEX SEARCH SERVICE MONEX_CONTRATOS_SEARCH
    ON CONTENIDO
    ATTRIBUTES TITULO, CATEGORIA, CLIENTE_ID, FECHA_DOCUMENTO
    WAREHOUSE = MONEX_WH
    TARGET_LAG = '30 minutes'
    AS (
        SELECT 
            DOCUMENTO_ID,
            TITULO,
            TIPO_DOCUMENTO,
            CATEGORIA,
            CLIENTE_ID,
            CONTENIDO,
            FECHA_DOCUMENTO
        FROM CORE.DOCUMENTOS
        WHERE TIPO_DOCUMENTO = 'CONTRATO' 
          AND ESTADO = 'ACTIVO'
    );

-- Servicio para manuales
CREATE OR REPLACE CORTEX SEARCH SERVICE MONEX_MANUALES_SEARCH
    ON CONTENIDO
    ATTRIBUTES TITULO, CATEGORIA, FECHA_DOCUMENTO
    WAREHOUSE = MONEX_WH
    TARGET_LAG = '1 day'
    AS (
        SELECT 
            DOCUMENTO_ID,
            TITULO,
            TIPO_DOCUMENTO,
            CATEGORIA,
            CONTENIDO,
            FECHA_DOCUMENTO
        FROM CORE.DOCUMENTOS
        WHERE TIPO_DOCUMENTO IN ('MANUAL', 'POLITICA')
          AND ESTADO = 'ACTIVO'
    );

-- =================================================================
-- PASO 12: CONFIGURAR PERMISOS
-- =================================================================

-- Crear rol de aplicación
CREATE OR REPLACE ROLE MONEX_APP_ROLE;

-- Permisos básicos
GRANT USAGE ON DATABASE MONEX_DB TO ROLE MONEX_APP_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE MONEX_DB TO ROLE MONEX_APP_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA CORE TO ROLE MONEX_APP_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA ANALYTICS TO ROLE MONEX_APP_ROLE;
GRANT USAGE ON WAREHOUSE MONEX_WH TO ROLE MONEX_APP_ROLE;

-- Permisos para Cortex
GRANT ROLE SNOWFLAKE.CORTEX_USER TO ROLE MONEX_APP_ROLE;

-- Permisos para Cortex Search
GRANT USAGE ON CORTEX SEARCH SERVICE MONEX_DOCUMENTS_SEARCH TO ROLE MONEX_APP_ROLE;
GRANT USAGE ON CORTEX SEARCH SERVICE MONEX_CONTRATOS_SEARCH TO ROLE MONEX_APP_ROLE;
GRANT USAGE ON CORTEX SEARCH SERVICE MONEX_MANUALES_SEARCH TO ROLE MONEX_APP_ROLE;

-- Permisos para stages
GRANT READ, WRITE ON STAGE STAGES.SEMANTIC_MODELS TO ROLE MONEX_APP_ROLE;
GRANT READ, WRITE ON STAGE STAGES.STREAMLIT_APP TO ROLE MONEX_APP_ROLE;

-- Otorgar rol al usuario actual y PUBLIC
GRANT ROLE MONEX_APP_ROLE TO USER CURRENT_USER();
GRANT ROLE MONEX_APP_ROLE TO ROLE PUBLIC;

COMMIT;

-- =================================================================
-- VERIFICACIÓN FINAL
-- =================================================================

SELECT 'Instalación completada exitosamente!' AS STATUS;
SELECT COUNT(*) AS CLIENTES FROM CORE.CLIENTES;
SELECT COUNT(*) AS TRANSACCIONES FROM CORE.TRANSACCIONES;
SELECT COUNT(*) AS INVERSIONES FROM CORE.INVERSIONES;
SELECT COUNT(*) AS DOCUMENTOS FROM CORE.DOCUMENTOS;
SHOW CORTEX SEARCH SERVICES IN SCHEMA DOCUMENTS;

-- =================================================================
-- PRÓXIMOS PASOS MANUALES
-- =================================================================

/*
🎉 ¡INSTALACIÓN COMPLETADA!

PRÓXIMOS PASOS MANUALES:

1. SUBIR ARCHIVOS:
   a) Subir monex_semantic_model.yaml a @MONEX_DB.STAGES.SEMANTIC_MODELS
   b) Subir monex_app.py a @MONEX_DB.STAGES.STREAMLIT_APP

2. CREAR APLICACIÓN STREAMLIT:
   Ejecutar el comando:
   
   CREATE OR REPLACE STREAMLIT MONEX_ANALYTICS_APP
       ROOT_LOCATION = '@MONEX_DB.STAGES.STREAMLIT_APP'
       MAIN_FILE = 'monex_app.py'
       QUERY_WAREHOUSE = MONEX_WH
       TITLE = 'Monex Grupo Financiero - Analytics Hub';

3. ACCEDER A LA APP:
   Data > Streamlit Apps > MONEX_ANALYTICS_APP

¡Todo listo para usar Cortex Analyst y Cortex Search!
*/


