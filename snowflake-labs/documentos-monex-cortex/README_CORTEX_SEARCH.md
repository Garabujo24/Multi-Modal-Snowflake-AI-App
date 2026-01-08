# 🔍 MONEX CORTEX SEARCH - CONFIGURACIÓN COMPLETA

## 📋 Descripción del Proyecto

Este proyecto implementa un sistema completo de búsqueda semántica usando **Snowflake Cortex Search** para los documentos corporativos de Monex Grupo Financiero. Permite realizar búsquedas inteligentes en documentación técnica, manuales de productos y guías de servicios.

## 🎯 Características Principales

- **Búsqueda Semántica Avanzada**: Entiende el contexto y significado de las consultas
- **4 Documentos Corporativos**: Cobertura completa de servicios Monex
- **Filtros Inteligentes**: Por área de negocio, tipo de documento y relevancia
- **APIs de Búsqueda**: Funciones SQL optimizadas para diferentes casos de uso
- **Análisis de Relevancia**: Scoring automático de resultados
- **Ejemplos Listos para Usar**: +50 queries de ejemplo

## 📚 Documentos Incluidos

### 1. **Servicios de Banca Corporativa** (`MONEX-BC-001`)
- **Área**: `BANCA_CORPORATIVA`
- **Contenido**: Captación institucional, créditos comerciales, leasing, comercio exterior
- **Tags**: banca corporativa, crédito, tesorería, cash management, leasing

### 2. **Productos de Inversión y Gestión de Patrimonio** (`MONEX-PI-002`)
- **Área**: `BANCA_PRIVADA`
- **Contenido**: 5 estrategias USD, fondos de inversión, productos estructurados, servicios fiduciarios
- **Tags**: banca privada, inversión, patrimonio, fondos, estructurados

### 3. **Servicios de Divisas y Pagos Internacionales** (`MONEX-FX-003`)
- **Área**: `DIVISAS_FX`
- **Contenido**: Operaciones spot/forward, opciones FX, pagos globales, plataformas tecnológicas
- **Tags**: divisas, FX, cambio, pagos internacionales, USD, EUR

### 4. **Instrumentos Derivados y Manejo de Riesgos** (`MONEX-DER-004`)
- **Área**: `DERIVADOS_RIESGOS`
- **Contenido**: Swaps, opciones, productos estructurados, gestión integral de riesgos
- **Tags**: derivados, riesgos, swaps, opciones, estructurados, hedging

## 🚀 Implementación Paso a Paso

### Paso 1: Ejecutar Setup Principal
```sql
-- Ejecutar el archivo principal de configuración
-- Este script crea todo lo necesario
@setup_cortex_search_monex.sql
```

### Paso 2: Verificar Instalación
```sql
-- Verificar que todo se creó correctamente
USE DATABASE MONEX_CORTEX_SEARCH;
USE SCHEMA DOCUMENTS;

-- Ver documentos cargados
SELECT * FROM DOCUMENT_STATS;

-- Verificar servicio de búsqueda
SELECT SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('monex_documents_search');
```

### Paso 3: Probar Búsquedas Básicas
```sql
-- Búsqueda simple
SELECT * FROM TABLE(search_monex_documents('productos de inversión'));

-- Búsqueda avanzada con filtros
SELECT * FROM TABLE(search_monex_documents_advanced(
    'derivados cobertura riesgo', 
    'DERIVADOS_RIESGOS'
));
```

## 📖 Guía de Uso

### Búsquedas Básicas
```sql
-- Función principal para búsquedas generales
SELECT * FROM TABLE(search_monex_documents('término de búsqueda'));

-- Ejemplos:
SELECT * FROM TABLE(search_monex_documents('banca corporativa'));
SELECT * FROM TABLE(search_monex_documents('divisas USD EUR'));
SELECT * FROM TABLE(search_monex_documents('fondos inversión'));
```

### Búsquedas Avanzadas
```sql
-- Función con filtros por área de negocio
SELECT * FROM TABLE(search_monex_documents_advanced(
    'query', 
    'business_area_filter',
    'document_type_filter'
));

-- Ejemplos:
SELECT * FROM TABLE(search_monex_documents_advanced(
    'crédito empresarial', 
    'BANCA_CORPORATIVA'
));
```

### Áreas de Negocio Disponibles
- `BANCA_CORPORATIVA`: Servicios para empresas
- `BANCA_PRIVADA`: Gestión de patrimonio e inversiones
- `DIVISAS_FX`: Operaciones cambiarias y pagos
- `DERIVADOS_RIESGOS`: Instrumentos derivados y gestión de riesgos

### Tipos de Documento
- `MANUAL_SERVICIOS`: Manuales de servicios corporativos
- `MANUAL_PRODUCTOS`: Guías de productos financieros

## 🎯 Casos de Uso Principales

### 1. **Para Ejecutivos Comerciales**
```sql
-- Buscar información sobre productos para clientes
SELECT * FROM TABLE(search_monex_documents('productos beneficios clientes corporativos'));
```

### 2. **Para Tesoreros Corporativos**
```sql
-- Encontrar soluciones de gestión de riesgo
SELECT * FROM TABLE(search_monex_documents('cobertura cambiaria hedging USD'));
```

