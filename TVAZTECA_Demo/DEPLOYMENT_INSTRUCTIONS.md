# Instrucciones de Deployment - TV Azteca Digital Cortex Search Demo

## 🎯 Objetivo
Guía paso a paso para hacer deployment de la aplicación TV Azteca Digital en **Streamlit in Snowflake**.

## 📋 Prerrequisitos

### Acceso a Snowflake
- ✅ Cuenta de Snowflake con privilegios SYSADMIN
- ✅ Streamlit in Snowflake habilitado
- ✅ Acceso a crear bases de datos y servicios de Cortex Search

### Archivos Necesarios
- ✅ `TVAZTECA_worksheet.sql` - Setup de infraestructura
- ✅ `streamlit_app.py` - Aplicación de búsqueda optimizada para SiS
- ✅ `tvazteca_chatbot_app.py` - **[NUEVO]** Chatbot con RAG y Cortex Complete
- ✅ `tvazteca_semantic_model.yaml` - Modelo semántico

## 🚀 Pasos de Deployment

### Paso 1: Configurar Infraestructura de Snowflake

1. **Abrir Snowsight**
   - Ir a tu instancia de Snowflake
   - Abrir Snowsight (nueva interfaz)

2. **Crear Worksheet**
   - Crear nuevo worksheet SQL
   - Copiar contenido de `TVAZTECA_worksheet.sql`

3. **Ejecutar Setup**
   ```sql
   -- Ejecutar sección por sección:
   -- 1. Section 0: Story and Use Case (leer y entender)
   -- 2. Section 1: Resource Setup (ejecutar completo)
   -- 3. Section 2: Synthetic Data Generation (ejecutar completo)
   -- 4. Section 3: The Demo (ejecutar parcial para crear servicio)
   ```

4. **Verificar Creación**
   ```sql
   -- Verificar que se crearon los recursos
   SHOW DATABASES LIKE 'TVAZTECA_DB';
   SHOW WAREHOUSES LIKE 'TVAZTECA_WH';
   
   -- Verificar servicio Cortex Search
   USE DATABASE TVAZTECA_DB;
   USE SCHEMA SEARCH_SCHEMA;
   SELECT SYSTEM$GET_SEARCH_SERVICE_STATUS('tv_azteca_search');
   ```

### Paso 2: Crear Aplicación Streamlit

1. **Navegar a Streamlit**
   - En Snowsight, ir a "Apps" en el menú lateral
   - Seleccionar "Streamlit"
   - Click en "Create Streamlit App"

2. **Configurar la App**
   
   **Opción A - Aplicación de Búsqueda:**
   ```
   App name: TV_Azteca_Digital_Search
   Warehouse: TVAZTECA_WH
   App location: 
     Database: TVAZTECA_DB
     Schema: RAW_SCHEMA
   ```

   **Opción B - Chatbot con RAG (Recomendado):**
   ```
   App name: TV_Azteca_Chatbot_RAG
   Warehouse: TVAZTECA_WH
   App location: 
     Database: TVAZTECA_DB
     Schema: RAW_SCHEMA
   ```

3. **Subir Código**
   
   **Para Búsqueda:** Copiar `streamlit_app.py`
   **Para Chatbot:** Copiar `tvazteca_chatbot_app.py` (Recomendado)

4. **Instalar Dependencias**
   - En el editor, crear archivo `requirements.txt`
   - Agregar:
     ```
     snowflake>=0.8.0
     pandas>=1.3.0
     plotly>=5.0.0
     ```

### Paso 3: Ejecutar y Verificar

1. **Ejecutar App**
   - Click en "Run" en la aplicación Streamlit
   - Esperar a que se inicialice (puede tomar 1-2 minutos)

2. **Verificar Conexión**
   - La app debe mostrar "✅ Conexión establecida con Snowflake"
   - Las métricas del sidebar deben cargar
   - No debe haber errores de conexión

3. **Probar Búsqueda**
   - Usar una consulta de ejemplo: "rating de Ventaneando"
   - Verificar que devuelve resultados relevantes
   - Probar filtros por departamento

### Paso 4: Configurar Permisos (Opcional)

