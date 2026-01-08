-- ============================================================================
-- DEMO INMOBILIARIA - URBANOVA
-- ============================================================================
-- Cliente: URBANOVA (Desarrollos Inmobiliarios Urbanova S.A. de C.V.)
-- Industria: Desarrollo Inmobiliario - Mercado Mexicano
-- Rol: Ingeniero de Datos
-- Plataforma: Snowflake SQL
-- Casos de Uso: Análisis de precios por zona, gestión de inventario, 
--                proyección de ventas
-- ============================================================================

-- ============================================================================
-- Sección 0: Historia y Caso de Uso
-- ============================================================================
/*
URBANOVA es un desarrollador inmobiliario mexicano enfocado en proyectos 
residenciales y comerciales en las principales ciudades del país. Con más de 
15 años en el mercado, la empresa gestiona múltiples desarrollos simultáneos 
en CDMX, Monterrey, Guadalajara, Querétaro, Mérida y Cancún.

RETOS DE NEGOCIO:
1. Visibilidad en tiempo real del inventario disponible por proyecto y tipo
2. Análisis de precios competitivos por zona geográfica
3. Proyección de ventas basada en tendencias históricas
4. Optimización de estrategias de pricing por segmento

SOLUCIÓN CON SNOWFLAKE:
- Consolidación de datos de ventas, inventario y proyectos en un Data Warehouse
- Análisis avanzado de precios por m² en diferentes zonas
- Modelos de proyección de ventas usando datos históricos
- Dashboard ejecutivo para toma de decisiones estratégicas

VALOR ESPERADO:
- Reducción de 30% en tiempo de análisis de mercado
- Optimización de precios con incremento de 15% en margen
- Proyección precisa de flujo de caja por proyecto
*/

-- ============================================================================
-- Sección 1: Configuración de Recursos
-- ============================================================================

-- 1.1 Crear Warehouse con configuración optimizada de costos
CREATE OR REPLACE WAREHOUSE URBANOVA_WH
    WITH WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse para demo de análisis inmobiliario - Auto-suspend en 60 seg para optimizar costos';

-- Usar el warehouse
USE WAREHOUSE URBANOVA_WH;

-- 1.2 Crear Base de Datos
CREATE OR REPLACE DATABASE URBANOVA_DB
    COMMENT = 'Base de datos para análisis de desarrollos inmobiliarios';

USE DATABASE URBANOVA_DB;

-- 1.3 Crear Schema
CREATE OR REPLACE SCHEMA URBANOVA_SCHEMA
    COMMENT = 'Schema principal para datos de propiedades, ventas e inventario';

USE SCHEMA URBANOVA_SCHEMA;

-- 1.4 Crear Roles y permisos (FinOps)
CREATE OR REPLACE ROLE URBANOVA_INGENIERO_DATOS;
CREATE OR REPLACE ROLE URBANOVA_ANALISTA_NEGOCIO;

GRANT USAGE ON WAREHOUSE URBANOVA_WH TO ROLE URBANOVA_INGENIERO_DATOS;
GRANT USAGE ON DATABASE URBANOVA_DB TO ROLE URBANOVA_INGENIERO_DATOS;
GRANT ALL ON SCHEMA URBANOVA_SCHEMA TO ROLE URBANOVA_INGENIERO_DATOS;

GRANT USAGE ON WAREHOUSE URBANOVA_WH TO ROLE URBANOVA_ANALISTA_NEGOCIO;
GRANT USAGE ON DATABASE URBANOVA_DB TO ROLE URBANOVA_ANALISTA_NEGOCIO;
GRANT USAGE ON SCHEMA URBANOVA_SCHEMA TO ROLE URBANOVA_ANALISTA_NEGOCIO;

-- 1.5 Tabla: Ciudades y Zonas
CREATE OR REPLACE TABLE URBANOVA_SCHEMA.CIUDADES (
    CIUDAD_ID NUMBER(10,0) PRIMARY KEY,
    NOMBRE_CIUDAD VARCHAR(100) NOT NULL,
    ESTADO VARCHAR(100) NOT NULL,
    ZONA_METROPOLITANA VARCHAR(100),
    POBLACION_APROX NUMBER(12,0),
    COMENTARIO VARCHAR(500)
);

-- 1.6 Tabla: Desarrollos/Proyectos
CREATE OR REPLACE TABLE URBANOVA_SCHEMA.DESARROLLOS (
    DESARROLLO_ID NUMBER(10,0) PRIMARY KEY,
    NOMBRE_DESARROLLO VARCHAR(200) NOT NULL,
    CIUDAD_ID NUMBER(10,0) NOT NULL,
    COLONIA VARCHAR(100),
    DELEGACION_MUNICIPIO VARCHAR(100),
    TIPO_DESARROLLO VARCHAR(50), -- Residencial, Mixto, Comercial
    FECHA_INICIO DATE,
    FECHA_ENTREGA_ESTIMADA DATE,
    TOTAL_UNIDADES NUMBER(10,0),
    ESTATUS VARCHAR(50), -- En Construcción, Preventa, Entregado
    COMENTARIO VARCHAR(500),
    FOREIGN KEY (CIUDAD_ID) REFERENCES URBANOVA_SCHEMA.CIUDADES(CIUDAD_ID)
);

-- 1.7 Tabla: Inventario de Propiedades
CREATE OR REPLACE TABLE URBANOVA_SCHEMA.PROPIEDADES (
    PROPIEDAD_ID NUMBER(10,0) PRIMARY KEY,
    DESARROLLO_ID NUMBER(10,0) NOT NULL,
    TIPO_PROPIEDAD VARCHAR(50), -- Departamento, Casa, Townhouse, Penthouse, Terreno, Local Comercial
    NUMERO_UNIDAD VARCHAR(20),
    NIVEL_PISO NUMBER(3,0),
    SUPERFICIE_M2 NUMBER(10,2),
    RECAMARAS NUMBER(2,0),
    BANOS NUMBER(3,1), -- Permite medios baños (2.5)
    ESTACIONAMIENTOS NUMBER(2,0),
    PRECIO_LISTA_MXN NUMBER(15,2),
    PRECIO_M2_MXN NUMBER(10,2),
    ESTATUS_INVENTARIO VARCHAR(50), -- Disponible, Apartado, Vendido, Escriturado
    FECHA_ACTUALIZACION DATE,
    COMENTARIO VARCHAR(500),
    FOREIGN KEY (DESARROLLO_ID) REFERENCES URBANOVA_SCHEMA.DESARROLLOS(DESARROLLO_ID)
);

-- 1.8 Tabla: Ventas Históricas
CREATE OR REPLACE TABLE URBANOVA_SCHEMA.VENTAS (
    VENTA_ID NUMBER(10,0) PRIMARY KEY,
    PROPIEDAD_ID NUMBER(10,0) NOT NULL,
    FECHA_VENTA DATE NOT NULL,
    PRECIO_VENTA_MXN NUMBER(15,2),
    DESCUENTO_APLICADO_PCT NUMBER(5,2), -- Porcentaje de descuento
    METODO_FINANCIAMIENTO VARCHAR(50), -- Contado, Hipoteca, Crédito Infonavit, Mixto
    ENGANCHE_MXN NUMBER(15,2),
    MESES_FINANCIAMIENTO NUMBER(4,0),
    TIPO_CLIENTE VARCHAR(50), -- Inversionista, Usuario Final, Extranjero
    AGENTE_ID NUMBER(10,0),
    COMENTARIO VARCHAR(500),
    FOREIGN KEY (PROPIEDAD_ID) REFERENCES URBANOVA_SCHEMA.PROPIEDADES(PROPIEDAD_ID)
);

-- 1.9 Tabla: Agentes de Ventas
CREATE OR REPLACE TABLE URBANOVA_SCHEMA.AGENTES (
    AGENTE_ID NUMBER(10,0) PRIMARY KEY,
    NOMBRE_COMPLETO VARCHAR(200) NOT NULL,
    EMAIL VARCHAR(100),
    TELEFONO VARCHAR(20),
    CIUDAD_BASE NUMBER(10,0),
    FECHA_INGRESO DATE,
    ESTATUS VARCHAR(50), -- Activo, Inactivo
    FOREIGN KEY (CIUDAD_BASE) REFERENCES URBANOVA_SCHEMA.CIUDADES(CIUDAD_ID)
);

-- 1.10 Tabla: Proyecciones de Ventas (Forecast)
CREATE OR REPLACE TABLE URBANOVA_SCHEMA.PROYECCIONES_VENTAS (
    PROYECCION_ID NUMBER(10,0) PRIMARY KEY,
    DESARROLLO_ID NUMBER(10,0) NOT NULL,
    MES_PROYECCION DATE NOT NULL,
    UNIDADES_PROYECTADAS NUMBER(10,0),
    INGRESOS_PROYECTADOS_MXN NUMBER(15,2),
    UNIDADES_REALES NUMBER(10,0),
    INGRESOS_REALES_MXN NUMBER(15,2),
    VARIACION_UNIDADES NUMBER(10,0),
    VARIACION_INGRESOS_MXN NUMBER(15,2),
    COMENTARIO VARCHAR(500),
    FOREIGN KEY (DESARROLLO_ID) REFERENCES URBANOVA_SCHEMA.DESARROLLOS(DESARROLLO_ID)
);

-- 1.11 Tabla: Costos de Construcción por Desarrollo
CREATE OR REPLACE TABLE URBANOVA_SCHEMA.COSTOS_CONSTRUCCION (
    COSTO_ID NUMBER(10,0) PRIMARY KEY,
    DESARROLLO_ID NUMBER(10,0) NOT NULL,
    TIPO_COSTO VARCHAR(100), -- Terreno, Construcción, Permisos, Marketing, Financiero, Otros
    DESCRIPCION VARCHAR(500),
    MONTO_MXN NUMBER(15,2),
    PORCENTAJE_TOTAL NUMBER(5,2), -- Porcentaje del costo total del proyecto
    FECHA_REGISTRO DATE,
    ESTATUS_PAGO VARCHAR(50), -- Pagado, Pendiente, Parcial
    COMENTARIO VARCHAR(500),
    FOREIGN KEY (DESARROLLO_ID) REFERENCES URBANOVA_SCHEMA.DESARROLLOS(DESARROLLO_ID)
);

-- 1.12 Tabla: Indicadores de Mercado y Variables Externas
CREATE OR REPLACE TABLE URBANOVA_SCHEMA.INDICADORES_MERCADO (
    INDICADOR_ID NUMBER(10,0) PRIMARY KEY,
    MES_REFERENCIA DATE NOT NULL,
    TASA_INTERES_HIPOTECARIO NUMBER(5,2), -- Tasa promedio de interés hipotecario en México
    INFLACION_ANUAL_PCT NUMBER(5,2), -- Inflación anual en porcentaje
    TIPO_CAMBIO_USD_MXN NUMBER(8,4), -- Tipo de cambio Dólar/Peso
    PRECIO_CEMENTO_TON NUMBER(10,2), -- Precio promedio del cemento por tonelada
    PRECIO_ACERO_TON NUMBER(10,2), -- Precio promedio del acero por tonelada
    INDICE_CONFIANZA_CONSUMIDOR NUMBER(6,2), -- Índice de confianza del consumidor
    PIB_CONSTRUCCION_VAR_PCT NUMBER(5,2), -- Variación % PIB sector construcción
    PERMISOS_CONSTRUCCION_TOTAL NUMBER(10,0), -- Total de permisos otorgados en el mes
    CREDITOS_HIPOTECARIOS_OTORGADOS NUMBER(10,0), -- Créditos hipotecarios otorgados en el mes
    COMENTARIO VARCHAR(500)
);

-- ============================================================================
-- Sección 2: Generación de Datos Sintéticos
-- ============================================================================

-- 2.1 Insertar Ciudades
INSERT INTO URBANOVA_SCHEMA.CIUDADES (
    CIUDAD_ID, NOMBRE_CIUDAD, ESTADO, ZONA_METROPOLITANA, POBLACION_APROX, COMENTARIO
)
VALUES
    (1, 'Ciudad de México', 'CDMX', 'Zona Metropolitana del Valle de México', 9200000, 'Capital y ciudad más poblada'),
    (2, 'Monterrey', 'Nuevo León', 'Zona Metropolitana de Monterrey', 1140000, 'Capital industrial del norte'),
    (3, 'Guadalajara', 'Jalisco', 'Zona Metropolitana de Guadalajara', 1460000, 'Capital de Jalisco, Silicon Valley mexicano'),
    (4, 'Querétaro', 'Querétaro', 'Zona Metropolitana de Querétaro', 940000, 'Hub industrial y aeroespacial'),
    (5, 'Mérida', 'Yucatán', 'Zona Metropolitana de Mérida', 920000, 'Capital cultural del sureste'),
    (6, 'Cancún', 'Quintana Roo', 'Zona Turística Caribe', 740000, 'Principal destino turístico de México');

-- 2.2 Insertar Agentes de Ventas
INSERT INTO URBANOVA_SCHEMA.AGENTES 
SELECT
    ROW_NUMBER() OVER (ORDER BY NULL) AS AGENTE_ID,
    nombre_completo,
    email,
    telefono,
    ciudad_base,
    fecha_ingreso,
    estatus
