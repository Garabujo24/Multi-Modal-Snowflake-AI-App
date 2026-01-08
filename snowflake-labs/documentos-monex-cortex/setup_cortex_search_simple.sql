-- =====================================================
-- MONEX GRUPO FINANCIERO - CORTEX SEARCH SETUP SIMPLE
-- Versión simplificada con sintaxis básica que funciona
-- =====================================================

-- Configurar variables de sesión
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- =====================================================
-- 1. CONFIGURACIÓN INICIAL
-- =====================================================

-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS MONEX_CORTEX_SEARCH
COMMENT = 'Base de datos para servicios de búsqueda Cortex Search de Monex Grupo Financiero';

-- Usar la base de datos
USE DATABASE MONEX_CORTEX_SEARCH;

-- Crear esquema para documentos
CREATE SCHEMA IF NOT EXISTS DOCUMENTS
COMMENT = 'Esquema para almacenar documentos y servicios de búsqueda';

USE SCHEMA DOCUMENTS;

-- =====================================================
-- 2. TABLA PARA DOCUMENTOS
-- =====================================================

-- Crear tabla para almacenar documentos corporativos
CREATE OR REPLACE TABLE MONEX_DOCUMENTS (
    document_id VARCHAR(100) PRIMARY KEY,
    document_title VARCHAR(500) NOT NULL,
    document_type VARCHAR(100) NOT NULL,
    business_area VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    file_name VARCHAR(200) NOT NULL,
    file_size_bytes NUMBER,
    upload_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    tags ARRAY,
    metadata VARIANT,
    created_by VARCHAR(100) DEFAULT 'system'
)
COMMENT = 'Tabla principal para almacenar documentos corporativos de Monex';

-- =====================================================
-- 3. INSERTAR DOCUMENTOS DE MONEX
-- =====================================================

-- Documento 1: Servicios de Banca Corporativa
INSERT INTO MONEX_DOCUMENTS 
SELECT 
    'MONEX-BC-001' as document_id,
    'Servicios de Banca Corporativa Monex' as document_title,
    'MANUAL_SERVICIOS' as document_type,
    'BANCA_CORPORATIVA' as business_area,
    'SERVICIOS DE BANCA CORPORATIVA MONEX. Monex Grupo Financiero es una institución financiera mexicana especializada en servicios corporativos, con más de 35 años de experiencia en el mercado financiero nacional e internacional. Fundada en 1985 por Héctor Lagos Dondé, Monex se ha consolidado como uno de los principales proveedores de servicios de cambio de divisas y soluciones financieras empresariales en México. La estructura organizacional incluye Banco Monex SA como Institución de Banca Múltiple, Monex Casa de Bolsa SA de CV para intermediación bursátil, y Monex Operadora de Fondos SA de CV para gestión de fondos de inversión. Los servicios de captación institucional incluyen sistema de ahorro institucional con tasas de rendimiento competitivas, acceso inmediato a fondos, gestión eficiente a través de plataformas digitales y asesoría personalizada. La cuenta digital empresarial ofrece apertura 100% digital, transferencias instantáneas 24/7, consulta de saldos en tiempo real e integración con sistemas contables. Los certificados de depósito a plazo corporativo tienen plazos desde 28 días hasta 360 días, tasas fijas garantizadas y montos desde 100,000 pesos. Los productos de crédito corporativo incluyen créditos comerciales especializados como líneas de crédito revolventes, créditos para capital de trabajo, financiamiento de proyectos específicos y tasas preferenciales para clientes recurrentes. Monex Leasing ofrece solución integral para adquisición de activos fijos con conservación del capital de trabajo, beneficios fiscales por deducibilidad, flexibilidad en estructuración de pagos y opciones para maquinaria industrial, flotillas vehiculares y equipos de cómputo. Los servicios de comercio exterior incluyen cartas de crédito comerciales tanto de importación como exportación, garantía de pago a proveedores extranjeros y plazos de hasta 180 días. Las cadenas productivas NAFIN ofrecen financiamiento de proveedores y compradores, factoraje de cuentas por cobrar de exportación y programas de desarrollo de proveedores. La gestión de efectivo y tesorería incluye cash management integral con concentración de fondos, administración de pagos, barrido automático de cuentas y dispersión masiva de nóminas. Las plataformas electrónicas de divisas proporcionan cotizaciones en tiempo real, ejecución instantánea de operaciones, spreads competitivos en todas las divisas y acceso 24/7 a mercados internacionales. Contacto: Oficinas Corporativas en Av. Paseo de la Reforma 284, Piso 15, Colonia Juárez, CDMX, teléfono 55 5231-4500, email corporativo@monex.com.mx, web www.monex.com.mx' as content,
    '01-servicios-banca-corporativa-monex.pdf' as file_name,
    2500 as file_size_bytes,
    CURRENT_TIMESTAMP() as upload_date,
    CURRENT_TIMESTAMP() as last_updated,
    ARRAY_CONSTRUCT('banca corporativa', 'crédito', 'tesorería', 'cash management', 'leasing', 'comercio exterior') as tags,
    OBJECT_CONSTRUCT(
        'target_audience', 'empresas corporativas',
        'language', 'español', 
        'region', 'méxico',
        'document_version', '1.0',
        'approval_status', 'approved'
    ) as metadata,
    'system' as created_by;

