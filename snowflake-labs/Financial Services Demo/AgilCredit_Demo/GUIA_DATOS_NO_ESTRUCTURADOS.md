# 📄 Guía: Procesamiento de Datos No Estructurados en Snowflake

## 🎯 Objetivo

Esta guía te muestra cómo extraer y analizar información de archivos **JSON** y **XML** usando funciones nativas de Snowflake, específicamente `PARSE_JSON()` y `PARSE_XML()`.

---

## 📂 Archivos Disponibles

### JSON Files
1. **`perfiles_clientes_detallados.json`** (10 clientes)
   - Perfiles completos con datos personales, contacto, empleo, historial crediticio
   - Información de comportamiento y segmentación avanzada
   - ~500 líneas de datos estructurados jerárquicamente

2. **`transacciones_logs.json`** (100 transacciones)
   - Logs detallados de transacciones con metadata
   - Información de dispositivo, ubicación GPS, checks de fraude
   - Datos de procesamiento y reintentos

### XML Files
1. **`reporte_riesgo_cartera.xml`**
   - Reporte ejecutivo de análisis de riesgo crediticio
   - Indicadores de morosidad (IMOR, cartera vencida)
   - Distribución de cartera por calificación y producto

2. **`reporte_cnbv_operaciones_inusuales.xml`**
   - Reporte regulatorio para la CNBV
   - Operaciones inusuales detectadas
   - Información de cumplimiento normativo

---

## 🚀 Proceso Paso a Paso

### ⚠️ Paso 1: Crear FILE FORMATs y Stage (OBLIGATORIO!)

**Este paso es OBLIGATORIO antes de intentar leer cualquier archivo JSON o XML.**

```sql
USE DATABASE AGILCREDIT_DEMO;
USE SCHEMA CORE;
USE WAREHOUSE COMPUTE_WH;

-- Crear FILE FORMAT para JSON arrays (IMPORTANTE!)
CREATE OR REPLACE FILE FORMAT JSON_ARRAY_FORMAT
    TYPE = JSON
    STRIP_OUTER_ARRAY = TRUE
    COMMENT = 'Formato para leer archivos JSON que son arrays';

-- Crear FILE FORMAT para XML (IMPORTANTE!)
CREATE OR REPLACE FILE FORMAT XML_FORMAT
    TYPE = XML
    COMMENT = 'Formato para leer archivos XML';

-- Crear stage para archivos no estructurados
CREATE OR REPLACE STAGE AGILCREDIT_UNSTRUCTURED_DATA
    FILE_FORMAT = JSON_ARRAY_FORMAT
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage para archivos no estructurados de AgilCredit';

-- Verificar que se crearon correctamente
SHOW FILE FORMATS LIKE '%FORMAT';
SHOW STAGES LIKE 'AGILCREDIT_UNSTRUCTURED_DATA';
```

**⚠️ ERRORES COMUNES SI NO HACES ESTO:**
- ❌ `File format 'JSON_ARRAY_FORMAT' does not exist` → No creaste el FILE FORMAT
- ❌ `File format 'XML_FORMAT' does not exist` → No creaste el FILE FORMAT  
- ❌ `Error parsing JSON: incomplete array value` → Usaste FILE FORMAT incorrecto o no lo especificaste

**💡 Tip:** Puedes usar el script separado `CREAR_FILE_FORMATS.sql` para hacer esto en un solo paso.

### Paso 2: Subir los Archivos

#### Opción A: Desde SnowSQL (Terminal)
```bash
snowsql -c mi_conexion

USE DATABASE AGILCREDIT_DEMO;
USE SCHEMA CORE;

-- Subir JSON
PUT file://./datos_no_estructurados/json/*.json 
    @AGILCREDIT_UNSTRUCTURED_DATA/json/ 
    AUTO_COMPRESS=FALSE;

-- Subir XML
PUT file://./datos_no_estructurados/xml/*.xml 
    @AGILCREDIT_UNSTRUCTURED_DATA/xml/ 
    AUTO_COMPRESS=FALSE;
```

#### Opción B: Desde Snowsight (UI Web)
1. Ve a **Data → Databases → AGILCREDIT_DEMO → CORE → Stages**
2. Click en `AGILCREDIT_UNSTRUCTURED_DATA`
3. Click **+ Files** (botón azul)
4. Arrastra y suelta los archivos o usa el selector
5. Crea las carpetas `json/` y `xml/` según sea necesario

