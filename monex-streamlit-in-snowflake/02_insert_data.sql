-- =================================================================
-- DATOS SINTÉTICOS PARA MONEX GRUPO FINANCIERO
-- =================================================================

USE DATABASE MONEX_DB;
USE SCHEMA CORE;
USE WAREHOUSE MONEX_WH;

-- =================================================================
-- INSERTAR PRODUCTOS FINANCIEROS
-- =================================================================

INSERT INTO PRODUCTOS VALUES
-- Créditos Corporativos
('CRED_CORP_001', 'Crédito Simple Empresarial', 'CREDITO', 'EMPRESARIAL', 'MXN', 12.5000, 1.5000, 100000.00, 50000000.00, 'Crédito para capital de trabajo empresarial', 'ACTIVO', CURRENT_TIMESTAMP()),
('CRED_CORP_002', 'Línea de Crédito Revolvente', 'CREDITO', 'CORPORATIVO', 'MXN', 14.0000, 2.0000, 500000.00, 100000000.00, 'Línea de crédito flexible para grandes empresas', 'ACTIVO', CURRENT_TIMESTAMP()),
('CRED_USD_001', 'Crédito USD Corporativo', 'CREDITO', 'CORPORATIVO', 'USD', 8.5000, 1.0000, 50000.00, 10000000.00, 'Financiamiento en dólares para empresas', 'ACTIVO', CURRENT_TIMESTAMP()),

-- Factoraje
('FACT_001', 'Factoraje Sin Recurso', 'FACTORAJE', 'SIN_RECURSO', 'MXN', 15.0000, 2.5000, 50000.00, 25000000.00, 'Factoraje sin recurso para empresas', 'ACTIVO', CURRENT_TIMESTAMP()),
('FACT_002', 'Factoraje Electrónico', 'FACTORAJE', 'ELECTRONICO', 'MXN', 14.5000, 2.0000, 25000.00, 15000000.00, 'Factoraje digital y ágil', 'ACTIVO', CURRENT_TIMESTAMP()),
('FACT_CAD_001', 'Cadenas Productivas NAFIN', 'FACTORAJE', 'CADENA_PRODUCTIVA', 'MXN', 12.0000, 1.5000, 10000.00, 5000000.00, 'Factoraje para cadenas productivas NAFIN', 'ACTIVO', CURRENT_TIMESTAMP()),

-- Inversiones USD
('INV_USD_001', 'USD Fixed Income', 'INVERSION', 'RENTA_FIJA', 'USD', 4.7000, 0.5000, 10000.00, 10000000.00, 'Estrategia conservadora en renta fija USD', 'ACTIVO', CURRENT_TIMESTAMP()),
('INV_USD_002', 'Global Equity', 'INVERSION', 'ACCIONES', 'USD', 12.8200, 1.0000, 25000.00, 25000000.00, 'Estrategia global en mercados accionarios', 'ACTIVO', CURRENT_TIMESTAMP()),
('INV_USD_003', 'Conservative Global Strategy', 'INVERSION', 'CONSERVADORA', 'USD', 6.6800, 0.7500, 15000.00, 15000000.00, 'Estrategia conservadora global', 'ACTIVO', CURRENT_TIMESTAMP()),
('INV_USD_004', 'Moderate Global Strategy', 'INVERSION', 'MODERADA', 'USD', 8.5800, 0.8500, 20000.00, 20000000.00, 'Estrategia moderada global', 'ACTIVO', CURRENT_TIMESTAMP()),
('INV_USD_005', 'Aggressive Global Strategy', 'INVERSION', 'AGRESIVA', 'USD', 10.6300, 1.2000, 30000.00, 30000000.00, 'Estrategia agresiva para mayor rendimiento', 'ACTIVO', CURRENT_TIMESTAMP()),

-- Fondos MXN
('FONDO_MXN_001', 'Fondo Monex Renta Fija', 'INVERSION', 'RENTA_FIJA', 'MXN', 9.2500, 1.0000, 5000.00, 5000000.00, 'Fondo de inversión en instrumentos de renta fija', 'ACTIVO', CURRENT_TIMESTAMP()),
('FONDO_MXN_002', 'Fondo Monex Mercado Dinero', 'INVERSION', 'MERCADO_DINERO', 'MXN', 7.8000, 0.5000, 1000.00, 1000000.00, 'Inversión líquida en mercado de dinero', 'ACTIVO', CURRENT_TIMESTAMP()),

