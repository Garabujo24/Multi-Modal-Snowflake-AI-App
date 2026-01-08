# 📚 Dataset Completo de Documentos No Estructurados

## 🎯 Descripción General

Dataset sintético de **273 archivos** de 5 tipos diferentes de documentos mexicanos para pruebas de **Cortex Search** en Snowflake.

**Cliente:** Unstructured Docs  
**Propósito:** Testing de búsqueda semántica y procesamiento de documentos no estructurados  
**Tamaño Total:** ~6.5 MB  
**Formato:** PDF + PNG

---

## 📊 Composición del Dataset

### 🎯 Resumen Rápido

| Tipo de Documento | PDFs | Imágenes | Total | Periodo |
|-------------------|------|----------|-------|---------|
| **Constancias SAT** | 13 | 13 | 26 + 2 metadatos | Único |
| **Recibos Nómina** | 18 | 18 | 36 | 3 meses |
| **Recibos Agua** | 39 | 39 | 78 | 3 meses |
| **Recibos Luz** | 26 | 26 | 52 | 2 meses |
| **Estados de Cuenta** | 39 | 39 | 78 | 3 meses |
| **TOTAL** | **135** | **135** | **273** | - |

---

## 📁 Estructura de Carpetas

```
output/
├── pdfs/                          # 13 Constancias SAT
├── imagenes/                      # 13 Imágenes de CSF
├── metadatos_constancias.csv      # Metadatos tabulares
├── metadatos_constancias.json     # Metadatos jerárquicos
│
├── recibos_nomina/
│   ├── pdfs/                      # 18 recibos (6 personas x 3 meses)
│   └── imagenes/                  # 18 imágenes
│
├── recibos_agua/
│   ├── pdfs/                      # 39 recibos (13 entidades x 3 meses)
│   └── imagenes/                  # 39 imágenes
│
├── recibos_luz/
│   ├── pdfs/                      # 26 recibos (13 entidades x 2 meses)
│   └── imagenes/                  # 26 imágenes
│
└── estados_cuenta/
    ├── pdfs/                      # 39 estados (13 entidades x 3 meses)
    └── imagenes/                  # 39 imágenes
```

---

## 📄 Tipos de Documentos

### 1. Constancias de Situación Fiscal (SAT)

**Descripción:** Documentos oficiales del SAT que certifican la situación tributaria de contribuyentes.

**Características:**
- ✅ Diseño oficial del SAT
- ✅ Código QR con datos verificables
- ✅ RFCs y CURPs válidos en formato
- ✅ 5 regímenes fiscales diferentes
- ✅ 12 estados de México

**Contenido:**
- RFC y CURP (cuando aplica)
- Nombre completo / Razón social
- Domicilio fiscal completo
- Régimen fiscal
- Obligaciones fiscales
- Estatus en el padrón

**Archivos:** 13 PDFs + 13 imágenes + 2 metadatos

**Nomenclatura:** `CSF_##_RFC_YYYYMM.pdf`

**Entidades:** Todas (7 PM + 6 PF)

---

### 2. Recibos de Nómina

**Descripción:** Comprobantes de pago de salarios y prestaciones.

**Características:**
- ✅ Formato empresarial profesional
- ✅ Percepciones detalladas
- ✅ Deducciones (ISR, IMSS, INFONAVIT)
- ✅ Cálculos realistas
- ✅ 3 meses de historial

**Contenido:**
- Datos del empleado (RFC, CURP, puesto)
- Sueldo base y prestaciones
- Vales de despensa
- Fondo de ahorro
- Deducciones fiscales
- Neto a pagar

**Archivos:** 18 PDFs + 18 imágenes

**Nomenclatura:** `NOMINA_###_RFC_YYYYMM.pdf`

**Entidades:** Solo Personas Físicas (6)

**Periodos:** Octubre, Septiembre, Agosto 2025

---

### 3. Recibos de Agua (COMAPA)

**Descripción:** Recibos de consumo de agua potable y alcantarillado.

**Características:**
- ✅ Diseño oficial COMAPA
- ✅ Consumo en m³
- ✅ Tarifas variables por consumo
- ✅ Cargo fijo + alcantarillado
- ✅ IVA incluido

**Contenido:**
- Número de servicio
- Consumo mensual en m³
- Detalle de cargos
- Alcantarillado y saneamiento
- Total a pagar
- Formas de pago

**Archivos:** 39 PDFs + 39 imágenes

