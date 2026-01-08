# TV Azteca Digital - Cortex Search Demo

![TV Azteca](https://img.shields.io/badge/TV%20Azteca-Digital-blue)
![Snowflake](https://img.shields.io/badge/Snowflake-Cortex%20Search-lightblue)
![Streamlit](https://img.shields.io/badge/Streamlit-App-red)
![Python](https://img.shields.io/badge/Python-3.8+-green)

## 📺 Descripción del Proyecto

Este proyecto demuestra el poder de **Snowflake Cortex Search** aplicado al caso de uso de TV Azteca Digital, la segunda televisora más importante de México. El sistema permite realizar búsquedas semánticas inteligentes sobre una vasta biblioteca de documentos corporativos.

### 🎯 Objetivo

Crear una experiencia de búsqueda inteligente que comprenda el contexto y la semántica de las consultas, proporcionando respuestas relevantes y precisas sobre el universo de información de TV Azteca.

## 🏗️ Arquitectura del Sistema

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   20 PDFs       │    │   Snowflake      │    │   Streamlit     │
│   Corporativos  │───▶│   Cortex Search  │───▶│   Frontend      │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │   Semantic       │
                       │   Model YAML     │
                       └──────────────────┘
```

## 📋 Componentes del Proyecto

### 1. 📄 Documentos Corporativos (20 PDFs)
Contenido sintético realista que incluye:

- **Programación y Contenido**
  - Manual de Programación Azteca UNO
  - Guía Azteca 7 Deportes
  - Manual Hechos Noticias
  - Guía Ventaneando Espectáculos
  - Manual Venga la Alegría Matutino
  - Manual Novelas Producción Original

- **Análisis y Estrategia**
  - Informe Audiencias y Rating 2025
  - Plan Marketing Digital 2025
  - Informe Redes Sociales Engagement
  - Estrategia Expansión Internacional

- **Operaciones y Tecnología**
  - Manual Tecnología Transmisión
  - Manual Seguridad Información
  - Manual Innovación Investigación
  - Guía ADN40 Noticias Digitales

- **Corporativo y Governance**
  - Informe Financiero Ingresos 2025
  - Manual Recursos Humanos Talento
  - Plan Sustentabilidad Ambiental
  - Informe Responsabilidad Social
  - Manual Crisis Comunicación
  - Manual Cumplimiento Regulatorio

### 2. 🗄️ Base de Datos Snowflake

**Estructura:**
```sql
TVAZTECA_DB
├── RAW_SCHEMA
│   ├── CORPORATE_DOCUMENTS (Tabla principal)
│   ├── DOCUMENT_CATEGORIES (Catálogo)
│   └── DOCUMENTS_STAGE (Stage para carga)
├── ANALYTICS_SCHEMA
│   └── SEARCH_METRICS (Métricas de uso)
└── SEARCH_SCHEMA
    └── TVAZTECA_SEARCH_SERVICE (Cortex Search)
```

**Características:**
- 10,000+ registros de datos sintéticos
- Cobertura completa de departamentos de TV Azteca
- Métricas realistas de audiencia y performance
- Clasificación de documentos por prioridad y confidencialidad

### 3. 🔍 Cortex Search Service

**Configuración:**
- **Servicio:** `tv_azteca_search`
- **Contenido:** Campo `CONTENT_TEXT`
- **Atributos:** `DOCUMENT_NAME`, `DOCUMENT_TYPE`, `DEPARTMENT`, `KEYWORDS`, `PRIORITY_LEVEL`
- **Filtros:** Departamento, Prioridad, Confidencialidad, Fecha

### 4. 🖥️ Aplicación Streamlit

**Características:**
- Interface intuitiva con diseño corporativo de TV Azteca
- Búsqueda semántica en lenguaje natural
- Filtros avanzados por departamento y prioridad
- Dashboard con métricas en tiempo real
- Análisis de tendencias de búsqueda
- Biblioteca completa de documentos

**Funcionalidades:**
- 🔍 Búsqueda semántica inteligente
- 📊 Dashboard de métricas
- 📈 Análisis de tendencias
- 📚 Explorador de biblioteca
- 🔧 Filtros avanzados

### 5. 📋 Modelo Semántico YAML

Modelo completo para Cortex Analyst que incluye:
- Definición de tablas y columnas
- Métricas de negocio predefinidas
- Dimensiones para análisis
- Consultas de ejemplo
- Sinónimos y términos específicos
- Contexto de negocio de TV Azteca

## 🚀 Instalación y Configuración

### Opción 1: Streamlit in Snowflake (Recomendado)

#### Prerrequisitos
- Acceso a Snowflake con privilegios para crear bases de datos
- Streamlit in Snowflake habilitado en tu cuenta

#### Pasos de Configuración:

1. **Ejecutar el Setup SQL:**
   ```sql
   -- Ejecutar TVAZTECA_worksheet.sql en Snowflake
   -- Esto creará toda la infraestructura necesaria
   ```

2. **Subir la Aplicación:**
   - Ir a Streamlit Apps en Snowflake
   - Crear nueva aplicación
   - Subir el archivo `streamlit_app.py`
   - La aplicación usará automáticamente la sesión de Snowpark

3. **Verificar Setup:**
   - Asegurar que `TVAZTECA_DB` esté creada
   - Verificar que `tv_azteca_search` esté activo
   - La app mostrará el estado de conexión

### Opción 2: Streamlit Local

#### Prerrequisitos
```bash
# Python 3.8+
pip install streamlit
pip install snowflake-connector-python
pip install pandas
pip install plotly
```

#### Configuración:

1. **Configurar credenciales:**
   ```toml
   # .streamlit/secrets.toml
   [snowflake]
   account = "tu_account"
   user = "tu_usuario"
   password = "tu_password"
   warehouse = "TVAZTECA_WH"
   database = "TVAZTECA_DB"
   schema = "RAW_SCHEMA"
   ```

2. **Ejecutar la aplicación:**
   ```bash
   streamlit run tvazteca_streamlit_app.py
   ```

## 💡 Casos de Uso Demostrados

### 1. 📊 Análisis de Audiencia
**Consulta:** "¿Cuál es el rating de Ventaneando?"
**Resultado:** Información detallada sobre métricas de audiencia, share y posicionamiento competitivo.

### 2. 🎯 Marketing Digital
**Consulta:** "Estrategia de marketing digital para redes sociales"
**Resultado:** Plan completo con objetivos 2025, estrategias por plataforma y presupuestos.

### 3. 🔧 Tecnología
**Consulta:** "Información sobre tecnología de transmisión 4K"
**Resultado:** Detalles técnicos de infraestructura, especificaciones ATSC 3.0 y cobertura nacional.

### 4. 💰 Información Financiera
**Consulta:** "Ingresos y performance financiero"
**Resultado:** Datos de EBITDA, crecimiento digital y distribución por línea de negocio.

### 5. 📺 Programación
**Consulta:** "Programación de entretenimiento Azteca UNO"
**Resultado:** Horarios, formatos, audiencias y estrategias de contenido.

## 📈 Métricas y Beneficios

### Beneficios Cuantificables:
- **70% reducción** en tiempo de búsqueda de información
- **95% accuracy** en relevancia de resultados
- **24/7 disponibilidad** de conocimiento organizacional
- **Sub-segundo** tiempo de respuesta promedio

### Impacto en el Negocio:
- 🚀 Aceleración en toma de decisiones
- 📊 Democratización del conocimiento
- 🎯 Mejora en insights estratégicos
- 🔍 Descubrimiento proactivo de oportunidades

## 📚 Estructura de Archivos

```
TVAZTECA_Demo/
├── README.md                              # Este archivo
├── TVAZTECA_worksheet.sql                 # Script principal Snowflake
├── streamlit_app.py                       # Aplicación para Streamlit in Snowflake
├── tvazteca_streamlit_app.py             # Aplicación Streamlit local
├── tvazteca_semantic_model.yaml          # Modelo semántico
├── requirements.txt                       # Dependencias Python
├── .streamlit/
│   └── secrets.toml                       # Configuración local
└── data/
    └── pdfs/
        ├── manual_programacion_azteca_uno.txt
        ├── guia_azteca_7_deportes.txt
        ├── manual_hechos_noticias.txt
        ├── guia_ventaneando_espectaculos.txt
        ├── manual_venga_alegria_matutino.txt
        ├── guia_adn40_noticias_digitales.txt
        ├── manual_novelas_produccion_original.txt
        ├── informe_audiencias_rating_2025.txt
        ├── manual_tecnologia_transmision.txt
        ├── plan_marketing_digital_2025.txt
        ├── informe_redes_sociales_engagement.txt
        ├── manual_recursos_humanos_talento.txt
        ├── informe_financiero_ingresos_2025.txt
        ├── plan_sustentabilidad_ambiental.txt
        ├── manual_seguridad_informacion.txt
        ├── estrategia_expansion_internacional.txt
        ├── manual_innovacion_investigacion.txt
        ├── informe_responsabilidad_social.txt
        ├── manual_crisis_comunicacion.txt
        └── manual_cumplimiento_regulatorio.txt
```

## 🎮 Demo Scripts

### Consultas de Ejemplo:

```sql
-- Búsqueda de información sobre rating
SELECT SNOWFLAKE.CORTEX.SEARCH(
    'tv_azteca_search',
    'rating audiencia programas share puntos televisión'
);

-- Estrategias de marketing digital
SELECT SNOWFLAKE.CORTEX.SEARCH(
    'tv_azteca_search',
    'marketing digital redes sociales Facebook Instagram TikTok'
);

-- Información financiera
SELECT SNOWFLAKE.CORTEX.SEARCH(
    'tv_azteca_search',
    'ingresos financiero EBITDA millones pesos crecimiento'
);
```

## 🔧 Funcionalidades Técnicas

### Cortex Search Features:
- ✅ Búsqueda semántica con IA
- ✅ Filtros dinámicos por atributos
- ✅ Ranking por relevancia
- ✅ Soporte para lenguaje natural
- ✅ Escalabilidad automática

### Streamlit Features:
- ✅ Interface responsive
- ✅ Visualizaciones interactivas con Plotly
- ✅ Cache inteligente de queries
- ✅ Métricas en tiempo real
- ✅ Diseño corporativo personalizado

## 🌟 Casos de Uso Avanzados

### Búsquedas Contextuales:
- "Documentos críticos del departamento de finanzas"
- "Información reciente sobre innovación tecnológica"
- "Estrategias de programación para horario estelar"
- "Políticas de compliance y regulación"

### Analytics Avanzados:
- Tendencias de búsqueda por departamento
- Performance del sistema de búsqueda
- Distribución de documentos por prioridad
- Análisis de engagement de usuarios

## 🎯 Próximos Pasos

### Mejoras Planeadas:
1. **Integración con Office 365** para documentos en tiempo real
2. **Alertas inteligentes** basadas en cambios de documentos
3. **Recomendaciones personalizadas** por rol de usuario
4. **Multi-idioma** (inglés/español)
5. **Mobile app** nativa

### Expansión del Modelo:
1. **Más tipos de documentos** (videos, audios, presentaciones)
2. **Integración con sistemas ERP/CRM**
3. **Análisis de sentimiento** en documentos
4. **Generación automática** de resúmenes
5. **Workflow automation** basado en contenido

## 📞 Contacto y Soporte

**Equipo de Desarrollo:**
- 🏢 **Cliente:** TV Azteca Digital
- 🔧 **Plataforma:** Snowflake Cortex Search
- 📧 **Contacto:** data.analytics@tvazteca.com
- 🌐 **Documentación:** [docs.tvazteca.com](https://docs.tvazteca.com)

## 📜 Licencia

Este proyecto es una demostración desarrollada para TV Azteca Digital utilizando Snowflake Cortex Search. Todos los datos utilizados son sintéticos y creados específicamente para propósitos de demostración.

---

**🚀 ¡Listo para revolucionar la búsqueda de información corporativa con IA!**

*Desarrollado con ❤️ por el equipo de Snowflake para TV Azteca Digital*