-- Documento 2: Productos de Inversión
INSERT INTO MONEX_DOCUMENTS 
SELECT 
    'MONEX-PI-002',
    'Productos de Inversión y Gestión de Patrimonio Monex',
    'MANUAL_PRODUCTOS',
    'BANCA_PRIVADA',
    'PRODUCTOS DE INVERSIÓN Y GESTIÓN DE PATRIMONIO MONEX. Monex Banca Privada se dedica a la preservación y crecimiento del patrimonio de individuos y familias de alto patrimonio neto, así como instituciones que buscan soluciones de inversión sofisticadas. El perfil de clientes incluye empresarios y profesionistas exitosos con patrimonio mínimo de USD 500,000, necesidades de diversificación internacional y objetivos de preservación y crecimiento a largo plazo. Las estrategias de inversión en USD incluyen USD Fixed Income como estrategia conservadora con inversión 100% en instrumentos de renta fija, perfil ideal para clientes conservadores, inversión exclusiva en ETFs listados en México y rendimiento anualizado desde inicio de 2.72%. Global Equity es una estrategia de crecimiento con inversión hasta 100% en acciones, mínimo 90% en renta variable principalmente ETFs, horizonte de inversión de largo plazo y rendimiento anualizado desde inicio de 74.62%. Conservative Global Strategy es una estrategia defensiva con 80% en USD Fixed Income y 20% en Global Equity, orientada a protección de capital con rendimiento anualizado desde inicio de 4.53%. Moderate Global Strategy es una estrategia balanceada con 60% en USD Fixed Income y 40% en Global Equity, participación activa en activos de riesgo y rendimiento anualizado desde inicio de 6.01%. Aggressive Global Strategy es una estrategia de crecimiento con 40% en USD Fixed Income y 60% en Global Equity, mayor tolerancia al riesgo y rendimiento anualizado desde inicio de 8.36%. Los fondos de inversión especializados de Monex Operadora de Fondos incluyen fondos de renta fija como Monex Deuda MX y Monex Global Bond USD, fondos de renta variable como Monex Equity Mexico y Monex Global Equity, y fondos mixtos como Monex Balanced Fund. Los productos del mercado de capitales incluyen trading de valores con acciones nacionales e internacionales, instrumentos de deuda gubernamental y corporativa, más de 15,000 instrumentos disponibles y ejecución multi-mercado. Las notas estructuradas posicionan a Monex como líder en el mercado mexicano con más de 1,700 notas estructuradas emitidas por 41,216 millones de pesos, incluyendo certificados de depósito estructurados, bonos bancarios estructurados y protección total o parcial de capital. Los servicios fiduciarios y patrimoniales incluyen fideicomisos especializados de administración, garantía e inmobiliarios con administración profesional de carteras. La Cuenta Personal Especial de Ahorro CPEA ofrece deducción anual hasta 152,000 MXN, exención de impuestos sobre rendimientos y retiro libre de impuestos después de 5 años. El Plan Personal de Retiro PPR es un sistema complementario de pensiones con aportaciones voluntarias deducibles, cobertura de seguros incluida y múltiples opciones de inversión. Contacto Banca Privada: Paseo de la Reforma 284, Piso 12, Col. Juárez, CDMX, teléfono 55 5231-4530, email bancaprivada@monex.com.mx, mínimos de inversión USD 500,000',
    '02-productos-inversion-gestion-patrimonio-monex.pdf',
    3200,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP(),
    ARRAY_CONSTRUCT('banca privada', 'inversión', 'patrimonio', 'fondos', 'estructurados', 'fiduciarios'),
    OBJECT_CONSTRUCT(
        'target_audience', 'banca privada',
        'language', 'español',
        'region', 'méxico', 
        'document_version', '1.0',
        'approval_status', 'approved'
    ),
    'system';

