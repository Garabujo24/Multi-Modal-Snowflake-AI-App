# 🛡️ Seguros Centinela - Dataset de Aseguradora Ficticia

**Seguros Centinela S.A. de C.V.** es una aseguradora mexicana ficticia creada para demos y pruebas de concepto. Este repositorio contiene:

- 📊 **Estructura de base de datos** para Snowflake
- 📄 **80 pólizas en PDF** (40 de Auto + 40 de GMM)
- 🔍 **Vistas semánticas** para análisis de datos

---

## 📁 Estructura del Proyecto

```
Insurance/
├── sql/
│   ├── CENTINELA_estructura_tablas.sql        # DDL de todas las tablas
│   ├── CENTINELA_datos_sinteticos.sql         # Datos de agentes y clientes
│   ├── CENTINELA_datos_sinteticos_parte2.sql  # Vehículos y pólizas AUTO
│   ├── CENTINELA_datos_sinteticos_parte3.sql  # Planes y pólizas GMM
│   ├── CENTINELA_vistas_semanticas.sql        # Vistas para análisis
│   └── CENTINELA_registrar_modelo_semantico.sql # Registro del modelo
├── semantic_model/
│   └── centinela_semantic_model.yaml          # Modelo semántico para Cortex
├── scripts/
│   └── generar_polizas_pdf.py                 # Generador de PDFs
├── polizas/
│   ├── autos/                                 # 40 pólizas de auto en PDF
│   └── gmm/                                   # 40 pólizas GMM en PDF
├── requirements.txt
└── README.md
```

---

## 🗄️ Modelo de Datos

### Schemas

| Schema | Descripción |
|--------|-------------|
| `CORE` | Tablas maestras (Clientes, Pólizas, Agentes) |
| `AUTOS` | Seguros de automóviles |
| `GMM` | Gastos Médicos Mayores |
| `OPERACIONES` | Siniestros, pagos, renovaciones |
| `SEMANTICO` | Vistas analíticas |

### Diagrama de Entidades

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   AGENTES   │────<│   CLIENTES  │────<│   POLIZAS   │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                    ┌──────────────────────────┼──────────────────────────┐
                    │                          │                          │
              ┌─────▼─────┐            ┌───────▼──────┐           ┌───────▼──────┐
              │ VEHICULOS │            │ POLIZAS_AUTO │           │ POLIZAS_GMM  │
              └───────────┘            └──────────────┘           └───────┬──────┘
                                                                          │
                                                                  ┌───────▼──────┐
                                                                  │ASEGURADOS_GMM│
                                                                  └──────────────┘
```

---

## 🚀 Instalación y Ejecución

### 1. Clonar el repositorio
```bash
git clone <repo-url>
cd Insurance
```

### 2. Instalar dependencias Python
```bash
pip install -r requirements.txt
```

### 3. Generar pólizas PDF
```bash
cd scripts
python generar_polizas_pdf.py
```

### 4. Ejecutar en Snowflake

Ejecutar los scripts SQL en el siguiente orden:

```sql
-- 1. Crear estructura
@CENTINELA_estructura_tablas.sql

-- 2. Cargar datos
@CENTINELA_datos_sinteticos.sql
@CENTINELA_datos_sinteticos_parte2.sql
@CENTINELA_datos_sinteticos_parte3.sql

