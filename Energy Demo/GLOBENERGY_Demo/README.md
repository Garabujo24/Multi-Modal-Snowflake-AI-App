# 🌍 GLOBENERGY - Demo de Plataforma Global de Gestión Energética

**Empresa Ficticia Internacional** | **Snowflake SQL** | **Ingeniero de Datos**

---

## 📋 Resumen Ejecutivo

**GLOBENERGY** es una empresa ficticia internacional que provee soluciones energéticas integrales a más de 40,000 ubicaciones de clientes en todo el mundo. Esta demo demuestra capacidades avanzadas de análisis de datos para:

- ⚡ **Optimización de Costos Energéticos**
- 📊 **Análisis de Consumo Multi-dimensional**
- 🔮 **Predicción de Demanda con Machine Learning**
- 🌱 **Sostenibilidad y Reducción de Huella de Carbono**
- 🌪️ **Continuidad de Negocios ante Eventos Climáticos**

---

## 🏗️ Arquitectura de Datos

### Recursos Creados en Snowflake

```
GLOBENERGY_WH                    # Warehouse (XSMALL, auto-suspend 60s)
└── GLOBENERGY_DB                # Database
    └── ENERGIA                  # Schema
        ├── CLIENTES             # 100 registros
        ├── TIPOS_ENERGIA        # 8 tipos (Gas, Electricidad, Renovables, etc.)
        ├── CONTRATOS            # 200 contratos
        ├── CONSUMO              # ⭐ 2,000 registros (tabla principal)
        ├── EVENTOS_CLIMATICOS   # 50 eventos
        └── PREDICCIONES_DEMANDA # 300 predicciones
```

### Modelo de Datos

```
                    ┌─────────────────┐
                    │   CLIENTES      │
                    │  (100 registros)│
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
         ┌──────────▼────────┐  ┌────▼──────────────┐
         │   CONTRATOS       │  │ PREDICCIONES_     │
         │  (200 registros)  │  │ DEMANDA           │
         └──────────┬────────┘  │ (300 registros)   │
                    │           └───────────────────┘
         ┌──────────▼────────┐
         │     CONSUMO       │  ◄── TABLA PRINCIPAL
         │  (2,000 registros)│
         └──────────┬────────┘
                    │
         ┌──────────▼────────┐
         │  TIPOS_ENERGIA    │
         │   (8 tipos)       │
         └───────────────────┘

    ┌──────────────────────┐
    │ EVENTOS_CLIMATICOS   │  (Tabla independiente)
    │   (50 eventos)       │
    └──────────────────────┘
```

---

## 📦 Productos y Servicios de GLOBENERGY

1. **Gas Natural** - Suministro residencial, comercial e industrial
2. **Electricidad** - Planes con precios fijos e indexados
3. **Gas Natural Licuado (LNG)** - Soluciones para flotas y operaciones remotas
4. **Propano** - Suministro al por mayor
5. **Combustibles Líquidos** - Diésel y otros combustibles
6. **Servicios Midstream** - Infraestructura y transporte
7. **Energía Solar** - Paneles fotovoltaicos (cero emisiones)
8. **Energía Eólica** - Turbinas eólicas (cero emisiones)
9. **Biogás** - Gas renovable de desechos orgánicos

---

## 🏢 Sectores Atendidos

- 🎓 **Educación** - Universidades, escuelas
- 🏥 **Salud** - Hospitales, clínicas
- 🏨 **Hospitalidad** - Hoteles, restaurantes
- 🏭 **Industrial** - Manufactura, logística
- 🏬 **Comercial** - Retail, oficinas
- 🏛️ **Gobierno** - Edificios públicos, infraestructura

---

## 🎯 Casos de Uso Demostrados

### 1️⃣ Optimización de Costos Energéticos

**Consultas incluidas:**
- **Q1**: Análisis de costos por sector y tipo de energía
- **Q2**: Identificar oportunidades de ahorro migrando a renovables (hasta 25% de ahorro)
- **Q3**: Comparativa de eficiencia energética por tamaño de empresa