### 3. **Para Analistas de Productos**
```sql
-- Investigar características técnicas
SELECT * FROM TABLE(search_monex_documents_advanced(
    'estructurados certificados', 
    'BANCA_PRIVADA'
));
```

### 4. **Para Atención al Cliente**
```sql
-- Responder preguntas específicas
SELECT * FROM TABLE(search_monex_documents('requisitos apertura cuenta'));
```

## 📊 Interpretación de Resultados

### Relevance Score
- **0.8 - 1.0**: Muy relevante (match exacto o muy cercano)
- **0.6 - 0.8**: Relevante (contenido relacionado)
- **0.4 - 0.6**: Moderadamente relevante (contexto relacionado)
- **0.0 - 0.4**: Poco relevante (coincidencias menores)

### Campos de Respuesta
- `document_id`: Identificador único del documento
- `document_title`: Título del documento
- `business_area`: Área de negocio
- `relevance_score`: Score de relevancia (0.0 - 1.0)
- `snippet`: Extracto del contenido (primeros 500 caracteres)

## 🔧 Administración y Mantenimiento

### Agregar Nuevos Documentos
```sql
-- Usar el procedimiento para agregar documentos
CALL add_document(
    'MONEX-NEW-001',
    'Título del Documento',
    'MANUAL_SERVICIOS',
    'BANCA_CORPORATIVA',
    'Contenido completo del documento...',
    'archivo.pdf',
    ARRAY_CONSTRUCT('tag1', 'tag2', 'tag3')
);
```

### Refrescar Índice de Búsqueda
```sql
-- Actualizar índice después de cambios
CALL refresh_search_service();
```

### Monitoreo del Sistema
```sql
-- Verificar estado del servicio
SELECT SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('monex_documents_search');

-- Ver estadísticas de documentos
SELECT * FROM DOCUMENT_STATS;

-- Analizar distribución por área
SELECT * FROM DOCUMENTS_BY_BUSINESS_AREA;
```

## 📝 Ejemplos de Búsqueda por Casos de Negocio

### Caso: Empresa Exportadora
```sql
-- Buscar información sobre cobertura cambiaria
SELECT * FROM TABLE(search_monex_documents('cobertura exportación forward USD hedge'));
```

### Caso: Inversionista Institucional
```sql
-- Encontrar productos de inversión
SELECT * FROM TABLE(search_monex_documents_advanced(
    'fondos patrimonio estrategias USD', 
    'BANCA_PRIVADA'
));
```

### Caso: CFO Corporativo
```sql
-- Buscar soluciones de financiamiento
SELECT * FROM TABLE(search_monex_documents('financiamiento capital trabajo línea crédito'));
```

### Caso: Tesorero Multinacional
```sql
-- Encontrar servicios de cash management
SELECT * FROM TABLE(search_monex_documents('cash management concentración fondos nómina'));
```

## 🎨 Personalización y Extensión

### Agregar Nuevas Áreas de Negocio
1. Modificar la tabla `MONEX_DOCUMENTS` si es necesario
2. Insertar documentos con la nueva área
3. Actualizar funciones de búsqueda si se requieren filtros específicos

### Crear Funciones Especializadas
```sql
-- Ejemplo: Función específica para búsqueda de productos
CREATE OR REPLACE FUNCTION search_products(query STRING)
RETURNS TABLE (...)
AS
$$
    SELECT ... FROM TABLE(search_monex_documents_advanced(query, NULL, 'MANUAL_PRODUCTOS'))
$$;
```

## 🔐 Seguridad y Permisos

### Roles Configurados
- `MONEX_SEARCH_USER`: Acceso de lectura y búsqueda
- `ACCOUNTADMIN`: Administración completa

### Otorgar Acceso a Usuarios
```sql
-- Asignar rol de búsqueda a usuarios
GRANT ROLE MONEX_SEARCH_USER TO USER nombre_usuario;
```

## 📈 Métricas y Análisis

### Analizar Calidad de Búsquedas
```sql
-- Ver distribución de scores de relevancia
WITH search_analysis AS (
    SELECT * FROM TABLE(search_monex_documents('término_frecuente'))
)
SELECT 
    AVG(relevance_score) as avg_relevance,
    COUNT(*) as total_results,
    COUNT(CASE WHEN relevance_score > 0.6 THEN 1 END) as high_relevance_count
FROM search_analysis;
```

## 🚨 Troubleshooting

### Problemas Comunes

1. **Servicio no responde**:
```sql
-- Verificar estado
SELECT SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('monex_documents_search');

-- Refrescar si es necesario
CALL refresh_search_service();
```

2. **Resultados de baja calidad**:
- Usar términos más específicos
- Combinar sinónimos relacionados
- Aplicar filtros por área de negocio

3. **No hay resultados**:
- Verificar que los documentos existen
- Revisar spelling de términos de búsqueda
- Usar términos más generales

## 📞 Soporte

Para soporte técnico o preguntas sobre implementación:
- Revisar logs de Snowflake
- Verificar permisos de usuario
- Consultar documentación de Cortex Search

## 🎉 ¡Listo para Usar!

El sistema está completamente configurado y listo para realizar búsquedas inteligentes en la documentación de Monex. Ejecuta los ejemplos proporcionados para familiarizarte con las capacidades del sistema.

```sql
-- ¡Prueba tu primera búsqueda!
SELECT * FROM TABLE(search_monex_documents('Monex productos servicios'));
```

