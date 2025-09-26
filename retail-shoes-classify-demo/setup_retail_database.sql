-- =====================================================
-- DEMO RETAIL - CLASIFICACIÓN AUTOMÁTICA DE ZAPATOS
-- Usando Snowflake AISQL CLASSIFY para categorización
-- =====================================================

-- Crear database y schema para retail
CREATE DATABASE IF NOT EXISTS RETAIL_SHOES_DEMO;
USE DATABASE RETAIL_SHOES_DEMO;

CREATE SCHEMA IF NOT EXISTS PRODUCTS;
USE SCHEMA PRODUCTS;

-- Crear warehouse optimizado para AI
CREATE WAREHOUSE IF NOT EXISTS RETAIL_AI_WH 
  WITH WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE
  COMMENT = 'Warehouse para demo de retail con AI classification';

USE WAREHOUSE RETAIL_AI_WH;

-- =====================================================
-- TABLA DE PRODUCTOS DE ZAPATOS
-- =====================================================

CREATE OR REPLACE TABLE shoes_products (
  product_id VARCHAR(20) PRIMARY KEY,
  product_name VARCHAR(200) NOT NULL,
  brand VARCHAR(100) NOT NULL,
  price_usd NUMBER(8,2) NOT NULL,
  description TEXT,
  image_url VARCHAR(500),
  material VARCHAR(100),
  color VARCHAR(50),
  size_range VARCHAR(50),
  gender VARCHAR(20),
  season VARCHAR(20),
  style_keywords VARCHAR(300),
  created_date DATE DEFAULT CURRENT_DATE(),
  ai_classification VARCHAR(50),
  ai_confidence NUMBER(5,4),
  classification_date TIMESTAMP_LTZ
);

-- Agregar comentarios para mejor documentación
ALTER TABLE shoes_products ADD COMMENT = 'Catálogo de productos de calzado para clasificación automática con AI';

COMMENT ON COLUMN shoes_products.product_id IS 'Identificador único del producto';
COMMENT ON COLUMN shoes_products.product_name IS 'Nombre comercial del producto';
COMMENT ON COLUMN shoes_products.image_url IS 'URL de la imagen del producto para análisis visual';
COMMENT ON COLUMN shoes_products.description IS 'Descripción detallada para análisis de texto';
COMMENT ON COLUMN shoes_products.ai_classification IS 'Clasificación automática: ZAPATOS, ZAPATILLAS, CHANCLAS';
COMMENT ON COLUMN shoes_products.ai_confidence IS 'Nivel de confianza de la clasificación AI (0-1)';

-- =====================================================
-- TABLA DE CATEGORÍAS DE REFERENCIA
-- =====================================================

CREATE OR REPLACE TABLE shoe_categories (
  category_id VARCHAR(20) PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL,
  description TEXT,
  typical_features TEXT,
  price_range_min NUMBER(8,2),
  price_range_max NUMBER(8,2)
);

-- Insertar categorías de referencia
INSERT INTO shoe_categories VALUES
('ZAPATOS', 'Zapatos Formales', 
 'Calzado formal para ocasiones elegantes, trabajo y eventos especiales',
 'Cuero, tacón bajo/medio, cordones o hebillas, diseño elegante',
 50.00, 500.00),

('ZAPATILLAS', 'Zapatillas Deportivas', 
 'Calzado deportivo y casual para actividades físicas y uso diario',
 'Materiales sintéticos, suela de goma, amortiguación, diseño atlético',
 30.00, 300.00),

('CHANCLAS', 'Chanclas y Sandalias', 
 'Calzado abierto para clima cálido, playa y uso casual',
 'Correas, suela plana o con poca elevación, materiales ligeros',
 10.00, 100.00);

-- =====================================================
-- INSERTAR PRODUCTOS DE MUESTRA CON IMÁGENES
-- =====================================================

INSERT INTO shoes_products (
  product_id, product_name, brand, price_usd, description, 
  image_url, material, color, size_range, gender, season, style_keywords
) VALUES

-- ZAPATOS FORMALES
('ZAP001', 'Oxford Classic Black', 'Eleganza', 89.99,
 'Zapatos Oxford de cuero genuino negro, perfectos para ocasiones formales y de negocios. Suela de cuero con acabado pulido.',
 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=400&fit=crop',
 'Cuero genuino', 'Negro', '38-45', 'Hombre', 'Todo el año', 'formal, oficina, elegante, cuero, oxford'),

('ZAP002', 'Stiletto Heel Pumps', 'Glamour', 125.50,
 'Zapatos de tacón alto estilo stiletto en cuero rojo. Diseño sofisticado para eventos especiales y noches elegantes.',
 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=400&h=400&fit=crop',
 'Cuero sintético', 'Rojo', '35-41', 'Mujer', 'Todo el año', 'tacón, elegante, fiesta, stiletto, formal'),

