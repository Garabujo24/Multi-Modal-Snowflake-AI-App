-- ============================================================================
-- OfficeMax México - Snowflake Quickstart Setup Script
-- Duración estimada: 5-10 minutos
-- Propósito: Configuración completa del entorno para el quickstart Back-to-School
-- ============================================================================

-- Configuración inicial
USE ROLE SYSADMIN;

-- ============================================================================
-- PASO 1: CREAR ESTRUCTURAS PRINCIPALES
-- ============================================================================

-- Crear base de datos principal
CREATE OR REPLACE DATABASE OFFICEMAX_ANALYTICS;
USE DATABASE OFFICEMAX_ANALYTICS;

-- Crear esquemas organizacionales
CREATE OR REPLACE SCHEMA RAW_DATA COMMENT = 'Datos en bruto de ventas, productos e inventario';
CREATE OR REPLACE SCHEMA ANALYTICS COMMENT = 'Vistas y tablas procesadas para análisis';
CREATE OR REPLACE SCHEMA ML_MODELS COMMENT = 'Modelos de Machine Learning y pronósticos';

-- Crear warehouse para análisis con configuración optimizada
CREATE OR REPLACE WAREHOUSE OFFICEMAX_WH WITH
    WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse principal para analytics de OfficeMax';

-- Crear warehouse específico para reportes
CREATE OR REPLACE WAREHOUSE OFFICEMAX_REPORTING_WH WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse optimizado para reportes de temporada escolar';

USE WAREHOUSE OFFICEMAX_WH;

-- ============================================================================
-- PASO 2: CREAR TABLAS DE DATOS BASE
-- ============================================================================

-- Tabla de productos Back-to-School
CREATE OR REPLACE TABLE RAW_DATA.PRODUCTOS (
    PRODUCTO_ID INTEGER PRIMARY KEY,
    NOMBRE_PRODUCTO VARCHAR(200) NOT NULL,
    CATEGORIA VARCHAR(100) NOT NULL,
    SUB_CATEGORIA VARCHAR(100),
    PRECIO_UNITARIO DECIMAL(10,2) NOT NULL,
    COSTO_UNITARIO DECIMAL(10,2) NOT NULL,
    MARCA VARCHAR(100),
    TEMPORADA VARCHAR(50) DEFAULT 'Back-to-School',
    ACTIVO BOOLEAN DEFAULT TRUE,
    FECHA_INGRESO TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    DESCRIPCION TEXT,
    COMENTARIOS VARCHAR(500)
);

-- Tabla de ventas históricas
CREATE OR REPLACE TABLE RAW_DATA.VENTAS (
    VENTA_ID INTEGER AUTOINCREMENT PRIMARY KEY,
    PRODUCTO_ID INTEGER NOT NULL,
    FECHA_VENTA DATE NOT NULL,
    CANTIDAD INTEGER NOT NULL CHECK (CANTIDAD > 0),
    PRECIO_VENTA DECIMAL(10,2) NOT NULL CHECK (PRECIO_VENTA > 0),
    DESCUENTO_APLICADO DECIMAL(5,2) DEFAULT 0 CHECK (DESCUENTO_APLICADO >= 0 AND DESCUENTO_APLICADO <= 100),
    SUCURSAL_ID INTEGER NOT NULL,
    VENDEDOR_ID INTEGER,
    METODO_PAGO VARCHAR(50) DEFAULT 'Efectivo',
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (PRODUCTO_ID) REFERENCES RAW_DATA.PRODUCTOS(PRODUCTO_ID)
);

