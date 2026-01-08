# 🚀 INSTRUCCIONES DE CONFIGURACIÓN Y USO
## TechFlow Solutions - Demo Kit de Snowflake Cortex

### 📋 Descripción General

Este Demo Kit proporciona una demostración completa e integral de las capacidades de Snowflake Cortex, incluyendo Cortex Analyst, Cortex Search, funciones AISQL multimodales y modelos predictivos de ML. La demo utiliza datos de la empresa ficticia "TechFlow Solutions" para mostrar casos de uso empresariales realistas.

---

## 🎯 COMPONENTES DEL DEMO KIT

### 📁 Archivos Incluidos

1. **`techflow_demo_schema.sql`** - Esquema completo de base de datos con tablas y datos de ejemplo
2. **`cortex_analyst_semantic_model.md`** - Documentación del modelo semántico para Cortex Analyst  
3. **`cortex_search_documents.md`** - Descripción de documentos ficticios para Cortex Search
4. **`aisql_multimodal_cases.md`** - Casos de uso para funciones multimodales AISQL
5. **`ml_predictive_strategies.sql`** - Estrategias y queries de ML predictivo
6. **`techflow_streamlit_app.py`** - Aplicación Streamlit completa
7. **`INSTRUCCIONES_DEMO_SETUP.md`** - Este archivo de instrucciones
8. **`requirements.txt`** - Dependencias de Python (se creará en Paso 3)
9. **`demo_narrative.md`** - Narrativa de ventas (se creará en pasos siguientes)

---

## ⚙️ CONFIGURACIÓN PASO A PASO

### 🔧 PASO 1: Preparación del Entorno Snowflake

#### A) Configuración de Cuenta y Permisos

```sql
-- 1. Crear role para la demo
USE ROLE ACCOUNTADMIN;
CREATE ROLE IF NOT EXISTS CORTEX_DEMO_ROLE;

-- 2. Otorgar permisos necesarios
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE CORTEX_DEMO_ROLE;
GRANT CREATE DATABASE ON ACCOUNT TO ROLE CORTEX_DEMO_ROLE;

-- 3. Habilitar Cortex (si no está habilitado)
-- Contactar a Snowflake Support si es necesario

-- 4. Asignar role a usuario demo
GRANT ROLE CORTEX_DEMO_ROLE TO USER [TU_USUARIO_DEMO];
```

#### B) Configuración de Warehouse

```sql
-- Crear warehouse optimizado para demo
CREATE OR REPLACE WAREHOUSE CORTEX_DEMO_WH WITH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse para TechFlow Cortex Demo';

GRANT ALL ON WAREHOUSE CORTEX_DEMO_WH TO ROLE CORTEX_DEMO_ROLE;
```

### 📊 PASO 2: Configuración de Base de Datos

#### A) Ejecutar Schema Principal

1. **Conectar a Snowflake** usando role `CORTEX_DEMO_ROLE` y warehouse `CORTEX_DEMO_WH`

2. **Ejecutar el archivo completo** `techflow_demo_schema.sql`:
   ```sql
   -- El archivo se ejecuta completo - contiene:
   -- - Creación de database TECHFLOW_DEMO
   -- - Schema CORTEX_DEMO
   -- - 5 tablas principales con datos
   -- - Vistas analíticas
   -- - Datos históricos para ML
   ```

3. **Verificar instalación correcta**:
   ```sql
   USE DATABASE TECHFLOW_DEMO;
   USE SCHEMA CORTEX_DEMO;
   
   -- Verificar tablas creadas
   SHOW TABLES;
   
   -- Verificar datos
   SELECT 'PRODUCTOS' AS TABLA, COUNT(*) AS REGISTROS FROM PRODUCTOS
   UNION ALL
   SELECT 'CLIENTES' AS TABLA, COUNT(*) AS REGISTROS FROM CLIENTES  
   UNION ALL
   SELECT 'TRANSACCIONES' AS TABLA, COUNT(*) AS REGISTROS FROM TRANSACCIONES
   UNION ALL
   SELECT 'CAMPANAS_MARKETING' AS TABLA, COUNT(*) AS REGISTROS FROM CAMPANAS_MARKETING
   UNION ALL
   SELECT 'TICKETS_SOPORTE' AS TABLA, COUNT(*) AS REGISTROS FROM TICKETS_SOPORTE;
   ```

#### B) Configuración de Cortex Analyst

1. **Crear Semantic Model** (En Snowsight):
   - Ir a "Data" → "Databases" → "TECHFLOW_DEMO"
   - Crear nuevo Semantic Model basado en la documentación de `cortex_analyst_semantic_model.md`
   - Configurar métricas y dimensiones según especificado