1. **Compartir App**
   ```sql
   -- Crear rol para usuarios de la app
   CREATE OR REPLACE ROLE TV_AZTECA_USERS;
   
   -- Otorgar permisos necesarios
   GRANT USAGE ON WAREHOUSE TVAZTECA_WH TO ROLE TV_AZTECA_USERS;
   GRANT USAGE ON DATABASE TVAZTECA_DB TO ROLE TV_AZTECA_USERS;
   GRANT USAGE ON SCHEMA TVAZTECA_DB.RAW_SCHEMA TO ROLE TV_AZTECA_USERS;
   GRANT USAGE ON SCHEMA TVAZTECA_DB.ANALYTICS_SCHEMA TO ROLE TV_AZTECA_USERS;
   GRANT USAGE ON SCHEMA TVAZTECA_DB.SEARCH_SCHEMA TO ROLE TV_AZTECA_USERS;
   GRANT SELECT ON ALL TABLES IN SCHEMA TVAZTECA_DB.RAW_SCHEMA TO ROLE TV_AZTECA_USERS;
   GRANT SELECT ON ALL TABLES IN SCHEMA TVAZTECA_DB.ANALYTICS_SCHEMA TO ROLE TV_AZTECA_USERS;
   ```

2. **Asignar Rol a Usuarios**
   ```sql
   -- Asignar rol a usuarios específicos
   GRANT ROLE TV_AZTECA_USERS TO USER tu_usuario;
   ```

## 🔧 Troubleshooting

### Problema: "Error obteniendo sesión de Snowpark"
**Solución:**
- Verificar que la app se ejecute en Streamlit in Snowflake
- No usar localmente el archivo `streamlit_app.py`

### Problema: "Table 'CORPORATE_DOCUMENTS' does not exist"
**Solución:**
- Ejecutar completamente la Sección 1 y 2 del worksheet SQL
- Verificar que se creó la base de datos `TVAZTECA_DB`

### Problema: "Search service not found"
**Solución:**
```sql
-- Verificar estado del servicio
SELECT SYSTEM$GET_SEARCH_SERVICE_STATUS('tv_azteca_search');

-- Si no existe, crear manualmente
CREATE OR REPLACE CORTEX SEARCH SERVICE tv_azteca_search
ON CONTENT_TEXT
ATTRIBUTES DOCUMENT_NAME, DOCUMENT_TYPE, DEPARTMENT, KEYWORDS, PRIORITY_LEVEL
WAREHOUSE = TVAZTECA_WH
TARGET_LAG = '1 minute'
AS (
    SELECT 
        DOCUMENT_ID,
        CONTENT_TEXT,
        DOCUMENT_NAME,
        DOCUMENT_TYPE,
        DEPARTMENT,
        KEYWORDS,
        PRIORITY_LEVEL,
        DOCUMENT_SUMMARY
    FROM TVAZTECA_DB.RAW_SCHEMA.CORPORATE_DOCUMENTS
    WHERE CONTENT_TEXT IS NOT NULL
);
```

### Problema: Métricas no cargan
**Solución:**
- Verificar que se ejecutó la Sección 2 (datos sintéticos)
- Comprobar que hay datos en `SEARCH_METRICS`
```sql
SELECT COUNT(*) FROM TVAZTECA_DB.ANALYTICS_SCHEMA.SEARCH_METRICS;
```

## ✅ Checklist de Validación

- [ ] Base de datos `TVAZTECA_DB` creada
- [ ] Warehouse `TVAZTECA_WH` activo
- [ ] Tabla `CORPORATE_DOCUMENTS` con 20 registros
- [ ] Servicio `tv_azteca_search` en estado "READY"
- [ ] Aplicación Streamlit desplegada y funcionando
- [ ] Búsquedas devuelven resultados relevantes
- [ ] Dashboard y métricas cargan correctamente
- [ ] No hay errores en la consola

## 📞 Soporte

Si encuentras problemas durante el deployment:

1. **Verificar logs de Streamlit**
   - Revisar errores en la consola de la aplicación
   - Verificar que no falten imports

2. **Validar setup de Snowflake**
   - Ejecutar queries de validación del worksheet
   - Comprobar permisos y roles

3. **Contactar al equipo**
   - Documentar el error específico
   - Incluir screenshots de errores
   - Proporcionar información de la cuenta Snowflake

---

**¡Tu aplicación TV Azteca Digital estará lista en Streamlit in Snowflake!** 🚀📺