-- Tabla de clientes
CREATE OR REPLACE TABLE RAW_DATA.CLIENTES (
    CLIENTE_ID INTEGER PRIMARY KEY,
    NOMBRE VARCHAR(100) NOT NULL,
    EMAIL VARCHAR(200) UNIQUE,
    TELEFONO VARCHAR(20),
    FECHA_REGISTRO DATE NOT NULL,
    TIPO_CLIENTE VARCHAR(50) DEFAULT 'Individual', -- Individual, Corporativo, Educativo
    CIUDAD VARCHAR(100),
    ESTADO VARCHAR(100),
    CODIGO_POSTAL VARCHAR(10),
    ACTIVO BOOLEAN DEFAULT TRUE,
    FECHA_ACTUALIZACION TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Tabla de inventario por sucursal
CREATE OR REPLACE TABLE RAW_DATA.INVENTARIO_BACK_TO_SCHOOL (
    INVENTARIO_ID INTEGER AUTOINCREMENT PRIMARY KEY,
    PRODUCTO_ID INTEGER NOT NULL,
    SUCURSAL_ID INTEGER NOT NULL,
    STOCK_ACTUAL INTEGER NOT NULL CHECK (STOCK_ACTUAL >= 0),
    STOCK_MINIMO INTEGER NOT NULL CHECK (STOCK_MINIMO >= 0),
    STOCK_MAXIMO INTEGER NOT NULL CHECK (STOCK_MAXIMO >= STOCK_MINIMO),
    ULTIMA_ACTUALIZACION TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (PRODUCTO_ID) REFERENCES RAW_DATA.PRODUCTOS(PRODUCTO_ID),
    UNIQUE (PRODUCTO_ID, SUCURSAL_ID)
);

-- Tabla para datos JSON (transacciones e-commerce)
CREATE OR REPLACE TABLE RAW_DATA.TRANSACCIONES_JSON (
    JSON_ID INTEGER AUTOINCREMENT PRIMARY KEY,
    ARCHIVO_ORIGEN VARCHAR(200),
    CONTENIDO_JSON VARIANT NOT NULL,
    FECHA_CARGA TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Tabla de eventos de marketing
CREATE OR REPLACE TABLE RAW_DATA.EVENTOS_MARKETING (
    EVENTO_ID INTEGER AUTOINCREMENT PRIMARY KEY,
    FECHA_EVENTO DATE NOT NULL,
    TIPO_EVENTO VARCHAR(100) NOT NULL,
    SUCURSAL_ID INTEGER,
    METADATA_JSON VARIANT,
    ACTIVO BOOLEAN DEFAULT TRUE,
    FECHA_CREACION TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- PASO 3: INSERTAR DATOS SIMULADOS DE PRODUCTOS
-- ============================================================================

-- Productos de temporada Back-to-School
INSERT INTO RAW_DATA.PRODUCTOS (PRODUCTO_ID, NOMBRE_PRODUCTO, CATEGORIA, SUB_CATEGORIA, PRECIO_UNITARIO, COSTO_UNITARIO, MARCA, DESCRIPCION) VALUES
-- Mochilas y Bolsas
(1001, 'Mochila Escolar Premium', 'Mochilas', 'Primaria', 899.00, 450.00, 'Kipling', 'Mochila resistente con múltiples compartimentos, ideal para niños de primaria'),
(1007, 'Mochila con Ruedas', 'Mochilas', 'Secundaria', 1299.00, 650.00, 'Samsonite', 'Mochila con sistema de ruedas, perfecta para estudiantes de secundaria'),
(1015, 'Morral Deportivo', 'Mochilas', 'Universitaria', 650.00, 325.00, 'Nike', 'Morral deportivo para actividades escolares y extracurriculares'),

-- Papelería Básica
(1002, 'Cuaderno Profesional 100 hojas', 'Papelería', 'Cuadernos', 45.00, 22.50, 'Scribe', 'Cuaderno profesional con hojas cuadriculadas, ideal para matemáticas'),
(1003, 'Set Plumas BIC 10 piezas', 'Papelería', 'Escritura', 85.00, 42.50, 'BIC', 'Set de plumas de colores variados, tinta de alta calidad'),
(1005, 'Pegamento en Barra', 'Papelería', 'Adhesivos', 25.00, 12.50, 'Resistol', 'Pegamento en barra lavable, no tóxico'),
(1006, 'Folder Tamaño Carta', 'Organización', 'Folders', 15.00, 7.50, 'Wilson Jones', 'Folder de plástico resistente, varios colores disponibles'),
(1016, 'Marcadores Fluorescentes 6pz', 'Papelería', 'Resaltadores', 95.00, 47.50, 'Stabilo', 'Set de marcadores fluorescentes en colores vibrantes'),
(1017, 'Hojas Blancas 500 hojas', 'Papelería', 'Papel', 180.00, 90.00, 'International Paper', 'Paquete de hojas blancas tamaño carta, 75gr'),

-- Tecnología y Calculadoras
(1004, 'Calculadora Científica', 'Tecnología', 'Calculadoras', 450.00, 225.00, 'Casio', 'Calculadora científica con funciones avanzadas para secundaria y preparatoria'),
(1018, 'Calculadora Básica', 'Tecnología', 'Calculadoras', 120.00, 60.00, 'Canon', 'Calculadora básica de 8 dígitos para operaciones simples'),

-- Arte y Creatividad
(1008, 'Lápices de Colores 24 pzs', 'Arte', 'Colores', 120.00, 60.00, 'Prismacolor', 'Set de lápices de colores de alta calidad para proyectos artísticos'),
(1019, 'Acuarelas 12 colores', 'Arte', 'Pintura', 85.00, 42.50, 'Winsor & Newton', 'Set de acuarelas profesionales con pincel incluido'),
(1020, 'Plastilina 8 colores', 'Arte', 'Modelado', 65.00, 32.50, 'Play-Doh', 'Set de plastilina no tóxica en colores variados'),

-- Organización y Archivo
(1021, 'Archivero Escolar', 'Organización', 'Archiveros', 250.00, 125.00, 'Leitz', 'Archivero plástico con separadores para organizar documentos'),
(1022, 'Separadores A-Z', 'Organización', 'Separadores', 45.00, 22.50, 'Avery', 'Separadores alfabéticos para organización de materiales'),

-- Instrumentos de Medición
(1023, 'Regla 30cm', 'Instrumentos', 'Medición', 18.00, 9.00, 'Faber-Castell', 'Regla transparente graduada en centímetros y pulgadas'),
(1024, 'Compás Escolar', 'Instrumentos', 'Geometría', 75.00, 37.50, 'Rotring', 'Compás de precisión para clases de geometría'),
(1025, 'Escuadras Juego 2pz', 'Instrumentos', 'Geometría', 35.00, 17.50, 'Staedtler', 'Juego de escuadras de 45° y 60° transparentes');

-- ============================================================================
-- PASO 4: INSERTAR DATOS DE CLIENTES
-- ============================================================================

INSERT INTO RAW_DATA.CLIENTES (CLIENTE_ID, NOMBRE, EMAIL, TELEFONO, FECHA_REGISTRO, TIPO_CLIENTE, CIUDAD, ESTADO, CODIGO_POSTAL) VALUES
-- Clientes Individuales
(2001, 'María González Pérez', 'maria.gonzalez@gmail.com', '555-0101', '2023-08-15', 'Individual', 'México DF', 'CDMX', '01000'),
(2003, 'Juan Pérez López', 'juan.perez@hotmail.com', '555-0301', '2023-08-01', 'Individual', 'Monterrey', 'Nuevo León', '64000'),
(2005, 'Ana Martínez Silva', 'ana.martinez@yahoo.com', '555-0501', '2023-07-25', 'Individual', 'Guadalajara', 'Jalisco', '44100'),
(2007, 'Carlos Rodríguez Hernández', 'carlos.rodriguez@outlook.com', '555-0701', '2023-08-10', 'Individual', 'Puebla', 'Puebla', '72000'),
(2009, 'Laura Sánchez Torres', 'laura.sanchez@gmail.com', '555-0901', '2023-07-30', 'Individual', 'Tijuana', 'Baja California', '22000'),

-- Clientes Educativos (Instituciones)
(2002, 'Colegio Benito Juárez', 'compras@colegiobj.edu.mx', '555-0201', '2023-07-20', 'Educativo', 'Guadalajara', 'Jalisco', '44200'),
(2006, 'Instituto Tecnológico Regional', 'adquisiciones@itr.edu.mx', '555-0601', '2023-07-15', 'Educativo', 'Monterrey', 'Nuevo León', '64100'),
(2008, 'Escuela Primaria Revolución', 'direccion@revolucion.edu.mx', '555-0801', '2023-08-05', 'Educativo', 'México DF', 'CDMX', '03100'),
(2010, 'Universidad del Valle', 'compras@univalle.edu.mx', '555-1001', '2023-07-12', 'Educativo', 'Puebla', 'Puebla', '72100'),

-- Clientes Corporativos
(2004, 'Empresa ABC SA de CV', 'compras@empresaabc.com', '555-0401', '2023-07-10', 'Corporativo', 'Puebla', 'Puebla', '72010'),
(2011, 'Corporativo XYZ', 'adquisiciones@xyz.com.mx', '555-1101', '2023-08-01', 'Corporativo', 'México DF', 'CDMX', '11000'),
(2012, 'Oficinas Centrales Norte', 'compras@norte.com.mx', '555-1201', '2023-07-28', 'Corporativo', 'Monterrey', 'Nuevo León', '64200');

-- ============================================================================
-- PASO 5: INSERTAR INVENTARIO POR SUCURSAL
-- ============================================================================

INSERT INTO RAW_DATA.INVENTARIO_BACK_TO_SCHOOL (PRODUCTO_ID, SUCURSAL_ID, STOCK_ACTUAL, STOCK_MINIMO, STOCK_MAXIMO) VALUES
-- Sucursal 101 (México DF - Centro)
(1001, 101, 45, 10, 100), (1002, 101, 150, 50, 500), (1003, 101, 75, 25, 200),
(1004, 101, 12, 5, 50), (1005, 101, 200, 100, 1000), (1006, 101, 300, 100, 800),
(1007, 101, 8, 5, 30), (1008, 101, 60, 20, 150), (1015, 101, 25, 10, 80),
(1016, 101, 40, 15, 120), (1017, 101, 80, 30, 200), (1018, 101, 35, 15, 100),
(1019, 101, 50, 20, 150), (1020, 101, 70, 25, 200), (1021, 101, 20, 8, 60),
(1022, 101, 90, 30, 250), (1023, 101, 120, 50, 300), (1024, 101, 30, 12, 80),
(1025, 101, 85, 30, 200),

-- Sucursal 102 (Monterrey - San Pedro)
(1001, 102, 32, 10, 100), (1002, 102, 200, 50, 500), (1003, 102, 90, 25, 200),
(1004, 102, 18, 5, 50), (1005, 102, 350, 100, 1000), (1006, 102, 250, 100, 800),
(1007, 102, 6, 5, 30), (1008, 102, 45, 20, 150), (1015, 102, 30, 10, 80),
(1016, 102, 55, 15, 120), (1017, 102, 65, 30, 200), (1018, 102, 42, 15, 100),
(1019, 102, 38, 20, 150), (1020, 102, 85, 25, 200), (1021, 102, 15, 8, 60),
(1022, 102, 75, 30, 250), (1023, 102, 95, 50, 300), (1024, 102, 25, 12, 80),
(1025, 102, 70, 30, 200),

-- Sucursal 103 (Guadalajara - Zapopan)
(1001, 103, 28, 10, 100), (1002, 103, 180, 50, 500), (1003, 103, 65, 25, 200),
(1004, 103, 15, 5, 50), (1005, 103, 300, 100, 1000), (1006, 103, 400, 100, 800),
(1007, 103, 10, 5, 30), (1008, 103, 55, 20, 150), (1015, 103, 20, 10, 80),
(1016, 103, 48, 15, 120), (1017, 103, 90, 30, 200), (1018, 103, 38, 15, 100),
(1019, 103, 62, 20, 150), (1020, 103, 75, 25, 200), (1021, 103, 25, 8, 60),
(1022, 103, 110, 30, 250), (1023, 103, 140, 50, 300), (1024, 103, 35, 12, 80),
(1025, 103, 95, 30, 200);

-- ============================================================================
-- PASO 6: GENERAR VENTAS HISTÓRICAS (ÚLTIMOS 2 MESES)
-- ============================================================================

-- Generador de ventas para julio 2024
INSERT INTO RAW_DATA.VENTAS (PRODUCTO_ID, FECHA_VENTA, CANTIDAD, PRECIO_VENTA, SUCURSAL_ID, VENDEDOR_ID, METODO_PAGO) 
SELECT 
    (1001 + (ROW_NUMBER() OVER (ORDER BY SEQ4()) % 15)) as PRODUCTO_ID, -- Rotar entre productos
    DATEADD('day', -(ROW_NUMBER() OVER (ORDER BY SEQ4()) % 45), '2024-07-31') as FECHA_VENTA, -- Últimos 45 días
    (1 + (ROW_NUMBER() OVER (ORDER BY SEQ4()) % 10)) as CANTIDAD, -- 1-10 unidades
    (SELECT PRECIO_UNITARIO FROM RAW_DATA.PRODUCTOS p WHERE p.PRODUCTO_ID = (1001 + (ROW_NUMBER() OVER (ORDER BY SEQ4()) % 15))) as PRECIO_VENTA,
    (101 + (ROW_NUMBER() OVER (ORDER BY SEQ4()) % 3)) as SUCURSAL_ID, -- Sucursales 101-103
    (501 + (ROW_NUMBER() OVER (ORDER BY SEQ4()) % 5)) as VENDEDOR_ID, -- Vendedores 501-505
    CASE (ROW_NUMBER() OVER (ORDER BY SEQ4()) % 4)
        WHEN 0 THEN 'Efectivo'
        WHEN 1 THEN 'Tarjeta'
        WHEN 2 THEN 'Transferencia'
        ELSE 'PayPal'
    END as METODO_PAGO
FROM TABLE(GENERATOR(ROWCOUNT => 200)); -- Generar 200 ventas base

-- Ventas adicionales específicas para demostrar patrones
INSERT INTO RAW_DATA.VENTAS (PRODUCTO_ID, FECHA_VENTA, CANTIDAD, PRECIO_VENTA, SUCURSAL_ID, VENDEDOR_ID, METODO_PAGO) VALUES
-- Pico de ventas en preparación Back-to-School (mediados de julio)
(1001, '2024-07-15', 15, 899.00, 101, 501, 'Tarjeta'),
(1002, '2024-07-15', 50, 45.00, 101, 501, 'Efectivo'),
(1003, '2024-07-16', 25, 85.00, 102, 502, 'Tarjeta'),
(1004, '2024-07-16', 8, 450.00, 101, 503, 'Transferencia'),
(1005, '2024-07-17', 100, 25.00, 103, 504, 'Efectivo'),
(1001, '2024-07-18', 22, 799.00, 102, 502, 'Tarjeta'), -- Precio con descuento
(1007, '2024-07-19', 5, 1299.00, 101, 501, 'Transferencia'),
(1008, '2024-07-20', 35, 120.00, 103, 505, 'Tarjeta'),

-- Ventas de fin de semana (patrones diferentes)
(1002, '2024-07-13', 80, 45.00, 101, 501, 'Efectivo'), -- Sábado
(1003, '2024-07-14', 45, 85.00, 102, 502, 'Tarjeta'), -- Domingo
(1006, '2024-07-20', 120, 15.00, 103, 503, 'Efectivo'), -- Sábado
(1005, '2024-07-21', 150, 25.00, 101, 504, 'Tarjeta'), -- Domingo

-- Ventas corporativas (volúmenes mayores)
(1002, '2024-07-22', 200, 42.00, 102, 502, 'Transferencia'), -- Descuento por volumen
(1003, '2024-07-22', 150, 80.00, 102, 502, 'Transferencia'),
(1006, '2024-07-23', 500, 14.00, 101, 501, 'Transferencia'),
(1017, '2024-07-23', 50, 170.00, 101, 501, 'Transferencia');

-- ============================================================================
-- PASO 7: INSERTAR DATOS JSON SIMULADOS
-- ============================================================================

-- Transacciones de e-commerce en formato JSON
INSERT INTO RAW_DATA.TRANSACCIONES_JSON (ARCHIVO_ORIGEN, CONTENIDO_JSON) VALUES
('ecommerce_2024_07_15.json', PARSE_JSON('{
    "transaction_id": "TXN-001",
    "timestamp": "2024-07-15T10:30:00Z",
    "customer": {
        "id": 2001,
        "type": "registered",
        "location": "CDMX",
        "segment": "Individual"
    },
    "items": [
        {"product_id": 1001, "name": "Mochila Escolar Premium", "quantity": 1, "unit_price": 899.00, "category": "Mochilas"},
        {"product_id": 1002, "name": "Cuaderno Profesional", "quantity": 3, "unit_price": 45.00, "category": "Papelería"}
    ],
    "payment": {
        "method": "credit_card",
        "total": 1034.00,
        "currency": "MXN",
        "installments": 1
    },
    "shipping": {
        "type": "standard",
        "cost": 99.00,
        "address": "Mexico DF",
        "estimated_delivery": "2024-07-18"
    },
    "analytics": {
        "source": "mobile_app",
        "campaign": "back_to_school_2024",
        "utm_medium": "social_media"
    }
}')),

('ecommerce_2024_07_16.json', PARSE_JSON('{
    "transaction_id": "TXN-002",
    "timestamp": "2024-07-16T14:15:00Z",
    "customer": {
        "id": 2003,
        "type": "guest",
        "location": "MTY",
        "segment": "Individual"
    },
    "items": [
        {"product_id": 1004, "name": "Calculadora Científica", "quantity": 1, "unit_price": 450.00, "category": "Tecnología"},
        {"product_id": 1008, "name": "Lápices de Colores 24 pzs", "quantity": 2, "unit_price": 120.00, "category": "Arte"}
    ],
    "payment": {
        "method": "paypal",
        "total": 690.00,
        "currency": "MXN",
        "installments": 1
    },
    "shipping": {
        "type": "express",
        "cost": 149.00,
        "address": "Monterrey",
        "estimated_delivery": "2024-07-17"
    },
    "analytics": {
        "source": "website",
        "campaign": "calculadora_promo",
        "utm_medium": "email"
    }
}')),

('ecommerce_2024_07_17.json', PARSE_JSON('{
    "transaction_id": "TXN-003",
    "timestamp": "2024-07-17T09:45:00Z",
    "customer": {
        "id": 2002,
        "type": "corporate",
        "location": "GDL",
        "segment": "Educativo"
    },
    "items": [
        {"product_id": 1002, "name": "Cuaderno Profesional", "quantity": 100, "unit_price": 42.00, "category": "Papelería"},
        {"product_id": 1003, "name": "Set Plumas BIC", "quantity": 50, "unit_price": 80.00, "category": "Papelería"},
        {"product_id": 1005, "name": "Pegamento en Barra", "quantity": 200, "unit_price": 23.00, "category": "Papelería"}
    ],
    "payment": {
        "method": "bank_transfer",
        "total": 12600.00,
        "currency": "MXN",
        "installments": 1
    },
    "shipping": {
        "type": "institutional",
        "cost": 0.00,
        "address": "Guadalajara",
        "estimated_delivery": "2024-07-19"
    },
    "analytics": {
        "source": "b2b_portal",
        "campaign": "institutional_discount",
        "utm_medium": "direct"
    }
}'));

-- ============================================================================
-- PASO 8: INSERTAR EVENTOS DE MARKETING
-- ============================================================================

INSERT INTO RAW_DATA.EVENTOS_MARKETING (FECHA_EVENTO, TIPO_EVENTO, SUCURSAL_ID, METADATA_JSON) VALUES
('2024-07-15', 'Promoción Back-to-School', 101, PARSE_JSON('{
    "descuento_porcentaje": 15,
    "productos_aplicables": [1001, 1002, 1003, 1006, 1017],
    "horario": {"inicio": "09:00", "fin": "21:00"},
    "canal": "tienda_fisica",
    "responsable": "María González",
    "objetivo_ventas": 50000,
    "presupuesto_marketing": 5000
}')),

('2024-07-20', 'Venta Especial Online', 0, PARSE_JSON('{
    "descuento_porcentaje": 20,
    "productos_aplicables": [1004, 1005, 1006, 1007, 1008],
    "vigencia": {"desde": "2024-07-20", "hasta": "2024-07-22"},
    "canal": "ecommerce",
    "codigo_promocional": "BACKTOSCHOOL20",
    "objetivo_ventas": 75000,
    "presupuesto_marketing": 8000
}')),

('2024-07-25', 'Descuento Corporativo', 102, PARSE_JSON('{
    "descuento_porcentaje": 25,
    "productos_aplicables": [1001, 1002, 1003, 1004, 1005, 1006, 1017],
    "tipo_cliente": "corporativo",
    "minimo_compra": 10000,
    "canal": "b2b_portal",
    "responsable": "Carlos Rodríguez",
    "objetivo_ventas": 100000,
    "vigencia_dias": 10
}')),

('2024-07-28', 'Festival de Arte Escolar', 103, PARSE_JSON('{
    "descuento_porcentaje": 10,
    "productos_aplicables": [1008, 1019, 1020],
    "evento_especial": true,
    "actividades": ["taller_pintura", "concurso_dibujo", "expo_arte"],
    "canal": "tienda_fisica",
    "horario": {"inicio": "10:00", "fin": "18:00"},
    "responsable": "Ana Martínez",
    "objetivo_ventas": 25000
}'));

-- ============================================================================
-- PASO 9: CREAR VISTAS Y TABLAS ANALÍTICAS
-- ============================================================================

-- Vista de transacciones e-commerce estructuradas
CREATE OR REPLACE VIEW ANALYTICS.TRANSACCIONES_ECOMMERCE AS
SELECT 
    CONTENIDO_JSON:transaction_id::STRING AS TRANSACTION_ID,
    CONTENIDO_JSON:timestamp::TIMESTAMP_NTZ AS FECHA_TRANSACCION,
    CONTENIDO_JSON:customer.id::INTEGER AS CLIENTE_ID,
    CONTENIDO_JSON:customer.type::STRING AS TIPO_CLIENTE,
    CONTENIDO_JSON:customer.location::STRING AS UBICACION_CLIENTE,
    CONTENIDO_JSON:customer.segment::STRING AS SEGMENTO_CLIENTE,
    CONTENIDO_JSON:payment.method::STRING AS METODO_PAGO,
    CONTENIDO_JSON:payment.total::DECIMAL(10,2) AS TOTAL_PAGO,
    CONTENIDO_JSON:shipping.type::STRING AS TIPO_ENVIO,
    CONTENIDO_JSON:shipping.cost::DECIMAL(10,2) AS COSTO_ENVIO,
    CONTENIDO_JSON:analytics.source::STRING AS FUENTE_TRAFICO,
    CONTENIDO_JSON:analytics.campaign::STRING AS CAMPAÑA,
    CONTENIDO_JSON:analytics.utm_medium::STRING AS MEDIO_UTM,
    FECHA_CARGA
FROM RAW_DATA.TRANSACCIONES_JSON;

-- Vista de items de transacción detallados
CREATE OR REPLACE VIEW ANALYTICS.ITEMS_TRANSACCION AS
SELECT 
    t.CONTENIDO_JSON:transaction_id::STRING AS TRANSACTION_ID,
    t.CONTENIDO_JSON:timestamp::TIMESTAMP_NTZ AS FECHA_TRANSACCION,
    VALUE:product_id::INTEGER AS PRODUCTO_ID,
    VALUE:name::STRING AS NOMBRE_PRODUCTO,
    VALUE:quantity::INTEGER AS CANTIDAD,
    VALUE:unit_price::DECIMAL(10,2) AS PRECIO_UNITARIO,
    VALUE:category::STRING AS CATEGORIA,
    (VALUE:quantity::INTEGER * VALUE:unit_price::DECIMAL(10,2)) AS SUBTOTAL
FROM RAW_DATA.TRANSACCIONES_JSON t,
LATERAL FLATTEN(input => t.CONTENIDO_JSON:items) f;

-- Tabla agregada de ventas diarias (optimización de consultas)
CREATE OR REPLACE TABLE ANALYTICS.VENTAS_DIARIAS AS
SELECT 
    FECHA_VENTA,
    PRODUCTO_ID,
    SUCURSAL_ID,
    COUNT(*) AS TRANSACCIONES,
    SUM(CANTIDAD) AS CANTIDAD_TOTAL,
    SUM(CANTIDAD * PRECIO_VENTA) AS INGRESOS_TOTALES,
    AVG(PRECIO_VENTA) AS PRECIO_PROMEDIO,
    MIN(PRECIO_VENTA) AS PRECIO_MINIMO,
    MAX(PRECIO_VENTA) AS PRECIO_MAXIMO
FROM RAW_DATA.VENTAS
GROUP BY FECHA_VENTA, PRODUCTO_ID, SUCURSAL_ID;

-- ============================================================================
-- PASO 10: CONFIGURAR CONTROL DE COSTOS
-- ============================================================================

-- Resource Monitor para control de gastos
CREATE OR REPLACE RESOURCE MONITOR OFFICEMAX_MONTHLY_BUDGET WITH
    CREDIT_QUOTA = 100
    FREQUENCY = MONTHLY
    START_TIMESTAMP = DATE_TRUNC('MONTH', CURRENT_DATE())
    TRIGGERS 
        ON 80 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND
        ON 110 PERCENT DO SUSPEND_IMMEDIATE;

-- Asignar monitor a warehouses
ALTER WAREHOUSE OFFICEMAX_WH SET RESOURCE_MONITOR = OFFICEMAX_MONTHLY_BUDGET;
ALTER WAREHOUSE OFFICEMAX_REPORTING_WH SET RESOURCE_MONITOR = OFFICEMAX_MONTHLY_BUDGET;

-- Tabla para tracking de costos por área
CREATE OR REPLACE TABLE ANALYTICS.QUERY_COST_TRACKING (
    QUERY_ID VARCHAR(200),
    AREA_NEGOCIO VARCHAR(100),
    PROYECTO VARCHAR(100),
    COSTO_ESTIMADO DECIMAL(10,4),
    FECHA_REGISTRO TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- PASO 11: CONFIGURAR CLUSTERING PARA PERFORMANCE
-- ============================================================================

-- Configurar clustering keys para optimizar consultas frecuentes
ALTER TABLE RAW_DATA.VENTAS CLUSTER BY (FECHA_VENTA, PRODUCTO_ID);
ALTER TABLE RAW_DATA.INVENTARIO_BACK_TO_SCHOOL CLUSTER BY (PRODUCTO_ID, SUCURSAL_ID);
ALTER TABLE ANALYTICS.VENTAS_DIARIAS CLUSTER BY (FECHA_VENTA);

-- ============================================================================
-- PASO 12: CREAR USUARIOS Y ROLES PARA APLICACIONES
-- ============================================================================

-- Crear rol específico para aplicaciones
CREATE OR REPLACE ROLE OFFICEMAX_APP_ROLE;

-- Otorgar permisos básicos
GRANT USAGE ON WAREHOUSE OFFICEMAX_REPORTING_WH TO ROLE OFFICEMAX_APP_ROLE;
GRANT USAGE ON DATABASE OFFICEMAX_ANALYTICS TO ROLE OFFICEMAX_APP_ROLE;
GRANT USAGE ON SCHEMA RAW_DATA TO ROLE OFFICEMAX_APP_ROLE;
GRANT USAGE ON SCHEMA ANALYTICS TO ROLE OFFICEMAX_APP_ROLE;
GRANT USAGE ON SCHEMA ML_MODELS TO ROLE OFFICEMAX_APP_ROLE;

-- Otorgar permisos de lectura
GRANT SELECT ON ALL TABLES IN SCHEMA RAW_DATA TO ROLE OFFICEMAX_APP_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA ANALYTICS TO ROLE OFFICEMAX_APP_ROLE;

-- Otorgar permisos futuros
GRANT SELECT ON FUTURE TABLES IN SCHEMA RAW_DATA TO ROLE OFFICEMAX_APP_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA ANALYTICS TO ROLE OFFICEMAX_APP_ROLE;

-- ============================================================================
-- PASO 13: CREAR FUNCIONES Y PROCEDIMIENTOS ÚTILES
-- ============================================================================

-- Función para calcular métricas de temporada
CREATE OR REPLACE FUNCTION ANALYTICS.CALCULAR_METRICAS_TEMPORADA(
    FECHA_INICIO DATE,
    FECHA_FIN DATE,
    TEMPORADA_PARAM STRING
)
RETURNS TABLE (
    CATEGORIA STRING,
    TOTAL_VENTAS NUMBER,
    INGRESOS_TOTALES NUMBER,
    PROMEDIO_PRECIO FLOAT
)
LANGUAGE SQL
AS
$$
    SELECT 
        p.CATEGORIA,
        SUM(v.CANTIDAD) as TOTAL_VENTAS,
        SUM(v.CANTIDAD * v.PRECIO_VENTA) as INGRESOS_TOTALES,
        AVG(v.PRECIO_VENTA) as PROMEDIO_PRECIO
    FROM RAW_DATA.VENTAS v
    JOIN RAW_DATA.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
    WHERE v.FECHA_VENTA BETWEEN FECHA_INICIO AND FECHA_FIN
        AND p.TEMPORADA = TEMPORADA_PARAM
    GROUP BY p.CATEGORIA
    ORDER BY INGRESOS_TOTALES DESC
$$;

-- Procedimiento para actualizar inventario
CREATE OR REPLACE PROCEDURE ANALYTICS.ACTUALIZAR_INVENTARIO(
    PRODUCTO_ID_PARAM INTEGER,
    SUCURSAL_ID_PARAM INTEGER,
    NUEVA_CANTIDAD INTEGER
)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    UPDATE RAW_DATA.INVENTARIO_BACK_TO_SCHOOL 
    SET STOCK_ACTUAL = NUEVA_CANTIDAD,
        ULTIMA_ACTUALIZACION = CURRENT_TIMESTAMP()
    WHERE PRODUCTO_ID = PRODUCTO_ID_PARAM 
        AND SUCURSAL_ID = SUCURSAL_ID_PARAM;
    
    RETURN 'Inventario actualizado correctamente';
END;
$$;

-- ============================================================================
-- PASO 14: VERIFICACIÓN FINAL Y ESTADÍSTICAS
-- ============================================================================

-- Verificar datos insertados
SELECT 
    'PRODUCTOS' as TABLA,
    COUNT(*) as REGISTROS,
    COUNT(DISTINCT CATEGORIA) as CATEGORIAS_UNICAS
FROM RAW_DATA.PRODUCTOS

UNION ALL

SELECT 
    'VENTAS' as TABLA,
    COUNT(*) as REGISTROS,
    COUNT(DISTINCT FECHA_VENTA) as DIAS_CON_VENTAS
FROM RAW_DATA.VENTAS

UNION ALL

SELECT 
    'CLIENTES' as TABLA,
    COUNT(*) as REGISTROS,
    COUNT(DISTINCT TIPO_CLIENTE) as TIPOS_CLIENTE
FROM RAW_DATA.CLIENTES

UNION ALL

SELECT 
    'INVENTARIO' as TABLA,
    COUNT(*) as REGISTROS,
    COUNT(DISTINCT SUCURSAL_ID) as SUCURSALES
FROM RAW_DATA.INVENTARIO_BACK_TO_SCHOOL

UNION ALL

SELECT 
    'TRANSACCIONES_JSON' as TABLA,
    COUNT(*) as REGISTROS,
    COUNT(DISTINCT ARCHIVO_ORIGEN) as ARCHIVOS_ORIGEN
FROM RAW_DATA.TRANSACCIONES_JSON;

-- Estadísticas de ventas por categoría
SELECT 
    p.CATEGORIA,
    COUNT(v.VENTA_ID) as TOTAL_TRANSACCIONES,
    SUM(v.CANTIDAD) as UNIDADES_VENDIDAS,
    SUM(v.CANTIDAD * v.PRECIO_VENTA) as INGRESOS_TOTALES,
    AVG(v.PRECIO_VENTA) as PRECIO_PROMEDIO
FROM RAW_DATA.VENTAS v
JOIN RAW_DATA.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
GROUP BY p.CATEGORIA
ORDER BY INGRESOS_TOTALES DESC;

-- ============================================================================
-- CONFIGURACIÓN COMPLETADA
-- ============================================================================

-- Configurar esquema por defecto para el quickstart
USE SCHEMA ANALYTICS;

-- Mensaje de confirmación
SELECT 
    '🎉 ¡CONFIGURACIÓN COMPLETADA!' as MENSAJE,
    'Base de datos OFFICEMAX_ANALYTICS lista para el quickstart' as DETALLE,
    'Tiempo estimado de setup: ' || DATEDIFF('minute', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()) || ' minutos' as DURACION;

-- ============================================================================
-- NOTAS IMPORTANTES PARA EL QUICKSTART
-- ============================================================================

/*
✅ COMPLETADO:
- Base de datos OFFICEMAX_ANALYTICS creada
- Esquemas RAW_DATA, ANALYTICS y ML_MODELS configurados
- Warehouses OFFICEMAX_WH y OFFICEMAX_REPORTING_WH creados
- 19 productos Back-to-School insertados
- 12 clientes de diferentes tipos insertados
- Inventario por sucursal configurado (3 sucursales)
- Más de 200 ventas históricas generadas
- Datos JSON de e-commerce insertados
- Eventos de marketing configurados
- Vistas analíticas creadas
- Control de costos configurado
- Clustering keys aplicados
- Roles y permisos establecidos
- Funciones y procedimientos creados

🚀 PRÓXIMOS PASOS:
1. Ejecutar el quickstart siguiendo la guía markdown
2. Experimentar con Time Travel, Undrop, Zero Copy Cloning
3. Procesar datos JSON y crear modelos de ML
4. Desarrollar dashboards y aplicaciones
5. Optimizar costos y performance

📊 DATOS DISPONIBLES:
- Productos: Mochilas, Papelería, Tecnología, Arte, Organización, Instrumentos
- Temporada: Back-to-School 2024
- Período: Últimos 45 días de ventas
- Sucursales: 101 (CDMX), 102 (MTY), 103 (GDL)
- Tipos de cliente: Individual, Educativo, Corporativo

⚠️ IMPORTANTE:
- Todos los datos son simulados para fines educativos
- Adaptar consultas según necesidades reales
- Monitorear costos durante el desarrollo
- Usar warehouse X-SMALL para pruebas iniciales
*/
