# 💱 Integración con API de Banxico - Tipo de Cambio

## 📋 Descripción

Integración completa con la **API REST del Banco de México (Banxico)** para consultar y almacenar tipos de cambio interbancarios en Snowflake.

**Cliente:** Unstructured Docs  
**API:** https://www.banxico.org.mx/SieAPIRest/service/v1/  
**Serie Principal:** SF43718 - Tipo de Cambio FIX (Pesos por Dólar)

---

## 🎯 Características

✅ **Stored Procedure en Snowflake** para consultar la API de Banxico  
✅ **Almacenamiento automático** de tipos de cambio históricos  
✅ **Funciones de conversión** USD ↔ MXN  
✅ **Vistas de análisis** con estadísticas y tendencias  
✅ **Script de prueba en Python** para validar la API  
✅ **Automatización** con Snowflake Tasks (opcional)  
✅ **100% en español** y documentado

---

## 📁 Archivos Incluidos

| Archivo | Descripción |
|---------|-------------|
| `banxico_tipo_cambio.sql` | Script SQL completo para Snowflake (17 KB) |
| `test_api_banxico.py` | Script Python para probar la API antes de implementar |
| `requirements.txt` | Dependencias Python actualizadas |

---

## 🚀 Inicio Rápido

### Paso 1: Obtener Token de Banxico (GRATIS)

1. Visita: https://www.banxico.org.mx/SieAPIRest/service/v1/token
2. Llena el formulario con tu correo electrónico
3. Recibirás el token por email en minutos
4. El token es **gratuito** y permite **1000 peticiones/día**

### Paso 2: Probar la API con Python

```bash
# Instalar dependencias
pip3 install requests pandas

# Editar test_api_banxico.py y reemplazar TU_TOKEN_AQUI con tu token

# Ejecutar script de prueba
python3 test_api_banxico.py
```

**Salida esperada:**
```
✅ Conexión exitosa con Banxico
📊 Datos recibidos:
   Serie: SF43718 - Tipo de cambio FIX (Pesos por Dólar)
   Registros: 30

💵 Tipo de Cambio Más Reciente:
   Fecha: 2025-10-30
   Valor: $17.234567 MXN por USD
   Variación: +0.012345 (+0.07%)
```

### Paso 3: Implementar en Snowflake

1. **Abrir Snowsight** y cargar `banxico_tipo_cambio.sql`

2. **Ejecutar las secciones 1-2** para crear tablas y configuración:
```sql
-- Crear tablas
CREATE TABLE TIPO_CAMBIO_BANXICO (...);
CREATE TABLE CONFIG_API_BANXICO (...);
```

3. **Configurar tu token**:
```sql
UPDATE CONFIG_API_BANXICO
SET VALOR = 'tu_token_real_aqui',
    FECHA_ACTUALIZACION = CURRENT_TIMESTAMP()
WHERE PARAMETRO = 'TOKEN_API';
```

4. **Ejecutar las secciones 3-6** para crear stored procedures y funciones

5. **Probar el stored procedure**:
```sql
CALL SP_CONSULTAR_TIPO_CAMBIO_BANXICO(
    '2025-10-01',  -- Fecha inicio
    '2025-10-30',  -- Fecha fin
    (SELECT VALOR FROM CONFIG_API_BANXICO WHERE PARAMETRO = 'TOKEN_API')
);
```

6. **Verificar datos**:
```sql
SELECT * FROM TIPO_CAMBIO_BANXICO
ORDER BY FECHA DESC
LIMIT 10;
```

---

## 📊 Componentes Creados en Snowflake

### Tablas

| Tabla | Propósito |
|-------|-----------|
| `TIPO_CAMBIO_BANXICO` | Almacena tipos de cambio históricos |
| `CONFIG_API_BANXICO` | Configuración de la API (token, URLs) |

### Stored Procedures

| Procedure | Descripción |
|-----------|-------------|
| `SP_CONSULTAR_TIPO_CAMBIO_BANXICO` | Consulta tipos de cambio por rango de fechas |
| `SP_OBTENER_TIPO_CAMBIO_ACTUAL` | Obtiene el tipo de cambio más reciente |

### Funciones

| Función | Uso |
|---------|-----|
| `FN_OBTENER_TIPO_CAMBIO(fecha)` | Retorna el tipo de cambio de una fecha específica |
| `FN_CONVERTIR_USD_A_MXN(monto, fecha)` | Convierte dólares a pesos |
| `FN_CONVERTIR_MXN_A_USD(monto, fecha)` | Convierte pesos a dólares |