#### Opción C: Desde Python
```python
import snowflake.connector

conn = snowflake.connector.connect(
    user='tu_usuario',
    password='tu_password',
    account='tu_account',
    warehouse='COMPUTE_WH',
    database='AGILCREDIT_DEMO',
    schema='CORE'
)

cursor = conn.cursor()

# Subir archivos
cursor.execute("""
    PUT file://./datos_no_estructurados/json/perfiles_clientes_detallados.json 
    @AGILCREDIT_UNSTRUCTURED_DATA/json/
    AUTO_COMPRESS=FALSE
""")
```

### Paso 3: Verificar Archivos

```sql
-- Listar archivos en el stage
LIST @AGILCREDIT_UNSTRUCTURED_DATA;

-- Ver contenido raw
SELECT $1 
FROM @AGILCREDIT_UNSTRUCTURED_DATA/json/perfiles_clientes_detallados.json
LIMIT 1;
```

---

## 📊 Procesamiento de JSON

### Ejemplo Básico: Leer y Extraer

```sql
-- Ver el JSON parseado directamente
-- Con STRIP_OUTER_ARRAY = TRUE, $1 ya es un objeto VARIANT, no texto!
SELECT 
    $1 as documento_parseado,
    $1:cliente_id::STRING as cliente_id_ejemplo
FROM @AGILCREDIT_UNSTRUCTURED_DATA/json/perfiles_clientes_detallados.json
    (FILE_FORMAT => JSON_ARRAY_FORMAT)
LIMIT 3;

-- Extraer campos específicos usando notación de punto
-- IMPORTANTE: Las rutas deben coincidir EXACTAMENTE con la estructura del JSON
SELECT 
    $1:cliente_id::STRING as CLIENTE_ID,
    $1:perfil_completo.datos_personales.nombre_completo::STRING as NOMBRE,
    $1:perfil_completo.datos_laborales.ingreso_mensual_neto::FLOAT as INGRESO,
    $1:perfil_completo.perfil_riesgo.score_interno_agilcredit::FLOAT as SCORE
FROM @AGILCREDIT_UNSTRUCTURED_DATA/json/perfiles_clientes_detallados.json
    (FILE_FORMAT => JSON_ARRAY_FORMAT)
LIMIT 10;
```

**⚠️ IMPORTANTE:** Verifica siempre las rutas JSON exactas. En este ejemplo:
- ❌ `perfil_completo.empleo.ingreso_mensual` (no existe)
- ✅ `perfil_completo.datos_laborales.ingreso_mensual_neto` (correcto)
- ❌ `perfil_completo.historial_crediticio.score_agilcredit` (no existe)
- ✅ `perfil_completo.perfil_riesgo.score_interno_agilcredit` (correcto)

**💡 Nota:** Con `STRIP_OUTER_ARRAY = TRUE`, cada elemento del array JSON se convierte automáticamente en una fila, y `$1` ya es un objeto VARIANT. **NO necesitas** `PARSE_JSON($1)`!

### Crear Vista Estructurada

```sql
CREATE OR REPLACE VIEW V_PERFILES_JSON AS
SELECT 
    $1:cliente_id::STRING as CLIENTE_ID,
    $1:perfil_completo.datos_personales.nombre_completo::STRING as NOMBRE,
    $1:perfil_completo.datos_personales.edad::INT as EDAD,
    $1:perfil_completo.contacto.email_principal::STRING as EMAIL,
    $1:perfil_completo.datos_laborales.ingreso_mensual_neto::FLOAT as INGRESO_NETO,
    $1:perfil_completo.datos_laborales.ingreso_mensual_bruto::FLOAT as INGRESO_BRUTO,
    $1:perfil_completo.perfil_riesgo.score_interno_agilcredit::FLOAT as SCORE,
    $1:perfil_completo.historial_crediticio.buro_credito.calificacion::INT as CALIFICACION_BURO,
    $1:perfil_completo.perfil_riesgo.clasificacion_riesgo::STRING as CLASIFICACION_RIESGO,
    $1:perfil_completo.scoring_ml.ltv_estimado::FLOAT as LTV_ESTIMADO
FROM @AGILCREDIT_UNSTRUCTURED_DATA/json/perfiles_clientes_detallados.json
    (FILE_FORMAT => JSON_ARRAY_FORMAT);

-- Usar la vista
SELECT * FROM V_PERFILES_JSON WHERE INGRESO_NETO > 30000 AND SCORE > 75;
```

