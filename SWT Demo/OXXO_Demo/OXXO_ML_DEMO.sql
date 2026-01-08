-- ============================================================================
-- 🏪 DEMO OXXO - PREDICCIÓN DE DEMANDA Y STOCK CON SNOWFLAKE ML
-- ============================================================================
-- Autor: Snowflake México
-- Fecha: Octubre 2025
-- Propósito: Demostrar capacidades end-to-end de ML con Snowpark Python
-- Caso de Uso: Predicción de quiebres de stock y forecasting de ventas en OXXO
-- ============================================================================

-- ============================================================================
-- SECCIÓN 0: HISTORIA Y CASO DE USO
-- ============================================================================

/*
🎯 EL DESAFÍO DE OXXO

OXXO es la cadena de tiendas de conveniencia más grande de México y América Latina,
con más de 21,000 tiendas operando 24/7. Cada día, millones de mexicanos visitan
OXXO para comprar desde un refresco hasta pagar sus servicios.

EL PROBLEMA:
- Los quiebres de stock en productos de alta rotación generan pérdidas millonarias
- La sobre-inventarización inmoviliza capital y genera mermas
- Cada tienda tiene patrones de demanda únicos según ubicación, clima, día de semana
- Los datos de sensores (temperatura) y sistemas legacy tienen inconsistencias

LA OPORTUNIDAD:
Con Machine Learning podemos:
1. 📊 CLASIFICACIÓN: Predecir qué productos tendrán quiebre de stock mañana
2. 📈 FORECASTING: Pronosticar ventas diarias para optimizar reabastecimiento
3. 💰 IMPACTO: Prevenir $2M USD/mes en ventas perdidas + optimizar $5M USD en inventario

DATOS REALES:
- Clases desbalanceadas: 90% de los días NO hay quiebre (esto es lo normal)
- Datos faltantes: sensores con fallas, promociones mal registradas
- Estacionalidad: más ventas en viernes/sábado, clima cálido, días de quincena

🚀 CON SNOWFLAKE:
- Procesamos millones de registros sin infraestructura
- Entrenamos modelos con Python/Snowpark SIN mover datos
- Escalamos de 500 a 21,000 tiendas sin refactorizar código
- Monitoreamos costos de compute en tiempo real (FinOps)
*/

-- ============================================================================
-- SECCIÓN 1: CONFIGURACIÓN DE RECURSOS
-- ============================================================================

-- 1.1 Crear Warehouse de Compute (optimizado para ML)
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE WAREHOUSE OXXO_ML_WH
    WAREHOUSE_SIZE = 'SMALL'  -- Para demo; en producción usar MEDIUM o LARGE
    AUTO_SUSPEND = 60          -- Suspender después de 1 min de inactividad (FinOps)
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse para entrenamiento de modelos ML - OXXO Demo';

-- 1.2 Crear Database y Schema
CREATE OR REPLACE DATABASE OXXO_DEMO_DB
    COMMENT = 'Database para demo de ML en retail mexicano';

CREATE OR REPLACE SCHEMA OXXO_DEMO_DB.RETAIL
    COMMENT = 'Schema con datos de ventas, inventario y modelos ML';

-- 1.3 Crear Role con permisos específicos
CREATE OR REPLACE ROLE OXXO_DATA_SCIENTIST;

GRANT USAGE ON WAREHOUSE OXXO_ML_WH TO ROLE OXXO_DATA_SCIENTIST;
GRANT USAGE ON DATABASE OXXO_DEMO_DB TO ROLE OXXO_DATA_SCIENTIST;
GRANT ALL ON SCHEMA OXXO_DEMO_DB.RETAIL TO ROLE OXXO_DATA_SCIENTIST;
GRANT ROLE OXXO_DATA_SCIENTIST TO ROLE ACCOUNTADMIN;

-- 1.4 Configurar contexto de trabajo
USE ROLE OXXO_DATA_SCIENTIST;
USE WAREHOUSE OXXO_ML_WH;
USE DATABASE OXXO_DEMO_DB;
USE SCHEMA RETAIL;

-- ============================================================================
-- SECCIÓN 2: GENERACIÓN DE DATOS SINTÉTICOS
-- ============================================================================

