# 🔍 Detección de Anomalías en Ventas Retail - Grupo Comercial Control

## 📋 Descripción del Proyecto

Este proyecto implementa un sistema completo de **detección de anomalías en series de tiempo múltiples** para **Grupo Comercial Control (C Control)**, una empresa mexicana líder en retail con más de 60 años de experiencia.

**Cliente**: [C Control / Grupo Comercial DSW](https://www.ccontrol.com.mx/)

**Tecnología**: Snowflake SQL - Función nativa `ANOMALY_DETECTION()`

**Rol**: Científico de Datos

---

## 🏢 Contexto del Cliente

**Grupo Comercial Control** opera tres marcas principales:

| Marca | Descripción | Desde |
|-------|-------------|-------|
| 🏬 **Del Sol** | Tienda departamental tradicional | 1963 |
| 🛍️ **Woolworth** | Tienda de variedad y productos del hogar | 1997 |
| 🥩 **Noreste Grill** | Restaurantes de carne asada | 2008 |

**Presencia**: +130 sucursales en 26 estados de la República Mexicana

---

## 🎯 Objetivo del Proyecto

Detectar **anomalías en ventas diarias y ticket promedio** para:

✅ Identificar caídas inesperadas de ventas causadas por eventos adversos  
✅ Detectar patrones anormales en el comportamiento del ticket promedio  
✅ Anticipar problemas operacionales (desabasto, problemas logísticos)  
✅ Optimizar respuesta ante eventos climáticos o de mercado  

---

## 📊 Dataset Sintético

### Características del Dataset

- **Periodo**: Último año (365 días)
- **Granularidad**: Diaria
- **Total de registros**: 3,285 (365 días × 9 sucursales)
- **Series de tiempo**: Multi-series con 3 dimensiones:
  - **Región**: Norte, Centro, Sur
  - **Tipo de tienda**: Del Sol, Woolworth, Noreste Grill
  - **Sucursal**: 9 sucursales específicas

### Variables Principales

| Variable | Descripción | Tipo |
|----------|-------------|------|
| `FECHA` | Fecha de la venta | Date |
| `VENTAS_TOTALES` | Ventas del día en MXN | Numeric |
| `TICKET_PROMEDIO` | Ticket promedio de compra | Numeric |
| `NUM_TRANSACCIONES` | Número de transacciones | Integer |
| `NUM_CLIENTES` | Número de clientes | Integer |

### Variables Exógenas

#### 🌡️ Clima
- `TEMPERATURA_C`: Temperatura en grados Celsius
- `PRECIPITACION_MM`: Precipitación en milímetros

#### 📅 Eventos
- `ES_DIA_FESTIVO`: Días festivos mexicanos
- `ES_QUINCENA`: Días 15 y 30 del mes
- `ES_FIN_SEMANA`: Sábados y domingos
- `HAY_PROMOCION`: Promociones activas
- `EVENTO_ADVERSO`: Contingencias ambientales, problemas logísticos

---

## 🚨 Anomalías Sintéticas Incluidas

### 1. Caídas de Ventas (-30% a -50%)

**Causas modeladas**:
- ⚠️ Contingencias ambientales / Cortes de luz (2% probabilidad, -50% ventas)
- ⚠️ Problemas logísticos / Desabasto (5% probabilidad, -30% ventas)
- 🌧️ Precipitación extrema (>30mm, -30% ventas)
- 🌡️ Temperaturas extremas (<10°C o >35°C, -10-15% ventas)

### 2. Ticket Promedio Anormal (-25% a -40%)

**Causas modeladas**:
- 🏷️ Liquidaciones no planificadas (3% días, -40% ticket)
- 💰 Promociones agresivas (5% días, -25% ticket)

---

## 🚀 Instrucciones de Uso

### Paso 1: Configuración Inicial

```sql
-- Conectarse a Snowflake con rol SYSADMIN
USE ROLE SYSADMIN;

-- Ejecutar todo el script
-- El script creará automáticamente:
-- ✅ Warehouse CCONTROL_WH (XSMALL, auto-suspend 60s)
-- ✅ Database CCONTROL_DB
-- ✅ Schema CCONTROL_SCHEMA
-- ✅ Tablas: SUCURSALES, VENTAS_DIARIAS
-- ✅ Vista: VW_VENTAS_MULTISERIES
```

### Paso 2: Ejecutar Detección de Anomalías

#### Modelo 1: Anomalías en Ventas Totales

```sql
SELECT 
    FECHA,
    TIPO_TIENDA,
    REGION,
    NOMBRE_SUCURSAL,
    VENTAS_TOTALES,
    
    ANOMALY_DETECTION(
        VENTAS_TOTALES, 
        TIPO_TIENDA, 
        REGION
    ) OVER (
        PARTITION BY TIPO_TIENDA, REGION
        ORDER BY FECHA
    ) AS SCORE_ANOMALIA
    
FROM CCONTROL_SCHEMA.VW_VENTAS_MULTISERIES
WHERE FECHA >= DATEADD(DAY, -365, CURRENT_DATE())
ORDER BY SCORE_ANOMALIA ASC;
```

#### Modelo 2: Anomalías en Ticket Promedio

```sql
SELECT 
    FECHA,
    TIPO_TIENDA,
    REGION,
    TICKET_PROMEDIO,
    
    ANOMALY_DETECTION(
        TICKET_PROMEDIO,
        TIPO_TIENDA,
        REGION
    ) OVER (
        PARTITION BY TIPO_TIENDA, REGION
        ORDER BY FECHA
    ) AS SCORE_ANOMALIA
    
FROM CCONTROL_SCHEMA.VW_VENTAS_MULTISERIES
ORDER BY SCORE_ANOMALIA ASC;
```

### Paso 3: Análisis de Resultados

La query de la **Sección 3.4** del script SQL genera un reporte completo:

- 🔴 **ANOMALÍA CRÍTICA**: Score < -2
- 🟠 **ANOMALÍA MODERADA**: Score < -1.5
- 🟢 **PICO EXCEPCIONAL**: Score > 2
- ⚪ **NORMAL**: Score entre -1.5 y 2

---

## 📈 Interpretación de Resultados

### Score de Anomalía

El score de anomalía representa cuántas desviaciones estándar se aleja el valor observado del comportamiento esperado:

| Score | Interpretación | Acción Recomendada |
|-------|----------------|-------------------|
| < -2.5 | Anomalía crítica | 🚨 Investigación inmediata |
| -2.5 a -1.5 | Anomalía moderada | ⚠️ Monitoreo cercano |
| -1.5 a 1.5 | Comportamiento normal | ✅ No requiere acción |
| > 2.0 | Pico excepcional | 📊 Analizar causa positiva |

### Ejemplo de Interpretación

```
FECHA: 2024-08-15
TIPO_TIENDA: Del Sol
REGIÓN: Norte
VENTAS_TOTALES: $45,000 (esperado: $85,000)
SCORE_ANOMALIA: -2.8
EVENTO_ADVERSO: Contingencia Ambiental / Corte de Luz
```

**Interpretación**: Caída del 47% en ventas, 2.8 desviaciones estándar por debajo de lo esperado. El evento adverso (corte de luz) explica la anomalía.

---

## 🎨 Modelo Semántico

El archivo `CCONTROL_semantic_model.yaml` define el modelo semántico simplificado para Snowflake.

**Características**:
- ✅ Solo usa `kind: dimension` y `kind: time_dimension`
- ✅ Estructura plana sin wrappers complejos
- ✅ 5 consultas verificadas ultra-simples
- ✅ Compatible con Snowflake Semantic Layer

---

## 💰 FinOps - Gestión de Costos

### Configuración Optimizada

```sql
-- Warehouse configurado para auto-suspensión
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60  -- Se suspende después de 1 minuto de inactividad
AUTO_RESUME = TRUE
```

### Verificación de Costos

```sql
-- Ver parámetros del warehouse
SHOW PARAMETERS LIKE 'STATEMENT_TIMEOUT_IN_SECONDS' IN WAREHOUSE CCONTROL_WH;

-- Ver estado del warehouse
SHOW WAREHOUSES LIKE 'CCONTROL_WH';
```

### Estimación de Créditos

Para este demo (XSMALL warehouse):
- **Ejecución completa del script**: ~0.1 créditos
- **Queries de análisis**: ~0.01-0.05 créditos cada una
- **Costo estimado total**: < $0.20 USD por demo completa

---

## 📊 Queries de Diagnóstico

El script incluye 8 queries de validación en la **Sección 4**:

1. ✅ Conteo de registros por sucursal
2. ✅ Rangos de ventas y ticket promedio
3. ✅ Distribución de variables exógenas (clima)
4. ✅ Conteo de eventos especiales
5. ✅ Eventos adversos registrados
6. ✅ Comparación días normales vs. con eventos
7. ✅ Estado del warehouse
8. ✅ Créditos consumidos (requiere ACCOUNTADMIN)

---

## 🔄 Próximos Pasos

1. **Alertas Automáticas**: Crear Snowflake Tasks para detectar anomalías en tiempo real
2. **Forecasting**: Usar `FORECAST()` para predicción de ventas
3. **Análisis de Causa Raíz**: Correlacionar anomalías con variables exógenas
4. **Dashboard**: Integrar con Tableau/Power BI/Streamlit
5. **ML Avanzado**: Entrenar modelos personalizados con Snowpark ML

---

## 📂 Estructura del Proyecto

```
Anomaly Detection/
│
├── README.md                              # Este archivo
├── CCONTROL_Anomaly_Detection_Demo.sql   # Script SQL completo
└── CCONTROL_semantic_model.yaml          # Modelo semántico Snowflake
```

---

## 🧠 Conceptos Clave

### ¿Qué es la Detección de Anomalías?

La detección de anomalías identifica patrones en datos que no se conforman al comportamiento esperado. En retail, esto incluye:

- **Caídas inesperadas** en ventas
- **Picos anormales** en transacciones
- **Cambios de tendencia** no explicados por estacionalidad

### ¿Por qué Series de Tiempo Múltiples?

Cada sucursal/región tiene su propio patrón de ventas:
- Del Sol en Monterrey ≠ Woolworth en CDMX
- El mismo día puede ser normal en una tienda y anómalo en otra
- Las variables exógenas (clima) afectan diferente a cada región

### ¿Cómo Funciona ANOMALY_DETECTION()?

Snowflake usa algoritmos de ML que:
1. Aprenden el patrón histórico de cada serie
2. Identifican estacionalidad (día de semana, mes, etc.)
3. Calculan bandas de confianza
4. Reportan valores que caen fuera de esas bandas

---

## 🌟 Ventajas de Esta Solución

✅ **Nativa de Snowflake**: No requiere herramientas externas  
✅ **Escalable**: Funciona con millones de registros  
✅ **Multi-series**: Detecta anomalías específicas por segmento  
✅ **Variables exógenas**: Explica variaciones por clima/eventos  
✅ **Costo-eficiente**: Auto-suspend optimiza consumo de créditos  
✅ **SQL puro**: No requiere Python/R, accesible para analistas  

---

## 📞 Contacto

**Cliente**: Grupo Comercial Control  
**Website**: [https://www.ccontrol.com.mx/](https://www.ccontrol.com.mx/)  
**Teléfono CDMX**: 01.555.228.9400  
**Teléfono Monterrey**: 01.818.329.5500  

---

## 📝 Notas Técnicas

### Reglas de Sintaxis Aplicadas

Este código sigue las mejores prácticas de Snowflake:

- ✅ `ROW_NUMBER() OVER (ORDER BY NULL)` en lugar de `SEQ4()`
- ✅ `MOD(x, y)` en lugar de operador `%`
- ✅ `UNIFORM(min, max, RANDOM())` para números aleatorios
- ✅ Referencias completas `SCHEMA.TABLA` en todas las queries
- ✅ `CASE WHEN` en lugar de `FILTER (WHERE ...)`
- ✅ Sin uso de `SELECT *` en JOINs

### Coherencia de Datos

Los rangos de datos sintéticos están cuidadosamente calibrados:

- Ventas base realistas por tipo de tienda
- Factores multiplicativos coherentes (estacionalidad, eventos)
- Anomalías con magnitud y frecuencia realista
- Variables exógenas correlacionadas con región

---

## 🎓 Recursos Adicionales

- [Documentación Snowflake ANOMALY_DETECTION](https://docs.snowflake.com/en/sql-reference/functions/anomaly_detection)
- [Snowflake Time Series Functions](https://docs.snowflake.com/en/sql-reference/functions-time-series)
- [Guía de FinOps en Snowflake](https://docs.snowflake.com/en/user-guide/cost-controlling)

---

**Desarrollado con ❤️ para Grupo Comercial Control**

*Demo de Detección de Anomalías en Retail - Snowflake SQL*