('ZAP003', 'Brown Leather Loafers', 'ComfortWalk', 75.00,
 'Mocasines de cuero marrón con acabado vintage. Cómodos y versátiles para uso casual-formal.',
 'https://images.unsplash.com/photo-1582897085656-c636d006a246?w=400&h=400&fit=crop',
 'Cuero', 'Marrón', '39-46', 'Hombre', 'Todo el año', 'mocasín, casual, cuero, marrón, cómodo'),

-- ZAPATILLAS DEPORTIVAS
('ZAP004', 'Air Run Pro', 'SportMax', 149.99,
 'Zapatillas deportivas de alto rendimiento con tecnología de amortiguación avanzada. Ideales para running y entrenamiento.',
 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop',
 'Malla transpirable', 'Blanco/Azul', '36-48', 'Unisex', 'Todo el año', 'running, deportivo, amortiguación, transpirable'),

('ZAP005', 'Casual Street Sneakers', 'UrbanStyle', 89.00,
 'Zapatillas urbanas casuales con diseño moderno. Perfectas para el día a día y actividades recreativas.',
 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=400&h=400&fit=crop',
 'Lona y sintético', 'Blanco', '35-44', 'Unisex', 'Primavera/Verano', 'casual, urbano, lona, moderno, diario'),

('ZAP006', 'Basketball High Tops', 'CourtKing', 129.99,
 'Zapatillas de básquetbol de caña alta con soporte de tobillo. Diseño retro con tecnología moderna.',
 'https://images.unsplash.com/photo-1597045566677-8cf032ed6634?w=400&h=400&fit=crop',
 'Cuero sintético', 'Negro/Rojo', '38-47', 'Unisex', 'Todo el año', 'basketball, caña alta, retro, soporte, deportivo'),

-- CHANCLAS Y SANDALIAS
('ZAP007', 'Beach Flip Flops', 'OceanWave', 24.99,
 'Chanclas de playa con suela antideslizante y correas cómodas. Perfectas para vacaciones y actividades acuáticas.',
 'https://images.unsplash.com/photo-1506629905607-62d8a37abf30?w=400&h=400&fit=crop',
 'Goma EVA', 'Azul/Blanco', '35-46', 'Unisex', 'Verano', 'playa, chanclas, antideslizante, vacaciones, goma'),

('ZAP008', 'Leather Gladiator Sandals', 'Roman', 79.99,
 'Sandalias estilo gladiador en cuero marrón con múltiples correas. Diseño bohemio y elegante.',
 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=400&h=400&fit=crop',
 'Cuero', 'Marrón', '36-42', 'Mujer', 'Primavera/Verano', 'gladiador, bohemio, cuero, correas, elegante'),

('ZAP009', 'Sport Sandals Outdoor', 'Adventure', 65.00,
 'Sandalias deportivas para actividades al aire libre con sujeción ajustable y suela antideslizante.',
 'https://images.unsplash.com/photo-1595950653106-6c9c1c7a3a24?w=400&h=400&fit=crop',
 'Nylon y goma', 'Negro/Gris', '38-45', 'Unisex', 'Verano', 'outdoor, deportivo, aventura, ajustable, antideslizante'),

-- MÁS PRODUCTOS PARA DIVERSIDAD
('ZAP010', 'Patent Leather Dress Shoes', 'Executive', 159.99,
 'Zapatos de charol negro para eventos formales. Acabado brillante y diseño impecable.',
 'https://images.unsplash.com/photo-1511556532299-8f662fc26c06?w=400&h=400&fit=crop',
 'Charol', 'Negro', '40-46', 'Hombre', 'Todo el año', 'charol, formal, brillante, elegante, eventos'),

('ZAP011', 'Running Trail Shoes', 'MountainGear', 119.99,
 'Zapatillas especializadas para trail running con agarre superior y protección contra rocas.',
 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
 'Sintético reforzado', 'Gris/Naranja', '37-47', 'Unisex', 'Todo el año', 'trail, montaña, agarre, protección, outdoor'),

('ZAP012', 'Platform Summer Sandals', 'TrendyFeet', 55.00,
 'Sandalias de plataforma para verano con diseño juvenil y colores vibrantes.',
 'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?w=400&h=400&fit=crop',
 'Sintético', 'Rosa/Dorado', '35-41', 'Mujer', 'Verano', 'plataforma, juvenil, vibrante, tendencia, verano');

-- =====================================================
-- FUNCIÓN PARA CLASIFICACIÓN AUTOMÁTICA
-- =====================================================

-- Crear función que usa AISQL CLASSIFY
CREATE OR REPLACE FUNCTION classify_shoe_product(description TEXT, product_name TEXT, style_keywords TEXT)
RETURNS OBJECT
LANGUAGE SQL
AS $$
  SELECT SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
    CONCAT(product_name, '. ', description, '. Características: ', style_keywords),
    ['ZAPATOS', 'ZAPATILLAS', 'CHANCLAS'],
    'Clasifica este producto de calzado en una de estas categorías:
     - ZAPATOS: Calzado formal, elegante, para oficina o eventos especiales
     - ZAPATILLAS: Calzado deportivo, casual, para actividades físicas o uso diario  
     - CHANCLAS: Calzado abierto, sandalias, para playa o clima cálido'
  )
