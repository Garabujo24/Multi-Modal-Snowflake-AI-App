# CASOS DE USO AISQL MULTIMODAL
## TechFlow Solutions Demo Kit

### Descripción General

Las funciones multimodales de AISQL en Snowflake Cortex permiten analizar e interpretar diferentes tipos de datos (texto, imágenes, audio) usando inteligencia artificial. Estos casos de uso están diseñados para demostrar el poder de la IA integrada directamente en SQL para extraer insights de datos no estructurados.

---

## 🔤 CASOS DE USO PARA ANÁLISIS DE TEXTO

### 1. **Análisis Inteligente de Tickets de Soporte**

#### **Datos Base**: 
Columna `DESCRIPCION_PROBLEMA` en tabla `TICKETS_SOPORTE`

#### **Casos de Uso**:

**A) Clasificación Automática de Problemas**
```sql
-- Ejemplo conceptual usando CLASSIFY()
SELECT 
    TICKET_ID,
    DESCRIPCION_PROBLEMA,
    SNOWFLAKE.CORTEX.CLASSIFY(
        DESCRIPCION_PROBLEMA,
        ['Technical Error', 'Feature Request', 'Performance Issue', 
         'Integration Problem', 'User Training', 'Bug Report']
    ) AS CATEGORIA_AUTOMATICA,
    TIPO_PROBLEMA AS CATEGORIA_MANUAL
FROM TICKETS_SOPORTE 
WHERE FECHA_CREACION >= '2024-01-01';
```

**B) Extracción de Información Específica**
```sql
-- Extraer códigos de error mencionados en tickets
SELECT 
    TICKET_ID,
    CLIENTE_ID,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        DESCRIPCION_PROBLEMA,
        'What error codes are mentioned in this support ticket?'
    ) AS CODIGOS_ERROR_ENCONTRADOS,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        DESCRIPCION_PROBLEMA,
        'What specific product features are mentioned?'
    ) AS FEATURES_MENCIONADAS
FROM TICKETS_SOPORTE 
WHERE DESCRIPCION_PROBLEMA ILIKE '%error%' OR DESCRIPCION_PROBLEMA ILIKE '%CS-%';
```

**C) Resumen Automático de Tickets Complejos**
```sql
-- Resumir descripciones largas de problemas
SELECT 
    TICKET_ID,
    CLIENTE_ID,
    PRODUCTO_ID,
    SNOWFLAKE.CORTEX.SUMMARIZE(DESCRIPCION_PROBLEMA) AS RESUMEN_EJECUTIVO,
    LENGTH(DESCRIPCION_PROBLEMA) AS CARACTERES_ORIGINAL,
    LENGTH(SNOWFLAKE.CORTEX.SUMMARIZE(DESCRIPCION_PROBLEMA)) AS CARACTERES_RESUMEN
FROM TICKETS_SOPORTE 
WHERE LENGTH(DESCRIPCION_PROBLEMA) > 200
ORDER BY CARACTERES_ORIGINAL DESC;
```

**D) Análisis de Sentimiento Granular**
```sql
-- Análisis de sentimiento más detallado que la columna existente
SELECT 
    TICKET_ID,
    SENTIMIENTO AS SENTIMIENTO_MANUAL,
    SNOWFLAKE.CORTEX.SENTIMENT(DESCRIPCION_PROBLEMA) AS SENTIMIENTO_IA,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        DESCRIPCION_PROBLEMA,
        'What is the customer''s emotional tone and level of urgency in this message?'
    ) AS ANALISIS_EMOCIONAL_DETALLADO
FROM TICKETS_SOPORTE 
WHERE FECHA_CREACION >= '2024-03-01';
```

### 2. **Análisis de Feedback de Productos**

#### **Casos de Uso**:

