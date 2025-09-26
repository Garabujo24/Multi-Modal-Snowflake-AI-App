# 🏢 OfficeMax México - Cortex AI Platform

## 📋 Descripción del Proyecto

Este proyecto implementa una plataforma completa de inteligencia artificial para OfficeMax México utilizando **Snowflake Cortex Analyst** y **Cortex Search**, junto con una aplicación Streamlit que se ejecuta directamente en Snowflake.

### 🎯 Características Principales

- **🤖 Cortex Analyst**: Análisis inteligente de datos con consultas en lenguaje natural
- **🔍 Cortex Search**: Búsqueda semántica de documentos corporativos
- **📊 Dashboard Ejecutivo**: Métricas en tiempo real del negocio
- **📈 Analytics Avanzado**: Análisis de productos, sucursales y clientes
- **🎨 Imagen Corporativa**: Diseño completo con colores y estilo de OfficeMax México

## 🚀 Estructura del Proyecto

```
📁 officemax-cortex-platform/
├── 📄 officemax_mexico_setup.sql          # Configuración inicial de BD y datos
├── 📄 officemax_generate_data.sql         # Generación de datos sintéticos
├── 📄 officemax_semantic_model.yaml       # Modelo semántico para Cortex Analyst
├── 📄 officemax_cortex_setup.sql          # Configuración de servicios Cortex
├── 📄 officemax_streamlit_app.py          # Aplicación principal Streamlit
├── 📄 officemax_deploy_streamlit.sql      # Script de deployment en Snowflake
└── 📄 README_OFFICEMAX.md                 # Esta documentación
```

## 🛠️ Instalación y Configuración

### Paso 1: Configuración Inicial de Base de Datos

```sql
-- Ejecutar en Snowflake con rol SYSADMIN o ACCOUNTADMIN
@officemax_mexico_setup.sql
```

**Este script crea:**
- ✅ Base de datos `OFFICEMAX_MEXICO`
- ✅ Esquemas: `RAW_DATA`, `ANALYTICS`, `ML_MODELS`, `CORTEX_SERVICES`
- ✅ Warehouses optimizados
- ✅ Tablas: productos, clientes, ventas, inventario, sucursales
- ✅ Categorías jerárquicas de productos OfficeMax

### Paso 2: Generación de Datos Sintéticos

```sql
-- Generar ventas históricas, eventos y documentos
@officemax_generate_data.sql
```

**Este script genera:**
- ✅ Ventas históricas de 12 meses con patrones estacionales
- ✅ Eventos de marketing (Back-to-School, Black Friday, etc.)
- ✅ Documentos corporativos para Cortex Search
- ✅ Vistas analíticas optimizadas

### Paso 3: Configuración de Cortex Services

```sql
-- Configurar Cortex Analyst y Cortex Search
@officemax_cortex_setup.sql
```

**Este script configura:**
- ✅ Servicio Cortex Search para documentos
- ✅ Modelo semántico para Cortex Analyst
- ✅ Funciones wrapper para servicios
- ✅ Procedimientos de análisis avanzado
- ✅ Roles y permisos

### Paso 4: Deploy de Aplicación Streamlit

```sql
-- Desplegar aplicación en Snowflake
@officemax_deploy_streamlit.sql
```

**Este script despliega:**
- ✅ Aplicación Streamlit en Snowflake
- ✅ Usuario demo: `OFFICEMAX_DEMO_USER`
- ✅ Configuración de monitoreo
- ✅ Tasks de mantenimiento automático

### Paso 5: Subir Archivo de Aplicación

1. Ve a **Snowsight** > **Data** > **Databases** > **OFFICEMAX_MEXICO** > **CORTEX_SERVICES** > **Stages**
2. Selecciona **OFFICEMAX_STREAMLIT_STAGE**
3. Sube el archivo `officemax_streamlit_app.py`

## 🎮 Uso de la Aplicación

### Acceso a la Aplicación

1. **Snowsight** > **Streamlit**
2. Busca **OFFICEMAX_CORTEX_APP**
3. Haz clic para acceder

### Credenciales Demo

- **Usuario**: `OFFICEMAX_DEMO_USER`
- **Password**: `OfficeMax2024!`
- **Rol**: `OFFICEMAX_CORTEX_USER`

### Funcionalidades Disponibles

#### 📊 Dashboard Ejecutivo
- Métricas en tiempo real del negocio
- KPIs principales: ventas, productos, clientes, márgenes
- Gráficos interactivos por categoría y canal
- Tendencias mensuales y análisis comparativo

#### 🤖 Cortex Analyst
- Consultas en lenguaje natural
- Preguntas sugeridas predefinidas
- Análisis automático de datos
- Visualizaciones dinámicas de resultados

#### 🔍 Cortex Search
- Búsqueda semántica de documentos
- Filtros por tipo y categoría
- Resultados con relevancia ponderada
- Manuales, políticas, FAQs y tutoriales

#### 📈 Analytics Avanzado
- **Análisis de Productos**: Performance, márgenes, rotación
- **Performance Sucursales**: Comparativo por región y formato
- **Análisis de Clientes**: Segmentación y comportamiento

## 💾 Estructura de Datos

### Tablas Principales