-- Cambio de Divisas
('FX_001', 'Compra-Venta USD/MXN', 'CAMBIO_DIVISAS', 'SPOT', 'MXN', 0.0000, 0.0100, 100.00, 10000000.00, 'Operaciones de cambio USD/MXN al contado', 'ACTIVO', CURRENT_TIMESTAMP()),
('FX_002', 'Forward USD/MXN', 'CAMBIO_DIVISAS', 'FORWARD', 'USD', 0.0000, 0.0200, 1000.00, 50000000.00, 'Contratos forward para cobertura cambiaria', 'ACTIVO', CURRENT_TIMESTAMP()),

-- Cuentas
('CTA_CORP_001', 'Cuenta Empresarial MXN', 'CUENTA', 'EMPRESARIAL', 'MXN', 2.5000, 500.00, 0.00, 999999999.99, 'Cuenta corriente para empresas', 'ACTIVO', CURRENT_TIMESTAMP()),
('CTA_USD_001', 'Cuenta USD Empresarial', 'CUENTA', 'EMPRESARIAL', 'USD', 1.2000, 25.00, 0.00, 999999999.99, 'Cuenta en dólares para empresas', 'ACTIVO', CURRENT_TIMESTAMP()),
('CTA_PRIV_001', 'Cuenta Private Banking', 'CUENTA', 'PRIVATE', 'MXN', 3.0000, 1000.00, 50000.00, 999999999.99, 'Cuenta exclusiva para private banking', 'ACTIVO', CURRENT_TIMESTAMP());

-- =================================================================
-- INSERTAR CLIENTES
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
-- INSERTAR TIPOS DE CAMBIO (últimos 90 días)
-- =================================================================

INSERT INTO TIPOS_CAMBIO 
WITH FECHAS AS (
    SELECT DATEADD(day, -ROW_NUMBER() OVER (ORDER BY NULL) + 1, CURRENT_DATE()) AS FECHA
    FROM TABLE(GENERATOR(ROWCOUNT => 90))
),
CAMBIOS AS (
    SELECT 
        FECHA,
        'USD' AS MONEDA_ORIGEN,
        'MXN' AS MONEDA_DESTINO,
        -- Tipo de cambio base alrededor de 18.50, con variación aleatoria
        (18.50 + (UNIFORM(0, 200, RANDOM()) / 100.0 - 1))::DECIMAL(10,6) AS TIPO_BASE
    FROM FECHAS
)
SELECT 
    FECHA,
    MONEDA_ORIGEN,
    MONEDA_DESTINO,
    (TIPO_BASE - 0.10)::DECIMAL(10,6) AS TIPO_CAMBIO_COMPRA,
    (TIPO_BASE + 0.10)::DECIMAL(10,6) AS TIPO_CAMBIO_VENTA,
    (UNIFORM(1000000, 6000000, RANDOM()))::DECIMAL(15,2) AS VOLUMEN_TRANSACCIONES,
    CURRENT_TIMESTAMP() AS FECHA_ACTUALIZACION
FROM CAMBIOS;