**A) Identificación de Temas Recurrentes**
```sql
-- Agregar columna de texto libre para feedback de productos
ALTER TABLE TICKETS_SOPORTE ADD COLUMN FEEDBACK_ADICIONAL VARCHAR(2000);

-- Análisis de temas comunes en feedback
SELECT 
    PRODUCTO_ID,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        FEEDBACK_ADICIONAL,
        'What are the main themes or topics mentioned in this feedback?'
    ) AS TEMAS_PRINCIPALES,
    COUNT(*) AS FRECUENCIA
FROM TICKETS_SOPORTE 
WHERE FEEDBACK_ADICIONAL IS NOT NULL 
  AND SENTIMIENTO = 'POSITIVO'
GROUP BY PRODUCTO_ID, TEMAS_PRINCIPALES
ORDER BY FRECUENCIA DESC;
```

**B) Generación de Respuestas Sugeridas**
```sql
-- Generar respuestas sugeridas para tickets comunes
SELECT 
    TICKET_ID,
    TIPO_PROBLEMA,
    DESCRIPCION_PROBLEMA,
    SNOWFLAKE.CORTEX.COMPLETE(
        'Based on this customer support ticket: "' || DESCRIPCION_PROBLEMA || 
        '", generate a professional, helpful response that addresses their concern and provides next steps.'
    ) AS RESPUESTA_SUGERIDA
FROM TICKETS_SOPORTE 
WHERE ESTADO = 'EN_PROCESO' 
  AND PRIORIDAD IN ('ALTA', 'CRITICA');
```

---

## 🖼️ CASOS DE USO PARA ANÁLISIS DE IMÁGENES

### 3. **Análisis Automático de Imágenes de Productos**

#### **Datos Base**: 
Columna `URL_IMAGEN` en tabla `PRODUCTOS`

#### **Casos de Uso**:

**A) Descripción Automática de Productos**
```sql
-- Generar descripciones automáticas basadas en imágenes
SELECT 
    PRODUCTO_ID,
    NOMBRE,
    URL_IMAGEN,
    SNOWFLAKE.CORTEX.DESCRIBE_IMAGE(
        BUILD_SCOPED_FILE_URL(@IMAGE_STAGE, URL_IMAGEN),
        'Describe this product image in detail, focusing on key features, design elements, and visual characteristics that would be important for marketing and sales.'
    ) AS DESCRIPCION_VISUAL_AUTOMATICA
FROM PRODUCTOS 
WHERE URL_IMAGEN IS NOT NULL 
  AND CATEGORIA = 'Software';
```

