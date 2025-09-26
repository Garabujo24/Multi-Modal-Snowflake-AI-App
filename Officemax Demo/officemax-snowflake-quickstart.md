author: OfficeMax México BI Team
summary: Quickstart completo de Snowflake para análisis y pronóstico de ventas Back-to-School
id: officemax-snowflake-analytics-quickstart
categories: analytics,ml,officemax
environments: Web
status: Published
feedback link: https://github.com/officemax-bi/snowflake-quickstart

# 📊 OfficeMax México - Quickstart Snowflake Analytics

## Resumen del Quickstart
Duration: 0:05:00

¡Bienvenido al quickstart de **OfficeMax México**! En este tutorial aprenderás a utilizar las capacidades avanzadas de Snowflake para análisis de datos, control de costos y pronósticos de ventas utilizando Machine Learning.

Este quickstart está diseñado específicamente para el equipo de Business Intelligence de OfficeMax México y se enfoca en productos de temporada **Back-to-School** con datos simulados realistas.

### Lo que aprenderás:
- ✅ **Time Travel**: Recuperación de datos históricos
- ✅ **Undrop**: Restauración de objetos eliminados 
- ✅ **Zero Copy Cloning**: Clonación eficiente de datos
- ✅ **Transformación JSON**: Procesamiento de datos semi-estructurados
- ✅ **Control de Costos**: Monitoreo y optimización de gastos
- ✅ **Desarrollo de Apps**: Integración con aplicaciones
- ✅ **ML para Pronósticos**: Modelos predictivos con SQL

### Prerrequisitos:
- Cuenta de Snowflake activa
- Permisos de SYSADMIN o ACCOUNTADMIN
- Conocimientos básicos de SQL
- Familiaridad con conceptos de BI

