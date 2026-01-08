-- ============================================================================
-- OFFICEMAX MÉXICO - SNOWFLAKE CORTEX PLATFORM SETUP
-- Base de datos sintética para Cortex Analyst y Cortex Search
-- Duración estimada: 10-15 minutos
-- ============================================================================

-- Configuración inicial
USE ROLE SYSADMIN;

-- ============================================================================
-- PASO 1: CREAR INFRAESTRUCTURA PRINCIPAL
-- ============================================================================

-- Crear base de datos principal para OfficeMax México
CREATE OR REPLACE DATABASE OFFICEMAX_MEXICO;
USE DATABASE OFFICEMAX_MEXICO;

-- Crear esquemas organizacionales
CREATE OR REPLACE SCHEMA RAW_DATA COMMENT = 'Datos en bruto de productos, ventas, clientes e inventario';
CREATE OR REPLACE SCHEMA ANALYTICS COMMENT = 'Vistas y tablas procesadas para análisis de negocio';
CREATE OR REPLACE SCHEMA ML_MODELS COMMENT = 'Modelos de Machine Learning y predicciones';
CREATE OR REPLACE SCHEMA CORTEX_SERVICES COMMENT = 'Servicios y configuraciones de Cortex';

-- Crear warehouses optimizados
CREATE OR REPLACE WAREHOUSE OFFICEMAX_WH WITH
    WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse principal para analytics de OfficeMax México';

CREATE OR REPLACE WAREHOUSE OFFICEMAX_CORTEX_WH WITH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 120
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse optimizado para servicios de Cortex';

USE WAREHOUSE OFFICEMAX_WH;

-- ============================================================================
-- PASO 2: CREAR TABLAS DE DATOS MAESTROS
-- ============================================================================