### Vistas

| Vista | Información |
|-------|-------------|
| `VW_TIPO_CAMBIO_RECIENTE` | Tipos de cambio del último mes con variaciones |
| `VW_TIPO_CAMBIO_ESTADISTICAS` | Estadísticas mensuales (min, max, promedio, mediana) |

---

## 💡 Ejemplos de Uso

### Consultar Tipo de Cambio Actual

```sql
CALL SP_OBTENER_TIPO_CAMBIO_ACTUAL();
-- Resultado: Tipo de cambio más reciente: $17.234567 MXN/USD al 2025-10-30
```

### Consultar Histórico de 30 Días

```sql
CALL SP_CONSULTAR_TIPO_CAMBIO_BANXICO(
    DATEADD(DAY, -30, CURRENT_DATE()),
    CURRENT_DATE(),
    (SELECT VALOR FROM CONFIG_API_BANXICO WHERE PARAMETRO = 'TOKEN_API')
);
```

### Ver Tipos de Cambio Almacenados

```sql
SELECT 
    FECHA,
    TIPO_CAMBIO,
    CONCAT('$', TIPO_CAMBIO, ' MXN por USD') AS FORMATO_LEGIBLE,
    FECHA_CONSULTA
FROM TIPO_CAMBIO_BANXICO
ORDER BY FECHA DESC
LIMIT 10;
```

### Convertir Montos

```sql
-- Convertir $1000 USD a MXN
SELECT FN_CONVERTIR_USD_A_MXN(1000, CURRENT_DATE()) AS PESOS_MEXICANOS;

-- Convertir $20,000 MXN a USD
SELECT FN_CONVERTIR_MXN_A_USD(20000, CURRENT_DATE()) AS DOLARES;
```

### Ver Estadísticas del Último Mes

```sql
SELECT * FROM VW_TIPO_CAMBIO_RECIENTE;
```

**Resultado:**
```
FECHA       | TIPO_CAMBIO | VARIACION_DIARIA | VARIACION_% | DIAS_ANTIGUO
------------|-------------|------------------|-------------|-------------
2025-10-30  | 17.234567   | +0.012345        | +0.07%      | 0
2025-10-29  | 17.222222   | -0.003456        | -0.02%      | 1
2025-10-28  | 17.225678   | +0.015432        | +0.09%      | 2
```

### Usar en Consultas de Documentos

```sql
-- Agregar tipo de cambio a recibos con montos en USD
SELECT 
    NOMBRE_ARCHIVO,
    MONTO_USD,
    FECHA_DOCUMENTO,
    FN_OBTENER_TIPO_CAMBIO(FECHA_DOCUMENTO) AS TIPO_CAMBIO,
    FN_CONVERTIR_USD_A_MXN(MONTO_USD, FECHA_DOCUMENTO) AS MONTO_MXN
FROM RECIBOS_INTERNACIONALES
WHERE FECHA_DOCUMENTO >= '2025-10-01';
```

---

## ⚙️ Automatización Opcional

### Actualización Diaria Automática

```sql
-- Crear task para actualización automática a las 6 PM
CREATE OR REPLACE TASK TASK_ACTUALIZAR_TIPO_CAMBIO
    WAREHOUSE = UNSTRUCTURED_DOCS_WH
    SCHEDULE = 'USING CRON 0 18 * * * America/Mexico_City'
    COMMENT = 'Actualiza el tipo de cambio diariamente'
AS
    CALL SP_OBTENER_TIPO_CAMBIO_ACTUAL();

-- Activar el task
ALTER TASK TASK_ACTUALIZAR_TIPO_CAMBIO RESUME;

-- Ver estado
SHOW TASKS LIKE 'TASK_ACTUALIZAR_TIPO_CAMBIO';

-- Pausar el task
ALTER TASK TASK_ACTUALIZAR_TIPO_CAMBIO SUSPEND;
```

---

## 📈 Casos de Uso

### 1. Conversión de Facturas Internacionales
```sql
-- Convertir facturas en USD a MXN para reporte fiscal
SELECT 
    FACTURA_ID,
    MONTO_USD,
    FECHA_FACTURA,
    FN_CONVERTIR_USD_A_MXN(MONTO_USD, FECHA_FACTURA) AS MONTO_MXN,
    FN_OBTENER_TIPO_CAMBIO(FECHA_FACTURA) AS TC_APLICADO
FROM FACTURAS_USD
WHERE YEAR(FECHA_FACTURA) = 2025;
```