2. **Configurar relaciones entre tablas**:
   ```sql
   -- Las relaciones están definidas por foreign keys en el schema
   -- Cortex Analyst las detectará automáticamente
   ```

### 🔍 PASO 3: Configuración de Cortex Search

#### A) Preparar Documentos (Simulados)

Para la demo, los documentos están descritos en `cortex_search_documents.md`. En una implementación real:

```sql
-- 1. Crear stage para documentos
CREATE OR REPLACE STAGE TECHFLOW_DOCS_STAGE
URL = 's3://tu-bucket/techflow-docs/'
CREDENTIALS = (AWS_KEY_ID = 'TU_KEY' AWS_SECRET_KEY = 'TU_SECRET');

-- 2. Crear servicio de Cortex Search
CREATE OR REPLACE CORTEX SEARCH SERVICE TECHFLOW_SEARCH_SERVICE
ON text_column
ATTRIBUTES = (title, document_type, date_created)
WAREHOUSE = CORTEX_DEMO_WH
TARGET_LAG = '1 hour'
AS (
  SELECT 
    text_content as text_column,
    document_title as title,
    doc_type as document_type,
    created_date as date_created
  FROM TECHFLOW_DOCUMENTS
);
```

**Para esta demo**: Los documentos están simulados en la aplicación Streamlit.

### 🐍 PASO 4: Configuración de Aplicación Streamlit

#### A) Preparar Entorno Python

1. **Crear entorno virtual**:
   ```bash
   python -m venv cortex_demo_env
   source cortex_demo_env/bin/activate  # Linux/Mac
   cortex_demo_env\Scripts\activate     # Windows
   ```

2. **Crear archivo `requirements.txt`**:
   ```txt
   streamlit==1.28.0
   pandas==2.0.3
   plotly==5.17.0
   snowflake-snowpark-python==1.9.0
   snowflake-connector-python==3.4.0
   ```

3. **Instalar dependencias**:
   ```bash
   pip install -r requirements.txt
   ```

#### B) Configurar Credenciales

1. **Crear archivo `.streamlit/secrets.toml`**:
   ```toml
   [snowflake]
   user = "TU_USUARIO"
   password = "TU_PASSWORD"
   account = "TU_ACCOUNT.region"
   warehouse = "CORTEX_DEMO_WH"
   database = "TECHFLOW_DEMO"
   schema = "CORTEX_DEMO"
   role = "CORTEX_DEMO_ROLE"
   ```

2. **Configurar variables de entorno** (alternativo):
   ```bash
   export SNOWFLAKE_USER="tu_usuario"
   export SNOWFLAKE_PASSWORD="tu_password"
   export SNOWFLAKE_ACCOUNT="tu_account"
   ```

#### C) Ejecutar Aplicación

```bash
streamlit run techflow_streamlit_app.py
```

La aplicación estará disponible en `http://localhost:8501`

### 🤖 PASO 5: Configuración de ML Predictivo

#### A) Ejecutar Queries de ML

1. **Ejecutar archivo completo** `ml_predictive_strategies.sql`:
   ```sql
   -- El archivo incluye:
   -- - Configuración de forecasting
   -- - Detección de anomalías  
   -- - Análisis de churn
   -- - Funciones Python para Snowpark
   -- - Procedimientos automatizados
   ```

2. **Verificar funciones ML creadas**:
   ```sql
   -- Verificar forecasts
   SELECT * FROM PRONOSTICO_VENTAS LIMIT 5;
   
   -- Verificar detección de anomalías
   SELECT * FROM ANOMALIAS_TRANSACCIONES WHERE ANOMALY_SCORE > 0.5;
   
   -- Verificar análisis de churn
   SELECT * FROM ANALISIS_CHURN_CLIENTES LIMIT 5;
   ```

#### B) Configurar Alertas Automatizadas

```sql
-- Crear task para generar alertas automáticamente
CREATE OR REPLACE TASK ALERTAS_DAILY_TASK
  WAREHOUSE = CORTEX_DEMO_WH
  SCHEDULE = 'USING CRON 0 9 * * * UTC'  -- 9 AM diario
AS
  CALL GENERAR_ALERTAS_ANOMALIAS();

-- Iniciar task
ALTER TASK ALERTAS_DAILY_TASK RESUME;
```

---

## 🎬 GUÍA DE USO PARA LA DEMO

### 📊 Estructura de la Demostración

#### **Duración Total Recomendada**: 45-60 minutos

### 🎯 **PARTE 1: Introducción y Context (5 minutos)**