**Valor de Negocio:**
- Identificar sectores con mayores costos para negociación
- Calcular ROI de migración a energías renovables
- Benchmark de eficiencia entre empresas similares

---

### 2️⃣ Análisis de Consumo

**Consultas incluidas:**
- **Q4**: Tendencia de consumo mensual por tipo de energía (últimos 12 meses)
- **Q5**: Consumo en horas pico vs no pico por sector
- **Q6**: Top 10 clientes con mayor consumo y costo

**Valor de Negocio:**
- Detectar patrones estacionales de consumo
- Optimizar contratos para reducir costos en hora pico
- Identificar clientes clave para programas de retención

---

### 3️⃣ Predicción de Demanda (Machine Learning)

**Consultas incluidas:**
- **Q7**: Precisión del modelo de predicción por tipo de energía
- **Q8**: Predicciones con mayor desviación (alertas de planificación)

**Valor de Negocio:**
- Planificación proactiva de suministro
- Reducir desabastecimientos y costos de emergencia
- Negociaciones más efectivas con proveedores upstream

---

### 4️⃣ Sostenibilidad y Huella de Carbono

**Consultas incluidas:**
- **Q9**: Emisiones de CO2 por sector y nivel de sostenibilidad
- **Q10**: Comparativa de emisiones: Fósiles vs Renovables
- **Q11**: Clientes líderes en sostenibilidad (menor huella relativa)

**Valor de Negocio:**
- Cumplimiento de objetivos ESG (Environmental, Social, Governance)
- Reportes de sostenibilidad para stakeholders
- Identificar oportunidades de decarbonización

---

### 5️⃣ Continuidad de Negocios ante Eventos Climáticos

**Consultas incluidas:**
- **Q12**: Impacto de eventos climáticos por región y severidad
- **Q13**: Correlación entre temperatura y consumo energético
- **Q14**: Plan de continuidad - Clientes en zonas de alto riesgo climático

**Valor de Negocio:**
- Planes de respuesta ante desastres naturales
- Identificar infraestructura crítica vulnerable
- Reducir pérdidas operacionales y costos de mitigación

---

### 6️⃣ Gestión de Contratos y Renovaciones

**Consultas incluidas:**
- **Q15**: Contratos próximos a vencer (oportunidades de renovación en los próximos 90 días)

**Valor de Negocio:**
- Pipeline de renovaciones para equipos comerciales
- Prevenir pérdida de clientes por vencimiento no atendido
- Oportunidades de upselling a contratos renovables

---

## 📊 Datos Sintéticos Generados

| Tabla | Registros | Descripción |
|-------|-----------|-------------|
| **CONSUMO** | 2,000 | ⭐ Registros de consumo energético (tabla principal) |
| CONTRATOS | 200 | Contratos activos, vencidos y renovados |
| CLIENTES | 100 | Clientes en 10 países, 6 sectores |
| PREDICCIONES_DEMANDA | 300 | Predicciones ML con confianza 75-98% |
| EVENTOS_CLIMATICOS | 50 | Tormentas, huracanes, olas de calor/frío |
| TIPOS_ENERGIA | 8 | Gas, electricidad, renovables |
| **TOTAL** | **2,658** | **Registros en toda la base de datos** |

---

## 🚀 Instrucciones de Uso

### Paso 1: Ejecutar el Script SQL

```sql
-- Abrir en Snowflake SQL Worksheet
-- Archivo: GLOBENERGY_Demo_Completo.sql

-- El script ejecuta automáticamente:
-- 1. Creación de Warehouse, DB, Schema, Roles
-- 2. Creación de 6 tablas
-- 3. Inserción de ~2,650 registros sintéticos
-- 4. 15 consultas de demostración
-- 5. 6 consultas de validación
```

**Tiempo estimado de ejecución:** 2-3 minutos

---

### Paso 2: Validar Datos