FROM (
    SELECT 'María Fernanda González' AS nombre_completo, 'mfgonzalez@urbanova.mx' AS email, '5512345678' AS telefono, 1 AS ciudad_base, '2020-03-15'::DATE AS fecha_ingreso, 'Activo' AS estatus UNION ALL
    SELECT 'Carlos Roberto Sánchez', 'crsanchez@urbanova.mx', '8187654321', 2, '2019-07-22'::DATE, 'Activo' UNION ALL
    SELECT 'Ana Patricia Martínez', 'apmartinez@urbanova.mx', '3398765432', 3, '2021-01-10'::DATE, 'Activo' UNION ALL
    SELECT 'Luis Alberto Ramírez', 'laramirez@urbanova.mx', '4421234567', 4, '2020-11-05'::DATE, 'Activo' UNION ALL
    SELECT 'Carmen Sofía Torres', 'cstorres@urbanova.mx', '9998887766', 5, '2022-02-14'::DATE, 'Activo' UNION ALL
    SELECT 'Jorge Eduardo López', 'jelopez@urbanova.mx', '9987654321', 6, '2021-06-20'::DATE, 'Activo' UNION ALL
    SELECT 'Isabel Guadalupe Hernández', 'ighernandez@urbanova.mx', '5523456789', 1, '2018-05-30'::DATE, 'Activo' UNION ALL
    SELECT 'Roberto Carlos Flores', 'rcflores@urbanova.mx', '8176543210', 2, '2020-09-12'::DATE, 'Inactivo'
);

-- 2.3 Insertar Desarrollos
INSERT INTO URBANOVA_SCHEMA.DESARROLLOS 
SELECT
    ROW_NUMBER() OVER (ORDER BY NULL) AS DESARROLLO_ID,
    nombre_desarrollo,
    ciudad_id,
    colonia,
    delegacion_municipio,
    tipo_desarrollo,
    fecha_inicio,
    fecha_entrega_estimada,
    total_unidades,
    estatus,
    comentario
FROM (
    SELECT 'Bosques de Santa Fe' AS nombre_desarrollo, 1 AS ciudad_id, 'Santa Fe' AS colonia, 'Cuajimalpa' AS delegacion_municipio, 'Residencial' AS tipo_desarrollo, '2023-01-15'::DATE AS fecha_inicio, '2025-06-30'::DATE AS fecha_entrega_estimada, 120 AS total_unidades, 'En Construcción' AS estatus, 'Desarrollo premium con amenidades de lujo' AS comentario UNION ALL
    SELECT 'Torre Polanco', 1, 'Polanco', 'Miguel Hidalgo', 'Residencial', '2022-06-01'::DATE, '2024-12-31'::DATE, 80, 'Preventa', 'Ubicación privilegiada en zona financiera' UNION ALL
    SELECT 'Residencial Valle Oriente', 2, 'Valle Oriente', 'San Pedro Garza García', 'Residencial', '2022-03-10'::DATE, '2024-09-30'::DATE, 95, 'En Construcción', 'Zona exclusiva con alto potencial de plusvalía' UNION ALL
    SELECT 'Cumbres Platinum', 2, 'Cumbres', 'Monterrey', 'Residencial', '2023-05-20'::DATE, '2025-12-31'::DATE, 150, 'Preventa', 'Desarrollo familiar con áreas verdes' UNION ALL
    SELECT 'Punto Sao Paulo', 3, 'Providencia', 'Guadalajara', 'Mixto', '2021-11-01'::DATE, '2024-03-31'::DATE, 110, 'Entregado', 'Desarrollo mixto con retail y residencial' UNION ALL
    SELECT 'Andares Residencial', 3, 'Puerta de Hierro', 'Zapopan', 'Residencial', '2023-02-14'::DATE, '2025-08-31'::DATE, 75, 'En Construcción', 'Lujo y conectividad en zona premium' UNION ALL
    SELECT 'Querétaro Business Park', 4, 'Centro Sur', 'Querétaro', 'Comercial', '2022-09-01'::DATE, '2024-06-30'::DATE, 45, 'En Construcción', 'Oficinas corporativas clase A' UNION ALL
    SELECT 'Villas del Marqués', 4, 'El Marqués', 'El Marqués', 'Residencial', '2023-03-20'::DATE, '2025-10-31'::DATE, 200, 'Preventa', 'Casas y townhouses familiares' UNION ALL
    SELECT 'Lofts Mérida Centro', 5, 'Centro Histórico', 'Mérida', 'Residencial', '2022-04-15'::DATE, '2024-08-31'::DATE, 60, 'En Construcción', 'Lofts modernos en zona colonial' UNION ALL
    SELECT 'Altabrisa Towers', 5, 'Altabrisa', 'Mérida', 'Residencial', '2023-07-01'::DATE, '2026-01-31'::DATE, 130, 'Preventa', 'Torres gemelas con vista panorámica' UNION ALL
    SELECT 'Marina Cancún Residences', 6, 'Puerto Cancún', 'Benito Juárez', 'Residencial', '2022-01-20'::DATE, '2024-11-30'::DATE, 90, 'En Construcción', 'Residencias frente a marina turística' UNION ALL
    SELECT 'Departamentos Playa Caracol', 6, 'Zona Hotelera', 'Benito Juárez', 'Residencial', '2023-04-10'::DATE, '2025-07-31'::DATE, 110, 'Preventa', 'Vista al mar Caribe, ideal para inversión turística'
);

-- 2.4 Insertar Propiedades (Inventario)
INSERT INTO URBANOVA_SCHEMA.PROPIEDADES
SELECT
    ROW_NUMBER() OVER (ORDER BY NULL) AS PROPIEDAD_ID,
    desarrollo_id,
    tipo_propiedad,
    numero_unidad,
    nivel_piso,
    superficie_m2,
    recamaras,
    banos,
    estacionamientos,
    precio_lista_mxn,
    ROUND(precio_lista_mxn / superficie_m2, 2) AS precio_m2_mxn,
    estatus_inventario,
    fecha_actualizacion,
    comentario
FROM (
    -- Desarrollo 1: Bosques de Santa Fe (CDMX) - 120 unidades
    SELECT 1 AS desarrollo_id, 'Departamento' AS tipo_propiedad, '101' AS numero_unidad, 1 AS nivel_piso, 85.5 AS superficie_m2, 2 AS recamaras, 2.0 AS banos, 1 AS estacionamientos, 4200000 AS precio_lista_mxn, 'Disponible' AS estatus_inventario, '2024-10-15'::DATE AS fecha_actualizacion, 'Vista a jardín interior' AS comentario UNION ALL
    SELECT 1, 'Departamento', '102', 1, 85.5, 2, 2.0, 1, 4200000, 'Vendido', '2024-09-10'::DATE, 'Vista a jardín interior' UNION ALL
    SELECT 1, 'Departamento', '201', 2, 95.0, 2, 2.0, 2, 5100000, 'Apartado', '2024-10-20'::DATE, 'Vista panorámica' UNION ALL
    SELECT 1, 'Departamento', '301', 3, 120.0, 3, 2.5, 2, 6800000, 'Disponible', '2024-10-15'::DATE, 'Doble altura' UNION ALL
    SELECT 1, 'Penthouse', 'PH-A', 15, 220.0, 4, 3.5, 3, 14500000, 'Disponible', '2024-10-15'::DATE, 'Roof garden privado' UNION ALL
    
    -- Desarrollo 2: Torre Polanco (CDMX) - 80 unidades
    SELECT 2, 'Departamento', 'A-501', 5, 110.0, 2, 2.0, 2, 7200000, 'Vendido', '2024-08-05'::DATE, 'Vista a Chapultepec' UNION ALL
    SELECT 2, 'Departamento', 'A-502', 5, 110.0, 2, 2.0, 2, 7200000, 'Disponible', '2024-10-15'::DATE, 'Vista a Chapultepec' UNION ALL
    SELECT 2, 'Departamento', 'B-801', 8, 145.0, 3, 3.0, 2, 10100000, 'Apartado', '2024-10-18'::DATE, 'Esquina con doble vista' UNION ALL
    SELECT 2, 'Penthouse', 'PH-1', 18, 280.0, 4, 4.0, 4, 22000000, 'Disponible', '2024-10-15'::DATE, 'Vista 360 grados' UNION ALL
    
    -- Desarrollo 3: Residencial Valle Oriente (Monterrey) - 95 unidades
    SELECT 3, 'Departamento', '101', 1, 92.0, 2, 2.0, 2, 3800000, 'Vendido', '2024-07-20'::DATE, 'Acceso directo a jardín' UNION ALL
    SELECT 3, 'Departamento', '102', 1, 92.0, 2, 2.0, 2, 3800000, 'Disponible', '2024-10-15'::DATE, 'Acceso directo a jardín' UNION ALL
    SELECT 3, 'Departamento', '203', 2, 105.0, 3, 2.5, 2, 4500000, 'Disponible', '2024-10-15'::DATE, 'Balcón amplio' UNION ALL
    SELECT 3, 'Departamento', '405', 4, 115.0, 3, 2.5, 2, 5200000, 'Apartado', '2024-10-22'::DATE, 'Vista a la sierra' UNION ALL
    
    -- Desarrollo 4: Cumbres Platinum (Monterrey) - 150 unidades
    SELECT 4, 'Casa', 'C-15', 0, 180.0, 3, 3.0, 2, 5900000, 'Vendido', '2024-09-05'::DATE, 'Jardín y terraza' UNION ALL
    SELECT 4, 'Casa', 'C-16', 0, 180.0, 3, 3.0, 2, 5900000, 'Disponible', '2024-10-15'::DATE, 'Jardín y terraza' UNION ALL
    SELECT 4, 'Townhouse', 'T-22', 0, 145.0, 3, 2.5, 2, 4800000, 'Disponible', '2024-10-15'::DATE, 'Tres niveles' UNION ALL
    SELECT 4, 'Casa', 'C-45', 0, 210.0, 4, 3.5, 3, 7200000, 'Apartado', '2024-10-19'::DATE, 'Esquina con jardín grande' UNION ALL
    
    -- Desarrollo 5: Punto Sao Paulo (Guadalajara) - 110 unidades - ENTREGADO
    SELECT 5, 'Departamento', '301', 3, 88.0, 2, 2.0, 1, 3100000, 'Escriturado', '2024-04-10'::DATE, 'Unidad entregada' UNION ALL
    SELECT 5, 'Departamento', '405', 4, 95.0, 2, 2.0, 2, 3650000, 'Escriturado', '2024-03-22'::DATE, 'Unidad entregada' UNION ALL
    SELECT 5, 'Local Comercial', 'LC-01', 0, 125.0, 0, 1.0, 0, 4800000, 'Vendido', '2024-05-15'::DATE, 'Frente a plaza' UNION ALL
    SELECT 5, 'Local Comercial', 'LC-02', 0, 125.0, 0, 1.0, 0, 4800000, 'Disponible', '2024-10-15'::DATE, 'Frente a plaza' UNION ALL
    
    -- Desarrollo 6: Andares Residencial (Guadalajara) - 75 unidades
    SELECT 6, 'Departamento', 'A-701', 7, 130.0, 3, 2.5, 2, 6800000, 'Disponible', '2024-10-15'::DATE, 'Vista a campo de golf' UNION ALL
    SELECT 6, 'Departamento', 'B-802', 8, 145.0, 3, 3.0, 2, 7900000, 'Apartado', '2024-10-21'::DATE, 'Esquina premium' UNION ALL
    SELECT 6, 'Penthouse', 'PH-1', 12, 260.0, 4, 3.5, 3, 16500000, 'Disponible', '2024-10-15'::DATE, 'Terraza con jacuzzi' UNION ALL
    
    -- Desarrollo 7: Querétaro Business Park (Querétaro) - 45 unidades comerciales
    SELECT 7, 'Local Comercial', 'OF-101', 1, 85.0, 0, 1.0, 2, 2900000, 'Vendido', '2024-06-08'::DATE, 'Oficina equipada' UNION ALL
    SELECT 7, 'Local Comercial', 'OF-102', 1, 85.0, 0, 1.0, 2, 2900000, 'Disponible', '2024-10-15'::DATE, 'Oficina equipada' UNION ALL
    SELECT 7, 'Local Comercial', 'OF-205', 2, 120.0, 0, 2.0, 3, 4100000, 'Disponible', '2024-10-15'::DATE, 'Oficina corporativa' UNION ALL
    SELECT 7, 'Local Comercial', 'OF-301', 3, 180.0, 0, 2.0, 5, 6200000, 'Apartado', '2024-10-17'::DATE, 'Piso completo' UNION ALL
    
    -- Desarrollo 8: Villas del Marqués (Querétaro) - 200 unidades
    SELECT 8, 'Casa', 'V-10', 0, 165.0, 3, 2.5, 2, 3800000, 'Vendido', '2024-09-12'::DATE, 'Casa en privada' UNION ALL
    SELECT 8, 'Casa', 'V-11', 0, 165.0, 3, 2.5, 2, 3800000, 'Disponible', '2024-10-15'::DATE, 'Casa en privada' UNION ALL
    SELECT 8, 'Townhouse', 'TH-25', 0, 135.0, 2, 2.5, 2, 3200000, 'Disponible', '2024-10-15'::DATE, 'Dos niveles' UNION ALL
    SELECT 8, 'Casa', 'V-88', 0, 195.0, 4, 3.0, 3, 4950000, 'Apartado', '2024-10-23'::DATE, 'Lote amplio' UNION ALL
    
    -- Desarrollo 9: Lofts Mérida Centro (Mérida) - 60 unidades
    SELECT 9, 'Departamento', 'L-201', 2, 75.0, 1, 1.5, 1, 2100000, 'Vendido', '2024-08-14'::DATE, 'Estilo loft industrial' UNION ALL
    SELECT 9, 'Departamento', 'L-202', 2, 75.0, 1, 1.5, 1, 2100000, 'Disponible', '2024-10-15'::DATE, 'Estilo loft industrial' UNION ALL
    SELECT 9, 'Departamento', 'L-305', 3, 95.0, 2, 2.0, 1, 2850000, 'Disponible', '2024-10-15'::DATE, 'Doble altura' UNION ALL
    SELECT 9, 'Departamento', 'L-401', 4, 110.0, 2, 2.0, 2, 3400000, 'Apartado', '2024-10-20'::DATE, 'Vista al centro histórico' UNION ALL
    
    -- Desarrollo 10: Altabrisa Towers (Mérida) - 130 unidades
    SELECT 10, 'Departamento', 'T1-501', 5, 100.0, 2, 2.0, 2, 3650000, 'Disponible', '2024-10-15'::DATE, 'Torre 1' UNION ALL
    SELECT 10, 'Departamento', 'T1-801', 8, 120.0, 3, 2.5, 2, 4600000, 'Disponible', '2024-10-15'::DATE, 'Vista panorámica' UNION ALL
    SELECT 10, 'Penthouse', 'T2-PH1', 15, 240.0, 4, 3.5, 3, 11800000, 'Apartado', '2024-10-16'::DATE, 'Roof garden y alberca privada' UNION ALL
    
    -- Desarrollo 11: Marina Cancún Residences (Cancún) - 90 unidades
    SELECT 11, 'Departamento', '201', 2, 105.0, 2, 2.0, 2, 5800000, 'Vendido', '2024-07-25'::DATE, 'Vista a marina' UNION ALL
    SELECT 11, 'Departamento', '202', 2, 105.0, 2, 2.0, 2, 5800000, 'Disponible', '2024-10-15'::DATE, 'Vista a marina' UNION ALL
    SELECT 11, 'Departamento', '305', 3, 125.0, 3, 2.5, 2, 7200000, 'Disponible', '2024-10-15'::DATE, 'Esquina con vista doble' UNION ALL
    SELECT 11, 'Penthouse', 'PH-A', 12, 210.0, 3, 3.0, 3, 13500000, 'Apartado', '2024-10-18'::DATE, 'Vista al mar y marina' UNION ALL
    
    -- Desarrollo 12: Departamentos Playa Caracol (Cancún) - 110 unidades
    SELECT 12, 'Departamento', 'PC-101', 1, 90.0, 2, 2.0, 1, 6500000, 'Disponible', '2024-10-15'::DATE, 'Acceso directo a playa' UNION ALL
    SELECT 12, 'Departamento', 'PC-205', 2, 110.0, 2, 2.0, 2, 8200000, 'Apartado', '2024-10-19'::DATE, 'Vista frontal al mar' UNION ALL
    SELECT 12, 'Departamento', 'PC-310', 3, 135.0, 3, 2.5, 2, 10500000, 'Disponible', '2024-10-15'::DATE, 'Vista panorámica al Caribe' UNION ALL
    SELECT 12, 'Penthouse', 'PC-PH2', 10, 250.0, 4, 3.5, 3, 19800000, 'Disponible', '2024-10-15'::DATE, 'Terraza frente al mar con jacuzzi'
);

