-- =====================================================
-- MONEX CORTEX SEARCH - EJEMPLOS DE BÚSQUEDA
-- Guía completa para realizar búsquedas en documentos corporativos
-- =====================================================

-- Configuración inicial
USE DATABASE MONEX_CORTEX_SEARCH;
USE SCHEMA DOCUMENTS;
USE WAREHOUSE COMPUTE_WH;

-- =====================================================
-- 1. BÚSQUEDAS BÁSICAS
-- =====================================================

-- Búsqueda general sobre productos de inversión
SELECT * FROM TABLE(search_monex_documents('productos de inversión patrimonio'));

-- Búsqueda sobre servicios de banca corporativa
SELECT * FROM TABLE(search_monex_documents('banca corporativa crédito empresarial'));

-- Búsqueda sobre divisas y cambio de moneda
SELECT * FROM TABLE(search_monex_documents('divisas USD EUR tipo cambio'));

-- Búsqueda sobre instrumentos derivados
SELECT * FROM TABLE(search_monex_documents('derivados swaps opciones forwards'));

-- =====================================================
-- 2. BÚSQUEDAS AVANZADAS CON FILTROS
-- =====================================================

-- Búsqueda específica en documentos de banca corporativa
SELECT * FROM TABLE(search_monex_documents_advanced(
    'financiamiento capital trabajo', 
    'BANCA_CORPORATIVA'
));

-- Búsqueda en documentos de banca privada
SELECT * FROM TABLE(search_monex_documents_advanced(
    'gestión patrimonio fondos inversión', 
    'BANCA_PRIVADA'
));

-- Búsqueda en documentos de divisas
SELECT * FROM TABLE(search_monex_documents_advanced(
    'operaciones spot forward', 
    'DIVISAS_FX'
));

-- Búsqueda en documentos de derivados y riesgos
SELECT * FROM TABLE(search_monex_documents_advanced(
    'gestión riesgos hedging cobertura', 
    'DERIVADOS_RIESGOS'
));

-- =====================================================
-- 3. BÚSQUEDAS POR PRODUCTOS ESPECÍFICOS
-- =====================================================

-- Leasing y financiamiento de activos
SELECT * FROM TABLE(search_monex_documents('leasing arrendamiento financiero maquinaria'));

-- Cartas de crédito y comercio exterior
SELECT * FROM TABLE(search_monex_documents('cartas crédito comercio exterior importación exportación'));

-- Productos estructurados
SELECT * FROM TABLE(search_monex_documents('notas estructuradas certificados depósito'));

-- Servicios fiduciarios
SELECT * FROM TABLE(search_monex_documents('fideicomiso administración fiduciario'));

-- Fondos de inversión
SELECT * FROM TABLE(search_monex_documents('fondos inversión operadora patrimonio'));

-- =====================================================
-- 4. BÚSQUEDAS POR CARACTERÍSTICAS TÉCNICAS
-- =====================================================

-- Plataformas tecnológicas y APIs
SELECT * FROM TABLE(search_monex_documents('API WebTrader plataforma digital tecnología'));

-- Análisis de riesgo y metodologías
SELECT * FROM TABLE(search_monex_documents('VaR análisis riesgo metodología'));

-- Regulación y compliance
SELECT * FROM TABLE(search_monex_documents('regulación compliance CNBV Basel'));

-- Calificaciones crediticias
SELECT * FROM TABLE(search_monex_documents('calificación crediticia Fitch Standard Poors'));

-- =====================================================
-- 5. BÚSQUEDAS POR MERCADOS Y GEOGRAFÍA
-- =====================================================

-- Presencia internacional
SELECT * FROM TABLE(search_monex_documents('internacional Estados Unidos Europa Houston Londres'));

-- Mercados específicos
SELECT * FROM TABLE(search_monex_documents('México CDMX sucursales oficinas'));

-- Corresponsales bancarios
SELECT * FROM TABLE(search_monex_documents('corresponsales Wells Fargo Deutsche Bank HSBC'));

-- =====================================================
-- 6. BÚSQUEDAS POR SEGMENTOS DE CLIENTES
-- =====================================================

-- Clientes corporativos
SELECT * FROM TABLE(search_monex_documents('corporativo empresas grandes tesorería'));

-- Banca privada y wealth management
SELECT * FROM TABLE(search_monex_documents('banca privada wealth management alto patrimonio'));

-- Instituciones financieras
SELECT * FROM TABLE(search_monex_documents('instituciones financieras bancos fondos pensiones'));

-- =====================================================
-- 7. BÚSQUEDAS COMBINADAS CON ANÁLISIS
-- =====================================================