```sql
-- Ejecutar query de resumen (V6 en el script)
-- Debería mostrar:
--   ✅ 95+ Clientes Activos
--   ✅ 180+ Contratos Activos
--   ✅ 2,000 Registros de Consumo
--   ✅ 50 Eventos Climáticos
--   ✅ 300 Predicciones con ~90% de precisión
```

---

### Paso 3: Explorar Modelo Semántico (Opcional)

El archivo `GLOBENERGY_Semantic_Model.yaml` puede ser importado en:
- **Snowflake Semantic Layer**
- **dbt (Data Build Tool)**
- **Herramientas BI compatibles con semantic models**

**Incluye:**
- ✅ 6 tablas con 50+ dimensiones documentadas
- ✅ 7 relaciones `many_to_one` entre tablas
- ✅ 5 consultas verificadas ultra-simples
- ✅ Sinónimos para búsqueda en lenguaje natural

---

## 💡 Insights Clave Esperados

Al ejecutar las consultas de demostración, deberías observar:

1. **Sector Industrial** representa ~40% del costo total de energía
2. **Migración a renovables** puede ahorrar hasta **25% en costos**
3. **Consumo en hora pico** es ~35% más caro que en hora normal
4. **Eventos climáticos críticos** afectan a 100+ clientes y cuestan $250K+ en mitigación
5. **Energías renovables** tienen **cero emisiones de CO2** vs 2-10 kg CO2/unidad en fósiles
6. **Predicciones ML** tienen confianza promedio de **88-92%**
7. **Contratos renovables** representan ~12% del total (oportunidad de crecimiento)

---

## 🔧 Configuración FinOps

El script incluye **control de costos** mediante:

```sql
-- Warehouse con auto-suspend agresivo
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60  -- 1 minuto de inactividad

-- Timeout de queries para evitar runaway queries
STATEMENT_TIMEOUT_IN_SECONDS = 300  -- 5 minutos máximo
```

**Costo estimado de ejecución:** <$0.10 USD

---

## 📁 Archivos Incluidos

```
GLOBENERGY_Demo/
├── GLOBENERGY_Demo_Completo.sql       # 🔥 Script principal con todo
├── GLOBENERGY_Semantic_Model.yaml     # 📊 Modelo semántico
└── README.md                          # 📖 Esta documentación
```

---

## 🌟 Características Técnicas

### Sintaxis Snowflake SQL (100% Compatible)

✅ **Secuencias**: `ROW_NUMBER() OVER (ORDER BY NULL)` en lugar de `SEQ4()`  
✅ **Módulo**: `MOD(x, y)` en lugar de operador `%`  
✅ **Aleatorios**: `UNIFORM(min, max, RANDOM())` en lugar de `RANDOM() * N`  
✅ **Referencias**: Nombres completos `SCHEMA.TABLA` en todos los JOINs  
✅ **Agregados con filtro**: `SUM(CASE WHEN ... THEN ... ELSE 0 END)` en lugar de `FILTER (WHERE ...)`

### Coherencia de Datos

- ✅ Rangos de consumo coherentes por sector (Industrial > Salud > Comercial)
- ✅ Factores de emisión CO2 realistas (Renovables = 0 kg, Diésel = 10.18 kg/galón)
- ✅ Precios de energía basados en mercado real (Electricidad $0.12/kWh, Gas $0.45/m³)
- ✅ Eficiencia energética entre 65-98% (rango operacional realista)
- ✅ Temperaturas entre -15°C y 35°C (rango global)

---

## 🎓 Casos de Uso para Demos

### Demo para Clientes de Energía

- Mostrar análisis de consumo y optimización de costos (Q1-Q6)
- Demostrar valor de migración a renovables (Q2, Q10, Q11)
- Presentar predicción de demanda con ML (Q7, Q8)

### Demo para Industrias Reguladas

- Reportes de sostenibilidad y emisiones CO2 (Q9, Q10, Q11)
- Cumplimiento ESG y objetivos de decarbonización
- Auditoría de contratos y compliance (Q15)

