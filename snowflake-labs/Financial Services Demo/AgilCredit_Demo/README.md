# 💳 AgilCredit - Demo Completa de Servicios Financieros

**Fintech Mexicana especializada en créditos personales y empresariales**

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Snowflake](https://img.shields.io/badge/Snowflake-Ready-29B5E8)
![Status](https://img.shields.io/badge/status-Production%20Ready-green)

---

## 📋 Tabla de Contenidos

- [Descripción General](#-descripción-general)
- [Características Principales](#-características-principales)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Datos Generados](#-datos-generados)
- [Instrucciones de Instalación](#-instrucciones-de-instalación)
- [Casos de Uso](#-casos-de-uso)
- [Procesamiento de Datos No Estructurados](#-procesamiento-de-datos-no-estructurados)
- [Modelo Semántico](#-modelo-semántico)
- [Dashboard Interactivo](#-dashboard-interactivo)
- [Gestión de Costos (FinOps)](#-gestión-de-costos-finops)
- [Recursos Adicionales](#-recursos-adicionales)

---

## 🎯 Descripción General

**AgilCredit** es una demostración completa de una fintech mexicana que utiliza Snowflake para:

- **Análisis de Riesgo Crediticio**: Evaluación de capacidad de pago, scoring interno y gestión de cartera
- **Detección de Fraude**: Sistema automatizado de alertas con ML para identificar transacciones sospechosas
- **Rentabilidad de Clientes**: Cálculo de LTV, CAC y segmentación por valor del cliente
- **Cumplimiento Regulatorio**: KYC (Know Your Customer) y PLD (Prevención de Lavado de Dinero)

### Historia de AgilCredit

AgilCredit nació en 2020 como respuesta a la necesidad de democratizar el acceso al crédito en México. Fundada por un equipo de expertos en tecnología financiera, la empresa se especializa en proporcionar créditos personales y empresariales de manera ágil, transparente y accesible.

**Misión**: Brindar soluciones financieras innovadoras que empoderen a individuos y empresas mexicanas a alcanzar sus metas, utilizando tecnología de punta para evaluar riesgos de manera justa y prevenir fraudes.

---

## ✨ Características Principales

### 🎨 Datos Sintéticos Realistas

- **1,000 clientes** con perfiles demográficos completos (nombres, CURP, RFC, domicilios mexicanos)
- **5 productos crediticios** (Personal Express, PyME, Nómina Plus, Auto Fácil, Línea Flexible)
- **2,000 solicitudes** con tasas de aprobación y rechazo realistas
- **1,200 créditos activos** con diferentes estatus (Vigente, Mora, Vencido, Liquidado)
- **10,000 transacciones** incluyendo desembolsos, pagos y cargos
- **200 alertas de fraude** con clasificación por tipo y nivel de riesgo
- **1,500 eventos de cumplimiento** (KYC, PLD, validaciones)

### 📊 Análisis Avanzado

- Matriz de riesgo por segmento de cliente
- Cálculo de IMOR (Índice de Morosidad)
- Score de riesgo interno (0-100)
- Análisis de rentabilidad (LTV/CAC ratio)
- Concentración geográfica de cartera
- Pruebas de estrés de cartera

### 🔍 Detección de Fraude

- Patrones de transacciones sospechosas
- Cambios de ubicación geográfica
- Dispositivos no reconocidos
- Montos inusuales
- Múltiples intentos fallidos

### 📁 Datos No Estructurados

- **JSON**: Logs de transacciones, perfiles detallados de clientes
- **XML**: Reportes regulatorios CNBV, análisis de riesgo de cartera
- **TXT**: Templates de contratos de crédito

---

## 📂 Estructura del Proyecto

```
AgilCredit_Demo/
│
├── README.md                                    # Este archivo
├── AgilCredit_Demo_Worksheet.sql              # Worksheet principal con toda la lógica
├── AgilCredit_Parse_Unstructured_Data.sql     # Script para procesar JSON/XML
├── AgilCredit_Process_PDF_Documents.sql       # Script para procesar PDF/TXT con Cortex
├── CREAR_FILE_FORMATS.sql                     # Script para crear FILE FORMATs (prerequisito)
├── agilcredit_modelo_semantico.yaml           # Modelo semántico con 3 verified queries
├── agilcredit_dashboard.py                     # Dashboard Streamlit interactivo (principal)
├── agilcredit_intelligence_costs_dashboard.py # Dashboard de costos Intelligence
├── run_dashboard.sh                            # Script de inicio rápido
├── requirements_dashboard.txt                  # Dependencias para dashboards
├── DASHBOARD_INTELLIGENCE_COSTS_README.md     # Documentación del dashboard de costos
├── GUIA_DATOS_NO_ESTRUCTURADOS.md             # Tutorial completo JSON/XML
├── CURSOR_USER_RULES_SNOWFLAKE.md             # Reglas para AI Cursor
├── LECCIONES_APRENDIDAS_SNOWFLAKE.md          # Best practices
│
├── CATALOGO_ARCHIVOS_NO_ESTRUCTURADOS.md      # Catálogo completo de 20 archivos
│
└── datos_no_estructurados/                     # 20 archivos no estructurados (~108 KB)
    ├── json/                                   # 9 archivos JSON (~47 KB)
    │   ├── perfiles_clientes_detallados.json  # Analytics: Perfiles completos
    │   ├── transacciones_logs.json            # Logs: Transacciones detalladas
    │   ├── logs_aplicacion_movil.json         # Logs: Eventos app móvil
    │   ├── eventos_scoring_ml.json            # ML: Scoring y modelos
    │   ├── historial_cambios_creditos.json    # Ops: Cambios en créditos
    │   ├── datos_cobranza_gestion.json        # Ops: Gestión de cobranza
    │   ├── configuracion_productos_reglas.json # Config: Reglas de negocio
    │   ├── eventos_seguridad_accesos.json     # Security: Eventos de acceso
    │   └── metricas_performance_sistema.json  # DevOps: Métricas de sistemas
    │
    ├── xml/                                    # 11 archivos XML (~61 KB)
    │   ├── reporte_riesgo_cartera.xml         # Riesgo: Análisis de cartera
    │   ├── reporte_cnbv_operaciones_inusuales.xml # Compliance: CNBV
    │   ├── reporte_morosidad_mensual.xml      # Cobranza: Morosidad mensual
    │   ├── reporte_solvencia_capital.xml      # Finanzas: ICAP y Basilea
    │   ├── reporte_quejas_condusef.xml        # Compliance: CONDUSEF
    │   ├── catalogo_productos_cnbv.xml        # Catálogos: Productos
    │   ├── balance_general_q3.xml             # Finanzas: Balance general
    │   ├── estado_resultados_q3.xml           # Finanzas: Estado de resultados
    │   ├── reporte_auditoria_interna.xml      # Auditoría: Hallazgos
    │   ├── reporte_operaciones_relevantes.xml # PLD: Operaciones relevantes
    │   └── reporte_provision_reservas.xml     # Riesgo: Provisiones
    │
    └── pdfs/
        └── contrato_credito_template.txt      # Template de contrato
```

---

## 📊 Datos Generados

### Volumen de Datos

| Entidad | Cantidad | Descripción |
|---------|----------|-------------|
| **Clientes** | 1,000 | Perfiles completos con datos demográficos y financieros |
| **Productos** | 5 | Catálogo de productos crediticios |
| **Solicitudes** | 2,000 | Solicitudes con aprobadas, rechazadas y pendientes |
| **Créditos** | 1,200 | Créditos activos y liquidados |
| **Transacciones** | 10,000 | Pagos, desembolsos, cargos |
| **Alertas de Fraude** | 200 | Alertas clasificadas por nivel de riesgo |
| **Eventos Cumplimiento** | 1,500 | Verificaciones KYC/PLD |

### Distribución Geográfica

Clientes distribuidos en las principales ciudades de México:
- Ciudad de México
- Guadalajara (Jalisco)
- Monterrey (Nuevo León)
- Puebla
- Tijuana (Baja California)
- León (Guanajuato)
- Querétaro
- Mérida (Yucatán)
- Y más...

---

## 🚀 Instrucciones de Instalación

### Pre-requisitos

- Acceso a una cuenta de Snowflake
- Rol con permisos para crear databases, schemas, warehouses
- (Opcional) Acceso a Streamlit in Snowflake para el dashboard

### Paso 1: Configurar el Entorno

1. **Abrir Snowflake**
   - Inicia sesión en tu cuenta de Snowflake
   - Ve a "Worksheets"

2. **Cargar el Worksheet**
   - Abre el archivo `AgilCredit_Demo_Worksheet.sql`
   - Copia todo el contenido
   - Pégalo en un nuevo worksheet en Snowflake

### Paso 2: Ejecutar el Worksheet

El worksheet está organizado en secciones claramente marcadas:

#### Sección 0: Historia y Caso de Uso
- Lectura recomendada para entender el contexto

#### Sección 1: Configuración de Recursos
```sql
-- Crea automáticamente:
-- - Warehouse: AGILCREDIT_WH
-- - Database: AGILCREDIT_DB
-- - Schemas: CORE, ANALYTICS, COMPLIANCE, UNSTRUCTURED
-- - Stages para archivos no estructurados
```

**⏱️ Tiempo estimado**: 1 minuto

#### Sección 2: Generación de Datos Sintéticos
```sql
-- Crea y pobla todas las tablas con datos sintéticos
-- Incluye: Clientes, Productos, Solicitudes, Créditos,
-- Transacciones, Alertas, Eventos de Cumplimiento, Rentabilidad
```

**⏱️ Tiempo estimado**: 3-5 minutos

#### Sección 3: La Demo
```sql
-- Consultas analíticas y vistas pre-construidas:
-- - Análisis de Riesgo
-- - Detección de Fraude
-- - Rentabilidad
-- - Cumplimiento
-- - Dashboard Ejecutivo
-- - FinOps (Costos)
```

**⏱️ Tiempo estimado**: Consultas instantáneas

### Paso 3: Cargar Datos No Estructurados (Opcional)

Para demostrar capacidades con datos no estructurados:

```sql
-- Desde Snowflake UI o SnowSQL:
PUT file://datos_no_estructurados/json/*.json @AGILCREDIT_DB.UNSTRUCTURED.LOGS_STAGE;
PUT file://datos_no_estructurados/xml/*.xml @AGILCREDIT_DB.UNSTRUCTURED.REGULATORY_STAGE;
PUT file://datos_no_estructurados/pdfs/*.txt @AGILCREDIT_DB.UNSTRUCTURED.DOCUMENTS_STAGE;
```

### Paso 4: Cargar Modelo Semántico (Opcional)

Si tu cuenta tiene acceso a Semantic Models:

1. Ve a "Data" → "Semantic Models" en Snowflake
2. Crea un nuevo modelo
3. Carga el archivo `agilcredit_modelo_semantico.yaml`
4. Valida y publica el modelo

### Paso 5: Deploy Dashboard Streamlit (Opcional)

Si tienes acceso a Streamlit in Snowflake:

1. Ve a "Streamlit" → "Create App"
2. Nombra la app: "AgilCredit Dashboard"
3. Copia el contenido de `agilcredit_dashboard.py`
4. Selecciona el warehouse: `AGILCREDIT_WH`
5. Deploy

---

## 🎯 Casos de Uso

### 1. 📈 Análisis de Riesgo Crediticio

**Objetivo**: Evaluar la calidad de la cartera y identificar clientes de alto riesgo

**Consultas clave**:
```sql
-- Ver matriz de riesgo por segmento
SELECT * FROM AGILCREDIT_DB.ANALYTICS.V_MATRIZ_RIESGO;

-- Top 20 clientes de mayor riesgo
SELECT * FROM AGILCREDIT_DB.CORE.CLIENTES c
JOIN AGILCREDIT_DB.CORE.CREDITOS cr ON c.CLIENTE_ID = cr.CLIENTE_ID
WHERE cr.ESTATUS_CREDITO IN ('MORA', 'VENCIDO')
ORDER BY cr.DIAS_MORA DESC, cr.SALDO_ACTUAL DESC
LIMIT 20;
```

**KPIs**:
- IMOR (Índice de Morosidad)
- Cartera Vencida
- Score de Riesgo Promedio por Segmento
- Días Mora Promedio

### 2. 🔍 Detección de Fraude

**Objetivo**: Identificar y prevenir transacciones fraudulentas

**Consultas clave**:
```sql
-- Dashboard de fraude
SELECT * FROM AGILCREDIT_DB.ANALYTICS.V_DASHBOARD_FRAUDE
WHERE FECHA >= CURRENT_DATE() - 30;

-- Alertas activas de alto riesgo
SELECT * FROM AGILCREDIT_DB.CORE.ALERTAS_FRAUDE
WHERE ESTATUS_ALERTA IN ('NUEVA', 'EN_REVISION')
  AND NIVEL_RIESGO = 'ALTO'
ORDER BY SCORE_FRAUDE DESC;
```

**Patrones detectados**:
- Transacciones desde ubicaciones geográficas sospechosas
- Dispositivos no reconocidos
- Montos inusuales
- Múltiples intentos fallidos
- Cambios frecuentes de IP

### 3. 💰 Rentabilidad de Clientes

**Objetivo**: Identificar clientes más rentables y optimizar estrategias de adquisición

**Consultas clave**:
```sql
-- Rentabilidad por segmento
SELECT * FROM AGILCREDIT_DB.ANALYTICS.V_RENTABILIDAD_SEGMENTOS;

-- Top 50 clientes más rentables
SELECT 
    c.CLIENTE_ID,
    c.NOMBRE_COMPLETO,
    r.UTILIDAD_NETA,
    r.LTV_ESTIMADO,
    r.CAC,
    r.RATIO_LTV_CAC
FROM AGILCREDIT_DB.ANALYTICS.RENTABILIDAD_CLIENTES r
JOIN AGILCREDIT_DB.CORE.CLIENTES c ON r.CLIENTE_ID = c.CLIENTE_ID
ORDER BY r.UTILIDAD_NETA DESC
LIMIT 50;
```

**Métricas**:
- LTV (Lifetime Value)
- CAC (Customer Acquisition Cost)
- Ratio LTV/CAC (ideal > 3.0)
- Margen de Rentabilidad
- Utilidad Neta por Cliente

### 4. ✅ Cumplimiento Regulatorio

**Objetivo**: Asegurar cumplimiento con regulaciones KYC y PLD

**Consultas clave**:
```sql
-- Status de cumplimiento
SELECT * FROM AGILCREDIT_DB.COMPLIANCE.V_STATUS_CUMPLIMIENTO;

-- Clientes que requieren actualización KYC
SELECT * FROM AGILCREDIT_DB.COMPLIANCE.V_STATUS_CUMPLIMIENTO
WHERE STATUS_CUMPLIMIENTO IN ('REQUIERE_ACTUALIZACION', 'PENDIENTE', 'INCOMPLETO')
  AND CREDITOS_ACTIVOS > 0
ORDER BY EXPOSICION_TOTAL DESC;
```

**Verificaciones**:
- KYC inicial completo
- Actualización anual de documentos
- Validación en listas (OFAC, PEP, CNBV)
- Verificación biométrica
- Validación de documentos (INE, comprobantes)

### 5. 📊 Dashboard Ejecutivo

**Objetivo**: Vista consolidada de todos los KPIs principales

**Consulta**:
```sql
SELECT * FROM AGILCREDIT_DB.ANALYTICS.V_KPIS_EJECUTIVOS;
```

**KPIs incluidos**:
- Total Clientes y % Activos
- Cartera Total
- Índice de Morosidad (IMOR)
- Volumen de Transacciones
- Alertas de Fraude
- Utilidad Neta Total
- Ratio LTV/CAC

---

## 📄 Procesamiento de Datos No Estructurados

AgilCredit incluye **20 archivos** de ejemplo (11 XML + 9 JSON) con casos de uso reales de procesamiento de datos no estructurados en Snowflake.

### 📊 Catálogo Completo de Archivos

📘 **[Ver Catálogo Completo](CATALOGO_ARCHIVOS_NO_ESTRUCTURADOS.md)** - Documentación detallada de los 20 archivos

### 📂 Resumen por Categoría

#### 📋 JSON Files (9 archivos - ~47 KB)
- **Analytics & ML**: Perfiles detallados, scoring ML, eventos de modelos
- **Logs Operativos**: App móvil, transacciones, métricas de performance
- **Operaciones**: Gestión de cobranza, cambios en créditos, configuración de productos
- **Seguridad**: Eventos de acceso sospechoso y auditoría de sistemas

#### 📄 XML Files (11 archivos - ~61 KB)
- **Compliance/Regulatorio**: CNBV operaciones inusuales, quejas CONDUSEF, PLD
- **Financieros**: Balance general, estado de resultados
- **Riesgo & Cobranza**: Morosidad mensual, solvencia, provisiones
- **Auditoría**: Reportes de auditoría interna, operaciones relevantes
- **Catálogos**: Productos registrados ante CNBV con CAT y requisitos

### 🚀 Cómo Usarlo

#### Scripts SQL Disponibles

**1. `AgilCredit_Parse_Unstructured_Data.sql`** - Procesamiento JSON/XML
El archivo incluye:

1. **Configuración de Stage** para almacenar archivos
2. **Instrucciones de carga** (SnowSQL, Snowsight UI, Python)
3. **Procesamiento de JSON** con `PARSE_JSON()`
   - Extracción de campos anidados
   - Manejo de arrays con `FLATTEN()`
   - Creación de vistas estructuradas
4. **Procesamiento de XML** con `PARSE_XML()` y `XMLGET()`
   - Navegación de jerarquías XML
   - Extracción de atributos y elementos
5. **Integración con tablas estructuradas**
   - Enriquecimiento de perfiles de clientes
   - Validación de reportes XML vs datos transaccionales
6. **Queries de análisis avanzado**
   - Detección de fraude con logs JSON
   - Segmentación con datos enriquecidos
   - Auditoría regulatoria con XML

**2. `AgilCredit_Process_PDF_Documents.sql`** - Procesamiento de Documentos PDF/TXT
El archivo incluye:

1. **Creación de tabla `RAW_DOCUMENTS`** para almacenar documentos completos
2. **Carga de 11 documentos PDF/TXT** con metadata estructurada
3. **Análisis con Snowflake Cortex:**
   - 📝 Resumen automático de documentos largos
   - 🔍 Extracción de información clave (montos, fechas, nombres)
   - 😊 Análisis de sentimiento en comunicaciones
   - 🏷️ Clasificación automática por categoría
   - ❓ Búsqueda semántica y Q&A sobre documentos
4. **Vistas analíticas:**
   - Resúmenes de documentos
   - Análisis de sentimiento por cliente
   - Búsqueda por tags
   - Timeline de comunicaciones
5. **Integración con datos estructurados**
   - Clientes con sus documentos y nivel de satisfacción
   - Correlación entre documentos y comportamiento de pago

#### Guía Detallada
Ver **`GUIA_DATOS_NO_ESTRUCTURADOS.md`** para:
- Tutorial paso a paso
- Ejemplos de código comentados
- Funciones clave de Snowflake
- Best practices y troubleshooting
- Casos de uso avanzados

### 🎯 Casos de Uso

**1. Enriquecimiento de Perfiles**
```sql
-- Combinar datos estructurados con JSON detallado
SELECT 
    c.CLIENTE_ID,
    c.NOMBRE_COMPLETO,
    j.CAPACIDAD_PAGO,
    j.NIVEL_ENGAGEMENT,
    j.PROB_CHURN
FROM CORE.CLIENTES c
LEFT JOIN V_PERFILES_JSON j ON c.CLIENTE_ID = j.CLIENTE_ID
WHERE j.CAPACIDAD_PAGO > 10000;
```

**2. Análisis de Fraude**
```sql
-- Transacciones sospechosas desde logs JSON
SELECT 
    TRANSACTION_ID,
    CLIENTE_ID,
    MONTO,
    FRAUD_SCORE,
    FRAUD_FLAGS
FROM V_TRANSACCIONES_LOGS_JSON
WHERE FRAUD_SCORE > 70;
```

**3. Validación Regulatoria**
```sql
-- Comparar reporte XML vs datos en vivo
SELECT 
    'XML Reporte' as FUENTE,
    CARTERA_TOTAL,
    IMOR
FROM V_REPORTE_RIESGO_XML

UNION ALL

SELECT 
    'Datos Vivo',
    SUM(SALDO_ACTUAL),
    AVG(DIAS_MORA)
FROM CREDITOS;
```

### 📊 Vistas Creadas

| Vista | Descripción | Registros |
|-------|-------------|-----------|
| `V_PERFILES_CLIENTES_JSON` | Perfiles detallados desde JSON | 10 |
| `V_TRANSACCIONES_LOGS_JSON` | Logs de transacciones parseados | 100 |
| `V_REPORTE_RIESGO_XML` | Indicadores de riesgo desde XML | 1 reporte |
| `V_REPORTE_CNBV_XML` | Compliance regulatorio desde XML | 1 reporte |
| `V_CLIENTES_ENRIQUECIDOS` | Integración estructurado + JSON | 1,000 |

### 🔧 Funciones de Snowflake Utilizadas

- `PARSE_JSON()` - Convertir texto JSON a VARIANT
- `PARSE_XML()` - Convertir texto XML a VARIANT
- `XMLGET()` - Extraer elementos XML por ruta
- `GET()` - Extraer valores de VARIANT
- `FLATTEN()` - Expandir arrays/objetos a filas
- Notación de punto (`:`) para navegación JSON
- Casting explícito (`::STRING`, `::FLOAT`, etc.)

---

## 🧠 Modelo Semántico con Snowflake Intelligence

El modelo semántico (`agilcredit_modelo_semantico.yaml`) proporciona una capa de abstracción sobre los datos para facilitar consultas en lenguaje natural con **Snowflake Intelligence (Cortex Analyst)**.

### 🎯 Características Avanzadas

#### 1. **Description (Descripción Detallada)**
- Contexto completo de AgilCredit como fintech mexicana
- 4 pilares de análisis: Riesgo, Fraude, Rentabilidad, Cumplimiento
- Definición de métricas clave (IMOR, LTV/CAC, Score de Riesgo)
- Catálogo de productos crediticios con rangos
- Geografía de operación y volúmenes

#### 2. **Orchestration Instructions (Instrucciones de Orquestación)**
Guías para que el agente de IA genere mejores consultas:
- **Priorización**: Qué tablas usar según el tipo de pregunta
- **Cálculos**: Fórmulas exactas para métricas clave (IMOR, Ratios)
- **Filtros**: Mejores prácticas de segmentación
- **Agregaciones**: Patrones comunes (SUM, AVG, COUNT)
- **Análisis temporal**: Uso de DATE_TRUNC y DATEADD
- **Alertas y umbrales**: Valores que requieren atención
- **Joins**: Relaciones entre tablas y cuándo usarlas

Ejemplo:
```yaml
IMOR (Índice de Morosidad) = (Cartera Vencida / Cartera Total) * 100
donde Cartera Vencida = SUM(saldo_actual) WHERE estatus IN ('MORA', 'VENCIDO')
```

#### 3. **Response Instructions (Instrucciones de Respuesta)**
Formato para respuestas del agente:
- **Estructura**: Resumen ejecutivo + métricas + contexto + recomendaciones
- **Formateo**: "$123.4M MXN", "45.67%", "3.5x"
- **Interpretación**: Rangos para IMOR, LTV/CAC, Scores
- **Benchmarks**: Comparación con objetivos
- **Recomendaciones**: Específicas y accionables
- **Alertas**: Uso de emojis (⚠️, 🚨, ✅, 📈, 📉)
- **Ejemplos**: Respuestas tipo para preguntas comunes

Ejemplo de respuesta estructurada:
```
Pregunta: "¿Cuál es la morosidad actual?"
Respuesta: "La cartera de AgilCredit presenta un IMOR del 4.35%, 
dentro del rango objetivo (< 5%). Esto representa $6.47M MXN 
en cartera vencida sobre una cartera total de $148.75M MXN. 
El segmento Premium tiene la mejor tasa (2.1%), mientras que 
Bronce muestra 7.8% (⚠️ requiere atención)."
```

#### 4. **Custom Instructions (Instrucciones Personalizadas)**
- **Glosario completo** de términos financieros mexicanos
- **Regulación**: CNBV, CONDUSEF, SOFOM, KYC, PLD
- **Estados de crédito**: Vigente, Mora, Vencido, Liquidado
- **Segmentos**: Premium, Oro, Plata, Bronce
- **Consideraciones**: Reglas de negocio específicas

### Tablas Principales

1. **clientes**: Información demográfica y de perfil
2. **productos**: Catálogo de productos crediticios
3. **creditos**: Créditos activos y su información
4. **transacciones**: Registro de todas las transacciones
5. **alertas_fraude**: Alertas del sistema de fraude
6. **rentabilidad_clientes**: Métricas de LTV, CAC, utilidad
7. **eventos_cumplimiento**: Eventos KYC/PLD

### Verified Queries (7 incluidas)

1. **Cartera Total y Morosidad**: ¿Cuál es el total de la cartera y la tasa de morosidad?
2. **Top Clientes Rentables**: ¿Quiénes son los clientes más rentables?
3. **Alertas de Fraude Activas**: ¿Cuántas alertas hay y su distribución?
4. **Desempeño de Productos**: Volumen y morosidad por producto
5. **Cumplimiento KYC Pendientes**: Clientes con KYC pendiente
6. **Tendencia de Originación**: Créditos otorgados en últimos 12 meses
7. **Concentración Geográfica**: Distribución y riesgo por estado

### 💡 Uso con Snowflake Intelligence

El modelo está optimizado para **Cortex Analyst** y permite hacer preguntas en lenguaje natural:

**Preguntas de ejemplo**:
- "¿Cuál es el IMOR actual y cómo se compara con el objetivo?"
- "Muéstrame los 10 clientes con mayor riesgo de incumplimiento"
- "¿Qué producto tiene la mejor rentabilidad?"
- "¿Cuántas alertas de fraude de nivel alto tenemos sin resolver?"
- "¿Qué porcentaje de clientes necesita actualización de KYC?"
- "¿Cuál es el ratio LTV/CAC por segmento de cliente?"
- "Dame la distribución geográfica de la cartera"

**El agente proporcionará**:
- ✅ Consulta SQL generada automáticamente
- 📊 Resultados formateados correctamente
- 💡 Interpretación con contexto de negocio
- ⚠️ Alertas si hay métricas fuera de rango
- 🎯 Recomendaciones accionables

---

## 📱 Dashboard Interactivo

El dashboard Streamlit (`agilcredit_dashboard.py`) proporciona visualizaciones interactivas.

### Vistas Disponibles

1. **📈 Dashboard Ejecutivo**
   - KPIs principales
   - Evolución de originación
   - Segmentación de clientes
   - Métricas consolidadas

2. **⚠️ Análisis de Riesgo**
   - Matriz de riesgo por segmento
   - Exposición vs Morosidad
   - Top clientes de mayor riesgo
   - Distribución de cartera por calificación

3. **🔍 Detección de Fraude**
   - Alertas activas y confirmadas
   - Distribución por tipo y nivel de riesgo
   - Score de fraude promedio
   - Patrones detectados

4. **💰 Rentabilidad**
   - Utilidad por segmento
   - Análisis LTV/CAC
   - Top clientes rentables
   - Ingresos y márgenes

5. **✅ Cumplimiento Regulatorio**
   - Status KYC/PLD por segmento
   - Clientes pendientes de actualización
   - Eventos de cumplimiento
   - Porcentaje de cumplimiento

6. **📍 Análisis Geográfico**
   - Concentración por estado y ciudad
   - Exposición vs Morosidad geográfica
   - Top 20 ubicaciones
   - TreeMap de distribución

### Características del Dashboard

- ✅ Compatible con Streamlit in Snowflake
- 📊 Gráficas interactivas con Plotly
- 🎨 Diseño moderno y responsive
- ⚡ Consultas optimizadas
- 🔄 Actualización en tiempo real

---

## 💰 Dashboard de Costos Intelligence

El dashboard de costos (`agilcredit_intelligence_costs_dashboard.py`) monitorea en tiempo real el consumo de Snowflake Intelligence Services.

### 📊 Servicios Monitoreados

1. **🤖 Cortex Analyst**
   - Requests procesados
   - Créditos por query
   - Análisis por usuario
   - Tendencia temporal

2. **🔍 Cortex Search**
   - Costos de indexación
   - Costos de búsqueda
   - Análisis por servicio
   - Proyecciones

3. **🏢 Warehouse**
   - Compute vs Cloud Services
   - Consumo diario
   - Identificación de picos
   - Optimización

4. **💸 Vista Consolidada**
   - Rollup de todos los servicios
   - Proyecciones mensuales/anuales
   - Exportación a CSV
   - Reportes ejecutivos

### 🚀 Inicio Rápido

```bash
# 1. Instalar dependencias
pip install -r requirements_dashboard.txt

# 2. Ejecutar dashboard
./run_dashboard.sh

# O manualmente:
streamlit run agilcredit_intelligence_costs_dashboard.py
```

### ⚙️ Configuración

**Parámetros Configurables:**
- 📅 Días de histórico (7-90 días)
- 💵 Costo por crédito (default: $2 USD)
- 👤 Filtro por usuario
- 🏢 Filtro por warehouse

**Credenciales:**
- Account, User, Password
- Role (ACCOUNTADMIN requerido)
- Warehouse name

### 📈 Características Clave

- ✅ **Configuración Persistente**: Guarda credenciales (excepto password)
- ✅ **Cache Inteligente**: Actualización cada 5 minutos
- ✅ **Visualizaciones Interactivas**: Gráficos con Plotly
- ✅ **Exportación**: Descarga datos en CSV
- ✅ **Proyecciones**: Estimaciones mensuales y anuales
- ✅ **Multi-Componente**: Vista consolidada de todos los servicios

### 📚 Documentación

Ver **[DASHBOARD_INTELLIGENCE_COSTS_README.md](DASHBOARD_INTELLIGENCE_COSTS_README.md)** para:
- Guía de instalación detallada
- Descripción de cada pestaña
- Troubleshooting
- Casos de uso
- Personalización

---

## 💰 Gestión de Costos (FinOps)

### Warehouse Sizing

El warehouse `AGILCREDIT_WH` está configurado como **XSMALL** para demo:

```sql
CREATE OR REPLACE WAREHOUSE AGILCREDIT_WH
    WAREHOUSE_SIZE = 'XSMALL'        -- Costo mínimo
    AUTO_SUSPEND = 60                 -- Suspender tras 1 min inactivo
    AUTO_RESUME = TRUE                -- Reanudar automáticamente
    INITIALLY_SUSPENDED = TRUE;       -- Iniciar suspendido
```

### Monitoreo de Costos

Vista de monitoreo incluida en el worksheet:

```sql
-- Consultar uso de créditos
SELECT * FROM AGILCREDIT_DB.ANALYTICS.V_COSTOS_WAREHOUSE;

-- Resumen de costos por día
SELECT 
    DATE_TRUNC('day', START_TIME) as FECHA,
    SUM(CREDITS_USED) as CREDITOS_USADOS,
    SUM(CREDITS_USED) * 2.5 as COSTO_USD_ESTIMADO
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE WAREHOUSE_NAME = 'AGILCREDIT_WH'
GROUP BY FECHA
ORDER BY FECHA DESC;
```

### Estimación de Costos

Para esta demo (10K transacciones):

| Componente | Créditos Estimados | Costo USD* |
|------------|-------------------|-----------|
| Setup inicial | 0.1 | $0.25 |
| Carga de datos | 0.3 | $0.75 |
| Consultas demo (50 queries) | 0.5 | $1.25 |
| Dashboard Streamlit (1 hora) | 0.2 | $0.50 |
| **TOTAL ESTIMADO** | **~1.1** | **~$2.75** |

*Asumiendo $2.50 USD por crédito (varía por región y plan)

### Recomendaciones de Optimización

1. **Suspender Warehouse** cuando no se use
2. **Usar XSMALL** para demos y desarrollo
3. **Clustering Keys** en tablas grandes de producción
4. **Materializar vistas** frecuentemente consultadas
5. **Result Cache** para consultas repetitivas

---

## 📚 Recursos Adicionales

### 🎓 Lecciones Aprendidas y Mejores Prácticas

**📄 [LECCIONES_APRENDIDAS_SNOWFLAKE.md](./LECCIONES_APRENDIDAS_SNOWFLAKE.md)**

Este documento contiene todos los aprendizajes de errores comunes encontrados durante el desarrollo de esta demo:

- ✅ **Generación de secuencias correcta** (`ROW_NUMBER()` vs `SEQ4()`)
- ✅ **Operador módulo** (`MOD()` vs `%`)
- ✅ **Números aleatorios** (`UNIFORM()` vs `RANDOM()`)
- ✅ **Manejo de múltiples schemas** (prefijos explícitos)
- ✅ **Diferencias PostgreSQL vs Snowflake** (sintaxis incompatibles)
- ✅ **Coherencia de datos sintéticos** (rangos y lógica de negocio)
- ✅ **Estrategia de debugging** (proceso paso a paso)
- ✅ **Checklist pre-ejecución** (verificación antes de ejecutar)

> 💡 **Recomendación:** Revisa este documento antes de crear tus propias demos para evitar errores comunes.

---

### Documentación de Referencia

- [Snowflake Documentation](https://docs.snowflake.com/)
- [Streamlit Documentation](https://docs.streamlit.io/)
- [Circular Única de Bancos - CNBV](https://www.cnbv.gob.mx/)
- [CONDUSEF - Comisión Nacional](https://www.condusef.gob.mx/)

### Conceptos Financieros

- **IMOR**: Índice de Morosidad = Cartera Vencida / Cartera Total
- **CAT**: Costo Anual Total (incluye intereses, comisiones, seguros)
- **LTV**: Lifetime Value (valor del cliente durante su vida útil)
- **CAC**: Customer Acquisition Cost
- **KYC**: Know Your Customer (conoce a tu cliente)
- **PLD**: Prevención de Lavado de Dinero
- **SOFOM**: Sociedad Financiera de Objeto Múltiple

### Regulaciones Mexicanas

- **CNBV**: Comisión Nacional Bancaria y de Valores
- **CONDUSEF**: Comisión Nacional para la Protección y Defensa de los Usuarios de Servicios Financieros
- **Banxico**: Banco de México
- **Ley Fintech**: Ley para Regular las Instituciones de Tecnología Financiera

---

## 👨‍💻 Casos de Uso Avanzados

### Machine Learning

El modelo incluye datos preparados para entrenar modelos de:

1. **Credit Scoring**
   - Predicción de probabilidad de incumplimiento
   - Features: historial crediticio, ingresos, score de buró

2. **Fraud Detection**
   - Clasificación de transacciones sospechosas
   - Features: patrones de comportamiento, ubicación, dispositivo

3. **Customer Churn**
   - Predicción de abandono de clientes
   - Features: actividad, rentabilidad, satisfacción

4. **LTV Prediction**
   - Estimación de valor del cliente
   - Features: comportamiento de pago, productos contratados

### Integración con Otras Herramientas

El modelo es compatible con:

- **Tableau**: Para visualizaciones avanzadas
- **Power BI**: Dashboards corporativos
- **Python**: Análisis con Snowpark
- **dbt**: Transformaciones y modelado de datos
- **Fivetran/Airbyte**: Ingesta de datos externos

---

## 🎓 Aprendizajes Clave

### Para Ingenieros de Datos

1. **Modelado de datos** para servicios financieros
2. **Generación de datos sintéticos** realistas
3. **Optimización de queries** complejas
4. **Gestión de costos** en Snowflake

### Para Analistas de Datos

1. **KPIs financieros** clave
2. **Análisis de riesgo** y morosidad
3. **Segmentación** de clientes
4. **Rentabilidad** y LTV/CAC

### Para Data Scientists

1. **Features** para modelos de ML
2. **Detección de anomalías** en transacciones
3. **Scoring de riesgo** interno
4. **Patrones de fraude**

---

## 🤝 Contribuciones

Este proyecto es una demo educativa. Si deseas mejorarlo:

1. Agrega más casos de uso específicos
2. Mejora el dashboard Streamlit
3. Crea notebooks con análisis ML
4. Expande el modelo semántico
5. Agrega más datos no estructurados

---

## 📄 Licencia

Este proyecto es una demostración educativa creada para fines de aprendizaje y demostración de capacidades de Snowflake en el sector financiero mexicano.

---

## 📞 Contacto y Soporte

Para preguntas sobre esta demo:

- **Repositorio**: [GitHub - Financial Services Demo](https://github.com/tu-usuario/financial-services-demo)
- **Issues**: Reporta bugs o solicita features
- **Snowflake Community**: [community.snowflake.com](https://community.snowflake.com/)

---

## 🎉 ¡Gracias por usar AgilCredit Demo!

Esperamos que esta demo te ayude a entender cómo Snowflake puede transformar el análisis de datos en servicios financieros. 

**Próximos pasos sugeridos:**

1. ✅ Ejecuta el worksheet completo
2. ✅ Explora las vistas analíticas
3. ✅ Carga el modelo semántico
4. ✅ Deploy el dashboard Streamlit
5. ✅ Experimenta con tus propias consultas
6. ✅ Adapta el modelo a tu caso de uso real

---

<div align="center">

**Made with ❤️ for the Snowflake Community**

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Streamlit](https://img.shields.io/badge/Streamlit-FF4B4B?style=for-the-badge&logo=streamlit&logoColor=white)

</div>