1. **Presentar TechFlow Solutions**:
   - Empresa de tecnología con soluciones empresariales
   - Presencia global, clientes enterprise/mid-market/SMB
   - Desafíos típicos: análisis de datos, búsqueda de información, predicciones

2. **Establecer el escenario**:
   - "Eres un ejecutivo de TechFlow que necesita insights rápidos"
   - "Los datos están distribuidos en múltiples sistemas"
   - "El tiempo es crítico para decisiones empresariales"

### 🤖 **PARTE 2: Cortex Analyst - Democratización de Datos (15 minutos)**

#### **Flujo de Demostración**:

1. **Mostrar Dashboard Ejecutivo** (3 min):
   - Métricas clave actuales
   - KPIs en tiempo real
   - "Pero necesitamos hacer preguntas específicas..."

2. **Demostrar preguntas en lenguaje natural** (8 min):
   ```
   Preguntas sugeridas para demostrar:
   • "¿Cuáles fueron nuestros ingresos totales en Q1 2024?"
   • "¿Qué producto tuvo mejor desempeño este año?"
   • "¿Cuál es el margen bruto por región?"
   • "¿Cuántos clientes nuevos hemos adquirido este trimestre?"
   ```

3. **Destacar capacidades** (4 min):
   - **No SQL requerido** - cualquier usuario de negocio puede usarlo
   - **Respuestas instantáneas** con visualizaciones automáticas
   - **Modelo semántico robusto** entiende contexto empresarial
   - **Drill-down automático** en insights relevantes

#### **Puntos Clave de Ventas**:
- ⚡ **Velocidad**: De pregunta a insight en segundos
- 🎯 **Democratización**: No necesitas ser analista de datos
- 🧠 **Inteligencia**: Entiende contexto y relaciones complejas
- 📊 **Visualización**: Gráficos automáticos contextuales

### 🔍 **PARTE 3: Cortex Search - Conocimiento Empresarial (10 minutos)**

#### **Flujo de Demostración**:

1. **Establecer el problema** (2 min):
   - "Información crítica está en documentos PDF"
   - "Búsqueda tradicional es lenta e imprecisa"
   - "Necesitamos respuestas, no solo documentos"

2. **Demostrar búsquedas inteligentes** (6 min):
   ```
   Búsquedas sugeridas:
   • "¿Cuáles fueron los ingresos y márgenes en 2023?"
   • "¿Cómo resolver errores de conectividad en CloudSync?"
   • "¿Cuál es el NPS actual y principales quejas?"
   • "¿Cuáles son los requisitos técnicos para AIChat?"
   ```

3. **Mostrar capacidades avanzadas** (2 min):
   - **Búsqueda semántica** vs keyword matching
   - **Extracción contextual** de información específica
   - **Referencias precisas** con páginas y secciones
   - **Múltiples documentos** simultáneamente

#### **Puntos Clave de Ventas**:
- 🔍 **Precisión**: RAG encuentra información exacta
- ⚡ **Velocidad**: Respuestas en segundos vs horas
- 🎯 **Contexto**: Entiende intención, no solo palabras
- 📚 **Escalabilidad**: Miles de documentos, una consulta

### 🎯 **PARTE 4: AISQL Multimodal - IA Integrada (10 minutos)**

#### **Flujo de Demostración**:

1. **Análisis de texto en SQL** (4 min):
   - Mostrar tickets de soporte reales
   - Clasificación automática de problemas
   - Análisis de sentimiento granular
   - Generación de respuestas sugeridas

2. **Análisis de imágenes** (3 min):
   - Descripción automática de interfaces de producto
   - Extracción de elementos de UI/UX
   - Insights para marketing visual

3. **Insights automáticos** (3 min):
   - Patrones descubiertos automáticamente
   - Recomendaciones de acción
   - Tendencias no evidentes manualmente

#### **Puntos Clave de Ventas**:
- 🤖 **IA Nativa**: Funciones AI directamente en SQL
- 🔄 **Multimodal**: Texto, imágenes, audio en un solo lugar
- 💡 **Insights Automáticos**: Descubre patrones ocultos
- ⚡ **Sin ETL**: Análisis directo en data warehouse

### 📈 **PARTE 5: ML Predictivo - Inteligencia Proactiva (10 minutos)**

#### **Flujo de Demostración**:

1. **Forecasting de ventas** (3 min):
   - Pronósticos automáticos por segmento
   - Intervalos de confianza
   - Planificación estratégica

2. **Detección de anomalías** (3 min):
   - Transacciones sospechosas en tiempo real
   - Prevención de fraude automática
   - Alertas inteligentes

3. **Análisis de churn** (4 min):
   - Identificación de clientes en riesgo
   - Scores de probabilidad precisos
   - Acciones de retención automatizadas

