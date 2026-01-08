# 💰 AgilCredit Intelligence Costs Dashboard

Dashboard interactivo de Streamlit para monitorear costos de Snowflake Intelligence Services en tiempo real.

## 🎯 Características

### 📊 Métricas Monitoreadas

- **Cortex Analyst**: Requests y créditos consumidos por queries de IA
- **Cortex Search**: Costos de indexación y búsqueda semántica
- **AI Services**: Uso general de servicios de IA (COMPLETE, SENTIMENT, etc.)
- **Warehouse**: Créditos de compute y cloud services
- **Vista Consolidada**: Rollup completo de todos los componentes

### 🎨 Visualizaciones

- Gráficos de tendencia temporal
- Distribución por componente (pie charts)
- Análisis por usuario
- Proyecciones mensuales/anuales
- Comparativas y benchmarks

### ⚙️ Funcionalidades

- ✅ Configuración persistente de credenciales
- ✅ Filtros por fecha, usuario y warehouse
- ✅ Cálculo de costos en USD configurable
- ✅ Exportación de datos a CSV
- ✅ Cache de datos para performance
- ✅ Actualización en tiempo real

---

## 🚀 Instalación y Uso

### 1. Instalar Dependencias

```bash
pip install -r requirements_dashboard.txt
```

O instalar individualmente:

```bash
pip install streamlit pandas plotly snowflake-snowpark-python
```

### 2. Ejecutar el Dashboard

```bash
streamlit run agilcredit_intelligence_costs_dashboard.py
```

La aplicación se abrirá automáticamente en tu navegador en `http://localhost:8501`

### 3. Configurar Conexión

En la barra lateral, ingresa:

- **Account**: Tu cuenta de Snowflake (ej: `abc12345.us-east-1`)
- **Usuario**: Tu usuario de Snowflake
- **Password**: Tu contraseña
- **Role**: `ACCOUNTADMIN` (o rol con acceso a `SNOWFLAKE.ACCOUNT_USAGE`)
- **Warehouse**: `AGILCREDIT_WH` (o tu warehouse)

💡 **Tip**: Haz clic en "Guardar Configuración" para no tener que ingresar estos datos cada vez (no se guarda el password por seguridad).

---

## 📋 Requisitos Previos

### Permisos en Snowflake

Tu rol debe tener acceso a las siguientes vistas:

```sql
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE ACCOUNTADMIN;

-- O específicamente:
GRANT USAGE ON SCHEMA SNOWFLAKE.ACCOUNT_USAGE TO ROLE ACCOUNTADMIN;

-- Vistas requeridas:
-- SNOWFLAKE.ACCOUNT_USAGE.CORTEX_ANALYST_USAGE_HISTORY
-- SNOWFLAKE.ACCOUNT_USAGE.METERING_DAILY_HISTORY
-- SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
-- SNOWFLAKE.ACCOUNT_USAGE.CORTEX_SEARCH_SERVING_USAGE_HISTORY
-- SNOWFLAKE.ACCOUNT_USAGE.CORTEX_SEARCH_DAILY_USAGE_HISTORY
```

### Warehouse Activo

Asegúrate de tener un warehouse activo y con créditos disponibles.

---

## 📊 Secciones del Dashboard

### 1️⃣ Overview (Tab 1)

**Contenido:**
- KPIs principales de todos los servicios
- Gráfico de área apilada con tendencia temporal
- Distribución de costos por componente (pie chart)
- Tabla resumen con porcentajes

**Métricas Clave:**
- Total de créditos por servicio
- Costo total en USD
- Distribución porcentual

### 2️⃣ Cortex Analyst (Tab 2)

**Contenido:**
- Total de requests procesados
- Créditos consumidos
- Promedio de créditos por request
- Análisis por usuario
- Tendencia diaria de uso

**Útil Para:**
- Identificar usuarios con mayor consumo
- Detectar picos de uso anormales
- Optimizar queries costosas

### 3️⃣ Cortex Search (Tab 3)

**Contenido:**
- Créditos de indexación y búsqueda
- Análisis por servicio de búsqueda
- Tendencia temporal
- Costo estimado en USD

**Útil Para:**
- Monitorear servicios de búsqueda semántica
- Identificar servicios con alto consumo
- Planificar optimizaciones de índices

### 4️⃣ Warehouse (Tab 4)

**Contenido:**
- Créditos de compute vs cloud services
- Tendencia diaria de consumo
- Estadísticas (promedio, máximo, mínimo)
- Distribución por tipo de crédito

**Útil Para:**
- Identificar warehouses costosos
- Analizar balance compute/cloud
- Detectar uso ineficiente

### 5️⃣ Consolidado (Tab 5)

**Contenido:**
- Tabla resumen de todos los componentes
- Proyecciones mensuales, trimestrales y anuales
- Exportación de datos a CSV