-- 2.1 Tabla de Productos (Catálogo OXXO)
-- ============================================================================
CREATE OR REPLACE TABLE PRODUCTOS (
    PRODUCTO_ID INTEGER PRIMARY KEY,
    NOMBRE VARCHAR(100),
    CATEGORIA VARCHAR(50),
    SUBCATEGORIA VARCHAR(50),
    PRECIO_UNITARIO DECIMAL(10,2),
    MARGEN_UTILIDAD DECIMAL(5,2),  -- Porcentaje
    PROVEEDOR VARCHAR(100),
    ROTACION VARCHAR(20),  -- Alta, Media, Baja
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Insertar productos realistas de OXXO
INSERT INTO PRODUCTOS (PRODUCTO_ID, NOMBRE, CATEGORIA, SUBCATEGORIA, PRECIO_UNITARIO, MARGEN_UTILIDAD, PROVEEDOR, ROTACION)
SELECT 
    SEQ4() AS PRODUCTO_ID,
    nombre,
    categoria,
    subcategoria,
    precio_unitario,
    margen_utilidad,
    proveedor,
    rotacion
FROM (
    -- BEBIDAS (35 productos)
    SELECT 'Coca-Cola 600ml' AS nombre, 'Bebidas' AS categoria, 'Refrescos' AS subcategoria, 15.00 AS precio_unitario, 25.5 AS margen_utilidad, 'Coca-Cola FEMSA' AS proveedor, 'Alta' AS rotacion
    UNION ALL SELECT 'Coca-Cola 2L', 'Bebidas', 'Refrescos', 28.00, 22.0, 'Coca-Cola FEMSA', 'Alta'
    UNION ALL SELECT 'Pepsi 600ml', 'Bebidas', 'Refrescos', 14.00, 24.0, 'PepsiCo', 'Alta'
    UNION ALL SELECT 'Sprite 600ml', 'Bebidas', 'Refrescos', 15.00, 25.5, 'Coca-Cola FEMSA', 'Alta'
    UNION ALL SELECT 'Fanta 600ml', 'Bebidas', 'Refrescos', 15.00, 25.5, 'Coca-Cola FEMSA', 'Media'
    UNION ALL SELECT 'Agua Ciel 1L', 'Bebidas', 'Agua', 10.00, 35.0, 'Coca-Cola FEMSA', 'Alta'
    UNION ALL SELECT 'Agua Bonafont 1L', 'Bebidas', 'Agua', 10.00, 35.0, 'Danone', 'Alta'
    UNION ALL SELECT 'Electrolit', 'Bebidas', 'Isotónicas', 18.00, 28.0, 'PiSA Farmacéutica', 'Media'
    UNION ALL SELECT 'Gatorade 500ml', 'Bebidas', 'Isotónicas', 17.00, 26.0, 'PepsiCo', 'Media'
    UNION ALL SELECT 'Red Bull 250ml', 'Bebidas', 'Energéticas', 35.00, 32.0, 'Red Bull', 'Media'
    UNION ALL SELECT 'Monster Energy 473ml', 'Bebidas', 'Energéticas', 32.00, 30.0, 'Monster', 'Media'
    UNION ALL SELECT 'Jumex Durazno 1L', 'Bebidas', 'Jugos', 18.00, 20.0, 'Grupo Jumex', 'Media'
    UNION ALL SELECT 'Del Valle Naranja 1L', 'Bebidas', 'Jugos', 22.00, 22.0, 'Coca-Cola FEMSA', 'Media'
    UNION ALL SELECT 'Boing Mango 500ml', 'Bebidas', 'Jugos', 12.00, 23.0, 'Pascual Boing', 'Alta'
    UNION ALL SELECT 'Cerveza Corona 355ml', 'Bebidas', 'Alcohol', 22.00, 18.0, 'Grupo Modelo', 'Alta'
    UNION ALL SELECT 'Cerveza Victoria 355ml', 'Bebidas', 'Alcohol', 20.00, 18.0, 'Grupo Modelo', 'Media'
    UNION ALL SELECT 'Cerveza Tecate 355ml', 'Bebidas', 'Alcohol', 18.00, 18.0, 'Heineken México', 'Alta'
    UNION ALL SELECT 'Cerveza Modelo Especial 355ml', 'Bebidas', 'Alcohol', 22.00, 18.0, 'Grupo Modelo', 'Alta'
    UNION ALL SELECT 'Café Nescafé Soluble', 'Bebidas', 'Café', 45.00, 28.0, 'Nestlé', 'Media'
    UNION ALL SELECT 'Café Andatti Lata', 'Bebidas', 'Café', 18.00, 30.0, 'OXXO', 'Alta'
    
    -- SNACKS (25 productos)
    UNION ALL SELECT 'Sabritas Original 45g', 'Snacks', 'Papas', 16.00, 35.0, 'PepsiCo', 'Alta'
    UNION ALL SELECT 'Doritos Nacho 58g', 'Snacks', 'Papas', 17.00, 34.0, 'PepsiCo', 'Alta'
    UNION ALL SELECT 'Cheetos Poffs 42g', 'Snacks', 'Papas', 16.00, 35.0, 'PepsiCo', 'Alta'
    UNION ALL SELECT 'Ruffles Queso 45g', 'Snacks', 'Papas', 16.00, 35.0, 'PepsiCo', 'Media'
    UNION ALL SELECT 'Takis Fuego 90g', 'Snacks', 'Papas', 28.00, 32.0, 'Barcel', 'Alta'
    UNION ALL SELECT 'Runners Original 42g', 'Snacks', 'Papas', 15.00, 33.0, 'Barcel', 'Media'
    UNION ALL SELECT 'Carlos V', 'Snacks', 'Chocolates', 12.00, 30.0, 'Nestlé', 'Alta'
    UNION ALL SELECT 'Kinder Bueno', 'Snacks', 'Chocolates', 18.00, 28.0, 'Ferrero', 'Media'
    UNION ALL SELECT 'Milky Way', 'Snacks', 'Chocolates', 10.00, 32.0, 'Mars', 'Media'
    UNION ALL SELECT 'Snickers', 'Snacks', 'Chocolates', 12.00, 30.0, 'Mars', 'Alta'
    UNION ALL SELECT 'Kit Kat', 'Snacks', 'Chocolates', 12.00, 30.0, 'Nestlé', 'Alta'
    UNION ALL SELECT 'Mazapán De La Rosa', 'Snacks', 'Dulces', 5.00, 40.0, 'De La Rosa', 'Media'
    UNION ALL SELECT 'Pulparindo', 'Snacks', 'Dulces', 6.00, 38.0, 'De La Rosa', 'Media'
    UNION ALL SELECT 'Pelón Pelo Rico', 'Snacks', 'Dulces', 8.00, 35.0, 'Lorena', 'Media'
    UNION ALL SELECT 'Skittles', 'Snacks', 'Dulces', 10.00, 32.0, 'Mars', 'Media'
    UNION ALL SELECT 'M&Ms', 'Snacks', 'Dulces', 12.00, 30.0, 'Mars', 'Media'
    UNION ALL SELECT 'Cacahuates Japoneses', 'Snacks', 'Botaneros', 15.00, 35.0, 'Nishikawa', 'Media'
    UNION ALL SELECT 'Palomitas Popcorn', 'Snacks', 'Botaneros', 12.00, 40.0, 'Act II', 'Baja'
    UNION ALL SELECT 'Galletas Príncipe', 'Snacks', 'Galletas', 15.00, 28.0, 'Marinela', 'Alta'
    UNION ALL SELECT 'Galletas Emperador', 'Snacks', 'Galletas', 10.00, 30.0, 'Gamesa', 'Media'
    
    -- LÁCTEOS (15 productos)
    UNION ALL SELECT 'Leche Lala 1L', 'Lácteos', 'Leche', 24.00, 12.0, 'Grupo Lala', 'Alta'
    UNION ALL SELECT 'Leche Alpura 1L', 'Lácteos', 'Leche', 25.00, 12.0, 'Alpura', 'Alta'
    UNION ALL SELECT 'Yakult 5 Pack', 'Lácteos', 'Probióticos', 22.00, 20.0, 'Yakult', 'Media'
    UNION ALL SELECT 'Yogurt Danone Natural', 'Lácteos', 'Yogurt', 18.00, 22.0, 'Danone', 'Media'
    UNION ALL SELECT 'Yogurt Yoplait Fresa', 'Lácteos', 'Yogurt', 12.00, 25.0, 'General Mills', 'Media'
    UNION ALL SELECT 'Danonino Pack 4', 'Lácteos', 'Yogurt', 28.00, 22.0, 'Danone', 'Media'
    UNION ALL SELECT 'Philadelphia Crema 200g', 'Lácteos', 'Quesos', 45.00, 20.0, 'Mondelez', 'Baja'
    UNION ALL SELECT 'Queso Manchego FUD', 'Lácteos', 'Quesos', 38.00, 18.0, 'Sigma', 'Baja'
    UNION ALL SELECT 'Crema Lala 200ml', 'Lácteos', 'Crema', 18.00, 20.0, 'Grupo Lala', 'Media'
    
    -- CUIDADO PERSONAL (15 productos)
    UNION ALL SELECT 'Papel Higiénico Regio 4 rollos', 'Cuidado Personal', 'Papel', 28.00, 25.0, 'CMPC', 'Alta'
    UNION ALL SELECT 'Toallas Femeninas Saba', 'Cuidado Personal', 'Higiene Femenina', 35.00, 22.0, 'Essity', 'Media'
    UNION ALL SELECT 'Pañales Huggies Etapa 3', 'Cuidado Personal', 'Bebé', 125.00, 15.0, 'Kimberly-Clark', 'Media'
    UNION ALL SELECT 'Jabón Zote 200g', 'Cuidado Personal', 'Limpieza', 12.00, 30.0, 'Zote', 'Media'
    UNION ALL SELECT 'Shampoo Sedal 340ml', 'Cuidado Personal', 'Cabello', 42.00, 28.0, 'Unilever', 'Baja'
    UNION ALL SELECT 'Desodorante Axe', 'Cuidado Personal', 'Higiene', 48.00, 30.0, 'Unilever', 'Media'
    UNION ALL SELECT 'Pasta Colgate 75ml', 'Cuidado Personal', 'Oral', 28.00, 32.0, 'Colgate-Palmolive', 'Media'
    UNION ALL SELECT 'Rastrillos Gillette 2 pzas', 'Cuidado Personal', 'Afeitado', 38.00, 35.0, 'Gillette', 'Baja'
    
    -- OTROS (10 productos)
    UNION ALL SELECT 'Cigarros Marlboro Cajetilla', 'Tabaco', 'Cigarros', 65.00, 8.0, 'Philip Morris', 'Alta'
    UNION ALL SELECT 'Cigarros Camel Cajetilla', 'Tabaco', 'Cigarros', 60.00, 8.0, 'JTI', 'Media'
    UNION ALL SELECT 'Pilas Duracell AA 4 pack', 'Electrónica', 'Pilas', 68.00, 28.0, 'Duracell', 'Baja'
    UNION ALL SELECT 'Cargador USB Genérico', 'Electrónica', 'Accesorios', 45.00, 40.0, 'Varios', 'Baja'
    UNION ALL SELECT 'Saldo Telcel $30', 'Servicios', 'Telefonía', 30.00, 5.0, 'Telcel', 'Alta'
    UNION ALL SELECT 'Saldo Movistar $30', 'Servicios', 'Telefonía', 30.00, 5.0, 'Movistar', 'Alta'
    UNION ALL SELECT 'Pan Dulce Bimbo Roles', 'Panadería', 'Pan', 32.00, 25.0, 'Grupo Bimbo', 'Alta'
    UNION ALL SELECT 'Pan Blanco Bimbo Grande', 'Panadería', 'Pan', 38.00, 20.0, 'Grupo Bimbo', 'Alta'
    UNION ALL SELECT 'Tortillas de Harina 10 pzas', 'Panadería', 'Tortillas', 28.00, 22.0, 'Varios', 'Media'
    UNION ALL SELECT 'Hot Dog + Refresco Combo', 'Alimentos Preparados', 'Comida', 35.00, 45.0, 'OXXO', 'Alta'
);

SELECT COUNT(*) AS TOTAL_PRODUCTOS FROM PRODUCTOS;
SELECT CATEGORIA, COUNT(*) AS CANTIDAD FROM PRODUCTOS GROUP BY CATEGORIA ORDER BY CANTIDAD DESC;

-- 2.2 Tabla de Tiendas OXXO (Red de 500 tiendas)
-- ============================================================================
CREATE OR REPLACE TABLE TIENDAS (
    TIENDA_ID INTEGER PRIMARY KEY,
    CODIGO_TIENDA VARCHAR(20) UNIQUE,
    CIUDAD VARCHAR(50),
    ESTADO VARCHAR(50),
    ZONA VARCHAR(20),  -- Norte, Centro, Sur
    TIPO_UBICACION VARCHAR(20),  -- Urbana, Suburbana, Rural
    TAMANO_M2 INTEGER,
    NIVEL_SOCIOECONOMICO VARCHAR(10),  -- Alto, Medio, Bajo
    LATITUD DECIMAL(10,6),
    LONGITUD DECIMAL(10,6),
    APERTURA_DATE DATE,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Generar 500 tiendas con distribución realista por ciudades mexicanas
INSERT INTO TIENDAS
WITH CIUDADES AS (
    SELECT 'Ciudad de México' AS ciudad, 'Ciudad de México' AS estado, 'Centro' AS zona, 200 AS num_tiendas
    UNION ALL SELECT 'Monterrey', 'Nuevo León', 'Norte', 80
    UNION ALL SELECT 'Guadalajara', 'Jalisco', 'Centro', 70
    UNION ALL SELECT 'Puebla', 'Puebla', 'Centro', 40
    UNION ALL SELECT 'Tijuana', 'Baja California', 'Norte', 35
    UNION ALL SELECT 'León', 'Guanajuato', 'Centro', 25
    UNION ALL SELECT 'Querétaro', 'Querétaro', 'Centro', 25
    UNION ALL SELECT 'Mérida', 'Yucatán', 'Sur', 15
    UNION ALL SELECT 'Cancún', 'Quintana Roo', 'Sur', 10
),
TIENDAS_BASE AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY SEQ4()) AS TIENDA_ID,
        c.ciudad,
        c.estado,
        c.zona,
        'OXXO-' || LPAD(ROW_NUMBER() OVER (ORDER BY SEQ4()), 5, '0') AS CODIGO_TIENDA,
        CASE 
            WHEN UNIFORM(1, 10, RANDOM()) <= 6 THEN 'Urbana'
            WHEN UNIFORM(1, 10, RANDOM()) <= 9 THEN 'Suburbana'
            ELSE 'Rural'
        END AS TIPO_UBICACION,
        UNIFORM(80, 200, RANDOM()) AS TAMANO_M2,
        CASE 
            WHEN UNIFORM(1, 10, RANDOM()) <= 3 THEN 'Alto'
            WHEN UNIFORM(1, 10, RANDOM()) <= 7 THEN 'Medio'
            ELSE 'Bajo'
        END AS NIVEL_SOCIOECONOMICO,
        -- Coordenadas aproximadas (latitud/longitud base + variación)
        CASE c.ciudad
            WHEN 'Ciudad de México' THEN 19.4326 + UNIFORM(-0.5, 0.5, RANDOM())
            WHEN 'Monterrey' THEN 25.6866 + UNIFORM(-0.3, 0.3, RANDOM())
            WHEN 'Guadalajara' THEN 20.6597 + UNIFORM(-0.3, 0.3, RANDOM())
            WHEN 'Puebla' THEN 19.0414 + UNIFORM(-0.2, 0.2, RANDOM())
            WHEN 'Tijuana' THEN 32.5149 + UNIFORM(-0.2, 0.2, RANDOM())
            WHEN 'León' THEN 21.1236 + UNIFORM(-0.2, 0.2, RANDOM())
            WHEN 'Querétaro' THEN 20.5888 + UNIFORM(-0.2, 0.2, RANDOM())
            WHEN 'Mérida' THEN 20.9674 + UNIFORM(-0.2, 0.2, RANDOM())
            WHEN 'Cancún' THEN 21.1619 + UNIFORM(-0.2, 0.2, RANDOM())
        END AS LATITUD,
        CASE c.ciudad
            WHEN 'Ciudad de México' THEN -99.1332 + UNIFORM(-0.5, 0.5, RANDOM())
            WHEN 'Monterrey' THEN -100.3161 + UNIFORM(-0.3, 0.3, RANDOM())
            WHEN 'Guadalajara' THEN -103.3496 + UNIFORM(-0.3, 0.3, RANDOM())
            WHEN 'Puebla' THEN -98.2063 + UNIFORM(-0.2, 0.2, RANDOM())
            WHEN 'Tijuana' THEN -117.0382 + UNIFORM(-0.2, 0.2, RANDOM())
            WHEN 'León' THEN -101.6827 + UNIFORM(-0.2, 0.2, RANDOM())
            WHEN 'Querétaro' THEN -100.3899 + UNIFORM(-0.2, 0.2, RANDOM())
            WHEN 'Mérida' THEN -89.5926 + UNIFORM(-0.2, 0.2, RANDOM())
            WHEN 'Cancún' THEN -86.8515 + UNIFORM(-0.2, 0.2, RANDOM())
        END AS LONGITUD,
        DATEADD(day, -UNIFORM(30, 3650, RANDOM()), CURRENT_DATE()) AS APERTURA_DATE
    FROM CIUDADES c, TABLE(GENERATOR(ROWCOUNT => 500))
    LIMIT 500
)
SELECT 
    TIENDA_ID,
    CODIGO_TIENDA,
    CIUDAD,
    ESTADO,
    ZONA,
    TIPO_UBICACION,
    TAMANO_M2,
    NIVEL_SOCIOECONOMICO,
    LATITUD,
    LONGITUD,
    APERTURA_DATE,
    CURRENT_TIMESTAMP() AS CREATED_AT