-- 2.5 Insertar Ventas Históricas (últimos 18 meses)
INSERT INTO URBANOVA_SCHEMA.VENTAS
SELECT
    ROW_NUMBER() OVER (ORDER BY NULL) AS VENTA_ID,
    propiedad_id,
    fecha_venta,
    precio_venta_mxn,
    descuento_aplicado_pct,
    metodo_financiamiento,
    enganche_mxn,
    meses_financiamiento,
    tipo_cliente,
    agente_id,
    comentario
FROM (
    -- Ventas del desarrollo 5 (Punto Sao Paulo - Entregado)
    SELECT 17 AS propiedad_id, '2024-04-10'::DATE AS fecha_venta, 3100000 AS precio_venta_mxn, 0.00 AS descuento_aplicado_pct, 'Hipoteca' AS metodo_financiamiento, 930000 AS enganche_mxn, 180 AS meses_financiamiento, 'Usuario Final' AS tipo_cliente, 3 AS agente_id, 'Cliente aprobado por banco' AS comentario UNION ALL
    SELECT 18, '2024-03-22'::DATE, 3650000, 0.00, 'Contado', 3650000, 0, 'Inversionista', 3, 'Pago en una exhibición' UNION ALL
    SELECT 19, '2024-05-15'::DATE, 4560000, 5.00, 'Mixto', 1824000, 120, 'Inversionista', 3, 'Descuento por preventa' UNION ALL
    
    -- Ventas CDMX
    SELECT 2, '2024-09-10'::DATE, 4200000, 0.00, 'Hipoteca', 840000, 240, 'Usuario Final', 1, 'Primera vivienda' UNION ALL
    SELECT 6, '2024-08-05'::DATE, 7200000, 0.00, 'Crédito Infonavit', 1440000, 180, 'Usuario Final', 1, 'Cliente con crédito aprobado' UNION ALL
    
    -- Ventas Monterrey
    SELECT 10, '2024-07-20'::DATE, 3800000, 0.00, 'Hipoteca', 1140000, 200, 'Usuario Final', 2, 'Familia joven' UNION ALL
    SELECT 14, '2024-09-05'::DATE, 5900000, 0.00, 'Mixto', 1770000, 180, 'Usuario Final', 2, 'Casa con jardín' UNION ALL
    
    -- Ventas Querétaro
    SELECT 26, '2024-06-08'::DATE, 2900000, 0.00, 'Contado', 2900000, 0, 'Inversionista', 4, 'Oficina corporativa' UNION ALL
    SELECT 30, '2024-09-12'::DATE, 3800000, 0.00, 'Crédito Infonavit', 760000, 240, 'Usuario Final', 4, 'Primera casa' UNION ALL
    
    -- Ventas Mérida
    SELECT 34, '2024-08-14'::DATE, 2100000, 0.00, 'Hipoteca', 630000, 180, 'Usuario Final', 5, 'Joven profesionista' UNION ALL
    
    -- Ventas Cancún
    SELECT 42, '2024-07-25'::DATE, 5800000, 0.00, 'Contado', 5800000, 0, 'Extranjero', 6, 'Inversionista estadounidense'
);

-- 2.6 Insertar Proyecciones de Ventas (Forecast para próximos 12 meses)
INSERT INTO URBANOVA_SCHEMA.PROYECCIONES_VENTAS
SELECT
    ROW_NUMBER() OVER (ORDER BY NULL) AS PROYECCION_ID,
    desarrollo_id,
    mes_proyeccion,
    unidades_proyectadas,
    ingresos_proyectados_mxn,
    unidades_reales,
    ingresos_reales_mxn,
    unidades_reales - unidades_proyectadas AS variacion_unidades,
    ingresos_reales_mxn - ingresos_proyectados_mxn AS variacion_ingresos_mxn,
    comentario
FROM (
    -- Proyecciones históricas (con datos reales)
    SELECT 1 AS desarrollo_id, '2024-09-01'::DATE AS mes_proyeccion, 3 AS unidades_proyectadas, 15000000 AS ingresos_proyectados_mxn, 1 AS unidades_reales, 4200000 AS ingresos_reales_mxn, 'Septiembre por debajo de proyección' AS comentario UNION ALL
    SELECT 2, '2024-08-01'::DATE, 2, 14000000, 1, 7200000, 'Agosto con menor ritmo de ventas' UNION ALL
    SELECT 3, '2024-07-01'::DATE, 4, 18000000, 1, 3800000, 'Julio por debajo de meta' UNION ALL
    SELECT 4, '2024-09-01'::DATE, 5, 30000000, 1, 5900000, 'Septiembre lento en Cumbres' UNION ALL
    
    -- Proyecciones futuras (sin datos reales aún)
    SELECT 1, '2024-11-01'::DATE, 4, 20000000, NULL, NULL, 'Proyección noviembre' UNION ALL
    SELECT 1, '2024-12-01'::DATE, 5, 25000000, NULL, NULL, 'Proyección diciembre - cierre de año' UNION ALL
    SELECT 2, '2024-11-01'::DATE, 3, 21000000, NULL, NULL, 'Proyección noviembre' UNION ALL
    SELECT 2, '2024-12-01'::DATE, 4, 28000000, NULL, NULL, 'Proyección diciembre' UNION ALL
    SELECT 3, '2024-11-01'::DATE, 5, 24000000, NULL, NULL, 'Proyección noviembre' UNION ALL
    SELECT 4, '2024-11-01'::DATE, 6, 35000000, NULL, NULL, 'Proyección noviembre' UNION ALL
    SELECT 6, '2024-11-01'::DATE, 3, 22000000, NULL, NULL, 'Proyección noviembre' UNION ALL
    SELECT 8, '2024-11-01'::DATE, 7, 28000000, NULL, NULL, 'Proyección noviembre' UNION ALL
    SELECT 11, '2024-11-01'::DATE, 4, 26000000, NULL, NULL, 'Proyección noviembre' UNION ALL
    SELECT 12, '2024-11-01'::DATE, 3, 27000000, NULL, NULL, 'Proyección noviembre'
);

-- 2.7 Insertar Costos de Construcción por Desarrollo
INSERT INTO URBANOVA_SCHEMA.COSTOS_CONSTRUCCION
SELECT
    ROW_NUMBER() OVER (ORDER BY NULL) AS COSTO_ID,
    desarrollo_id,
    tipo_costo,
    descripcion,
    monto_mxn,
    porcentaje_total,
    fecha_registro,
    estatus_pago,
    comentario