-- Documento 3: Servicios de Divisas
INSERT INTO MONEX_DOCUMENTS 
SELECT 
    'MONEX-FX-003',
    'Servicios de Divisas y Pagos Internacionales Monex',
    'MANUAL_SERVICIOS',
    'DIVISAS_FX',
    'SERVICIOS DE DIVISAS Y PAGOS INTERNACIONALES MONEX. Desde su fundación en 1985, Monex se ha consolidado como el líder indiscutible en el mercado mexicano de cambio de divisas con más de 35 años de experiencia. Las cifras de liderazgo incluyen más de 5 millones de transacciones anuales, volumen anual de USD 190,000 millones, participación de mercado del 35% del mercado retail mexicano y más de 40,000 clientes activos entre empresas e individuos. Los servicios de cambio de divisas incluyen operaciones spot de entrega inmediata, siendo USD/MXN el par estrella con spread típico de 1-3 centavos dependiendo del monto, monto mínimo de 1,000 USD, liquidación T+0 mismo día y horarios de 8:00 a 17:00 hrs horario México. Otras divisas principales incluyen EUR/MXN peso euro mexicano, GBP/MXN libra esterlina peso mexicano, CAD/MXN dólar canadiense peso mexicano y JPY/MXN yen japonés peso mexicano. Las operaciones a plazo forward tienen plazos de 1 día a 12 meses, todas las divisas principales y selectas emergentes, monto mínimo USD 10,000 equivalente y garantías por línea de crédito o colateral. Las opciones de divisas incluyen calls y puts europeas, opciones barrera knock-in y knock-out, y opciones asiáticas average rate. Los pagos y transferencias internacionales de Monex Global Payments cuentan con red de corresponsalías bancarias en Estados Unidos incluyendo Wells Fargo como cuenta principal para USD, JPMorgan Chase para backup y servicios especializados, y Bank of America para pagos retail y corporate. En Europa incluyen Deutsche Bank Alemania como hub para EUR, BNP Paribas Francia para servicios multi-divisa y Santander España para especialización iberoamericana. En Asia-Pacífico incluyen HSBC Hong Kong como gateway asiático, Bank of Tokyo-Mitsubishi para servicios JPY y DBS Singapore como hub del sudeste asiático. Los tipos de transferencias incluyen wire transfers tradicionales SWIFT estándar global, transferencias express same day value y bulk payments hasta 10,000 beneficiarios. Las plataformas tecnológicas FX incluyen Monex FX Pro plataforma institucional con trading engine latencia sub-10ms, price feeds múltiples proveedores de liquidez, risk management límites automáticos en tiempo real y conectividad FIX Protocol REST APIs WebSocket. Monex FX Retail plataforma para empresas incluye WebTrader acceso desde cualquier navegador, mobile app iOS y Android nativo, deal blotter historial completo de operaciones y market data precios en tiempo real. La presencia internacional incluye Monex USA con Monex Securities Inc Houston TX FINRA member SIPC protected y Tempus Inc adquirida 2010, regulación FINRA member SIPC protected y AUM USD 379 millones. Monex Europe incluye Monex Europe Limited Londres UK y Monex España Madrid, regulación FCA regulated y volumen EUR 500 millones anuales. El Centro de Análisis Monex cuenta con equipo de research incluyendo Chief Economist PhD en Economía 20+ años experiencia, FX Strategist CFA especialista en mercados emergentes y Technical Analyst CMT experto en análisis técnico. Las publicaciones incluyen Daily FX Commentary, Weekly FX Outlook y Monthly FX Strategy. Contacto Mesa de Cambios: Dealing Room +52 55 5231-4545, Institutional Sales +52 55 5231-4550, WebTrader portal.monex.com.mx, API Access developers.monex.com.mx',
    '03-servicios-divisas-pagos-internacionales-monex.pdf',
    4100,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP(),
    ARRAY_CONSTRUCT('divisas', 'FX', 'cambio', 'pagos internacionales', 'USD', 'EUR', 'forwards', 'opciones'),
    OBJECT_CONSTRUCT(
        'target_audience', 'tesoreros corporativos',
        'language', 'español',
        'region', 'méxico',
        'document_version', '1.0', 
        'approval_status', 'approved'
    ),
    'system';

