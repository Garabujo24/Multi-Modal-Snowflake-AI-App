# 🏔️ Snowflake Labs by Garabujo24

Repositorio centralizado de proyectos, demos y casos de uso desarrollados con Snowflake Data Cloud.

## 📂 Estructura del Repositorio

Todo el contenido de labs, demos y quickstarts está organizado bajo la carpeta `snowflake-labs/`:

```
snowflake-labs/
├── Anomaly Detection/           # Demo de detección de anomalías con datos retail
├── Financial Services Demo/     # Casos de uso para servicios financieros
├── Insurance/                   # Demo para sector seguros (Centinela)
├── Unstructured Documents/      # Procesamiento de documentos no estructurados
├── Demo Cursor/                 # Demos varios con Cursor
├── Farma_Pronto/               # Caso de uso farmacéutico
├── Inmobiliarios/              # Demo sector inmobiliario (Urbanova)
├── multi-modal-snowflake-ai-app/  # Generador de apps multimodales con IA
├── telco_customer_360/         # Customer 360 para telecomunicaciones
├── ado-cortex-demo/            # Demo ADO con Cortex
├── documentos-monex-cortex/    # Búsqueda semántica con Cortex Search
├── retail-shoes-classify-demo/ # Clasificación de productos retail
├── snowflake-mcp-openai/       # Integración OpenAI MCP
└── ... (25 proyectos en total)
```

## 🚀 Proyectos Destacados

### 🔍 Anomaly Detection
Sistema completo de detección de anomalías en ventas retail usando Z-Score y variables exógenas (clima, eventos, promociones).

**Stack:** Snowflake SQL, Python, Window Functions  
**Ubicación:** `snowflake-labs/Anomaly Detection/`

### 💰 Financial Services
Demos y casos de uso para instituciones financieras con datos sintéticos de créditos, hipotecas, inversiones y riesgo.

**Stack:** Snowflake SQL, Cortex, Semantic Models  
**Ubicación:** `snowflake-labs/Financial Services Demo/`

### 🏥 Insurance (Centinela)
Plataforma de seguros con pólizas GMM y Auto, procesamiento de documentos PDF y modelos semánticos.

**Stack:** Snowflake SQL, Python, Cortex AI, Document AI  
**Ubicación:** `snowflake-labs/Insurance/`

### 📄 Unstructured Documents
Procesamiento avanzado de documentos no estructurados (PDFs, audios, imágenes) con Cortex AI.

**Stack:** Snowflake, Document AI, Audio Processing, OCR  
**Ubicación:** `snowflake-labs/Unstructured Documents/`

### 🤖 Multi-Modal AI App Generator
Generador automatizado de aplicaciones Snowflake completas con Streamlit, Cortex Search y Semantic Models.

**Stack:** Python, OpenAI API, Snowflake Python Connector  
**Ubicación:** `snowflake-labs/multi-modal-snowflake-ai-app/`

## 🛠️ Tecnologías Principales

- **Snowflake SQL** - Queries, procedimientos, UDFs
- **Snowpark Python** - Desarrollo serverless en Snowflake
- **Cortex AI** - LLMs, Semantic Models, Document AI
- **Streamlit in Snowflake** - Apps interactivas nativas
- **Snowflake ML** - Machine Learning y Feature Engineering
- **Cortex Search** - Búsqueda semántica RAG

## 📖 Uso de los Proyectos

Cada proyecto incluye su propio README con:
- Descripción del caso de uso
- Instrucciones de setup
- Scripts SQL de configuración
- Dependencias (requirements.txt)
- Guías de ejecución paso a paso

## 🔧 Setup General

1. **Clonar el repositorio**
```bash
git clone git@github.com:Garabujo24/snowflake-labs.git
cd snowflake-labs
```

2. **Navegar al proyecto deseado**
```bash
cd snowflake-labs/[NOMBRE_PROYECTO]
```

3. **Seguir las instrucciones específicas** del README del proyecto

## 📝 Nomenclatura y Estándares

Todos los proyectos siguen las siguientes convenciones:

- **SQL:** 
  - Prefijos por cliente/proyecto (ej: `MEGAMART_`, `CENTINELA_`)
  - CREATE OR REPLACE para idempotencia
  - Comentarios en español
  - Sección de FinOps incluida

- **Python:**
  - PEP 8 compliant
  - requirements.txt con versiones fijas
  - Conexión via Snowpark cuando aplica

- **Semantic Models:**
  - YAML format
  - Máxima simplicidad (dimensions y time_dimensions)
  - Verified queries incluidas

## 🌐 Sectores Cubiertos

- 🏪 Retail (Anomaly Detection, CasaLey, Farma Pronto, Officemax)
- 💰 Fintech (AgilCredit, Monex, Kueski, Maxikash)
- 🏥 Seguros (Centinela)
- 🏢 Inmobiliario (Urbanova)
- ⚡ Energía (GlobEnergy, Fénix)
- 📺 Media (TV Azteca)
- 📞 Telco (Customer 360)
- 🚌 Transporte (ADO)

## 🔒 Seguridad

⚠️ **IMPORTANTE:** Este repositorio contiene código de demostración. Nunca incluyas:
- Credenciales reales de Snowflake
- Tokens o secrets
- Datos sensibles de clientes
- Información de producción

Usa siempre placeholders como `<YOUR_ACCOUNT>`, `<TU_USUARIO>`, etc.

## 🤝 Contribuciones

Este es un repositorio personal de labs y demos. Si tienes sugerencias o mejoras:

1. Abre un Issue describiendo la mejora
2. Fork el repositorio
3. Crea un Pull Request con cambios detallados

## 📄 Licencia

Los proyectos en este repositorio son demos educativas y de referencia. Consulta con cada proyecto específico para detalles de licenciamiento.

## 📬 Contacto

**GitHub:** [@Garabujo24](https://github.com/Garabujo24)  
**Repositorio:** [snowflake-labs](https://github.com/Garabujo24/snowflake-labs)

---

**Actualizado:** Enero 2026  
**Proyectos Totales:** 25+  
**Stack Principal:** Snowflake Data Cloud ❄️