**Útil Para:**
- Reporting ejecutivo
- Planificación de presupuesto
- Análisis de tendencias a largo plazo

---

## ⚡ Optimización y Performance

### Cache de Datos

El dashboard usa cache de Streamlit (`@st.cache_data`) con TTL de 5 minutos:
- Reduce carga en Snowflake
- Mejora velocidad de carga
- Refresca automáticamente

### Filtros Disponibles

**Parámetros Configurables:**
- 📅 **Días de histórico**: 7 a 90 días
- 💵 **Costo por crédito**: $0 - $10 USD (default: $2)
- 👤 **Usuario**: Filtrar por usuario específico
- 🏢 **Warehouse**: Filtrar por warehouse

---

## 📥 Exportación de Datos

En la pestaña "Consolidado", puedes descargar un CSV con:
- Fecha
- Componente (Analyst, Search, Warehouse)
- Créditos consumidos
- Total diario

**Nombre del archivo:** `agilcredit_intelligence_costs_YYYYMMDD.csv`

---

## 🔧 Configuración Avanzada

### Archivo de Configuración

El dashboard guarda tu configuración (excepto password) en:
```
snowflake_config.json
```

**Contenido:**
```json
{
  "account": "abc12345.us-east-1",
  "user": "mi_usuario",
  "role": "ACCOUNTADMIN",
  "warehouse": "AGILCREDIT_WH"
}
```

### Variables de Entorno (Opcional)

Puedes usar variables de entorno para credenciales:

```bash
export SNOWFLAKE_ACCOUNT="abc12345.us-east-1"
export SNOWFLAKE_USER="mi_usuario"
export SNOWFLAKE_PASSWORD="mi_password"
export SNOWFLAKE_ROLE="ACCOUNTADMIN"
export SNOWFLAKE_WAREHOUSE="AGILCREDIT_WH"
```

---

## 🎨 Personalización

### Modificar Costo por Crédito

Por defecto, el dashboard usa **$2 USD por crédito**. Ajusta este valor en la barra lateral según tu contrato con Snowflake.

### Cambiar Periodo de Análisis

Ajusta el slider "Días de histórico" para ver más o menos datos históricos (7-90 días).

### Añadir Filtros Adicionales

Edita el archivo `agilcredit_intelligence_costs_dashboard.py` para añadir:
- Filtros por database/schema
- Alertas de umbral
- Comparativas periodo vs periodo

---

## 🐛 Troubleshooting

### Error: "No se puede conectar a Snowflake"

**Solución:**
1. Verifica tus credenciales
2. Confirma que el account name es correcto
3. Asegúrate de tener internet

### Error: "No hay datos disponibles"

**Posibles Causas:**
- El rol no tiene acceso a `SNOWFLAKE.ACCOUNT_USAGE`
- No hay uso registrado en el periodo seleccionado
- El warehouse no coincide con el nombre filtrado

**Solución:**
```sql
-- Verificar acceso
SHOW GRANTS TO ROLE ACCOUNTADMIN;

-- Verificar datos
SELECT COUNT(*) FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_ANALYST_USAGE_HISTORY
WHERE START_TIME >= DATEADD(day, -30, CURRENT_DATE());
```

### Error: "Cache no funciona"

**Solución:**
```bash
# Limpiar cache de Streamlit
streamlit cache clear
```

---

## 📈 Casos de Uso

### 1. Monitoreo Diario de Costos

Abre el dashboard cada mañana para revisar el consumo del día anterior y detectar anomalías.

### 2. Optimización de Queries

Identifica usuarios o servicios con alto consumo de Cortex Analyst y revisa sus queries para optimizar.

### 3. Reportes Ejecutivos

Usa la pestaña "Consolidado" para generar reportes mensuales de costos y proyecciones.

### 4. Alertas de Presupuesto

Configura el costo por crédito según tu presupuesto y monitorea si te acercas al límite.

### 5. Análisis de ROI

Compara costos de Intelligence vs beneficios (reducción de tiempo de análisis, mejor toma de decisiones).

---

## 🔄 Actualizaciones Futuras

**En el roadmap:**
- [ ] Alertas automáticas por email
- [ ] Comparativa mes a mes
- [ ] Exportación a Excel con gráficos
- [ ] Integración con Slack/Teams
- [ ] Predicciones con ML
- [ ] Multi-cuenta support

---

## 📞 Soporte

Para preguntas o issues:
- Email: data-engineering@agilcredit.mx
- Documentación: [Snowflake Intelligence Docs](https://docs.snowflake.com/en/user-guide/snowflake-cortex)

---

## 📄 Licencia

© 2025 AgilCredit SOFOM E.N.R. - Uso interno.

---

**¡Feliz monitoreo de costos! 💰📊**