#### **Puntos Clave de Ventas**:
- 🔮 **Predictivo**: Anticipa problemas y oportunidades
- ⚡ **Tiempo Real**: Alertas inmediatas
- 🎯 **Accionable**: Recomendaciones específicas
- 💰 **ROI Medible**: Prevención de pérdidas cuantificable

### ⚠️ **PARTE 6: Monitoreo y Alertas - Operaciones Inteligentes (5 minutos)**

#### **Flujo de Demostración**:

1. **Dashboard en tiempo real** (2 min):
   - Métricas operacionales live
   - Alertas prioritarias
   - Tendencias automáticas

2. **Sistema de alertas inteligente** (3 min):
   - Configuración de umbrales dinámicos
   - Escalación automática
   - Integración con herramientas existentes

#### **Puntos Clave de Ventas**:
- 👁️ **Visibilidad Total**: Operaciones transparentes
- 🚨 **Proactividad**: Problemas detectados antes que ocurran
- ⚙️ **Automatización**: Menos intervención manual
- 📊 **Inteligencia**: Aprende de patrones históricos

---

## 🎭 PERSONALIZACIÓN DE LA DEMO

### 🎯 **Por Industria del Cliente**

#### **Servicios Financieros**:
- Enfoque en detección de fraude y compliance
- Análisis de riesgo crediticio
- Regulaciones y reportes automáticos

#### **Retail/E-commerce**:
- Análisis de comportamiento de cliente
- Optimización de inventario
- Personalización y recomendaciones

#### **Manufactura**:
- Predictive maintenance
- Optimización de cadena de suministro
- Quality control automatizado

#### **Healthcare**:
- Análisis de resultados de pacientes
- Optimización operacional
- Investigación y desarrollo

### 🎯 **Por Rol del Audiencia**

#### **C-Level Executives**:
- Enfoque en ROI y impacto empresarial
- Métricas estratégicas y KPIs
- Ventaja competitiva y diferenciación

#### **IT/Data Leaders**:
- Capacidades técnicas y escalabilidad
- Integración con arquitectura existente
- Seguridad y governance

#### **Business Analysts**:
- Facilidad de uso y productividad
- Calidad de insights y precisión
- Flujos de trabajo y colaboración

---

## 🔧 SOLUCIÓN DE PROBLEMAS COMUNES

### ❌ **Problemas de Conexión Snowflake**

**Error**: `snowflake.connector.errors.DatabaseError`
```bash
# Verificar credenciales
streamlit secrets list

# Verificar conectividad de red
telnet tu-account.snowflakecomputing.com 443

# Verificar permisos de usuario
USE ROLE CORTEX_DEMO_ROLE;
USE WAREHOUSE CORTEX_DEMO_WH;
```

### ❌ **Errores de Streamlit**

**Error**: `ModuleNotFoundError`
```bash
# Reinstalar dependencias
pip install -r requirements.txt --upgrade

# Verificar entorno virtual activo
which python
```

**Error**: `DuplicateWidgetID`
```bash
# Limpiar cache de Streamlit
streamlit cache clear
```

### ❌ **Problemas de Performance**

**Warehouse muy lento**:
```sql
-- Aumentar tamaño de warehouse
ALTER WAREHOUSE CORTEX_DEMO_WH SET WAREHOUSE_SIZE = 'LARGE';
```

**Queries lentas**:
```sql
-- Verificar clustering de tablas grandes
ALTER TABLE TRANSACCIONES CLUSTER BY (FECHA_TRANSACCION);
```

### ❌ **Datos no cargan correctamente**

```sql
-- Verificar conteo de registros
SELECT COUNT(*) FROM TRANSACCIONES;

-- Verificar datos recientes
SELECT MAX(FECHA_TRANSACCION) FROM TRANSACCIONES;

-- Re-ejecutar inserts si es necesario
-- (Código está en techflow_demo_schema.sql)
```

---

## 📱 CONFIGURACIÓN AVANZADA

### 🔐 **Seguridad y Compliance**

#### **Row-Level Security**:
```sql
-- Ejemplo: Restringir acceso por región
CREATE OR REPLACE ROW ACCESS POLICY region_policy AS (region varchar) 
RETURNS BOOLEAN ->
  CURRENT_ROLE() = 'ADMIN_ROLE' OR 
  region = CURRENT_USER();

ALTER TABLE TRANSACCIONES ADD ROW ACCESS POLICY region_policy ON (region);
```