### Demo de Resiliencia Operacional

- Impacto de eventos climáticos en operaciones (Q12)
- Planes de continuidad de negocios (Q14)
- Correlación clima-consumo para forecasting (Q13)

### Demo Técnica de Snowflake

- Uso de `GENERATOR()` para datos sintéticos escalables
- Consultas analíticas complejas con múltiples JOINs
- Window functions y agregaciones avanzadas
- Modelo semántico para self-service analytics

---

## 🔐 Seguridad y Roles

```sql
-- Rol creado: GLOBENERGY_ANALISTA
-- Permisos:
--   ✅ SELECT en todas las tablas
--   ✅ USAGE en Warehouse, Database, Schema
--   ❌ SIN permisos de INSERT, UPDATE, DELETE (solo lectura)
```

---

## 📞 Próximos Pasos

1. **Dashboards**: Crear visualizaciones en Snowsight o Tableau
2. **Machine Learning**: Integrar Snowflake Cortex para predicciones avanzadas
3. **Alertas**: Configurar alerts para eventos climáticos y consumos anómalos
4. **Time Series**: Agregar análisis de series temporales con Snowflake Time Series
5. **Data Sharing**: Compartir insights con clientes mediante Secure Data Sharing

---

## 📊 Estructura de Consultas

### Secciones del Script SQL

| Sección | Descripción | Líneas |
|---------|-------------|--------|
| **Sección 0** | Historia y Caso de Uso (narrativa) | 1-90 |
| **Sección 1** | Configuración de Recursos (CREATE OR REPLACE) | 91-180 |
| **Sección 2** | Generación de Datos Sintéticos (INSERT INTO) | 181-450 |
| **Sección 3** | La Demo (15 consultas de valor) | 451-750 |
| **Sección 4** | Queries de Diagnóstico y Validación | 751-850 |

---

## 🌍 Cobertura Geográfica

**Países incluidos en los datos:**
- 🇺🇸 Estados Unidos
- 🇨🇦 Canadá
- 🇲🇽 México
- 🇬🇧 Reino Unido
- 🇩🇪 Alemania
- 🇫🇷 Francia
- 🇪🇸 España
- 🇧🇷 Brasil
- 🇦🇷 Argentina
- 🇨🇱 Chile

**Regiones:** América del Norte, América Latina, Europa

---

## 📈 KPIs Principales

Los datos permiten calcular KPIs clave como:

- **Costo Total Facturado (USD)**: ~$30M+ anual
- **Emisiones CO2 (Toneladas)**: Varía por mix energético
- **Eficiencia Energética Promedio**: ~82%
- **Precisión de Predicciones ML**: ~88%
- **Tasa de Renovación de Contratos**: ~90%
- **Clientes Afectados por Clima**: ~500 anualmente
- **Ahorro Potencial con Renovables**: ~$7.5M (25% del total)

---

## 🏆 Conclusión

Esta demo de **GLOBENERGY** demuestra capacidades avanzadas de:

✅ **Modelado de Datos** para industria energética  
✅ **Análisis Multi-dimensional** (sector, geografía, tipo de energía, tiempo)  
✅ **Machine Learning** para predicción de demanda  
✅ **Sostenibilidad** y reporting ESG  
✅ **Resiliencia Operacional** ante eventos climáticos  
✅ **FinOps** y control de costos en Snowflake  

**Ideal para demostraciones con:**
- Empresas de energía y utilities
- Clientes enfocados en sostenibilidad
- Organizaciones con necesidades de continuidad de negocios
- Casos de uso de análisis predictivo y optimización

---

**Desarrollado por:** Ingeniero de Datos  
**Tecnología:** Snowflake SQL + Semantic Modeling  
**Fecha:** Octubre 2025  
**Versión:** 1.0  

---

© 2025 GLOBENERGY Demo - Empresa Ficticia para Fines Demostrativos