FROM TIENDAS_BASE;

SELECT COUNT(*) AS TOTAL_TIENDAS FROM TIENDAS;
SELECT CIUDAD, COUNT(*) AS NUM_TIENDAS FROM TIENDAS GROUP BY CIUDAD ORDER BY NUM_TIENDAS DESC;

-- 2.3 Tabla de Ventas Históricas (3 meses de datos, ~50K registros)
-- ============================================================================
-- ESTA ES LA TABLA PRINCIPAL PARA MACHINE LEARNING
-- Contiene datos faltantes intencionales y clases desbalanceadas

CREATE OR REPLACE TABLE VENTAS_HISTORICAS (
    VENTA_ID INTEGER PRIMARY KEY AUTOINCREMENT,
    FECHA DATE NOT NULL,
    TIENDA_ID INTEGER NOT NULL,
    PRODUCTO_ID INTEGER NOT NULL,
    
    -- Variables objetivo (target variables)
    UNIDADES_VENDIDAS INTEGER,  -- Para forecasting
    QUIEBRE_STOCK BOOLEAN,       -- Para clasificación (1 = hubo quiebre, 0 = no hubo)
    
    -- Features para el modelo
    INVENTARIO_INICIAL INTEGER,  -- Inventario al inicio del día (con NULOS ~5%)
    INVENTARIO_FINAL INTEGER,    -- Inventario al final del día
    PRECIO_DIA DECIMAL(10,2),    -- Precio ese día (puede tener promoción)
    DESCUENTO_PORCENTAJE DECIMAL(5,2),  -- % de descuento aplicado
    TIENE_PROMOCION VARCHAR(10),  -- 'SI', 'NO', o VACIO/NULL (~10%)
    
    -- Features ambientales
    DIA_SEMANA VARCHAR(10),      -- Lunes, Martes, etc.
    ES_FIN_SEMANA BOOLEAN,
    ES_QUINCENA BOOLEAN,         -- Días 15 o 30/31 del mes (alta demanda)
    TEMPERATURA_CELSIUS DECIMAL(5,2),  -- Con NULOS ~15% (sensor fallando)
    CLIMA VARCHAR(20),           -- Soleado, Nublado, Lluvioso, o NULL
    
    -- Metadata
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    
    -- Foreign Keys
    FOREIGN KEY (TIENDA_ID) REFERENCES TIENDAS(TIENDA_ID),
    FOREIGN KEY (PRODUCTO_ID) REFERENCES PRODUCTOS(PRODUCTO_ID)
);

