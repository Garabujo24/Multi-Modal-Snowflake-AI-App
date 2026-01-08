# 🎙️ Audios de Llamadas Bancarias - Dataset de Prueba

## 📋 Descripción

Colección de **26 audios sintéticos** de llamadas bancarias con sus transcripciones y metadatos para pruebas de **Speech-to-Text** y análisis de conversaciones con **Cortex AI** en Snowflake.

**Cliente:** Unstructured Docs  
**Propósito:** Testing de procesamiento de audio y análisis de conversaciones  
**Tecnología:** Google Text-to-Speech (gTTS)  
**Formato:** MP3 + TXT + JSON

---

## 📊 Composición del Dataset de Audios

### 🎯 Resumen Rápido

| Componente | Cantidad | Tamaño Total |
|------------|----------|--------------|
| **Audios MP3** | 26 | ~80 MB |
| **Transcripciones TXT** | 26 | ~208 KB |
| **Metadata JSON** | 26 | ~208 KB |
| **TOTAL** | **78 archivos** | **~80.4 MB** |

---

## 📁 Estructura de Archivos

```
output/audios_banco/
├── mp3/                    # 26 archivos MP3 (750 KB - 1.2 MB cada uno)
│   ├── LLAMADA_001_TAS180523KL8_solicitud_credito_20251022.mp3
│   ├── LLAMADA_002_TAS180523KL8_consulta_saldo_20251025.mp3
│   └── ...
├── transcripciones/        # 26 archivos TXT con texto completo
│   ├── LLAMADA_001_TAS180523KL8_solicitud_credito_20251022.txt
│   ├── LLAMADA_002_TAS180523KL8_consulta_saldo_20251025.txt
│   └── ...
└── metadata/               # 26 archivos JSON con metadatos estructurados
    ├── LLAMADA_001_TAS180523KL8_solicitud_credito_20251022.json
    ├── LLAMADA_002_TAS180523KL8_consulta_saldo_20251025.json
    └── ...
```

---

## 🎭 Tipos de Llamadas Incluidas

### 1. **Consulta de Saldo** (4-5 llamadas)
- **Duración:** 2-3 minutos
- **Categoría:** Información
- **Contenido:** Cliente consulta saldo y movimientos de su cuenta

### 2. **Reporte de Fraude** (4-5 llamadas)
- **Duración:** 4-5 minutos
- **Categoría:** Seguridad
- **Contenido:** Cliente reporta cargo no reconocido, bloqueo de tarjeta

### 3. **Solicitud de Crédito** (4-5 llamadas)
- **Duración:** 5-7 minutos
- **Categoría:** Productos
- **Contenido:** Cliente solicita crédito personal, pre-aprobación

### 4. **Aclaración de Cargo** (4-5 llamadas)
- **Duración:** 3-4 minutos
- **Categoría:** Soporte
- **Contenido:** Cliente pregunta sobre un cargo específico

### 5. **Solicitud de Transferencia** (3-4 llamadas)
- **Duración:** 3-4 minutos
- **Categoría:** Operaciones
- **Contenido:** Cliente realiza transferencia interbancaria

### 6. **Actualización de Datos** (3-4 llamadas)
- **Duración:** 3-4 minutos
- **Categoría:** Administración
- **Contenido:** Cliente actualiza dirección, teléfono, correo

---

## 👥 Cobertura de Entidades

Cada una de las **13 entidades** del dataset tiene **2 llamadas** con diferentes escenarios:

| Entidad | Llamadas |
|---------|----------|
| TECNOLOGÍA AVANZADA DEL SURESTE | 2 |
| MARÍA GUADALUPE HERNÁNDEZ | 2 |
| COMERCIALIZADORA DE ALIMENTOS | 2 |
| JOSÉ ROBERTO GARCÍA | 2 |
| CONSTRUCTORA INDUSTRIAL BAJÍO | 2 |
| ANA PATRICIA MARTÍNEZ | 2 |
| SERVICIOS LOGÍSTICOS | 2 |
| CARLOS EDUARDO RAMÍREZ | 2 |
| DESARROLLOS INMOBILIARIOS | 2 |
| LAURA ISABEL TORRES | 2 |
| MANUFACTURAS TEXTILES | 2 |
| FERNANDO JAVIER LÓPEZ | 2 |
| EXPORTADORA AGRÍCOLA | 2 |