-- Tabla de categorías de productos (jerarquía de OfficeMax)
CREATE OR REPLACE TABLE RAW_DATA.CATEGORIAS (
    CATEGORIA_ID INTEGER PRIMARY KEY,
    CATEGORIA_PADRE VARCHAR(100),
    CATEGORIA_HIJO VARCHAR(100) NOT NULL,
    NIVEL INTEGER NOT NULL CHECK (NIVEL BETWEEN 1 AND 3),
    ACTIVO BOOLEAN DEFAULT TRUE,
    DESCRIPCION TEXT,
    METADATA JSON,
    FECHA_CREACION TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Tabla de productos completa de OfficeMax México
CREATE OR REPLACE TABLE RAW_DATA.PRODUCTOS (
    PRODUCTO_ID VARCHAR(20) PRIMARY KEY,
    SKU VARCHAR(50) UNIQUE NOT NULL,
    NOMBRE_PRODUCTO VARCHAR(300) NOT NULL,
    CATEGORIA_ID INTEGER NOT NULL,
    MARCA VARCHAR(100),
    PRECIO_REGULAR DECIMAL(10,2) NOT NULL CHECK (PRECIO_REGULAR > 0),
    PRECIO_PROMOCIONAL DECIMAL(10,2),
    COSTO_UNITARIO DECIMAL(10,2) NOT NULL CHECK (COSTO_UNITARIO > 0),
    DESCRIPCION_CORTA VARCHAR(500),
    DESCRIPCION_DETALLADA TEXT,
    ESPECIFICACIONES JSON,
    TAGS VARCHAR(500),
    TEMPORADA VARCHAR(50) DEFAULT 'Todo el año',
    ES_DIGITAL BOOLEAN DEFAULT FALSE,
    REQUIERE_INSTALACION BOOLEAN DEFAULT FALSE,
    ACTIVO BOOLEAN DEFAULT TRUE,
    FECHA_LANZAMIENTO DATE,
    FECHA_DESCONTINUACION DATE,
    PESO_KG DECIMAL(8,3),
    DIMENSIONES_CM VARCHAR(50),
    CODIGO_BARRAS VARCHAR(20),
    PROVEEDOR_PRINCIPAL VARCHAR(100),
    STOCK_MINIMO INTEGER DEFAULT 10,
    STOCK_MAXIMO INTEGER DEFAULT 1000,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (CATEGORIA_ID) REFERENCES RAW_DATA.CATEGORIAS(CATEGORIA_ID)
);

-- Tabla de clientes (B2B, B2C, Educativo)
CREATE OR REPLACE TABLE RAW_DATA.CLIENTES (
    CLIENTE_ID VARCHAR(20) PRIMARY KEY,
    TIPO_CLIENTE VARCHAR(20) NOT NULL CHECK (TIPO_CLIENTE IN ('INDIVIDUAL', 'EMPRESARIAL', 'EDUCATIVO', 'GOBIERNO')),
    NOMBRE_COMPLETO VARCHAR(200) NOT NULL,
    RAZON_SOCIAL VARCHAR(200),
    RFC VARCHAR(15),
    EMAIL VARCHAR(250) UNIQUE,
    TELEFONO VARCHAR(20),
    TELEFONO_ALTERNATIVO VARCHAR(20),
    FECHA_REGISTRO DATE NOT NULL,
    FECHA_NACIMIENTO DATE,
    GENERO VARCHAR(10) CHECK (GENERO IN ('M', 'F', 'OTRO', NULL)),
    SEGMENTO VARCHAR(50) DEFAULT 'REGULAR', -- REGULAR, VIP, CORPORATIVO, PREMIUM
    NIVEL_CREDITICIO VARCHAR(20) DEFAULT 'ESTANDAR',
    LIMITE_CREDITO DECIMAL(12,2) DEFAULT 0,
    DESCUENTO_CORPORATIVO DECIMAL(5,2) DEFAULT 0,
    
    -- Dirección principal
    CALLE VARCHAR(200),
    NUMERO_EXTERIOR VARCHAR(20),
    NUMERO_INTERIOR VARCHAR(20),
    COLONIA VARCHAR(100),
    MUNICIPIO VARCHAR(100),
    ESTADO VARCHAR(50),
    CODIGO_POSTAL VARCHAR(10),
    PAIS VARCHAR(50) DEFAULT 'México',
    
    -- Preferencias y comportamiento
    CANAL_PREFERIDO VARCHAR(30) DEFAULT 'TIENDA', -- TIENDA, ONLINE, TELEFONO, APP
    METODO_PAGO_PREFERIDO VARCHAR(30) DEFAULT 'EFECTIVO',
    FRECUENCIA_COMPRA VARCHAR(20) DEFAULT 'MENSUAL',
    PROMEDIO_COMPRA DECIMAL(10,2) DEFAULT 0,
    TOTAL_COMPRAS_HISTORICAS DECIMAL(12,2) DEFAULT 0,
    
    -- Control
    ACTIVO BOOLEAN DEFAULT TRUE,
    MARKETING_PERMITIDO BOOLEAN DEFAULT TRUE,
    NOTAS TEXT,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Tabla de sucursales y puntos de venta
CREATE OR REPLACE TABLE RAW_DATA.SUCURSALES (
    SUCURSAL_ID INTEGER PRIMARY KEY,
    CODIGO_SUCURSAL VARCHAR(20) UNIQUE NOT NULL,
    NOMBRE_SUCURSAL VARCHAR(100) NOT NULL,
    TIPO_PUNTO_VENTA VARCHAR(30) NOT NULL, -- TIENDA, OUTLET, KIOSCO, POP_UP
    FORMATO_TIENDA VARCHAR(50), -- MEGATIENDA, TIENDA_EXPRESS, TRADICIONAL
    
    -- Ubicación
    DIRECCION_COMPLETA VARCHAR(500),
    COLONIA VARCHAR(100),
    MUNICIPIO VARCHAR(100),
    ESTADO VARCHAR(50) NOT NULL,
    CODIGO_POSTAL VARCHAR(10),
    LATITUD DECIMAL(10,8),
    LONGITUD DECIMAL(11,8),
    
    -- Detalles operativos
    METROS_CUADRADOS INTEGER,
    NUMERO_EMPLEADOS INTEGER,
    GERENTE_NOMBRE VARCHAR(100),
    TELEFONO VARCHAR(20),
    EMAIL VARCHAR(100),
    HORARIO_JSON JSON,
    
    -- Fechas importantes
    FECHA_APERTURA DATE NOT NULL,
    FECHA_REMODELACION DATE,
    
    -- Estado
    ACTIVO BOOLEAN DEFAULT TRUE,
    PERMITE_ECOMMERCE BOOLEAN DEFAULT TRUE,
    PERMITE_CLICK_COLLECT BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Tabla de inventario por sucursal
CREATE OR REPLACE TABLE RAW_DATA.INVENTARIO (
    INVENTARIO_ID INTEGER AUTOINCREMENT PRIMARY KEY,
    PRODUCTO_ID VARCHAR(20) NOT NULL,
    SUCURSAL_ID INTEGER NOT NULL,
    STOCK_ACTUAL INTEGER NOT NULL CHECK (STOCK_ACTUAL >= 0),
    STOCK_DISPONIBLE INTEGER NOT NULL CHECK (STOCK_DISPONIBLE >= 0),
    STOCK_RESERVADO INTEGER DEFAULT 0 CHECK (STOCK_RESERVADO >= 0),
    STOCK_EN_TRANSITO INTEGER DEFAULT 0 CHECK (STOCK_EN_TRANSITO >= 0),
    UBICACION_ALMACEN VARCHAR(50),
    ULTIMO_CONTEO DATE,
    AJUSTE_INVENTARIO INTEGER DEFAULT 0,
    COSTO_PROMEDIO DECIMAL(10,2),
    FECHA_ULTIMA_ENTRADA TIMESTAMP_NTZ,
    FECHA_ULTIMA_SALIDA TIMESTAMP_NTZ,
    ROTACION_DIAS DECIMAL(6,2),
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (PRODUCTO_ID) REFERENCES RAW_DATA.PRODUCTOS(PRODUCTO_ID),
    FOREIGN KEY (SUCURSAL_ID) REFERENCES RAW_DATA.SUCURSALES(SUCURSAL_ID),
    UNIQUE (PRODUCTO_ID, SUCURSAL_ID)
);

-- Tabla de ventas (transacciones)
CREATE OR REPLACE TABLE RAW_DATA.VENTAS (
    VENTA_ID VARCHAR(30) PRIMARY KEY,
    TICKET_ID VARCHAR(30) NOT NULL,
    FECHA_VENTA TIMESTAMP_NTZ NOT NULL,
    FECHA_SOLO DATE GENERATED ALWAYS AS (DATE(FECHA_VENTA)) STORED,
    MES_ANO VARCHAR(7) GENERATED ALWAYS AS (TO_VARCHAR(FECHA_VENTA, 'YYYY-MM')) STORED,
    
    -- Cliente
    CLIENTE_ID VARCHAR(20),
    TIPO_CLIENTE VARCHAR(20) NOT NULL,
    
    -- Producto
    PRODUCTO_ID VARCHAR(20) NOT NULL,
    CANTIDAD INTEGER NOT NULL CHECK (CANTIDAD > 0),
    PRECIO_UNITARIO DECIMAL(10,2) NOT NULL CHECK (PRECIO_UNITARIO > 0),
    DESCUENTO_UNITARIO DECIMAL(10,2) DEFAULT 0 CHECK (DESCUENTO_UNITARIO >= 0),
    SUBTOTAL DECIMAL(12,2) GENERATED ALWAYS AS (CANTIDAD * PRECIO_UNITARIO) STORED,
    DESCUENTO_TOTAL DECIMAL(12,2) GENERATED ALWAYS AS (CANTIDAD * DESCUENTO_UNITARIO) STORED,
    TOTAL_LINEA DECIMAL(12,2) GENERATED ALWAYS AS (SUBTOTAL - DESCUENTO_TOTAL) STORED,
    
    -- Ubicación y canal
    SUCURSAL_ID INTEGER NOT NULL,
    CANAL_VENTA VARCHAR(30) NOT NULL, -- TIENDA, ONLINE, TELEFONO, APP_MOVIL
    
    -- Promociones y descuentos
    CODIGO_PROMOCION VARCHAR(50),
    TIPO_DESCUENTO VARCHAR(50),
    PORCENTAJE_DESCUENTO DECIMAL(5,2) DEFAULT 0,
    
    -- Información adicional
    VENDEDOR_ID VARCHAR(20),
    METODO_PAGO VARCHAR(30) NOT NULL,
    CATEGORIA_TRANSACCION VARCHAR(30) DEFAULT 'VENTA', -- VENTA, DEVOLUCION, AJUSTE
    NUMERO_CUOTAS INTEGER DEFAULT 1,
    
    -- Costos y margen
    COSTO_TOTAL DECIMAL(12,2),
    MARGEN_BRUTO DECIMAL(12,2),
    PORCENTAJE_MARGEN DECIMAL(5,2),
    
    -- Auditoría
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    FOREIGN KEY (CLIENTE_ID) REFERENCES RAW_DATA.CLIENTES(CLIENTE_ID),
    FOREIGN KEY (PRODUCTO_ID) REFERENCES RAW_DATA.PRODUCTOS(PRODUCTO_ID),
    FOREIGN KEY (SUCURSAL_ID) REFERENCES RAW_DATA.SUCURSALES(SUCURSAL_ID)
);

-- Tabla de eventos de marketing y promociones
CREATE OR REPLACE TABLE RAW_DATA.EVENTOS_MARKETING (
    EVENTO_ID INTEGER AUTOINCREMENT PRIMARY KEY,
    NOMBRE_EVENTO VARCHAR(200) NOT NULL,
    TIPO_EVENTO VARCHAR(50) NOT NULL, -- DESCUENTO, PROMOCION, TEMPORADA, LIQUIDACION
    DESCRIPCION TEXT,
    
    -- Vigencia
    FECHA_INICIO DATE NOT NULL,
    FECHA_FIN DATE NOT NULL,
    ACTIVO BOOLEAN DEFAULT TRUE,
    
    -- Configuración del descuento
    PORCENTAJE_DESCUENTO DECIMAL(5,2) DEFAULT 0,
    MONTO_DESCUENTO_FIJO DECIMAL(10,2) DEFAULT 0,
    COMPRA_MINIMA DECIMAL(10,2) DEFAULT 0,
    LIMITE_USES_TOTAL INTEGER,
    LIMITE_USES_CLIENTE INTEGER DEFAULT 1,
    
    -- Alcance
    SUCURSALES_APLICABLES JSON, -- Lista de sucursal_ids
    CANALES_APLICABLES JSON, -- Lista de canales
    PRODUCTOS_APLICABLES JSON, -- Lista de producto_ids o categorías
    CLIENTES_OBJETIVO JSON, -- Criterios de segmentación
    
    -- Resultados
    PRESUPUESTO_ASIGNADO DECIMAL(12,2),
    COSTO_REAL DECIMAL(12,2) DEFAULT 0,
    VENTAS_GENERADAS DECIMAL(12,2) DEFAULT 0,
    NUMERO_TRANSACCIONES INTEGER DEFAULT 0,
    
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Tabla para documentos (Cortex Search)
CREATE OR REPLACE TABLE RAW_DATA.DOCUMENTOS (
    DOCUMENTO_ID VARCHAR(50) PRIMARY KEY,
    TITULO VARCHAR(500) NOT NULL,
    TIPO_DOCUMENTO VARCHAR(50) NOT NULL, -- MANUAL_PRODUCTO, POLITICA, TUTORIAL, FAQ, PROMOCION
    CATEGORIA VARCHAR(50) NOT NULL, -- PRODUCTOS, SERVICIOS, NORMATIVAS, MARKETING, CAPACITACION
    CONTENIDO TEXT NOT NULL,
    RESUMEN VARCHAR(1000),
    AUTOR VARCHAR(100),
    DEPARTAMENTO VARCHAR(50),
    VERSION VARCHAR(20) DEFAULT '1.0',
    IDIOMA VARCHAR(10) DEFAULT 'es-MX',
    TAGS JSON,
    METADATA JSON,
    ARCHIVO_ORIGINAL VARCHAR(500),
    URL_DOCUMENTO VARCHAR(500),
    FECHA_CREACION TIMESTAMP_NTZ NOT NULL,
    FECHA_ACTUALIZACION TIMESTAMP_NTZ,
    FECHA_EXPIRACION DATE,
    ACTIVO BOOLEAN DEFAULT TRUE,
    PUBLICO BOOLEAN DEFAULT FALSE,
    INDICE_BUSQUEDA BOOLEAN DEFAULT TRUE,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- PASO 3: INSERTAR DATOS MAESTROS - CATEGORÍAS
-- ============================================================================

INSERT INTO RAW_DATA.CATEGORIAS (CATEGORIA_ID, CATEGORIA_PADRE, CATEGORIA_HIJO, NIVEL, DESCRIPCION) VALUES
-- Nivel 1 - Categorías principales
(1, NULL, 'Tecnología', 1, 'Productos tecnológicos: computadoras, tablets, accesorios'),
(2, NULL, 'Papelería', 1, 'Productos de papelería y escritura'),
(3, NULL, 'Mobiliario de Oficina', 1, 'Muebles y mobiliario para oficina'),
(4, NULL, 'Impresión y Copiado', 1, 'Servicios y suministros de impresión'),
(5, NULL, 'Material Escolar', 1, 'Productos específicos para el sector educativo'),
(6, NULL, 'Organización', 1, 'Productos para organización y almacenamiento'),
(7, NULL, 'Comunicaciones', 1, 'Teléfonos, radios y equipos de comunicación'),
(8, NULL, 'Seguridad', 1, 'Productos de seguridad para oficina'),

-- Nivel 2 - Subcategorías Tecnología
(11, 'Tecnología', 'Computadoras', 2, 'Laptops, desktops, all-in-one'),
(12, 'Tecnología', 'Tablets y Accesorios', 2, 'Tablets, covers, stylus'),
(13, 'Tecnología', 'Periféricos', 2, 'Mouse, teclados, webcams, audífonos'),
(14, 'Tecnología', 'Almacenamiento', 2, 'USB, discos duros, memorias'),
(15, 'Tecnología', 'Redes y Conectividad', 2, 'Routers, cables, adaptadores'),

-- Nivel 2 - Subcategorías Papelería
(21, 'Papelería', 'Instrumentos de Escritura', 2, 'Plumas, lápices, marcadores'),
(22, 'Papelería', 'Papel y Cuadernos', 2, 'Hojas, cuadernos, blocks'),
(23, 'Papelería', 'Adhesivos y Correctores', 2, 'Pegamentos, cintas, correctores'),
(24, 'Papelería', 'Instrumentos de Medición', 2, 'Reglas, compases, escuadras'),

-- Nivel 2 - Subcategorías Mobiliario
(31, 'Mobiliario de Oficina', 'Sillas', 2, 'Sillas ejecutivas, operativas, de visita'),
(32, 'Mobiliario de Oficina', 'Escritorios', 2, 'Escritorios ejecutivos, modulares, standing'),
(33, 'Mobiliario de Oficina', 'Archiveros', 2, 'Archiveros verticales, laterales, móviles'),
(34, 'Mobiliario de Oficina', 'Mesas', 2, 'Mesas de juntas, auxiliares, de trabajo'),

-- Nivel 2 - Subcategorías Material Escolar
(51, 'Material Escolar', 'Mochilas', 2, 'Mochilas escolares, deportivas, con ruedas'),
(52, 'Material Escolar', 'Útiles Escolares', 2, 'Kits escolares, loncheras, estuches'),
(53, 'Material Escolar', 'Arte y Manualidades', 2, 'Colores, plastilina, materiales creativos');

-- ============================================================================
-- PASO 4: INSERTAR SUCURSALES
-- ============================================================================

INSERT INTO RAW_DATA.SUCURSALES (SUCURSAL_ID, CODIGO_SUCURSAL, NOMBRE_SUCURSAL, TIPO_PUNTO_VENTA, FORMATO_TIENDA, DIRECCION_COMPLETA, COLONIA, MUNICIPIO, ESTADO, CODIGO_POSTAL, METROS_CUADRADOS, NUMERO_EMPLEADOS, TELEFONO, FECHA_APERTURA, ACTIVO, HORARIO_JSON) VALUES
(101, 'OM-CDMX-001', 'OfficeMax Santa Fe', 'TIENDA', 'MEGATIENDA', 'Av. Santa Fe 482, Centro Comercial Santa Fe', 'Santa Fe', 'Cuajimalpa', 'CDMX', '05348', 2500, 35, '55-5292-1234', '2018-03-15', TRUE, '{"lun_vie": "09:00-21:00", "sabado": "09:00-20:00", "domingo": "10:00-19:00"}'),
(102, 'OM-CDMX-002', 'OfficeMax Polanco', 'TIENDA', 'TRADICIONAL', 'Av. Presidente Masaryk 111, Polanco', 'Polanco', 'Miguel Hidalgo', 'CDMX', '11560', 1800, 28, '55-5280-5678', '2019-06-20', TRUE, '{"lun_vie": "09:00-20:00", "sabado": "09:00-19:00", "domingo": "10:00-18:00"}'),
(103, 'OM-CDMX-003', 'OfficeMax Insurgentes Sur', 'TIENDA', 'TRADICIONAL', 'Av. Insurgentes Sur 1728, Del Valle', 'Del Valle', 'Benito Juárez', 'CDMX', '03100', 1600, 22, '55-5534-9012', '2017-11-10', TRUE, '{"lun_vie": "08:30-20:30", "sabado": "09:00-19:00", "domingo": "10:00-18:00"}'),

(201, 'OM-GDL-001', 'OfficeMax Guadalajara Centro', 'TIENDA', 'MEGATIENDA', 'Av. López Mateos Norte 2077, Jardines del Country', 'Jardines del Country', 'Zapopan', 'Jalisco', '45010', 2200, 32, '33-3647-2345', '2019-01-25', TRUE, '{"lun_vie": "09:00-21:00", "sabado": "09:00-20:00", "domingo": "10:00-19:00"}'),
(202, 'OM-GDL-002', 'OfficeMax Plaza del Sol', 'TIENDA', 'TRADICIONAL', 'Av. López Mateos Sur 2375, Plaza del Sol', 'Jardines del Country', 'Zapopan', 'Jalisco', '45050', 1500, 25, '33-3121-6789', '2020-08-15', TRUE, '{"lun_vie": "10:00-21:00", "sabado": "10:00-20:00", "domingo": "11:00-19:00"}'),

(301, 'OM-MTY-001', 'OfficeMax Monterrey San Pedro', 'TIENDA', 'MEGATIENDA', 'Av. José Vasconcelos 402 Ote, San Pedro Garza García', 'Del Valle', 'San Pedro Garza García', 'Nuevo León', '66220', 2800, 40, '81-8363-4567', '2018-09-12', TRUE, '{"lun_vie": "09:00-21:00", "sabado": "09:00-20:00", "domingo": "10:00-19:00"}'),
(302, 'OM-MTY-002', 'OfficeMax Monterrey Centro', 'TIENDA', 'TRADICIONAL', 'Av. Constitución 1075 Ote, Centro', 'Centro', 'Monterrey', 'Nuevo León', '64000', 1400, 20, '81-8340-7890', '2019-05-18', TRUE, '{"lun_vie": "08:30-20:00", "sabado": "09:00-19:00", "domingo": "10:00-18:00"}'),

(401, 'OM-PUE-001', 'OfficeMax Puebla Angelópolis', 'TIENDA', 'TRADICIONAL', 'Blvd. del Niño Poblano 2510, Reserva Territorial Atlixcáyotl', 'Concepción La Cruz', 'Puebla', 'Puebla', '72197', 1700, 26, '222-303-1234', '2020-02-10', TRUE, '{"lun_vie": "09:00-20:00", "sabado": "09:00-19:00", "domingo": "10:00-18:00"}'),

(501, 'OM-TIJ-001', 'OfficeMax Tijuana Río', 'TIENDA', 'TRADICIONAL', 'Paseo de los Héroes 2507, Zona Río', 'Zona Río', 'Tijuana', 'Baja California', '22010', 1600, 24, '664-634-5678', '2021-03-08', TRUE, '{"lun_vie": "09:00-20:00", "sabado": "09:00-19:00", "domingo": "10:00-18:00"}'),

-- Outlet y formatos especiales
(601, 'OM-CDMX-OUT1', 'OfficeMax Outlet Periférico', 'OUTLET', 'OUTLET', 'Periférico Sur 4690, Jardines del Pedregal', 'Jardines del Pedregal', 'Coyoacán', 'CDMX', '04500', 1200, 15, '55-5424-9999', '2021-11-01', TRUE, '{"lun_vie": "10:00-19:00", "sabado": "10:00-18:00", "domingo": "11:00-17:00"}'),
(602, 'OM-GDL-EXP1', 'OfficeMax Express Zapopan', 'TIENDA', 'TIENDA_EXPRESS', 'Av. Patria 1891, Puerta de Hierro', 'Puerta de Hierro', 'Zapopan', 'Jalisco', '45116', 800, 12, '33-3647-8888', '2022-01-15', TRUE, '{"lun_vie": "08:00-21:00", "sabado": "09:00-20:00", "domingo": "10:00-19:00"}');

-- ============================================================================
-- PASO 5: GENERAR PRODUCTOS SINTÉTICOS DE OFFICEMAX
-- ============================================================================

-- Productos de Tecnología
INSERT INTO RAW_DATA.PRODUCTOS VALUES
-- Computadoras
('OM-TECH-001', 'LAPTOP-HP-001', 'Laptop HP Pavilion 15.6" Intel Core i5', 11, 'HP', 18999.00, 16999.00, 14500.00, 'Laptop HP Pavilion con Intel Core i5, 8GB RAM, 256GB SSD', 'Laptop HP Pavilion 15.6" con procesador Intel Core i5-1135G7, 8GB RAM DDR4, 256GB SSD, Windows 11 Home, perfecta para trabajo y estudio.', '{"procesador": "Intel Core i5-1135G7", "ram": "8GB", "almacenamiento": "256GB SSD", "pantalla": "15.6 pulgadas", "so": "Windows 11"}', 'laptop, hp, intel, ssd, windows', 'Todo el año', FALSE, FALSE, TRUE, '2023-01-15', NULL, 2.1, '35.8 x 24.2 x 1.79 cm', '194850123456', 'HP Inc.', 5, 50, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('OM-TECH-002', 'LAPTOP-DELL-001', 'Laptop Dell Inspiron 15 3000 AMD Ryzen 5', 11, 'Dell', 16499.00, 14999.00, 12800.00, 'Laptop Dell Inspiron con AMD Ryzen 5, ideal para productividad', 'Laptop Dell Inspiron 15 3000 con procesador AMD Ryzen 5, 8GB RAM, 512GB SSD, pantalla de 15.6", Windows 11 Home, diseño moderno y eficiente.', '{"procesador": "AMD Ryzen 5", "ram": "8GB", "almacenamiento": "512GB SSD", "pantalla": "15.6 pulgadas", "so": "Windows 11"}', 'laptop, dell, amd, ryzen, ssd', 'Todo el año', FALSE, FALSE, TRUE, '2023-02-01', NULL, 1.9, '35.4 x 24.9 x 1.99 cm', '884116387654', 'Dell Technologies', 3, 40, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('OM-TECH-003', 'DESKTOP-HP-001', 'Desktop HP All-in-One 24" Intel Core i3', 11, 'HP', 14999.00, 13499.00, 11200.00, 'Computadora All-in-One HP con pantalla integrada de 24"', 'Desktop HP All-in-One 24" con Intel Core i3, 8GB RAM, 1TB HDD, pantalla touch, webcam HD, teclado y mouse inalámbricos incluidos.', '{"procesador": "Intel Core i3", "ram": "8GB", "almacenamiento": "1TB HDD", "pantalla": "24 pulgadas touch", "incluye": "teclado y mouse"}', 'desktop, hp, all-in-one, touch, webcam', 'Todo el año', FALSE, TRUE, TRUE, '2023-03-10', NULL, 5.8, '54 x 17.5 x 41.2 cm', '194850234567', 'HP Inc.', 2, 25, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Tablets y Accesorios
('OM-TECH-004', 'TABLET-IPAD-001', 'iPad Air 10.9" 64GB WiFi', 12, 'Apple', 14999.00, 13999.00, 11500.00, 'iPad Air con chip M1 y pantalla Liquid Retina', 'iPad Air de 10.9" con chip M1, 64GB de almacenamiento, WiFi, pantalla Liquid Retina, compatible con Apple Pencil y Magic Keyboard.', '{"chip": "Apple M1", "almacenamiento": "64GB", "pantalla": "10.9 pulgadas Liquid Retina", "conectividad": "WiFi", "compatible": "Apple Pencil"}', 'ipad, apple, tablet, m1, retina', 'Todo el año', FALSE, FALSE, TRUE, '2023-01-20', NULL, 0.461, '24.76 x 17.85 x 0.61 cm', '194252706789', 'Apple Inc.', 2, 30, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('OM-TECH-005', 'TABLET-SAMSUNG-001', 'Samsung Galaxy Tab A8 10.5" 64GB', 12, 'Samsung', 6999.00, 5999.00, 4800.00, 'Tablet Samsung Galaxy Tab A8 con pantalla de 10.5"', 'Samsung Galaxy Tab A8 de 10.5" con 4GB RAM, 64GB almacenamiento, Android 11, batería de larga duración, ideal para entretenimiento y trabajo.', '{"ram": "4GB", "almacenamiento": "64GB", "pantalla": "10.5 pulgadas", "so": "Android 11", "bateria": "7040 mAh"}', 'samsung, galaxy, tablet, android', 'Todo el año', FALSE, FALSE, TRUE, '2023-02-15', NULL, 0.508, '24.68 x 16.13 x 0.69 cm', '887276789012', 'Samsung Electronics', 5, 50, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Periféricos
('OM-TECH-006', 'MOUSE-LOGITECH-001', 'Mouse Logitech MX Master 3S Inalámbrico', 13, 'Logitech', 2199.00, 1899.00, 1400.00, 'Mouse inalámbrico Logitech MX Master 3S para productividad', 'Mouse Logitech MX Master 3S con sensor de 8000 DPI, scroll electromagnético, conectividad Bluetooth y USB-C, batería de 70 días.', '{"dpi": "8000", "conectividad": "Bluetooth + USB-C", "bateria": "70 días", "botones": "7", "scroll": "electromagnético"}', 'mouse, logitech, inalámbrico, bluetooth, productividad', 'Todo el año', FALSE, FALSE, TRUE, '2023-01-10', NULL, 0.141, '12.4 x 8.4 x 5.1 cm', '097855156789', 'Logitech', 10, 100, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('OM-TECH-007', 'TECLADO-LOGITECH-001', 'Teclado Logitech MX Keys Advanced', 13, 'Logitech', 2599.00, 2299.00, 1800.00, 'Teclado inalámbrico Logitech MX Keys para profesionales', 'Teclado Logitech MX Keys con teclas iluminadas, conectividad múltiple, batería recargable, diseño ergonómico para escritura cómoda.', '{"iluminacion": "adaptativa", "conectividad": "Bluetooth + USB", "teclas": "low-profile", "bateria": "recargable", "layout": "español"}', 'teclado, logitech, iluminado, bluetooth, ergonómico', 'Todo el año', FALSE, FALSE, TRUE, '2023-01-12', NULL, 0.810, '43.0 x 13.2 x 2.0 cm', '097855167890', 'Logitech', 8, 80, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- Productos de Papelería
INSERT INTO RAW_DATA.PRODUCTOS VALUES
-- Instrumentos de Escritura
('OM-PAP-001', 'PLUMA-BIC-001', 'Plumas BIC Cristal Azul Caja 50 pzs', 21, 'BIC', 299.00, 249.00, 180.00, 'Caja de 50 plumas BIC Cristal color azul', 'Plumas BIC Cristal, el clásico de escritura suave y confiable. Tinta azul, punta media, caja con 50 piezas. Perfectas para oficina y escuela.', '{"color": "azul", "punta": "media", "cantidad": "50 piezas", "tipo": "ballpoint", "marca": "BIC"}', 'pluma, bic, azul, oficina, escritura', 'Todo el año', FALSE, FALSE, TRUE, '2023-01-01', NULL, 0.750, '16 x 12 x 8 cm', '070330678901', 'BIC', 20, 500, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('OM-PAP-002', 'PLUMA-PILOT-001', 'Pluma Pilot G2 Gel Negra', 21, 'Pilot', 45.00, 39.00, 28.00, 'Pluma de gel Pilot G2 con tinta negra fluida', 'Pluma Pilot G2 con tinta de gel negra, punta retráctil, escritura suave y precisa. Ideal para documentos importantes y uso diario.', '{"color": "negro", "tipo": "gel", "punta": "retráctil", "grosor": "0.7mm", "grip": "antideslizante"}', 'pluma, pilot, gel, negro, retráctil', 'Todo el año', FALSE, FALSE, TRUE, '2023-01-05', NULL, 0.020, '14.5 x 1.2 cm', '072838234567', 'Pilot Corporation', 50, 1000, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('OM-PAP-003', 'LAPIZ-FABER-001', 'Lápices Faber-Castell HB Caja 12 pzs', 21, 'Faber-Castell', 89.00, 79.00, 55.00, 'Caja de 12 lápices Faber-Castell dureza HB', 'Lápices Faber-Castell de grafito HB, madera certificada, calidad premium. Caja con 12 lápices ideales para dibujo técnico y escritura.', '{"dureza": "HB", "cantidad": "12 piezas", "material": "madera certificada", "uso": "dibujo y escritura", "calidad": "premium"}', 'lápiz, faber-castell, hb, grafito, dibujo', 'Todo el año', FALSE, FALSE, TRUE, '2023-01-08', NULL, 0.120, '19 x 4 x 1.5 cm', '421569789012', 'Faber-Castell', 30, 800, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Papel y Cuadernos
('OM-PAP-004', 'PAPEL-HP-001', 'Papel HP Office 75g Carta 500 hojas', 22, 'HP', 189.00, 169.00, 125.00, 'Resma de papel HP Office tamaño carta 75g', 'Papel HP Office de 75g/m², tamaño carta, blancura 94%, ideal para impresión láser e inyección de tinta. Resma de 500 hojas.', '{"gramaje": "75g/m²", "tamaño": "carta", "cantidad": "500 hojas", "blancura": "94%", "compatible": "láser e inyección"}', 'papel, hp, carta, office, impresión', 'Todo el año', FALSE, FALSE, TRUE, '2023-01-01', NULL, 2.500, '28 x 21.5 x 5.5 cm', '889296345678', 'HP Inc.', 25, 300, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('OM-PAP-005', 'CUADERNO-SCRIBE-001', 'Cuaderno Profesional Scribe 100 hojas', 22, 'Scribe', 65.00, 55.00, 38.00, 'Cuaderno profesional Scribe de 100 hojas rayado', 'Cuaderno profesional Scribe con 100 hojas rayadas, pasta dura, espiral metálico, papel de 75g. Ideal para notas y apuntes profesionales.', '{"hojas": "100", "rayado": "sí", "pasta": "dura", "espiral": "metálico", "papel": "75g"}', 'cuaderno, scribe, profesional, rayado, espiral', 'Todo el año', FALSE, FALSE, TRUE, '2023-01-01', NULL, 0.350, '27 x 21 x 1.5 cm', '750049456789', 'Scribe', 40, 600, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Adhesivos y Correctores
('OM-PAP-006', 'PEGAMENTO-RESISTOL-001', 'Pegamento en Barra Resistol 40g', 23, 'Resistol', 28.00, 24.00, 16.00, 'Pegamento en barra Resistol lavable de 40g', 'Pegamento en barra Resistol de 40g, lavable, no tóxico, secado rápido. Ideal para papel, cartón y materiales porosos.', '{"peso": "40g", "lavable": "sí", "toxico": "no", "secado": "rápido", "materiales": "papel, cartón"}', 'pegamento, resistol, barra, lavable, no tóxico', 'Todo el año', FALSE, FALSE, TRUE, '2023-01-01', NULL, 0.040, '10 x 2.5 cm', '750367567890', 'Henkel', 60, 1200, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('OM-PAP-007', 'CORRECTOR-LIQUID-001', 'Corrector Líquido Paper Mate 20ml', 23, 'Paper Mate', 35.00, 29.00, 20.00, 'Corrector líquido Paper Mate con aplicador de precisión', 'Corrector líquido Paper Mate de 20ml, secado rápido, cobertura opaca, aplicador de precisión para correcciones exactas.', '{"volumen": "20ml", "secado": "rápido", "cobertura": "opaca", "aplicador": "precisión", "tipo": "líquido"}', 'corrector, liquid, paper mate, precisión', 'Todo el año', FALSE, FALSE, TRUE, '2023-01-03', NULL, 0.025, '12 x 2 cm', '071641678901', 'Newell Brands', 80, 1500, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- Productos de Material Escolar
INSERT INTO RAW_DATA.PRODUCTOS VALUES
-- Mochilas
('OM-ESC-001', 'MOCHILA-JANSPORT-001', 'Mochila JanSport SuperBreak Azul', 51, 'JanSport', 1299.00, 1099.00, 780.00, 'Mochila JanSport SuperBreak clásica color azul', 'Mochila JanSport SuperBreak de 25L, diseño clásico, correas acolchadas, compartimento principal amplio, bolsillo frontal, garantía de por vida.', '{"capacidad": "25L", "color": "azul", "correas": "acolchadas", "compartimentos": "2", "garantia": "de por vida"}', 'mochila, jansport, azul, escolar, garantía', 'Back-to-School', FALSE, FALSE, TRUE, '2023-01-10', NULL, 0.400, '42 x 33 x 21 cm', '192362789012', 'JanSport', 8, 120, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('OM-ESC-002', 'MOCHILA-KIPLING-001', 'Mochila Kipling Seoul Extra Grande', 51, 'Kipling', 2899.00, 2499.00, 1850.00, 'Mochila Kipling Seoul XL con múltiples compartimentos', 'Mochila Kipling Seoul Extra Grande con 6 compartimentos, material resistente al agua, cremalleras resistentes, mono Kipling incluido.', '{"tamaño": "XL", "compartimentos": "6", "resistente_agua": "sí", "incluye": "mono Kipling", "material": "nylon"}', 'mochila, kipling, xl, compartimentos, resistente', 'Back-to-School', FALSE, FALSE, TRUE, '2023-02-01', NULL, 0.650, '44 x 32 x 19 cm', '875696890123', 'Kipling', 5, 80, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Útiles Escolares
('OM-ESC-003', 'KIT-ESCOLAR-001', 'Kit Escolar Básico OfficeMax', 52, 'OfficeMax', 459.00, 399.00, 285.00, 'Kit escolar básico con útiles esenciales', 'Kit escolar OfficeMax incluye: 10 lápices, 5 plumas, goma, sacapuntas, regla, pegamento, colores y cuaderno. Todo lo necesario para el regreso a clases.', '{"incluye": "lápices, plumas, goma, sacapuntas, regla, pegamento, colores, cuaderno", "piezas": "múltiples", "uso": "escolar"}', 'kit, escolar, útiles, básico, regreso a clases', 'Back-to-School', FALSE, FALSE, TRUE, '2023-01-15', NULL, 0.800, '30 x 20 x 8 cm', '123456789012', 'OfficeMax', 15, 200, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Arte y Manualidades
('OM-ESC-004', 'COLORES-PRISMACOLOR-001', 'Lápices de Colores Prismacolor 24 pzs', 53, 'Prismacolor', 599.00, 529.00, 380.00, 'Set de 24 lápices de colores Prismacolor Premier', 'Lápices de colores Prismacolor Premier, set de 24 colores vibrantes, mina suave, mezcla fácil, calidad profesional para arte y manualidades.', '{"cantidad": "24", "tipo": "premier", "mina": "suave", "calidad": "profesional", "mezcla": "fácil"}', 'colores, prismacolor, arte, profesional, 24', 'Todo el año', FALSE, FALSE, TRUE, '2023-01-18', NULL, 0.350, '19 x 19 x 2 cm', '070735012345', 'Prismacolor', 12, 150, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('OM-ESC-005', 'PLASTILINA-PLAYDOH-001', 'Play-Doh Set 8 Colores 224g', 53, 'Play-Doh', 189.00, 159.00, 115.00, 'Set de plastilina Play-Doh con 8 colores surtidos', 'Set Play-Doh con 8 botes de plastilina de colores surtidos, 28g cada uno, no tóxico, fácil de moldear, estimula la creatividad.', '{"colores": "8", "peso_total": "224g", "peso_bote": "28g", "toxico": "no", "uso": "creativo"}', 'plastilina, play-doh, colores, creatividad, no tóxico', 'Todo el año', FALSE, FALSE, TRUE, '2023-02-05', NULL, 0.224, '20 x 15 x 6 cm', '630509456789', 'Hasbro', 25, 300, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- Productos de Mobiliario
INSERT INTO RAW_DATA.PRODUCTOS VALUES
-- Sillas
('OM-MOB-001', 'SILLA-EXEC-001', 'Silla Ejecutiva Ergonómica Negra', 31, 'OfficeMax', 4599.00, 3999.00, 2800.00, 'Silla ejecutiva ergonómica con soporte lumbar', 'Silla ejecutiva ergonómica con respaldo alto, soporte lumbar ajustable, brazos acolchados, base de nylon, rodajas de PU, certificación GREENGUARD.', '{"tipo": "ejecutiva", "respaldo": "alto", "soporte_lumbar": "ajustable", "brazos": "acolchados", "certificacion": "GREENGUARD"}', 'silla, ejecutiva, ergonómica, lumbar, oficina', 'Todo el año', FALSE, TRUE, TRUE, '2023-01-20', NULL, 18.5, '70 x 70 x 125 cm', '456789012345', 'OfficeMax', 2, 25, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Escritorios
('OM-MOB-002', 'ESCRITORIO-EXEC-001', 'Escritorio Ejecutivo L-Shape Caoba', 32, 'OfficeMax', 8999.00, 7999.00, 5600.00, 'Escritorio ejecutivo en forma de L acabado caoba', 'Escritorio ejecutivo en forma de L, acabado caoba, superficie de trabajo amplia, cajones con cerradura, pasacables incluidos, resistente y elegante.', '{"forma": "L", "acabado": "caoba", "cajones": "con cerradura", "pasacables": "incluidos", "uso": "ejecutivo"}', 'escritorio, ejecutivo, L-shape, caoba, cajones', 'Todo el año', FALSE, TRUE, TRUE, '2023-02-10', NULL, 55.0, '150 x 150 x 75 cm', '567890123456', 'OfficeMax', 1, 10, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- PASO 6: GENERAR CLIENTES SINTÉTICOS
-- ============================================================================

INSERT INTO RAW_DATA.CLIENTES VALUES
-- Clientes Individuales
('CLI-IND-001', 'INDIVIDUAL', 'María Elena González Pérez', NULL, 'GOPE850315M29', 'maria.gonzalez@gmail.com', '55-1234-5678', '55-8765-4321', '2022-03-15', '1985-03-15', 'F', 'REGULAR', 'ESTANDAR', 0, 0, 'Av. Universidad 1234', '101', NULL, 'Copilco', 'Coyoacán', 'CDMX', '04360', 'México', 'ONLINE', 'TARJETA', 'MENSUAL', 1250.00, 15000.00, TRUE, TRUE, 'Cliente frecuente de productos de oficina', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('CLI-IND-002', 'INDIVIDUAL', 'Carlos Roberto Martínez Silva', NULL, 'MASC790822H15', 'carlos.martinez@hotmail.com', '33-2345-6789', NULL, '2021-08-22', '1979-08-22', 'M', 'VIP', 'PREMIUM', 25000, 5, 'Av. Patria 2567', '45', 'B', 'Jardines Universidad', 'Zapopan', 'Jalisco', '45110', 'México', 'TIENDA', 'EFECTIVO', 'QUINCENAL', 2800.00, 42000.00, TRUE, TRUE, 'Comprador de tecnología y mobiliario', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('CLI-IND-003', 'INDIVIDUAL', 'Ana Patricia Rodríguez López', NULL, 'ROLA920505M21', 'ana.rodriguez@yahoo.com', '81-3456-7890', '81-9876-5432', '2023-01-10', '1992-05-05', 'F', 'REGULAR', 'ESTANDAR', 0, 0, 'Av. Constitución 891', '234', NULL, 'Centro', 'Monterrey', 'Nuevo León', '64000', 'México', 'APP_MOVIL', 'TRANSFERENCIA', 'MENSUAL', 950.00, 11400.00, TRUE, FALSE, 'Prefiere compras por app móvil', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('CLI-IND-004', 'INDIVIDUAL', 'José Luis Hernández Torres', NULL, 'HETJ871201H45', 'jose.hernandez@outlook.com', '222-4567-8901', NULL, '2022-07-18', '1987-12-01', 'M', 'REGULAR', 'ESTANDAR', 0, 0, 'Calle 16 de Septiembre 445', '12', 'A', 'Centro Histórico', 'Puebla', 'Puebla', '72000', 'México', 'TIENDA', 'TARJETA', 'BIMESTRAL', 1480.00, 17760.00, TRUE, TRUE, 'Cliente de papelería y útiles escolares', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Clientes Empresariales
('CLI-EMP-001', 'EMPRESARIAL', 'Laura Verónica Sánchez Morales', 'Consultores Integrales SA de CV', 'CIN120315AB4', 'compras@consultoresintegrales.com', '55-5555-1111', '55-5555-2222', '2021-05-20', '1988-09-12', 'F', 'CORPORATIVO', 'PREMIUM', 150000, 15, 'Blvd. Manuel Ávila Camacho 123', '45', '3er Piso', 'Lomas de Chapultepec', 'Miguel Hidalgo', 'CDMX', '11000', 'México', 'TELEFONO', 'CREDITO', 'MENSUAL', 12500.00, 300000.00, TRUE, TRUE, 'Empresa de consultoría, compras corporativas mensuales', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('CLI-EMP-002', 'EMPRESARIAL', 'Roberto Carlos Méndez Jiménez', 'Desarrollos Tecnológicos del Norte SA de CV', 'DTN180910CD7', 'adquisiciones@dtecnorte.com', '81-8888-3333', '81-8888-4444', '2020-09-10', '1982-06-25', 'M', 'CORPORATIVO', 'PREMIUM', 200000, 20, 'Av. San Jerónimo 456', '78', 'Torre B Piso 15', 'San Jerónimo', 'Monterrey', 'Nuevo León', '64640', 'México', 'ONLINE', 'TRANSFERENCIA', 'QUINCENAL', 18900.00, 453600.00, TRUE, FALSE, 'Empresa de desarrollo de software, compras de tecnología', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Clientes Educativos
('CLI-EDU-001', 'EDUCATIVO', 'Patricia Elena Romero Vázquez', 'Instituto Educativo San Patricio AC', 'IES050422NP8', 'compras@sanpatricio.edu.mx', '33-7777-5555', '33-7777-6666', '2019-04-22', '1975-11-30', 'F', 'PREMIUM', 'EDUCATIVO', 80000, 25, 'Av. López Mateos Norte 789', '123', NULL, 'Jardines de Guadalupe', 'Zapopan', 'Jalisco', '45030', 'México', 'TELEFONO', 'CHEQUE', 'BIMESTRAL', 8500.00, 204000.00, TRUE, TRUE, 'Colegio privado, compras de material escolar y mobiliario', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

('CLI-EDU-002', 'EDUCATIVO', 'Miguel Ángel Flores Castillo', 'Universidad Tecnológica de Puebla', 'UTP850630G12', 'adquisiciones@utpuebla.edu.mx', '222-9999-7777', '222-9999-8888', '2018-06-30', '1978-04-15', 'M', 'PREMIUM', 'EDUCATIVO', 120000, 30, 'Blvd. Universidad Tecnológica 1', 'S/N', NULL, 'San Miguel Canoa', 'Puebla', 'Puebla', '72640', 'México', 'ONLINE', 'TRANSFERENCIA', 'MENSUAL', 15200.00, 456000.00, TRUE, FALSE, 'Universidad pública, compras de tecnología y mobiliario', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Clientes Gobierno
('CLI-GOB-001', 'GOBIERNO', 'Sandra Leticia Morales Rivera', 'Municipio de San Pedro Garza García', 'MSG191201GH5', 'compras@sanpedro.gob.mx', '81-4444-9999', '81-4444-0000', '2019-12-01', '1984-02-28', 'F', 'CORPORATIVO', 'GOBIERNO', 300000, 45, 'Av. José Vasconcelos 402', 'S/N', 'Planta Baja', 'Del Valle', 'San Pedro Garza García', 'Nuevo León', '66220', 'México', 'ONLINE', 'TRANSFERENCIA', 'MENSUAL', 25800.00, 774000.00, TRUE, FALSE, 'Gobierno municipal, licitaciones y compras directas', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- PASO 7: GENERAR INVENTARIO INICIAL
-- ============================================================================

-- Insertar inventario base para todos los productos en todas las sucursales
INSERT INTO RAW_DATA.INVENTARIO (PRODUCTO_ID, SUCURSAL_ID, STOCK_ACTUAL, STOCK_DISPONIBLE, STOCK_RESERVADO, UBICACION_ALMACEN, ULTIMO_CONTEO, COSTO_PROMEDIO, ROTACION_DIAS)
SELECT 
    p.PRODUCTO_ID,
    s.SUCURSAL_ID,
    -- Stock actual basado en tipo de sucursal y producto
    CASE 
        WHEN s.FORMATO_TIENDA = 'MEGATIENDA' THEN FLOOR(RANDOM() * 50) + 20
        WHEN s.FORMATO_TIENDA = 'TRADICIONAL' THEN FLOOR(RANDOM() * 30) + 10
        WHEN s.FORMATO_TIENDA = 'TIENDA_EXPRESS' THEN FLOOR(RANDOM() * 15) + 5
        ELSE FLOOR(RANDOM() * 10) + 2
    END as STOCK_ACTUAL,
    -- Stock disponible (95% del actual)
    FLOOR((CASE 
        WHEN s.FORMATO_TIENDA = 'MEGATIENDA' THEN FLOOR(RANDOM() * 50) + 20
        WHEN s.FORMATO_TIENDA = 'TRADICIONAL' THEN FLOOR(RANDOM() * 30) + 10
        WHEN s.FORMATO_TIENDA = 'TIENDA_EXPRESS' THEN FLOOR(RANDOM() * 15) + 5
        ELSE FLOOR(RANDOM() * 10) + 2
    END) * 0.95) as STOCK_DISPONIBLE,
    -- Stock reservado (5% del actual)
    FLOOR((CASE 
        WHEN s.FORMATO_TIENDA = 'MEGATIENDA' THEN FLOOR(RANDOM() * 50) + 20
        WHEN s.FORMATO_TIENDA = 'TRADICIONAL' THEN FLOOR(RANDOM() * 30) + 10
        WHEN s.FORMATO_TIENDA = 'TIENDA_EXPRESS' THEN FLOOR(RANDOM() * 15) + 5
        ELSE FLOOR(RANDOM() * 10) + 2
    END) * 0.05) as STOCK_RESERVADO,
    -- Ubicación en almacén
    CASE 
        WHEN p.CATEGORIA_ID BETWEEN 11 AND 15 THEN 'A' || FLOOR(RANDOM() * 10) + 1 || '-' || FLOOR(RANDOM() * 20) + 1
        WHEN p.CATEGORIA_ID BETWEEN 21 AND 24 THEN 'B' || FLOOR(RANDOM() * 10) + 1 || '-' || FLOOR(RANDOM() * 20) + 1
        WHEN p.CATEGORIA_ID BETWEEN 31 AND 34 THEN 'C' || FLOOR(RANDOM() * 10) + 1 || '-' || FLOOR(RANDOM() * 20) + 1
        WHEN p.CATEGORIA_ID BETWEEN 51 AND 53 THEN 'D' || FLOOR(RANDOM() * 10) + 1 || '-' || FLOOR(RANDOM() * 20) + 1
        ELSE 'E' || FLOOR(RANDOM() * 10) + 1 || '-' || FLOOR(RANDOM() * 20) + 1
    END as UBICACION_ALMACEN,
    -- Último conteo (últimos 30 días)
    DATEADD('day', -(FLOOR(RANDOM() * 30)), CURRENT_DATE()) as ULTIMO_CONTEO,
    -- Costo promedio (con variación del ±5%)
    p.COSTO_UNITARIO * (0.95 + (RANDOM() * 0.1)) as COSTO_PROMEDIO,
    -- Rotación en días (entre 15 y 90 días)
    FLOOR(RANDOM() * 75) + 15 as ROTACION_DIAS
FROM RAW_DATA.PRODUCTOS p
CROSS JOIN RAW_DATA.SUCURSALES s
WHERE p.ACTIVO = TRUE AND s.ACTIVO = TRUE;

-- ============================================================================
-- Mensaje de finalización del setup inicial
-- ============================================================================

SELECT 
    '🏢 OFFICEMAX MÉXICO - SETUP INICIAL COMPLETADO' as MENSAJE,
    'Base de datos creada con datos sintéticos listos para Cortex' as DETALLE,
    CURRENT_TIMESTAMP() as TIMESTAMP_COMPLETION;