-- Búsqueda con análisis de relevancia
WITH search_results AS (
    SELECT * FROM TABLE(search_monex_documents('gestión activos portfolio'))
)
SELECT 
    document_title,
    business_area,
    relevance_score,
    CASE 
        WHEN relevance_score > 0.8 THEN 'Muy Relevante'
        WHEN relevance_score > 0.6 THEN 'Relevante'
        WHEN relevance_score > 0.4 THEN 'Moderadamente Relevante'
        ELSE 'Poco Relevante'
    END as relevance_category,
    snippet
FROM search_results
ORDER BY relevance_score DESC;

-- Análisis de cobertura por área de negocio
WITH search_coverage AS (
    SELECT 
        d.business_area,
        COUNT(*) as total_documents,
        AVG(LENGTH(d.content)) as avg_content_length
    FROM MONEX_DOCUMENTS d
    GROUP BY d.business_area
)
SELECT 
    business_area,
    total_documents,
    ROUND(avg_content_length, 0) as avg_chars,
    ROUND(avg_content_length / 1000, 1) as approx_pages
FROM search_coverage
ORDER BY total_documents DESC;

-- =====================================================
-- 8. BÚSQUEDAS ESPECÍFICAS POR CASOS DE USO
-- =====================================================

-- Caso de uso: Empresa exportadora busca cobertura cambiaria
SELECT 
    document_title,
    business_area,
    relevance_score,
    snippet
FROM TABLE(search_monex_documents('cobertura cambiaria exportación forward hedge USD'))
WHERE relevance_score > 0.3
ORDER BY relevance_score DESC;

-- Caso de uso: Empresa busca financiamiento para capital de trabajo
SELECT 
    document_title,
    business_area,
    relevance_score,
    snippet
FROM TABLE(search_monex_documents('financiamiento capital trabajo línea crédito'))
WHERE relevance_score > 0.3
ORDER BY relevance_score DESC;

-- Caso de uso: Inversionista busca productos estructurados
SELECT 
    document_title,
    business_area,
    relevance_score,
    snippet
FROM TABLE(search_monex_documents('productos estructurados certificados protección capital'))
WHERE relevance_score > 0.3
ORDER BY relevance_score DESC;

-- Caso de uso: Tesorero corporativo busca gestión de efectivo
SELECT 
    document_title,
    business_area,
    relevance_score,
    snippet
FROM TABLE(search_monex_documents('cash management tesorería concentración fondos'))
WHERE relevance_score > 0.3
ORDER BY relevance_score DESC;

-- =====================================================
-- 9. BÚSQUEDAS CON MÚLTIPLES TÉRMINOS Y SINÓNIMOS
-- =====================================================

-- Términos relacionados con inversión
SELECT * FROM TABLE(search_monex_documents('inversión portfolio patrimonio wealth management AUM'));

-- Términos relacionados con riesgo
SELECT * FROM TABLE(search_monex_documents('riesgo cobertura hedging derivatives risk management'));

-- Términos relacionados con tecnología
SELECT * FROM TABLE(search_monex_documents('digital tecnología API plataforma electronic trading'));

-- Términos relacionados con regulación
SELECT * FROM TABLE(search_monex_documents('regulación compliance CNBV Banxico normativa'));

-- =====================================================
-- 10. ANÁLISIS DE CALIDAD DE BÚSQUEDA
-- =====================================================

-- Verificar distribución de scores de relevancia
WITH relevance_analysis AS (
    SELECT 
        query_term,
        AVG(relevance_score) as avg_relevance,
        COUNT(*) as result_count,
        MAX(relevance_score) as max_relevance,
        MIN(relevance_score) as min_relevance
    FROM (
        SELECT 'productos inversión' as query_term, * FROM TABLE(search_monex_documents('productos inversión'))
        UNION ALL
        SELECT 'derivados riesgo' as query_term, * FROM TABLE(search_monex_documents('derivados riesgo'))
        UNION ALL
        SELECT 'banca corporativa' as query_term, * FROM TABLE(search_monex_documents('banca corporativa'))
        UNION ALL
        SELECT 'divisas cambio' as query_term, * FROM TABLE(search_monex_documents('divisas cambio'))
    )
    GROUP BY query_term
)
SELECT 
    query_term,
    ROUND(avg_relevance, 3) as avg_relevance,
    result_count,
    ROUND(max_relevance, 3) as max_relevance,
    ROUND(min_relevance, 3) as min_relevance
FROM relevance_analysis
ORDER BY avg_relevance DESC;

-- =====================================================
-- 11. BÚSQUEDAS PARA DIFERENTES ROLES
-- =====================================================

-- Para Directores Comerciales
SELECT * FROM TABLE(search_monex_documents('clientes corporativos productos rentabilidad comisiones ingresos'));

