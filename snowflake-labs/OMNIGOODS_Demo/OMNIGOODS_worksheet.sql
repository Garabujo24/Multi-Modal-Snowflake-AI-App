-- OMNIGOODS CORTEX DEMO
-- Author: Data Engineer & AI Specialist
-- Date: 2025-09-10
-- Version: 1.0

--------------------------------------------------------------------------------------------------
-- Section 0: Story and Use Case
--------------------------------------------------------------------------------------------------
-- La historia sigue a OMNIGOODS, una empresa de retail y comercio electrónico en crecimiento
-- que busca aprovechar la inteligencia artificial para mejorar su negocio.
--
-- OMNIGOODS quiere:
-- 1.  **Entender a sus clientes a un nivel más profundo**: ¿Qué opinan de los productos?
--     (Análisis de Sentimientos sobre reseñas de productos).
-- 2.  **Optimizar su catálogo de productos**: ¿Cómo pueden describir mejor sus productos para
--     aumentar las ventas? (Generación de texto con IA).
-- 3.  **Acceder rápidamente a conocimiento interno**: ¿Cómo pueden sus empleados encontrar
--     respuestas en manuales de productos sin leerlos por completo? (Búsqueda en documentos).
-- 4.  **Predecir el futuro del negocio**: ¿Cuál será la demanda de productos en los próximos meses
--     para optimizar el inventario? (Pronóstico de series temporales).
-- 5.  **Tomar decisiones basadas en datos de forma conversacional**: Permitir a los analistas de
--     negocio hacer preguntas en lenguaje natural. (Cortex Analyst).
--
-- Este worksheet demuestra cómo Snowflake Cortex puede resolver estos desafíos directamente en la
-- plataforma de datos, de forma segura, gobernada y eficiente.
--------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------
-- Section 1: Resource Setup
--------------------------------------------------------------------------------------------------
-- Creación de todos los recursos de Snowflake necesarios para la demo.
-- Todos los recursos están prefijados con "OMNIGOODS_" para una fácil identificación y limpieza.
--------------------------------------------------------------------------------------------------

-- Usar un rol con permisos para crear bases de datos, warehouses, etc.
USE ROLE ACCOUNTADMIN;

-- Creación del Rol, Warehouse, Base de Datos y Schema
CREATE OR REPLACE ROLE OMNIGOODS_DEMO_ROLE;
CREATE OR REPLACE WAREHOUSE OMNIGOODS_DEMO_WH WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60;
CREATE OR REPLACE DATABASE OMNIGOODS_DB;
CREATE OR REPLACE SCHEMA OMNIGOODS_DB.RAW;

-- Conceder privilegios al nuevo rol
GRANT USAGE ON WAREHOUSE OMNIGOODS_DEMO_WH TO ROLE OMNIGOODS_DEMO_ROLE;
GRANT USAGE ON DATABASE OMNIGOODS_DB TO ROLE OMNIGOODS_DEMO_ROLE;
GRANT USAGE ON SCHEMA OMNIGOODS_DB.RAW TO ROLE OMNIGOODS_DEMO_ROLE;
GRANT CREATE TABLE ON SCHEMA OMNIGOODS_DB.RAW TO ROLE OMNIGOODS_DEMO_ROLE;
GRANT CREATE STAGE ON SCHEMA OMNIGOODS_DB.RAW TO ROLE OMNIGOODS_DEMO_ROLE;
GRANT CREATE FILE FORMAT ON SCHEMA OMNIGOODS_DB.RAW TO ROLE OMNIGOODS_DEMO_ROLE;

-- Privilegios específicos para Cortex Search
GRANT CREATE CORTEX SEARCH SERVICE ON SCHEMA OMNIGOODS_DB.RAW TO ROLE OMNIGOODS_DEMO_ROLE;
GRANT USAGE ON INTEGRATION CORTEX_USER_SEARCH_INTEGRATION TO ROLE OMNIGOODS_DEMO_ROLE;