**✨ Mucho más simple!** Ya no necesitas CTE ni `PARSE_JSON()` porque el FILE FORMAT hace todo el trabajo.

**💡 Tip:** Para ver la estructura completa del JSON y verificar las rutas:
```sql
SELECT $1 FROM @STAGE/archivo.json (FILE_FORMAT => JSON_ARRAY_FORMAT) LIMIT 1;
```

### Trabajar con Arrays Anidados

```sql
-- JSON contiene arrays como "idiomas": ["Español", "Inglés"]
-- Extraer cada idioma como una fila separada
SELECT 
    $1:cliente_id::STRING as CLIENTE_ID,
    $1:perfil_completo.datos_personales.nombre_completo::STRING as NOMBRE,
    $1:perfil_completo.datos_personales.idiomas as IDIOMAS_ARRAY,
    idioma.VALUE::STRING as IDIOMA_INDIVIDUAL
FROM @AGILCREDIT_UNSTRUCTURED_DATA/json/perfiles_clientes_detallados.json
    (FILE_FORMAT => JSON_ARRAY_FORMAT),
LATERAL FLATTEN(input => $1:perfil_completo.datos_personales.idiomas) idioma;
```

**💡 Nota:** `STRIP_OUTER_ARRAY` solo aplica al array principal del archivo. Para arrays **anidados** dentro de los objetos, aún necesitas `FLATTEN()`.

---

## 🔍 Procesamiento de XML

### Ejemplo Básico: Leer y Parsear XML

```sql
-- Ver XML parseado directamente
-- Con FILE_FORMAT => XML_FORMAT, $1 ya es un VARIANT parseado!
SELECT 
    $1 as documento_parseado
FROM @AGILCREDIT_UNSTRUCTURED_DATA/xml/reporte_riesgo_cartera.xml
    (FILE_FORMAT => XML_FORMAT)
LIMIT 1;

-- Extraer elementos específicos
SELECT 
    GET(XMLGET(XMLGET($1, 'MetadataReporte'), 'FechaGeneracion'), '$')::DATE as FECHA,
    GET(XMLGET(XMLGET(XMLGET($1, 'ResumenEjecutivo'), 'CarteraTotal'), 'MontoTotal'), '$')::FLOAT as MONTO
FROM @AGILCREDIT_UNSTRUCTURED_DATA/xml/reporte_riesgo_cartera.xml
    (FILE_FORMAT => XML_FORMAT);
```

**💡 Nota:** Con `FILE_FORMAT => XML_FORMAT`, $1 ya es un VARIANT parseado. **NO necesitas** `PARSE_XML($1)`!

### Estructura de Funciones XML

```sql
-- Anatomía de la extracción XML (con FILE_FORMAT):
$1                                     -- 1. Ya es VARIANT parseado (gracias a FILE_FORMAT)
  → XMLGET($1, 'ElementoPadre')       -- 2. Obtener elemento padre
    → XMLGET(..., 'ElementoHijo')      -- 3. Obtener elemento hijo
      → GET(..., '$')                  -- 4. Extraer el valor del elemento
        → ::STRING / ::FLOAT / ::DATE  -- 5. Convertir a tipo específico
```

### Crear Vista desde XML

```sql
CREATE OR REPLACE VIEW V_REPORTE_RIESGO_XML AS
SELECT 
    GET(XMLGET(XMLGET($1, 'MetadataReporte'), 'FechaGeneracion'), '$')::DATE as FECHA_REPORTE,
    GET(XMLGET(XMLGET(XMLGET($1, 'ResumenEjecutivo'), 'CarteraTotal'), 'MontoTotal'), '$')::FLOAT as CARTERA_TOTAL,
    GET(XMLGET(XMLGET(XMLGET($1, 'ResumenEjecutivo'), 'IndicadoresRiesgo'), 'IMOR'), '$')::FLOAT as IMOR,
    GET(XMLGET(XMLGET(XMLGET($1, 'ResumenEjecutivo'), 'IndicadoresRiesgo'), 'CarteraVencida'), '$')::FLOAT as CARTERA_VENCIDA
FROM @AGILCREDIT_UNSTRUCTURED_DATA/xml/reporte_riesgo_cartera.xml
    (FILE_FORMAT => XML_FORMAT);
```