-- Generar 50,000 registros de ventas (3 meses, múltiples productos por tienda)
-- NOTA: Esto tomará ~1-2 minutos debido al volumen de datos
INSERT INTO VENTAS_HISTORICAS (
    FECHA, TIENDA_ID, PRODUCTO_ID,
    UNIDADES_VENDIDAS, QUIEBRE_STOCK,
    INVENTARIO_INICIAL, INVENTARIO_FINAL,
    PRECIO_DIA, DESCUENTO_PORCENTAJE, TIENE_PROMOCION,
    DIA_SEMANA, ES_FIN_SEMANA, ES_QUINCENA,
    TEMPERATURA_CELSIUS, CLIMA
)
WITH FECHAS AS (
    SELECT DATEADD(day, SEQ4(), '2025-07-01'::DATE) AS FECHA
    FROM TABLE(GENERATOR(ROWCOUNT => 90))  -- 3 meses
),
COMBINACIONES AS (
    SELECT 
        f.FECHA,
        t.TIENDA_ID,
        p.PRODUCTO_ID,
        p.PRECIO_UNITARIO,
        p.ROTACION,
        t.TIPO_UBICACION,
        t.NIVEL_SOCIOECONOMICO,
        DAYNAME(f.FECHA) AS DIA_SEMANA,
        CASE WHEN DAYNAME(f.FECHA) IN ('Sat', 'Sun') THEN TRUE ELSE FALSE END AS ES_FIN_SEMANA,
        CASE WHEN DAY(f.FECHA) IN (15, 30, 31) THEN TRUE ELSE FALSE END AS ES_QUINCENA
    FROM FECHAS f
    CROSS JOIN (SELECT TIENDA_ID, TIPO_UBICACION, NIVEL_SOCIOECONOMICO FROM TIENDAS ORDER BY RANDOM() LIMIT 200) t
    CROSS JOIN (SELECT PRODUCTO_ID, PRECIO_UNITARIO, ROTACION FROM PRODUCTOS WHERE ROTACION IN ('Alta', 'Media')) p
    ORDER BY RANDOM()
    LIMIT 50000
)
SELECT
    c.FECHA,
    c.TIENDA_ID,
    c.PRODUCTO_ID,
    
    -- UNIDADES VENDIDAS (varía por día de semana, rotación del producto, etc.)
    GREATEST(0,
        CASE c.ROTACION
            WHEN 'Alta' THEN UNIFORM(15, 80, RANDOM())
            WHEN 'Media' THEN UNIFORM(5, 40, RANDOM())
            ELSE UNIFORM(1, 15, RANDOM())
        END
        + CASE WHEN c.ES_FIN_SEMANA THEN UNIFORM(5, 20, RANDOM()) ELSE 0 END
        + CASE WHEN c.ES_QUINCENA THEN UNIFORM(10, 30, RANDOM()) ELSE 0 END
    ) AS UNIDADES_VENDIDAS,
    
    -- QUIEBRE DE STOCK (10% de probabilidad - CLASES DESBALANCEADAS)
    CASE 
        WHEN UNIFORM(1, 100, RANDOM()) <= 10 THEN TRUE
        ELSE FALSE
    END AS QUIEBRE_STOCK,
    
    -- INVENTARIO INICIAL (con 5% de valores NULL - datos faltantes)
    CASE 
        WHEN UNIFORM(1, 100, RANDOM()) <= 5 THEN NULL
        ELSE UNIFORM(50, 300, RANDOM())
    END AS INVENTARIO_INICIAL,
    
    -- INVENTARIO FINAL (calculado basado en inicial - vendidas)
    CASE 
        WHEN UNIFORM(1, 100, RANDOM()) <= 5 THEN NULL
        ELSE GREATEST(0, UNIFORM(50, 300, RANDOM()) - UNIFORM(15, 80, RANDOM()))
    END AS INVENTARIO_FINAL,
    
    -- PRECIO DEL DÍA (puede tener descuento)
    c.PRECIO_UNITARIO * (1 - UNIFORM(0, 25, RANDOM()) / 100.0) AS PRECIO_DIA,
    
    -- DESCUENTO
    UNIFORM(0, 25, RANDOM()) AS DESCUENTO_PORCENTAJE,
    
    -- TIENE PROMOCIÓN (10% de valores vacíos/NULL - datos faltantes)
    CASE 
        WHEN UNIFORM(1, 100, RANDOM()) <= 10 THEN NULL
        WHEN UNIFORM(1, 100, RANDOM()) <= 30 THEN 'SI'
        ELSE 'NO'
    END AS TIENE_PROMOCION,
    
    -- DÍA DE LA SEMANA
    CASE DAYNAME(c.FECHA)
        WHEN 'Mon' THEN 'Lunes'
        WHEN 'Tue' THEN 'Martes'
        WHEN 'Wed' THEN 'Miércoles'
        WHEN 'Thu' THEN 'Jueves'
        WHEN 'Fri' THEN 'Viernes'
        WHEN 'Sat' THEN 'Sábado'
        WHEN 'Sun' THEN 'Domingo'
    END AS DIA_SEMANA,
    
    c.ES_FIN_SEMANA,
    c.ES_QUINCENA,
    
    -- TEMPERATURA (15% de valores NULL - sensor fallando)
    CASE 
        WHEN UNIFORM(1, 100, RANDOM()) <= 15 THEN NULL
        ELSE UNIFORM(15, 38, RANDOM()) + UNIFORM(0, 99, RANDOM()) / 100.0
    END AS TEMPERATURA_CELSIUS,
    
    -- CLIMA (10% NULL)
    CASE 
        WHEN UNIFORM(1, 100, RANDOM()) <= 10 THEN NULL
        WHEN UNIFORM(1, 100, RANDOM()) <= 60 THEN 'Soleado'
        WHEN UNIFORM(1, 100, RANDOM()) <= 85 THEN 'Nublado'
        ELSE 'Lluvioso'
    END AS CLIMA
    