### 2. Análisis de Impacto Cambiario
```sql
-- Ver impacto de variación cambiaria en operaciones
SELECT 
    DATE_TRUNC('MONTH', FECHA) AS MES,
    MIN(TIPO_CAMBIO) AS TC_MIN,
    MAX(TIPO_CAMBIO) AS TC_MAX,
    AVG(TIPO_CAMBIO) AS TC_PROM,
    (MAX(TIPO_CAMBIO) - MIN(TIPO_CAMBIO)) AS VOLATILIDAD,
    ROUND((MAX(TIPO_CAMBIO) - MIN(TIPO_CAMBIO)) / AVG(TIPO_CAMBIO) * 100, 2) AS VOLATILIDAD_PCT
FROM TIPO_CAMBIO_BANXICO
WHERE FECHA >= DATEADD(MONTH, -6, CURRENT_DATE())
GROUP BY DATE_TRUNC('MONTH', FECHA)
ORDER BY MES DESC;
```

### 3. Alertas de Tipo de Cambio
```sql
-- Detectar variaciones significativas (>1%)
SELECT 
    FECHA,
    TIPO_CAMBIO,
    LAG(TIPO_CAMBIO) OVER (ORDER BY FECHA) AS TC_ANTERIOR,
    ROUND(
        ((TIPO_CAMBIO - LAG(TIPO_CAMBIO) OVER (ORDER BY FECHA)) / 
        LAG(TIPO_CAMBIO) OVER (ORDER BY FECHA)) * 100, 
        2
    ) AS VARIACION_PCT
FROM TIPO_CAMBIO_BANXICO
WHERE FECHA >= DATEADD(DAY, -30, CURRENT_DATE())
QUALIFY ABS(VARIACION_PCT) > 1.0
ORDER BY FECHA DESC;
```

---

## 🔍 Diagnóstico y Monitoreo

### Verificar Estado del Sistema

```sql
-- Dashboard de tipo de cambio
SELECT 
    'Último tipo de cambio' AS METRICA,
    MAX(FECHA)::VARCHAR AS VALOR,
    DATEDIFF(DAY, MAX(FECHA), CURRENT_DATE())::VARCHAR || ' días' AS ANTIGUEDAD
FROM TIPO_CAMBIO_BANXICO
UNION ALL
SELECT 
    'Total de registros',
    COUNT(*)::VARCHAR,
    ''
FROM TIPO_CAMBIO_BANXICO
UNION ALL
SELECT 
    'Rango de fechas',
    CONCAT(MIN(FECHA), ' a ', MAX(FECHA)),
    ''
FROM TIPO_CAMBIO_BANXICO;
```

### Validar Datos

```sql
-- Verificar integridad
SELECT 
    'Registros duplicados' AS VALIDACION,
    COUNT(*) AS CASOS
FROM (
    SELECT FECHA, SERIE, COUNT(*) as cnt
    FROM TIPO_CAMBIO_BANXICO
    GROUP BY FECHA, SERIE
    HAVING COUNT(*) > 1
)
UNION ALL
SELECT 
    'Valores nulos',
    COUNT(*)
FROM TIPO_CAMBIO_BANXICO
WHERE TIPO_CAMBIO IS NULL
UNION ALL
SELECT 
    'Valores anómalos (< 10 o > 30)',
    COUNT(*)
FROM TIPO_CAMBIO_BANXICO
WHERE TIPO_CAMBIO < 10 OR TIPO_CAMBIO > 30;
```

---

## 📚 Series Adicionales Disponibles

Banxico ofrece más de 30,000 series económicas. Algunas relevantes:

| Serie | Descripción |
|-------|-------------|
| **SF43718** | Tipo de Cambio FIX (Pesos por Dólar) - **PRINCIPAL** |
| SF46410 | Tipo de Cambio Promedio (Pesos por Dólar) |
| SF60632 | TIIE 28 días (Tasa de Interés) |
| SF43783 | Tasa de fondeo bancario |
| SF61745 | Tipo de cambio Euro/Peso |
| SF43878 | Índice Nacional de Precios al Consumidor |

Para consultar el catálogo completo:
- Web: https://www.banxico.org.mx/SieAPIRest/service/v1/doc/catalogoSeries
- Script: `python3 test_api_banxico.py` (opción interactiva)

---