**B) Extracción de Características Visuales**
```sql
-- CORREGIDO: Extraer características visuales usando datos simulados y funciones disponibles

-- Crear tabla de análisis visual detallado si no existe
CREATE OR REPLACE TABLE TECHFLOW_DEMO.CORTEX_DEMO.ANALISIS_VISUAL_DETALLADO (
    PRODUCTO_ID VARCHAR(10),
    URL_IMAGEN VARCHAR(500),
    DESCRIPCION_VISUAL TEXT,
    ELEMENTOS_UI_RAW TEXT,
    TIPO_INTERFAZ_BASE VARCHAR(100),
    COLORES_PRINCIPALES VARCHAR(200),
    PATRONES_DISENO TEXT
);

-- Insertar datos simulados para análisis visual
INSERT INTO TECHFLOW_DEMO.CORTEX_DEMO.ANALISIS_VISUAL_DETALLADO VALUES
('PROD001', 'cloudsync_dashboard.png', 
 'Modern dashboard interface with clean blue and white color scheme. Features data visualization charts, KPI cards, and real-time sync indicators.',
 'Left navigation sidebar, top header bar, data cards grid, progress bars, status indicators, search functionality, filter dropdowns',
 'Web application dashboard',
 'Primary: Blue (#2563eb), Secondary: White (#ffffff), Accent: Gray (#6b7280), Success: Green (#22c55e)',
 'Card-based layout, progressive disclosure, responsive grid system, flat design, minimal shadows'),
 
('PROD002', 'dataflow_analytics.png',
 'Business intelligence interface with dark theme and interactive data visualizations. Multiple chart types and advanced filtering capabilities.',
 'Interactive charts, filter panels, date range selectors, export buttons, drill-down menus, tooltip overlays, legend controls',
 'Business intelligence web application',
 'Primary: Dark navy (#1e293b), Secondary: Orange (#f97316), Accent: Green (#22c55e), Warning: Yellow (#fbbf24)',
 'Dark mode design, data storytelling layout, interactive hover states, gradient overlays'),
 
('PROD005', 'aichat_assistant.png',
 'Conversational AI interface with chat bubbles, avatar, and quick action buttons. Mobile-optimized with clean typography.',
 'Chat message bubbles, AI avatar icon, quick reply buttons, typing indicator, send button, emoji picker, attachment icon',
 'Mobile chat application',
 'Primary: Light blue (#3b82f6), Secondary: Gray (#9ca3af), Background: White (#f9fafb), Text: Dark gray (#374151)',
 'Conversational UI patterns, minimalist design, mobile-first responsive, bubble UI, floating action buttons'),
 
('PROD008', 'quantum_analytics.png',
 'Advanced analytics platform with quantum computing visualizations. Futuristic design with complex data models.',
 'Quantum circuit diagrams, 3D data visualizations, mathematical formula displays, performance graphs, neon accent elements',
 'Advanced analytics web platform',
 'Primary: Deep purple (#6b21a8), Secondary: Cyan (#06b6d4), Accent: Neon pink (#ec4899), Glow: Electric blue (#0ea5e9)',
 'Futuristic aesthetic, high-tech visualization, gradient effects, neon accents, glassmorphism, 3D elements');

-- Query corregida para análisis de características visuales
SELECT 
    p.PRODUCTO_ID,
    p.NOMBRE,
    p.CATEGORIA,
    a.URL_IMAGEN,
    
    -- Análisis inteligente de elementos UI usando CORTEX.COMPLETE
    SNOWFLAKE.CORTEX.COMPLETE(
        'mixtral-8x7b',
        'Analyze these UI elements from a ' || p.CATEGORIA || ' product interface: "' || a.ELEMENTOS_UI_RAW || 
        '". Categorize them by: 1) Navigation elements, 2) Data input/output, 3) Interactive controls, 4) Visual feedback. 
        Provide insights on UX design patterns used.'
    ) AS ANALISIS_ELEMENTOS_UI,
    
    -- Extracción específica del tipo de interfaz
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        'This is a ' || a.TIPO_INTERFAZ_BASE || ' with the following characteristics: ' || a.DESCRIPCION_VISUAL,
        'What type of application interface is this - mobile app, web application, or desktop software? Explain the key identifying features.'
    ) AS TIPO_INTERFAZ_DETALLADO,
    
    -- Análisis de colores y patrones usando COMPLETE
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-7b',
        'Analyze this color scheme: "' || a.COLORES_PRINCIPALES || '" and design patterns: "' || a.PATRONES_DISENO || 
        '". Explain: 1) Color psychology impact, 2) Accessibility considerations, 3) Brand perception, 4) User experience implications.'
    ) AS ANALISIS_COLORES_PATRONES,
    
    -- Datos originales para referencia
    a.COLORES_PRINCIPALES,
    a.PATRONES_DISENO,
    a.ELEMENTOS_UI_RAW AS ELEMENTOS_UI_DETECTADOS
    
FROM TECHFLOW_DEMO.CORTEX_DEMO.PRODUCTOS p
JOIN TECHFLOW_DEMO.CORTEX_DEMO.ANALISIS_VISUAL_DETALLADO a ON p.PRODUCTO_ID = a.PRODUCTO_ID
WHERE p.CATEGORIA IN ('Software', 'IA/ML')
ORDER BY p.CATEGORIA, p.NOMBRE;
```

**C) Comparación Visual de Productos**
```sql
-- Crear tabla de análisis comparativo visual
CREATE OR REPLACE TABLE ANALISIS_VISUAL_PRODUCTOS AS
SELECT 
    p.PRODUCTO_ID,
    p.NOMBRE,
    p.CATEGORIA,
    SNOWFLAKE.CORTEX.CLASSIFY(
        SNOWFLAKE.CORTEX.DESCRIBE_IMAGE(
            BUILD_SCOPED_FILE_URL(@IMAGE_STAGE, p.URL_IMAGEN)
        ),
        ['Modern UI', 'Traditional Interface', 'Mobile-First', 'Data-Heavy', 'Minimalist Design']
    ) AS ESTILO_UI,
    SNOWFLAKE.CORTEX.COMPLETE(
        'Based on this product image analysis: ' || 
        SNOWFLAKE.CORTEX.DESCRIBE_IMAGE(BUILD_SCOPED_FILE_URL(@IMAGE_STAGE, p.URL_IMAGEN)) ||
        ', suggest 3 marketing positioning points that highlight the visual appeal and user experience.'
    ) AS PUNTOS_MARKETING_VISUAL
FROM PRODUCTOS p
WHERE p.URL_IMAGEN IS NOT NULL;
```

