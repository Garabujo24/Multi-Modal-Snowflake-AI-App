-- =====================================================
-- DESPLIEGUE STREAMLIT IN SNOWFLAKE - RETAIL SHOES AI CLASSIFIER
-- Demo de clasificación automática de zapatos con AISQL CLASSIFY
-- =====================================================

-- Usar el contexto correcto
USE WAREHOUSE RETAIL_AI_WH;
USE DATABASE RETAIL_SHOES_DEMO;
USE SCHEMA PRODUCTS;

-- =====================================================
-- 1. CREAR STAGES PARA LA APLICACIÓN
-- =====================================================

-- Stage para archivos de la aplicación Streamlit
CREATE STAGE IF NOT EXISTS retail_streamlit_stage
  DIRECTORY = (ENABLE = TRUE)
  COMMENT = 'Stage para archivos de la aplicación Retail Shoes AI Classifier';

-- =====================================================
-- 2. SUBIR ARCHIVOS (ejecutar manualmente)
-- =====================================================

-- Subir la aplicación Streamlit (ejecutar desde SnowSQL o Snowsight)
-- PUT file://app.py @retail_streamlit_stage AUTO_COMPRESS=FALSE;

-- Verificar archivos subidos
-- LIST @retail_streamlit_stage;

-- =====================================================
-- 3. CREAR LA APLICACIÓN STREAMLIT
-- =====================================================

CREATE STREAMLIT IF NOT EXISTS retail_shoes_ai_classifier
  ROOT_LOCATION = '@retail_streamlit_stage'
  MAIN_FILE = 'app.py'
  QUERY_WAREHOUSE = 'RETAIL_AI_WH'
  COMMENT = 'Demo de clasificación automática de zapatos usando Snowflake AISQL CLASSIFY';

-- =====================================================
-- 4. CONFIGURAR PERMISOS ADICIONALES
-- =====================================================

-- Permisos en el stage para la aplicación
GRANT READ ON STAGE retail_streamlit_stage TO ROLE retail_demo_role;

-- Permisos para la aplicación Streamlit
GRANT USAGE ON STREAMLIT retail_shoes_ai_classifier TO ROLE retail_demo_role;

-- =====================================================
-- 5. VERIFICAR CONFIGURACIÓN
-- =====================================================

-- Verificar que la aplicación fue creada
SHOW STREAMLITS LIKE 'retail_shoes_ai_classifier';

-- Verificar permisos
SHOW GRANTS TO ROLE retail_demo_role;

-- Verificar que los datos existen
SELECT 
  COUNT(*) as total_productos,
  COUNT(ai_classification) as productos_clasificados,
  AVG(ai_confidence) as confianza_promedio
FROM shoes_products;

-- =====================================================
-- 6. OBTENER URL DE LA APLICACIÓN
-- =====================================================

-- La URL de la aplicación será:
-- https://[account].snowflakecomputing.com/streamlit/[database]/[schema]/[app_name]

SELECT 
  'https://' || CURRENT_ACCOUNT() || '.snowflakecomputing.com/streamlit/' ||
  CURRENT_DATABASE() || '/' || CURRENT_SCHEMA() || '/retail_shoes_ai_classifier' 
  as streamlit_url;

-- =====================================================
-- 7. COMANDOS DE GESTIÓN DE LA APLICACIÓN
-- =====================================================

-- Ver información de la aplicación
-- DESC STREAMLIT retail_shoes_ai_classifier;

-- Actualizar la aplicación (después de modificar archivos)
-- ALTER STREAMLIT retail_shoes_ai_classifier SET ROOT_LOCATION = '@retail_streamlit_stage';

-- Eliminar la aplicación (si es necesario)
-- DROP STREAMLIT retail_shoes_ai_classifier;

-- =====================================================
-- 8. DATOS DE MUESTRA ADICIONALES (OPCIONAL)
-- =====================================================

-- Agregar más productos de muestra si es necesario
INSERT INTO shoes_products (
  product_id, product_name, brand, price_usd, description, 
  image_url, material, color, size_range, gender, season, style_keywords
) VALUES

-- ZAPATOS ADICIONALES
('ZAP013', 'Elegant Wedding Heels', 'Bridal', 199.99,
 'Zapatos de novia con tacón alto y acabado satinado. Perfectos para bodas y eventos especiales.',
 'https://images.unsplash.com/photo-1566479179817-c0ad35d6d3ea?w=400&h=400&fit=crop',
 'Satín', 'Blanco', '35-42', 'Mujer', 'Todo el año', 'boda, elegante, satín, tacón, formal'),

