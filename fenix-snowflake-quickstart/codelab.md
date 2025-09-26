summary: Snowflake Avanzado para Fenix Energia - Time Travel, Control de Costos, JSON y Escalamiento
id: fenix-snowflake-quickstart
categories: snowflake,data-engineering,analytics
tags: fenix-energia,snowflake,time-travel,cost-control,json,warehouses
status: Published
authors: Fenix Energia Tech Team
Feedback Link: https://www.fenixenergia.com.mx/

# Snowflake Avanzado para Fenix Energia
<!-- ------------------------ -->
## Introducción
Duration: 5

### ¡Bienvenidos a Fénix Energia! 

![Fenix Logo](https://via.placeholder.com/200x80/FF6B35/FFFFFF?text=FENIX+ENERGIA)

En **Fénix Energia**, como líderes en generación, suministro y comercialización de energía en México, manejamos grandes volúmenes de datos críticos para nuestras operaciones. Este quickstart te guiará a través de las capacidades avanzadas de Snowflake que son esenciales para nuestro negocio energético.

### ¿Qué aprenderás?

- **Time Travel** de Snowflake para recuperación de datos críticos
- **Control de Costos** para optimizar nuestro presupuesto de datos
- **Análisis de JSON** para datos de sensores y medidores
- **Escalamiento de Warehouses** para manejar picos de demanda

### ¿Qué necesitas?

- Acceso a una cuenta Snowflake
- Conocimientos básicos de SQL
- Experiencia con datos del sector energético

> aside positive
> **Sobre Fénix Energia:** Ubicados en Lago Zúrich 245, Edif. Carso, Piso 5, Col. Ampliación Granada, somos una empresa mexicana dedicada a la transformación del sector energético nacional.

<!-- ------------------------ -->
## Configuración del Entorno
Duration: 10

### Configuración Inicial para Fénix Energia

Primero, configuraremos nuestro entorno Snowflake con datos simulados del sector energético que manejamos en Fénix.

```sql
-- Crear database para datos de Fenix Energia
CREATE DATABASE IF NOT EXISTS FENIX_ENERGIA_DB;
USE DATABASE FENIX_ENERGIA_DB;

-- Crear schema para datos operacionales
CREATE SCHEMA IF NOT EXISTS OPERACIONES;
USE SCHEMA OPERACIONES;

-- Crear warehouse específico para análisis energético
CREATE WAREHOUSE IF NOT EXISTS FENIX_ANALYTICS_WH 
  WITH WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'Warehouse principal para análisis de Fenix Energia';

USE WAREHOUSE FENIX_ANALYTICS_WH;
```

### Crear Tablas de Datos Energéticos

```sql
-- Tabla de generación de energía
CREATE TABLE generacion_energia (
  id NUMBER AUTOINCREMENT PRIMARY KEY,
  planta_id VARCHAR(50),
  timestamp TIMESTAMP_NTZ,
  megawatts_generados NUMBER(10,2),
  tipo_energia VARCHAR(20), -- solar, eolica, termica
  eficiencia NUMBER(5,2),
  metadatos_sensores VARIANT -- JSON data
);

-- Tabla de consumo por clientes
CREATE TABLE consumo_clientes (
  id NUMBER AUTOINCREMENT PRIMARY KEY,
  cliente_id VARCHAR(50),
  fecha DATE,
  kwh_consumidos NUMBER(12,2),
  tarifa VARCHAR(20),
  region VARCHAR(50),
  facturado BOOLEAN DEFAULT FALSE
);

-- Insertar datos de ejemplo
INSERT INTO generacion_energia 
  (planta_id, timestamp, megawatts_generados, tipo_energia, eficiencia, metadatos_sensores)
VALUES 
  ('PLANTA_SOLAR_01', CURRENT_TIMESTAMP(), 45.5, 'solar', 85.3, 
   PARSE_JSON('{"temperatura": 32, "radiacion": 850, "panel_status": {"activos": 120, "mantenimiento": 5}}')),
  ('PLANTA_EOLICA_02', CURRENT_TIMESTAMP(), 78.2, 'eolica', 92.1,
   PARSE_JSON('{"viento_mps": 12.5, "turbinas": {"operativas": 15, "paradas": 1}}')),
  ('PLANTA_TERMICA_03', CURRENT_TIMESTAMP(), 125.8, 'termica', 88.7,
   PARSE_JSON('{"combustible": "gas_natural", "temp_caldera": 580, "presion_bar": 45}'));

INSERT INTO consumo_clientes 
  (cliente_id, fecha, kwh_consumidos, tarifa, region)
VALUES 
  ('CLIENTE_001', CURRENT_DATE(), 1250.5, 'industrial', 'norte'),
  ('CLIENTE_002', CURRENT_DATE(), 456.2, 'comercial', 'centro'),
  ('CLIENTE_003', CURRENT_DATE(), 89.3, 'residencial', 'sur');
```

> aside positive
> **¡Excelente!** Has configurado tu entorno Snowflake con datos típicos del sector energético que manejamos en Fénix Energia.

<!-- ------------------------ -->
## Lección 1: Time Travel para Datos Críticos
Duration: 15

### ¿Por qué Time Travel es Crucial en Fénix Energia?

En el sector energético, los datos son críticos para:
- **Auditorías regulatorias** de la CRE (Comisión Reguladora de Energía)
- **Recuperación de datos** tras actualizaciones erróneas
- **Análisis histórico** de generación y consumo
- **Compliance** con normativas energéticas mexicanas

### Configurar Time Travel

```sql
-- Verificar configuración actual de Time Travel
SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN ACCOUNT;

-- Configurar retención extendida para datos críticos (máximo 90 días)
ALTER TABLE generacion_energia SET DATA_RETENTION_TIME_IN_DAYS = 90;
ALTER TABLE consumo_clientes SET DATA_RETENTION_TIME_IN_DAYS = 90;

-- Verificar configuración
SHOW TABLES LIKE '%' IN SCHEMA operaciones;
```

### Simulando un Incidente: Actualización Errónea

```sql
-- Antes del incidente: verificar datos actuales
SELECT COUNT(*) as total_registros, 
       AVG(megawatts_generados) as promedio_mw
FROM generacion_energia;

-- INCIDENTE: Actualización errónea que afecta todos los registros
UPDATE generacion_energia 
SET megawatts_generados = megawatts_generados * 0.1 -- Error: dividió por 10
WHERE tipo_energia = 'solar';

-- Verificar el daño
SELECT planta_id, megawatts_generados, tipo_energia
FROM generacion_energia 
WHERE tipo_energia = 'solar';
```

### Recuperación usando Time Travel

```sql
-- Opción 1: Ver datos de hace 5 minutos
SELECT planta_id, megawatts_generados, tipo_energia
FROM generacion_energia AT(OFFSET => -300) -- 300 segundos = 5 minutos
WHERE tipo_energia = 'solar';

-- Opción 2: Ver datos desde un timestamp específico
SELECT planta_id, megawatts_generados, tipo_energia
FROM generacion_energia AT(TIMESTAMP => DATEADD(MINUTE, -10, CURRENT_TIMESTAMP()))
WHERE tipo_energia = 'solar';

-- Opción 3: Recuperar usando query ID (más preciso)
-- Primero obtén el query ID de antes del incidente
SHOW QUERIES IN ACCOUNT ORDER BY start_time DESC LIMIT 10;

-- Luego usa el query ID (reemplaza con el ID real)
-- SELECT * FROM generacion_energia BEFORE(STATEMENT => '01a2b3c4-...');
```

### Restaurar Datos Correctos

```sql
-- Crear tabla temporal con datos correctos
CREATE TEMPORARY TABLE temp_generacion_correcta AS
SELECT * FROM generacion_energia AT(OFFSET => -300);

-- Restaurar datos usando MERGE
MERGE INTO generacion_energia t
USING temp_generacion_correcta s ON t.id = s.id
WHEN MATCHED AND t.tipo_energia = 'solar' THEN
  UPDATE SET megawatts_generados = s.megawatts_generados;

-- Verificar la restauración
SELECT planta_id, megawatts_generados, tipo_energia
FROM generacion_energia 
WHERE tipo_energia = 'solar';
```

### Auditoría de Cambios

```sql
-- Query para auditoría: comparar datos actuales vs históricos
SELECT 
  'ACTUAL' as version,
  COUNT(*) as registros,
  AVG(megawatts_generados) as promedio_mw,
  SUM(megawatts_generados) as total_mw
FROM generacion_energia
WHERE tipo_energia = 'solar'

UNION ALL

SELECT 
  'HACE_1_HORA' as version,
  COUNT(*) as registros,
  AVG(megawatts_generados) as promedio_mw,
  SUM(megawatts_generados) as total_mw
FROM generacion_energia AT(OFFSET => -3600)
WHERE tipo_energia = 'solar';
```

> aside positive
> **¡Perfecto!** Has aprendido a usar Time Travel para proteger los datos críticos de Fénix Energia. Esta funcionalidad es esencial para cumplir con auditorías regulatorias y mantener la integridad de nuestros datos operacionales.

<!-- ------------------------ -->
## Lección 2: Control de Costos Inteligente
Duration: 20

### Optimización de Costos en Fénix Energia

Como empresa energética, optimizar costos es crucial para mantener tarifas competitivas. Snowflake nos permite controlar y optimizar nuestros gastos en datos.

### Monitoreo de Uso Actual

```sql
-- Ver uso de créditos por warehouse
SELECT 
  warehouse_name,
  SUM(credits_used) as total_credits,
  AVG(credits_used_compute) as avg_compute_credits,
  COUNT(*) as queries_executed
FROM table(information_schema.warehouse_metering_history(
  dateadd('days', -7, current_date()),
  current_date()
))
GROUP BY warehouse_name
ORDER BY total_credits DESC;

-- Análisis de queries más costosas
SELECT 
  query_text,
  warehouse_name,
  total_elapsed_time/1000 as seconds_elapsed,
  credits_used_cloud_services,
  bytes_scanned
FROM table(information_schema.query_history(
  dateadd('days', -1, current_date()),
  current_date()
))
WHERE credits_used_cloud_services > 0
ORDER BY credits_used_cloud_services DESC
LIMIT 10;
```

### Configurar Alertas de Costos

```sql
-- Crear resource monitor para controlar costos
CREATE RESOURCE MONITOR IF NOT EXISTS FENIX_COST_MONITOR
  WITH CREDIT_QUOTA = 100 -- Límite mensual en créditos
  FREQUENCY = MONTHLY
  START_TIMESTAMP = CURRENT_DATE()
  TRIGGERS
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO SUSPEND
    ON 100 PERCENT DO SUSPEND_IMMEDIATE;

-- Asignar monitor a nuestro warehouse
ALTER WAREHOUSE FENIX_ANALYTICS_WH 
  SET RESOURCE_MONITOR = FENIX_COST_MONITOR;
```

### Optimización de Warehouses

```sql
-- Crear warehouses especializados por tipo de workload
CREATE WAREHOUSE IF NOT EXISTS FENIX_ETL_WH
  WITH WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'Para procesos ETL de datos energéticos';

CREATE WAREHOUSE IF NOT EXISTS FENIX_REPORTES_WH
  WITH WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 300  -- 5 minutos para reportes
  AUTO_RESUME = TRUE
  COMMENT = 'Para reportes ejecutivos y dashboard';

CREATE WAREHOUSE IF NOT EXISTS FENIX_ADHOC_WH
  WITH WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'Para consultas ad-hoc y desarrollo';
```

### Optimización de Consultas

```sql
-- Usar clustering para optimizar consultas frecuentes
ALTER TABLE generacion_energia 
  CLUSTER BY (tipo_energia, DATE(timestamp));

-- Crear vistas materializadas para reportes frecuentes
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_resumen_diario_generacion AS
SELECT 
  DATE(timestamp) as fecha,
  tipo_energia,
  COUNT(*) as num_registros,
  SUM(megawatts_generados) as total_mw,
  AVG(eficiencia) as eficiencia_promedio
FROM generacion_energia
GROUP BY DATE(timestamp), tipo_energia;

-- Query optimizada usando la vista materializada
SELECT * FROM mv_resumen_diario_generacion
WHERE fecha >= DATEADD('days', -30, CURRENT_DATE())
ORDER BY fecha DESC, total_mw DESC;
```

### Análisis de Costo-Beneficio

```sql
-- Función para calcular costo por query
CREATE OR REPLACE FUNCTION calcular_costo_query(credits NUMBER, precio_credito NUMBER)
RETURNS NUMBER
LANGUAGE SQL
AS $$
  credits * precio_credito
$$;

-- Análisis de eficiencia por tipo de consulta
WITH query_costs AS (
  SELECT 
    warehouse_name,
    CASE 
      WHEN UPPER(query_text) LIKE '%SELECT%' THEN 'CONSULTA'
      WHEN UPPER(query_text) LIKE '%INSERT%' THEN 'INSERCION'
      WHEN UPPER(query_text) LIKE '%UPDATE%' THEN 'ACTUALIZACION'
      ELSE 'OTROS'
    END as tipo_operacion,
    credits_used_cloud_services,
    calcular_costo_query(credits_used_cloud_services, 2.5) as costo_estimado_usd
  FROM table(information_schema.query_history(
    dateadd('days', -7, current_date()),
    current_date()
  ))
  WHERE credits_used_cloud_services > 0
)
SELECT 
  warehouse_name,
  tipo_operacion,
  COUNT(*) as num_operaciones,
  SUM(costo_estimado_usd) as costo_total_usd,
  AVG(costo_estimado_usd) as costo_promedio_usd
FROM query_costs
GROUP BY warehouse_name, tipo_operacion
ORDER BY costo_total_usd DESC;
```

### Dashboard de Costos para Fénix

```sql
-- Vista ejecutiva de costos para dashboard
CREATE OR REPLACE VIEW v_dashboard_costos_fenix AS
SELECT 
  'CREDITOS_HOY' as metrica,
  SUM(credits_used) as valor,
  'credits' as unidad
FROM table(information_schema.warehouse_metering_history(
  current_date(),
  current_date()
))

UNION ALL

SELECT 
  'CREDITOS_MES' as metrica,
  SUM(credits_used) as valor,
  'credits' as unidad
FROM table(information_schema.warehouse_metering_history(
  date_trunc('month', current_date()),
  current_date()
))

UNION ALL

SELECT 
  'QUERIES_HOY' as metrica,
  COUNT(*) as valor,
  'queries' as unidad
FROM table(information_schema.query_history(
  current_date(),
  current_date()
));

-- Consultar dashboard
SELECT * FROM v_dashboard_costos_fenix;
```

> aside negative
> **¡Importante!** El control de costos es fundamental para Fénix Energia. Estas técnicas nos permiten mantener operaciones eficientes mientras ofrecemos tarifas competitivas a nuestros clientes.

<!-- ------------------------ -->
## Lección 3: Análisis de JSON para Sensores IoT
Duration: 15

### JSON en el Sector Energético de Fénix

En Fénix Energia, nuestros sensores IoT y medidores inteligentes generan datos JSON complejos que incluyen:
- **Telemetría** de plantas de generación
- **Estados** de equipos críticos
- **Métricas** ambientales y operacionales
- **Alertas** de mantenimiento predictivo

### Explorando Datos JSON de Sensores

```sql
-- Ver estructura JSON de nuestros sensores
SELECT 
  planta_id,
  metadatos_sensores,
  tipo_energia
FROM generacion_energia
LIMIT 3;

-- Extraer valores específicos del JSON
SELECT 
  planta_id,
  tipo_energia,
  metadatos_sensores:temperatura::NUMBER as temperatura,
  metadatos_sensores:radiacion::NUMBER as radiacion_solar,
  metadatos_sensores:viento_mps::NUMBER as velocidad_viento
FROM generacion_energia;
```

### Insertar Datos JSON Complejos de Plantas

```sql
-- Insertar datos más complejos de nuestras plantas
INSERT INTO generacion_energia 
  (planta_id, timestamp, megawatts_generados, tipo_energia, eficiencia, metadatos_sensores)
VALUES 
  ('PLANTA_SOLAR_04', CURRENT_TIMESTAMP(), 67.8, 'solar',
   PARSE_JSON('{
     "ubicacion": {"latitud": 25.6866, "longitud": -100.3161, "estado": "Nuevo Leon"},
     "paneles": {
       "total": 150,
       "activos": 148,
       "mantenimiento": 2,
       "eficiencia_individual": [98.5, 97.2, 99.1, 96.8, 98.9]
     },
     "condiciones_climaticas": {
       "temperatura": 28,
       "radiacion": 920,
       "nubosidad": 15,
       "viento": 8.5
     },
     "alertas": [
       {"nivel": "warning", "componente": "panel_A12", "mensaje": "Eficiencia baja"},
       {"nivel": "info", "componente": "inversor_3", "mensaje": "Mantenimiento programado"}
     ]
   }')),
   
  ('PLANTA_EOLICA_05', CURRENT_TIMESTAMP(), 95.3, 'eolica',
   PARSE_JSON('{
     "ubicacion": {"latitud": 24.1477, "longitud": -98.1719, "estado": "Tamaulipas"},
     "turbinas": {
       "total": 20,
       "operativas": 19,
       "mantenimiento": 1,
       "potencia_individual": [4.8, 4.9, 4.7, 5.1, 4.6, 4.8, 4.9, 5.0, 4.7, 4.8]
     },
     "condiciones_viento": {
       "velocidad_promedio": 14.2,
       "rafagas_max": 18.7,
       "direccion": "noreste",
       "turbulencia": "baja"
     },
     "sistemas": {
       "control_pitch": "operativo",
       "sistema_frenado": "operativo",
       "orientacion_nacelle": "automatica"
     }
   }');
```

### Análisis Avanzado de JSON

```sql
-- Extraer y analizar arrays dentro del JSON
SELECT 
  planta_id,
  tipo_energia,
  f.value::NUMBER as eficiencia_panel
FROM generacion_energia,
LATERAL FLATTEN(input => metadatos_sensores:paneles.eficiencia_individual) f
WHERE tipo_energia = 'solar'
AND metadatos_sensores:paneles.eficiencia_individual IS NOT NULL;

-- Análisis de alertas por planta
SELECT 
  planta_id,
  alert.value:nivel::STRING as nivel_alerta,
  alert.value:componente::STRING as componente,
  alert.value:mensaje::STRING as mensaje
FROM generacion_energia,
LATERAL FLATTEN(input => metadatos_sensores:alertas) alert
WHERE metadatos_sensores:alertas IS NOT NULL;

-- Estadísticas por ubicación geográfica
SELECT 
  metadatos_sensores:ubicacion.estado::STRING as estado,
  tipo_energia,
  COUNT(*) as num_plantas,
  AVG(megawatts_generados) as promedio_mw,
  AVG(eficiencia) as eficiencia_promedio
FROM generacion_energia
WHERE metadatos_sensores:ubicacion.estado IS NOT NULL
GROUP BY metadatos_sensores:ubicacion.estado, tipo_energia
ORDER BY promedio_mw DESC;
```

### Funciones Especializadas para JSON

```sql
-- Función para extraer coordenadas GPS
CREATE OR REPLACE FUNCTION extraer_coordenadas(json_data VARIANT)
RETURNS STRING
LANGUAGE SQL
AS $$
  CONCAT(
    json_data:ubicacion.latitud::STRING, ',', 
    json_data:ubicacion.longitud::STRING
  )
$$;

-- Función para calcular distancia entre plantas
CREATE OR REPLACE FUNCTION calcular_distancia_plantas(lat1 NUMBER, lon1 NUMBER, lat2 NUMBER, lon2 NUMBER)
RETURNS NUMBER
LANGUAGE SQL
AS $$
  -- Fórmula de Haversine simplificada (en km)
  ROUND(
    6371 * ACOS(
      COS(RADIANS(lat1)) * 
      COS(RADIANS(lat2)) * 
      COS(RADIANS(lon2) - RADIANS(lon1)) + 
      SIN(RADIANS(lat1)) * 
      SIN(RADIANS(lat2))
    ), 2
  )
$$;

-- Usar las funciones
SELECT 
  planta_id,
  extraer_coordenadas(metadatos_sensores) as coordenadas,
  metadatos_sensores:ubicacion.estado::STRING as estado
FROM generacion_energia
WHERE metadatos_sensores:ubicacion IS NOT NULL;
```

### Vista Materializada para Análisis JSON

```sql
-- Crear vista optimizada para análisis frecuentes
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sensores_fenix AS
SELECT 
  planta_id,
  timestamp,
  tipo_energia,
  megawatts_generados,
  eficiencia,
  metadatos_sensores:ubicacion.estado::STRING as estado,
  metadatos_sensores:ubicacion.latitud::NUMBER as latitud,
  metadatos_sensores:ubicacion.longitud::NUMBER as longitud,
  metadatos_sensores:temperatura::NUMBER as temperatura,
  metadatos_sensores:radiacion::NUMBER as radiacion,
  metadatos_sensores:viento_mps::NUMBER as velocidad_viento,
  ARRAY_SIZE(metadatos_sensores:alertas) as num_alertas
FROM generacion_energia
WHERE metadatos_sensores IS NOT NULL;

-- Consulta optimizada usando la vista
SELECT 
  estado,
  tipo_energia,
  AVG(temperatura) as temp_promedio,
  AVG(megawatts_generados) as mw_promedio,
  SUM(num_alertas) as total_alertas
FROM mv_sensores_fenix
WHERE timestamp >= DATEADD('days', -7, CURRENT_TIMESTAMP())
GROUP BY estado, tipo_energia
ORDER BY mw_promedio DESC;
```

### Monitoreo en Tiempo Real

```sql
-- Query para dashboard en tiempo real de Fénix
CREATE OR REPLACE VIEW v_dashboard_plantas_tiempo_real AS
SELECT 
  planta_id,
  tipo_energia,
  metadatos_sensores:ubicacion.estado::STRING as estado,
  megawatts_generados,
  eficiencia,
  CASE 
    WHEN ARRAY_SIZE(metadatos_sensores:alertas) = 0 THEN 'OPERATIVO'
    WHEN ARRAY_SIZE(metadatos_sensores:alertas) <= 2 THEN 'ATENCION'
    ELSE 'CRITICO'
  END as estatus_planta,
  timestamp
FROM generacion_energia
WHERE timestamp >= DATEADD('hours', -1, CURRENT_TIMESTAMP());

-- Dashboard ejecutivo
SELECT * FROM v_dashboard_plantas_tiempo_real
ORDER BY timestamp DESC;
```

> aside positive
> **¡Excelente!** Ahora puedes manejar eficientemente los datos JSON complejos de nuestros sensores IoT en Fénix Energia. Esta capacidad es crucial para el monitoreo en tiempo real de nuestras plantas de generación.

<!-- ------------------------ -->
## Lección 4: Escalamiento Dinámico de Warehouses
Duration: 15

### Escalamiento para Demanda Energética Variable

En Fénix Energia, la demanda de análisis varía según:
- **Picos de consumo** eléctrico (mañana y noche)
- **Reportes regulatorios** mensuales para la CRE
- **Análisis predictivos** de generación
- **Emergencias** operacionales

### Configurar Warehouses Multi-Tamaño

```sql
-- Warehouse para análisis ligeros (consultas rápidas)
CREATE WAREHOUSE IF NOT EXISTS FENIX_LIGHT_WH
  WITH WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'Para consultas ligeras y monitoreo básico';

-- Warehouse para análisis pesados (ETL y ML)
CREATE WAREHOUSE IF NOT EXISTS FENIX_HEAVY_WH
  WITH WAREHOUSE_SIZE = 'LARGE'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE
  COMMENT = 'Para ETL pesado y machine learning';

-- Warehouse para emergencias (escalamiento rápido)
CREATE WAREHOUSE IF NOT EXISTS FENIX_EMERGENCY_WH
  WITH WAREHOUSE_SIZE = 'XLARGE'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'Para análisis críticos durante emergencias';
```

### Escalamiento Automático por Carga

```sql
-- Función para determinar warehouse apropiado
CREATE OR REPLACE FUNCTION seleccionar_warehouse_optimo(
  num_registros NUMBER,
  complejidad_query STRING
)
RETURNS STRING
LANGUAGE SQL
AS $$
  CASE 
    WHEN num_registros < 100000 AND complejidad_query = 'SIMPLE' THEN 'FENIX_LIGHT_WH'
    WHEN num_registros < 1000000 AND complejidad_query = 'MEDIUM' THEN 'FENIX_ANALYTICS_WH'
    WHEN num_registros >= 1000000 OR complejidad_query = 'COMPLEX' THEN 'FENIX_HEAVY_WH'
    ELSE 'FENIX_ANALYTICS_WH'
  END
$$;

-- Procedimiento para escalamiento dinámico
CREATE OR REPLACE PROCEDURE escalar_warehouse_dinamico(
  warehouse_name STRING,
  nuevo_tamano STRING
)
RETURNS STRING
LANGUAGE SQL
AS $$
BEGIN
  LET sql_command := 'ALTER WAREHOUSE ' || warehouse_name || 
                     ' SET WAREHOUSE_SIZE = ''' || nuevo_tamano || '''';
  EXECUTE IMMEDIATE :sql_command;
  RETURN 'Warehouse ' || warehouse_name || ' escalado a ' || nuevo_tamano;
END;
$$;
```

### Simulación de Carga Variable

```sql
-- Usar warehouse pequeño para consultas simples
USE WAREHOUSE FENIX_LIGHT_WH;

-- Query simple: verificación de estado
SELECT 
  COUNT(*) as total_plantas,
  SUM(megawatts_generados) as total_mw_actual
FROM generacion_energia
WHERE timestamp >= DATEADD('hours', -1, CURRENT_TIMESTAMP());

-- Cambiar a warehouse más grande para análisis complejo
USE WAREHOUSE FENIX_HEAVY_WH;

-- Query compleja: análisis predictivo de generación
WITH analisis_historico AS (
  SELECT 
    tipo_energia,
    DATE(timestamp) as fecha,
    HOUR(timestamp) as hora,
    AVG(megawatts_generados) as promedio_mw,
    AVG(eficiencia) as promedio_eficiencia,
    COUNT(*) as num_registros
  FROM generacion_energia
  WHERE timestamp >= DATEADD('days', -30, CURRENT_TIMESTAMP())
  GROUP BY tipo_energia, DATE(timestamp), HOUR(timestamp)
),
prediccion_base AS (
  SELECT 
    tipo_energia,
    hora,
    AVG(promedio_mw) as mw_esperado,
    STDDEV(promedio_mw) as variabilidad,
    AVG(promedio_eficiencia) as eficiencia_esperada
  FROM analisis_historico
  GROUP BY tipo_energia, hora
)
SELECT 
  p.tipo_energia,
  p.hora,
  ROUND(p.mw_esperado, 2) as generacion_esperada_mw,
  ROUND(p.mw_esperado - p.variabilidad, 2) as minimo_esperado,
  ROUND(p.mw_esperado + p.variabilidad, 2) as maximo_esperado,
  ROUND(p.eficiencia_esperada, 2) as eficiencia_promedio
FROM prediccion_base p
ORDER BY p.tipo_energia, p.hora;
```

### Monitoreo de Performance

```sql
-- Vista para monitorear performance de warehouses
CREATE OR REPLACE VIEW v_performance_warehouses AS
SELECT 
  warehouse_name,
  warehouse_size,
  AVG(total_elapsed_time)/1000 as avg_time_seconds,
  SUM(credits_used) as total_credits,
  COUNT(*) as num_queries,
  AVG(bytes_scanned)/1024/1024/1024 as avg_gb_scanned
FROM table(information_schema.query_history(
  dateadd('hours', -24, current_timestamp()),
  current_timestamp()
))
WHERE warehouse_name LIKE 'FENIX%'
GROUP BY warehouse_name, warehouse_size
ORDER BY total_credits DESC;

-- Consultar performance
SELECT * FROM v_performance_warehouses;
```

### Automatización de Escalamiento

```sql
-- Procedimiento para escalamiento automático basado en métricas
CREATE OR REPLACE PROCEDURE auto_escalar_warehouse()
RETURNS STRING
LANGUAGE SQL
AS $$
DECLARE
  tiempo_promedio NUMBER;
  creditos_usados NUMBER;
  warehouse_actual STRING;
  nuevo_tamano STRING;
BEGIN
  -- Obtener métricas de la última hora
  SELECT 
    AVG(total_elapsed_time)/1000,
    SUM(credits_used),
    warehouse_name
  INTO :tiempo_promedio, :creditos_usados, :warehouse_actual
  FROM table(information_schema.query_history(
    dateadd('hours', -1, current_timestamp()),
    current_timestamp()
  ))
  WHERE warehouse_name = 'FENIX_ANALYTICS_WH'
  GROUP BY warehouse_name;
  
  -- Lógica de escalamiento
  IF (:tiempo_promedio > 60 AND :creditos_usados > 5) THEN
    SET nuevo_tamano = 'LARGE';
  ELSEIF (:tiempo_promedio > 30 AND :creditos_usados > 2) THEN
    SET nuevo_tamano = 'MEDIUM';
  ELSE
    SET nuevo_tamano = 'SMALL';
  END IF;
  
  -- Ejecutar escalamiento
  LET sql_escalamiento := 'ALTER WAREHOUSE ' || :warehouse_actual || 
                          ' SET WAREHOUSE_SIZE = ''' || :nuevo_tamano || '''';
  EXECUTE IMMEDIATE :sql_escalamiento;
  
  RETURN 'Warehouse escalado a ' || :nuevo_tamano || 
         ' basado en tiempo promedio: ' || :tiempo_promedio || 's';
END;
$$;

-- Programar tarea de escalamiento automático
CREATE TASK IF NOT EXISTS task_auto_escalamiento
  WAREHOUSE = FENIX_ANALYTICS_WH
  SCHEDULE = 'USING CRON 0 */2 * * * UTC' -- Cada 2 horas
AS
  CALL auto_escalar_warehouse();

-- Activar la tarea (requiere privilegios EXECUTE TASK)
-- ALTER TASK task_auto_escalamiento RESUME;
```

### Configuración para Emergencias

```sql
-- Procedimiento de emergencia para escalamiento máximo
CREATE OR REPLACE PROCEDURE activar_modo_emergencia()
RETURNS STRING
LANGUAGE SQL
AS $$
BEGIN
  -- Escalar warehouse principal al máximo
  ALTER WAREHOUSE FENIX_ANALYTICS_WH SET WAREHOUSE_SIZE = 'XLARGE';
  ALTER WAREHOUSE FENIX_HEAVY_WH SET WAREHOUSE_SIZE = 'XLARGE';
  
  -- Reducir tiempo de auto-suspend para respuesta rápida
  ALTER WAREHOUSE FENIX_ANALYTICS_WH SET AUTO_SUSPEND = 30;
  ALTER WAREHOUSE FENIX_HEAVY_WH SET AUTO_SUSPEND = 30;
  
  -- Activar warehouse de emergencia
  ALTER WAREHOUSE FENIX_EMERGENCY_WH SET WAREHOUSE_SIZE = 'XLARGE';
  
  RETURN 'Modo emergencia activado - Todos los warehouses escalados al máximo';
END;
$$;

-- Procedimiento para volver a operación normal
CREATE OR REPLACE PROCEDURE desactivar_modo_emergencia()
RETURNS STRING
LANGUAGE SQL
AS $$
BEGIN
  -- Volver a tamaños normales
  ALTER WAREHOUSE FENIX_ANALYTICS_WH SET WAREHOUSE_SIZE = 'SMALL';
  ALTER WAREHOUSE FENIX_HEAVY_WH SET WAREHOUSE_SIZE = 'MEDIUM';
  
  -- Restaurar tiempos normales de auto-suspend
  ALTER WAREHOUSE FENIX_ANALYTICS_WH SET AUTO_SUSPEND = 60;
  ALTER WAREHOUSE FENIX_HEAVY_WH SET AUTO_SUSPEND = 300;
  
  -- Suspender warehouse de emergencia
  ALTER WAREHOUSE FENIX_EMERGENCY_WH SUSPEND;
  
  RETURN 'Modo normal restaurado - Warehouses optimizados para operación estándar';
END;
$$;
```

> aside negative
> **¡Crítico para Fénix!** El escalamiento dinámico de warehouses es esencial para manejar las fluctuaciones en la demanda de análisis de datos energéticos. Esto nos permite mantener performance óptima mientras controlamos costos.

<!-- ------------------------ -->
## Conclusión y Próximos Pasos
Duration: 5

### ¡Felicitaciones! 🎉

Has completado exitosamente el quickstart de **Snowflake Avanzado para Fénix Energia**. Ahora tienes las herramientas necesarias para:

### ✅ Lo que has aprendido:

- **Time Travel**: Proteger y recuperar datos críticos del sector energético
- **Control de Costos**: Optimizar gastos manteniendo performance
- **Análisis JSON**: Procesar datos IoT de plantas y sensores
- **Escalamiento**: Manejar cargas variables eficientemente

### 🚀 Próximos pasos para Fénix Energia:

1. **Implementar en Producción**
   - Configurar estos patrones en tu entorno real
   - Establecer monitoring proactivo
   - Crear alertas automáticas

2. **Expansión Avanzada**
   - Machine Learning con Snowpark
   - Integración con sistemas SCADA
   - Análisis predictivo de demanda

3. **Compliance y Seguridad**
   - Configurar auditorías para CRE
   - Implementar data governance
   - Establecer políticas de retención

### 📞 Contacto Fénix Energia

**Oficinas Corporativas:**
- **Dirección**: Lago Zúrich 245, Edif. Carso, Piso 5, Col. Ampliación Granada
- **Web**: [fenixenergia.com.mx](https://www.fenixenergia.com.mx/)

### 🔗 Recursos Adicionales

- [Documentación Snowflake](https://docs.snowflake.com/)
- [Mejores Prácticas de Costos](https://docs.snowflake.com/en/user-guide/cost-understanding.html)
- [Guía JSON en Snowflake](https://docs.snowflake.com/en/user-guide/semistructured-concepts.html)

> aside positive
> **¡Gracias!** Has completado tu entrenamiento en Snowflake para Fénix Energia. Estás listo para optimizar nuestras operaciones de datos energéticos. ⚡

---

**© 2025 Fénix Energia - Transformando el futuro energético de México** 🇲🇽 