-- Documento 4: Instrumentos Derivados
INSERT INTO MONEX_DOCUMENTS 
SELECT 
    'MONEX-DER-004',
    'Instrumentos Derivados y Manejo de Riesgos Monex',
    'MANUAL_PRODUCTOS',
    'DERIVADOS_RIESGOS', 
    'INSTRUMENTOS DERIVADOS Y MANEJO DE RIESGOS MONEX. Monex se posiciona como líder en México en el desarrollo y estructuración de instrumentos derivados, habiendo establecido durante 2022 un área de manejo de riesgos como una de las divisiones más dinámicas del banco. Con la emisión de 1,705 notas estructuradas por un nocional de 41,216 millones de pesos. El marco conceptual de riesgos financieros incluye tipos de riesgos financieros como riesgo de mercado con riesgo de tasa de interés por variaciones en el valor de activos/pasivos, riesgo cambiario por exposición a fluctuaciones en tipos de cambio y riesgo de precio de commodities por volatilidad en precios de materias primas. El riesgo de crédito incluye riesgo de contraparte por probabilidad de incumplimiento y riesgo de concentración por exposición excesiva a un solo emisor. El riesgo de liquidez incluye riesgo de financiamiento por incapacidad de cumplir obligaciones y riesgo de mercado de liquidez por dificultad para liquidar posiciones. Los derivados de tasas de interés incluyen Interest Rate Swaps IRS con pata fija donde cliente paga tasa fija anual, pata flotante donde cliente recibe TIIE 28 días + spread, frecuencia de pagos trimestrales o semestrales y nocional de 10 millones MXN mínimo. Los Forward Rate Agreements FRAs son swap de un solo período sobre tasa futura, settlement cash settlement en fecha de inicio, benchmark TIIE 28 TIIE 91 CETES 28 y plazos estándar 1x4 2x5 3x6 6x9 9x12. Los Caps Floors y Collars incluyen Interest Rate Caps para protección contra alza de tasas, Interest Rate Floors para protección contra baja de tasas e Interest Rate Collars como compra cap + venta floor. Los derivados de inflación incluyen UDI Swaps pata real vs pata nominal y TIIE Real Swaps tasa real fija vs TIIE Real. Los derivados de tipo de cambio incluyen Cross Currency Swaps con intercambio inicial de principal en ambas divisas, intercambio periódico de intereses en monedas respectivas, intercambio final reintercambio de principales y divisas USD/MXN EUR/MXN GBP/MXN. Las opciones de divisas incluyen opciones vanilla con Call Options USD/MXN Right to Buy USD contra MXN y Put Options USD/MXN Right to Sell USD contra MXN. Las estrategias con opciones incluyen Protective Put Collar, Risk Reversal y Straddle. Las opciones exóticas incluyen opciones barrera Knock-Out Knock-In y opciones asiáticas Average Rate Options. Los productos estructurados OTC incluyen notas estructuradas donde Monex lidera el mercado mexicano con más de 1,700 notas estructuradas emitidas en 2022, capital protegido 85%-100% del principal, upside participation exposición a subyacente específico y vencimiento 6 meses a 5 años. Los certificados ligados a equity incluyen S&P 500 Linked Certificate, Autocall Equity Certificate y Basket de acciones mexicanas. Los certificados de divisas incluyen USD/MXN Range Accrual y Multi-Currency Worst-Of. Los bonos bancarios estructurados incluyen Step-Up Floating Rate Notes, Inflation Plus Notes y Credit-Linked Notes. Los derivados de commodities incluyen WTI Crude Oil Participation Certificate, Pemex vs WTI Spread Note, Gold Participation Certificate y Agricultural Basket Note. La gestión integral de riesgos corporativos incluye assessment de riesgos corporativos con metodología de evaluación de identificación de exposiciones, cuantificación de riesgos y desarrollo de estrategia. Las herramientas de medición incluyen Bloomberg Risk & Analytics, Reuters Eikon, Monex Risk Platform y Monte Carlo Simulation. Las políticas de hedging incluyen hedging de riesgo cambiario con hedge ratio 50%-90% de exposición neta, horizon rolling 12-month hedging e instruments forwards 60% options 40%. El hedging de riesgo de tasa incluye Asset-Liability Management, Duration Matching activos vs pasivos y Gap Analysis vencimientos por períodos. Contacto Derivados y Riesgos: Mesa de Derivados +52 55 5231-4580, email derivados@monex.com.mx, Risk Advisory +52 55 5231-4595, email riskadvisory@monex.com.mx',
    '04-instrumentos-derivados-manejo-riesgos-monex.pdf',
    4800,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP(),
    ARRAY_CONSTRUCT('derivados', 'riesgos', 'swaps', 'opciones', 'estructurados', 'hedging', 'forwards'),
    OBJECT_CONSTRUCT(
        'target_audience', 'tesoreros corporativos',
        'language', 'español',
        'region', 'méxico',
        'document_version', '1.0',
        'approval_status', 'approved'
    ),
    'system';