Positive
: Este quickstart utiliza el esquema de colores corporativo de OfficeMax (azul #003366 y rojo #CC0000) y datos simulados de productos de oficina y escolares.

## Preparación del Entorno
Duration: 0:08:00

Vamos a configurar nuestro entorno de trabajo con los datos necesarios para el análisis de OfficeMax.

### Paso 1: Configuración Inicial de Base de Datos

Ejecuta el siguiente código para crear la estructura básica:

```sql
-- Crear base de datos principal
CREATE OR REPLACE DATABASE OFFICEMAX_ANALYTICS;
USE DATABASE OFFICEMAX_ANALYTICS;

-- Crear esquemas organizacionales
CREATE OR REPLACE SCHEMA RAW_DATA;
CREATE OR REPLACE SCHEMA ANALYTICS;
CREATE OR REPLACE SCHEMA ML_MODELS;

-- Crear warehouse para análisis
CREATE OR REPLACE WAREHOUSE OFFICEMAX_WH WITH
    WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

USE WAREHOUSE OFFICEMAX_WH;
```

### Paso 2: Crear Tablas de Datos Base

```sql
-- Tabla de productos Back-to-School
CREATE OR REPLACE TABLE RAW_DATA.PRODUCTOS (
    PRODUCTO_ID INTEGER PRIMARY KEY,
    NOMBRE_PRODUCTO VARCHAR(200),
    CATEGORIA VARCHAR(100),
    SUB_CATEGORIA VARCHAR(100),
    PRECIO_UNITARIO DECIMAL(10,2),
    COSTO_UNITARIO DECIMAL(10,2),
    MARCA VARCHAR(100),
    TEMPORADA VARCHAR(50),
    FECHA_INGRESO TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Tabla de ventas históricas
CREATE OR REPLACE TABLE RAW_DATA.VENTAS (
    VENTA_ID INTEGER AUTOINCREMENT PRIMARY KEY,
    PRODUCTO_ID INTEGER,
    FECHA_VENTA DATE,
    CANTIDAD INTEGER,
    PRECIO_VENTA DECIMAL(10,2),
    DESCUENTO_APLICADO DECIMAL(5,2) DEFAULT 0,
    SUCURSAL_ID INTEGER,
    VENDEDOR_ID INTEGER,
    METODO_PAGO VARCHAR(50),
    CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (PRODUCTO_ID) REFERENCES RAW_DATA.PRODUCTOS(PRODUCTO_ID)
);

-- Tabla de clientes
CREATE OR REPLACE TABLE RAW_DATA.CLIENTES (
    CLIENTE_ID INTEGER PRIMARY KEY,
    NOMBRE VARCHAR(100),
    EMAIL VARCHAR(200),
    TELEFONO VARCHAR(20),
    FECHA_REGISTRO DATE,
    TIPO_CLIENTE VARCHAR(50), -- Individual, Corporativo, Educativo
    CIUDAD VARCHAR(100),
    ESTADO VARCHAR(100)
);
```

### Paso 3: Insertar Datos Simulados Back-to-School

```sql
-- Insertar productos de temporada escolar
INSERT INTO RAW_DATA.PRODUCTOS VALUES
(1001, 'Mochila Escolar Premium', 'Mochilas', 'Primaria', 899.00, 450.00, 'Kipling', 'Back-to-School', CURRENT_TIMESTAMP()),
(1002, 'Cuaderno Profesional 100 hojas', 'Papelería', 'Cuadernos', 45.00, 22.50, 'Scribe', 'Back-to-School', CURRENT_TIMESTAMP()),
(1003, 'Set Plumas BIC 10 piezas', 'Papelería', 'Escritura', 85.00, 42.50, 'BIC', 'Back-to-School', CURRENT_TIMESTAMP()),
(1004, 'Calculadora Científica', 'Tecnología', 'Calculadoras', 450.00, 225.00, 'Casio', 'Back-to-School', CURRENT_TIMESTAMP()),
(1005, 'Pegamento en Barra', 'Papelería', 'Adhesivos', 25.00, 12.50, 'Resistol', 'Back-to-School', CURRENT_TIMESTAMP()),
(1006, 'Folder Tamaño Carta', 'Organización', 'Folders', 15.00, 7.50, 'Wilson Jones', 'Back-to-School', CURRENT_TIMESTAMP()),
(1007, 'Mochila con Ruedas', 'Mochilas', 'Secundaria', 1299.00, 650.00, 'Samsonite', 'Back-to-School', CURRENT_TIMESTAMP()),
(1008, 'Lápices de Colores 24 pzs', 'Arte', 'Colores', 120.00, 60.00, 'Prismacolor', 'Back-to-School', CURRENT_TIMESTAMP());

-- Insertar clientes
INSERT INTO RAW_DATA.CLIENTES VALUES
(2001, 'María González', 'maria.gonzalez@gmail.com', '555-0101', '2023-08-15', 'Individual', 'México DF', 'CDMX'),
(2002, 'Colegio Benito Juárez', 'compras@colegiobj.edu.mx', '555-0201', '2023-07-20', 'Educativo', 'Guadalajara', 'Jalisco'),
(2003, 'Juan Pérez', 'juan.perez@hotmail.com', '555-0301', '2023-08-01', 'Individual', 'Monterrey', 'Nuevo León'),
(2004, 'Empresa ABC SA', 'compras@empresaabc.com', '555-0401', '2023-07-10', 'Corporativo', 'Puebla', 'Puebla');
```

Positive
: ✅ ¡Excelente! Has configurado la base de datos con productos típicos de la temporada Back-to-School de OfficeMax México.

## Time Travel - Recuperación de Datos
Duration: 0:10:00

El **Time Travel** de Snowflake te permite acceder a versiones anteriores de tus datos. Es especialmente útil para recuperar datos modificados o eliminados accidentalmente.

### Paso 1: Generar Ventas Históricas

Primero, vamos a crear datos de ventas para luego simular un error:

```sql
-- Insertar ventas del período Back-to-School 2024
INSERT INTO RAW_DATA.VENTAS (PRODUCTO_ID, FECHA_VENTA, CANTIDAD, PRECIO_VENTA, SUCURSAL_ID, VENDEDOR_ID, METODO_PAGO) VALUES
(1001, '2024-07-15', 15, 899.00, 101, 501, 'Tarjeta'),
(1002, '2024-07-15', 50, 45.00, 101, 501, 'Efectivo'),
(1003, '2024-07-16', 25, 85.00, 102, 502, 'Tarjeta'),
(1004, '2024-07-16', 8, 450.00, 101, 503, 'Transferencia'),
(1005, '2024-07-17', 100, 25.00, 103, 504, 'Efectivo'),
(1001, '2024-07-18', 22, 799.00, 102, 502, 'Tarjeta'),
(1007, '2024-07-19', 5, 1299.00, 101, 501, 'Transferencia'),
(1008, '2024-07-20', 35, 120.00, 103, 505, 'Tarjeta');

-- Verificar datos insertados
SELECT COUNT(*) as TOTAL_VENTAS FROM RAW_DATA.VENTAS;
```

### Paso 2: Simular Error - Eliminación Accidental

```sql
-- ¡OOPS! Eliminación accidental de ventas importantes
DELETE FROM RAW_DATA.VENTAS 
WHERE FECHA_VENTA = '2024-07-18' AND PRODUCTO_ID = 1001;

-- Verificar el error - ya no aparecen las ventas del 18 de julio
SELECT * FROM RAW_DATA.VENTAS 
WHERE FECHA_VENTA = '2024-07-18' AND PRODUCTO_ID = 1001;
```

### Paso 3: Recuperación con Time Travel

```sql
-- Recuperar datos de hace 5 minutos usando Time Travel
SELECT * FROM RAW_DATA.VENTAS AT(OFFSET => -300) -- 300 segundos = 5 minutos
WHERE FECHA_VENTA = '2024-07-18' AND PRODUCTO_ID = 1001;

-- Recuperar usando timestamp específico
SELECT * FROM RAW_DATA.VENTAS AT(TIMESTAMP => DATEADD(MINUTE, -10, CURRENT_TIMESTAMP()))
WHERE FECHA_VENTA = '2024-07-18' AND PRODUCTO_ID = 1001;

-- Restaurar los datos eliminados
INSERT INTO RAW_DATA.VENTAS (PRODUCTO_ID, FECHA_VENTA, CANTIDAD, PRECIO_VENTA, SUCURSAL_ID, VENDEDOR_ID, METODO_PAGO)
SELECT PRODUCTO_ID, FECHA_VENTA, CANTIDAD, PRECIO_VENTA, SUCURSAL_ID, VENDEDOR_ID, METODO_PAGO
FROM RAW_DATA.VENTAS AT(OFFSET => -300)
WHERE FECHA_VENTA = '2024-07-18' AND PRODUCTO_ID = 1001;
```

### Paso 4: Análisis de Cambios Históricos

```sql
-- Comparar ventas actuales vs. hace 1 hora
SELECT 
    'ACTUAL' as PERIODO,
    COUNT(*) as TOTAL_VENTAS,
    SUM(CANTIDAD * PRECIO_VENTA) as VENTAS_TOTALES
FROM RAW_DATA.VENTAS
UNION ALL
SELECT 
    'HACE_1_HORA' as PERIODO,
    COUNT(*) as TOTAL_VENTAS,
    SUM(CANTIDAD * PRECIO_VENTA) as VENTAS_TOTALES
FROM RAW_DATA.VENTAS AT(OFFSET => -3600);
```

Positive
: 🎯 **Caso de Uso Real**: En OfficeMax, Time Travel es crucial durante la temporada Back-to-School cuando hay muchas actualizaciones de inventario y precios. Permite recuperar datos sin impactar las operaciones.

## Undrop - Restauración de Objetos
Duration: 0:08:00

La función **Undrop** permite restaurar objetos (tablas, esquemas, bases de datos) eliminados accidentalmente.

### Paso 1: Crear Tabla de Inventario Temporal

```sql
-- Crear tabla de inventario para temporada escolar
CREATE OR REPLACE TABLE RAW_DATA.INVENTARIO_BACK_TO_SCHOOL (
    PRODUCTO_ID INTEGER,
    SUCURSAL_ID INTEGER,
    STOCK_ACTUAL INTEGER,
    STOCK_MINIMO INTEGER,
    STOCK_MAXIMO INTEGER,
    ULTIMA_ACTUALIZACION TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Poblar con datos de inventario
INSERT INTO RAW_DATA.INVENTARIO_BACK_TO_SCHOOL VALUES
(1001, 101, 45, 10, 100, CURRENT_TIMESTAMP()),
(1001, 102, 32, 10, 100, CURRENT_TIMESTAMP()),
(1001, 103, 28, 10, 100, CURRENT_TIMESTAMP()),
(1002, 101, 150, 50, 500, CURRENT_TIMESTAMP()),
(1002, 102, 200, 50, 500, CURRENT_TIMESTAMP()),
(1003, 101, 75, 25, 200, CURRENT_TIMESTAMP()),
(1004, 101, 12, 5, 50, CURRENT_TIMESTAMP()),
(1005, 102, 300, 100, 1000, CURRENT_TIMESTAMP());

-- Verificar datos
SELECT * FROM RAW_DATA.INVENTARIO_BACK_TO_SCHOOL;
```

### Paso 2: Eliminación Accidental de Tabla

```sql
-- ¡ERROR! Eliminación accidental de la tabla importante
DROP TABLE RAW_DATA.INVENTARIO_BACK_TO_SCHOOL;

-- Intentar consultar la tabla (esto dará error)
-- SELECT * FROM RAW_DATA.INVENTARIO_BACK_TO_SCHOOL;
```

### Paso 3: Restauración con Undrop

```sql
-- Restaurar la tabla eliminada
UNDROP TABLE RAW_DATA.INVENTARIO_BACK_TO_SCHOOL;

-- Verificar que los datos se recuperaron correctamente
SELECT * FROM RAW_DATA.INVENTARIO_BACK_TO_SCHOOL;

-- Verificar integridad de los datos
SELECT 
    COUNT(*) as TOTAL_REGISTROS,
    COUNT(DISTINCT PRODUCTO_ID) as PRODUCTOS_UNICOS,
    COUNT(DISTINCT SUCURSAL_ID) as SUCURSALES_UNICAS
FROM RAW_DATA.INVENTARIO_BACK_TO_SCHOOL;
```

### Paso 4: Mejores Prácticas para Undrop

```sql
-- Ver historial de objetos eliminados
SHOW TABLES HISTORY IN SCHEMA RAW_DATA;

-- Crear backup antes de operaciones riesgosas
CREATE TABLE RAW_DATA.INVENTARIO_BACKUP 
CLONE RAW_DATA.INVENTARIO_BACK_TO_SCHOOL;
```

Negative
: ⚠️ **Importante**: Undrop solo funciona dentro del período de retención (por defecto 1 día para tables, 7 días para schemas/databases). ¡Actúa rápido!

## Zero Copy Cloning - Clonación Eficiente
Duration: 0:08:00

**Zero Copy Cloning** permite crear copias instantáneas de objetos sin duplicar físicamente los datos, perfecto para testing y desarrollo.

### Paso 1: Crear Entorno de Desarrollo

```sql
-- Crear esquema de desarrollo
CREATE OR REPLACE SCHEMA DEV;

-- Clonar tabla de productos para desarrollo
CREATE TABLE DEV.PRODUCTOS_DEV 
CLONE RAW_DATA.PRODUCTOS;

-- Clonar tabla de ventas para testing
CREATE TABLE DEV.VENTAS_TEST 
CLONE RAW_DATA.VENTAS;

-- Verificar que las tablas clonadas tienen los mismos datos
SELECT COUNT(*) as PRODUCTOS_PROD FROM RAW_DATA.PRODUCTOS;
SELECT COUNT(*) as PRODUCTOS_DEV FROM DEV.PRODUCTOS_DEV;
```

### Paso 2: Experimentos Sin Riesgo

```sql
-- Experimentar con nuevos precios en el clon (sin afectar producción)
UPDATE DEV.PRODUCTOS_DEV 
SET PRECIO_UNITARIO = PRECIO_UNITARIO * 0.9 
WHERE CATEGORIA = 'Papelería';

-- Verificar cambios solo en desarrollo
SELECT 
    'PRODUCCION' as AMBIENTE,
    NOMBRE_PRODUCTO,
    PRECIO_UNITARIO
FROM RAW_DATA.PRODUCTOS 
WHERE CATEGORIA = 'Papelería'
UNION ALL
SELECT 
    'DESARROLLO' as AMBIENTE,
    NOMBRE_PRODUCTO,
    PRECIO_UNITARIO
FROM DEV.PRODUCTOS_DEV 
WHERE CATEGORIA = 'Papelería'
ORDER BY NOMBRE_PRODUCTO, AMBIENTE;
```

### Paso 3: Clonación de Base de Datos Completa

```sql
-- Crear clon completo de la base de datos para testing
CREATE DATABASE OFFICEMAX_ANALYTICS_TEST 
CLONE OFFICEMAX_ANALYTICS;

-- Usar la base clonada
USE DATABASE OFFICEMAX_ANALYTICS_TEST;

-- Verificar estructura clonada
SHOW TABLES IN SCHEMA RAW_DATA;
```

### Paso 4: Análisis de Costos de Clonación

```sql
-- Ver uso de almacenamiento por tabla
SELECT 
    TABLE_NAME,
    TABLE_SCHEMA,
    BYTES,
    BYTES / (1024*1024*1024) as GB_SIZE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('RAW_DATA', 'DEV')
ORDER BY BYTES DESC;
```

Positive
: 💡 **Beneficio Clave**: En OfficeMax, usar clones para testing de estrategias de precios Back-to-School permite experimentar sin riesgo antes de implementar cambios en producción.

## Transformación de Archivos JSON
Duration: 0:12:00

Aprendamos a procesar datos semi-estructurados JSON, común en sistemas de e-commerce y logs de aplicaciones.

### Paso 1: Crear Stage para Archivos JSON

```sql
-- Volver a base de datos principal
USE DATABASE OFFICEMAX_ANALYTICS;

-- Crear stage para archivos JSON
CREATE OR REPLACE STAGE RAW_DATA.JSON_STAGE;

-- Crear tabla para almacenar JSON raw
CREATE OR REPLACE TABLE RAW_DATA.TRANSACCIONES_JSON (
    ARCHIVO_ORIGEN VARCHAR(200),
    CONTENIDO_JSON VARIANT,
    FECHA_CARGA TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
```

### Paso 2: Simular Datos JSON de Transacciones E-commerce

```sql
-- Insertar datos JSON simulados de transacciones online
INSERT INTO RAW_DATA.TRANSACCIONES_JSON (ARCHIVO_ORIGEN, CONTENIDO_JSON) VALUES
('ecommerce_2024_07_15.json', PARSE_JSON('{
    "transaction_id": "TXN-001",
    "timestamp": "2024-07-15T10:30:00Z",
    "customer": {
        "id": 2001,
        "type": "registered",
        "location": "CDMX"
    },
    "items": [
        {"product_id": 1001, "name": "Mochila Escolar Premium", "quantity": 1, "unit_price": 899.00},
        {"product_id": 1002, "name": "Cuaderno Profesional", "quantity": 3, "unit_price": 45.00}
    ],
    "payment": {
        "method": "credit_card",
        "total": 1034.00,
        "currency": "MXN"
    },
    "shipping": {
        "type": "standard",
        "cost": 99.00,
        "address": "Mexico DF"
    }
}')),
('ecommerce_2024_07_16.json', PARSE_JSON('{
    "transaction_id": "TXN-002",
    "timestamp": "2024-07-16T14:15:00Z",
    "customer": {
        "id": 2003,
        "type": "guest",
        "location": "MTY"
    },
    "items": [
        {"product_id": 1004, "name": "Calculadora Científica", "quantity": 1, "unit_price": 450.00}
    ],
    "payment": {
        "method": "paypal",
        "total": 549.00,
        "currency": "MXN"
    },
    "shipping": {
        "type": "express",
        "cost": 99.00,
        "address": "Monterrey"
    }
}'));
```

### Paso 3: Extraer y Transformar Datos JSON

```sql
-- Crear vista estructurada de transacciones
CREATE OR REPLACE VIEW ANALYTICS.TRANSACCIONES_ECOMMERCE AS
SELECT 
    CONTENIDO_JSON:transaction_id::STRING AS TRANSACTION_ID,
    CONTENIDO_JSON:timestamp::TIMESTAMP_NTZ AS FECHA_TRANSACCION,
    CONTENIDO_JSON:customer.id::INTEGER AS CLIENTE_ID,
    CONTENIDO_JSON:customer.type::STRING AS TIPO_CLIENTE,
    CONTENIDO_JSON:customer.location::STRING AS UBICACION_CLIENTE,
    CONTENIDO_JSON:payment.method::STRING AS METODO_PAGO,
    CONTENIDO_JSON:payment.total::DECIMAL(10,2) AS TOTAL_PAGO,
    CONTENIDO_JSON:shipping.type::STRING AS TIPO_ENVIO,
    CONTENIDO_JSON:shipping.cost::DECIMAL(10,2) AS COSTO_ENVIO,
    FECHA_CARGA
FROM RAW_DATA.TRANSACCIONES_JSON;

-- Ver resultados transformados
SELECT * FROM ANALYTICS.TRANSACCIONES_ECOMMERCE;
```

### Paso 4: Procesar Arrays JSON (Items de Transacción)

```sql
-- Crear tabla detallada de items por transacción
CREATE OR REPLACE VIEW ANALYTICS.ITEMS_TRANSACCION AS
SELECT 
    t.CONTENIDO_JSON:transaction_id::STRING AS TRANSACTION_ID,
    t.CONTENIDO_JSON:timestamp::TIMESTAMP_NTZ AS FECHA_TRANSACCION,
    VALUE:product_id::INTEGER AS PRODUCTO_ID,
    VALUE:name::STRING AS NOMBRE_PRODUCTO,
    VALUE:quantity::INTEGER AS CANTIDAD,
    VALUE:unit_price::DECIMAL(10,2) AS PRECIO_UNITARIO,
    (VALUE:quantity::INTEGER * VALUE:unit_price::DECIMAL(10,2)) AS SUBTOTAL
FROM RAW_DATA.TRANSACCIONES_JSON t,
LATERAL FLATTEN(input => t.CONTENIDO_JSON:items) f;

-- Analizar ventas por producto desde JSON
SELECT 
    PRODUCTO_ID,
    NOMBRE_PRODUCTO,
    SUM(CANTIDAD) AS TOTAL_VENDIDO,
    SUM(SUBTOTAL) AS INGRESOS_TOTALES,
    AVG(PRECIO_UNITARIO) AS PRECIO_PROMEDIO
FROM ANALYTICS.ITEMS_TRANSACCION
GROUP BY PRODUCTO_ID, NOMBRE_PRODUCTO
ORDER BY INGRESOS_TOTALES DESC;
```

### Paso 5: Crear Tabla Híbrida (Structured + Semi-Structured)

```sql
-- Tabla que combina datos estructurados y JSON
CREATE OR REPLACE TABLE RAW_DATA.EVENTOS_MARKETING (
    EVENTO_ID INTEGER AUTOINCREMENT PRIMARY KEY,
    FECHA_EVENTO DATE,
    TIPO_EVENTO VARCHAR(100),
    SUCURSAL_ID INTEGER,
    METADATA_JSON VARIANT
);

-- Insertar eventos de marketing Back-to-School
INSERT INTO RAW_DATA.EVENTOS_MARKETING (FECHA_EVENTO, TIPO_EVENTO, SUCURSAL_ID, METADATA_JSON) VALUES
('2024-07-15', 'Promoción Back-to-School', 101, PARSE_JSON('{
    "descuento_porcentaje": 15,
    "productos_aplicables": [1001, 1002, 1003],
    "horario": {"inicio": "09:00", "fin": "21:00"},
    "canal": "tienda_fisica",
    "responsable": "María González"
}')),
('2024-07-20', 'Venta Especial Online', 0, PARSE_JSON('{
    "descuento_porcentaje": 20,
    "productos_aplicables": [1004, 1005, 1006, 1007, 1008],
    "vigencia": {"desde": "2024-07-20", "hasta": "2024-07-22"},
    "canal": "ecommerce",
    "codigo_promocional": "BACKTOSCHOOL20"
}'));

-- Consultar eventos con filtros en JSON
SELECT 
    EVENTO_ID,
    FECHA_EVENTO,
    TIPO_EVENTO,
    METADATA_JSON:descuento_porcentaje::INTEGER AS DESCUENTO,
    METADATA_JSON:canal::STRING AS CANAL,
    ARRAY_SIZE(METADATA_JSON:productos_aplicables) AS NUM_PRODUCTOS
FROM RAW_DATA.EVENTOS_MARKETING
WHERE METADATA_JSON:descuento_porcentaje::INTEGER >= 15;
```

Positive
: 📊 **Aplicación Real**: OfficeMax puede usar esta técnica para procesar logs de su e-commerce, datos de apps móviles, y feeds de sistemas externos como ERP o CRM.

## Control de Costos - Optimización Financiera
Duration: 0:10:00

El control de costos es fundamental para maximizar el ROI de Snowflake. Aprenderemos a monitorear y optimizar el gasto.

### Paso 1: Monitoreo de Uso de Warehouse

```sql
-- Ver uso de créditos por warehouse en los últimos 7 días
SELECT 
    WAREHOUSE_NAME,
    COUNT(*) AS TOTAL_CONSULTAS,
    SUM(TOTAL_ELAPSED_TIME) / 1000 AS TIEMPO_TOTAL_SEGUNDOS,
    SUM(CREDITS_USED_CLOUD_SERVICES) AS CREDITOS_SERVICIOS,
    AVG(EXECUTION_TIME) / 1000 AS TIEMPO_PROMEDIO_SEGUNDOS
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATEADD('DAY', -7, CURRENT_TIMESTAMP())
    AND WAREHOUSE_NAME IS NOT NULL
GROUP BY WAREHOUSE_NAME
ORDER BY CREDITOS_SERVICIOS DESC;
```

### Paso 2: Análisis de Consultas Costosas

```sql
-- Identificar consultas más costosas para optimizar
SELECT 
    QUERY_ID,
    USER_NAME,
    QUERY_TEXT,
    WAREHOUSE_NAME,
    TOTAL_ELAPSED_TIME / 1000 AS DURACION_SEGUNDOS,
    BYTES_SCANNED / (1024*1024*1024) AS GB_ESCANEADOS,
    CREDITS_USED_CLOUD_SERVICES,
    START_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATEADD('DAY', -7, CURRENT_TIMESTAMP())
    AND CREDITS_USED_CLOUD_SERVICES > 0.1  -- Consultas que usaron más de 0.1 créditos
ORDER BY CREDITS_USED_CLOUD_SERVICES DESC
LIMIT 10;
```

### Paso 3: Optimización de Warehouse

```sql
-- Crear warehouse optimizado para reportes Back-to-School
CREATE OR REPLACE WAREHOUSE OFFICEMAX_REPORTING_WH WITH
    WAREHOUSE_SIZE = 'X-SMALL'  -- Empezar pequeño
    AUTO_SUSPEND = 60           -- Suspender después de 1 minuto
    AUTO_RESUME = TRUE          -- Reanudar automáticamente
    INITIALLY_SUSPENDED = TRUE  -- Iniciar suspendido
    COMMENT = 'Warehouse optimizado para reportes de temporada escolar';

-- Configurar escalado automático (solo en ediciones Enterprise+)
-- ALTER WAREHOUSE OFFICEMAX_REPORTING_WH SET 
--     MIN_CLUSTER_COUNT = 1 
--     MAX_CLUSTER_COUNT = 3 
--     SCALING_POLICY = 'STANDARD';
```

### Paso 4: Resource Monitor para Control de Gastos

```sql
-- Crear monitor de recursos para controlar gastos mensuales
CREATE OR REPLACE RESOURCE MONITOR OFFICEMAX_MONTHLY_BUDGET WITH
    CREDIT_QUOTA = 100          -- Límite de 100 créditos mensuales
    FREQUENCY = MONTHLY         -- Reseteo mensual
    START_TIMESTAMP = DATE_TRUNC('MONTH', CURRENT_DATE())
    TRIGGERS 
        ON 80 PERCENT DO NOTIFY    -- Notificar al 80%
        ON 100 PERCENT DO SUSPEND  -- Suspender warehouses al 100%
        ON 110 PERCENT DO SUSPEND_IMMEDIATE; -- Suspensión inmediata al 110%

-- Asignar monitor al warehouse
ALTER WAREHOUSE OFFICEMAX_WH SET RESOURCE_MONITOR = OFFICEMAX_MONTHLY_BUDGET;
ALTER WAREHOUSE OFFICEMAX_REPORTING_WH SET RESOURCE_MONITOR = OFFICEMAX_MONTHLY_BUDGET;
```

### Paso 5: Análisis de Costos por Área de Negocio

```sql
-- Crear tabla de etiquetado por área de negocio
CREATE OR REPLACE TABLE ANALYTICS.QUERY_COST_TRACKING (
    QUERY_ID VARCHAR(200),
    AREA_NEGOCIO VARCHAR(100),
    PROYECTO VARCHAR(100),
    COSTO_ESTIMADO DECIMAL(10,4),
    FECHA_REGISTRO TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Vista de costos por área (simulado para el ejemplo)
CREATE OR REPLACE VIEW ANALYTICS.COSTOS_POR_AREA AS
SELECT 
    qh.USER_NAME,
    CASE 
        WHEN qh.QUERY_TEXT ILIKE '%back%school%' OR qh.QUERY_TEXT ILIKE '%escolar%' THEN 'Temporadas Especiales'
        WHEN qh.QUERY_TEXT ILIKE '%inventario%' OR qh.QUERY_TEXT ILIKE '%stock%' THEN 'Operaciones'
        WHEN qh.QUERY_TEXT ILIKE '%cliente%' OR qh.QUERY_TEXT ILIKE '%venta%' THEN 'Ventas'
        ELSE 'General'
    END AS AREA_NEGOCIO,
    COUNT(*) AS TOTAL_CONSULTAS,
    SUM(qh.CREDITS_USED_CLOUD_SERVICES) AS CREDITOS_UTILIZADOS,
    SUM(qh.CREDITS_USED_CLOUD_SERVICES) * 4.25 AS COSTO_ESTIMADO_USD  -- Precio promedio por crédito
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY qh
WHERE qh.START_TIME >= DATEADD('DAY', -30, CURRENT_TIMESTAMP())
    AND qh.WAREHOUSE_NAME LIKE 'OFFICEMAX%'
GROUP BY qh.USER_NAME, AREA_NEGOCIO
ORDER BY CREDITOS_UTILIZADOS DESC;

-- Ver resumen de costos
SELECT * FROM ANALYTICS.COSTOS_POR_AREA;
```

### Paso 6: Mejores Prácticas de Optimización

```sql
-- Ejemplo de consulta optimizada vs no optimizada

-- ❌ CONSULTA NO OPTIMIZADA (escanea toda la tabla)
-- SELECT * FROM RAW_DATA.VENTAS WHERE FECHA_VENTA = '2024-07-15';

-- ✅ CONSULTA OPTIMIZADA (con clustering key y filtros específicos)
SELECT 
    PRODUCTO_ID, 
    SUM(CANTIDAD) AS TOTAL_VENDIDO,
    SUM(CANTIDAD * PRECIO_VENTA) AS INGRESOS
FROM RAW_DATA.VENTAS 
WHERE FECHA_VENTA = '2024-07-15'
GROUP BY PRODUCTO_ID;

-- Configurar clustering para optimizar consultas frecuentes
ALTER TABLE RAW_DATA.VENTAS CLUSTER BY (FECHA_VENTA, PRODUCTO_ID);

-- Crear tabla agregada para consultas frecuentes (reduce costos)
CREATE OR REPLACE TABLE ANALYTICS.VENTAS_DIARIAS AS
SELECT 
    FECHA_VENTA,
    PRODUCTO_ID,
    COUNT(*) AS TRANSACCIONES,
    SUM(CANTIDAD) AS CANTIDAD_TOTAL,
    SUM(CANTIDAD * PRECIO_VENTA) AS INGRESOS_TOTALES,
    AVG(PRECIO_VENTA) AS PRECIO_PROMEDIO
FROM RAW_DATA.VENTAS
GROUP BY FECHA_VENTA, PRODUCTO_ID;
```

Negative
: 💰 **Importante**: En temporadas altas como Back-to-School, el uso de Snowflake puede aumentar significativamente. El monitoreo proactivo evita sorpresas en la facturación.

## Desarrollo de Aplicaciones - Integración
Duration: 0:12:00

Aprende a integrar Snowflake con aplicaciones para crear soluciones end-to-end.

### Paso 1: Configurar Conexión Segura

```sql
-- Crear usuario específico para aplicaciones
CREATE OR REPLACE USER OFFICEMAX_APP_USER 
    PASSWORD = 'SecureP@ssw0rd123!'
    DEFAULT_WAREHOUSE = OFFICEMAX_REPORTING_WH
    DEFAULT_DATABASE = OFFICEMAX_ANALYTICS
    DEFAULT_SCHEMA = ANALYTICS
    MUST_CHANGE_PASSWORD = FALSE;

-- Crear rol específico para aplicaciones
CREATE OR REPLACE ROLE OFFICEMAX_APP_ROLE;
GRANT USAGE ON WAREHOUSE OFFICEMAX_REPORTING_WH TO ROLE OFFICEMAX_APP_ROLE;
GRANT USAGE ON DATABASE OFFICEMAX_ANALYTICS TO ROLE OFFICEMAX_APP_ROLE;
GRANT USAGE ON SCHEMA RAW_DATA TO ROLE OFFICEMAX_APP_ROLE;
GRANT USAGE ON SCHEMA ANALYTICS TO ROLE OFFICEMAX_APP_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA RAW_DATA TO ROLE OFFICEMAX_APP_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA ANALYTICS TO ROLE OFFICEMAX_APP_ROLE;

-- Asignar rol al usuario
GRANT ROLE OFFICEMAX_APP_ROLE TO USER OFFICEMAX_APP_USER;
ALTER USER OFFICEMAX_APP_USER SET DEFAULT_ROLE = OFFICEMAX_APP_ROLE;
```

### Paso 2: API REST para Dashboard en Tiempo Real

```python
# Código Python para aplicación de dashboard
import snowflake.connector
import pandas as pd
from datetime import datetime, timedelta
import json

class OfficeMaxAnalytics:
    def __init__(self):
        self.conn = snowflake.connector.connect(
            user='OFFICEMAX_APP_USER',
            password='SecureP@ssw0rd123!',
            account='YOUR_ACCOUNT.region',
            warehouse='OFFICEMAX_REPORTING_WH',
            database='OFFICEMAX_ANALYTICS',
            schema='ANALYTICS'
        )
    
    def get_ventas_back_to_school(self, fecha_inicio, fecha_fin):
        """Obtener ventas de productos Back-to-School en período específico"""
        query = """
        SELECT 
            p.NOMBRE_PRODUCTO,
            p.CATEGORIA,
            p.SUB_CATEGORIA,
            SUM(v.CANTIDAD) as UNIDADES_VENDIDAS,
            SUM(v.CANTIDAD * v.PRECIO_VENTA) as INGRESOS_TOTALES,
            AVG(v.PRECIO_VENTA) as PRECIO_PROMEDIO
        FROM RAW_DATA.VENTAS v
        JOIN RAW_DATA.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
        WHERE v.FECHA_VENTA BETWEEN %s AND %s
            AND p.TEMPORADA = 'Back-to-School'
        GROUP BY p.NOMBRE_PRODUCTO, p.CATEGORIA, p.SUB_CATEGORIA
        ORDER BY INGRESOS_TOTALES DESC
        """
        
        df = pd.read_sql(query, self.conn, params=[fecha_inicio, fecha_fin])
        return df.to_dict('records')
    
    def get_inventario_critico(self, stock_minimo=10):
        """Obtener productos con inventario crítico"""
        query = """
        SELECT 
            p.NOMBRE_PRODUCTO,
            p.CATEGORIA,
            i.SUCURSAL_ID,
            i.STOCK_ACTUAL,
            i.STOCK_MINIMO,
            CASE 
                WHEN i.STOCK_ACTUAL <= i.STOCK_MINIMO THEN 'CRÍTICO'
                WHEN i.STOCK_ACTUAL <= i.STOCK_MINIMO * 1.5 THEN 'BAJO'
                ELSE 'NORMAL'
            END as NIVEL_STOCK
        FROM RAW_DATA.INVENTARIO_BACK_TO_SCHOOL i
        JOIN RAW_DATA.PRODUCTOS p ON i.PRODUCTO_ID = p.PRODUCTO_ID
        WHERE i.STOCK_ACTUAL <= %s * 2
        ORDER BY i.STOCK_ACTUAL ASC
        """
        
        df = pd.read_sql(query, self.conn, params=[stock_minimo])
        return df.to_dict('records')
    
    def get_tendencias_ventas(self, dias=30):
        """Obtener tendencias de ventas por día"""
        query = """
        SELECT 
            FECHA_VENTA,
            COUNT(DISTINCT VENTA_ID) as TRANSACCIONES,
            SUM(CANTIDAD) as UNIDADES_VENDIDAS,
            SUM(CANTIDAD * PRECIO_VENTA) as INGRESOS_DIARIOS
        FROM RAW_DATA.VENTAS
        WHERE FECHA_VENTA >= DATEADD('DAY', -%s, CURRENT_DATE())
        GROUP BY FECHA_VENTA
        ORDER BY FECHA_VENTA
        """
        
        df = pd.read_sql(query, self.conn, params=[dias])
        return df.to_dict('records')

# Ejemplo de uso
if __name__ == "__main__":
    analytics = OfficeMaxAnalytics()
    
    # Obtener ventas de la última semana
    fecha_fin = datetime.now().date()
    fecha_inicio = fecha_fin - timedelta(days=7)
    
    ventas = analytics.get_ventas_back_to_school(fecha_inicio, fecha_fin)
    print(f"Ventas Back-to-School (últimos 7 días): {json.dumps(ventas, indent=2)}")
    
    # Verificar inventario crítico
    inventario = analytics.get_inventario_critico()
    print(f"Productos con inventario crítico: {len(inventario)} items")
```

### Paso 3: Streamlit Dashboard Interactivo

```python
# dashboard_officemax.py - Dashboard interactivo con Streamlit
import streamlit as st
import snowflake.connector
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta

# Configuración de página con colores corporativos OfficeMax
st.set_page_config(
    page_title="OfficeMax Analytics - Back to School",
    page_icon="🎒",
    layout="wide",
    initial_sidebar_state="expanded"
)

# CSS personalizado con colores corporativos
st.markdown("""
<style>
    .main-header {
        background: linear-gradient(90deg, #003366, #CC0000);
        color: white;
        padding: 1rem;
        border-radius: 10px;
        text-align: center;
        margin-bottom: 2rem;
    }
    .metric-card {
        background: #f8f9fa;
        padding: 1rem;
        border-radius: 8px;
        border-left: 4px solid #003366;
        margin-bottom: 1rem;
    }
    .sidebar .sidebar-content {
        background: #f0f2f6;
    }
</style>
""", unsafe_allow_html=True)

# Header principal
st.markdown("""
<div class="main-header">
    <h1>🏢 OfficeMax México - Analytics Dashboard</h1>
    <h3>📚 Temporada Back-to-School 2024</h3>
</div>
""", unsafe_allow_html=True)

@st.cache_data
def get_snowflake_connection():
    """Crear conexión a Snowflake con caché"""
    return snowflake.connector.connect(
        user='OFFICEMAX_APP_USER',
        password='SecureP@ssw0rd123!',
        account='YOUR_ACCOUNT.region',
        warehouse='OFFICEMAX_REPORTING_WH',
        database='OFFICEMAX_ANALYTICS',
        schema='ANALYTICS'
    )

@st.cache_data(ttl=300)  # Cache por 5 minutos
def load_ventas_data():
    """Cargar datos de ventas desde Snowflake"""
    conn = get_snowflake_connection()
    query = """
    SELECT 
        v.FECHA_VENTA,
        p.NOMBRE_PRODUCTO,
        p.CATEGORIA,
        p.SUB_CATEGORIA,
        v.CANTIDAD,
        v.PRECIO_VENTA,
        v.CANTIDAD * v.PRECIO_VENTA as INGRESOS,
        v.SUCURSAL_ID
    FROM RAW_DATA.VENTAS v
    JOIN RAW_DATA.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
    WHERE p.TEMPORADA = 'Back-to-School'
    ORDER BY v.FECHA_VENTA DESC
    """
    return pd.read_sql(query, conn)

# Sidebar con filtros
st.sidebar.header("🔍 Filtros de Análisis")

# Cargar datos
df_ventas = load_ventas_data()

# Filtros en sidebar
fechas = st.sidebar.date_input(
    "📅 Rango de Fechas",
    value=(df_ventas['FECHA_VENTA'].min(), df_ventas['FECHA_VENTA'].max()),
    min_value=df_ventas['FECHA_VENTA'].min(),
    max_value=df_ventas['FECHA_VENTA'].max()
)

categorias = st.sidebar.multiselect(
    "📦 Categorías",
    options=df_ventas['CATEGORIA'].unique(),
    default=df_ventas['CATEGORIA'].unique()
)

sucursales = st.sidebar.multiselect(
    "🏪 Sucursales",
    options=sorted(df_ventas['SUCURSAL_ID'].unique()),
    default=sorted(df_ventas['SUCURSAL_ID'].unique())
)

# Aplicar filtros
mask = (
    (df_ventas['FECHA_VENTA'] >= fechas[0]) & 
    (df_ventas['FECHA_VENTA'] <= fechas[1]) &
    (df_ventas['CATEGORIA'].isin(categorias)) &
    (df_ventas['SUCURSAL_ID'].isin(sucursales))
)
df_filtered = df_ventas[mask]

# KPIs principales
col1, col2, col3, col4 = st.columns(4)

with col1:
    total_ingresos = df_filtered['INGRESOS'].sum()
    st.metric(
        label="💰 Ingresos Totales",
        value=f"${total_ingresos:,.2f} MXN",
        delta=f"{len(df_filtered)} transacciones"
    )

with col2:
    total_unidades = df_filtered['CANTIDAD'].sum()
    st.metric(
        label="📦 Unidades Vendidas",
        value=f"{total_unidades:,}",
        delta=f"{df_filtered['NOMBRE_PRODUCTO'].nunique()} productos"
    )

with col3:
    ticket_promedio = df_filtered['INGRESOS'].mean()
    st.metric(
        label="🧾 Ticket Promedio",
        value=f"${ticket_promedio:.2f} MXN",
        delta=f"Por transacción"
    )

with col4:
    sucursales_activas = df_filtered['SUCURSAL_ID'].nunique()
    st.metric(
        label="🏪 Sucursales Activas",
        value=f"{sucursales_activas}",
        delta=f"Con ventas Back-to-School"
    )

# Gráficos principales
st.subheader("📊 Análisis de Ventas Back-to-School")

col1, col2 = st.columns(2)

with col1:
    # Ventas por categoría
    ventas_categoria = df_filtered.groupby('CATEGORIA')['INGRESOS'].sum().reset_index()
    fig_categoria = px.pie(
        ventas_categoria, 
        values='INGRESOS', 
        names='CATEGORIA',
        title="💼 Ingresos por Categoría",
        color_discrete_sequence=['#003366', '#CC0000', '#0066CC', '#FF6600']
    )
    st.plotly_chart(fig_categoria, use_container_width=True)

with col2:
    # Top productos
    top_productos = df_filtered.groupby('NOMBRE_PRODUCTO')['INGRESOS'].sum().nlargest(10).reset_index()
    fig_productos = px.bar(
        top_productos,
        x='INGRESOS',
        y='NOMBRE_PRODUCTO',
        orientation='h',
        title="🏆 Top 10 Productos por Ingresos",
        color='INGRESOS',
        color_continuous_scale=['#003366', '#CC0000']
    )
    fig_productos.update_layout(yaxis={'categoryorder': 'total ascending'})
    st.plotly_chart(fig_productos, use_container_width=True)

# Tendencia temporal
st.subheader("📈 Tendencia de Ventas")
ventas_diarias = df_filtered.groupby('FECHA_VENTA').agg({
    'INGRESOS': 'sum',
    'CANTIDAD': 'sum'
}).reset_index()

fig_tendencia = go.Figure()
fig_tendencia.add_trace(go.Scatter(
    x=ventas_diarias['FECHA_VENTA'],
    y=ventas_diarias['INGRESOS'],
    name='Ingresos Diarios',
    line=dict(color='#003366', width=3),
    fill='tonexty'
))

fig_tendencia.update_layout(
    title="💹 Evolución de Ingresos Diarios",
    xaxis_title="Fecha",
    yaxis_title="Ingresos (MXN)",
    showlegend=True
)
st.plotly_chart(fig_tendencia, use_container_width=True)

# Tabla detallada
st.subheader("📋 Detalle de Transacciones")
st.dataframe(
    df_filtered[['FECHA_VENTA', 'NOMBRE_PRODUCTO', 'CATEGORIA', 'CANTIDAD', 'PRECIO_VENTA', 'INGRESOS', 'SUCURSAL_ID']],
    use_container_width=True
)

# Footer con información
st.markdown("---")
st.markdown("""
<div style='text-align: center; color: #666;'>
    <p>🏢 OfficeMax México - Dashboard de Analytics | Powered by Snowflake ❄️</p>
    <p>📊 Datos actualizados automáticamente cada 5 minutos</p>
</div>
""", unsafe_allow_html=True)
```

### Paso 4: Automatización con Funciones Serverless

```sql
-- Crear función para calcular métricas de temporada
CREATE OR REPLACE FUNCTION ANALYTICS.CALCULAR_METRICAS_TEMPORADA(
    FECHA_INICIO DATE,
    FECHA_FIN DATE,
    TEMPORADA_PARAM STRING
)
RETURNS TABLE (
    CATEGORIA STRING,
    TOTAL_VENTAS NUMBER,
    INGRESOS_TOTALES NUMBER,
    CRECIMIENTO_PORCENTUAL FLOAT
)
LANGUAGE SQL
AS
$$
    SELECT 
        p.CATEGORIA,
        SUM(v.CANTIDAD) as TOTAL_VENTAS,
        SUM(v.CANTIDAD * v.PRECIO_VENTA) as INGRESOS_TOTALES,
        -- Calcular crecimiento vs período anterior
        (SUM(v.CANTIDAD * v.PRECIO_VENTA) / 
         LAG(SUM(v.CANTIDAD * v.PRECIO_VENTA)) OVER (ORDER BY p.CATEGORIA) - 1) * 100 as CRECIMIENTO_PORCENTUAL
    FROM RAW_DATA.VENTAS v
    JOIN RAW_DATA.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
    WHERE v.FECHA_VENTA BETWEEN FECHA_INICIO AND FECHA_FIN
        AND p.TEMPORADA = TEMPORADA_PARAM
    GROUP BY p.CATEGORIA
    ORDER BY INGRESOS_TOTALES DESC
$$;

-- Usar la función
SELECT * FROM TABLE(ANALYTICS.CALCULAR_METRICAS_TEMPORADA(
    '2024-07-01', 
    '2024-07-31', 
    'Back-to-School'
));
```

### Paso 5: Webhook para Alertas en Tiempo Real

```sql
-- Crear tabla para tracking de alertas
CREATE OR REPLACE TABLE ANALYTICS.ALERTAS_INVENTARIO (
    ALERTA_ID INTEGER AUTOINCREMENT PRIMARY KEY,
    PRODUCTO_ID INTEGER,
    SUCURSAL_ID INTEGER,
    TIPO_ALERTA VARCHAR(100),
    STOCK_ACTUAL INTEGER,
    UMBRAL INTEGER,
    FECHA_ALERTA TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    ESTADO VARCHAR(50) DEFAULT 'PENDIENTE'
);

-- Procedimiento para generar alertas automáticas
CREATE OR REPLACE PROCEDURE ANALYTICS.GENERAR_ALERTAS_STOCK()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    INSERT INTO ANALYTICS.ALERTAS_INVENTARIO (PRODUCTO_ID, SUCURSAL_ID, TIPO_ALERTA, STOCK_ACTUAL, UMBRAL)
    SELECT 
        i.PRODUCTO_ID,
        i.SUCURSAL_ID,
        'STOCK_BAJO' as TIPO_ALERTA,
        i.STOCK_ACTUAL,
        i.STOCK_MINIMO
    FROM RAW_DATA.INVENTARIO_BACK_TO_SCHOOL i
    JOIN RAW_DATA.PRODUCTOS p ON i.PRODUCTO_ID = p.PRODUCTO_ID
    WHERE i.STOCK_ACTUAL <= i.STOCK_MINIMO
        AND p.TEMPORADA = 'Back-to-School'
        AND NOT EXISTS (
            SELECT 1 FROM ANALYTICS.ALERTAS_INVENTARIO a
            WHERE a.PRODUCTO_ID = i.PRODUCTO_ID 
                AND a.SUCURSAL_ID = i.SUCURSAL_ID
                AND a.ESTADO = 'PENDIENTE'
        );
    
    RETURN 'Alertas generadas correctamente';
END;
$$;

-- Ejecutar procedimiento
CALL ANALYTICS.GENERAR_ALERTAS_STOCK();

-- Ver alertas pendientes
SELECT 
    a.ALERTA_ID,
    p.NOMBRE_PRODUCTO,
    a.SUCURSAL_ID,
    a.TIPO_ALERTA,
    a.STOCK_ACTUAL,
    a.UMBRAL,
    a.FECHA_ALERTA
FROM ANALYTICS.ALERTAS_INVENTARIO a
JOIN RAW_DATA.PRODUCTOS p ON a.PRODUCTO_ID = p.PRODUCTO_ID
WHERE a.ESTADO = 'PENDIENTE'
ORDER BY a.FECHA_ALERTA DESC;
```

Positive
: 🔗 **Integración Real**: Este código puede integrarse con sistemas ERP, CRM, y herramientas de BI como Tableau o Power BI para crear soluciones empresariales completas.

## Modelo de Pronóstico de Ventas - ML en SQL
Duration: 0:15:00

Vamos a crear un modelo de Machine Learning para pronosticar ventas de productos Back-to-School usando las funciones nativas de ML de Snowflake.

### Paso 1: Preparación de Datos para ML

```sql
-- Crear esquema específico para ML
USE SCHEMA ML_MODELS;

-- Crear tabla de características (features) para el modelo
CREATE OR REPLACE TABLE FEATURES_VENTAS_TEMPORADA AS
SELECT 
    p.PRODUCTO_ID,
    p.NOMBRE_PRODUCTO,
    p.CATEGORIA,
    p.SUB_CATEGORIA,
    p.PRECIO_UNITARIO,
    p.COSTO_UNITARIO,
    (p.PRECIO_UNITARIO - p.COSTO_UNITARIO) as MARGEN_UNITARIO,
    (p.PRECIO_UNITARIO - p.COSTO_UNITARIO) / p.PRECIO_UNITARIO as MARGEN_PORCENTUAL,
    v.FECHA_VENTA,
    EXTRACT(YEAR FROM v.FECHA_VENTA) as AÑO,
    EXTRACT(MONTH FROM v.FECHA_VENTA) as MES,
    EXTRACT(WEEK FROM v.FECHA_VENTA) as SEMANA,
    EXTRACT(DOW FROM v.FECHA_VENTA) as DIA_SEMANA, -- 0=Domingo, 6=Sábado
    v.SUCURSAL_ID,
    SUM(v.CANTIDAD) as CANTIDAD_VENDIDA,
    SUM(v.CANTIDAD * v.PRECIO_VENTA) as INGRESOS,
    COUNT(*) as NUMERO_TRANSACCIONES,
    AVG(v.PRECIO_VENTA) as PRECIO_PROMEDIO
FROM RAW_DATA.VENTAS v
JOIN RAW_DATA.PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
WHERE p.TEMPORADA = 'Back-to-School'
GROUP BY 
    p.PRODUCTO_ID, p.NOMBRE_PRODUCTO, p.CATEGORIA, p.SUB_CATEGORIA,
    p.PRECIO_UNITARIO, p.COSTO_UNITARIO, v.FECHA_VENTA, v.SUCURSAL_ID
ORDER BY v.FECHA_VENTA;

-- Ver datos preparados
SELECT * FROM FEATURES_VENTAS_TEMPORADA LIMIT 10;
```

### Paso 2: Análisis Exploratorio de Datos

```sql
-- Estadísticas descriptivas por categoría
SELECT 
    CATEGORIA,
    COUNT(*) as REGISTROS,
    AVG(CANTIDAD_VENDIDA) as PROMEDIO_CANTIDAD,
    STDDEV(CANTIDAD_VENDIDA) as DESV_EST_CANTIDAD,
    MIN(CANTIDAD_VENDIDA) as MIN_CANTIDAD,
    MAX(CANTIDAD_VENDIDA) as MAX_CANTIDAD,
    AVG(INGRESOS) as PROMEDIO_INGRESOS,
    SUM(INGRESOS) as TOTAL_INGRESOS
FROM FEATURES_VENTAS_TEMPORADA
GROUP BY CATEGORIA
ORDER BY TOTAL_INGRESOS DESC;

-- Análisis de tendencias por día de semana
SELECT 
    DIA_SEMANA,
    CASE DIA_SEMANA
        WHEN 0 THEN 'Domingo'
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
    END as NOMBRE_DIA,
    AVG(CANTIDAD_VENDIDA) as PROMEDIO_VENTAS,
    AVG(NUMERO_TRANSACCIONES) as PROMEDIO_TRANSACCIONES
FROM FEATURES_VENTAS_TEMPORADA
GROUP BY DIA_SEMANA, NOMBRE_DIA
ORDER BY DIA_SEMANA;

-- Correlación entre precio y cantidad vendida
SELECT 
    CATEGORIA,
    CORR(PRECIO_UNITARIO, CANTIDAD_VENDIDA) as CORRELACION_PRECIO_CANTIDAD,
    CORR(MARGEN_PORCENTUAL, CANTIDAD_VENDIDA) as CORRELACION_MARGEN_CANTIDAD
FROM FEATURES_VENTAS_TEMPORADA
GROUP BY CATEGORIA;
```

### Paso 3: Crear Dataset de Entrenamiento y Prueba

```sql
-- Dividir datos en entrenamiento (80%) y prueba (20%)
CREATE OR REPLACE TABLE DATASET_ENTRENAMIENTO AS
SELECT *,
    ROW_NUMBER() OVER (ORDER BY FECHA_VENTA, PRODUCTO_ID) as ROW_NUM
FROM FEATURES_VENTAS_TEMPORADA;

-- Calcular punto de corte (80% para entrenamiento)
SET TOTAL_ROWS = (SELECT COUNT(*) FROM DATASET_ENTRENAMIENTO);
SET TRAIN_CUTOFF = ($TOTAL_ROWS * 0.8)::INTEGER;

-- Crear tablas de entrenamiento y prueba
CREATE OR REPLACE TABLE TRAIN_DATA AS
SELECT * FROM DATASET_ENTRENAMIENTO 
WHERE ROW_NUM <= $TRAIN_CUTOFF;

CREATE OR REPLACE TABLE TEST_DATA AS
SELECT * FROM DATASET_ENTRENAMIENTO 
WHERE ROW_NUM > $TRAIN_CUTOFF;

-- Verificar división
SELECT 
    'ENTRENAMIENTO' as DATASET,
    COUNT(*) as REGISTROS,
    MIN(FECHA_VENTA) as FECHA_MIN,
    MAX(FECHA_VENTA) as FECHA_MAX
FROM TRAIN_DATA
UNION ALL
SELECT 
    'PRUEBA' as DATASET,
    COUNT(*) as REGISTROS,
    MIN(FECHA_VENTA) as FECHA_MIN,
    MAX(FECHA_VENTA) as FECHA_MAX
FROM TEST_DATA;
```

### Paso 4: Crear Modelo de Regresión Lineal

```sql
-- Crear modelo para predecir cantidad vendida
CREATE OR REPLACE SNOWFLAKE.ML.FORECAST MODELO_PRONOSTICO_BACK_TO_SCHOOL (
    INPUT_DATA => SYSTEM$REFERENCE('TABLE', 'TRAIN_DATA'),
    SERIES_COLNAME => 'PRODUCTO_ID',
    TIMESTAMP_COLNAME => 'FECHA_VENTA',
    TARGET_COLNAME => 'CANTIDAD_VENDIDA',
    CONFIG_OBJECT => {
        'ON_ERROR': 'SKIP',
        'PREDICTION_INTERVAL': 0.95
    }
);

-- Ver información del modelo
DESCRIBE SNOWFLAKE.ML.FORECAST MODELO_PRONOSTICO_BACK_TO_SCHOOL;
```

### Paso 5: Realizar Predicciones

```sql
-- Generar pronósticos para los próximos 30 días
CREATE OR REPLACE TABLE PRONOSTICOS_VENTAS AS
SELECT 
    PRODUCTO_ID,
    TS as FECHA_PRONOSTICO,
    FORECAST as CANTIDAD_PRONOSTICADA,
    LOWER_BOUND as LIMITE_INFERIOR,
    UPPER_BOUND as LIMITE_SUPERIOR
FROM TABLE(
    SNOWFLAKE.ML.FORECAST(
        MODEL_NAME => 'MODELO_PRONOSTICO_BACK_TO_SCHOOL',
        SERIES_VALUE => (SELECT DISTINCT PRODUCTO_ID FROM TRAIN_DATA),
        FORECASTING_PERIODS => 30
    )
);

-- Enriquecer pronósticos con información de productos
CREATE OR REPLACE VIEW PRONOSTICOS_DETALLADOS AS
SELECT 
    pr.FECHA_PRONOSTICO,
    pr.PRODUCTO_ID,
    p.NOMBRE_PRODUCTO,
    p.CATEGORIA,
    p.PRECIO_UNITARIO,
    pr.CANTIDAD_PRONOSTICADA,
    pr.LIMITE_INFERIOR,
    pr.LIMITE_SUPERIOR,
    (pr.CANTIDAD_PRONOSTICADA * p.PRECIO_UNITARIO) as INGRESOS_PRONOSTICADOS,
    (pr.LIMITE_INFERIOR * p.PRECIO_UNITARIO) as INGRESOS_MIN,
    (pr.LIMITE_SUPERIOR * p.PRECIO_UNITARIO) as INGRESOS_MAX
FROM PRONOSTICOS_VENTAS pr
JOIN RAW_DATA.PRODUCTOS p ON pr.PRODUCTO_ID = p.PRODUCTO_ID
ORDER BY pr.FECHA_PRONOSTICO, pr.CANTIDAD_PRONOSTICADA DESC;

-- Ver pronósticos
SELECT * FROM PRONOSTICOS_DETALLADOS LIMIT 20;
```

### Paso 6: Evaluar Precisión del Modelo

```sql
-- Crear pronósticos para datos de prueba para evaluar precisión
CREATE OR REPLACE TABLE EVALUACION_MODELO AS
SELECT 
    t.PRODUCTO_ID,
    t.FECHA_VENTA,
    t.CANTIDAD_VENDIDA as CANTIDAD_REAL,
    -- Simular predicción (en un modelo real usaríamos los resultados del modelo)
    CASE 
        WHEN t.CATEGORIA = 'Mochilas' THEN t.CANTIDAD_VENDIDA * (0.9 + RANDOM()/10)
        WHEN t.CATEGORIA = 'Papelería' THEN t.CANTIDAD_VENDIDA * (0.95 + RANDOM()/20)
        ELSE t.CANTIDAD_VENDIDA * (0.85 + RANDOM()/5)
    END as CANTIDAD_PREDICHA
FROM TEST_DATA t;

-- Calcular métricas de evaluación
SELECT 
    COUNT(*) as TOTAL_PREDICCIONES,
    AVG(ABS(CANTIDAD_REAL - CANTIDAD_PREDICHA)) as MAE, -- Error Absoluto Medio
    SQRT(AVG(POWER(CANTIDAD_REAL - CANTIDAD_PREDICHA, 2))) as RMSE, -- Raíz del Error Cuadrático Medio
    AVG(ABS((CANTIDAD_REAL - CANTIDAD_PREDICHA) / CANTIDAD_REAL)) * 100 as MAPE, -- Error Porcentual Absoluto Medio
    CORR(CANTIDAD_REAL, CANTIDAD_PREDICHA) as CORRELACION
FROM EVALUACION_MODELO
WHERE CANTIDAD_REAL > 0; -- Evitar divisiones por cero

-- Análisis de precisión por categoría
SELECT 
    p.CATEGORIA,
    COUNT(*) as PREDICCIONES,
    AVG(ABS(e.CANTIDAD_REAL - e.CANTIDAD_PREDICHA)) as MAE,
    AVG(ABS((e.CANTIDAD_REAL - e.CANTIDAD_PREDICHA) / e.CANTIDAD_REAL)) * 100 as MAPE_PORCENTAJE
FROM EVALUACION_MODELO e
JOIN RAW_DATA.PRODUCTOS p ON e.PRODUCTO_ID = p.PRODUCTO_ID
WHERE e.CANTIDAD_REAL > 0
GROUP BY p.CATEGORIA
ORDER BY MAE;
```

### Paso 7: Insights de Negocio y Recomendaciones

```sql
-- Top productos con mayor crecimiento pronosticado
SELECT 
    NOMBRE_PRODUCTO,
    CATEGORIA,
    AVG(CANTIDAD_PRONOSTICADA) as PROMEDIO_DIARIO_PRONOSTICADO,
    SUM(INGRESOS_PRONOSTICADOS) as INGRESOS_TOTALES_30_DIAS,
    -- Comparar con promedio histórico
    (SELECT AVG(CANTIDAD_VENDIDA) 
     FROM FEATURES_VENTAS_TEMPORADA f 
     WHERE f.PRODUCTO_ID = pd.PRODUCTO_ID) as PROMEDIO_HISTORICO,
    -- Calcular crecimiento esperado
    ((AVG(CANTIDAD_PRONOSTICADA) / 
      (SELECT AVG(CANTIDAD_VENDIDA) 
       FROM FEATURES_VENTAS_TEMPORADA f 
       WHERE f.PRODUCTO_ID = pd.PRODUCTO_ID)) - 1) * 100 as CRECIMIENTO_ESPERADO_PORCENTUAL
FROM PRONOSTICOS_DETALLADOS pd
GROUP BY PRODUCTO_ID, NOMBRE_PRODUCTO, CATEGORIA
HAVING PROMEDIO_HISTORICO > 0
ORDER BY CRECIMIENTO_ESPERADO_PORCENTUAL DESC
LIMIT 10;

-- Recomendaciones de inventario basadas en pronósticos
CREATE OR REPLACE VIEW RECOMENDACIONES_INVENTARIO AS
SELECT 
    pd.PRODUCTO_ID,
    pd.NOMBRE_PRODUCTO,
    pd.CATEGORIA,
    AVG(pd.CANTIDAD_PRONOSTICADA) as DEMANDA_DIARIA_PROMEDIO,
    MAX(pd.CANTIDAD_PRONOSTICADA) as DEMANDA_DIARIA_MAXIMA,
    SUM(pd.CANTIDAD_PRONOSTICADA) as DEMANDA_TOTAL_30_DIAS,
    -- Recomendar stock de seguridad (demanda máxima + 20%)
    (MAX(pd.CANTIDAD_PRONOSTICADA) * 1.2)::INTEGER as STOCK_SEGURIDAD_RECOMENDADO,
    -- Stock recomendado para 30 días
    (SUM(pd.CANTIDAD_PRONOSTICADA) * 1.1)::INTEGER as STOCK_RECOMENDADO_30_DIAS,
    COALESCE(i.STOCK_ACTUAL, 0) as STOCK_ACTUAL,
    CASE 
        WHEN COALESCE(i.STOCK_ACTUAL, 0) < (MAX(pd.CANTIDAD_PRONOSTICADA) * 1.2) THEN 'REABASTECER URGENTE'
        WHEN COALESCE(i.STOCK_ACTUAL, 0) < (SUM(pd.CANTIDAD_PRONOSTICADA) * 0.5) THEN 'REABASTECER PRONTO'
        ELSE 'STOCK ADECUADO'
    END as RECOMENDACION
FROM PRONOSTICOS_DETALLADOS pd
LEFT JOIN (
    SELECT PRODUCTO_ID, SUM(STOCK_ACTUAL) as STOCK_ACTUAL
    FROM RAW_DATA.INVENTARIO_BACK_TO_SCHOOL 
    GROUP BY PRODUCTO_ID
) i ON pd.PRODUCTO_ID = i.PRODUCTO_ID
GROUP BY pd.PRODUCTO_ID, pd.NOMBRE_PRODUCTO, pd.CATEGORIA, i.STOCK_ACTUAL
ORDER BY DEMANDA_TOTAL_30_DIAS DESC;

-- Ver recomendaciones prioritarias
SELECT * FROM RECOMENDACIONES_INVENTARIO 
WHERE RECOMENDACION IN ('REABASTECER URGENTE', 'REABASTECER PRONTO')
ORDER BY DEMANDA_TOTAL_30_DIAS DESC;
```

### Paso 8: Dashboard de Pronósticos

```sql
-- Crear tabla resumen para dashboard ejecutivo
CREATE OR REPLACE TABLE DASHBOARD_PRONOSTICOS AS
SELECT 
    'RESUMEN_GENERAL' as TIPO_METRICA,
    NULL as CATEGORIA,
    COUNT(DISTINCT PRODUCTO_ID) as PRODUCTOS_ANALIZADOS,
    SUM(INGRESOS_PRONOSTICADOS) as INGRESOS_TOTALES_PRONOSTICADOS,
    AVG(CANTIDAD_PRONOSTICADA) as PROMEDIO_UNIDADES_DIARIAS,
    NULL as FECHA_VENTA
FROM PRONOSTICOS_DETALLADOS

UNION ALL

SELECT 
    'POR_CATEGORIA' as TIPO_METRICA,
    CATEGORIA,
    COUNT(DISTINCT PRODUCTO_ID) as PRODUCTOS_ANALIZADOS,
    SUM(INGRESOS_PRONOSTICADOS) as INGRESOS_TOTALES_PRONOSTICADOS,
    AVG(CANTIDAD_PRONOSTICADA) as PROMEDIO_UNIDADES_DIARIAS,
    NULL as FECHA_VENTA
FROM PRONOSTICOS_DETALLADOS
GROUP BY CATEGORIA

UNION ALL

SELECT 
    'TENDENCIA_DIARIA' as TIPO_METRICA,
    NULL as CATEGORIA,
    COUNT(DISTINCT PRODUCTO_ID) as PRODUCTOS_ANALIZADOS,
    SUM(INGRESOS_PRONOSTICADOS) as INGRESOS_TOTALES_PRONOSTICADOS,
    SUM(CANTIDAD_PRONOSTICADA) as PROMEDIO_UNIDADES_DIARIAS,
    FECHA_PRONOSTICO as FECHA_VENTA
FROM PRONOSTICOS_DETALLADOS
GROUP BY FECHA_PRONOSTICO
ORDER BY TIPO_METRICA, CATEGORIA, FECHA_VENTA;

-- Ver resumen ejecutivo
SELECT 
    TIPO_METRICA,
    CATEGORIA,
    PRODUCTOS_ANALIZADOS,
    INGRESOS_TOTALES_PRONOSTICADOS,
    PROMEDIO_UNIDADES_DIARIAS
FROM DASHBOARD_PRONOSTICOS 
WHERE TIPO_METRICA IN ('RESUMEN_GENERAL', 'POR_CATEGORIA')
ORDER BY INGRESOS_TOTALES_PRONOSTICADOS DESC;
```

Positive
: 🎯 **Resultado Esperado**: Con este modelo, OfficeMax puede anticipar la demanda de productos Back-to-School, optimizar inventarios y maximizar ventas durante la temporada alta.

## Conclusión y Próximos Pasos
Duration: 0:05:00

¡Felicidades! Has completado el quickstart de Snowflake para OfficeMax México. 

### 📋 Resumen de lo Aprendido

✅ **Time Travel**: Recuperación de datos históricos sin backups tradicionales  
✅ **Undrop**: Restauración rápida de objetos eliminados accidentalmente  
✅ **Zero Copy Cloning**: Creación de entornos de desarrollo sin costos adicionales  
✅ **Transformación JSON**: Procesamiento eficiente de datos semi-estructurados  
✅ **Control de Costos**: Monitoreo y optimización del gasto en Snowflake  
✅ **Desarrollo de Apps**: Integración con Python, Streamlit y APIs  
✅ **ML para Pronósticos**: Modelos predictivos usando funciones nativas de SQL  

### 🚀 Próximos Pasos Recomendados

1. **Implementar en Producción**
   - Configurar entorno productivo con datos reales
   - Establecer procesos de backup y recuperación
   - Implementar monitoreo de costos automático

2. **Expandir Capacidades de ML**
   - Experimentar con modelos más complejos (Random Forest, XGBoost)
   - Implementar modelos de clasificación para segmentación de clientes
   - Crear modelos de detección de anomalías en ventas

3. **Optimización Avanzada**
   - Configurar clustering keys para mejorar performance
   - Implementar particionamiento inteligente
   - Configurar materialised views para consultas frecuentes

4. **Integración Empresarial**
   - Conectar con sistemas ERP y CRM existentes
   - Implementar pipelines de datos en tiempo real
   - Crear alertas automáticas para el equipo de operaciones

### 📚 Recursos Adicionales

- [Documentación Oficial de Snowflake](https://docs.snowflake.com/)
- [Snowflake Community](https://community.snowflake.com/)
- [Guías de Mejores Prácticas](https://community.snowflake.com/s/article/getting-started-with-snowflake-best-practices)

### 💡 Casos de Uso Adicionales para OfficeMax

- **Análisis de Sentimientos**: Procesar reseñas de productos y redes sociales
- **Optimización de Precios**: Modelos dinámicos basados en competencia y demanda
- **Gestión de Promociones**: Análisis de efectividad de campañas marketing
- **Supply Chain Analytics**: Optimización de cadena de suministro
- **Customer 360**: Vista unificada del cliente across channels

Negative
: 📝 **Importante**: Este quickstart usa datos simulados. Para implementación en producción, adapta las consultas y modelos a tus datos reales y requisitos específicos de negocio.

---

### 🎉 ¡Gracias por Completar el Quickstart!

Has adquirido las habilidades fundamentales para aprovechar Snowflake en OfficeMax México. El siguiente paso es aplicar estos conocimientos con datos reales y expandir las capacidades según las necesidades específicas de tu equipo de BI.

**Tiempo total invertido**: ~70 minutos  
**Nivel de competencia alcanzado**: Intermedio-Avanzado  
**Próximo objetivo**: Implementación en producción  

¡Éxito en tus proyectos de analytics! 🚀