-- Asignar rol al usuario actual (reemplazar 'TU_USUARIO' con tu nombre de usuario)
-- GRANT ROLE OMNIGOODS_DEMO_ROLE TO USER TU_USUARIO;

-- Cambiar al contexto de la demo
USE ROLE OMNIGOODS_DEMO_ROLE;
USE WAREHOUSE OMNIGOODS_DEMO_WH;
USE DATABASE OMNIGOODS_DB;
USE SCHEMA RAW;


-- Creación de las tablas para datos estructurados
CREATE OR REPLACE TABLE CUSTOMERS (
    CUSTOMER_ID INT,
    CUSTOMER_NAME VARCHAR,
    EMAIL VARCHAR,
    LOCATION VARCHAR
);

CREATE OR REPLACE TABLE PRODUCTS (
    PRODUCT_ID INT,
    PRODUCT_NAME VARCHAR,
    CATEGORY VARCHAR,
    PRICE FLOAT,
    IMAGE_URL VARCHAR -- Para la demo multimodal
);

CREATE OR REPLACE TABLE SALES (
    SALE_ID INT,
    CUSTOMER_ID INT,
    PRODUCT_ID INT,
    SALE_DATE DATE,
    QUANTITY INT,
    TOTAL_PRICE FLOAT
);

CREATE OR REPLACE TABLE CUSTOMER_REVIEWS (
    REVIEW_ID INT,
    PRODUCT_ID INT,
    CUSTOMER_ID INT,
    REVIEW_DATE DATE,
    REVIEW_TEXT VARCHAR
);


-- Creación de un Stage para datos no estructurados (manuales en PDF/TXT)
CREATE OR REPLACE STAGE OMNIGOODS_DOCS;


--------------------------------------------------------------------------------------------------
-- Section 2: Synthetic Data Generation
--------------------------------------------------------------------------------------------------
-- Inserción de datos sintéticos y realistas para simular el negocio de OMNIGOODS.
--------------------------------------------------------------------------------------------------

INSERT INTO CUSTOMERS (CUSTOMER_ID, CUSTOMER_NAME, EMAIL, LOCATION) VALUES
(1, 'Ana Torres', 'ana.t@example.com', 'Madrid'),
(2, 'Bruno Diaz', 'bruno.d@example.com', 'Barcelona'),
(3, 'Carla Gomez', 'carla.g@example.com', 'Valencia'),
(4, 'David Ruiz', 'david.r@example.com', 'Sevilla');

INSERT INTO PRODUCTS (PRODUCT_ID, PRODUCT_NAME, CATEGORY, PRICE, IMAGE_URL) VALUES
(101, 'OMNIGOODS Smartwatch Pro', 'Electronics', 299.99, 'https://storage.googleapis.com/omnigoods-demo-images/smartwatch.jpg'),
(102, 'OMNIGOODS Auriculares Inalámbricos', 'Electronics', 149.99, 'https://storage.googleapis.com/omnigoods-demo-images/headphones.jpg'),
(201, 'OMNIGOODS Zapatillas Runner', 'Footwear', 89.99, 'https://storage.googleapis.com/omnigoods-demo-images/shoes.jpg'),
(301, 'OMNIGOODS Mochila Urbana', 'Accessories', 59.99, 'https://storage.googleapis.com/omnigoods-demo-images/backpack.jpg');

-- Generar ventas para los últimos 12 meses
INSERT INTO SALES (SALE_ID, CUSTOMER_ID, PRODUCT_ID, SALE_DATE, QUANTITY, TOTAL_PRICE)
WITH dates AS (
    SELECT DATEADD('day', -ROW_NUMBER() OVER (ORDER BY seq4()), CURRENT_DATE()) as sale_date
    FROM TABLE(GENERATOR(ROWCOUNT => 365))
),
sales_data AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY sale_date, p.PRODUCT_ID) as sale_id,
        c.CUSTOMER_ID,
        p.PRODUCT_ID,
        d.sale_date,
        UNIFORM(1, 3, RANDOM()) as quantity,
        (quantity * p.PRICE) as total_price
    FROM dates d
    CROSS JOIN PRODUCTS p
    CROSS JOIN CUSTOMERS c
    WHERE DAYOFWEEK(d.sale_date) IN (5, 6, 0) -- Simular más ventas los fines de semana
    AND UNIFORM(1, 100, RANDOM()) > 50 -- No todos los clientes compran todos los productos todos los días
)
SELECT * FROM sales_data LIMIT 200; -- Limitar a 200 ventas para la demo