FROM (
    -- Desarrollo 1: Bosques de Santa Fe (CDMX) - Costo total estimado: $504M
    SELECT 1 AS desarrollo_id, 'Terreno' AS tipo_costo, 'Adquisición de terreno 5,000 m2' AS descripcion, 180000000 AS monto_mxn, 35.71 AS porcentaje_total, '2022-11-15'::DATE AS fecha_registro, 'Pagado' AS estatus_pago, 'Ubicación premium Santa Fe' AS comentario UNION ALL
    SELECT 1, 'Construcción', 'Obra civil y acabados premium', 252000000, 50.00, '2023-01-15'::DATE, 'Parcial', '120 unidades residenciales' UNION ALL
    SELECT 1, 'Permisos', 'Permisos y licencias de construcción', 15000000, 2.98, '2022-12-10'::DATE, 'Pagado', 'Trámites delegacionales' UNION ALL
    SELECT 1, 'Marketing', 'Campaña de preventa y comercialización', 25000000, 4.96, '2023-02-01'::DATE, 'Parcial', 'Marketing digital y tradicional' UNION ALL
    SELECT 1, 'Financiero', 'Intereses de crédito puente', 22000000, 4.37, '2023-01-01'::DATE, 'Parcial', 'Financiamiento bancario' UNION ALL
    SELECT 1, 'Otros', 'Imprevistos y contingencias', 10000000, 1.98, '2023-01-01'::DATE, 'Pendiente', 'Reserva para imprevistos' UNION ALL
    
    -- Desarrollo 2: Torre Polanco (CDMX) - Costo total: $448M
    SELECT 2, 'Terreno', 'Adquisición de terreno 3,500 m2', 160000000, 35.71, '2022-01-20'::DATE, 'Pagado', 'Zona exclusiva Polanco' UNION ALL
    SELECT 2, 'Construcción', 'Construcción de torre de 18 niveles', 224000000, 50.00, '2022-06-01'::DATE, 'Parcial', '80 unidades de lujo' UNION ALL
    SELECT 2, 'Permisos', 'Licencias y permisos especiales', 13000000, 2.90, '2022-03-15'::DATE, 'Pagado', 'Zona patrimonial' UNION ALL
    SELECT 2, 'Marketing', 'Preventa y publicidad', 22000000, 4.91, '2022-05-01'::DATE, 'Parcial', 'Campaña dirigida a segmento alto' UNION ALL
    SELECT 2, 'Financiero', 'Costos financieros', 20000000, 4.46, '2022-06-01'::DATE, 'Parcial', 'Crédito constructor' UNION ALL
    SELECT 2, 'Otros', 'Contingencias', 9000000, 2.01, '2022-06-01'::DATE, 'Pendiente', 'Fondo de contingencia' UNION ALL
    
    -- Desarrollo 3: Residencial Valle Oriente (Monterrey) - Costo total: $313M
    SELECT 3, 'Terreno', 'Terreno 4,200 m2', 90000000, 28.75, '2021-10-10'::DATE, 'Pagado', 'San Pedro Garza García' UNION ALL
    SELECT 3, 'Construcción', 'Construcción de 95 unidades', 156500000, 50.00, '2022-03-10'::DATE, 'Parcial', 'Acabados de primera' UNION ALL
    SELECT 3, 'Permisos', 'Permisos municipales', 9000000, 2.88, '2021-12-15'::DATE, 'Pagado', 'Municipio de San Pedro' UNION ALL
    SELECT 3, 'Marketing', 'Comercialización', 15000000, 4.79, '2022-02-01'::DATE, 'Parcial', 'Marketing regional' UNION ALL
    SELECT 3, 'Financiero', 'Intereses bancarios', 14000000, 4.47, '2022-03-10'::DATE, 'Parcial', 'Financiamiento local' UNION ALL
    SELECT 3, 'Otros', 'Varios', 9000000, 2.88, '2022-03-10'::DATE, 'Pendiente', 'Reserva' UNION ALL
    
    -- Desarrollo 4: Cumbres Platinum (Monterrey) - Costo total: $675M (casas)
    SELECT 4, 'Terreno', 'Fraccionamiento 25,000 m2', 210000000, 31.11, '2022-11-01'::DATE, 'Pagado', 'Zona Cumbres' UNION ALL
    SELECT 4, 'Construcción', 'Construcción de 150 casas', 337500000, 50.00, '2023-05-20'::DATE, 'Parcial', 'Desarrollo horizontal' UNION ALL
    SELECT 4, 'Permisos', 'Permisos de fraccionamiento', 20000000, 2.96, '2023-01-10'::DATE, 'Pagado', 'Uso de suelo residencial' UNION ALL
    SELECT 4, 'Marketing', 'Preventa y sala de ventas', 33750000, 5.00, '2023-04-01'::DATE, 'Parcial', 'Casa muestra incluida' UNION ALL
    SELECT 4, 'Financiero', 'Costos de financiamiento', 27000000, 4.00, '2023-05-20'::DATE, 'Parcial', 'Crédito de habilitación' UNION ALL
    SELECT 4, 'Otros', 'Urbanización e infraestructura', 46750000, 6.93, '2023-05-20'::DATE, 'Parcial', 'Servicios y amenidades' UNION ALL
    
    -- Desarrollo 5: Punto Sao Paulo (Guadalajara) - Costo total: $352M - ENTREGADO
    SELECT 5, 'Terreno', 'Terreno mixto 5,500 m2', 100000000, 28.41, '2021-03-15'::DATE, 'Pagado', 'Zona Providencia' UNION ALL
    SELECT 5, 'Construcción', 'Obra mixta (retail + residencial)', 176000000, 50.00, '2021-11-01'::DATE, 'Pagado', 'Proyecto terminado' UNION ALL
    SELECT 5, 'Permisos', 'Permisos uso mixto', 10500000, 2.98, '2021-06-20'::DATE, 'Pagado', 'Licencias especiales' UNION ALL
    SELECT 5, 'Marketing', 'Campaña completa', 17500000, 4.97, '2021-09-01'::DATE, 'Pagado', 'Preventa exitosa' UNION ALL
    SELECT 5, 'Financiero', 'Intereses totales', 16000000, 4.55, '2021-11-01'::DATE, 'Pagado', 'Liquidado' UNION ALL
    SELECT 5, 'Otros', 'Contingencias y otros', 32000000, 9.09, '2021-11-01'::DATE, 'Pagado', 'Proyecto terminado' UNION ALL
    
    -- Desarrollo 6: Andares Residencial (Guadalajara) - Costo total: $405M
    SELECT 6, 'Terreno', 'Terreno premium 3,800 m2', 140000000, 34.57, '2022-09-01'::DATE, 'Pagado', 'Puerta de Hierro' UNION ALL
    SELECT 6, 'Construcción', 'Torre residencial 75 unidades', 202500000, 50.00, '2023-02-14'::DATE, 'Parcial', 'Construcción en proceso' UNION ALL
    SELECT 6, 'Permisos', 'Licencias municipales', 12000000, 2.96, '2022-11-20'::DATE, 'Pagado', 'Zapopan' UNION ALL
    SELECT 6, 'Marketing', 'Preventa exclusiva', 20250000, 5.00, '2023-01-10'::DATE, 'Parcial', 'Segmento premium' UNION ALL
    SELECT 6, 'Financiero', 'Financiamiento', 16200000, 4.00, '2023-02-14'::DATE, 'Parcial', 'En curso' UNION ALL
    SELECT 6, 'Otros', 'Varios', 14050000, 3.47, '2023-02-14'::DATE, 'Pendiente', 'Reserva' UNION ALL
    
    -- Desarrollo 8: Villas del Marqués (Querétaro) - Costo total: $570M
    SELECT 8, 'Terreno', 'Terreno 35,000 m2', 165000000, 28.95, '2022-10-01'::DATE, 'Pagado', 'El Marqués zona en crecimiento' UNION ALL
    SELECT 8, 'Construcción', '200 casas y townhouses', 285000000, 50.00, '2023-03-20'::DATE, 'Parcial', 'Fraccionamiento familiar' UNION ALL
    SELECT 8, 'Permisos', 'Permisos de lotificación', 17000000, 2.98, '2022-12-05'::DATE, 'Pagado', 'Municipio El Marqués' UNION ALL
    SELECT 8, 'Marketing', 'Comercialización regional', 28500000, 5.00, '2023-02-01'::DATE, 'Parcial', 'Ventas en curso' UNION ALL
    SELECT 8, 'Financiero', 'Intereses', 22800000, 4.00, '2023-03-20'::DATE, 'Parcial', 'Financiamiento activo' UNION ALL
    SELECT 8, 'Otros', 'Infraestructura común', 51700000, 9.07, '2023-03-20'::DATE, 'Parcial', 'Áreas verdes y servicios' UNION ALL
    
    -- Desarrollo 11: Marina Cancún Residences - Costo total: $468M
    SELECT 11, 'Terreno', 'Terreno frente a marina', 175000000, 37.39, '2021-09-10'::DATE, 'Pagado', 'Puerto Cancún ubicación premium' UNION ALL
    SELECT 11, 'Construcción', '90 residencias marina', 234000000, 50.00, '2022-01-20'::DATE, 'Parcial', 'Vista a marina' UNION ALL
    SELECT 11, 'Permisos', 'Permisos zona federal', 14000000, 2.99, '2021-11-15'::DATE, 'Pagado', 'Trámites federales' UNION ALL
    SELECT 11, 'Marketing', 'Marketing internacional', 23400000, 5.00, '2021-12-01'::DATE, 'Parcial', 'Mercado extranjero' UNION ALL
    SELECT 11, 'Financiero', 'Costos financieros', 18720000, 4.00, '2022-01-20'::DATE, 'Parcial', 'En proceso' UNION ALL
    SELECT 11, 'Otros', 'Otros conceptos', 3000000, 0.64, '2022-01-20'::DATE, 'Pendiente', 'Reserva' UNION ALL
    
    -- Desarrollo 12: Departamentos Playa Caracol - Costo total: $792M
    SELECT 12, 'Terreno', 'Terreno zona hotelera frente al mar', 310000000, 39.14, '2022-10-01'::DATE, 'Pagado', 'Primera línea de playa' UNION ALL
    SELECT 12, 'Construcción', '110 departamentos vista al mar', 396000000, 50.00, '2023-04-10'::DATE, 'Parcial', 'Torre frente al Caribe' UNION ALL
    SELECT 12, 'Permisos', 'Permisos ambientales y construcción', 23000000, 2.90, '2023-01-05'::DATE, 'Pagado', 'SEMARNAT y municipales' UNION ALL
    SELECT 12, 'Marketing', 'Campaña internacional', 39600000, 5.00, '2023-03-01'::DATE, 'Parcial', 'Target inversionistas' UNION ALL
    SELECT 12, 'Financiero', 'Intereses', 23760000, 3.00, '2023-04-10'::DATE, 'Parcial', 'Financiamiento en USD y MXN' UNION ALL
    SELECT 12, 'Otros', 'Reservas', 0, 0.00, '2023-04-10'::DATE, 'Pendiente', 'Sin contingencias registradas'
);

-- 2.8 Insertar Indicadores de Mercado (Últimos 18 meses)
INSERT INTO URBANOVA_SCHEMA.INDICADORES_MERCADO
SELECT
    ROW_NUMBER() OVER (ORDER BY NULL) AS INDICADOR_ID,
    mes_referencia,
    tasa_interes_hipotecario,
    inflacion_anual_pct,
    tipo_cambio_usd_mxn,
    precio_cemento_ton,
    precio_acero_ton,
    indice_confianza_consumidor,
    pib_construccion_var_pct,
    permisos_construccion_total,
    creditos_hipotecarios_otorgados,
    comentario
FROM (
    -- 2023
    SELECT '2023-05-01'::DATE AS mes_referencia, 10.80 AS tasa_interes_hipotecario, 5.84 AS inflacion_anual_pct, 17.45 AS tipo_cambio_usd_mxn, 2850.00 AS precio_cemento_ton, 18500.00 AS precio_acero_ton, 47.2 AS indice_confianza_consumidor, 2.3 AS pib_construccion_var_pct, 12500 AS permisos_construccion_total, 28400 AS creditos_hipotecarios_otorgados, 'Mercado estable, inflación controlada' AS comentario UNION ALL
    SELECT '2023-06-01'::DATE, 10.75, 5.06, 17.20, 2820.00, 18200.00, 47.8, 2.5, 13200, 29100, 'Incremento en permisos de construcción' UNION ALL
    SELECT '2023-07-01'::DATE, 10.65, 4.87, 16.95, 2800.00, 17950.00, 48.1, 2.8, 14100, 30200, 'Tendencia positiva en sector construcción' UNION ALL
    SELECT '2023-08-01'::DATE, 10.55, 4.64, 16.88, 2780.00, 17800.00, 48.5, 3.1, 14800, 31500, 'Mejora en confianza del consumidor' UNION ALL
    SELECT '2023-09-01'::DATE, 10.50, 4.45, 17.05, 2790.00, 17900.00, 48.9, 3.2, 15200, 32100, 'Auge en créditos hipotecarios' UNION ALL
    SELECT '2023-10-01'::DATE, 10.45, 4.26, 17.35, 2850.00, 18300.00, 49.1, 3.0, 15500, 33000, 'Ligero aumento en precios de insumos' UNION ALL
    SELECT '2023-11-01'::DATE, 10.40, 4.32, 17.48, 2880.00, 18600.00, 48.7, 2.8, 14900, 31800, 'Fin de año con mercado activo' UNION ALL
    SELECT '2023-12-01'::DATE, 10.35, 4.66, 17.12, 2900.00, 18800.00, 48.3, 2.5, 13800, 29500, 'Cierre de año, desaceleración típica' UNION ALL
    
    -- 2024
    SELECT '2024-01-01'::DATE, 10.30, 4.88, 17.02, 2920.00, 19000.00, 47.9, 2.2, 12100, 27600, 'Inicio de año con cautela' UNION ALL
    SELECT '2024-02-01'::DATE, 10.28, 4.98, 17.15, 2940.00, 19200.00, 47.5, 2.1, 11800, 26900, 'Mes corto, actividad moderada' UNION ALL
    SELECT '2024-03-01'::DATE, 10.25, 4.42, 16.82, 2880.00, 18950.00, 48.2, 2.4, 13500, 28800, 'Recuperación en Q1' UNION ALL
    SELECT '2024-04-01'::DATE, 10.20, 4.65, 16.71, 2850.00, 18700.00, 48.6, 2.7, 14200, 30100, 'Primavera con buen ritmo' UNION ALL
    SELECT '2024-05-01'::DATE, 10.15, 4.69, 16.88, 2830.00, 18550.00, 49.0, 3.0, 15100, 31400, 'Mayo activo en desarrollos' UNION ALL
    SELECT '2024-06-01'::DATE, 10.12, 4.98, 18.12, 2950.00, 19100.00, 48.2, 2.6, 14600, 30500, 'Volatilidad cambiaria, elecciones' UNION ALL
    SELECT '2024-07-01'::DATE, 10.10, 5.57, 18.45, 3020.00, 19800.00, 47.6, 2.2, 13900, 29200, 'Post elecciones, ajuste de mercado' UNION ALL
    SELECT '2024-08-01'::DATE, 10.08, 5.15, 19.20, 3150.00, 20500.00, 46.8, 1.9, 13200, 28100, 'Depreciación del peso, insumos caros' UNION ALL
    SELECT '2024-09-01'::DATE, 10.05, 4.66, 19.85, 3280.00, 21200.00, 46.2, 1.5, 12800, 27300, 'Septiembre con presiones inflacionarias' UNION ALL
    SELECT '2024-10-01'::DATE, 10.02, 4.58, 19.62, 3250.00, 21000.00, 46.5, 1.7, 13100, 27800, 'Estabilización gradual del mercado'
);

-- ============================================================================
-- Sección 3: La Demo (Consultas que demuestran valor)
-- ============================================================================

-- ANÁLISIS 1: Precio promedio por m² por ciudad y tipo de propiedad
-- Caso de Uso: Benchmarking de precios para estrategia comercial
SELECT 
    c.NOMBRE_CIUDAD,
    p.TIPO_PROPIEDAD,
    COUNT(p.PROPIEDAD_ID) AS TOTAL_UNIDADES,
    ROUND(AVG(p.PRECIO_M2_MXN), 2) AS PRECIO_M2_PROMEDIO,
    ROUND(MIN(p.PRECIO_M2_MXN), 2) AS PRECIO_M2_MINIMO,
    ROUND(MAX(p.PRECIO_M2_MXN), 2) AS PRECIO_M2_MAXIMO,
    ROUND(AVG(p.PRECIO_LISTA_MXN), 0) AS PRECIO_PROMEDIO_UNIDAD
FROM URBANOVA_SCHEMA.PROPIEDADES p
INNER JOIN URBANOVA_SCHEMA.DESARROLLOS d ON p.DESARROLLO_ID = d.DESARROLLO_ID
INNER JOIN URBANOVA_SCHEMA.CIUDADES c ON d.CIUDAD_ID = c.CIUDAD_ID
WHERE p.ESTATUS_INVENTARIO IN ('Disponible', 'Apartado')
GROUP BY c.NOMBRE_CIUDAD, p.TIPO_PROPIEDAD
ORDER BY c.NOMBRE_CIUDAD, PRECIO_M2_PROMEDIO DESC;