## ⚠️ Consideraciones Importantes

### Límites de la API
- ✅ **1000 peticiones por día** (más que suficiente)
- ✅ API **100% gratuita**
- ⚠️ El tipo de cambio FIX se publica después de las **12:00 del día siguiente**
- ⚠️ No hay datos para **fines de semana** ni **días festivos**

### Mejores Prácticas
1. **Cachear datos**: Almacenar tipos de cambio históricos evita consultas repetidas
2. **Actualización diaria**: Usar Tasks para automatizar a las 6 PM
3. **Validación**: Implementar checks de valores anómalos
4. **Logging**: Registrar cada consulta a la API
5. **Retry logic**: Reintentar en caso de errores transitorios

### Seguridad
- 🔒 **No compartir tu token** públicamente
- 🔒 Usar roles con permisos limitados en producción
- 🔒 Implementar **Row Level Security** si es necesario
- 🔒 Auditar accesos a la tabla de configuración

---

## 💰 FinOps - Costos

### API de Banxico
- ✅ **$0.00** - API completamente gratuita

### Snowflake
- **Compute**: ~0.001 créditos por consulta (despreciable)
- **Storage**: < 1 MB por año de datos (despreciable)
- **Tasks**: Si automatizas diariamente, ~0.03 créditos/mes

**Costo total mensual estimado: < $0.10 USD**

---

## 🛠️ Troubleshooting

### Error: "Token inválido o expirado"
```sql
-- Verificar token configurado
SELECT * FROM CONFIG_API_BANXICO WHERE PARAMETRO = 'TOKEN_API';

-- Actualizar token
UPDATE CONFIG_API_BANXICO
SET VALOR = 'nuevo_token_aqui'
WHERE PARAMETRO = 'TOKEN_API';
```

### Error: "No hay datos para el periodo"
- El tipo de cambio FIX no se publica en fines de semana
- Ampliar el rango de fechas o consultar días hábiles

### Error: "Timeout al conectar con Banxico"
- Verificar conectividad de red desde Snowflake
- Reintentar después de unos minutos
- Verificar si hay mantenimiento programado en Banxico

---

## 📞 Referencias y Recursos

### Documentación Oficial
- **API Banxico**: https://www.banxico.org.mx/SieAPIRest/service/v1/doc/introduccion
- **Catálogo de Series**: https://www.banxico.org.mx/SieAPIRest/service/v1/doc/catalogoSeries
- **Registro de Token**: https://www.banxico.org.mx/SieAPIRest/service/v1/token

### Snowflake
- **Python UDFs**: https://docs.snowflake.com/en/developer-guide/udf/python/udf-python
- **Tasks**: https://docs.snowflake.com/en/user-guide/tasks-intro
- **External Functions**: https://docs.snowflake.com/en/sql-reference/external-functions-introduction

### Soporte
- **Banxico**: webmaster@banxico.org.mx
- **Este proyecto**: Unstructured Docs

---

## 🔄 Actualizaciones y Mantenimiento

### Verificar Actualizaciones de la API
```bash
# Probar conexión con la API
python3 test_api_banxico.py
```

### Actualizar Datos Históricos
```sql
-- Cargar datos de todo el año actual
CALL SP_CONSULTAR_TIPO_CAMBIO_BANXICO(
    '2025-01-01',
    CURRENT_DATE(),
    (SELECT VALOR FROM CONFIG_API_BANXICO WHERE PARAMETRO = 'TOKEN_API')
);
```

### Backup de Datos
```sql
-- Exportar datos a tabla de respaldo
CREATE TABLE TIPO_CAMBIO_BANXICO_BACKUP AS
SELECT * FROM TIPO_CAMBIO_BANXICO;
```

---

## ✅ Checklist de Implementación

- [ ] Obtener token de Banxico
- [ ] Probar API con `test_api_banxico.py`
- [ ] Ejecutar `banxico_tipo_cambio.sql` en Snowflake
- [ ] Configurar token en tabla `CONFIG_API_BANXICO`
- [ ] Probar stored procedures
- [ ] Cargar datos históricos (últimos 30-90 días)
- [ ] Crear Task de actualización automática (opcional)
- [ ] Documentar uso para tu equipo
- [ ] Implementar casos de uso específicos

---

**Cliente:** Unstructured Docs  
**Versión:** 1.0  
**Fecha:** Octubre 2025  
**API:** Banco de México (Banxico)  

✨ **Integración lista para producción** ✨