#### **Column-Level Security**:
```sql
-- Enmascarar información sensible
CREATE OR REPLACE MASKING POLICY email_mask AS (val string) 
RETURNS string ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN_ROLE') THEN val
    ELSE '*****@******.com'
  END;

ALTER TABLE CLIENTES ALTER COLUMN EMAIL SET MASKING POLICY email_mask;
```

### 📊 **Optimización de Performance**

#### **Clustering Keys**:
```sql
-- Para tablas grandes, configurar clustering
ALTER TABLE TRANSACCIONES CLUSTER BY (FECHA_TRANSACCION, REGION);
ALTER TABLE TICKETS_SOPORTE CLUSTER BY (FECHA_CREACION, PRIORIDAD);
```

#### **Materialized Views**:
```sql
-- Para métricas consultadas frecuentemente
CREATE OR REPLACE MATERIALIZED VIEW MV_MONTHLY_SALES AS
SELECT 
    DATE_TRUNC('MONTH', FECHA_TRANSACCION) AS MES,
    SUM(CANTIDAD * PRECIO_UNITARIO) AS INGRESOS_TOTALES,
    COUNT(*) AS NUMERO_TRANSACCIONES
FROM TRANSACCIONES 
WHERE ESTADO_PEDIDO = 'COMPLETADO'
GROUP BY DATE_TRUNC('MONTH', FECHA_TRANSACCION);
```

### 🔄 **Automatización y Scheduling**

#### **Tasks para actualización de datos**:
```sql
-- Task para actualizar métricas diariamente
CREATE OR REPLACE TASK UPDATE_DAILY_METRICS
  WAREHOUSE = CORTEX_DEMO_WH
  SCHEDULE = 'USING CRON 0 2 * * * UTC'  -- 2 AM UTC diario
AS
  -- Refresh materialized views
  ALTER MATERIALIZED VIEW MV_MONTHLY_SALES REFRESH;

ALTER TASK UPDATE_DAILY_METRICS RESUME;
```

#### **Streams para cambios en tiempo real**:
```sql
-- Stream para detectar nuevas transacciones
CREATE OR REPLACE STREAM TRANSACCIONES_STREAM ON TABLE TRANSACCIONES;

-- Task para procesar cambios
CREATE OR REPLACE TASK PROCESS_NEW_TRANSACTIONS
  WAREHOUSE = CORTEX_DEMO_WH
  SCHEDULE = '5 MINUTE'
WHEN
  SYSTEM$STREAM_HAS_DATA('TRANSACCIONES_STREAM')
AS
  -- Procesar nuevas transacciones para anomalías
  INSERT INTO ANOMALIAS_TRANSACCIONES 
  SELECT /* query para nuevas anomalías */;
```

---

## 📋 CHECKLIST PRE-DEMO

### ✅ **24 Horas Antes**
- [ ] Verificar acceso a cuenta Snowflake
- [ ] Confirmar que Cortex está habilitado
- [ ] Probar ejecución completa del setup
- [ ] Verificar aplicación Streamlit funciona
- [ ] Preparar escenarios de personalización

### ✅ **1 Hora Antes**
- [ ] Ejecutar queries de prueba en Snowflake
- [ ] Verificar datos actualizados
- [ ] Probar conectividad de red
- [ ] Tener backup de datos listos
- [ ] Configurar pantalla y audio

### ✅ **Durante la Demo**
- [ ] Modo simulación activado si hay problemas de conectividad
- [ ] Narrativa adaptada al cliente específico
- [ ] Ejemplos relevantes para su industria
- [ ] Q&A preparada para objeciones comunes

---

## 📞 SOPORTE Y CONTACTOS

### 🆘 **En Caso de Problemas Técnicos**

1. **Problemas de Snowflake**: Contactar Snowflake Support
2. **Problemas de aplicación**: Revisar logs en terminal
3. **Problemas de red**: Verificar firewall y VPN
4. **Emergencia durante demo**: Activar modo simulación

### 📚 **Recursos Adicionales**

- **Documentación Cortex**: [docs.snowflake.com/cortex](https://docs.snowflake.com/cortex)
- **Snowpark Python**: [docs.snowflake.com/snowpark](https://docs.snowflake.com/snowpark)
- **Streamlit**: [docs.streamlit.io](https://docs.streamlit.io)

### 💡 **Tips para Ingeniero de Ventas**

1. **Practica la demo** al menos 3 veces antes de presentar
2. **Personaliza ejemplos** según la industria del cliente
3. **Prepara respuestas** para objeciones técnicas comunes
4. **Enfócate en valor** de negocio, no solo en características técnicas
5. **Ten backups** para cada sección en caso de problemas técnicos

---

*¡Éxito en tu demostración de Snowflake Cortex con TechFlow Solutions! 🚀*





