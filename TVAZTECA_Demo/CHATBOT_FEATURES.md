# TV Azteca Digital - Chatbot con RAG
## Características y Funcionalidades

### 🎯 **Descripción General**
Chatbot inteligente especializado en TV Azteca que utiliza **Retrieval-Augmented Generation (RAG)** para proporcionar respuestas precisas basadas en información corporativa real.

---

### 🚀 **Funcionalidades Principales**

#### 1. **Conversación Natural con IA**
- ✅ Chat conversacional usando **Snowflake Cortex Complete**
- ✅ Soporte para múltiples modelos LLM (Mistral, Llama, Mixtral)
- ✅ Respuestas contextuales en español mexicano profesional
- ✅ Memoria de conversación con historial configurable

#### 2. **Búsqueda Inteligente Híbrida**
- ✅ **Cortex Search** para búsqueda semántica avanzada (cuando está disponible)
- ✅ **Búsqueda SQL fallback** para compatibilidad total
- ✅ Detección automática de disponibilidad de Cortex Search
- ✅ Filtros por departamento (Programación, Finanzas, Marketing, etc.)

#### 3. **Especialización en TV Azteca**
- ✅ Base de conocimientos especializada en:
  - 📺 Programación y contenidos
  - 📊 Ratings y audiencias
  - 💰 Información financiera
  - 🎯 Marketing digital
  - 🔧 Tecnología y transmisión
  - 🏢 Operaciones corporativas

#### 4. **Referencias y Trazabilidad**
- ✅ Citas automáticas de documentos fuente
- ✅ Tabla de referencias con departamento y tipo de documento
- ✅ Transparencia en el origen de la información
- ✅ Indicador del método de búsqueda utilizado

---

### 🛠️ **Características Técnicas**

#### **Arquitectura RAG**
```
Usuario → Pregunta → Búsqueda en Docs → Contexto + Historial → LLM → Respuesta
```

#### **Compatibilidad Total**
- ✅ **Streamlit in Snowflake** (nativo)
- ✅ **Snowpark Session** automática
- ✅ **Cortex Search** con fallback a SQL
- ✅ **Cortex Complete** para generación

#### **Configuración Avanzada**
- 🎛️ Selección de modelo LLM
- 📄 Control de chunks de contexto (1-10)
- 💭 Gestión de historial de chat (1-10 mensajes)
- 🏢 Filtros por departamento
- 🐛 Modo debug para desarrollo

---

### 📊 **Monitoreo y Métricas**

#### **Estado del Sistema**
- ✅ Verificación de disponibilidad de Cortex Search
- ✅ Conteo de documentos disponibles
- ✅ Métricas de departamentos
- ✅ Estado del servicio `tv_azteca_search`

#### **Información de Debug**
- 🔍 Contexto de documentos recuperados
- 📝 Consultas extendidas con historial
- ⚙️ Session state completo
- 🔄 Método de búsqueda utilizado

---

### 🎨 **Experiencia de Usuario**

#### **Interfaz Intuitiva**
- 🎨 Diseño corporativo de TV Azteca
- 🤖 Chat fluido con iconos distintivos
- 📱 Layout responsivo de dos columnas
- 💡 Sugerencias de preguntas iniciales

#### **Sugerencias de Uso**
```
📺 Programación:
- "¿Cuál es el rating de Ventaneando?"
- "¿Qué programas transmite Azteca UNO?"

💰 Finanzas:
- "¿Cuáles son los ingresos de TV Azteca?"
- "¿Cómo ha crecido el negocio digital?"

🎯 Marketing:
- "¿Cuál es la estrategia de redes sociales?"
- "¿Qué campañas digitales están activas?"
```

---

### 🔧 **Configuración Técnica**

#### **Base de Datos**
- **Servicio:** `TVAZTECA_DB.SEARCH_SCHEMA.TV_AZTECA_SEARCH`
- **Tabla:** `TVAZTECA_DB.RAW_SCHEMA.CORPORATE_DOCUMENTS`
- **Warehouse:** `TVAZTECA_WH`

#### **Dependencias**
```txt
snowflake>=0.8.0          # Para Cortex Complete y Root
pandas>=1.3.0             # Análisis de datos
plotly>=5.0.0             # Visualizaciones
```

#### **Modelos LLM Soportados**
- `mistral-large2` (Recomendado para español)
- `llama3.1-70b` (Alto rendimiento)
- `llama3.1-8b` (Rápido y eficiente)
- `mixtral-8x7b` (Versatil)
- `llama3-70b` (Estable)
- `llama3-8b` (Liviano)

---

### 🚨 **Manejo de Errores**

#### **Cortex Search No Disponible**
- ✅ Detección automática de disponibilidad
- ✅ Fallback transparente a búsqueda SQL
- ✅ Mensajes informativos para el usuario
- ✅ Guías de solución paso a paso

#### **Robustez del Sistema**
- 🛡️ Validación de entrada para prevenir inyección SQL
- 🔄 Recuperación automática ante fallos
- 📝 Logging detallado para debugging
- ⚠️ Manejo graceful de errores de conexión

---

### 📈 **Ventajas del Chatbot vs Búsqueda Tradicional**

| Característica | Búsqueda Tradicional | Chatbot RAG |
|----------------|---------------------|-------------|
| **Interacción** | Keywords y filtros | Lenguaje natural |
| **Contexto** | Resultados aislados | Conversación continua |
| **Personalización** | Genérica | Especializada en TV Azteca |
| **Comprensión** | Literal | Semántica y contextual |
| **Respuestas** | Lista de documentos | Respuestas sintetizadas |
| **Referencias** | Manual | Automáticas |
| **Experiencia** | Técnica | Conversacional |

---

### 🎯 **Casos de Uso Ideales**

1. **Ejecutivos:** Consultas estratégicas sobre audiencias y competencia
2. **Marketing:** Datos de campañas y engagement en redes sociales
3. **Finanzas:** Métricas de ingresos y rentabilidad por canal
4. **Programación:** Información de shows, horarios y ratings
5. **Tecnología:** Especificaciones técnicas y infraestructura
6. **Legal:** Políticas corporativas y cumplimiento regulatorio

---

### 🔮 **Próximas Mejoras Sugeridas**

- 📊 **Visualizaciones interactivas** de métricas en respuestas
- 🔗 **Integración con APIs** externas de TV Azteca
- 📱 **Notificaciones** para alertas de rating o noticias
- 🎯 **Personalización** por rol de usuario
- 📝 **Exportación** de conversaciones a PDF/Excel
- 🌐 **Multiidioma** para expansión internacional

---

## 📞 **Soporte y Deployment**

Para deployment completo, consultar:
- `DEPLOYMENT_INSTRUCTIONS.md` - Guía paso a paso
- `TVAZTECA_worksheet.sql` - Setup de infraestructura
- `requirements.txt` - Dependencias necesarias