**✨ Sin CTE!** El FILE_FORMAT hace el parseo automáticamente.

---

## 🔄 Integración con Datos Estructurados

### Enriquecer Tablas con JSON

```sql
-- Combinar datos de tabla CLIENTES con información adicional del JSON
SELECT 
    c.CLIENTE_ID,
    c.NOMBRE_COMPLETO,
    c.INGRESO_MENSUAL as INGRESO_BASE,
    j.INGRESOS_ADICIONALES,
    j.GASTOS_MENSUALES,
    j.CAPACIDAD_PAGO,
    j.EMPRESA,
    j.PUESTO,
    j.NIVEL_ENGAGEMENT
FROM CORE.CLIENTES c
LEFT JOIN V_PERFILES_JSON j ON c.CLIENTE_ID = j.CLIENTE_ID;
```

### Validar Reportes XML vs Datos Transaccionales

```sql
-- Comparar indicadores del reporte XML con cálculos en vivo
SELECT 
    'Reporte XML' as FUENTE,
    x.CARTERA_TOTAL,
    x.IMOR
FROM V_REPORTE_RIESGO_XML x

UNION ALL

SELECT 
    'Datos en Vivo' as FUENTE,
    SUM(SALDO_ACTUAL) as CARTERA_TOTAL,
    ROUND(
        SUM(CASE WHEN ESTATUS_CREDITO IN ('MORA', 'VENCIDO') 
            THEN SALDO_ACTUAL ELSE 0 END) * 100.0 / SUM(SALDO_ACTUAL), 
        2
    ) as IMOR
FROM CORE.CREDITOS;
```

---

## 🎨 Casos de Uso Avanzados

### 1. Detección de Anomalías con Logs JSON

```sql
-- Transacciones con alto score de fraude desde logs
SELECT 
    t.TRANSACTION_ID,
    t.CLIENTE_ID,
    t.TIMESTAMP,
    t.MONTO,
    t.FRAUD_SCORE,
    t.FRAUD_FLAGS,
    t.IP_ADDRESS,
    t.DEVICE_TYPE
FROM V_TRANSACCIONES_LOGS_JSON t
WHERE t.FRAUD_SCORE > 70
ORDER BY t.FRAUD_SCORE DESC;
```

### 2. Segmentación Avanzada con Datos Enriquecidos

```sql
-- Identificar clientes premium con bajo riesgo de churn
SELECT 
    j.CLIENTE_ID,
    j.NOMBRE,
    j.SEGMENTO_RENTABILIDAD,
    j.LTV_ESTIMADO,
    j.PROB_CHURN,
    j.NIVEL_ENGAGEMENT,
    j.CAPACIDAD_PAGO,
    COUNT(cr.CREDITO_ID) as NUM_CREDITOS
FROM V_PERFILES_JSON j
LEFT JOIN CORE.CREDITOS cr ON j.CLIENTE_ID = cr.CLIENTE_ID
WHERE j.SEGMENTO_RENTABILIDAD = 'Alto Valor'
  AND j.PROB_CHURN < 0.2
  AND j.NIVEL_ENGAGEMENT IN ('Alto', 'Muy Alto')
GROUP BY j.CLIENTE_ID, j.NOMBRE, j.SEGMENTO_RENTABILIDAD, 
         j.LTV_ESTIMADO, j.PROB_CHURN, j.NIVEL_ENGAGEMENT, j.CAPACIDAD_PAGO
ORDER BY j.LTV_ESTIMADO DESC;
```

### 3. Auditoría Regulatoria con XML

```sql
-- Extraer operaciones inusuales del reporte CNBV
SELECT 
    r.NUMERO_REPORTE,
    r.FECHA_PRESENTACION,
    r.TOTAL_OPERACIONES,
    r.MONTO_TOTAL_OPERACIONES,
    r.CLIENTES_INVOLUCRADOS
FROM V_REPORTE_CNBV_XML r
WHERE r.TOTAL_OPERACIONES > 0;
```

---

## 📝 Funciones Clave de Snowflake

### FILE FORMATS (Lo Más Importante!)