-- ANÁLISIS 2: Inventario disponible por desarrollo
-- Caso de Uso: Control de disponibilidad y velocidad de ventas
SELECT 
    d.NOMBRE_DESARROLLO,
    c.NOMBRE_CIUDAD,
    d.TOTAL_UNIDADES,
    SUM(CASE WHEN p.ESTATUS_INVENTARIO = 'Disponible' THEN 1 ELSE 0 END) AS UNIDADES_DISPONIBLES,
    SUM(CASE WHEN p.ESTATUS_INVENTARIO = 'Apartado' THEN 1 ELSE 0 END) AS UNIDADES_APARTADAS,
    SUM(CASE WHEN p.ESTATUS_INVENTARIO = 'Vendido' THEN 1 ELSE 0 END) AS UNIDADES_VENDIDAS,
    SUM(CASE WHEN p.ESTATUS_INVENTARIO = 'Escriturado' THEN 1 ELSE 0 END) AS UNIDADES_ESCRITURADAS,
    ROUND(
        (SUM(CASE WHEN p.ESTATUS_INVENTARIO IN ('Vendido', 'Escriturado') THEN 1 ELSE 0 END) * 100.0) / d.TOTAL_UNIDADES, 
        2
    ) AS PORCENTAJE_VENDIDO,
    d.ESTATUS AS ESTATUS_DESARROLLO
FROM URBANOVA_SCHEMA.DESARROLLOS d
INNER JOIN URBANOVA_SCHEMA.CIUDADES c ON d.CIUDAD_ID = c.CIUDAD_ID
LEFT JOIN URBANOVA_SCHEMA.PROPIEDADES p ON d.DESARROLLO_ID = p.DESARROLLO_ID
GROUP BY 
    d.NOMBRE_DESARROLLO, 
    c.NOMBRE_CIUDAD, 
    d.TOTAL_UNIDADES, 
    d.ESTATUS
ORDER BY PORCENTAJE_VENDIDO DESC;

-- ANÁLISIS 3: Desempeño de ventas por agente
-- Caso de Uso: Evaluación de desempeño del equipo comercial
SELECT 
    a.NOMBRE_COMPLETO AS AGENTE,
    c.NOMBRE_CIUDAD AS CIUDAD_BASE,
    COUNT(v.VENTA_ID) AS TOTAL_VENTAS,
    ROUND(SUM(v.PRECIO_VENTA_MXN), 0) AS INGRESOS_TOTALES_MXN,
    ROUND(AVG(v.PRECIO_VENTA_MXN), 0) AS TICKET_PROMEDIO_MXN,
    ROUND(AVG(v.DESCUENTO_APLICADO_PCT), 2) AS DESCUENTO_PROMEDIO_PCT
FROM URBANOVA_SCHEMA.AGENTES a
INNER JOIN URBANOVA_SCHEMA.CIUDADES c ON a.CIUDAD_BASE = c.CIUDAD_ID
LEFT JOIN URBANOVA_SCHEMA.VENTAS v ON a.AGENTE_ID = v.AGENTE_ID
WHERE a.ESTATUS = 'Activo'
GROUP BY a.NOMBRE_COMPLETO, c.NOMBRE_CIUDAD
ORDER BY INGRESOS_TOTALES_MXN DESC NULLS LAST;

-- ANÁLISIS 4: Análisis de métodos de financiamiento
-- Caso de Uso: Estrategia financiera y alianzas con instituciones
SELECT 
    v.METODO_FINANCIAMIENTO,
    COUNT(v.VENTA_ID) AS NUMERO_OPERACIONES,
    ROUND(SUM(v.PRECIO_VENTA_MXN), 0) AS MONTO_TOTAL_MXN,
    ROUND(AVG(v.PRECIO_VENTA_MXN), 0) AS TICKET_PROMEDIO_MXN,
    ROUND(AVG(v.ENGANCHE_MXN), 0) AS ENGANCHE_PROMEDIO_MXN,
    ROUND(AVG(v.MESES_FINANCIAMIENTO), 0) AS PLAZO_PROMEDIO_MESES,
    ROUND(
        (COUNT(v.VENTA_ID) * 100.0) / (SELECT COUNT(*) FROM URBANOVA_SCHEMA.VENTAS),
        2
    ) AS PORCENTAJE_DEL_TOTAL
FROM URBANOVA_SCHEMA.VENTAS v
GROUP BY v.METODO_FINANCIAMIENTO
ORDER BY NUMERO_OPERACIONES DESC;

-- ANÁLISIS 5: Proyecciones vs Reales - Análisis de Precisión
-- Caso de Uso: Validar precisión de forecast y ajustar proyecciones futuras
SELECT 
    d.NOMBRE_DESARROLLO,
    pv.MES_PROYECCION,
    pv.UNIDADES_PROYECTADAS,
    pv.UNIDADES_REALES,
    pv.VARIACION_UNIDADES,
    CASE 
        WHEN pv.UNIDADES_REALES IS NOT NULL THEN
            ROUND((pv.VARIACION_UNIDADES * 100.0) / pv.UNIDADES_PROYECTADAS, 2)
        ELSE NULL
    END AS VARIACION_PORCENTUAL,
    ROUND(pv.INGRESOS_PROYECTADOS_MXN, 0) AS INGRESOS_PROYECTADOS,
    ROUND(pv.INGRESOS_REALES_MXN, 0) AS INGRESOS_REALES,
    ROUND(pv.VARIACION_INGRESOS_MXN, 0) AS VARIACION_INGRESOS,
    CASE
        WHEN pv.UNIDADES_REALES IS NULL THEN 'Pendiente'
        WHEN pv.VARIACION_UNIDADES >= 0 THEN 'Cumplido'
        ELSE 'Por Debajo'
    END AS ESTATUS_CUMPLIMIENTO
FROM URBANOVA_SCHEMA.PROYECCIONES_VENTAS pv
INNER JOIN URBANOVA_SCHEMA.DESARROLLOS d ON pv.DESARROLLO_ID = d.DESARROLLO_ID
ORDER BY pv.MES_PROYECCION DESC, d.NOMBRE_DESARROLLO;

-- ANÁLISIS 6: Top 10 propiedades más caras disponibles
-- Caso de Uso: Catálogo de propiedades premium para clientes VIP
SELECT 
    p.PROPIEDAD_ID,
    d.NOMBRE_DESARROLLO,
    c.NOMBRE_CIUDAD,
    p.TIPO_PROPIEDAD,
    p.NUMERO_UNIDAD,
    p.SUPERFICIE_M2,
    p.RECAMARAS,
    p.BANOS,
    p.ESTACIONAMIENTOS,
    ROUND(p.PRECIO_LISTA_MXN, 0) AS PRECIO_MXN,
    ROUND(p.PRECIO_M2_MXN, 2) AS PRECIO_M2_MXN,
    p.COMENTARIO
FROM URBANOVA_SCHEMA.PROPIEDADES p
INNER JOIN URBANOVA_SCHEMA.DESARROLLOS d ON p.DESARROLLO_ID = d.DESARROLLO_ID
INNER JOIN URBANOVA_SCHEMA.CIUDADES c ON d.CIUDAD_ID = c.CIUDAD_ID
WHERE p.ESTATUS_INVENTARIO = 'Disponible'
ORDER BY p.PRECIO_LISTA_MXN DESC
LIMIT 10;

-- ANÁLISIS 7: Evolución temporal de ventas (últimos 6 meses)
-- Caso de Uso: Tendencias de mercado y estacionalidad
SELECT 
    DATE_TRUNC('MONTH', v.FECHA_VENTA) AS MES,
    COUNT(v.VENTA_ID) AS UNIDADES_VENDIDAS,
    ROUND(SUM(v.PRECIO_VENTA_MXN), 0) AS INGRESOS_TOTALES_MXN,
    ROUND(AVG(v.PRECIO_VENTA_MXN), 0) AS TICKET_PROMEDIO_MXN,
    COUNT(DISTINCT d.DESARROLLO_ID) AS DESARROLLOS_CON_VENTAS
FROM URBANOVA_SCHEMA.VENTAS v
INNER JOIN URBANOVA_SCHEMA.PROPIEDADES p ON v.PROPIEDAD_ID = p.PROPIEDAD_ID
INNER JOIN URBANOVA_SCHEMA.DESARROLLOS d ON p.DESARROLLO_ID = d.DESARROLLO_ID
WHERE v.FECHA_VENTA >= DATEADD('MONTH', -6, CURRENT_DATE())
GROUP BY DATE_TRUNC('MONTH', v.FECHA_VENTA)
ORDER BY MES DESC;

-- ANÁLISIS 8: Tipo de cliente y comportamiento de compra
-- Caso de Uso: Segmentación de mercado para marketing dirigido
SELECT 
    v.TIPO_CLIENTE,
    c.NOMBRE_CIUDAD,
    COUNT(v.VENTA_ID) AS NUMERO_COMPRAS,
    ROUND(AVG(v.PRECIO_VENTA_MXN), 0) AS TICKET_PROMEDIO_MXN,
    ROUND(AVG(v.ENGANCHE_MXN * 100.0 / v.PRECIO_VENTA_MXN), 2) AS ENGANCHE_PROMEDIO_PCT,
    v.METODO_FINANCIAMIENTO AS METODO_MAS_USADO
FROM URBANOVA_SCHEMA.VENTAS v
INNER JOIN URBANOVA_SCHEMA.PROPIEDADES p ON v.PROPIEDAD_ID = p.PROPIEDAD_ID
INNER JOIN URBANOVA_SCHEMA.DESARROLLOS d ON p.DESARROLLO_ID = d.DESARROLLO_ID
INNER JOIN URBANOVA_SCHEMA.CIUDADES c ON d.CIUDAD_ID = c.CIUDAD_ID
GROUP BY v.TIPO_CLIENTE, c.NOMBRE_CIUDAD, v.METODO_FINANCIAMIENTO
ORDER BY v.TIPO_CLIENTE, NUMERO_COMPRAS DESC;

-- ANÁLISIS 9: Rentabilidad por Desarrollo (Costos vs Ingresos Proyectados)
-- Caso de Uso: Análisis de márgenes y rentabilidad por proyecto
SELECT 
    d.NOMBRE_DESARROLLO,
    c.NOMBRE_CIUDAD,
    d.TOTAL_UNIDADES,
    ROUND(SUM(cc.MONTO_MXN), 0) AS COSTO_TOTAL_DESARROLLO_MXN,
    ROUND(AVG(p.PRECIO_LISTA_MXN), 0) AS PRECIO_PROMEDIO_UNIDAD,
    ROUND(AVG(p.PRECIO_LISTA_MXN) * d.TOTAL_UNIDADES, 0) AS INGRESOS_PROYECTADOS_TOTALES,
    ROUND((AVG(p.PRECIO_LISTA_MXN) * d.TOTAL_UNIDADES) - SUM(cc.MONTO_MXN), 0) AS UTILIDAD_BRUTA_PROYECTADA,
    ROUND(
        ((AVG(p.PRECIO_LISTA_MXN) * d.TOTAL_UNIDADES) - SUM(cc.MONTO_MXN)) * 100.0 / 
        (AVG(p.PRECIO_LISTA_MXN) * d.TOTAL_UNIDADES),
        2
    ) AS MARGEN_BRUTO_PCT,
    d.ESTATUS AS ESTATUS_DESARROLLO
FROM URBANOVA_SCHEMA.DESARROLLOS d
INNER JOIN URBANOVA_SCHEMA.CIUDADES c ON d.CIUDAD_ID = c.CIUDAD_ID
INNER JOIN URBANOVA_SCHEMA.COSTOS_CONSTRUCCION cc ON d.DESARROLLO_ID = cc.DESARROLLO_ID
LEFT JOIN URBANOVA_SCHEMA.PROPIEDADES p ON d.DESARROLLO_ID = p.DESARROLLO_ID
WHERE cc.DESARROLLO_ID IN (1, 2, 3, 4, 5, 6, 8, 11, 12) -- Desarrollos con datos de costos
GROUP BY 
    d.NOMBRE_DESARROLLO, 
    c.NOMBRE_CIUDAD, 
    d.TOTAL_UNIDADES, 
    d.ESTATUS
ORDER BY MARGEN_BRUTO_PCT DESC;

-- ANÁLISIS 10: Desglose de Costos por Tipo y Desarrollo
-- Caso de Uso: Identificar áreas de optimización de costos
SELECT 
    d.NOMBRE_DESARROLLO,
    c.NOMBRE_CIUDAD,
    cc.TIPO_COSTO,
    ROUND(SUM(cc.MONTO_MXN), 0) AS MONTO_TOTAL_MXN,
    ROUND(AVG(cc.PORCENTAJE_TOTAL), 2) AS PORCENTAJE_PROMEDIO,
    cc.ESTATUS_PAGO
FROM URBANOVA_SCHEMA.COSTOS_CONSTRUCCION cc
INNER JOIN URBANOVA_SCHEMA.DESARROLLOS d ON cc.DESARROLLO_ID = d.DESARROLLO_ID
INNER JOIN URBANOVA_SCHEMA.CIUDADES c ON d.CIUDAD_ID = c.CIUDAD_ID
GROUP BY 
    d.NOMBRE_DESARROLLO, 
    c.NOMBRE_CIUDAD, 
    cc.TIPO_COSTO,
    cc.ESTATUS_PAGO
ORDER BY d.NOMBRE_DESARROLLO, MONTO_TOTAL_MXN DESC;

-- ANÁLISIS 11: Indicadores Macroeconómicos y su Evolución
-- Caso de Uso: Entender el contexto de mercado para decisiones estratégicas
SELECT 
    MES_REFERENCIA,
    TASA_INTERES_HIPOTECARIO,
    INFLACION_ANUAL_PCT,
    ROUND(TIPO_CAMBIO_USD_MXN, 2) AS TIPO_CAMBIO,
    ROUND(PRECIO_CEMENTO_TON, 0) AS PRECIO_CEMENTO,
    ROUND(PRECIO_ACERO_TON, 0) AS PRECIO_ACERO,
    INDICE_CONFIANZA_CONSUMIDOR,
    PIB_CONSTRUCCION_VAR_PCT,
    CREDITOS_HIPOTECARIOS_OTORGADOS,
    COMENTARIO