---

## 🎙️ Características de los Audios

### Formato Técnico
- **Formato:** MP3
- **Codec:** MPEG Audio Layer 3
- **Tasa de bits:** Variable (~64-128 kbps)
- **Frecuencia de muestreo:** 22050 Hz (gTTS default)
- **Canales:** Mono
- **Idioma:** Español (México)

### Calidad del Audio
- ✅ Voz sintética clara y profesional
- ✅ Velocidad normal de conversación
- ✅ Sin ruido de fondo
- ✅ Formato compatible con Snowflake/Cortex

---

## 📄 Estructura de Transcripciones

Cada archivo TXT contiene:

```
LLAMADA BANCARIA - [Título del Escenario]
======================================================================

Cliente: [Nombre Completo]
RFC: [RFC]
Fecha: DD/MM/YYYY HH:MM
Duración estimada: X-Y minutos
Categoría: [Categoría]

======================================================================

TRANSCRIPCIÓN:

Ejecutivo: [Diálogo...]
Cliente: [Diálogo...]
...

======================================================================
*** TRANSCRIPCIÓN SINTÉTICA - SOLO PARA PRUEBAS ***
```

---

## 📊 Estructura de Metadata (JSON)

```json
{
  "id_llamada": 1,
  "cliente": {
    "nombre": "TECNOLOGÍA AVANZADA DEL SURESTE SA DE CV",
    "rfc": "TAS180523KL8",
    "tipo": "Persona Moral",
    "estado": "Yucatán"
  },
  "llamada": {
    "tipo": "solicitud_credito",
    "titulo": "Solicitud de Crédito",
    "categoria": "Productos",
    "fecha": "2025-10-22T14:30:00",
    "duracion_estimada": "5-7 minutos"
  },
  "archivos": {
    "audio": "LLAMADA_001_TAS180523KL8_solicitud_credito_20251022.mp3",
    "transcripcion": "LLAMADA_001_TAS180523KL8_solicitud_credito_20251022.txt",
    "metadata": "LLAMADA_001_TAS180523KL8_solicitud_credito_20251022.json"
  },
  "datos_extraidos": {
    "ejecutivo": "Diana Morales",
    "num_cuenta": "****1234",
    "ultimos_rfc": "2KL8"
  },
  "proposito": "Pruebas de Cortex Search y Speech-to-Text",
  "nota": "Contenido sintético sin validez real"
}
```

---

## 🚀 Casos de Uso para Snowflake

### 1. Speech-to-Text con Cortex AI
```sql
-- Extraer texto de audio usando Cortex
SELECT 
    NOMBRE_ARCHIVO,
    SNOWFLAKE.CORTEX.TRANSCRIBE(
        BUILD_SCOPED_FILE_URL(@AUDIO_STAGE, NOMBRE_ARCHIVO)
    ) AS TEXTO_EXTRAIDO
FROM AUDIOS_LLAMADAS;
```

### 2. Análisis de Sentimiento
```sql
-- Analizar sentimiento de la conversación
SELECT 
    ID_LLAMADA,
    CLIENTE_NOMBRE,
    SNOWFLAKE.CORTEX.SENTIMENT(TRANSCRIPCION) AS SENTIMIENTO,
    CATEGORIA
FROM LLAMADAS_TRANSCRIPCIONES;
```

### 3. Clasificación de Llamadas
```sql
-- Clasificar tipo de llamada automáticamente
SELECT 
    ID_LLAMADA,
    TRANSCRIPCION,
    SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
        TRANSCRIPCION,
        ['Consulta', 'Reclamo', 'Solicitud', 'Soporte', 'Venta']
    ) AS TIPO_CLASIFICADO
FROM LLAMADAS_TRANSCRIPCIONES;
```

### 4. Extracción de Información
```sql
-- Extraer datos clave de la conversación
SELECT 
    ID_LLAMADA,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        TRANSCRIPCION,
        'What is the account number mentioned?'
    ) AS CUENTA,
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        TRANSCRIPCION,
        'What is the issue or request?'
    ) AS MOTIVO
FROM LLAMADAS_TRANSCRIPCIONES;
```