| FILE FORMAT | Propósito | Beneficio |
|-------------|-----------|-----------|
| `JSON_ARRAY_FORMAT`<br>`(TYPE=JSON, STRIP_OUTER_ARRAY=TRUE)` | Para JSON arrays `[{...}, {...}]` | $1 ya es VARIANT<br>❌ NO necesitas `PARSE_JSON()` |
| `XML_FORMAT`<br>`(TYPE=XML)` | Para archivos XML | $1 ya es VARIANT<br>❌ NO necesitas `PARSE_XML()` |

### Para JSON

| Función | Descripción | Ejemplo |
|---------|-------------|---------|
| `$1:path::TYPE` | Extrae valor con notación de punto | `$1:cliente.nombre::STRING` |
| `FLATTEN()` | Expande arrays **anidados** a filas | `LATERAL FLATTEN(input => $1:items)` |
| `ARRAY_SIZE()` | Cuenta elementos en array | `ARRAY_SIZE($1:items)` |

### Para XML

| Función | Descripción | Ejemplo |
|---------|-------------|---------|
| `XMLGET($1, 'tag')` | Obtiene elemento XML por nombre | `XMLGET($1, 'Cliente')` |
| `GET(elem, '$')` | Extrae el valor del elemento | `GET(XMLGET(...), '$')` |
| `::TYPE` | Convierte a tipo específico | `...::STRING`, `...::FLOAT` |

**🔑 Regla de Oro:** Con FILE FORMAT correcto, `$1` ya es VARIANT. NO uses `PARSE_JSON($1)` ni `PARSE_XML($1)`!

---

## ⚠️ Consideraciones y Best Practices

### 1. Performance
- **Materializa vistas frecuentes** como tablas para mejor rendimiento
- Usa `LIMIT` en desarrollo para queries rápidas
- Considera crear **columnas computadas** para campos frecuentemente accedidos

```sql
-- Materializar vista
CREATE TABLE PERFILES_JSON_MATERIALIZED AS 
SELECT * FROM V_PERFILES_JSON;

-- Refrescar periódicamente con TASK
CREATE TASK REFRESH_PERFILES_JSON
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 2 * * * America/Mexico_City'
AS
    CREATE OR REPLACE TABLE PERFILES_JSON_MATERIALIZED AS 
    SELECT * FROM V_PERFILES_JSON;
```

### 2. Manejo de Tipos
- Siempre usa **casting explícito** (`::<TYPE>`) al extraer valores
- Los valores `NULL` en JSON/XML deben manejarse explícitamente
- Usa `TRY_CAST()` para conversiones seguras

```sql
-- Casting seguro
SELECT 
    TRY_CAST(doc:edad AS INT) as EDAD,
    COALESCE(doc:telefono::STRING, 'No disponible') as TELEFONO
FROM ...
```

### 3. Estructura de Archivos
- **JSON**: Mantén archivos < 100 MB para mejor procesamiento
- **XML**: Evita anidación excesiva (> 5 niveles)
- Usa convenciones de nombres consistentes en tus archivos

### 4. Seguridad
- Controla acceso al stage con **GRANTS** apropiados
- Usa **MASKING POLICIES** para datos sensibles en vistas
- Audita acceso a datos no estructurados con **QUERY_HISTORY**

```sql
-- Otorgar acceso al stage
GRANT READ ON STAGE AGILCREDIT_UNSTRUCTURED_DATA TO ROLE ANALISTA_DATOS;

-- Crear política de enmascaramiento
CREATE MASKING POLICY MASK_EMAIL AS (val STRING) RETURNS STRING ->
    CASE 
        WHEN CURRENT_ROLE() IN ('ADMIN', 'COMPLIANCE_OFFICER') THEN val
        ELSE '***@***.com'
    END;
```

---

## 🔧 Troubleshooting

### Problema: "File format 'JSON_ARRAY_FORMAT' does not exist" o "File format 'XML_FORMAT' does not exist" ⚠️
**Causa:** No has creado los FILE FORMATs necesarios

**Solución:**
```sql
-- Ejecuta estos comandos PRIMERO:
USE DATABASE AGILCREDIT_DEMO;
USE SCHEMA CORE;

CREATE OR REPLACE FILE FORMAT JSON_ARRAY_FORMAT
    TYPE = JSON
    STRIP_OUTER_ARRAY = TRUE;

CREATE OR REPLACE FILE FORMAT XML_FORMAT
    TYPE = XML;

-- Verificar que se crearon
SHOW FILE FORMATS LIKE '%FORMAT';
```