FROM URBANOVA_SCHEMA.INDICADORES_MERCADO
ORDER BY MES_REFERENCIA DESC
LIMIT 12;

-- ANÁLISIS 12: Correlación entre Indicadores de Mercado y Ventas
-- Caso de Uso: Identificar variables externas que impactan las ventas
SELECT 
    DATE_TRUNC('MONTH', v.FECHA_VENTA) AS MES,
    COUNT(v.VENTA_ID) AS VENTAS_MES,
    ROUND(AVG(im.TASA_INTERES_HIPOTECARIO), 2) AS TASA_INTERES_PROMEDIO,
    ROUND(AVG(im.INFLACION_ANUAL_PCT), 2) AS INFLACION_PROMEDIO,
    ROUND(AVG(im.TIPO_CAMBIO_USD_MXN), 2) AS TIPO_CAMBIO_PROMEDIO,
    ROUND(AVG(im.INDICE_CONFIANZA_CONSUMIDOR), 1) AS CONFIANZA_CONSUMIDOR,
    ROUND(AVG(im.PRECIO_CEMENTO_TON), 0) AS PRECIO_CEMENTO_PROMEDIO,
    ROUND(AVG(v.PRECIO_VENTA_MXN), 0) AS TICKET_PROMEDIO_VENTAS
FROM URBANOVA_SCHEMA.VENTAS v
LEFT JOIN URBANOVA_SCHEMA.INDICADORES_MERCADO im 
    ON DATE_TRUNC('MONTH', v.FECHA_VENTA) = DATE_TRUNC('MONTH', im.MES_REFERENCIA)
GROUP BY DATE_TRUNC('MONTH', v.FECHA_VENTA)
ORDER BY MES DESC;

-- ANÁLISIS 13: Impacto de Costos de Insumos en Rentabilidad
-- Caso de Uso: Analizar cómo el aumento de precios de materiales afecta márgenes
SELECT 
    im.MES_REFERENCIA,
    ROUND(im.PRECIO_CEMENTO_TON, 0) AS PRECIO_CEMENTO,
    ROUND(im.PRECIO_ACERO_TON, 0) AS PRECIO_ACERO,
    ROUND(
        ((im.PRECIO_CEMENTO_TON - LAG(im.PRECIO_CEMENTO_TON) OVER (ORDER BY im.MES_REFERENCIA)) * 100.0) / 
        LAG(im.PRECIO_CEMENTO_TON) OVER (ORDER BY im.MES_REFERENCIA),
        2
    ) AS VAR_PCT_CEMENTO,
    ROUND(
        ((im.PRECIO_ACERO_TON - LAG(im.PRECIO_ACERO_TON) OVER (ORDER BY im.MES_REFERENCIA)) * 100.0) / 
        LAG(im.PRECIO_ACERO_TON) OVER (ORDER BY im.MES_REFERENCIA),
        2
    ) AS VAR_PCT_ACERO,
    im.PIB_CONSTRUCCION_VAR_PCT,
    im.COMENTARIO
FROM URBANOVA_SCHEMA.INDICADORES_MERCADO im
ORDER BY im.MES_REFERENCIA DESC
LIMIT 12;

-- ANÁLISIS 14: Resumen Financiero Ejecutivo por Desarrollo
-- Caso de Uso: Dashboard ejecutivo de rentabilidad y avance
SELECT 
    d.NOMBRE_DESARROLLO,
    c.NOMBRE_CIUDAD,
    d.ESTATUS,
    d.TOTAL_UNIDADES,
    COUNT(DISTINCT p.PROPIEDAD_ID) AS UNIDADES_REGISTRADAS,
    SUM(CASE WHEN p.ESTATUS_INVENTARIO IN ('Vendido', 'Escriturado') THEN 1 ELSE 0 END) AS UNIDADES_VENDIDAS,
    ROUND(SUM(cc.MONTO_MXN), 0) AS INVERSION_TOTAL_MXN,
    ROUND(SUM(CASE WHEN v.VENTA_ID IS NOT NULL THEN v.PRECIO_VENTA_MXN ELSE 0 END), 0) AS INGRESOS_REALES_MXN,
    ROUND(
        (SUM(CASE WHEN p.ESTATUS_INVENTARIO IN ('Vendido', 'Escriturado') THEN 1 ELSE 0 END) * 100.0) / 
        d.TOTAL_UNIDADES,
        2
    ) AS AVANCE_VENTAS_PCT,
    ROUND(
        SUM(CASE WHEN v.VENTA_ID IS NOT NULL THEN v.PRECIO_VENTA_MXN ELSE 0 END) - SUM(cc.MONTO_MXN),
        0
    ) AS RESULTADO_ACTUAL_MXN,
    CASE
        WHEN SUM(CASE WHEN v.VENTA_ID IS NOT NULL THEN v.PRECIO_VENTA_MXN ELSE 0 END) > SUM(cc.MONTO_MXN) 
        THEN 'Rentable'
        WHEN SUM(CASE WHEN v.VENTA_ID IS NOT NULL THEN v.PRECIO_VENTA_MXN ELSE 0 END) = 0
        THEN 'Sin Ventas'
        ELSE 'En Recuperación'
    END AS ESTATUS_FINANCIERO
FROM URBANOVA_SCHEMA.DESARROLLOS d
INNER JOIN URBANOVA_SCHEMA.CIUDADES c ON d.CIUDAD_ID = c.CIUDAD_ID
LEFT JOIN URBANOVA_SCHEMA.PROPIEDADES p ON d.DESARROLLO_ID = p.DESARROLLO_ID
LEFT JOIN URBANOVA_SCHEMA.COSTOS_CONSTRUCCION cc ON d.DESARROLLO_ID = cc.DESARROLLO_ID
LEFT JOIN URBANOVA_SCHEMA.VENTAS v ON p.PROPIEDAD_ID = v.PROPIEDAD_ID
WHERE cc.DESARROLLO_ID IS NOT NULL  -- Solo desarrollos con registro de costos
GROUP BY 
    d.NOMBRE_DESARROLLO,
    c.NOMBRE_CIUDAD,
    d.ESTATUS,
    d.TOTAL_UNIDADES
ORDER BY RESULTADO_ACTUAL_MXN DESC;

-- ============================================================================
-- Sección 4: Queries de Diagnóstico y Validación
-- ============================================================================

-- DIAGNÓSTICO 1: Conteo de registros por tabla
SELECT 'CIUDADES' AS TABLA, COUNT(*) AS TOTAL_REGISTROS FROM URBANOVA_SCHEMA.CIUDADES
UNION ALL
SELECT 'DESARROLLOS', COUNT(*) FROM URBANOVA_SCHEMA.DESARROLLOS
UNION ALL
SELECT 'PROPIEDADES', COUNT(*) FROM URBANOVA_SCHEMA.PROPIEDADES
UNION ALL
SELECT 'AGENTES', COUNT(*) FROM URBANOVA_SCHEMA.AGENTES
UNION ALL
SELECT 'VENTAS', COUNT(*) FROM URBANOVA_SCHEMA.VENTAS
UNION ALL
SELECT 'PROYECCIONES_VENTAS', COUNT(*) FROM URBANOVA_SCHEMA.PROYECCIONES_VENTAS
UNION ALL
SELECT 'COSTOS_CONSTRUCCION', COUNT(*) FROM URBANOVA_SCHEMA.COSTOS_CONSTRUCCION
UNION ALL
SELECT 'INDICADORES_MERCADO', COUNT(*) FROM URBANOVA_SCHEMA.INDICADORES_MERCADO;

-- DIAGNÓSTICO 2: Rangos de precios por ciudad
SELECT 
    c.NOMBRE_CIUDAD,
    COUNT(p.PROPIEDAD_ID) AS TOTAL_PROPIEDADES,
    ROUND(MIN(p.PRECIO_LISTA_MXN), 0) AS PRECIO_MINIMO,
    ROUND(MAX(p.PRECIO_LISTA_MXN), 0) AS PRECIO_MAXIMO,
    ROUND(AVG(p.PRECIO_LISTA_MXN), 0) AS PRECIO_PROMEDIO,
    ROUND(MIN(p.PRECIO_M2_MXN), 2) AS PRECIO_M2_MINIMO,
    ROUND(MAX(p.PRECIO_M2_MXN), 2) AS PRECIO_M2_MAXIMO,
    ROUND(AVG(p.PRECIO_M2_MXN), 2) AS PRECIO_M2_PROMEDIO
FROM URBANOVA_SCHEMA.PROPIEDADES p
INNER JOIN URBANOVA_SCHEMA.DESARROLLOS d ON p.DESARROLLO_ID = d.DESARROLLO_ID
INNER JOIN URBANOVA_SCHEMA.CIUDADES c ON d.CIUDAD_ID = c.CIUDAD_ID
GROUP BY c.NOMBRE_CIUDAD
ORDER BY PRECIO_M2_PROMEDIO DESC;

-- DIAGNÓSTICO 3: Distribución de estatus de inventario
SELECT 
    ESTATUS_INVENTARIO,
    COUNT(*) AS TOTAL_UNIDADES,
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM URBANOVA_SCHEMA.PROPIEDADES), 2) AS PORCENTAJE
FROM URBANOVA_SCHEMA.PROPIEDADES
GROUP BY ESTATUS_INVENTARIO
ORDER BY TOTAL_UNIDADES DESC;

-- DIAGNÓSTICO 4: Verificar integridad referencial
SELECT 
    'Propiedades sin desarrollo' AS VALIDACION,
    COUNT(*) AS REGISTROS_CON_PROBLEMA
FROM URBANOVA_SCHEMA.PROPIEDADES p
LEFT JOIN URBANOVA_SCHEMA.DESARROLLOS d ON p.DESARROLLO_ID = d.DESARROLLO_ID
WHERE d.DESARROLLO_ID IS NULL

UNION ALL

SELECT 
    'Desarrollos sin ciudad',
    COUNT(*)
FROM URBANOVA_SCHEMA.DESARROLLOS d
LEFT JOIN URBANOVA_SCHEMA.CIUDADES c ON d.CIUDAD_ID = c.CIUDAD_ID
WHERE c.CIUDAD_ID IS NULL

UNION ALL

SELECT 
    'Ventas sin propiedad',
    COUNT(*)
FROM URBANOVA_SCHEMA.VENTAS v
LEFT JOIN URBANOVA_SCHEMA.PROPIEDADES p ON v.PROPIEDAD_ID = p.PROPIEDAD_ID
WHERE p.PROPIEDAD_ID IS NULL;

-- DIAGNÓSTICO 5: FinOps - Verificar configuración de timeout
SHOW PARAMETERS LIKE 'STATEMENT_TIMEOUT_IN_SECONDS' IN WAREHOUSE URBANOVA_WH;

-- DIAGNÓSTICO 6: Monitoreo de costos - Uso del Warehouse
SELECT 
    WAREHOUSE_NAME,
    AVG(CASE WHEN EXECUTION_STATUS = 'SUCCESS' THEN TOTAL_ELAPSED_TIME ELSE NULL END) / 1000 AS AVG_QUERY_TIME_SECONDS,
    COUNT(*) AS TOTAL_QUERIES
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE WAREHOUSE_NAME = 'URBANOVA_WH'
    AND START_TIME >= DATEADD('DAY', -7, CURRENT_DATE())
GROUP BY WAREHOUSE_NAME;

-- ============================================================================
-- Sección 5: Gestión de Proveedores de Materiales y Servicios
-- ============================================================================

-- 5.1 Tabla: Proveedores de Materiales y Servicios
CREATE OR REPLACE TABLE URBANOVA_SCHEMA.PROVEEDORES (
    PROVEEDOR_ID NUMBER(10,0) PRIMARY KEY,
    RAZON_SOCIAL VARCHAR(200) NOT NULL,
    NOMBRE_COMERCIAL VARCHAR(150),
    RFC VARCHAR(13) NOT NULL,
    CATEGORIA VARCHAR(50) NOT NULL, -- Albañilería, Pintura, Plomería, Mantenimiento, Electricidad, Acabados
    ESPECIALIDAD VARCHAR(100),
    DIRECCION VARCHAR(300),
    CIUDAD_ID NUMBER(10,0),
    TELEFONO VARCHAR(20),
    EMAIL VARCHAR(100),
    CONTACTO_PRINCIPAL VARCHAR(100),
    DIAS_CREDITO NUMBER(3,0),
    LIMITE_CREDITO_MXN NUMBER(15,2),
    CALIFICACION_PROVEEDOR NUMBER(3,1), -- 1.0 a 5.0
    ESTATUS VARCHAR(30), -- Activo, Suspendido, Inactivo
    FECHA_ALTA DATE,
    COMENTARIO VARCHAR(500),
    FOREIGN KEY (CIUDAD_ID) REFERENCES URBANOVA_SCHEMA.CIUDADES(CIUDAD_ID)
);