### 5. Resumen Automático
```sql
-- Generar resumen de la llamada
SELECT 
    ID_LLAMADA,
    CLIENTE_NOMBRE,
    SNOWFLAKE.CORTEX.SUMMARIZE(TRANSCRIPCION) AS RESUMEN,
    CATEGORIA
FROM LLAMADAS_TRANSCRIPCIONES;
```

### 6. Búsqueda Semántica
```sql
-- Buscar llamadas relacionadas con fraude
SELECT 
    ID_LLAMADA,
    CLIENTE_NOMBRE,
    FECHA,
    SIMILARITY_SCORE
FROM LLAMADAS_TRANSCRIPCIONES
WHERE VECTOR_COSINE_SIMILARITY(
    SNOWFLAKE.CORTEX.EMBED_TEXT('e5-base-v2', TRANSCRIPCION),
    SNOWFLAKE.CORTEX.EMBED_TEXT('e5-base-v2', 'reporte de fraude tarjeta robada')
) > 0.7
ORDER BY SIMILARITY_SCORE DESC;
```

---

## 📈 Análisis Disponibles

### Por Categoría
```sql
SELECT 
    CATEGORIA,
    COUNT(*) AS TOTAL_LLAMADAS,
    AVG(LENGTH(TRANSCRIPCION)) AS LONG_PROMEDIO,
    COUNT(DISTINCT RFC) AS CLIENTES_DISTINTOS
FROM LLAMADAS_TRANSCRIPCIONES
GROUP BY CATEGORIA
ORDER BY TOTAL_LLAMADAS DESC;
```

### Por Sentimiento
```sql
SELECT 
    CATEGORIA,
    SNOWFLAKE.CORTEX.SENTIMENT(TRANSCRIPCION) AS SENTIMIENTO,
    COUNT(*) AS TOTAL
FROM LLAMADAS_TRANSCRIPCIONES
GROUP BY CATEGORIA, SENTIMIENTO
ORDER BY CATEGORIA, TOTAL DESC;
```

### Palabras Clave Frecuentes
```sql
SELECT 
    CATEGORIA,
    REGEXP_COUNT(TRANSCRIPCION, 'cuenta', 1, 'i') AS MENCIONES_CUENTA,
    REGEXP_COUNT(TRANSCRIPCION, 'saldo', 1, 'i') AS MENCIONES_SALDO,
    REGEXP_COUNT(TRANSCRIPCION, 'tarjeta', 1, 'i') AS MENCIONES_TARJETA,
    REGEXP_COUNT(TRANSCRIPCION, 'transferencia', 1, 'i') AS MENCIONES_TRANSFER
FROM LLAMADAS_TRANSCRIPCIONES
GROUP BY CATEGORIA;
```

---

## 🛠️ Cómo Generar Más Audios

### Regenerar Todos
```bash
python3 generar_audios_banco.py
```

### Personalizar Escenarios

Editar `ESCENARIOS` en `generar_audios_banco.py`:

```python
ESCENARIOS = {
    "mi_nuevo_escenario": {
        "titulo": "Mi Título",
        "categoria": "Categoría",
        "duracion_aprox": "X-Y minutos",
        "plantilla": """
        Ejecutivo: ...
        Cliente: ...
        """
    }
}
```

### Requisitos
```bash
pip3 install gtts
```

---

## 💡 Tips para Demos

### 1. Reproducir Audio en Presentación
- Los archivos MP3 se pueden reproducir directamente
- Usar con el TXT para seguir la conversación
- Mostrar metadata JSON para contexto

### 2. Demostrar Cortex Speech-to-Text
```sql
-- Cargar audio a stage
PUT file:///path/to/audio.mp3 @AUDIO_STAGE;

-- Transcribir
SELECT SNOWFLAKE.CORTEX.TRANSCRIBE(
    BUILD_SCOPED_FILE_URL(@AUDIO_STAGE, 'audio.mp3')
);
```

### 3. Comparar Transcripción Automática vs Manual
- Transcripción manual: `LLAMADA_XXX.txt`
- Transcripción automática: `CORTEX.TRANSCRIBE(audio)`
- Calcular similitud y accuracy

### 4. Dashboard de Análisis
Crear vista consolidada:
```sql
CREATE VIEW VW_ANALISIS_LLAMADAS AS
SELECT 
    l.ID_LLAMADA,
    l.CLIENTE_NOMBRE,
    l.CATEGORIA,
    l.FECHA,
    SNOWFLAKE.CORTEX.SENTIMENT(l.TRANSCRIPCION) AS SENTIMIENTO,
    SNOWFLAKE.CORTEX.SUMMARIZE(l.TRANSCRIPCION) AS RESUMEN,
    LENGTH(l.TRANSCRIPCION) AS LONGITUD_TEXTO
FROM LLAMADAS_TRANSCRIPCIONES l;
```