-- =====================================================
-- 4. CREAR CORTEX SEARCH SERVICE
-- =====================================================

-- Crear el servicio de búsqueda Cortex Search
CREATE OR REPLACE CORTEX SEARCH SERVICE monex_documents_search
ON content
ATTRIBUTES document_title, document_type, business_area, tags
WAREHOUSE = COMPUTE_WH
TARGET_LAG = '1 hour'
AS (
    SELECT 
        document_id,
        content,
        document_title,
        document_type,
        business_area,
        tags,
        metadata
    FROM MONEX_DOCUMENTS
);

-- =====================================================
-- 5. VISTAS Y UTILIDADES BÁSICAS
-- =====================================================

-- Vista para estadísticas de documentos
CREATE OR REPLACE VIEW DOCUMENT_STATS AS
SELECT 
    COUNT(*) as total_documents,
    COUNT(DISTINCT business_area) as business_areas,
    COUNT(DISTINCT document_type) as document_types,
    AVG(LENGTH(content)) as avg_content_length,
    MIN(upload_date) as earliest_document,
    MAX(upload_date) as latest_document
FROM MONEX_DOCUMENTS;

-- Vista para documentos por área de negocio
CREATE OR REPLACE VIEW DOCUMENTS_BY_BUSINESS_AREA AS
SELECT 
    business_area,
    COUNT(*) as document_count,
    LISTAGG(document_title, '; ') as document_titles
FROM MONEX_DOCUMENTS
GROUP BY business_area
ORDER BY document_count DESC;

-- Procedimiento para refrescar el servicio
CREATE OR REPLACE PROCEDURE refresh_search_service()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    ALTER CORTEX SEARCH SERVICE monex_documents_search REFRESH;
    RETURN 'Search service refreshed successfully';
END;
$$;

-- =====================================================
-- 6. GRANTS Y PERMISOS
-- =====================================================

-- Crear rol para usuarios de búsqueda
CREATE ROLE IF NOT EXISTS MONEX_SEARCH_USER;

