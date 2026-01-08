# 🚀 Guía Rápida - Constancias SAT para Cortex Search

## 📦 ¿Qué se generó?

Se crearon **13 constancias de situación fiscal** sintéticas del SAT mexicano para pruebas de Cortex Search en Snowflake.

### Archivos Generados

```
output/
├── pdfs/                    # 13 archivos PDF (4-5 KB cada uno)
│   ├── CSF_01_TAS180523KL8.pdf
│   ├── CSF_02_HESM850614J39.pdf
│   └── ... (11 más)
├── imagenes/                # 13 archivos PNG (43-44 KB cada uno)
│   ├── CSF_01_TAS180523KL8.png
│   ├── CSF_02_HESM850614J39.png
│   └── ... (11 más)
├── metadatos_constancias.csv    # Metadatos en formato CSV
└── metadatos_constancias.json   # Metadatos en formato JSON
```

## 📊 Composición del Dataset

- **7 Personas Morales** (53.8%) - Empresas SA de CV
- **6 Personas Físicas** (46.2%) - Contribuyentes individuales
- **12 Estados** diferentes de México
- **5 Regímenes fiscales** distintos (601, 605, 612, 621, 626)
- **11 Sectores** representados (Tecnología, Alimentos, Construcción, etc.)

## 🎯 Casos de Uso para Cortex Search

### 1. **Búsqueda Semántica**
Encuentra constancias usando lenguaje natural:
- "Busca empresas del sector tecnológico"
- "Encuentra contribuyentes en Jalisco"
- "Muéstrame personas físicas con actividad empresarial"

### 2. **Clasificación Automática**
Clasifica documentos por:
- Tipo de contribuyente
- Sector de actividad
- Región geográfica
- Régimen fiscal

### 3. **Extracción de Datos**
Extrae información estructurada:
- RFC y CURP
- Nombres y razones sociales
- Domicilios fiscales
- Obligaciones fiscales

### 4. **Análisis Geoespacial**
Identifica patrones:
- Concentración de empresas por estado
- Distribución de regímenes fiscales
- Sectores económicos por región

## ⚡ Inicio Rápido (3 pasos)

### Paso 1: Cargar a Snowflake

```sql
-- Ejecutar setup_cortex_search.sql
-- El script configura todo automáticamente:
-- ✓ Warehouse
-- ✓ Base de datos
-- ✓ Tablas
-- ✓ Stage
-- ✓ Datos sintéticos
```

### Paso 2: Subir PDFs

Desde SnowSQL:

```bash
PUT file:///Users/gjimenez/Documents/GitHub/Unstructured%20Documents/output/pdfs/*.pdf @CONSTANCIAS_STAGE AUTO_COMPRESS=FALSE;
```

Desde Snowflake Web UI:
1. Ir a Databases → UNSTRUCTURED_DOCS_DB → DOCUMENTOS_SAT → Stages
2. Seleccionar CONSTANCIAS_STAGE
3. Hacer clic en "Upload Files"
4. Seleccionar todos los PDFs de la carpeta `output/pdfs/`

### Paso 3: Probar búsquedas

```sql
-- Buscar empresas de tecnología
SELECT * FROM CONSTANCIAS_FISCALES 
WHERE NOMBRE_CONTRIBUYENTE ILIKE '%tecnolog%';

-- Ver distribución por estado
SELECT ESTADO, COUNT(*) 
FROM CONSTANCIAS_FISCALES 
GROUP BY ESTADO;

-- Análisis con Cortex AI
SELECT 
    NOMBRE_CONTRIBUYENTE,
    SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
        NOMBRE_CONTRIBUYENTE,
        ['Tecnología', 'Alimentos', 'Construcción', 'Servicios']
    ) AS SECTOR
FROM CONSTANCIAS_FISCALES;
```

## 🔍 Consultas de Ejemplo

### Búsqueda por RFC
```sql
SELECT * FROM CONSTANCIAS_FISCALES 
WHERE RFC = 'TAS180523KL8';
```

### Personas Físicas en RESICO
```sql
SELECT NOMBRE_CONTRIBUYENTE, ESTADO 
FROM CONSTANCIAS_FISCALES
WHERE REGIMEN_FISCAL LIKE '626%';
```

### Empresas en Jalisco
```sql
SELECT NOMBRE_CONTRIBUYENTE, MUNICIPIO
FROM CONSTANCIAS_FISCALES
WHERE ESTADO = 'Jalisco' AND TIPO_PERSONA = 'Persona Moral';
```

### Análisis por Régimen
```sql
SELECT 
    LEFT(REGIMEN_FISCAL, 3) AS CODIGO,
    COUNT(*) AS TOTAL
FROM CONSTANCIAS_FISCALES
GROUP BY LEFT(REGIMEN_FISCAL, 3);
```