('ZAP014', 'Business Casual Loafers', 'ProfessionalFeet', 119.00,
 'Mocasines de cuero para uso empresarial. Diseño moderno y cómodo para largas jornadas de trabajo.',
 'https://images.unsplash.com/photo-1614252369475-531eba835eb1?w=400&h=400&fit=crop',
 'Cuero', 'Negro', '38-46', 'Hombre', 'Todo el año', 'business, mocasín, cómodo, oficina, profesional'),

-- ZAPATILLAS ADICIONALES
('ZAP015', 'CrossFit Training Shoes', 'FitMax', 139.99,
 'Zapatillas especializadas para entrenamientos de CrossFit con soporte lateral y suela resistente.',
 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=400&h=400&fit=crop',
 'Sintético', 'Negro/Blanco', '36-48', 'Unisex', 'Todo el año', 'crossfit, entrenamiento, resistente, gimnasio, fitness'),

('ZAP016', 'Skate Shoes Urban', 'StreetBoard', 79.99,
 'Zapatillas de skate con suela de goma vulcanizada y refuerzos en zonas de alto desgaste.',
 'https://images.unsplash.com/photo-1603808033192-082d6919d3e1?w=400&h=400&fit=crop',
 'Lona reforzada', 'Gris', '35-45', 'Unisex', 'Todo el año', 'skate, urbano, resistente, juvenil, street'),

-- CHANCLAS ADICIONALES
('ZAP017', 'Luxury Resort Sandals', 'Paradise', 159.00,
 'Sandalias de lujo con detalles dorados y plantilla acolchada. Perfectas para resorts y vacaciones.',
 'https://images.unsplash.com/photo-1520256862855-398228c41684?w=400&h=400&fit=crop',
 'Cuero premium', 'Dorado', '36-42', 'Mujer', 'Verano', 'lujo, resort, dorado, acolchada, vacaciones'),

('ZAP018', 'Waterproof Beach Sandals', 'AquaStep', 45.00,
 'Sandalias impermeables para actividades acuáticas con suela antideslizante y secado rápido.',
 'https://images.unsplash.com/photo-1515347619252-60a4bf4fff4f?w=400&h=400&fit=crop',
 'EVA impermeable', 'Azul marino', '35-46', 'Unisex', 'Verano', 'impermeable, acuático, antideslizante, playa, deportivo');

-- Clasificar automáticamente los nuevos productos
CALL classify_all_products();

-- =====================================================
-- 9. CONFIGURACIÓN DE MONITOREO
-- =====================================================

-- Crear vista para monitoreo de uso de la aplicación
CREATE OR REPLACE VIEW streamlit_usage_stats AS
SELECT 
  DATE(start_time) as fecha_uso,
  COUNT(*) as sesiones_totales,
  COUNT(DISTINCT user_name) as usuarios_unicos,
  AVG(execution_time_ms) as tiempo_promedio_ms
FROM TABLE(INFORMATION_SCHEMA.STREAMLIT_USAGE_HISTORY(
  DATE_RANGE_START => DATEADD('day', -30, CURRENT_DATE())
))
WHERE streamlit_name = 'retail_shoes_ai_classifier'
GROUP BY fecha_uso
ORDER BY fecha_uso DESC;

-- =====================================================
-- INSTRUCCIONES DE DESPLIEGUE
-- =====================================================

/*
PASOS PARA DESPLEGAR LA APLICACIÓN:

1. Ejecutar este script completo en Snowflake (hasta línea 66)
2. Desde SnowSQL o Snowsight, subir archivos:
   PUT file://app.py @retail_streamlit_stage AUTO_COMPRESS=FALSE;

3. Verificar que los archivos están en el stage:
   LIST @retail_streamlit_stage;

4. La aplicación estará disponible en la URL generada en el paso 6

5. Otorgar permisos a usuarios:
   GRANT ROLE retail_demo_role TO USER <username>;

6. Acceder a la aplicación desde Snowsight:
   - Ir a "Streamlit"
   - Buscar "retail_shoes_ai_classifier"
   - Hacer clic para abrir

NOTA: Para usar AISQL CLASSIFY se requiere una cuenta Snowflake 
      con permisos y características habilitadas para Cortex AI.
*/

-- =====================================================
-- INFORMACIÓN FINAL
-- =====================================================

SELECT 
  '👟 RETAIL SHOES AI CLASSIFIER' as titulo,
  '✅ Aplicación Streamlit lista para usar' as estado,
  'Acceder desde Snowsight → Streamlit → retail_shoes_ai_classifier' as instrucciones;