### 4. **Análisis de Documentos con Contenido Visual**

#### **Casos de Uso**:

**A) Extracción de Información de Diagramas**
```sql
-- Análisis de diagramas de arquitectura en documentación
CREATE OR REPLACE TABLE DOCUMENTOS_TECNICOS (
    DOC_ID VARCHAR(10),
    NOMBRE_DOCUMENTO VARCHAR(100),
    URL_DIAGRAMA VARCHAR(200),
    TIPO_DIAGRAMA VARCHAR(50)
);

-- QUERY CORREGIDA: Análisis de Diagramas con CORTEX.COMPLETE (simulado)

-- Crear tabla con datos simulados de documentos técnicos
CREATE OR REPLACE TABLE TECHFLOW_DEMO.CORTEX_DEMO.DOCUMENTOS_TECNICOS (
    DOC_ID VARCHAR(10),
    NOMBRE_DOCUMENTO VARCHAR(100),
    URL_DIAGRAMA VARCHAR(200),
    TIPO_DIAGRAMA VARCHAR(50),
    DESCRIPCION_CONTENIDO TEXT
);

-- Insertar datos de ejemplo
INSERT INTO TECHFLOW_DEMO.CORTEX_DEMO.DOCUMENTOS_TECNICOS VALUES
('DOC001', 'CloudSync Architecture Overview', 'cloudsync_arch.png', 'Architecture', 
 'Technical diagram showing CloudSync system architecture with API Gateway, microservices, database clusters, and external integrations including SAP, Salesforce, and AWS services'),
('DOC002', 'DataFlow Analytics Pipeline', 'dataflow_pipeline.png', 'Architecture',
 'Data pipeline architecture diagram featuring data ingestion layer, ETL processes, Apache Kafka streams, data warehouse, and business intelligence dashboards'),
('DOC003', 'SecureVault Security Model', 'securevault_security.png', 'Security',
 'Security architecture showing encryption layers, identity management, multi-factor authentication, audit trails, and compliance frameworks like SOC2 and ISO27001'),
('DOC004', 'AIChat Integration Patterns', 'aichat_integration.png', 'Integration',
 'Integration architecture with REST APIs, webhook endpoints, CRM connectors, and machine learning model deployment using Docker containers'),
('DOC005', 'Enterprise Network Topology', 'network_topology.png', 'Network',
 'Network diagram displaying VPC configuration, subnets, load balancers, firewalls, and hybrid cloud connectivity between on-premises and cloud infrastructure');

-- Query corregida usando CORTEX.COMPLETE para simular análisis de diagramas
SELECT 
    DOC_ID,
    NOMBRE_DOCUMENTO,
    URL_DIAGRAMA,
    TIPO_DIAGRAMA,
    SNOWFLAKE.CORTEX.COMPLETE(
        'mixtral-8x7b',
        'Based on this technical documentation: "' || DESCRIPCION_CONTENIDO || 
        '", identify and list the main architectural components and their connections. 
        Focus on: 1) Core systems, 2) Integration points, 3) Data flow patterns. 
        Respond in a structured format with bullet points.'
    ) AS COMPONENTES_ARQUITECTURA,
    SNOWFLAKE.CORTEX.COMPLETE(
        'mixtral-8x7b',
        'From this technical description: "' || DESCRIPCION_CONTENIDO || 
        '", extract and list all technologies, platforms, and tools mentioned. 
        Include: databases, cloud services, frameworks, protocols, and standards. 
        Format as a comma-separated list.'
    ) AS TECNOLOGIAS_IDENTIFICADAS
FROM TECHFLOW_DEMO.CORTEX_DEMO.DOCUMENTOS_TECNICOS
WHERE TIPO_DIAGRAMA = 'Architecture'
ORDER BY DOC_ID;
```

