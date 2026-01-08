# 🏢 URBANOVA - Demo Inmobiliaria

Demo completa de análisis de datos para **URBANOVA**, un desarrollador inmobiliario mexicano con presencia en las principales ciudades del país.

## 📊 Contenido

1. **URBANOVA_demo.sql** - Script completo de Snowflake con datos sintéticos
2. **URBANOVA_semantic_model.yaml** - Modelo semántico para Cortex Analyst
3. **README.md** - Este archivo

---

## 🎯 Casos de Uso Implementados

- ✅ **Análisis de precios por zona** - Benchmarking de precios por m² en diferentes ciudades
- ✅ **Gestión de inventario** - Control de disponibilidad y velocidad de ventas
- ✅ **Proyección de ventas** - Forecast vs reales con análisis de variación
- ✅ **Desempeño comercial** - Evaluación de agentes y métodos de financiamiento
- ✅ **Segmentación de clientes** - Análisis por tipo de cliente y comportamiento

---

## 🚀 Instrucciones de Uso

### 1️⃣ Ejecutar el Script SQL en Snowflake

```sql
-- Copiar y pegar el contenido completo de URBANOVA_demo.sql
-- en la interfaz de Snowflake (Snowsight o Classic UI)

-- El script creará automáticamente:
-- ✓ Warehouse: URBANOVA_WH (XSMALL, auto-suspend 60 seg)
-- ✓ Database: URBANOVA_DB
-- ✓ Schema: URBANOVA_SCHEMA
-- ✓ Roles: URBANOVA_INGENIERO_DATOS, URBANOVA_ANALISTA_NEGOCIO
-- ✓ 8 Tablas principales con datos sintéticos
-- ✓ Consultas de análisis y diagnóstico
```

### 2️⃣ Cargar el Modelo Semántico (Cortex Analyst)

```sql
-- En Snowsight, crear un stage para el modelo semántico
CREATE OR REPLACE STAGE URBANOVA_DB.URBANOVA_SCHEMA.SEMANTIC_MODELS;

-- Subir el archivo URBANOVA_semantic_model.yaml al stage
PUT file:///path/to/URBANOVA_semantic_model.yaml @URBANOVA_DB.URBANOVA_SCHEMA.SEMANTIC_MODELS;

-- Verificar que se subió correctamente
LIST @URBANOVA_DB.URBANOVA_SCHEMA.SEMANTIC_MODELS;
```

### 3️⃣ Usar Cortex Analyst con el Modelo

Una vez cargado el modelo semántico, puedes hacer preguntas en lenguaje natural como:

- "¿Cuántas propiedades disponibles hay en Monterrey?"
- "¿Cuál es el precio promedio por m² en CDMX?"
- "Muéstrame los desarrollos con mayor porcentaje de ventas"
- "¿Cuáles son las propiedades tipo Penthouse disponibles?"
- "¿Cuál es el costo total de construcción de Bosques de Santa Fe?"
- "¿Cómo ha variado la tasa de interés hipotecario en los últimos meses?"
- "¿Qué desarrollos tienen mejor margen de rentabilidad?"

---

## 📍 Datos Incluidos

### Ciudades (6)
- Ciudad de México (CDMX)
- Monterrey, Nuevo León
- Guadalajara, Jalisco
- Querétaro, Querétaro
- Mérida, Yucatán
- Cancún, Quintana Roo

### Desarrollos (12)
Proyectos residenciales, comerciales y mixtos distribuidos en las 6 ciudades principales.

### Propiedades (50+)
- **Tipos**: Departamento, Casa, Townhouse, Penthouse, Terreno, Local Comercial
- **Rangos de precio**: $2.1M - $22M MXN
- **Estatus**: Disponible, Apartado, Vendido, Escriturado

### Ventas Históricas (12)
Transacciones de los últimos 6 meses con diferentes métodos de financiamiento.

### Agentes (8)
Equipo comercial activo distribuido por ciudad.

### Costos de Construcción (54 registros)
Desglose detallado de costos por desarrollo:
- **Tipos de costo**: Terreno, Construcción, Permisos, Marketing, Financiero, Otros
- **Rangos**: $3M - $396M MXN por rubro
- **9 desarrollos** con información completa de costos

### Indicadores de Mercado (18 meses)
Variables macroeconómicas que afectan el sector inmobiliario:
- **Tasas de interés** hipotecario (10.02% - 10.80%)
- **Inflación** anual (4.26% - 5.84%)
- **Tipo de cambio** USD/MXN (16.71 - 19.85)
- **Precios de insumos**: Cemento y acero por tonelada
- **Confianza del consumidor** e indicadores de construcción
- **Créditos hipotecarios** otorgados mensualmente

---

## 💡 Consultas de Análisis Incluidas

