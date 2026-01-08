# 🚀 Guía de Inicio Rápido - Detección de Anomalías C Control

## ⚡ Ejecución en 5 Minutos

### Paso 1: Ejecutar Script SQL en Snowflake (3 min)

1. **Abre Snowflake Worksheet**
   - Conéctate a tu cuenta Snowflake
   - Crea un nuevo Worksheet

2. **Copia y ejecuta el script completo**
   ```sql
   -- Abre el archivo: CCONTROL_Anomaly_Detection_Demo.sql
   -- Copia TODO el contenido y ejecútalo en Snowflake
   ```

3. **Verifica la ejecución**
   ```sql
   -- Debería retornar 3,285 registros
   SELECT COUNT(*) FROM CCONTROL_SCHEMA.VENTAS_DIARIAS;
   
   -- Debería retornar 9 sucursales
   SELECT COUNT(*) FROM CCONTROL_SCHEMA.SUCURSALES;
   ```

✅ **Listo!** Ya tienes el dataset sintético con anomalías

---

### Paso 2: Ejecutar Queries de Análisis (2 min)

1. **Detección básica de anomalías**
   ```sql
   -- Ejecuta la query de la Sección 3.2 del script SQL
   -- Te mostrará las anomalías detectadas en ventas
   ```

2. **Ver anomalías críticas**
   ```sql
   -- Ejecuta la query de la Sección 3.4 del script SQL
   -- Verás un reporte completo con clasificación de severidad
   ```

3. **Dashboard resumen**
   ```sql
   -- Ejecuta la query de la Sección 3.5 del script SQL
   -- Resumen de anomalías por tipo de tienda y región
   ```

---

## 📊 Opcional: Dashboard Interactivo con Streamlit

### Requisitos Previos

- Python 3.8 o superior
- Credenciales de Snowflake

### Instalación

```bash
# 1. Crea un entorno virtual
python -m venv venv

# 2. Activa el entorno
# En macOS/Linux:
source venv/bin/activate
# En Windows:
venv\Scripts\activate

# 3. Instala dependencias
pip install -r requirements.txt
```

### Configuración

```bash
# 1. Crea carpeta de configuración
mkdir .streamlit

# 2. Crea archivo de credenciales
cp .streamlit_secrets_example.toml .streamlit/secrets.toml

# 3. Edita el archivo con tus credenciales
nano .streamlit/secrets.toml  # o usa tu editor favorito
```

Contenido de `.streamlit/secrets.toml`:
```toml
[snowflake]
user = "tu_usuario"
password = "tu_password"
account = "tu_cuenta.region"
```

### Ejecución

```bash
# Ejecuta el dashboard
streamlit run visualizacion_anomalias.py
```

El dashboard se abrirá automáticamente en `http://localhost:8501`

---

## 🎯 ¿Qué Puedes Hacer?

### Con SQL Directo en Snowflake

✅ Detectar anomalías en ventas totales  
✅ Detectar anomalías en ticket promedio  
✅ Analizar impacto de variables exógenas (clima, eventos)  
✅ Comparar desempeño por región y tipo de tienda  
✅ Identificar patrones temporales (día de semana, mes)  
✅ Exportar resultados para Tableau/Power BI  

### Con Dashboard de Streamlit

✅ Visualización interactiva de series de tiempo  
✅ Filtros dinámicos por fecha, región, tipo de tienda  
✅ KPIs en tiempo real  
✅ Gráficas de correlación clima-ventas  
✅ Tabla de anomalías detectadas  
✅ Exportación de datos filtrados  

---

## 📁 Estructura del Proyecto

```
Anomaly Detection/
│
├── README.md                               # Documentación completa
├── QUICKSTART.md                           # Esta guía
│
├── CCONTROL_Anomaly_Detection_Demo.sql    # Script SQL principal ⭐
├── CCONTROL_Queries_Avanzadas.sql         # Queries adicionales
├── CCONTROL_semantic_model.yaml           # Modelo semántico Snowflake
│
├── visualizacion_anomalias.py             # Dashboard Streamlit
├── requirements.txt                        # Dependencias Python
└── .streamlit_secrets_example.toml        # Ejemplo de configuración
```

---

## 🔍 Queries Más Importantes