---

## 🎵 CASOS DE USO PARA ANÁLISIS DE AUDIO (Conceptual)

### 5. **Análisis de Llamadas de Ventas**

#### **Datos Base**: 
Tabla conceptual `LLAMADAS_VENTAS` con transcripciones

#### **Casos de Uso**:

**A) Análisis de Sentimiento en Llamadas**
```sql
-- Crear tabla conceptual para llamadas de ventas
CREATE OR REPLACE TABLE LLAMADAS_VENTAS (
    LLAMADA_ID VARCHAR(15),
    VENDEDOR_ID VARCHAR(10),
    CLIENTE_ID VARCHAR(10),
    FECHA_LLAMADA TIMESTAMP,
    DURACION_MINUTOS INT,
    TRANSCRIPCION TEXT,
    RESULTADO_LLAMADA VARCHAR(50)
);

-- Análisis de sentimiento y éxito de llamadas
SELECT 
    LLAMADA_ID,
    VENDEDOR_ID,
    CLIENTE_ID,
    RESULTADO_LLAMADA,
    SNOWFLAKE.CORTEX.SENTIMENT(TRANSCRIPCION) AS SENTIMIENTO_GENERAL,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        TRANSCRIPCION,
        'What were the main objections or concerns raised by the customer?'
    ) AS OBJECIONES_IDENTIFICADAS,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        TRANSCRIPCION,
        'What products or features showed the most customer interest?'
    ) AS PRODUCTOS_INTERES
FROM LLAMADAS_VENTAS 
WHERE FECHA_LLAMADA >= '2024-01-01';
```

**B) Extracción de Insights de Ventas**
```sql
-- Identificar patrones de éxito en llamadas
SELECT 
    VENDEDOR_ID,
    AVG(CASE WHEN RESULTADO_LLAMADA = 'CERRADA' THEN 1 ELSE 0 END) AS TASA_CONVERSION,
    SNOWFLAKE.CORTEX.SUMMARIZE(
        LISTAGG(
            CASE WHEN RESULTADO_LLAMADA = 'CERRADA' THEN TRANSCRIPCION END, 
            ' | '
        )
    ) AS PATRONES_EXITO,
    COUNT(*) AS TOTAL_LLAMADAS
FROM LLAMADAS_VENTAS 
GROUP BY VENDEDOR_ID
HAVING COUNT(*) >= 10
ORDER BY TASA_CONVERSION DESC;
```

---

## 🔄 CASOS DE USO INTEGRADOS MULTIMODALES

### 6. **Análisis Integral de Experiencia del Cliente**

#### **Combinando Texto, Imágenes y Datos Estructurados**:

```sql
-- Vista integrada de experiencia del cliente
CREATE OR REPLACE VIEW EXPERIENCIA_CLIENTE_360 AS
SELECT 
    c.CLIENTE_ID,
    c.NOMBRE AS NOMBRE_CLIENTE,
    c.SEGMENTO,
    
    -- Métricas transaccionales
    COUNT(t.TRANSACCION_ID) AS TOTAL_COMPRAS,
    SUM(t.CANTIDAD * t.PRECIO_UNITARIO) AS VALOR_TOTAL,
    
    -- Análisis de soporte con IA
    COUNT(ts.TICKET_ID) AS TOTAL_TICKETS,
    AVG(ts.SATISFACCION_CLIENTE) AS SATISFACCION_PROMEDIO,
    SNOWFLAKE.CORTEX.SUMMARIZE(
        LISTAGG(ts.DESCRIPCION_PROBLEMA, ' | ')
    ) AS RESUMEN_PROBLEMAS_REPORTADOS,
    
    -- Análisis de sentimiento agregado
    AVG(SNOWFLAKE.CORTEX.SENTIMENT(ts.DESCRIPCION_PROBLEMA)) AS SENTIMIENTO_PROMEDIO_IA,
    
    -- Productos más utilizados
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        LISTAGG(p.NOMBRE || ': ' || p.DESCRIPCION, ' | '),
        'What are the main product categories and use cases for this customer?'
    ) AS PERFIL_PRODUCTOS_IA

FROM CLIENTES c
LEFT JOIN TRANSACCIONES t ON c.CLIENTE_ID = t.CLIENTE_ID
LEFT JOIN TICKETS_SOPORTE ts ON c.CLIENTE_ID = ts.CLIENTE_ID
LEFT JOIN PRODUCTOS p ON t.PRODUCTO_ID = p.PRODUCTO_ID
GROUP BY c.CLIENTE_ID, c.NOMBRE, c.SEGMENTO;
```