**Nomenclatura:** `AGUA_###_RFC_YYYYMM.pdf`

**Entidades:** Todas (13)

**Periodos:** Octubre, Septiembre, Agosto 2025

---

### 4. Recibos de Luz (CFE)

**Descripción:** Recibos de consumo de energía eléctrica.

**Características:**
- ✅ Diseño oficial CFE
- ✅ Consumo en kWh
- ✅ Tarifas DAC y domésticas
- ✅ Historial de consumo
- ✅ Periodo bimestral

**Contenido:**
- Número de servicio CFE
- RMU (Registro de Medidor Único)
- Consumo en kWh
- Tarifa aplicada (1C, DAC)
- Historial 6 meses
- Total a pagar

**Archivos:** 26 PDFs + 26 imágenes

**Nomenclatura:** `LUZ_###_RFC_YYYYMM.pdf`

**Entidades:** Todas (13)

**Periodos:** Octubre, Septiembre 2025 (bimestral)

---

### 5. Estados de Cuenta Bancarios

**Descripción:** Estados de cuenta con movimientos y saldos mensuales.

**Características:**
- ✅ Diseño bancario profesional
- ✅ Saldos inicial y final
- ✅ Movimientos detallados
- ✅ Tipos de transacciones variadas
- ✅ Cálculos realistas

**Contenido:**
- Datos del titular
- Número de cuenta (parcial)
- CLABE interbancaria
- Saldo inicial y final
- Movimientos del periodo
- Cargos y abonos

**Archivos:** 39 PDFs + 39 imágenes

**Nomenclatura:** `EDO_CTA_###_RFC_YYYYMM.pdf`

**Entidades:** Todas (13)

**Periodos:** Octubre, Septiembre, Agosto 2025

---

## 👥 Entidades del Dataset

### Personas Morales (7)

1. **TECNOLOGÍA AVANZADA DEL SURESTE SA DE CV** - Yucatán
2. **COMERCIALIZADORA DE ALIMENTOS DEL NORTE SA DE CV** - Nuevo León
3. **CONSTRUCTORA INDUSTRIAL BAJÍO SA DE CV** - Guanajuato
4. **SERVICIOS LOGÍSTICOS DEL PACÍFICO SA DE CV** - Sinaloa
5. **DESARROLLOS INMOBILIARIOS CANCÚN SA DE CV** - Quintana Roo
6. **MANUFACTURAS TEXTILES DE OCCIDENTE SA DE CV** - Jalisco
7. **EXPORTADORA AGRÍCOLA DE SONORA SA DE CV** - Sonora

### Personas Físicas (6)

1. **MARÍA GUADALUPE HERNÁNDEZ SÁNCHEZ** - Jalisco
2. **JOSÉ ROBERTO GARCÍA LÓPEZ** - Ciudad de México
3. **ANA PATRICIA MARTÍNEZ RODRÍGUEZ** - Puebla
4. **CARLOS EDUARDO RAMÍREZ FERNÁNDEZ** - Querétaro
5. **LAURA ISABEL TORRES MENDOZA** - Veracruz
6. **FERNANDO JAVIER LÓPEZ CASTILLO** - San Luis Potosí

---

## 📍 Cobertura Geográfica

**12 Estados de México:**
- Jalisco (2 entidades)
- Yucatán, Nuevo León, Ciudad de México, Guanajuato, Puebla, Sinaloa, Querétaro, Quintana Roo, Veracruz, San Luis Potosí, Sonora (1 c/u)

---

## 🎯 Casos de Uso para Cortex Search

### 1. Búsqueda por Entidad
```sql
-- Todos los documentos de una persona/empresa
SELECT * FROM DOCUMENTOS WHERE RFC = 'HESM850614J39';

-- Resultado: CSF + 3 nóminas + 3 recibos agua + 2 luz + 3 estados cuenta
```

### 2. Búsqueda por Tipo de Documento
```sql
-- Todos los recibos de luz
SELECT * FROM DOCUMENTOS WHERE TIPO_DOCUMENTO = 'CFE';

-- Todos los estados de cuenta con saldo > 100K
SELECT * FROM ESTADOS_CUENTA WHERE SALDO_FINAL > 100000;
```

### 3. Búsqueda Temporal
```sql
-- Documentos de octubre 2025
SELECT * FROM DOCUMENTOS WHERE PERIODO = '202510';

-- Tendencia de consumo de agua
SELECT RFC, PERIODO, CONSUMO_M3 
FROM RECIBOS_AGUA 
ORDER BY RFC, PERIODO;
```

