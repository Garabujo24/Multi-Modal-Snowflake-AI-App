# 🏦 Monex Grupo Financiero - Analytics Hub

Sistema completo de análisis financiero con **Snowflake Cortex Analyst** y **Cortex Search** para Monex Grupo Financiero.

## 🌟 Características

- **🤖 Cortex Analyst**: Análisis de datos estructurados con consultas en lenguaje natural
- **🔍 Cortex Search**: Búsqueda inteligente en documentos y contratos
- **📊 Dashboard Ejecutivo**: Métricas en tiempo real con visualizaciones interactivas
- **💰 Análisis Financiero**: Factoraje, inversiones USD, tipos de cambio
- **🎨 Imagen Corporativa**: Diseño con colores y branding oficial de Monex

## 🚀 Instalación Rápida

### Opción 1: Instalación Automática (Recomendada)

1. **Ejecutar el script principal**:
   ```sql
   -- Copia y pega el contenido completo de quick_setup.sql en Snowflake
   ```

2. **Subir archivos**:
   - Sube `monex_semantic_model.yaml` a `@MONEX_DB.STAGES.SEMANTIC_MODELS`
   - Sube `monex_app.py` a `@MONEX_DB.STAGES.STREAMLIT_APP`

3. **Crear aplicación Streamlit**:
   ```sql
   CREATE OR REPLACE STREAMLIT MONEX_ANALYTICS_APP
       ROOT_LOCATION = '@MONEX_DB.STAGES.STREAMLIT_APP'
       MAIN_FILE = 'monex_app.py'
       QUERY_WAREHOUSE = MONEX_WH
       TITLE = 'Monex Grupo Financiero - Analytics Hub';
   ```

4. **Acceder**: Data > Streamlit Apps > MONEX_ANALYTICS_APP

### Opción 2: Instalación Paso a Paso

1. **Setup inicial**: `01_setup_database.sql`
2. **Datos sintéticos**: `02_insert_data.sql`
3. **Documentos**: `03_insert_documents.sql`
4. **Cortex Search**: `04_setup_cortex_search.sql`
5. **Despliegue**: `05_deploy_streamlit.sql`

## 📋 Contenido del Proyecto

### Archivos SQL
- `01_setup_database.sql` - Configuración inicial de BD, tablas y permisos
- `02_insert_data.sql` - Datos sintéticos de clientes, transacciones, inversiones
- `03_insert_documents.sql` - Documentos para Cortex Search
- `04_setup_cortex_search.sql` - Configuración de servicios de búsqueda
- `05_deploy_streamlit.sql` - Despliegue de aplicación Streamlit
- `quick_setup.sql` - Instalación completa en un solo archivo

### Archivos de Aplicación
- `monex_app.py` - Aplicación Streamlit principal
- `monex_semantic_model.yaml` - Modelo semántico para Cortex Analyst

## 💼 Servicios de Monex Incluidos

### Banca Corporativa
- Créditos empresariales y líneas de crédito
- Análisis de clientes por segmento (Empresarial, PYME)
- Métricas de volumen y rentabilidad

### Private Banking
- Estrategias de inversión USD:
  - USD Fixed Income (4.70% rendimiento)
  - Global Equity (12.82% rendimiento)
  - Conservative Strategy (6.68% rendimiento)
  - Moderate Strategy (8.58% rendimiento)
  - Aggressive Strategy (10.63% rendimiento)

### Factoraje
- Factoraje sin recurso y con recurso
- Cadenas productivas NAFIN
- Análisis por empresa deudora
- Tasas de descuento variables (12%-18%)

### Cambio de Divisas
- Operaciones spot USD/MXN
- Contratos forward
- Tipos de cambio históricos
- Análisis de volatilidad

## 🤖 Ejemplos de Uso

### Cortex Analyst (Consultas en Lenguaje Natural)