---

## 📊 Estadísticas del Dataset

### Distribución por Categoría
- Información: ~19% (consultas de saldo)
- Seguridad: ~19% (reportes de fraude)
- Productos: ~19% (solicitudes de crédito)
- Soporte: ~19% (aclaraciones)
- Operaciones: ~12% (transferencias)
- Administración: ~12% (actualizaciones)

### Distribución por Tipo de Cliente
- Personas Morales: 46% (12 llamadas)
- Personas Físicas: 54% (14 llamadas)

### Duración Promedio
- Mínima: ~2 minutos (consulta saldo)
- Máxima: ~7 minutos (solicitud crédito)
- Promedio: ~4 minutos

---

## ⚠️ Consideraciones Importantes

### Limitaciones de gTTS
- ✅ Voz sintética clara pero robótica
- ⚠️ Sin entonación emocional natural
- ⚠️ Pausas predefinidas (no naturales)
- ⚠️ Sin ruido de fondo (muy "limpio")

### Para Producción Real
- Considerar usar voces más naturales (Amazon Polly, Azure TTS)
- Agregar ruido de fondo realista
- Incluir variaciones de tono y velocidad
- Simular interrupciones y pausas naturales

### Privacidad
- ✅ Todos los datos son sintéticos
- ✅ Nombres y RFCs ficticios
- ✅ Números de cuenta generados aleatoriamente
- ✅ Sin información real de clientes

---

## 🔧 Troubleshooting

### Error: "Connection timeout"
```bash
# gTTS requiere conexión a internet
# Verificar conectividad y reintentar
```

### Error: "Module 'gtts' not found"
```bash
pip3 install gtts
```

### Audios no se reproducen
- Verificar codec MP3 en tu reproductor
- Probar con VLC o reproductor web
- Convertir a WAV si es necesario

---

## 📞 Scripts Relacionados

| Script | Propósito |
|--------|-----------|
| `generar_audios_banco.py` | Genera audios MP3 + transcripciones |
| `generar_constancias_sat.py` | Genera constancias fiscales |
| `generar_recibos_servicios.py` | Genera recibos y estados de cuenta |

---

## 🎯 Roadmap Futuro

- [ ] Agregar más escenarios (quejas, cancelaciones)
- [ ] Múltiples voces (hombre/mujer, diferentes acentos)
- [ ] Ruido de fondo realista
- [ ] Conversaciones más largas (10-15 minutos)
- [ ] Emociones variadas (enojo, urgencia, satisfacción)
- [ ] Interrupciones y pausas naturales
- [ ] Audio en diferentes calidades (teléfono, VoIP)

---

## 📚 Referencias

### Tecnología Usada
- **gTTS:** https://github.com/pndurette/gTTS
- **Snowflake Cortex:** https://docs.snowflake.com/en/user-guide/snowflake-cortex

### Cortex Audio Functions
- **TRANSCRIBE:** https://docs.snowflake.com/en/sql-reference/functions/transcribe-snowflake-cortex
- **SENTIMENT:** https://docs.snowflake.com/en/sql-reference/functions/sentiment-snowflake-cortex
- **SUMMARIZE:** https://docs.snowflake.com/en/sql-reference/functions/summarize-snowflake-cortex

---

## ✅ Checklist de Uso

- [ ] Instalar gtts: `pip3 install gtts`
- [ ] Ejecutar generador: `python3 generar_audios_banco.py`
- [ ] Verificar archivos generados (MP3 + TXT + JSON)
- [ ] Cargar audios a Snowflake stage
- [ ] Crear tabla de metadatos
- [ ] Probar Cortex Speech-to-Text
- [ ] Implementar análisis de sentimiento
- [ ] Crear dashboard de análisis

---

**Cliente:** Unstructured Docs  
**Versión:** 1.0  
**Fecha:** Noviembre 2025  
**Total Audios:** 26  
**Tamaño Total:** ~80 MB

✨ **Listo para Speech-to-Text y análisis con Cortex AI** ✨