-- 5.2 Tabla: Catálogo de Materiales
CREATE OR REPLACE TABLE URBANOVA_SCHEMA.CATALOGO_MATERIALES (
    MATERIAL_ID NUMBER(10,0) PRIMARY KEY,
    PROVEEDOR_ID NUMBER(10,0) NOT NULL,
    CODIGO_SKU VARCHAR(30),
    DESCRIPCION VARCHAR(200) NOT NULL,
    CATEGORIA VARCHAR(50), -- Albañilería, Pintura, Plomería, Mantenimiento, Electricidad
    UNIDAD_MEDIDA VARCHAR(20), -- Pieza, Kg, M², M³, Litro, Metro, Bulto, Cubeta
    PRECIO_UNITARIO_MXN NUMBER(12,2),
    IVA_INCLUIDO BOOLEAN DEFAULT FALSE,
    TIEMPO_ENTREGA_DIAS NUMBER(3,0),
    STOCK_MINIMO NUMBER(10,0),
    ESTATUS VARCHAR(30), -- Disponible, Agotado, Descontinuado
    COMENTARIO VARCHAR(500),
    FOREIGN KEY (PROVEEDOR_ID) REFERENCES URBANOVA_SCHEMA.PROVEEDORES(PROVEEDOR_ID)
);

-- 5.3 Tabla: Órdenes de Compra
CREATE OR REPLACE TABLE URBANOVA_SCHEMA.ORDENES_COMPRA (
    ORDEN_ID NUMBER(10,0) PRIMARY KEY,
    PROVEEDOR_ID NUMBER(10,0) NOT NULL,
    DESARROLLO_ID NUMBER(10,0) NOT NULL,
    NUMERO_ORDEN VARCHAR(20) NOT NULL,
    FECHA_ORDEN DATE NOT NULL,
    FECHA_ENTREGA_ESPERADA DATE,
    FECHA_ENTREGA_REAL DATE,
    SUBTOTAL_MXN NUMBER(15,2),
    IVA_MXN NUMBER(15,2),
    TOTAL_MXN NUMBER(15,2),
    ESTATUS_ORDEN VARCHAR(50), -- Solicitada, Aprobada, Enviada, Recibida, Cancelada
    ESTATUS_PAGO VARCHAR(50), -- Pendiente, Parcial, Pagado
    COMENTARIO VARCHAR(500),
    FOREIGN KEY (PROVEEDOR_ID) REFERENCES URBANOVA_SCHEMA.PROVEEDORES(PROVEEDOR_ID),
    FOREIGN KEY (DESARROLLO_ID) REFERENCES URBANOVA_SCHEMA.DESARROLLOS(DESARROLLO_ID)
);

-- 5.4 Tabla: Solicitudes de Reparación/Mantenimiento
CREATE OR REPLACE TABLE URBANOVA_SCHEMA.SOLICITUDES_REPARACION (
    SOLICITUD_ID NUMBER(10,0) PRIMARY KEY,
    PROPIEDAD_ID NUMBER(10,0) NOT NULL,
    NUMERO_SOLICITUD VARCHAR(20) NOT NULL,
    FECHA_SOLICITUD DATE NOT NULL,
    TIPO_REPARACION VARCHAR(100), -- Plomería, Electricidad, Pintura, Carpintería, etc.
    PRIORIDAD VARCHAR(20), -- Alta, Media, Baja
    DESCRIPCION_PROBLEMA VARCHAR(1000),
    PROVEEDOR_ASIGNADO_ID NUMBER(10,0),
    FECHA_ATENCION DATE,
    FECHA_CIERRE DATE,
    COSTO_REPARACION_MXN NUMBER(12,2),
    ESTATUS VARCHAR(50), -- Abierta, En Proceso, Cerrada, Cancelada
    CALIFICACION_SERVICIO NUMBER(2,1), -- 1.0 a 5.0
    COMENTARIO VARCHAR(500),
    FOREIGN KEY (PROPIEDAD_ID) REFERENCES URBANOVA_SCHEMA.PROPIEDADES(PROPIEDAD_ID),
    FOREIGN KEY (PROVEEDOR_ASIGNADO_ID) REFERENCES URBANOVA_SCHEMA.PROVEEDORES(PROVEEDOR_ID)
);

-- ============================================================================
-- Sección 5.5: Datos Sintéticos de Proveedores
-- ============================================================================

-- Insertar Proveedores de Materiales y Servicios
INSERT INTO URBANOVA_SCHEMA.PROVEEDORES 
SELECT
    ROW_NUMBER() OVER (ORDER BY NULL) AS PROVEEDOR_ID,
    razon_social,
    nombre_comercial,
    rfc,
    categoria,
    especialidad,
    direccion,
    ciudad_id,
    telefono,
    email,
    contacto_principal,
    dias_credito,
    limite_credito,
    calificacion,
    estatus,
    fecha_alta,
    comentario
FROM (
    -- PROVEEDORES DE ALBAÑILERÍA
    SELECT 
        'Materiales de Construcción del Centro S.A. de C.V.' AS razon_social,
        'MatCentro' AS nombre_comercial,
        'MCC850623HG7' AS rfc,
        'Albañilería' AS categoria,
        'Cemento, Arena, Grava, Block' AS especialidad,
        'Av. Insurgentes Sur 1234, Col. Del Valle' AS direccion,
        1 AS ciudad_id,
        '5555123456' AS telefono,
        'ventas@matcentro.mx' AS email,
        'Ing. Roberto Mendoza' AS contacto_principal,
        30 AS dias_credito,
        2000000.00 AS limite_credito,
        4.5 AS calificacion,
        'Activo' AS estatus,
        '2018-03-15'::DATE AS fecha_alta,
        'Proveedor principal de materiales básicos de construcción' AS comentario
    UNION ALL
    SELECT 'Cementos y Agregados del Norte S.A. de C.V.', 'CemNorte', 'CAN910415XY9', 'Albañilería', 'Cemento Premium y Morteros', 'Av. Constitución 890, Centro', 2, '8181234567', 'ventas@cemnorte.mx', 'Lic. Patricia Garza', 45, 3000000.00, 4.7, 'Activo', '2017-06-20'::DATE, 'Especialista en cemento de alta resistencia'
    UNION ALL
    SELECT 'Blocks y Prefabricados Querétaro S.A. de C.V.', 'BlockQro', 'BPQ880912AB1', 'Albañilería', 'Block, Adoquín, Prefabricados', 'Carretera 57 Km 12, Zona Industrial', 4, '4421987654', 'contacto@blockqro.mx', 'Arq. Miguel Ángel Ruiz', 30, 1500000.00, 4.3, 'Activo', '2019-01-10'::DATE, 'Fabricante de prefabricados de concreto'
    UNION ALL
    SELECT 'Materiales Pérez Hermanos S.A.', 'Pérez Hnos', 'MPH760305CD2', 'Albañilería', 'Materiales generales', 'Calle 60 #234, Centro', 5, '9999876543', 'pedidos@perezhnos.mx', 'Sr. Joaquín Pérez', 15, 800000.00, 4.0, 'Activo', '2015-09-05'::DATE, 'Proveedor tradicional de la región'
    
    -- PROVEEDORES DE PINTURA
    UNION ALL
    SELECT 'Pinturas y Recubrimientos Nacionales S.A. de C.V.', 'PintuNac', 'PRN920708EF3', 'Pintura', 'Pinturas vinílicas, esmaltes, impermeabilizantes', 'Av. Revolución 567, Col. Mixcoac', 1, '5556789012', 'ventas@pintunac.mx', 'Ing. Laura Castillo', 30, 1500000.00, 4.6, 'Activo', '2016-04-12'::DATE, 'Distribuidor autorizado de marcas premium'
    UNION ALL
    SELECT 'Comex Guadalajara Distribución S.A. de C.V.', 'Comex GDL', 'CGD870520GH4', 'Pintura', 'Línea completa Comex', 'Av. López Mateos 2345, Zona Industrial', 3, '3333456789', 'distribuidora@comexgdl.mx', 'Lic. Fernando Ochoa', 45, 2500000.00, 4.8, 'Activo', '2014-11-22'::DATE, 'Distribuidor exclusivo Comex región occidente'
    UNION ALL
    SELECT 'Impermeabilizantes del Sureste S.A. de C.V.', 'ImperSur', 'IDS940315IJ5', 'Pintura', 'Impermeabilizantes y selladores', 'Av. Tulum 890, Zona Hotelera', 6, '9981234567', 'ventas@impersur.mx', 'Ing. Carlos Medina', 30, 1000000.00, 4.4, 'Activo', '2020-02-28'::DATE, 'Especialistas en impermeabilización para clima tropical'
    UNION ALL
    SELECT 'Acabados y Texturas Monterrey S.A. de C.V.', 'AcabTex', 'ATM900812KL6', 'Pintura', 'Texturas, tirol, pastas', 'Av. Ruiz Cortines 456, San Nicolás', 2, '8187654321', 'contacto@acabtex.mx', 'Arq. Diana Villarreal', 30, 1200000.00, 4.2, 'Activo', '2018-07-15'::DATE, 'Especialistas en acabados arquitectónicos'
    
    -- PROVEEDORES DE PLOMERÍA
    UNION ALL
    SELECT 'Plomería Industrial de México S.A. de C.V.', 'PlomerInd', 'PIM880625MN7', 'Plomería', 'Tubería PVC, cobre, conexiones', 'Av. Central 789, Parque Industrial', 1, '5553456789', 'ventas@plomerind.mx', 'Ing. Raúl Domínguez', 30, 1800000.00, 4.5, 'Activo', '2015-03-10'::DATE, 'Distribuidor mayorista de materiales de plomería'
    UNION ALL
    SELECT 'Hidráulica y Sanitarios del Bajío S.A. de C.V.', 'HidroSan', 'HSB910930OP8', 'Plomería', 'Sistemas hidráulicos y sanitarios', 'Blvd. Bernardo Quintana 234, Centro', 4, '4423214567', 'ventas@hidrosan.mx', 'Ing. Alejandra Vega', 45, 2200000.00, 4.7, 'Activo', '2016-08-20'::DATE, 'Especialistas en sistemas hidráulicos residenciales'
    UNION ALL
    SELECT 'Materiales Sanitarios Premium S.A. de C.V.', 'SaniPrem', 'MSP950412QR9', 'Plomería', 'Muebles de baño, grifería premium', 'Av. Chapultepec 567, Col. Americana', 3, '3336547890', 'premium@saniprem.mx', 'Lic. Roberto Silva', 30, 3000000.00, 4.8, 'Activo', '2019-05-15'::DATE, 'Distribuidor de marcas de lujo en sanitarios'
    UNION ALL
    SELECT 'Válvulas y Conexiones del Norte S.A. de C.V.', 'ValvuNor', 'VCN870218ST0', 'Plomería', 'Válvulas industriales, bombas', 'Av. Fundidora 123, Centro', 2, '8189876543', 'ventas@valvunor.mx', 'Ing. Francisco Torres', 30, 1500000.00, 4.3, 'Activo', '2017-10-08'::DATE, 'Especialistas en válvulas y sistemas de bombeo'
    
    -- PROVEEDORES DE MANTENIMIENTO
    UNION ALL
    SELECT 'Servicios Integrales de Mantenimiento S.A. de C.V.', 'ServiMan', 'SIM920815UV1', 'Mantenimiento', 'Mantenimiento preventivo y correctivo', 'Calle Durango 234, Col. Roma', 1, '5557890123', 'servicios@serviman.mx', 'Ing. Marco Antonio López', 15, 1000000.00, 4.4, 'Activo', '2018-01-20'::DATE, 'Servicios de mantenimiento integral para desarrollos'
    UNION ALL
    SELECT 'Mantenimiento Profesional Regio S.A. de C.V.', 'MantePro', 'MPR890623WX2', 'Mantenimiento', 'Áreas comunes, elevadores, sistemas', 'Av. Vasconcelos 890, Valle Oriente', 2, '8182345678', 'contacto@mantepro.mx', 'Ing. Eduardo Garza', 30, 1500000.00, 4.6, 'Activo', '2016-11-30'::DATE, 'Especialistas en mantenimiento de edificios corporativos'
    UNION ALL
    SELECT 'Limpieza y Conservación del Caribe S.A. de C.V.', 'LimpCarib', 'LCC950220YZ3', 'Mantenimiento', 'Limpieza, fumigación, jardinería', 'Av. Nichupté 456, Zona Hotelera', 6, '9987654321', 'servicios@limpcarib.mx', 'Lic. María del Carmen Sosa', 15, 600000.00, 4.2, 'Activo', '2020-06-15'::DATE, 'Servicios especializados para clima tropical'
    UNION ALL
    SELECT 'Técnicos Especializados HVAC S.A. de C.V.', 'TecHVAC', 'TEH910405A11', 'Mantenimiento', 'Aires acondicionados, calefacción, ventilación', 'Av. Paseo de la Reforma 789, Polanco', 1, '5554567890', 'servicio@techvac.mx', 'Ing. Andrés Salazar', 30, 2000000.00, 4.7, 'Activo', '2017-04-25'::DATE, 'Especialistas en sistemas HVAC para desarrollos residenciales'
);

-- Insertar Catálogo de Materiales
INSERT INTO URBANOVA_SCHEMA.CATALOGO_MATERIALES
SELECT
    ROW_NUMBER() OVER (ORDER BY NULL) AS MATERIAL_ID,
    proveedor_id,
    codigo_sku,
    descripcion,
    categoria,
    unidad_medida,
    precio_unitario,
    iva_incluido,
    tiempo_entrega,
    stock_minimo,
    estatus,
    comentario