-- =================================================================
-- INSERTAR TRANSACCIONES (datos de los últimos 12 meses)
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
        'TXN_' || LPAD(RN, 8, '0') AS TRANSACCION_ID,
        -- Seleccionar cliente aleatoriamente
        (ARRAY_CONSTRUCT('CORP_001','CORP_002','CORP_003','CORP_004','CORP_005','CORP_006','CORP_007','CORP_008',
                        'PYME_001','PYME_002','PYME_003','PYME_004','PYME_005',
                        'PRIV_001','PRIV_002','PRIV_003','PRIV_004','PRIV_005',
                        'IND_001','IND_002','IND_003'))[MOD(ABS(R1 * 1000000)::INT, 21) + 1]::VARCHAR AS CLIENTE_ID,
        -- Seleccionar producto aleatoriamente
        (ARRAY_CONSTRUCT('CRED_CORP_001','FACT_001','INV_USD_001','INV_USD_002','FONDO_MXN_001','FX_001','CTA_CORP_001'))[MOD(ABS(R2 * 1000000)::INT, 7) + 1]::VARCHAR AS PRODUCTO_ID,
        -- Tipo de transacción
        (ARRAY_CONSTRUCT('DEPOSITO','RETIRO','TRANSFERENCIA','INVERSION','CAMBIO_FX'))[MOD(ABS(R3 * 1000000)::INT, 5) + 1]::VARCHAR AS TIPO_TRANSACCION,
        -- Monto aleatorio según el tipo
        CASE 
            WHEN MOD(ABS(R4 * 100)::INT, 100) < 30 THEN (MOD(ABS(R5 * 49000)::INT, 49000) + 1000)::DECIMAL(15,2)  -- Transacciones pequeñas
            WHEN MOD(ABS(R4 * 100)::INT, 100) < 70 THEN (MOD(ABS(R5 * 450000)::INT, 450000) + 50000)::DECIMAL(15,2)  -- Transacciones medianas  
            ELSE (MOD(ABS(R5 * 4500000)::INT, 4500000) + 500000)::DECIMAL(15,2)  -- Transacciones grandes
        END AS MONTO,
        -- Moneda
        (ARRAY_CONSTRUCT('MXN','USD'))[MOD(ABS(R6 * 1000000)::INT, 2) + 1]::VARCHAR AS MONEDA,
        -- Fecha aleatoria en los últimos 12 meses
        DATEADD(hour, MOD(ABS(R8 * 24)::INT, 24), 
            DATEADD(day, -MOD(ABS(R7 * 365)::INT, 365), CURRENT_DATE())
        ) AS FECHA_TRANSACCION,
        'COMPLETADA' AS ESTADO,
        (ARRAY_CONSTRUCT('DIGITAL','SUCURSAL','TELEFONO'))[MOD(ABS(R7 * 1000000)::INT, 3) + 1]::VARCHAR AS CANAL,
        CASE 
            WHEN MOD(ABS(R8 * 100)::INT, 100) < 40 THEN 'SUCURSAL_CDMX_CENTRO'
            WHEN MOD(ABS(R8 * 100)::INT, 100) < 60 THEN 'SUCURSAL_MTY_CENTRO'  
            WHEN MOD(ABS(R8 * 100)::INT, 100) < 80 THEN 'SUCURSAL_GDL_CENTRO'
            ELSE 'DIGITAL_PLATFORM'
        END AS SUCURSAL
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
    (MONTO * 0.002)::DECIMAL(10,2) AS COMISION,  -- Comisión del 0.2%
    CURRENT_TIMESTAMP() AS FECHA_CREACION
FROM DATOS_TRANS;

-- =================================================================
-- INSERTAR INVERSIONES
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
        'INV_' || LPAD(RN, 8, '0') AS INVERSION_ID,
        -- Solo clientes PRIVADO y algunos CORPORATIVO
        (ARRAY_CONSTRUCT('PRIV_001','PRIV_002','PRIV_003','PRIV_004','PRIV_005',
                        'CORP_001','CORP_002','CORP_003'))[MOD(ABS(R1 * 1000000)::INT, 8) + 1]::VARCHAR AS CLIENTE_ID,
        -- Estrategias de inversión
        (ARRAY_CONSTRUCT('USD_FIXED_INCOME','GLOBAL_EQUITY','CONSERVATIVE','MODERATE','AGGRESSIVE'))[MOD(ABS(R2 * 1000000)::INT, 5) + 1]::VARCHAR AS FONDO_ESTRATEGIA,
        -- Monto invertido
        CASE 
            WHEN (ABS(R3) * 100) < 30 THEN ((ABS(R4) * 90000) + 10000)::DECIMAL(15,2)   -- Inversiones pequeñas
            WHEN (ABS(R3) * 100) < 70 THEN ((ABS(R4) * 900000) + 100000)::DECIMAL(15,2) -- Inversiones medianas
            ELSE ((ABS(R4) * 9000000) + 1000000)::DECIMAL(15,2)                   -- Inversiones grandes
        END AS MONTO_INVERTIDO,
        'USD' AS MONEDA,
        -- Fecha de inversión en los últimos 18 meses
        DATEADD(day, -(ABS(R4) * 540)::INT, CURRENT_DATE()) AS FECHA_INVERSION
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
    CASE FONDO_ESTRATEGIA
        WHEN 'USD_FIXED_INCOME' THEN 4.70
        WHEN 'GLOBAL_EQUITY' THEN 12.82
        WHEN 'CONSERVATIVE' THEN 6.68
        WHEN 'MODERATE' THEN 8.58
        WHEN 'AGGRESSIVE' THEN 10.63
    END + (((ABS(R3) * 200) - 100) / 100.0) AS RENDIMIENTO_ANUAL,  -- Pequeña variación
    MONTO_INVERTIDO * (1 + (DATEDIFF(day, FECHA_INVERSION, CURRENT_DATE()) / 365.0) * 
        CASE FONDO_ESTRATEGIA
            WHEN 'USD_FIXED_INCOME' THEN 0.047
            WHEN 'GLOBAL_EQUITY' THEN 0.1282
            WHEN 'CONSERVATIVE' THEN 0.0668
            WHEN 'MODERATE' THEN 0.0858
            WHEN 'AGGRESSIVE' THEN 0.1063
        END
    ) AS VALOR_ACTUAL,
    'ACTIVA' AS ESTADO,
    'Inversión gestionada por Monex Private Banking' AS NOTAS,
    CURRENT_TIMESTAMP() AS FECHA_CREACION