-- 3. Crear vistas semánticas
@CENTINELA_vistas_semanticas.sql
```

---

## 📊 Vistas Semánticas Disponibles

| Vista | Descripción |
|-------|-------------|
| `VW_POLIZAS_COMPLETA` | Vista maestra de todas las pólizas |
| `VW_POLIZAS_AUTO_DETALLE` | Detalle completo de seguros de auto |
| `VW_POLIZAS_GMM_DETALLE` | Detalle completo de GMM |
| `VW_DASHBOARD_VENTAS` | Métricas para dashboard de ventas |
| `VW_CARTERA_VEHICULOS` | Análisis de cartera de vehículos |
| `VW_CARTERA_GMM` | Análisis de cartera médica |
| `VW_KPI_EJECUTIVO` | KPIs consolidados |
| `VW_ANALISIS_AGENTES` | Desempeño de agentes |
| `VW_RENOVACIONES_PENDIENTES` | Pólizas por renovar |

---

## 📋 Datos Generados

### Pólizas de Automóvil (40)
- Marcas: Nissan, VW, Toyota, Honda, Mazda, BMW, Mercedes-Benz, Audi, etc.
- Coberturas: Amplia, Limitada, Premium, RC Básica
- Años modelo: 2020-2024
- Valores: $280,000 - $1,400,000 MXN

### Pólizas GMM (40)
- Planes: Básico, Esencial, Plus, Elite, Familiar
- Tipo: Individual y Familiar (hasta 4 asegurados)
- Sumas aseguradas: $5M - $50M MXN
- Coberturas: Dental, Visual, Maternidad, Internacional

---

## 📈 Queries de Ejemplo

### Resumen de cartera
```sql
SELECT * FROM CENTINELA_DB.SEMANTICO.VW_KPI_EJECUTIVO;
```

### Pólizas por vencer en 30 días
```sql
SELECT * FROM CENTINELA_DB.SEMANTICO.VW_RENOVACIONES_PENDIENTES
WHERE prioridad_renovacion IN ('Crítico', 'Urgente');
```

### Producción por agente
```sql
SELECT 
    nombre_completo,
    total_polizas,
    prima_total,
    comisiones_generadas
FROM CENTINELA_DB.SEMANTICO.VW_ANALISIS_AGENTES
ORDER BY prima_total DESC;
```

### Top 10 vehículos más asegurados
```sql
SELECT 
    marca, 
    submarca,
    COUNT(*) as cantidad,
    SUM(valor_comercial_total) as valor_total
FROM CENTINELA_DB.SEMANTICO.VW_CARTERA_VEHICULOS
GROUP BY marca, submarca
ORDER BY cantidad DESC
LIMIT 10;
```

---

## 🤖 Modelo Semántico para Cortex Analyst

El proyecto incluye un modelo semántico YAML para usar con **Snowflake Cortex Analyst**.

### Estructura del Modelo

```yaml
# Tablas definidas:
- agentes          # Fuerza de ventas
- clientes         # Asegurados
- polizas          # Tabla maestra de pólizas
- vehiculos        # Vehículos asegurados
- polizas_auto     # Detalle de pólizas de auto
- planes_gmm       # Catálogo de planes médicos
- polizas_gmm      # Detalle de pólizas GMM
- siniestros       # Reclamaciones
- pagos            # Control de cobros
```

### Cómo usar el modelo semántico

1. **Subir el archivo YAML al stage:**
```sql
PUT file:///ruta/centinela_semantic_model.yaml 
    @CENTINELA_DB.CORE.SEMANTIC_MODEL_STAGE;
```

2. **Registrar el modelo:**
```sql
@CENTINELA_registrar_modelo_semantico.sql
```

3. **Ejemplo de consulta con Cortex:**
```sql
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'llama3.1-70b',
    '¿Cuál es el total de primas por tipo de seguro?'
);
```

### Consultas verificadas incluidas

| Consulta | Descripción |
|----------|-------------|
| `total_primas_por_tipo` | Total de primas por AUTO y GMM |
| `polizas_por_agente` | Productividad de cada agente |
| `vehiculos_por_marca` | Marcas más aseguradas |
| `clientes_por_estado` | Distribución geográfica |
| `planes_gmm_populares` | Planes más contratados |

---

## ⚙️ FinOps

```sql
-- Suspender warehouse cuando no se use
ALTER WAREHOUSE CENTINELA_WH SUSPEND;

-- Verificar consumo
SELECT 
    warehouse_name,
    SUM(credits_used) as creditos
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE warehouse_name = 'CENTINELA_WH'
AND start_time >= DATEADD(day, -7, CURRENT_TIMESTAMP())
GROUP BY warehouse_name;
```

---

## 📝 Notas

- Todos los datos son **ficticios** y generados aleatoriamente
- Los RFCs y CURPs son sintéticos y no corresponden a personas reales
- Diseñado para **demos y pruebas de concepto**
- Compatible con Snowflake y Cortex AI

---

**Autor:** Ingeniero de Datos  
**Versión:** 1.0  
**Fecha:** 2024