INSERT INTO CUSTOMER_REVIEWS (REVIEW_ID, PRODUCT_ID, CUSTOMER_ID, REVIEW_DATE, REVIEW_TEXT) VALUES
(1, 101, 1, '2025-08-01', '¡El reloj es increíble! La batería dura muchísimo y el GPS es muy preciso. Totalmente recomendado.'),
(2, 101, 2, '2025-08-02', 'Me decepcionó un poco. La pantalla se raya con facilidad y la conexión con el móvil a veces falla.'),
(3, 102, 3, '2025-08-05', 'El sonido es espectacular, de lo mejor que he probado. Valen cada céntimo.'),
(4, 201, 4, '2025-08-10', 'Las zapatillas son muy cómodas para correr, pero el diseño no me convence del todo.'),
(5, 101, 3, '2025-08-12', 'No está mal, pero esperaba más por este precio. Cumple su función sin más.'),
(6, 301, 1, '2025-08-15', 'La mochila es perfecta para el día a día. Muchos compartimentos y material resistente.'),
(7, 102, 4, '2025-08-18', 'Cancelación de ruido deficiente. No los recomiendo para viajar en transporte público.');


--------------------------------------------------------------------------------------------------
-- Section 3: The Demo
--------------------------------------------------------------------------------------------------
-- Consultas y acciones que demuestran el valor de Snowflake Cortex.
--------------------------------------------------------------------------------------------------

-- -----------------------------------------
-- CASO DE USO 1: Análisis de Sentimientos con AISQL
-- Objetivo: Entender la opinión de los clientes sobre los productos.
-- -----------------------------------------
SELECT
    REVIEW_TEXT,
    SNOWFLAKE.CORTEX.SENTIMENT(REVIEW_TEXT) AS sentiment_score,
    CASE
        WHEN sentiment_score > 0.5 THEN 'Positivo'
        WHEN sentiment_score < -0.5 THEN 'Negativo'
        ELSE 'Neutral'
    END AS sentiment_label
FROM CUSTOMER_REVIEWS;


-- -----------------------------------------
-- CASO DE USO 2: Generación de Texto con AISQL (Multimodal)
-- Objetivo: Crear descripciones de marketing para productos.
-- -----------------------------------------
SELECT
    PRODUCT_NAME,
    IMAGE_URL, -- Podemos referenciar la imagen en el prompt
    SNOWFLAKE.CORTEX.COMPLETE(
        'llama3-8b',
        CONCAT('Crea una descripción de marketing corta y atractiva para el siguiente producto: ', PRODUCT_NAME,
               '. Es de la categoría ', CATEGORY, '. Resalta sus beneficios clave.')
    ) AS marketing_description
FROM PRODUCTS;


-- -----------------------------------------
-- CASO DE USO 3: Búsqueda en Documentos con Cortex Search
-- Objetivo: Encontrar información específica en manuales de producto.
-- -----------------------------------------
-- Paso 3.1: Subir el archivo de datos no estructurados
--          Usa la UI de Snowsight o el comando PUT para subir el archivo
--          'OMNIGOODS_Product_Manual_Smartwatch.txt' al stage 'OMNIGOODS_DOCS'.
--          Ej: PUT file:///path/to/your/file/OMNIGOODS_Product_Manual_Smartwatch.txt @OMNIGOODS_DOCS;