```
✅ "¿Cuáles son los ingresos totales por mes?"
✅ "¿Cuántos clientes tenemos por segmento?"
✅ "¿Cuál es el rendimiento promedio de las inversiones USD?"
✅ "¿Qué volumen de factoraje tenemos por empresa deudora?"
✅ "¿Cómo han variado los tipos de cambio en el último mes?"
```

### Cortex Search (Búsqueda en Documentos)

```
✅ "factoraje sin recurso"
✅ "inversiones USD private banking"
✅ "procedimientos cambio divisas"
✅ "crédito empresarial garantías"
✅ "comisiones factoraje NAFIN"
```

## 📊 Dashboard Ejecutivo

### Métricas Principales
- **Clientes Activos**: Total de clientes por segmento
- **Volumen Mensual**: Transacciones del mes actual
- **Inversiones USD**: Capital bajo administración
- **Factoraje Vigente**: Operaciones en curso

### Visualizaciones
- Distribución de transacciones por tipo
- Rendimiento por estrategia de inversión
- Evolución de tipos de cambio USD/MXN
- Top empresas deudoras en factoraje

## 🛠️ Requisitos Técnicos

### Snowflake
- Cuenta con privilegios de ACCOUNTADMIN
- Región US East (recomendado para Cortex)
- Acceso a Cortex Analyst y Cortex Search
- Warehouse tamaño SMALL o mayor

### Datos Incluidos
- **5,000** transacciones sintéticas
- **200** inversiones USD
- **300** operaciones de factoraje
- **90 días** de tipos de cambio
- **25** clientes (corporativos, PYME, private banking)
- **10** documentos para búsqueda

## 🔧 Configuración Avanzada

### Personalización de Colores
Modifica las variables en `monex_app.py`:
```python
MONEX_COLORS = {
    'primary': '#001f3f',      # Azul marino
    'secondary': '#0074D9',    # Azul claro
    'accent': '#2ECC40',       # Verde
    'warning': '#FF851B',      # Naranja
    'error': '#FF4136',        # Rojo
}
```

### Agregar Nuevos Servicios de Búsqueda
```sql
CREATE CORTEX SEARCH SERVICE NEW_SERVICE
    ON CONTENIDO
    ATTRIBUTES CATEGORIA, FECHA
    WAREHOUSE = MONEX_WH
    TARGET_LAG = '1 hour'
    AS (SELECT * FROM DOCUMENTOS WHERE CATEGORIA = 'NUEVA_CATEGORIA');
```

## 🐛 Solución de Problemas

### Error: "Cortex Analyst no responde"
- ✅ Verificar que `monex_semantic_model.yaml` esté subido
- ✅ Comprobar permisos de `SNOWFLAKE.CORTEX_USER`
- ✅ Validar sintaxis del modelo YAML

### Error: "Cortex Search no encuentra resultados"
- ✅ Verificar que los servicios estén en estado "READY"
- ✅ Comprobar que hay datos en la tabla DOCUMENTOS
- ✅ Validar permisos USAGE en los servicios

### Error: "Aplicación no carga"
- ✅ Verificar que `monex_app.py` esté en el stage correcto
- ✅ Comprobar permisos del rol MONEX_APP_ROLE
- ✅ Validar que el warehouse esté activo

## 📞 Contacto

Este proyecto simula el sistema de Monex Grupo Financiero para demostración de Snowflake Cortex.

**Monex Real**:
- 📞 55-5231-4500
- 🌐 www.monex.com.mx

## 📄 Licencia

Proyecto de demostración para Snowflake Cortex. Los datos son completamente sintéticos y no representan información real de clientes.

---

### 🎯 Próximos Pasos

1. Ejecuta `quick_setup.sql` en tu cuenta de Snowflake
2. Sube los archivos `monex_semantic_model.yaml` y `monex_app.py`
3. Crea la aplicación Streamlit
4. ¡Comienza a explorar tus datos con IA!

**¡Disfruta analizando datos financieros con el poder de Snowflake Cortex!** 🚀