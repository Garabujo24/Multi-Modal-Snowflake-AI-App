# 👟 Retail Shoes AI Classifier

## 🤖 Demo de Clasificación Automática con Snowflake AISQL CLASSIFY

Aplicación **Streamlit** que demuestra las capacidades de **Snowflake Cortex AI** para clasificar automáticamente productos de calzado usando análisis de texto con **AISQL CLASSIFY**.

![Retail Shoes](https://via.placeholder.com/600x200/667eea/ffffff?text=👟+RETAIL+SHOES+AI+CLASSIFIER)

---

## ✨ **Características Principales**

### 🎯 **Clasificación Automática**
- **3 Categorías**: ZAPATOS, ZAPATILLAS, CHANCLAS
- **Análisis de Texto**: Nombre, descripción y palabras clave
- **Nivel de Confianza**: Puntaje de 0-1 para cada clasificación
- **Tiempo Real**: Reclasificación instantánea

### 🛍️ **Interfaz Visual Atractiva**
- **Tarjetas de Producto**: Con imágenes reales de Unsplash
- **Badges de Categoría**: Colores distintivos por tipo
- **Barras de Confianza**: Visualización del nivel de certeza
- **Filtros Dinámicos**: Por categoría, precio y confianza

### 📊 **Análisis y Métricas**
- **Gráficos Interactivos**: Distribución y estadísticas
- **Dashboard Ejecutivo**: KPIs en tiempo real
- **Productos de Revisión**: Identificación de baja confianza
- **Exportación de Datos**: Descarga en CSV

---

## 🏗️ **Arquitectura del Proyecto**

```
retail-shoes-classify-demo/
├── 📱 app.py                          # Aplicación Streamlit principal
├── 🗄️ setup_retail_database.sql       # Configuración de base de datos
├── 🚀 deploy_streamlit.sql            # Despliegue en Snowflake
├── 📦 requirements.txt                # Dependencias Python
├── 📖 README.md                       # Esta documentación
└── 🎨 demo_screenshots/               # Capturas de pantalla (opcional)
```

---

## 🤖 **Tecnología AISQL CLASSIFY**

### **¿Cómo Funciona?**

La función `SNOWFLAKE.CORTEX.CLASSIFY_TEXT` analiza el texto del producto y lo categoriza automáticamente:

```sql
CREATE FUNCTION classify_shoe_product(description TEXT, product_name TEXT, style_keywords TEXT)
RETURNS OBJECT
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
```

### **Categorías de Clasificación**

| Categoría | Descripción | Ejemplos | Rango de Precio |
|-----------|-------------|----------|-----------------|
| **👔 ZAPATOS** | Calzado formal y elegante | Oxford, tacones, mocasines | $50 - $500 |
| **👟 ZAPATILLAS** | Calzado deportivo y casual | Running, basketball, urbanas | $30 - $300 |
| **🩴 CHANCLAS** | Calzado abierto para clima cálido | Flip-flops, sandalias | $10 - $100 |

---

## 🚀 **Instalación y Configuración**

### **Opción 1: Streamlit in Snowflake (Recomendado)**

```sql
-- 1. Ejecutar configuración de base de datos
source setup_retail_database.sql

-- 2. Ejecutar despliegue de Streamlit
source deploy_streamlit.sql

-- 3. Subir aplicación
PUT file://app.py @retail_streamlit_stage AUTO_COMPRESS=FALSE;

-- 4. Acceder desde Snowsight → Streamlit → retail_shoes_ai_classifier
```

### **Opción 2: Ejecución Local**

```bash
# 1. Clonar/descargar archivos
cd retail-shoes-classify-demo

# 2. Instalar dependencias
pip install -r requirements.txt

# 3. Configurar credenciales de Snowflake (.env o secrets)
# 4. Ejecutar aplicación
streamlit run app.py
```

---

## 📊 **Datos de Muestra Incluidos**

### **18 Productos Realistas**

La demo incluye productos variados con imágenes reales:

#### **👔 ZAPATOS (6 productos)**
- Oxford Classic Black - $89.99
- Stiletto Heel Pumps - $125.50
- Brown Leather Loafers - $75.00
- Patent Leather Dress Shoes - $159.99
- Elegant Wedding Heels - $199.99
- Business Casual Loafers - $119.00

#### **👟 ZAPATILLAS (6 productos)**
- Air Run Pro - $149.99
- Casual Street Sneakers - $89.00
- Basketball High Tops - $129.99
- Running Trail Shoes - $119.99
- CrossFit Training Shoes - $139.99
- Skate Shoes Urban - $79.99

#### **🩴 CHANCLAS (6 productos)**
- Beach Flip Flops - $24.99
- Leather Gladiator Sandals - $79.99
- Sport Sandals Outdoor - $65.00
- Platform Summer Sandals - $55.00
- Luxury Resort Sandals - $159.00
- Waterproof Beach Sandals - $45.00

---

## 🎨 **Características de la Interfaz**

### **🛍️ Catálogo de Productos**
- **Tarjetas Visuales**: Imagen, información y clasificación
- **Filtros Dinámicos**: Por categoría, precio y confianza
- **Reclasificación**: Botón para procesar nuevamente
- **Información Completa**: Marca, precio, material, género

### **📊 Análisis de Clasificación**
- **Gráfico de Distribución**: Pie chart por categoría
- **Confianza Promedio**: Bar chart por tipo
- **Análisis de Precios**: Comparativa por categoría
- **Productos de Revisión**: Lista de baja confianza

### **➕ Agregar Productos**
- **Formulario Completo**: Todos los campos necesarios
- **Clasificación Automática**: Al guardar el producto
- **Validación**: Campos obligatorios marcados
- **Feedback Visual**: Confirmación y errores

### **ℹ️ Información**
- **Documentación**: Cómo funciona la clasificación
- **Métricas de Confianza**: Explicación de niveles
- **Tecnologías**: Stack técnico utilizado
- **Código SQL**: Función de clasificación

---

## 📈 **Métricas de Confianza**

La aplicación evalúa la certeza de cada clasificación:

| Nivel | Rango | Color | Descripción |
|-------|-------|-------|-------------|
| **🟢 Alta** | ≥ 0.8 | Verde | Clasificación muy confiable |
| **🟡 Media** | 0.6 - 0.8 | Amarillo | Clasificación aceptable |
| **🔴 Baja** | < 0.6 | Rojo | Requiere revisión manual |

---

## 🔧 **Configuración Técnica**

### **Recursos de Snowflake**

```sql
WAREHOUSE: RETAIL_AI_WH              # Warehouse optimizado para AI
DATABASE: RETAIL_SHOES_DEMO          # Base de datos de la demo
SCHEMA: PRODUCTS                     # Schema principal

TABLAS:
├── shoes_products                   # Catálogo de productos
├── shoe_categories                  # Categorías de referencia
└── streamlit_usage_stats           # Estadísticas de uso

FUNCIONES:
└── classify_shoe_product()         # Función de clasificación AI

PROCEDIMIENTOS:
└── classify_all_products()         # Clasificación masiva

ROLES:
└── retail_demo_role                # Rol con permisos necesarios
```

### **Permisos Requeridos**

```sql
-- Para usar AISQL CLASSIFY
GRANT USAGE ON FUNCTION SNOWFLAKE.CORTEX.CLASSIFY_TEXT TO ROLE retail_demo_role;

-- Para la aplicación
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA PRODUCTS TO ROLE retail_demo_role;
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA PRODUCTS TO ROLE retail_demo_role;
GRANT USAGE ON ALL PROCEDURES IN SCHEMA PRODUCTS TO ROLE retail_demo_role;
```

---

## 🎯 **Casos de Uso**

### **👨‍💼 Para Retailers**
- **Automatización**: Clasificación de catálogos grandes
- **Consistencia**: Categorización uniforme
- **Eficiencia**: Reducción de trabajo manual
- **Escalabilidad**: Procesamiento de miles de productos

### **👩‍🔬 Para Data Scientists**
- **Exploración**: Análisis de precisión del modelo
- **Validación**: Comparación con clasificación manual
- **Optimización**: Ajuste de prompts y categorías
- **Métricas**: Monitoreo de confianza y performance

### **👨‍💻 Para Desarrolladores**
- **Integración**: API de clasificación en sistemas existentes
- **Prototipo**: Base para aplicaciones de ML
- **Aprendizaje**: Ejemplo de uso de Cortex AI
- **Extensión**: Adaptación a otros dominios

---

## 🛠️ **Personalización y Extensión**

### **Agregar Nuevas Categorías**

```sql
-- Modificar la función de clasificación
ALTER FUNCTION classify_shoe_product
SET BODY = $$
  SELECT SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
    CONCAT(product_name, '. ', description, '. Características: ', style_keywords),
    ['ZAPATOS', 'ZAPATILLAS', 'CHANCLAS', 'BOTAS', 'PANTUFLAS'],  -- Nuevas categorías
    'Clasifica este producto...'
  )
$$;
```

### **Personalizar Interfaz**

```python
# Modificar colores en app.py
.badge-botas {
    background: linear-gradient(45deg, #8e44ad, #9b59b6);
    color: white;
}
```

### **Agregar Campos**

```sql
-- Agregar columnas a la tabla
ALTER TABLE shoes_products ADD COLUMN style VARCHAR(50);
ALTER TABLE shoes_products ADD COLUMN popularity_score NUMBER(3,2);
```

---

## 📊 **Monitoreo y Análisis**

### **Estadísticas de Uso**

```sql
-- Ver uso de la aplicación
SELECT * FROM streamlit_usage_stats 
ORDER BY fecha_uso DESC 
LIMIT 30;

-- Análisis de clasificación
SELECT 
  ai_classification,
  COUNT(*) as total,
  AVG(ai_confidence) as confianza_promedio,
  MIN(ai_confidence) as confianza_minima,
  MAX(ai_confidence) as confianza_maxima
FROM shoes_products 
GROUP BY ai_classification;
```

### **Productos Problemáticos**

```sql
-- Productos con baja confianza
SELECT product_name, ai_classification, ai_confidence
FROM shoes_products 
WHERE ai_confidence < 0.7
ORDER BY ai_confidence ASC;
```

---

## 🔍 **Troubleshooting**

### **Problemas Comunes**

#### **Error: Function SNOWFLAKE.CORTEX.CLASSIFY_TEXT not found**
```sql
-- Verificar que Cortex está habilitado
SELECT SNOWFLAKE.CORTEX.COMPLETE('snowflake-arctic', 'Hello') as test;

-- Verificar permisos
SHOW GRANTS TO ROLE retail_demo_role;
```

#### **Error: Images not loading**
- Verificar conectividad a Unsplash
- URLs de imágenes pueden cambiar, actualizar si es necesario
- Usar imágenes locales como alternativa

#### **Error: Classification taking too long**
- Verificar tamaño del warehouse (MEDIUM recomendado)
- Reducir cantidad de productos a clasificar
- Verificar carga del sistema Cortex

---

## 🚀 **Despliegue en Producción**

### **Streamlit in Snowflake**

```sql
-- Configuración de producción
CREATE WAREHOUSE RETAIL_PROD_WH 
  WITH WAREHOUSE_SIZE = 'LARGE'
  AUTO_SUSPEND = 60;

-- Monitoreo automático
CREATE TASK monitor_classification_quality
  WAREHOUSE = RETAIL_PROD_WH
  SCHEDULE = 'USING CRON 0 9 * * MON'
  AS
    INSERT INTO classification_quality_log
    SELECT CURRENT_TIMESTAMP(), AVG(ai_confidence)
    FROM shoes_products
    WHERE classification_date >= DATEADD('week', -1, CURRENT_DATE());
```

### **Consideraciones de Escalabilidad**

- **Batch Processing**: Para catálogos grandes (>10,000 productos)
- **Caching**: Guardar resultados para evitar reclasificaciones
- **Rate Limiting**: Controlar uso de Cortex API
- **Error Handling**: Manejo robusto de fallos

---

## 📈 **Métricas de Performance**

### **Benchmarks Esperados**

| Métrica | Valor Típico | Descripción |
|---------|--------------|-------------|
| **Precisión** | 85-95% | Clasificación correcta vs manual |
| **Confianza Promedio** | 0.75-0.90 | Nivel de certeza del modelo |
| **Tiempo de Clasificación** | 1-3 segundos | Por producto individual |
| **Throughput** | 100-500 productos/min | Clasificación masiva |

---

## 🔄 **Actualizaciones y Mantenimiento**

### **Versioning**

```sql
-- Crear tabla de versiones
CREATE TABLE app_versions (
  version VARCHAR(10),
  release_date DATE,
  features TEXT,
  sql_changes TEXT
);
```

### **Backup y Recovery**

```sql
-- Backup de datos
CREATE TABLE shoes_products_backup AS 
SELECT * FROM shoes_products;

-- Backup de configuración
SHOW FUNCTIONS LIKE 'classify_shoe_product';
```

---

## 🎉 **¡Comenzar Ahora!**

### **Pasos Rápidos**

```bash
# 1. Configurar Snowflake
source setup_retail_database.sql

# 2. Desplegar aplicación  
source deploy_streamlit.sql

# 3. Subir código
PUT file://app.py @retail_streamlit_stage AUTO_COMPRESS=FALSE;

# 4. Acceder a la aplicación
# Snowsight → Streamlit → retail_shoes_ai_classifier
```

**¡Comienza a clasificar productos con IA en minutos! 🚀👟🤖**

---

## 📞 **Soporte y Recursos**

### **Documentación Técnica**
- **Snowflake Cortex**: [docs.snowflake.com/cortex](https://docs.snowflake.com/en/user-guide/snowflake-cortex)
- **AISQL CLASSIFY**: [docs.snowflake.com/classify](https://docs.snowflake.com/en/sql-reference/functions/classify)
- **Streamlit**: [docs.streamlit.io](https://docs.streamlit.io)

### **Comunidad**
- **Snowflake Community**: [community.snowflake.com](https://community.snowflake.com)
- **GitHub Issues**: Para reportar problemas
- **Stack Overflow**: Preguntas técnicas con tag `snowflake-cortex`

### **Contacto**
- **Email**: Para soporte empresarial
- **Demo Request**: Solicitar demostración personalizada
- **Training**: Workshops sobre Cortex AI

---

## 📝 **Licencia y Disclaimer**

- **Datos ficticios** generados para demostración
- **Imágenes de Unsplash** bajo licencia libre
- **Código abierto** para uso educativo y comercial
- **No garantías** sobre precisión de clasificación

**Snowflake Cortex AI** y **AISQL CLASSIFY** son marcas registradas de Snowflake Inc.

© 2025 Retail Shoes AI Classifier Demo - Powered by Snowflake Cortex AI