| Tabla | Descripción | Registros Aprox. |
|-------|-------------|------------------|
| `PRODUCTOS` | Catálogo completo OfficeMax | 25+ productos |
| `CLIENTES` | Base de clientes B2B/B2C | 10+ clientes |
| `VENTAS` | Transacciones históricas | 1,000+ ventas |
| `SUCURSALES` | Red de tiendas | 12 sucursales |
| `INVENTARIO` | Stock por sucursal | 300+ registros |
| `DOCUMENTOS` | Base de conocimiento | 8+ documentos |

### Categorías de Productos

- **🖥️ Tecnología**: Computadoras, tablets, periféricos
- **📝 Papelería**: Escritura, papel, adhesivos
- **🎒 Material Escolar**: Mochilas, útiles, arte
- **🪑 Mobiliario**: Sillas, escritorios, archiveros

## 🎨 Diseño y UI/UX

### Colores Corporativos OfficeMax
- **Rojo Principal**: `#E31B24` 
- **Azul Secundario**: `#003B7A`
- **Naranja Acento**: `#FF6B35`
- **Verde Éxito**: `#28A745`

### Características de Diseño
- ✅ Header con gradientes corporativos
- ✅ Tarjetas de métricas con efectos hover
- ✅ Gráficos con paleta de colores OfficeMax
- ✅ Animaciones CSS sutiles
- ✅ Responsive design optimizado
- ✅ Elementos visuales de marca

## 🔧 Mantenimiento y Monitoreo

### Tasks Automáticos
- **Estadísticas Diarias**: Actualización de métricas de uso
- **Limpieza de Logs**: Eliminación de logs antiguos

### Monitoreo Disponible
```sql
-- Ver actividad de usuarios
SELECT * FROM CORTEX_SERVICES.APP_MONITORING;

-- Usuarios más activos
SELECT * FROM CORTEX_SERVICES.TOP_USERS;

-- Estado de salud
SELECT CORTEX_SERVICES.CHECK_APP_HEALTH();
```

### Configuración de la App
```sql
-- Ver configuración actual
SELECT * FROM CORTEX_SERVICES.APP_CONFIG;

-- Actualizar configuración
UPDATE CORTEX_SERVICES.APP_CONFIG 
SET CONFIG_VALUE = '"New Value"' 
WHERE CONFIG_KEY = 'APP_TITLE';
```

## 📊 Consultas de Ejemplo

### Cortex Analyst - Preguntas Sugeridas

```sql
-- Análisis de productos más vendidos
"¿Cuáles son los 10 productos más vendidos en los últimos 30 días?"

-- Performance por sucursal
"¿Cómo ha sido el performance de ventas por sucursal este mes?"

-- Análisis de márgenes
"¿Qué productos tienen los mejores márgenes de ganancia?"

-- Tendencias por categoría
"¿Cuáles son las tendencias de venta por categoría de producto?"
```

### Cortex Search - Búsquedas Comunes

```sql
-- Documentos técnicos
"manual configuración laptop impresora"

-- Políticas corporativas
"política garantía productos defectuosos"

-- Preguntas frecuentes
"preguntas frecuentes compras online"

-- Promociones
"promociones descuentos back to school"
```

## 🔍 Troubleshooting

### Problemas Comunes

**Error de conexión a Snowflake:**
```sql
-- Verificar permisos
SHOW GRANTS TO ROLE OFFICEMAX_CORTEX_USER;
```

**Cortex Search no funciona:**
```sql
-- Verificar servicio
SHOW CORTEX SEARCH SERVICES;
-- Recrear si es necesario
DROP CORTEX SEARCH SERVICE OFFICEMAX_DOCUMENTS_SEARCH;
-- Ejecutar nuevamente officemax_cortex_setup.sql
```

**Sin datos en dashboard:**
```sql
-- Verificar datos
SELECT COUNT(*) FROM RAW_DATA.VENTAS;
-- Si está vacío, ejecutar officemax_generate_data.sql
```

## 📈 Roadmap y Extensiones

### Próximas Características
- 🔄 **Cortex Agents**: Agentes conversacionales
- 📱 **App Móvil**: Versión responsive mejorada
- 🤖 **ML Models**: Predicciones de demanda
- 📧 **Alertas**: Notificaciones automáticas
- 🔗 **Integraciones**: APIs externas

### Personalización
- Modificar colores en `OFFICEMAX_COLORS`
- Agregar nuevas métricas en dashboard
- Extender modelo semántico con más tablas
- Crear nuevos análisis personalizados

## 🤝 Contribución y Soporte

### Estructura del Código
- **Backend**: SQL procedures y functions
- **Frontend**: Streamlit con Python
- **Data**: Modelo semántico YAML
- **Config**: Variables en tablas de configuración

### Mejores Prácticas
- ✅ Usar roles específicos para cada función
- ✅ Implementar logging de actividades
- ✅ Mantener documentación actualizada
- ✅ Monitorear performance regularmente

## 📄 Licencia

Este proyecto es una demostración para OfficeMax México utilizando tecnologías Snowflake Cortex.

---

## 🎉 ¡Listo para Usar!

Tu plataforma **OfficeMax México - Cortex AI Platform** está lista. Disfruta explorando las capacidades de inteligencia artificial con datos sintéticos realistas y una interfaz diseñada específicamente para la imagen corporativa de OfficeMax México.

**¿Preguntas?** Consulta la documentación en `CORTEX_SERVICES.APP_DOCUMENTATION` o revisa los logs de actividad para troubleshooting.

---

*Desarrollado con ❤️ para OfficeMax México usando Snowflake Cortex*