-- Paso 3.2: Crear un servicio de búsqueda de Cortex
--           Nota: Esto puede tener un costo asociado.
CREATE OR REPLACE CORTEX SEARCH SERVICE OMNIGOODS_SEARCH_SERVICE
  ON OMNIGOODS_DOCS
  USING '{"columns":["relative_path", "file_url", "last_modified"]}';
-- El servicio tardará unos momentos en indexar los archivos.

-- Paso 3.3: Realizar búsquedas sobre los documentos
--           Una vez indexado, podemos hacer preguntas en lenguaje natural.
SELECT OMNIGOODS_SEARCH_SERVICE!SEARCH(
    '¿Qué cubre la garantía del Smartwatch Pro?'
) AS search_results;

SELECT OMNIGOODS_SEARCH_SERVICE!SEARCH(
    '¿Cuánto dura la batería del reloj y cómo puedo alargarla?'
) AS search_results;


-- -----------------------------------------
-- CASO DE USO 4: Pronóstico de Ventas con Funciones de ML
-- Objetivo: Predecir la cantidad de productos vendidos para las próximas 2 semanas.
-- -----------------------------------------
-- Paso 4.1: Crear una vista agregada de ventas diarias
CREATE OR REPLACE VIEW DAILY_SALES_AGG AS
SELECT
    SALE_DATE AS ts,
    SUM(QUANTITY) AS quantity_sold
FROM SALES
GROUP BY SALE_DATE
ORDER BY SALE_DATE;

-- Paso 4.2: Crear el modelo de pronóstico
--           Nota: Esto puede tener un costo asociado.
CREATE OR REPLACE SNOWFLAKE.ML.FORECAST sales_forecast(
    INPUT_DATA => SYSTEM$REFERENCE('VIEW', 'DAILY_SALES_AGG'),
    TIMESTAMP_COLNAME => 'ts',
    TARGET_COLNAME => 'quantity_sold'
);

-- Paso 4.3: Generar el pronóstico para los siguientes 14 días
CALL sales_forecast!FORECAST(FORECASTING_PERIODS => 14);


-- -----------------------------------------
-- CASO DE USO 5: Experiencia Conversacional con Cortex Analyst
-- Objetivo: Permitir que los usuarios de negocio hagan preguntas en lenguaje natural.
-- -----------------------------------------
-- Paso 5.1: Crear un modelo semántico
--           Crea y sube el archivo 'omnigoods_semantic_model.yaml' a un stage.
--           Este archivo define las tablas, relaciones, dimensiones y métricas para Cortex Analyst.
--           Ej: PUT file:///path/to/your/file/omnigoods_semantic_model.yaml @OMNIGOODS_DOCS;

-- Paso 5.2: Activar Cortex Analyst
--           Usa la UI de Snowsight para crear una 'App' de Cortex Search
--           y apunta al modelo semántico subido en el stage.

-- Paso 5.3: ¡Hacer preguntas!
--           Una vez configurado, los analistas pueden ir a la App y preguntar:
--           "¿Cuáles fueron las ventas totales el mes pasado?"
--           "Muéstrame los 3 productos más vendidos en Madrid"
--           "Compara las ventas de smartwatch vs auriculares en agosto"
--
-- El modelo semántico que crearás a continuación es la clave para que esto funcione.


--------------------------------------------------------------------------------------------------
-- Section 4: Cleanup (Opcional)
--------------------------------------------------------------------------------------------------
-- Desmontaje de todos los recursos creados para la demo.
-- ¡¡¡PRECAUCIÓN: Esto eliminará permanentemente la base de datos y el warehouse!!!
--------------------------------------------------------------------------------------------------
/*
USE ROLE ACCOUNTADMIN;
DROP DATABASE IF EXISTS OMNIGOODS_DB;
DROP WAREHOUSE IF EXISTS OMNIGOODS_DEMO_WH;
DROP ROLE IF EXISTS OMNIGOODS_DEMO_ROLE;
*/

-- Fin del script