FROM DATOS_INV;

-- =================================================================
-- INSERTAR OPERACIONES DE FACTORAJE
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
        'FACT_' || LPAD(RN, 8, '0') AS FACTORAJE_ID,
        -- Solo clientes corporativos y PYME
        (ARRAY_CONSTRUCT('CORP_001','CORP_002','CORP_003','CORP_004','CORP_005',
                        'PYME_001','PYME_002','PYME_003','PYME_004','PYME_005'))[MOD(ABS(R1 * 1000000)::INT, 10) + 1]::VARCHAR AS CLIENTE_ID,
        'FAC' || LPAD((ABS(R2) * 899999 + 100000)::INT, 6, '0') AS NUMERO_FACTURA,
        -- Empresas deudoras ficticias
        (ARRAY_CONSTRUCT('Liverpool S.A.B. de C.V.','El Palacio de Hierro S.A.',
                        'Soriana S.A.B. de C.V.','Chedraui S.A.B. de C.V.',
                        'Office Depot de México S.A.','Home Depot México S.A.',
                        'Costco de México S.A.','Sam''s Club México S.A.'))[MOD(ABS(R3 * 1000000)::INT, 8) + 1]::VARCHAR AS EMPRESA_DEUDORA,
        -- Monto factura
        ((ABS(R4) * 1900000) + 100000)::DECIMAL(15,2) AS MONTO_FACTURA,
        -- Fecha factura en los últimos 6 meses
        DATEADD(day, -(ABS(R5) * 180)::INT, CURRENT_DATE()) AS FECHA_FACTURA,
        -- Tasa de descuento entre 12% y 18%
        ((ABS(R6) * 6.0) + 12.0)::DECIMAL(8,4) AS TASA_DESCUENTO
    FROM RANDOMS_FACT
)
SELECT 
    FACTORAJE_ID,
    CLIENTE_ID,
    NUMERO_FACTURA,
    EMPRESA_DEUDORA,
    MONTO_FACTURA,
    MONTO_FACTURA * 0.85 AS MONTO_ADELANTO,  -- 85% del valor de la factura
    FECHA_FACTURA,
    DATEADD(day, (ABS(R6) * 60 + 30)::INT, FECHA_FACTURA) AS FECHA_VENCIMIENTO,  -- 30-90 días
    FECHA_FACTURA AS FECHA_OPERACION,
    TASA_DESCUENTO,
    2.5 AS COMISION,
    CASE 
        WHEN FECHA_FACTURA > DATEADD(day, -90, CURRENT_DATE()) THEN 'VIGENTE'
        WHEN (ABS(R5) * 100) < 10 THEN 'VENCIDO'
        ELSE 'COBRADO'
    END AS ESTADO,
    'SIN_RECURSO' AS TIPO_FACTORAJE,
    CURRENT_TIMESTAMP() AS FECHA_CREACION
FROM DATOS_FACT;

COMMIT;

SELECT 'Datos sintéticos insertados exitosamente!' AS STATUS;