$$;

-- =====================================================
-- VISTA PARA ANÁLISIS DE CLASIFICACIÓN
-- =====================================================

CREATE OR REPLACE VIEW shoe_classification_analysis AS
SELECT 
  p.product_id,
  p.product_name,
  p.brand,
  p.price_usd,
  p.description,
  p.image_url,
  p.color,
  p.gender,
  p.season,
  p.style_keywords,
  p.ai_classification,
  p.ai_confidence,
  c.category_name,
  c.description as category_description,
  c.typical_features,
  CASE 
    WHEN p.price_usd BETWEEN c.price_range_min AND c.price_range_max 
    THEN 'Precio típico'
    WHEN p.price_usd < c.price_range_min 
    THEN 'Precio bajo'
    ELSE 'Precio premium'
  END as price_category,
  CASE 
    WHEN p.ai_confidence >= 0.8 THEN 'Alta confianza'
    WHEN p.ai_confidence >= 0.6 THEN 'Confianza media'
    ELSE 'Baja confianza'
  END as confidence_level
FROM shoes_products p
LEFT JOIN shoe_categories c ON p.ai_classification = c.category_id;

-- =====================================================
-- PROCEDIMIENTO PARA CLASIFICAR TODOS LOS PRODUCTOS
-- =====================================================

CREATE OR REPLACE PROCEDURE classify_all_products()
RETURNS STRING
LANGUAGE SQL
AS $$
DECLARE
  products_classified INTEGER DEFAULT 0;
  total_products INTEGER DEFAULT 0;
BEGIN
  -- Contar total de productos
  SELECT COUNT(*) INTO total_products FROM shoes_products;
  
  -- Actualizar clasificación para productos sin clasificar
  UPDATE shoes_products 
  SET 
    ai_classification = classify_shoe_product(description, product_name, style_keywords):class,
    ai_confidence = classify_shoe_product(description, product_name, style_keywords):confidence,
    classification_date = CURRENT_TIMESTAMP()
  WHERE ai_classification IS NULL;
  
  -- Contar productos clasificados
  GET DIAGNOSTICS products_classified = ROW_COUNT;
  
  RETURN 'Clasificación completada. ' || products_classified || ' productos de ' || total_products || ' fueron clasificados.';
END;
$$;

-- =====================================================
-- EJECUTAR CLASIFICACIÓN INICIAL
-- =====================================================

-- Llamar al procedimiento para clasificar productos existentes
CALL classify_all_products();

-- =====================================================
-- CONSULTAS DE VERIFICACIÓN
-- =====================================================

-- Ver resumen de clasificación
SELECT 
  ai_classification,
  COUNT(*) as total_productos,
  AVG(ai_confidence) as confianza_promedio,
  AVG(price_usd) as precio_promedio
FROM shoes_products 
WHERE ai_classification IS NOT NULL
GROUP BY ai_classification
ORDER BY total_productos DESC;

-- Ver productos con menor confianza para revisión manual
SELECT 
  product_id,
  product_name,
  ai_classification,
  ai_confidence,
  style_keywords
FROM shoes_products 
WHERE ai_confidence < 0.7
ORDER BY ai_confidence ASC;

-- =====================================================
-- CONFIGURACIÓN DE PERMISOS
-- =====================================================

-- Crear rol para la aplicación
CREATE ROLE IF NOT EXISTS retail_demo_role;

-- Otorgar permisos necesarios
GRANT USAGE ON WAREHOUSE RETAIL_AI_WH TO ROLE retail_demo_role;
GRANT USAGE ON DATABASE RETAIL_SHOES_DEMO TO ROLE retail_demo_role;
GRANT USAGE ON SCHEMA PRODUCTS TO ROLE retail_demo_role;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA PRODUCTS TO ROLE retail_demo_role;
GRANT SELECT ON ALL VIEWS IN SCHEMA PRODUCTS TO ROLE retail_demo_role;
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA PRODUCTS TO ROLE retail_demo_role;
GRANT USAGE ON ALL PROCEDURES IN SCHEMA PRODUCTS TO ROLE retail_demo_role;

-- Otorgar permisos para usar Cortex AI
GRANT USAGE ON FUNCTION SNOWFLAKE.CORTEX.CLASSIFY_TEXT TO ROLE retail_demo_role;

-- =====================================================
-- INFORMACIÓN DE LA DEMO
-- =====================================================

SELECT 
  '👟 DEMO RETAIL - CLASIFICACIÓN DE ZAPATOS' as titulo,
  '✅ Base de datos configurada exitosamente' as estado,
  COUNT(*) || ' productos de muestra cargados' as info
FROM shoes_products;

SELECT 
  '🤖 CLASIFICACIÓN AI COMPLETADA' as resultado,
  COUNT(*) || ' productos clasificados automáticamente' as detalle
FROM shoes_products 
WHERE ai_classification IS NOT NULL;