### 4. Búsqueda Geográfica
```sql
-- Todas las entidades en Jalisco
SELECT * FROM DOCUMENTOS WHERE ESTADO = 'Jalisco';
```

### 5. Búsqueda Semántica con Cortex AI
```sql
-- Lenguaje natural
SELECT CORTEX_SEARCH(
  'documentos_index',
  'empresas de tecnología con consumo alto de electricidad'
);

-- Clasificación automática
SELECT 
  NOMBRE_ARCHIVO,
  SNOWFLAKE.CORTEX.CLASSIFY_TEXT(
    TEXTO_EXTRAIDO,
    ['Fiscal', 'Nómina', 'Servicios', 'Bancario']
  ) AS CATEGORIA
FROM DOCUMENTOS;
```

### 6. Análisis de Consumo
```sql
-- Comparativa de consumo eléctrico
SELECT 
  RFC,
  NOMBRE_CONTRIBUYENTE,
  AVG(CONSUMO_KWH) AS PROMEDIO_KWH,
  MAX(TOTAL_PAGAR) AS MAXIMO_PAGO
FROM RECIBOS_LUZ
GROUP BY RFC, NOMBRE_CONTRIBUYENTE
ORDER BY PROMEDIO_KWH DESC;
```

### 7. Validación Cruzada
```sql
-- Verificar consistencia de dirección entre documentos
SELECT 
  c.RFC,
  c.NOMBRE_CONTRIBUYENTE,
  c.DOMICILIO AS DOM_CSF,
  r.DOMICILIO AS DOM_AGUA
FROM CONSTANCIAS_FISCALES c
JOIN RECIBOS_AGUA r ON c.RFC = r.RFC
WHERE c.DOMICILIO != r.DOMICILIO;
```

---

## 🛠️ Scripts Disponibles

### Generadores

| Script | Genera | Documentos |
|--------|--------|------------|
| `generar_constancias_sat.py` | Constancias SAT | 13 |
| `generar_recibos_servicios.py` | Nómina, Agua, Luz, Edo Cuenta | 122 |
| `generar_metadatos_csv.py` | Metadatos CSV/JSON | 2 |

### Configuración Snowflake

| Script | Propósito |
|--------|-----------|
| `setup_cortex_search.sql` | Setup completo (DB, tablas, stage) |
| `ejemplos_consultas.sql` | 50+ queries de ejemplo |

### Utilidades

| Script | Función |
|--------|---------|
| `validar_archivos.py` | Validación de integridad |
| `requirements.txt` | Dependencias Python |

---

## 🚀 Inicio Rápido

### 1. Generar Documentos

```bash
# Instalar dependencias
pip3 install -r requirements.txt

# Generar constancias SAT
python3 generar_constancias_sat.py

# Generar recibos y estados de cuenta
python3 generar_recibos_servicios.py

# Generar metadatos
python3 generar_metadatos_csv.py

# Validar
python3 validar_archivos.py
```

### 2. Cargar a Snowflake

```sql
-- 1. Ejecutar setup
@setup_cortex_search.sql

-- 2. Cargar PDFs
PUT file:///path/to/output/**/*.pdf @STAGE_NAME AUTO_COMPRESS=FALSE;

-- 3. Probar búsquedas
@ejemplos_consultas.sql
```

### 3. Configurar Cortex Search

```sql
-- Crear servicio de búsqueda
CREATE CORTEX SEARCH SERVICE DOCUMENTOS_SEARCH
ON TEXTO_EXTRAIDO
WAREHOUSE = WH_NAME
AS (
  SELECT ID, RFC, TIPO_DOCUMENTO, TEXTO_EXTRAIDO, METADATA
  FROM DOCUMENTOS
);

-- Probar búsqueda
SELECT * FROM CORTEX_SEARCH(
  'DOCUMENTOS_SEARCH',
  'recibos de luz en octubre'
);
```

---

## 📊 Estadísticas del Dataset

### Por Tipo de Documento
- Constancias SAT: 5% (13)
- Recibos Nómina: 13% (18)
- Recibos Agua: 29% (39)
- Recibos Luz: 19% (26)
- Estados de Cuenta: 29% (39)
- Metadatos: 1% (2)

### Por Entidad
- Cada Persona Física: ~21 documentos
- Cada Persona Moral: ~21 documentos

