# Generador de Constancias de Situación Fiscal (SAT México)

## 📋 Descripción

Herramienta para generar constancias de situación fiscal sintéticas del SAT (Servicio de Administración Tributaria de México) con propósitos de **pruebas y capacitación**.

**Cliente:** Unstructured Docs  
**Propósito:** Pruebas de Cortex Search con documentos no estructurados

⚠️ **IMPORTANTE:** Estos documentos son ÚNICAMENTE para pruebas y NO tienen validez oficial ni legal.

## 🎯 Características

- ✅ **13 constancias** con datos sintéticos variados
- ✅ Diseño similar al oficial del SAT mexicano
- ✅ Generación en formato **PDF** e **imágenes PNG**
- ✅ Códigos QR integrados
- ✅ Variedad de escenarios:
  - Personas Físicas y Morales
  - Diferentes regímenes fiscales (601, 612, 626, 605, 621)
  - Múltiples estados de la República Mexicana
  - Diversas obligaciones fiscales

## 📊 Datos Incluidos

Cada constancia contiene:
- RFC y CURP (cuando aplica)
- Nombre completo o razón social
- Domicilio fiscal completo
- Régimen fiscal
- Obligaciones fiscales
- Estatus en el padrón
- Código QR con datos verificables
- Folio único

## 🚀 Instalación

### 1. Instalar dependencias de Python

```bash
pip install -r requirements.txt
```

### 2. (Opcional) Instalar Poppler para conversión a imágenes

**macOS:**
```bash
brew install poppler
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt-get install poppler-utils
```

**Windows:**
- Descargar desde: https://github.com/oschwartz10612/poppler-windows/releases
- Agregar al PATH

> **Nota:** Si no instalas Poppler, el script generará los PDFs correctamente pero mostrará una advertencia al intentar generar las imágenes.

## 📝 Uso

Ejecuta el script principal:

```bash
python generar_constancias_sat.py
```

### Salida

El script generará:
- **13 PDFs** en la carpeta `output/pdfs/`
- **13 imágenes PNG** en la carpeta `output/imagenes/`

Nomenclatura de archivos:
- `CSF_01_TAS180523KL8.pdf`
- `CSF_01_TAS180523KL8.png`

## 📁 Estructura de Archivos

```
Unstructured Documents/
├── generar_constancias_sat.py   # Script principal
├── requirements.txt              # Dependencias de Python
├── README.md                     # Este archivo
└── output/
    ├── pdfs/                     # Constancias en formato PDF
    │   ├── CSF_01_TAS180523KL8.pdf
    │   ├── CSF_02_HESM850614J39.pdf
    │   └── ...
    └── imagenes/                 # Constancias en formato PNG
        ├── CSF_01_TAS180523KL8.png
        ├── CSF_02_HESM850614J39.png
        └── ...
```

## 🎭 Escenarios Incluidos

### Personas Morales (7)
1. **Tecnología Avanzada del Sureste** - Yucatán - Régimen 601
2. **Comercializadora de Alimentos del Norte** - Nuevo León - Régimen 601
3. **Constructora Industrial Bajío** - Guanajuato - Régimen 601
4. **Servicios Logísticos del Pacífico** - Sinaloa - Régimen 601
5. **Desarrollos Inmobiliarios Cancún** - Quintana Roo - Régimen 601
6. **Manufacturas Textiles de Occidente** - Jalisco - Régimen 601
7. **Exportadora Agrícola de Sonora** - Sonora - Régimen 601

### Personas Físicas (6)
1. **María Guadalupe Hernández** - Jalisco - Régimen 612 (Actividad Empresarial)
2. **José Roberto García** - CDMX - Régimen 626 (Simplificado de Confianza)
3. **Ana Patricia Martínez** - Puebla - Régimen 605 (Sueldos y Salarios)
4. **Carlos Eduardo Ramírez** - Querétaro - Régimen 612 (Actividad Profesional)
5. **Laura Isabel Torres** - Veracruz - Régimen 621 (Incorporación Fiscal)
6. **Fernando Javier López** - San Luis Potosí - Régimen 626 (RESICO)

## 🔍 Uso con Cortex Search

Estos documentos están diseñados para probar:

1. **OCR y extracción de texto** de documentos PDF
2. **Búsqueda semántica** de información fiscal
3. **Clasificación** de tipos de contribuyentes
4. **Extracción de entidades** (RFC, nombres, direcciones)
5. **Validación** de formato de documentos oficiales

### Ejemplo de carga a Snowflake:

```sql
-- Crear stage para documentos
CREATE OR REPLACE STAGE UNSTRUCTURED_DOCS_STAGE;

-- Cargar PDFs
PUT file:///ruta/a/output/pdfs/*.pdf @UNSTRUCTURED_DOCS_STAGE;

-- Crear tabla para metadatos
CREATE OR REPLACE TABLE CONSTANCIAS_SAT (
    NOMBRE_ARCHIVO VARCHAR,
    RFC VARCHAR,
    NOMBRE_CONTRIBUYENTE VARCHAR,
    TIPO_PERSONA VARCHAR,
    REGIMEN_FISCAL VARCHAR,
    ESTADO VARCHAR,
    ARCHIVO_PDF BINARY
);
```

## ⚙️ Personalización

Para modificar los datos sintéticos, edita la lista `CONTRIBUYENTES` en el archivo `generar_constancias_sat.py`.

Cada contribuyente puede tener:
- `tipo`: "Persona Física" o "Persona Moral"
- `nombre`: Nombre completo o razón social
- `rfc`: Registro Federal de Contribuyentes
- `curp`: CURP (solo personas físicas)
- `regimen`: Código y descripción del régimen fiscal
- `estado`, `municipio`, `colonia`, `calle`: Datos de domicilio
- `correo`: Correo electrónico
- `fecha_inicio`: Fecha de inicio de operaciones

## 🛠️ Dependencias

- **reportlab** (4.0.7): Generación de PDFs
- **Pillow** (10.1.0): Manipulación de imágenes
- **PyPDF2** (3.0.1): Lectura de PDFs
- **python-barcode** (0.15.1): Generación de códigos de barras
- **qrcode** (7.4.2): Generación de códigos QR
- **pdf2image**: Conversión PDF a imagen (requiere Poppler)

## 📞 Soporte

Para preguntas o problemas:
- Revisar que todas las dependencias estén instaladas
- Verificar permisos de escritura en las carpetas de salida
- Confirmar versión de Python >= 3.8

## ⚖️ Aviso Legal

Estos documentos son **simulaciones sintéticas** creadas exclusivamente para:
- Entrenamiento de modelos de IA
- Pruebas de software
- Desarrollo de aplicaciones
- Capacitación

**NO deben usarse para:**
- Trámites fiscales reales
- Representación ante autoridades
- Suplantación de identidad
- Fraude fiscal

Los datos (RFC, CURP, nombres, direcciones) son **ficticios** y cualquier similitud con personas o empresas reales es **coincidencia**.

---

**Generado para:** Unstructured Docs  
**Fecha:** Octubre 2025  
**Versión:** 1.0