### 7. **Generación Automática de Reportes Ejecutivos**

```sql
-- Generar insights ejecutivos usando múltiples fuentes
SELECT 
    'Q1 2024 Executive Summary' AS REPORTE,
    SNOWFLAKE.CORTEX.COMPLETE(
        'Generate an executive summary based on the following business data: ' ||
        'Total Revenue: $' || (SELECT SUM(CANTIDAD * PRECIO_UNITARIO) FROM TRANSACCIONES WHERE FECHA_TRANSACCION >= '2024-01-01' AND FECHA_TRANSACCION < '2024-04-01') ||
        ', Customer Satisfaction: ' || (SELECT AVG(SATISFACCION_CLIENTE) FROM TICKETS_SOPORTE WHERE FECHA_CREACION >= '2024-01-01') ||
        ', Top Issues: ' || (SELECT SNOWFLAKE.CORTEX.SUMMARIZE(LISTAGG(DESCRIPCION_PROBLEMA, '; ')) FROM TICKETS_SOPORTE WHERE FECHA_CREACION >= '2024-01-01' AND PRIORIDAD = 'ALTA') ||
        '. Provide 3 key insights and 2 recommendations.'
    ) AS RESUMEN_EJECUTIVO_IA;
```

---

## 🛠️ CONFIGURACIÓN TÉCNICA PARA AISQL MULTIMODAL

### **Preparación de Datos**

#### **Para Análisis de Texto**:
```sql
-- Configurar stage para documentos de texto
CREATE OR REPLACE STAGE TEXT_ANALYSIS_STAGE
URL = 's3://techflow-cortex-demo/text-data/'
CREDENTIALS = (AWS_KEY_ID = 'AKIA...' AWS_SECRET_KEY = '...');

-- Función auxiliar para limpiar texto
CREATE OR REPLACE FUNCTION CLEAN_TEXT(input_text STRING)
RETURNS STRING
LANGUAGE SQL
AS $$
    TRIM(REGEXP_REPLACE(input_text, '[^a-zA-Z0-9\\s\\-\\.]', ' '))
$$;
```

#### **Para Análisis de Imágenes**:
```sql
-- Configurar stage para imágenes
CREATE OR REPLACE STAGE IMAGE_STAGE
URL = 's3://techflow-cortex-demo/product-images/'
CREDENTIALS = (AWS_KEY_ID = 'AKIA...' AWS_SECRET_KEY = '...');

-- Tabla de metadatos de imágenes
CREATE OR REPLACE TABLE IMAGE_METADATA (
    IMAGE_ID VARCHAR(20),
    PRODUCTO_ID VARCHAR(10),
    FILE_PATH VARCHAR(200),
    IMAGE_TYPE VARCHAR(20),
    UPLOAD_DATE TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);
```

### **Optimización de Rendimiento**

#### **Caching de Resultados de IA**:
```sql
-- Tabla para cachear resultados costosos de IA
CREATE OR REPLACE TABLE AI_RESULTS_CACHE (
    CONTENT_HASH VARCHAR(64),
    FUNCTION_NAME VARCHAR(50),
    PARAMETERS VARCHAR(1000),
    RESULT TEXT,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    EXPIRES_AT TIMESTAMP
);

-- Índice para búsquedas rápidas
CREATE INDEX idx_content_hash ON AI_RESULTS_CACHE(CONTENT_HASH, FUNCTION_NAME);
```