FROM (
    -- Materiales de Albañilería
    SELECT 1 AS proveedor_id, 'ALB-CEM-001' AS codigo_sku, 'Cemento Portland Gris CPC 30R 50kg' AS descripcion, 'Albañilería' AS categoria, 'Bulto' AS unidad_medida, 185.00 AS precio_unitario, FALSE AS iva_incluido, 1 AS tiempo_entrega, 500 AS stock_minimo, 'Disponible' AS estatus, 'Cemento de uso general' AS comentario
    UNION ALL SELECT 1, 'ALB-ARE-001', 'Arena de Río Cribada M³', 'Albañilería', 'M³', 380.00, FALSE, 2, 50, 'Disponible', 'Arena para mezcla'
    UNION ALL SELECT 1, 'ALB-GRA-001', 'Grava Triturada 3/4" M³', 'Albañilería', 'M³', 420.00, FALSE, 2, 50, 'Disponible', 'Grava para concreto'
    UNION ALL SELECT 2, 'ALB-CEM-002', 'Cemento Premium Alta Resistencia 50kg', 'Albañilería', 'Bulto', 245.00, FALSE, 1, 300, 'Disponible', 'Cemento de alta resistencia'
    UNION ALL SELECT 3, 'ALB-BLO-001', 'Block Hueco 15x20x40cm', 'Albañilería', 'Pieza', 18.50, FALSE, 3, 2000, 'Disponible', 'Block estándar para muros'
    UNION ALL SELECT 3, 'ALB-ADO-001', 'Adoquín Rectangular Rojo 10x20cm', 'Albañilería', 'M²', 185.00, FALSE, 5, 500, 'Disponible', 'Adoquín para exteriores'
    UNION ALL SELECT 1, 'ALB-VAR-001', 'Varilla Corrugada 3/8" 12m', 'Albañilería', 'Pieza', 95.50, FALSE, 1, 200, 'Disponible', 'Varilla para refuerzo'
    UNION ALL SELECT 1, 'ALB-MAL-001', 'Malla Electrosoldada 6x6/10-10', 'Albañilería', 'Rollo', 650.00, FALSE, 2, 50, 'Disponible', 'Malla para losas'
    
    -- Materiales de Pintura
    UNION ALL SELECT 5, 'PIN-VIN-001', 'Pintura Vinílica Blanca Premium 19L', 'Pintura', 'Cubeta', 750.00, FALSE, 1, 100, 'Disponible', 'Pintura vinílica lavable'
    UNION ALL SELECT 5, 'PIN-VIN-002', 'Pintura Vinílica Color Pastel 19L', 'Pintura', 'Cubeta', 820.00, FALSE, 2, 80, 'Disponible', 'Varios colores disponibles'
    UNION ALL SELECT 6, 'PIN-ESM-001', 'Esmalte Alkydálico Blanco 4L', 'Pintura', 'Galón', 450.00, FALSE, 1, 50, 'Disponible', 'Esmalte para exteriores'
    UNION ALL SELECT 7, 'PIN-IMP-001', 'Impermeabilizante Acrílico 5 Años 19L', 'Pintura', 'Cubeta', 1250.00, FALSE, 2, 60, 'Disponible', 'Impermeabilizante garantizado'
    UNION ALL SELECT 7, 'PIN-IMP-002', 'Impermeabilizante Fibratado 10 Años 19L', 'Pintura', 'Cubeta', 1850.00, FALSE, 2, 40, 'Disponible', 'Máxima protección'
    UNION ALL SELECT 8, 'PIN-TEX-001', 'Tirol Texturizado Blanco 25kg', 'Pintura', 'Bulto', 185.00, FALSE, 1, 100, 'Disponible', 'Tirol para exteriores'
    UNION ALL SELECT 8, 'PIN-PAS-001', 'Pasta Texturizada Grano Fino 25kg', 'Pintura', 'Bulto', 245.00, FALSE, 2, 80, 'Disponible', 'Pasta para acabados'
    UNION ALL SELECT 5, 'PIN-SEL-001', 'Sellador Acrílico 19L', 'Pintura', 'Cubeta', 580.00, FALSE, 1, 70, 'Disponible', 'Sellador base agua'
    
    -- Materiales de Plomería
    UNION ALL SELECT 9, 'PLO-TUB-001', 'Tubo PVC Hidráulico 4" 6m', 'Plomería', 'Pieza', 320.00, FALSE, 1, 100, 'Disponible', 'Tubo para drenaje'
    UNION ALL SELECT 9, 'PLO-TUB-002', 'Tubo PVC Hidráulico 2" 6m', 'Plomería', 'Pieza', 145.00, FALSE, 1, 150, 'Disponible', 'Tubo para agua'
    UNION ALL SELECT 9, 'PLO-CON-001', 'Conexión Codo PVC 4" 90°', 'Plomería', 'Pieza', 85.00, FALSE, 1, 200, 'Disponible', 'Conexión estándar'
    UNION ALL SELECT 10, 'PLO-TUB-003', 'Tubo Cobre Tipo M 1/2" 6m', 'Plomería', 'Pieza', 580.00, FALSE, 2, 50, 'Disponible', 'Tubo cobre para agua caliente'
    UNION ALL SELECT 11, 'PLO-SAN-001', 'WC Completo Económico', 'Plomería', 'Juego', 2850.00, FALSE, 5, 30, 'Disponible', 'WC con tanque y accesorios'
    UNION ALL SELECT 11, 'PLO-SAN-002', 'Lavabo Empotrado Premium', 'Plomería', 'Pieza', 3500.00, FALSE, 7, 20, 'Disponible', 'Lavabo de porcelana premium'
    UNION ALL SELECT 11, 'PLO-GRI-001', 'Grifería Monomando Cocina', 'Plomería', 'Pieza', 1850.00, FALSE, 3, 25, 'Disponible', 'Grifería cromada'
    UNION ALL SELECT 12, 'PLO-VAL-001', 'Válvula Check Bronce 1"', 'Plomería', 'Pieza', 450.00, FALSE, 2, 40, 'Disponible', 'Válvula de retención'
    
    -- Materiales de Mantenimiento
    UNION ALL SELECT 13, 'MAN-HER-001', 'Kit Herramientas Mantenimiento Básico', 'Mantenimiento', 'Kit', 2500.00, FALSE, 3, 10, 'Disponible', 'Kit completo de herramientas'
    UNION ALL SELECT 14, 'MAN-ELE-001', 'Motor Elevador 5HP', 'Mantenimiento', 'Pieza', 45000.00, FALSE, 15, 2, 'Disponible', 'Motor de repuesto para elevador'
    UNION ALL SELECT 15, 'MAN-LIM-001', 'Kit Limpieza Industrial', 'Mantenimiento', 'Kit', 850.00, FALSE, 2, 20, 'Disponible', 'Productos de limpieza profesional'
    UNION ALL SELECT 16, 'MAN-CLI-001', 'Filtro HVAC Carbón Activado', 'Mantenimiento', 'Pieza', 350.00, FALSE, 3, 50, 'Disponible', 'Filtro para aires acondicionados'
    UNION ALL SELECT 16, 'MAN-CLI-002', 'Gas Refrigerante R410A 11.3kg', 'Mantenimiento', 'Cilindro', 2800.00, FALSE, 5, 15, 'Disponible', 'Gas refrigerante ecológico'
);

-- Insertar Solicitudes de Reparación de ejemplo
INSERT INTO URBANOVA_SCHEMA.SOLICITUDES_REPARACION
SELECT
    ROW_NUMBER() OVER (ORDER BY NULL) AS SOLICITUD_ID,
    propiedad_id,
    numero_solicitud,
    fecha_solicitud,
    tipo_reparacion,
    prioridad,
    descripcion_problema,
    proveedor_asignado_id,
    fecha_atencion,
    fecha_cierre,
    costo_reparacion,
    estatus,
    calificacion,
    comentario
FROM (
    SELECT 1 AS propiedad_id, 'SR-2024-0001' AS numero_solicitud, '2024-01-15'::DATE AS fecha_solicitud, 'Plomería' AS tipo_reparacion, 'Alta' AS prioridad, 'Fuga de agua en llave del lavabo de cocina' AS descripcion_problema, 9 AS proveedor_asignado_id, '2024-01-16'::DATE AS fecha_atencion, '2024-01-16'::DATE AS fecha_cierre, 850.00 AS costo_reparacion, 'Cerrada' AS estatus, 4.5 AS calificacion, 'Reparación exitosa' AS comentario
    UNION ALL SELECT 5, 'SR-2024-0002', '2024-01-20'::DATE, 'Pintura', 'Media', 'Manchas de humedad en pared de recámara', 5, '2024-01-25'::DATE, '2024-01-26'::DATE, 2500.00, 'Cerrada', 4.8, 'Se repintó área afectada'
    UNION ALL SELECT 12, 'SR-2024-0003', '2024-02-05'::DATE, 'Electricidad', 'Alta', 'Apagón parcial en departamento', 13, '2024-02-05'::DATE, '2024-02-06'::DATE, 1200.00, 'Cerrada', 4.2, 'Se reemplazó interruptor dañado'
    UNION ALL SELECT 18, 'SR-2024-0004', '2024-02-10'::DATE, 'Plomería', 'Alta', 'WC no funciona correctamente', 9, '2024-02-11'::DATE, '2024-02-11'::DATE, 950.00, 'Cerrada', 4.6, 'Se reemplazó mecanismo interno'
    UNION ALL SELECT 25, 'SR-2024-0005', '2024-02-15'::DATE, 'Mantenimiento', 'Baja', 'Aire acondicionado no enfría adecuadamente', 16, '2024-02-20'::DATE, '2024-02-20'::DATE, 1800.00, 'Cerrada', 4.4, 'Recarga de gas y limpieza de filtros'
    UNION ALL SELECT 30, 'SR-2024-0006', '2024-02-28'::DATE, 'Carpintería', 'Media', 'Puerta principal no cierra correctamente', 13, '2024-03-02'::DATE, '2024-03-02'::DATE, 650.00, 'Cerrada', 4.0, 'Ajuste de bisagras y cerradura'
    UNION ALL SELECT 8, 'SR-2024-0007', '2024-03-05'::DATE, 'Pintura', 'Baja', 'Desgaste general de pintura en recámaras', 5, '2024-03-15'::DATE, '2024-03-17'::DATE, 4500.00, 'Cerrada', 4.7, 'Repintado completo de recámaras'
    UNION ALL SELECT 15, 'SR-2024-0008', '2024-03-10'::DATE, 'Plomería', 'Alta', 'Fuga en regadera de baño principal', 10, '2024-03-10'::DATE, '2024-03-11'::DATE, 780.00, 'Cerrada', 4.9, 'Cambio de empaques y llaves'
    UNION ALL SELECT 22, 'SR-2024-0009', '2024-03-18'::DATE, 'Mantenimiento', 'Media', 'Elevador hace ruidos extraños', 14, '2024-03-20'::DATE, NULL, 0.00, 'En Proceso', NULL, 'Diagnóstico en proceso'
    UNION ALL SELECT 35, 'SR-2024-0010', '2024-03-22'::DATE, 'Pintura', 'Alta', 'Filtración de agua dañó pintura de techo', 7, '2024-03-23'::DATE, NULL, 0.00, 'En Proceso', NULL, 'Pendiente de impermeabilización'
);

-- ============================================================================
-- Consultas de Análisis: Gestión de Proveedores
-- ============================================================================

-- Análisis de Proveedores por Categoría
SELECT 
    CATEGORIA,
    COUNT(*) AS TOTAL_PROVEEDORES,
    ROUND(AVG(CALIFICACION_PROVEEDOR), 2) AS CALIFICACION_PROMEDIO,
    SUM(LIMITE_CREDITO_MXN) AS CREDITO_TOTAL_DISPONIBLE
FROM URBANOVA_SCHEMA.PROVEEDORES
WHERE ESTATUS = 'Activo'
GROUP BY CATEGORIA
ORDER BY TOTAL_PROVEEDORES DESC;

-- Top Proveedores por Calificación
SELECT 
    RAZON_SOCIAL,
    NOMBRE_COMERCIAL,
    CATEGORIA,
    ESPECIALIDAD,
    CALIFICACION_PROVEEDOR,
    LIMITE_CREDITO_MXN
FROM URBANOVA_SCHEMA.PROVEEDORES
WHERE ESTATUS = 'Activo'
ORDER BY CALIFICACION_PROVEEDOR DESC
LIMIT 10;

-- Catálogo de Materiales por Categoría
SELECT 
    CATEGORIA,
    COUNT(*) AS TOTAL_PRODUCTOS,
    ROUND(AVG(PRECIO_UNITARIO_MXN), 2) AS PRECIO_PROMEDIO,
    MIN(PRECIO_UNITARIO_MXN) AS PRECIO_MINIMO,
    MAX(PRECIO_UNITARIO_MXN) AS PRECIO_MAXIMO
FROM URBANOVA_SCHEMA.CATALOGO_MATERIALES
WHERE ESTATUS = 'Disponible'
GROUP BY CATEGORIA
ORDER BY TOTAL_PRODUCTOS DESC;

-- Análisis de Solicitudes de Reparación
SELECT 
    TIPO_REPARACION,
    COUNT(*) AS TOTAL_SOLICITUDES,
    SUM(CASE WHEN ESTATUS = 'Cerrada' THEN 1 ELSE 0 END) AS CERRADAS,
    SUM(CASE WHEN ESTATUS = 'En Proceso' THEN 1 ELSE 0 END) AS EN_PROCESO,
    ROUND(AVG(COSTO_REPARACION_MXN), 2) AS COSTO_PROMEDIO,
    ROUND(AVG(CALIFICACION_SERVICIO), 2) AS CALIFICACION_PROMEDIO
FROM URBANOVA_SCHEMA.SOLICITUDES_REPARACION
GROUP BY TIPO_REPARACION
ORDER BY TOTAL_SOLICITUDES DESC;

-- ============================================================================
-- FIN DEL SCRIPT - DEMO URBANOVA
-- ============================================================================
-- Siguiente paso: Crear modelo semántico .yaml para Cortex Analyst
-- ============================================================================

