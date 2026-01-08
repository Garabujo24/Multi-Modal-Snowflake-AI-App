# Configuración del Entorno - Detección de Anomalías en Retail

## 📋 Descripción

Este directorio contiene los scripts SQL necesarios para configurar el entorno completo de Snowflake para el proyecto de **Detección de Anomalías en Retail**.

## 📁 Contenido

### `setup_environment.sql`

Script principal que configura todo el entorno de Snowflake, incluyendo:

#### **Sección 1: Configuración de Recursos**
- **Warehouse**: `CCONTROL_ANALYTICS_WH` (XSMALL, optimizado para ML)
- **Base de Datos**: `CCONTROL_DB`
- **Schema**: `CCONTROL_DB.ANALYTICS`
- **Roles**: `CCONTROL_DATA_SCIENTIST` con permisos apropiados
- **FinOps**: Configuración de timeout para control de costos
- **Tablas**:
  - `VENTAS_DIARIAS`: Tabla principal con datos de ventas multi-series
  - `CAT_SUCURSALES`: Catálogo de sucursales

#### **Sección 2: Generación de Datos Sintéticos**
- Generación de 365 días de datos históricos
- 15 sucursales distribuidas en 3 regiones (Norte, Centro, Sur)
- 3 tipos de tiendas (Del Sol, Woolworth, Noreste Grill)
- Variables exógenas:
  - **Clima**: Temperatura, precipitación, humedad
  - **Eventos**: Días festivos, promociones, eventos adversos
  - **Temporales**: Día de semana, fin de semana, quincena
- **6 tipos de anomalías sintéticas**:
  1. Evento climático extremo (Huracán en Cancún)
  2. Problema operativo (Falla eléctrica en CDMX)
  3. Construcción cercana (Obras viales en Monterrey)
  4. Ticket promedio anormalmente bajo (Error en sistema POS)
  5. Caída generalizada regional (Alerta de seguridad)
  6. Ticket promedio inusualmente alto (Temporada navideña)

## 🚀 Uso

### Requisitos Previos
- Acceso a una cuenta de Snowflake
- Permisos para crear Warehouses, Databases, Schemas, Roles y Tablas

### Ejecución

1. Conéctate a tu cuenta de Snowflake
2. Ejecuta el script completo `setup_environment.sql`
3. El script creará automáticamente:
   - Todos los recursos necesarios
   - Las tablas con sus estructuras
   - Los datos sintéticos (5,475 registros: 365 días × 15 sucursales)
   - Las anomalías inyectadas en los datos

### Tiempo de Ejecución Estimado
- **Configuración de recursos**: ~30 segundos
- **Generación de datos**: ~2-3 minutos
- **Total**: ~3-4 minutos

## 💰 FinOps - Control de Costos

El script incluye configuraciones de FinOps:

```sql
-- Warehouse con auto-suspensión agresiva
AUTO_SUSPEND = 60  -- Se suspende después de 1 minuto de inactividad
WAREHOUSE_SIZE = 'XSMALL'  -- Tamaño mínimo para minimizar costos

-- Timeout de sesión
ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = 3600;
```

### Estimación de Costos
- **Warehouse XSMALL**: ~$2/hora de créditos
- **Ejecución completa del script**: ~$0.10 - $0.15 USD
- **Almacenamiento**: ~1 MB (despreciable)

## 📊 Estructura de Datos

### Tabla: `VENTAS_DIARIAS`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| FECHA | DATE | Fecha de la venta |
| REGION | VARCHAR(50) | Región (Norte, Centro, Sur) |
| TIPO_TIENDA | VARCHAR(50) | Tipo de tienda |
| SUCURSAL | VARCHAR(100) | Nombre de la sucursal |
| SUCURSAL_ID | INTEGER | ID único de sucursal |
| VENTAS_TOTALES | DECIMAL(12,2) | Ventas totales del día |
| NUM_TRANSACCIONES | INTEGER | Número de transacciones |
| TICKET_PROMEDIO | DECIMAL(10,2) | Ticket promedio |
| NUM_CLIENTES | INTEGER | Número de clientes |
| TEMPERATURA_C | DECIMAL(4,1) | Temperatura en °C |
| PRECIPITACION_MM | DECIMAL(5,1) | Precipitación en mm |
| HUMEDAD_PCT | INTEGER | Humedad relativa (%) |
| ES_DIA_FESTIVO | BOOLEAN | Indica si es día festivo |
| ES_PROMOCION | BOOLEAN | Indica si hay promoción |
| ES_EVENTO_ADVERSO | BOOLEAN | Indica evento adverso |
| TIPO_EVENTO | VARCHAR(100) | Descripción del evento |
| DIA_SEMANA | INTEGER | Día de la semana (1-7) |
| ES_FIN_SEMANA | BOOLEAN | Indica si es fin de semana |
| ES_QUINCENA | BOOLEAN | Indica si es día de quincena |
| TIENE_ANOMALIA | BOOLEAN | Indica si tiene anomalía |
| TIPO_ANOMALIA | VARCHAR(50) | Tipo de anomalía |

### Tabla: `CAT_SUCURSALES`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| SUCURSAL_ID | INTEGER | ID único (PK) |
| SUCURSAL | VARCHAR(100) | Nombre de la sucursal |
| TIPO_TIENDA | VARCHAR(50) | Tipo de tienda |
| REGION | VARCHAR(50) | Región |
| ESTADO | VARCHAR(50) | Estado |
| CIUDAD | VARCHAR(100) | Ciudad |
| FECHA_APERTURA | DATE | Fecha de apertura |

## 🔄 Re-ejecución

El script utiliza `CREATE OR REPLACE`, por lo que puede ejecutarse múltiples veces sin problemas. Cada ejecución:
- Recreará las tablas (eliminando datos previos)
- Regenerará los datos sintéticos
- Aplicará las anomalías nuevamente

## 📝 Notas Importantes

1. **Reproducibilidad**: Los datos sintéticos utilizan funciones `HASH()` para garantizar reproducibilidad entre ejecuciones
2. **Fechas Relativas**: Las anomalías se insertan en fechas relativas a `CURRENT_DATE()`, por lo que cambiarán según la fecha de ejecución
3. **Permisos**: Asegúrate de tener los permisos necesarios antes de ejecutar el script
4. **Limpieza**: Si deseas eliminar todo el entorno, ejecuta:

```sql
DROP DATABASE IF EXISTS CCONTROL_DB CASCADE;
DROP WAREHOUSE IF EXISTS CCONTROL_ANALYTICS_WH;
DROP ROLE IF EXISTS CCONTROL_DATA_SCIENTIST;
```

## 🆘 Soporte

Para problemas o preguntas sobre la configuración del entorno, consulta la documentación principal del proyecto o contacta al equipo de desarrollo.

---

**Última actualización**: Noviembre 2025  
**Versión**: 1.0  
**Autor**: Equipo de Data Science - CCONTROL