#### **Batch Processing para Análisis Masivo**:
```sql
-- Procedimiento para procesamiento por lotes
CREATE OR REPLACE PROCEDURE BATCH_ANALYZE_TICKETS()
RETURNS VARCHAR
LANGUAGE SQL
AS $$
BEGIN
    -- Procesar tickets nuevos sin análisis de IA
    CREATE OR REPLACE TEMPORARY TABLE NEW_TICKET_ANALYSIS AS
    SELECT 
        TICKET_ID,
        SNOWFLAKE.CORTEX.CLASSIFY(DESCRIPCION_PROBLEMA, 
            ['Technical', 'Billing', 'Feature Request', 'Bug Report']) AS AI_CATEGORY,
        SNOWFLAKE.CORTEX.SENTIMENT(DESCRIPCION_PROBLEMA) AS AI_SENTIMENT,
        CURRENT_TIMESTAMP() AS ANALYZED_AT
    FROM TICKETS_SOPORTE 
    WHERE TICKET_ID NOT IN (SELECT TICKET_ID FROM AI_RESULTS_CACHE WHERE FUNCTION_NAME = 'TICKET_ANALYSIS');
    
    -- Insertar resultados en caché
    INSERT INTO AI_RESULTS_CACHE 
    SELECT 
        SHA2(TICKET_ID || DESCRIPCION_PROBLEMA),
        'TICKET_ANALYSIS',
        AI_CATEGORY || '|' || AI_SENTIMENT,
        ANALYZED_AT,
        DATEADD('day', 30, ANALYZED_AT)
    FROM NEW_TICKET_ANALYSIS;
    
    RETURN 'Analyzed ' || (SELECT COUNT(*) FROM NEW_TICKET_ANALYSIS) || ' new tickets';
END;
$$;
```

---

## 📊 MÉTRICAS Y MONITOREO

### **Tracking de Uso de Funciones IA**:
```sql
-- Vista para monitorear uso de funciones Cortex
CREATE OR REPLACE VIEW CORTEX_USAGE_METRICS AS
SELECT 
    DATE_TRUNC('day', QUERY_HISTORY.START_TIME) AS FECHA,
    COUNT(*) AS TOTAL_QUERIES,
    SUM(CASE WHEN QUERY_TEXT ILIKE '%CORTEX.COMPLETE%' THEN 1 ELSE 0 END) AS COMPLETE_CALLS,
    SUM(CASE WHEN QUERY_TEXT ILIKE '%CORTEX.SENTIMENT%' THEN 1 ELSE 0 END) AS SENTIMENT_CALLS,
    SUM(CASE WHEN QUERY_TEXT ILIKE '%CORTEX.CLASSIFY%' THEN 1 ELSE 0 END) AS CLASSIFY_CALLS,
    SUM(CASE WHEN QUERY_TEXT ILIKE '%CORTEX.EXTRACT_ANSWER%' THEN 1 ELSE 0 END) AS EXTRACT_CALLS,
    AVG(EXECUTION_TIME) AS AVG_EXECUTION_TIME_MS
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY 
WHERE QUERY_TEXT ILIKE '%CORTEX.%'
  AND START_TIME >= DATEADD('day', -30, CURRENT_TIMESTAMP())
GROUP BY DATE_TRUNC('day', QUERY_HISTORY.START_TIME)
ORDER BY FECHA DESC;
```

### **ROI de Análisis de IA**:
```sql
-- Calcular ROI de análisis automatizado vs manual
SELECT 
    'AI Analysis ROI' AS METRIC,
    COUNT(*) AS TOTAL_TICKETS_ANALYZED,
    COUNT(*) * 15 AS MINUTES_SAVED_MANUAL_ANALYSIS,
    COUNT(*) * 0.5 AS ESTIMATED_COST_USD,
    (COUNT(*) * 15 * 30 / 60) AS HOURS_SAVED_MONTHLY, -- Assuming 30 USD/hour analyst
    (COUNT(*) * 15 * 30 / 60) - (COUNT(*) * 0.5) AS NET_SAVINGS_USD
FROM TICKETS_SOPORTE 
WHERE FECHA_CREACION >= DATEADD('month', -1, CURRENT_TIMESTAMP());
```

---

*Estos casos de uso multimodales demuestran cómo AISQL puede transformar datos no estructurados en insights accionables, automatizar procesos manuales y proporcionar análisis más profundos de la experiencia del cliente y operaciones empresariales.*