**💡 Alternativa:** Ejecuta el script `CREAR_FILE_FORMATS.sql` que hace todo esto automáticamente.

---

### Problema: "Error parsing JSON: incomplete array value, pos 2" ⚠️
**Causa:** Tu archivo JSON es un array `[{...}, {...}]` pero no has configurado `STRIP_OUTER_ARRAY = TRUE`

**Solución:**
```sql
-- Opción 1: Crear FILE FORMAT con STRIP_OUTER_ARRAY (RECOMENDADO)
CREATE OR REPLACE FILE FORMAT JSON_ARRAY_FORMAT
    TYPE = JSON
    STRIP_OUTER_ARRAY = TRUE;

-- Usar el formato en la query
SELECT $1 
FROM @STAGE/archivo.json (FILE_FORMAT => JSON_ARRAY_FORMAT);

-- Opción 2: Especificar inline
SELECT $1 
FROM @STAGE/archivo.json (FILE_FORMAT => (TYPE=JSON, STRIP_OUTER_ARRAY=TRUE));
```

**Explicación:**
- Sin `STRIP_OUTER_ARRAY`: Snowflake lee el archivo línea por línea → falla porque `[` no es un objeto válido
- Con `STRIP_OUTER_ARRAY = TRUE`: Snowflake procesa el array completo y convierte cada elemento en una fila

### Problema: "File not found in stage"
**Solución:** Verifica que subiste los archivos correctamente
```sql
LIST @AGILCREDIT_UNSTRUCTURED_DATA;
```

### Problema: "Error parsing JSON" (otros casos)
**Solución:** Verifica que el JSON es válido
```sql
-- Ver contenido raw
SELECT $1 FROM @STAGE/archivo.json LIMIT 1;

-- Validar JSON en terminal
python3 -c "import json; json.load(open('archivo.json')); print('✅ Válido')"
```

### Problema: "PARSE_XML returns NULL" o "XMLGET returns NULL"
**Causa:** No estás usando el FILE_FORMAT correcto para XML

**Solución:**
```sql
-- ❌ MAL: Sin FILE_FORMAT, $1 es texto y PARSE_XML puede fallar
SELECT PARSE_XML($1) FROM @STAGE/archivo.xml;

-- ✅ BIEN: Con FILE_FORMAT, $1 ya es VARIANT parseado
SELECT $1 FROM @STAGE/archivo.xml (FILE_FORMAT => XML_FORMAT);
```

**Si XMLGET sigue retornando NULL, verifica la ruta:**
```sql
-- Ver estructura completa del XML
SELECT $1 FROM @STAGE/archivo.xml (FILE_FORMAT => XML_FORMAT) LIMIT 1;

-- Verificar nombres de elementos (case-sensitive!)
SELECT XMLGET($1, 'ReporteRiesgoCartera') FROM @STAGE/archivo.xml (FILE_FORMAT => XML_FORMAT);
```

### Problema: Performance lento
**Solución:** Materializa vistas frecuentes
```sql
CREATE TABLE mi_tabla AS SELECT * FROM mi_vista;
```

---

## 📚 Recursos Adicionales

- **Script completo:** `AgilCredit_Parse_Unstructured_Data.sql`
- **Documentación Snowflake:** [Semi-Structured Data](https://docs.snowflake.com/en/user-guide/semistructured-concepts.html)
- **Archivos de ejemplo:** `./datos_no_estructurados/`

---

## ✅ Checklist de Implementación

- [ ] Crear stage `AGILCREDIT_UNSTRUCTURED_DATA`
- [ ] Subir archivos JSON y XML al stage
- [ ] Verificar archivos con `LIST @STAGE`
- [ ] Ejecutar queries de prueba para JSON
- [ ] Ejecutar queries de prueba para XML
- [ ] Crear vistas estructuradas
- [ ] Integrar con tablas existentes
- [ ] Configurar refrescos automáticos (TASKS)
- [ ] Implementar controles de acceso
- [ ] Documentar vistas creadas para el equipo

---

**¡Listo!** 🎉 Ahora puedes extraer y analizar datos no estructurados en Snowflake con confianza.