-- Otorgar permisos necesarios
GRANT USAGE ON DATABASE MONEX_CORTEX_SEARCH TO ROLE MONEX_SEARCH_USER;
GRANT USAGE ON SCHEMA DOCUMENTS TO ROLE MONEX_SEARCH_USER;
GRANT SELECT ON ALL TABLES IN SCHEMA DOCUMENTS TO ROLE MONEX_SEARCH_USER;
GRANT SELECT ON ALL VIEWS IN SCHEMA DOCUMENTS TO ROLE MONEX_SEARCH_USER;
GRANT USAGE ON ALL PROCEDURES IN SCHEMA DOCUMENTS TO ROLE MONEX_SEARCH_USER;

-- Otorgar uso del servicio de búsqueda
GRANT USAGE ON CORTEX SEARCH SERVICE monex_documents_search TO ROLE MONEX_SEARCH_USER;

-- =====================================================
-- 7. VALIDACIÓN BÁSICA
-- =====================================================

-- Verificar documentos insertados
SELECT 'Documents inserted' as status, COUNT(*) as count FROM MONEX_DOCUMENTS;

-- Verificar servicio de búsqueda
SELECT 'Search service status' as status, 
       SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('monex_documents_search') as service_status;

-- Mostrar estadísticas
SELECT * FROM DOCUMENT_STATS;
SELECT * FROM DOCUMENTS_BY_BUSINESS_AREA;

-- =====================================================
-- 8. EJEMPLOS DE USO DIRECTO (SIN FUNCIONES)
-- =====================================================

-- Crear vista con ejemplos de búsqueda directa
CREATE OR REPLACE VIEW SEARCH_EXAMPLES AS
SELECT * FROM VALUES
    ('Búsqueda básica', 'SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH_PREVIEW(''monex_documents_search'', ''productos de inversión''))'),
    ('Búsqueda de crédito', 'SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH_PREVIEW(''monex_documents_search'', ''crédito empresarial capital trabajo''))'),
    ('Búsqueda de derivados', 'SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH_PREVIEW(''monex_documents_search'', ''swaps tasas interés hedging''))'),
    ('Búsqueda de FX', 'SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH_PREVIEW(''monex_documents_search'', ''divisas USD EUR forward''))'),
    ('Productos estructurados', 'SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH_PREVIEW(''monex_documents_search'', ''notas estructuradas certificados''))'),
    ('Gestión de riesgos', 'SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH_PREVIEW(''monex_documents_search'', ''VaR exposición riesgo''))'),
    ('Servicios fiduciarios', 'SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH_PREVIEW(''monex_documents_search'', ''fideicomiso patrimonio administración''))'),
    ('Tecnología', 'SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH_PREVIEW(''monex_documents_search'', ''API WebTrader plataforma digital''))')
AS examples(description, query_example);

-- Mostrar ejemplos
SELECT * FROM SEARCH_EXAMPLES;

-- =====================================================
-- PRUEBAS BÁSICAS DE BÚSQUEDA
-- =====================================================

-- Prueba básica 1: Búsqueda general
SELECT 'Test 1: Basic search' as test_name;
SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH_PREVIEW('monex_documents_search', 'Monex banca corporativa')) LIMIT 5;

-- Prueba básica 2: Búsqueda de productos
SELECT 'Test 2: Product search' as test_name;
SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH_PREVIEW('monex_documents_search', 'productos inversión fondos')) LIMIT 5;

-- Prueba básica 3: Búsqueda de divisas
SELECT 'Test 3: FX search' as test_name;
SELECT * FROM TABLE(SNOWFLAKE.CORTEX.SEARCH_PREVIEW('monex_documents_search', 'divisas USD EUR')) LIMIT 5;

-- =====================================================
-- MENSAJE FINAL
-- =====================================================

SELECT '✅ CORTEX SEARCH SIMPLE SETUP COMPLETED! ✅' as message,
       'Ready to search with: SNOWFLAKE.CORTEX.SEARCH_PREVIEW(''monex_documents_search'', ''query'')' as description,
       'Use examples from SEARCH_EXAMPLES view for testing' as next_steps;