### Por Periodo
- Agosto 2025: ~70 documentos
- Septiembre 2025: ~70 documentos
- Octubre 2025: ~70 documentos
- Únicos (CSF): 13 documentos

### Tamaños
- PDFs totales: ~4.0 MB
- Imágenes totales: ~2.5 MB
- Total: ~6.5 MB

---

## ⚙️ Personalización

### Agregar Más Entidades

Editar `CONTRIBUYENTES` en:
- `generar_constancias_sat.py`
- `generar_recibos_servicios.py`

### Agregar Más Meses

Modificar `periodos` en `generar_recibos_servicios.py`:

```python
periodos = []
for i in range(6):  # 6 meses en lugar de 3
    fecha = hoy - timedelta(days=30 * i)
    periodos.append({...})
```

### Agregar Más Tipos de Documentos

Crear nuevas funciones siguiendo el patrón:

```python
def crear_nuevo_documento(entidad, periodo, numero):
    # Tu lógica aquí
    pass
```

---

## 📖 Documentación Adicional

- `README.md` - Documentación de constancias SAT
- `GUIA_RAPIDA.md` - Inicio rápido (3 pasos)
- `RESUMEN_EJECUTIVO.md` - Overview ejecutivo
- Este archivo - Dataset completo

---

## 🔍 Búsquedas de Ejemplo

### Básicas
```sql
-- Por RFC
WHERE RFC = 'TAS180523KL8'

-- Por tipo
WHERE TIPO_DOCUMENTO IN ('NOMINA', 'AGUA', 'LUZ')

-- Por periodo
WHERE PERIODO = '202510'

-- Por monto
WHERE TOTAL > 5000
```

### Avanzadas
```sql
-- Consumo promedio por estado
SELECT ESTADO, AVG(CONSUMO_KWH)
FROM RECIBOS_LUZ l
JOIN CONSTANCIAS_FISCALES c ON l.RFC = c.RFC
GROUP BY ESTADO;

-- Documentos completos por persona
SELECT 
  RFC,
  COUNT(DISTINCT TIPO_DOCUMENTO) AS TIPOS_DOC,
  COUNT(*) AS TOTAL_DOCS
FROM DOCUMENTOS
GROUP BY RFC
HAVING COUNT(DISTINCT TIPO_DOCUMENTO) >= 4;
```

### Con Cortex AI
```sql
-- Resumen inteligente
SELECT 
  RFC,
  SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large',
    'Resume el perfil financiero de: ' || DATOS_COMPLETOS
  ) AS RESUMEN
FROM VISTA_CONSOLIDADA;

-- Extracción de montos
SELECT 
  NOMBRE_ARCHIVO,
  SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
    TEXTO_EXTRAIDO,
    'What is the total amount to pay?'
  ) AS MONTO_EXTRAIDO
FROM DOCUMENTOS;
```

---

## ⚠️ Avisos Importantes

### Validez Legal
- ❌ **NO** tienen validez oficial
- ❌ **NO** usar para trámites reales
- ❌ **NO** representan documentos del SAT, CFE, COMAPA o bancos
- ✅ Solo para desarrollo y pruebas

### Datos Sintéticos
- RFCs: Formato válido pero ficticios
- CURPs: Formato válido pero ficticios
- Nombres: Ficticios
- Direcciones: Ficticias
- Montos: Aleatorios realistas

### Privacidad
- No contienen datos reales de personas
- No hay información personal real
- Seguro para compartir en entornos de desarrollo

---

## 🤝 Soporte

### Regenerar Todo

```bash
python3 generar_constancias_sat.py
python3 generar_recibos_servicios.py
python3 generar_metadatos_csv.py
python3 validar_archivos.py
```

### Limpiar

```bash
rm -rf output/
```

### Problemas Comunes

**Error: pdf2image no funciona**
```bash
# macOS
brew install poppler

# Linux
sudo apt-get install poppler-utils
```

**Error: Falta dependencia**
```bash
pip3 install -r requirements.txt
```

---

## 📞 Recursos

- [Cortex Search Docs](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search)
- [Cortex AI Functions](https://docs.snowflake.com/en/user-guide/snowflake-cortex/llm-functions)
- [Document AI](https://docs.snowflake.com/en/user-guide/snowflake-cortex/document-ai)

---

**Cliente:** Unstructured Docs  
**Versión:** 2.0  
**Fecha:** Octubre 2025  
**Dataset:** 273 archivos | 13 entidades | 5 tipos | 3 meses

✨ **Listo para Cortex Search en Snowflake** ✨