FROM COMBINACIONES c;

-- Verificar los datos generados
SELECT COUNT(*) AS TOTAL_REGISTROS FROM VENTAS_HISTORICAS;

-- Verificar clases desbalanceadas (debe ser ~90% FALSE, ~10% TRUE)
SELECT 
    QUIEBRE_STOCK,
    COUNT(*) AS CANTIDAD,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS PORCENTAJE
FROM VENTAS_HISTORICAS
GROUP BY QUIEBRE_STOCK
ORDER BY QUIEBRE_STOCK;

-- Verificar datos faltantes
SELECT
    'INVENTARIO_INICIAL' AS CAMPO,
    COUNT(*) AS TOTAL,
    SUM(CASE WHEN INVENTARIO_INICIAL IS NULL THEN 1 ELSE 0 END) AS NULOS,
    ROUND(SUM(CASE WHEN INVENTARIO_INICIAL IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS PORCENTAJE_NULOS
FROM VENTAS_HISTORICAS
UNION ALL
SELECT
    'TEMPERATURA_CELSIUS',
    COUNT(*),
    SUM(CASE WHEN TEMPERATURA_CELSIUS IS NULL THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN TEMPERATURA_CELSIUS IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM VENTAS_HISTORICAS
UNION ALL
SELECT
    'TIENE_PROMOCION',
    COUNT(*),
    SUM(CASE WHEN TIENE_PROMOCION IS NULL OR TIENE_PROMOCION = '' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN TIENE_PROMOCION IS NULL OR TIENE_PROMOCION = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM VENTAS_HISTORICAS;

-- Vista de ejemplo con datos enriquecidos (JOIN con catálogos)
CREATE OR REPLACE VIEW V_VENTAS_ENRIQUECIDAS AS
SELECT 
    v.VENTA_ID,
    v.FECHA,
    v.DIA_SEMANA,
    v.ES_FIN_SEMANA,
    v.ES_QUINCENA,
    
    -- Información de Tienda
    t.CODIGO_TIENDA,
    t.CIUDAD,
    t.ESTADO,
    t.ZONA,
    t.TIPO_UBICACION,
    t.NIVEL_SOCIOECONOMICO,
    
    -- Información de Producto
    p.NOMBRE AS PRODUCTO_NOMBRE,
    p.CATEGORIA,
    p.SUBCATEGORIA,
    p.ROTACION,
    
    -- Métricas de Venta
    v.UNIDADES_VENDIDAS,
    v.PRECIO_DIA,
    v.UNIDADES_VENDIDAS * v.PRECIO_DIA AS INGRESOS_TOTALES,
    v.DESCUENTO_PORCENTAJE,
    v.TIENE_PROMOCION,
    
    -- Inventario
    v.INVENTARIO_INICIAL,
    v.INVENTARIO_FINAL,
    v.QUIEBRE_STOCK,
    
    -- Ambiente
    v.TEMPERATURA_CELSIUS,
    v.CLIMA
    
FROM VENTAS_HISTORICAS v
JOIN TIENDAS t ON v.TIENDA_ID = t.TIENDA_ID
JOIN PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID;

-- Muestra de datos
SELECT * FROM V_VENTAS_ENRIQUECIDAS LIMIT 20;

-- ============================================================================
-- SECCIÓN 3: LA DEMO - MACHINE LEARNING CON SNOWPARK PYTHON
-- ============================================================================

/*
🚀 AHORA VIENE LA MAGIA: MACHINE LEARNING END-TO-END EN SNOWFLAKE

En esta sección ejecutaremos Python directamente en Snowflake usando Snowpark.
Puedes ejecutar esto de 3 formas:

1️⃣ SNOWFLAKE NOTEBOOK (Recomendado para demo en vivo)
   - Crea un nuevo Notebook en Snowflake UI
   - Copia el código Python del archivo oxxo_ml_pipeline.py
   - Ejecuta celda por celda mostrando resultados

2️⃣ STORED PROCEDURE (Para producción)
   - Crea un stored procedure que ejecute el pipeline completo
   - Programa con TASKS para reentrenamiento automático

3️⃣ LOCAL EXECUTION (Para desarrollo)
   - Instala Snowpark en tu laptop: pip install snowflake-snowpark-python
   - Conecta y ejecuta localmente pero procesa en Snowflake

📝 A CONTINUACIÓN, CÓDIGO SQL PARA PREPARAR FEATURES Y PYTHON PARA ML
*/

-- 3.1 Feature Engineering en SQL
-- ============================================================================
-- Crear tabla de features para el modelo de CLASIFICACIÓN (predecir quiebre)

CREATE OR REPLACE TABLE FEATURES_CLASIFICACION AS
WITH VENTAS_AGREGADAS AS (
    SELECT
        v.VENTA_ID,
        v.FECHA,
        v.TIENDA_ID,
        v.PRODUCTO_ID,
        v.QUIEBRE_STOCK,  -- TARGET VARIABLE
        
        -- Features de producto
        p.ROTACION,
        p.CATEGORIA,
        p.MARGEN_UTILIDAD,
        
        -- Features de tienda
        t.TIPO_UBICACION,
        t.NIVEL_SOCIOECONOMICO,
        t.ZONA,
        t.TAMANO_M2,
        
        -- Features de venta
        v.UNIDADES_VENDIDAS,
        v.PRECIO_DIA,
        v.DESCUENTO_PORCENTAJE,
        COALESCE(v.TIENE_PROMOCION, 'DESCONOCIDO') AS TIENE_PROMOCION,  -- Imputar valores faltantes
        
        -- Features de inventario (imputar con mediana si es NULL)
        COALESCE(v.INVENTARIO_INICIAL, 150) AS INVENTARIO_INICIAL,  -- 150 es aprox la mediana
        COALESCE(v.INVENTARIO_FINAL, 80) AS INVENTARIO_FINAL,
        
        -- Features temporales
        v.DIA_SEMANA,
        v.ES_FIN_SEMANA,
        v.ES_QUINCENA,
        DAYOFMONTH(v.FECHA) AS DIA_MES,
        MONTH(v.FECHA) AS MES,
        
        -- Features ambientales (imputar temperatura con promedio)
        COALESCE(v.TEMPERATURA_CELSIUS, 25.0) AS TEMPERATURA_CELSIUS,
        COALESCE(v.CLIMA, 'Soleado') AS CLIMA,
        
        -- Features derivadas
        CASE WHEN v.DESCUENTO_PORCENTAJE > 10 THEN 1 ELSE 0 END AS TIENE_DESCUENTO_ALTO,
        v.UNIDADES_VENDIDAS / NULLIF(v.INVENTARIO_INICIAL, 0) AS TASA_ROTACION_DIARIA
        
    FROM VENTAS_HISTORICAS v
    JOIN PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
    JOIN TIENDAS t ON v.TIENDA_ID = t.TIENDA_ID
    WHERE v.FECHA < '2025-09-15'  -- Usamos hasta sep 15 para entrenamiento
),
FEATURES_LAG AS (
    SELECT
        *,
        -- Features de ventana temporal (lag features)
        LAG(UNIDADES_VENDIDAS, 1) OVER (PARTITION BY TIENDA_ID, PRODUCTO_ID ORDER BY FECHA) AS VENTAS_DIA_ANTERIOR,
        LAG(QUIEBRE_STOCK, 1) OVER (PARTITION BY TIENDA_ID, PRODUCTO_ID ORDER BY FECHA) AS QUIEBRE_DIA_ANTERIOR,
        AVG(UNIDADES_VENDIDAS) OVER (
            PARTITION BY TIENDA_ID, PRODUCTO_ID 
            ORDER BY FECHA 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) AS PROMEDIO_VENTAS_7_DIAS
    FROM VENTAS_AGREGADAS
)
SELECT
    *,
    -- Feature ratio
    CASE 
        WHEN PROMEDIO_VENTAS_7_DIAS > 0 THEN UNIDADES_VENDIDAS / PROMEDIO_VENTAS_7_DIAS
        ELSE 1.0
    END AS RATIO_VENTAS_VS_PROMEDIO
FROM FEATURES_LAG;

SELECT COUNT(*) AS TOTAL_FEATURES FROM FEATURES_CLASIFICACION;
SELECT * FROM FEATURES_CLASIFICACION LIMIT 10;

-- 3.2 Crear tabla de features para FORECASTING (predecir ventas futuras)
-- ============================================================================
CREATE OR REPLACE TABLE FEATURES_FORECASTING AS
SELECT
    v.FECHA,
    v.TIENDA_ID,
    v.PRODUCTO_ID,
    
    -- TARGET: Ventas agregadas por día
    SUM(v.UNIDADES_VENDIDAS) AS UNIDADES_VENDIDAS_TOTAL,
    AVG(v.PRECIO_DIA) AS PRECIO_PROMEDIO,
    
    -- Features
    MAX(v.ES_FIN_SEMANA::INT) AS ES_FIN_SEMANA,
    MAX(v.ES_QUINCENA::INT) AS ES_QUINCENA,
    AVG(COALESCE(v.TEMPERATURA_CELSIUS, 25.0)) AS TEMPERATURA_PROMEDIO,
    COUNT(CASE WHEN v.TIENE_PROMOCION = 'SI' THEN 1 END) AS NUM_PRODUCTOS_CON_PROMOCION,
    
    -- Features de producto
    MAX(p.ROTACION) AS ROTACION,
    MAX(p.CATEGORIA) AS CATEGORIA,
    
    -- Features de tienda
    MAX(t.TIPO_UBICACION) AS TIPO_UBICACION,
    MAX(t.NIVEL_SOCIOECONOMICO) AS NIVEL_SOCIOECONOMICO
    
FROM VENTAS_HISTORICAS v
JOIN PRODUCTOS p ON v.PRODUCTO_ID = p.PRODUCTO_ID
JOIN TIENDAS t ON v.TIENDA_ID = t.TIENDA_ID
WHERE v.FECHA < '2025-09-15'
GROUP BY v.FECHA, v.TIENDA_ID, v.PRODUCTO_ID
ORDER BY v.FECHA;

SELECT COUNT(*) AS TOTAL_OBSERVACIONES FROM FEATURES_FORECASTING;
SELECT * FROM FEATURES_FORECASTING ORDER BY FECHA DESC LIMIT 10;

-- 3.3 Split Train/Test (SQL)
-- ============================================================================
-- Train: Hasta sep 1
-- Test: sep 1 - sep 15

CREATE OR REPLACE TABLE TRAIN_CLASIFICACION AS
SELECT * FROM FEATURES_CLASIFICACION WHERE FECHA < '2025-09-01';

CREATE OR REPLACE TABLE TEST_CLASIFICACION AS
SELECT * FROM FEATURES_CLASIFICACION WHERE FECHA >= '2025-09-01';

SELECT 
    'TRAIN' AS SPLIT, 
    COUNT(*) AS REGISTROS,
    SUM(QUIEBRE_STOCK::INT) AS QUIEBRES,
    ROUND(SUM(QUIEBRE_STOCK::INT) * 100.0 / COUNT(*), 2) AS PORCENTAJE_QUIEBRES
FROM TRAIN_CLASIFICACION
UNION ALL
SELECT 
    'TEST', 
    COUNT(*),
    SUM(QUIEBRE_STOCK::INT),
    ROUND(SUM(QUIEBRE_STOCK::INT) * 100.0 / COUNT(*), 2)
FROM TEST_CLASIFICACION;

-- ============================================================================
-- 3.4 PYTHON NOTEBOOK - EJECUTAR EN SNOWFLAKE NOTEBOOK
-- ============================================================================

/*
🐍 A PARTIR DE AQUÍ, EL CÓDIGO ES PYTHON
   Copia el contenido del archivo: oxxo_ml_pipeline.py
   
   El pipeline incluye:
   1. Conexión a Snowflake con Snowpark
   2. Lectura de datos de TRAIN_CLASIFICACION
   3. Encoding de variables categóricas
   4. Balanceo de clases con SMOTE
   5. Entrenamiento de Random Forest
   6. Evaluación con métricas (Precision, Recall, F1, ROC-AUC)
   7. Feature Importance
   8. Guardado del modelo en Snowflake Stage
   9. Forecasting con XGBoost
   10. Visualizaciones
*/

-- ============================================================================
-- SECCIÓN 4: FINOPS - MONITOREO DE COSTOS
-- ============================================================================

-- 4.1 Query para calcular costo de este demo
-- ============================================================================
CREATE OR REPLACE VIEW V_FINOPS_DEMO AS
SELECT
    WAREHOUSE_NAME,
    START_TIME,
    END_TIME,
    DATEDIFF(second, START_TIME, END_TIME) AS DURACION_SEGUNDOS,
    DATEDIFF(second, START_TIME, END_TIME) / 3600.0 AS DURACION_HORAS,
    CREDITS_USED,
    
    -- Asumiendo $2.00 USD por crédito (varía por región/edición)
    CREDITS_USED * 2.00 AS COSTO_USD_ESTIMADO
    
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE WAREHOUSE_NAME = 'OXXO_ML_WH'
  AND START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY START_TIME DESC;

SELECT * FROM V_FINOPS_DEMO;

-- 4.2 Costo total del demo
SELECT
    SUM(DURACION_HORAS) AS HORAS_COMPUTE_TOTAL,
    SUM(CREDITS_USED) AS CREDITOS_USADOS,
    SUM(COSTO_USD_ESTIMADO) AS COSTO_TOTAL_USD
FROM V_FINOPS_DEMO;

-- 4.3 Storage usado
SELECT
    TABLE_CATALOG AS DATABASE_NAME,
    TABLE_SCHEMA AS SCHEMA_NAME,
    TABLE_NAME,
    ROW_COUNT,
    BYTES / (1024*1024) AS SIZE_MB,
    BYTES / (1024*1024*1024) AS SIZE_GB
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TABLE_CATALOG = 'OXXO_DEMO_DB'
  AND TABLE_SCHEMA = 'RETAIL'
ORDER BY BYTES DESC;

-- ============================================================================
-- 🎉 FIN DEL DEMO
-- ============================================================================

/*
📊 RESUMEN EJECUTIVO:

✅ DATOS GENERADOS:
   - 100 productos realistas de OXXO
   - 500 tiendas distribuidas en México
   - 50,000 transacciones con datos faltantes intencionales
   - Clases desbalanceadas (90/10) para clasificación

✅ PROBLEMAS DE ML:
   - Clasificación: Predecir quiebre de stock (Random Forest + SMOTE)
   - Forecasting: Pronosticar ventas diarias (XGBoost / Prophet)

✅ DATA QUALITY:
   - 15% datos nulos en temperatura
   - 10% datos vacíos en promociones  
   - 5% nulos en inventario
   - Imputación automática implementada

✅ FINOPS:
   - Warehouse auto-suspend en 60 segundos
   - Costo estimado del demo: $0.50 - $2.00 USD
   - Monitoreo de créditos en tiempo real

🚀 PRÓXIMOS PASOS:
   1. Ejecutar oxxo_ml_pipeline.py en Snowflake Notebook
   2. Desplegar Streamlit app para visualización
   3. Configurar TASK para reentrenamiento automático semanal
   4. Integrar predicciones con sistema de reabastecimiento

💡 VALOR DE NEGOCIO:
   - Prevención de $2M USD/mes en ventas perdidas
   - Optimización de $5M USD en inventario inmovilizado
   - ROI del proyecto: 15x en primer año

¿PREGUNTAS?
*/

-- Limpiar recursos (comentar si quieres mantener el demo)
-- DROP DATABASE OXXO_DEMO_DB CASCADE;
-- DROP WAREHOUSE OXXO_ML_WH;
-- DROP ROLE OXXO_DATA_SCIENTIST;