El script incluye 14 análisis predefinidos:

1. **Precio promedio por m²** por ciudad y tipo de propiedad
2. **Inventario disponible** por desarrollo con % de venta
3. **Desempeño de ventas** por agente
4. **Análisis de métodos** de financiamiento
5. **Proyecciones vs Reales** - Precisión de forecast
6. **Top 10 propiedades** más caras disponibles
7. **Evolución temporal** de ventas (últimos 6 meses)
8. **Tipo de cliente** y comportamiento de compra
9. **Rentabilidad por desarrollo** - Costos vs Ingresos proyectados con márgenes
10. **Desglose de costos** por tipo y desarrollo
11. **Indicadores macroeconómicos** - Evolución de variables externas
12. **Correlación mercado-ventas** - Impacto de indicadores en ventas
13. **Impacto de costos de insumos** - Variación de precios de materiales
14. **Resumen financiero ejecutivo** - Dashboard de rentabilidad por proyecto

---

## 💰 FinOps - Optimización de Costos

El script incluye configuración optimizada de costos:

- ✅ Warehouse **XSMALL** (suficiente para la demo)
- ✅ Auto-suspend a **60 segundos** de inactividad
- ✅ Auto-resume activado
- ✅ Queries de diagnóstico de uso y costos
- ✅ Verificación de STATEMENT_TIMEOUT

---

## 📈 Métricas Clave del Negocio

| Métrica | Descripción |
|---------|-------------|
| **Precio M² Promedio** | Benchmark por ciudad y tipo |
| **% Vendido por Desarrollo** | Velocidad de ventas |
| **Ticket Promedio** | Por agente y método de pago |
| **Variación Proyección** | Precisión del forecast |
| **Unidades Disponibles** | Inventario actual |
| **Margen Bruto por Desarrollo** | Rentabilidad (Ingresos - Costos) |
| **Costo Total por Desarrollo** | Inversión total del proyecto |
| **Tasa de Interés Hipotecario** | Indicador de financiamiento |
| **Precio de Insumos** | Cemento y acero (impacto en costos) |
| **Índice de Confianza** | Sentimiento del consumidor |

---

## 🛠️ Estructura de Datos

```
URBANOVA_DB
└── URBANOVA_SCHEMA
    ├── CIUDADES
    ├── DESARROLLOS
    ├── PROPIEDADES
    ├── AGENTES
    ├── VENTAS
    ├── PROYECCIONES_VENTAS
    ├── COSTOS_CONSTRUCCION
    └── INDICADORES_MERCADO
```

### Relaciones
- `PROPIEDADES` → `DESARROLLOS` (many-to-one)
- `DESARROLLOS` → `CIUDADES` (many-to-one)
- `VENTAS` → `PROPIEDADES` (many-to-one)
- `AGENTES` → `CIUDADES` (many-to-one)
- `PROYECCIONES_VENTAS` → `DESARROLLOS` (many-to-one)
- `COSTOS_CONSTRUCCION` → `DESARROLLOS` (many-to-one)

---

## 🔍 Validaciones Incluidas

El script incluye queries de diagnóstico para verificar:

1. ✅ Conteo de registros por tabla
2. ✅ Rangos de precios por ciudad
3. ✅ Distribución de estatus de inventario
4. ✅ Integridad referencial (foreign keys)
5. ✅ Configuración de FinOps
6. ✅ Uso del warehouse (últimos 7 días)

---

## 📞 Contacto

**Cliente**: URBANOVA - Desarrollos Inmobiliarios Urbanova S.A. de C.V.  
**Rol**: Ingeniero de Datos  
**Plataforma**: Snowflake SQL  
**Fecha de creación**: Octubre 2024

---

## 🎓 Notas Técnicas

### Sintaxis Snowflake Utilizada
- `ROW_NUMBER() OVER (ORDER BY NULL)` para generación de IDs
- `MOD(x, y)` para operaciones módulo
- `UNIFORM(min, max, RANDOM())` para números aleatorios
- Referencias completas `SCHEMA.TABLA` en todos los JOINs
- `SUM(CASE WHEN ...)` en lugar de `FILTER (WHERE ...)`

### Modelo Semántico
- **Solo dimensiones**: `kind: dimension` y `kind: time_dimension`
- **Sin medidas**: No se usa `kind: measure` para máxima simplicidad
- **Relaciones**: Solo `many_to_one`
- **Consultas verificadas**: 5 consultas ultra-simples validadas
- **Estructura plana**: Sin wrapper `semantic_model` en la raíz

---

## 📄 Licencia

Demo creada para fines educativos y demostración de capacidades de Snowflake.

---

**¡Listo para usar! 🚀**

Ejecuta el script SQL y comienza a analizar datos inmobiliarios de inmediato.