### 1. Detectar Anomalías en Ventas

```sql
SELECT 
    FECHA,
    TIPO_TIENDA,
    REGION,
    VENTAS_TOTALES,
    ANOMALY_DETECTION(VENTAS_TOTALES, TIPO_TIENDA, REGION) 
        OVER (PARTITION BY TIPO_TIENDA, REGION ORDER BY FECHA) AS SCORE
FROM CCONTROL_SCHEMA.VW_VENTAS_MULTISERIES
WHERE FECHA >= DATEADD(DAY, -90, CURRENT_DATE())
ORDER BY SCORE ASC
LIMIT 50;
```

### 2. Anomalías Críticas de Hoy

```sql
SELECT *
FROM CCONTROL_SCHEMA.VW_DASHBOARD_ANOMALIAS
WHERE FECHA = CURRENT_DATE()
  AND CLASIFICACION_ANOMALIA IN ('Crítica', 'Moderada')
ORDER BY SCORE_ANOMALIA_VENTAS ASC;
```

### 3. Resumen por Región

```sql
SELECT 
    REGION,
    COUNT(*) AS TOTAL_DIAS,
    SUM(CASE WHEN CLASIFICACION_ANOMALIA = 'Crítica' THEN 1 ELSE 0 END) AS ANOMALIAS_CRITICAS,
    ROUND(AVG(VENTAS_TOTALES), 2) AS PROMEDIO_VENTAS
FROM CCONTROL_SCHEMA.VW_DASHBOARD_ANOMALIAS
WHERE FECHA >= DATEADD(DAY, -30, CURRENT_DATE())
GROUP BY REGION
ORDER BY ANOMALIAS_CRITICAS DESC;
```

---

## 💡 Interpretación de Scores

| Score | Significado | Acción |
|-------|-------------|--------|
| < -2.5 | 🔴 Anomalía Crítica | Investigar inmediatamente |
| -2.5 a -1.5 | 🟠 Anomalía Moderada | Monitorear de cerca |
| -1.5 a 1.5 | ✅ Normal | No requiere acción |
| > 2.0 | 🟢 Pico Excepcional | Analizar causa positiva |

---

## ⚠️ Troubleshooting

### Error: "No se puede conectar a Snowflake"

**Solución:**
- Verifica que el warehouse `CCONTROL_WH` esté activo
- Confirma que tienes permisos en el rol SYSADMIN
- Revisa las credenciales en `.streamlit/secrets.toml`

### Error: "Tabla no existe"

**Solución:**
- Ejecuta primero el script `CCONTROL_Anomaly_Detection_Demo.sql` completo
- Verifica que estés usando el schema correcto:
  ```sql
  USE DATABASE CCONTROL_DB;
  USE SCHEMA CCONTROL_SCHEMA;
  ```

### Dashboard de Streamlit no carga datos

**Solución:**
1. Verifica la conexión a Snowflake en la sidebar
2. Confirma que la vista `VW_DASHBOARD_ANOMALIAS` existe:
   ```sql
   SHOW VIEWS LIKE 'VW_DASHBOARD_ANOMALIAS';
   ```
3. Revisa los logs en la terminal donde ejecutaste Streamlit

---

## 📞 Recursos Adicionales

- **Documentación completa**: Ver `README.md`
- **Queries avanzadas**: Ver `CCONTROL_Queries_Avanzadas.sql`
- **Snowflake Docs**: [ANOMALY_DETECTION()](https://docs.snowflake.com/en/sql-reference/functions/anomaly_detection)

---

## 🎓 Próximos Pasos Recomendados

1. ✅ **Ejecutar análisis exploratorio** con las queries de la Sección 3
2. ✅ **Identificar causas raíz** correlacionando anomalías con eventos adversos
3. ✅ **Crear alertas automáticas** con Snowflake Tasks
4. ✅ **Integrar con BI tools** (Tableau, Power BI) usando la vista de dashboard
5. ✅ **Entrenar modelos de forecasting** con `FORECAST()` de Snowflake

---

**¿Listo para empezar? 🚀**

Ejecuta el script SQL en Snowflake y comienza a detectar anomalías en minutos.

---

*Desarrollado para Grupo Comercial Control | Detección de Anomalías con Snowflake*