## 📈 Análisis Avanzado con Cortex

### Resumen Inteligente con IA
```sql
SELECT 
    NOMBRE_CONTRIBUYENTE,
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large',
        'Resume en 1 frase: ' || TEXTO_EXTRAIDO
    ) AS RESUMEN_IA
FROM CONSTANCIAS_FISCALES
LIMIT 5;
```

### Búsqueda Semántica
```sql
-- Con Cortex Search configurado
SELECT * FROM CORTEX_SEARCH(
    'BUSQUEDA_CONSTANCIAS',
    'empresas de construcción en el bajío'
);
```

### Clasificación de Sector
```sql
SELECT 
    NOMBRE_CONTRIBUYENTE,
    SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
        NOMBRE_CONTRIBUYENTE,
        ['Industrial', 'Comercio', 'Servicios', 'Tecnología']
    ) AS CATEGORIA
FROM CONSTANCIAS_FISCALES
WHERE TIPO_PERSONA = 'Persona Moral';
```

## 📋 Archivos de Metadatos

### CSV (`metadatos_constancias.csv`)
21 campos incluyendo:
- Identificación (RFC, CURP, Nombre)
- Régimen fiscal
- Domicilio completo
- Datos operativos
- Sector económico

**Uso:**
```sql
-- Cargar CSV a Snowflake
COPY INTO CONSTANCIAS_FISCALES_META
FROM @CONSTANCIAS_STAGE/metadatos_constancias.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1);
```

### JSON (`metadatos_constancias.json`)
Estructura jerárquica con:
- Identificación
- Régimen fiscal
- Domicilio
- Contacto
- Datos operativos
- Metadata

**Uso:**
```sql
-- Consultar JSON directamente
SELECT 
    $1:identificacion:rfc::VARCHAR AS RFC,
    $1:identificacion:nombre::VARCHAR AS NOMBRE,
    $1:regimen_fiscal:descripcion::VARCHAR AS REGIMEN
FROM @CONSTANCIAS_STAGE/metadatos_constancias.json;
```

## 🔧 Scripts Disponibles

| Script | Propósito |
|--------|-----------|
| `generar_constancias_sat.py` | Genera 13 PDFs e imágenes de constancias |
| `generar_metadatos_csv.py` | Exporta metadatos a CSV y JSON |
| `setup_cortex_search.sql` | Configura entorno completo en Snowflake |

## 💡 Tips y Mejores Prácticas

### Para Demos
1. **Comienza simple**: Muestra búsquedas básicas por RFC o nombre
2. **Escala a IA**: Luego introduce clasificación con Cortex
3. **Impresiona con semántica**: Termina con búsquedas en lenguaje natural

### Para Desarrollo
1. **Valida RFCs**: Implementa validación de formato de RFC
2. **Enriquece datos**: Agrega más campos según tu caso de uso
3. **Integra OCR**: Usa PARSE_DOCUMENT para extraer texto real de PDFs

### Para Producción
1. **Seguridad**: Implementa row-level security
2. **Auditoría**: Registra quién accede a qué documentos
3. **Backups**: Mantén respaldos del stage y tablas

## 📊 Estadísticas del Dataset

- **Total documentos**: 13
- **Tamaño total PDFs**: ~60 KB
- **Tamaño total imágenes**: ~560 KB
- **Estados representados**: 12
- **Años de operación**: 4-15 años (desde 2010)

## ⚠️ Importante

⚠️ **ESTOS DOCUMENTOS SON SINTÉTICOS Y SOLO PARA PRUEBAS**

- ❌ NO tienen validez legal
- ❌ NO usar para trámites reales
- ❌ NO representan documentos oficiales del SAT
- ✅ Solo para desarrollo, demos y capacitación

## 🎓 Recursos Adicionales

### Documentación Snowflake
- [Cortex Search](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search)
- [Cortex AI Functions](https://docs.snowflake.com/en/user-guide/snowflake-cortex/llm-functions)
- [Document AI](https://docs.snowflake.com/en/user-guide/snowflake-cortex/document-ai)

### SAT México
- [Portal SAT](https://www.sat.gob.mx)
- [Constancia de Situación Fiscal oficial](https://www.sat.gob.mx/aplicacion/login/53027/obtiene-tu-constancia-de-situacion-fiscal)

## 🤝 Soporte

Para regenerar las constancias:
```bash
python3 generar_constancias_sat.py
```

Para regenerar metadatos:
```bash
python3 generar_metadatos_csv.py
```

Para instalar dependencias:
```bash
pip3 install -r requirements.txt
```

---

**Cliente:** Unstructured Docs  
**Versión:** 1.0  
**Fecha:** Octubre 2025  
**Propósito:** Pruebas de Cortex Search con documentos fiscales mexicanos