-- Para Tesoreros
SELECT * FROM TABLE(search_monex_documents('liquidez cash management tipo cambio cobertura riesgo'));

-- Para Analistas de Riesgo
SELECT * FROM TABLE(search_monex_documents('VaR exposición concentración límites contraparte'));

-- Para Gerentes de Producto
SELECT * FROM TABLE(search_monex_documents('productos características beneficios competitivos mercado'));

-- Para Ejecutivos de Cuenta
SELECT * FROM TABLE(search_monex_documents('servicios soluciones cliente relationship management'));

-- =====================================================
-- 12. MANTENIMIENTO Y MONITOREO
-- =====================================================

-- Verificar estado del servicio de búsqueda
SELECT SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('monex_documents_search') as service_status;

-- Estadísticas de uso del servicio
SELECT 
    'Total Documents' as metric,
    COUNT(*) as value
FROM MONEX_DOCUMENTS
UNION ALL
SELECT 
    'Business Areas',
    COUNT(DISTINCT business_area)
FROM MONEX_DOCUMENTS
UNION ALL
SELECT 
    'Document Types',
    COUNT(DISTINCT document_type)
FROM MONEX_DOCUMENTS;

-- Verificar integridad de contenido
SELECT 
    document_id,
    document_title,
    LENGTH(content) as content_length,
    CASE 
        WHEN content IS NULL THEN 'ERROR: Content is NULL'
        WHEN LENGTH(content) < 100 THEN 'WARNING: Content too short'
        WHEN LENGTH(content) > 50000 THEN 'INFO: Very long content'
        ELSE 'OK'
    END as content_status
FROM MONEX_DOCUMENTS
ORDER BY content_length DESC;

-- =====================================================
-- 13. EJEMPLOS DE INTEGRACIÓN CON APLICACIONES
-- =====================================================

-- Función para usar en aplicaciones con parámetros dinámicos
CREATE OR REPLACE FUNCTION search_with_context(
    user_query STRING,
    user_role STRING DEFAULT 'general',
    max_results INTEGER DEFAULT 5
)
RETURNS TABLE (
    document_id VARCHAR,
    document_title VARCHAR,
    business_area VARCHAR,
    relevance_score FLOAT,
    snippet VARCHAR,
    recommendation VARCHAR
)
LANGUAGE SQL
AS
$$
    WITH search_results AS (
        SELECT * FROM TABLE(search_monex_documents(user_query))
        LIMIT max_results
    )
    SELECT 
        document_id,
        document_title,
        business_area,
        relevance_score,
        snippet,
        CASE user_role
            WHEN 'tesorero' THEN 'Revisar secciones de gestión de riesgo y liquidez'
            WHEN 'comercial' THEN 'Enfocar en beneficios y casos de éxito'
            WHEN 'operaciones' THEN 'Verificar procesos y requisitos operativos'
            ELSE 'Revisar información general del producto/servicio'
        END as recommendation
    FROM search_results
    ORDER BY relevance_score DESC
$$;

-- Ejemplo de uso de la función contextual
SELECT * FROM TABLE(search_with_context('productos estructurados', 'tesorero', 3));

-- =====================================================
-- NOTAS IMPORTANTES PARA EL USO
-- =====================================================

/*
GUÍA DE MEJORES PRÁCTICAS:

1. ESTRUCTURA DE QUERIES:
   - Usar términos específicos del negocio financiero
   - Combinar sinónimos para mejores resultados
   - Incluir contexto (ej: "USD MXN" en lugar de solo "divisas")

2. INTERPRETACIÓN DE RELEVANCE SCORE:
   - 0.8-1.0: Muy relevante (match exacto o muy cercano)
   - 0.6-0.8: Relevante (contenido relacionado)
   - 0.4-0.6: Moderadamente relevante (contexto relacionado)
   - 0.0-0.4: Poco relevante (términos coincidentes menores)

3. OPTIMIZACIÓN DE BÚSQUEDAS:
   - Usar filtros de business_area para resultados más precisos
   - Combinar múltiples términos relacionados
   - Revisar snippets para contexto adicional

4. MANTENIMIENTO:
   - Refrescar el servicio después de agregar nuevos documentos
   - Monitorear performance y calidad de resultados
   - Actualizar contenido regularmente

5. CASOS DE USO TÍPICOS:
   - Búsqueda de productos por características
   - Identificación de soluciones para casos específicos
   - Comparación de opciones disponibles
   - Localización de información técnica
*/

-- Verificación final del setup
SELECT 
    '🎯 CORTEX SEARCH READY FOR USE!' as status,
    'Use the examples above to start searching Monex documents' as instructions,
    'Documents available: ' || COUNT(*) as document_count
FROM MONEX_DOCUMENTS;

