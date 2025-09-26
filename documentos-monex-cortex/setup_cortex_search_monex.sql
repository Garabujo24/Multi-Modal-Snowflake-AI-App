-- =====================================================
-- MONEX GRUPO FINANCIERO - CORTEX SEARCH SETUP
-- Configuración de servicios de búsqueda para documentos corporativos
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

-- Insertar documento 1: Servicios de Banca Corporativa
INSERT INTO MONEX_DOCUMENTS (
    document_id,
    document_title,
    document_type,
    business_area,
    content,
    file_name,
    tags,
    metadata
) 
SELECT 
    'MONEX-BC-001',
    'Servicios de Banca Corporativa Monex',
    'MANUAL_SERVICIOS',
    'BANCA_CORPORATIVA',
    '# SERVICIOS DE BANCA CORPORATIVA MONEX

## Introducción a Monex Grupo Financiero

Monex Grupo Financiero es una institución financiera mexicana especializada en servicios corporativos, con más de 35 años de experiencia en el mercado financiero nacional e internacional. Fundada en 1985 por Héctor Lagos Dondé, quien continúa como presidente de la compañía, Monex se ha consolidado como uno de los principales proveedores de servicios de cambio de divisas y soluciones financieras empresariales en México.

### Estructura Organizacional
- Banco Monex, S.A. - Institución de Banca Múltiple
- Monex Casa de Bolsa, S.A. de C.V. - Intermediación bursátil
- Monex Operadora de Fondos, S.A. de C.V. - Gestión de fondos de inversión

### Presencia Internacional
- México: Oficinas corporativas en Ciudad de México
- Estados Unidos: Oficinas en Houston y Los Ángeles
- Europa: Operaciones en España y Reino Unido

## Servicios de Captación Institucional

### Sistema de Ahorro Institucional
Monex ofrece soluciones de captación para empresas e instituciones:
- Tasas de rendimiento competitivas
- Acceso inmediato a fondos
- Gestión eficiente a través de plataformas digitales
- Asesoría personalizada

### Cuenta Digital Empresarial
- Apertura 100% digital
- Transferencias instantáneas 24/7
- Consulta de saldos en tiempo real
- Integración con sistemas contables

### Certificados de Depósito a Plazo Corporativo
- Plazos desde 28 días hasta 360 días
- Tasas fijas garantizadas
- Montos desde $100,000 pesos

## Productos de Crédito Corporativo

### Créditos Comerciales Especializados
- Líneas de crédito revolventes
- Créditos para capital de trabajo
- Financiamiento de proyectos específicos
- Tasas preferenciales para clientes recurrentes

### Monex Leasing
Solución integral para adquisición de activos fijos:
- Conservación del capital de trabajo
- Beneficios fiscales por deducibilidad
- Flexibilidad en estructuración de pagos
- Maquinaria industrial, flotillas vehiculares, equipos de cómputo

## Servicios de Comercio Exterior

### Cartas de Crédito Comerciales
- Cartas de crédito de importación
- Cartas de crédito de exportación
- Garantía de pago a proveedores extranjeros
- Plazos de hasta 180 días

### Cadenas Productivas NAFIN
- Financiamiento de proveedores y compradores
- Factoraje de cuentas por cobrar de exportación
- Programas de desarrollo de proveedores

## Gestión de Efectivo y Tesorería

### Cash Management Integral
- Concentración de fondos
- Administración de pagos
- Barrido automático de cuentas
- Dispersión masiva de nóminas

### Plataformas Electrónicas de Divisas
- Cotizaciones en tiempo real
- Ejecución instantánea de operaciones
- Spreads competitivos en todas las divisas
- Acceso 24/7 a mercados internacionales

## Contacto
Oficinas Corporativas: Av. Paseo de la Reforma 284, Piso 15, Colonia Juárez, CDMX
Teléfono: 55 5231-4500
Email: corporativo@monex.com.mx
Web: www.monex.com.mx',
    '01-servicios-banca-corporativa-monex.pdf',
    ARRAY_CONSTRUCT('banca corporativa', 'crédito', 'tesorería', 'cash management', 'leasing', 'comercio exterior'),
    OBJECT_CONSTRUCT(
        'target_audience', 'empresas corporativas',
        'language', 'español',
        'region', 'méxico',
        'document_version', '1.0',
        'approval_status', 'approved'
    );

-- Insertar documento 2: Productos de Inversión
INSERT INTO MONEX_DOCUMENTS (
    document_id,
    document_title,
    document_type,
    business_area,
    content,
    file_name,
    tags,
    metadata
) 
SELECT 
    'MONEX-PI-002',
    'Productos de Inversión y Gestión de Patrimonio Monex',
    'MANUAL_PRODUCTOS',
    'BANCA_PRIVADA',
    '# PRODUCTOS DE INVERSIÓN Y GESTIÓN DE PATRIMONIO MONEX

## Banca Privada Monex: Filosofía y Enfoque

Monex Banca Privada se dedica a la preservación y crecimiento del patrimonio de individuos y familias de alto patrimonio neto, así como instituciones que buscan soluciones de inversión sofisticadas.

### Perfil de Clientes
- Empresarios y profesionistas exitosos
- Patrimonio mínimo de USD $500,000
- Necesidades de diversificación internacional
- Objetivos de preservación y crecimiento a largo plazo

## Estrategias de Inversión en USD

### USD Fixed Income - Estrategia Conservadora
- Inversión 100% en instrumentos de renta fija
- Perfil ideal para clientes conservadores
- Inversión exclusiva en ETFs listados en México
- Rendimiento anualizado desde inicio: 2.72%

### Global Equity - Estrategia de Crecimiento
- Inversión hasta 100% en acciones
- Mínimo 90% en renta variable (principalmente ETFs)
- Horizonte de inversión de largo plazo
- Rendimiento anualizado desde inicio: 74.62%

### Conservative Global Strategy - Estrategia Defensiva
- 80% en USD Fixed Income
- 20% en Global Equity
- Orientada a protección de capital
- Rendimiento anualizado desde inicio: 4.53%

### Moderate Global Strategy - Estrategia Balanceada
- 60% en USD Fixed Income
- 40% en Global Equity
- Participación activa en activos de riesgo
- Rendimiento anualizado desde inicio: 6.01%

### Aggressive Global Strategy - Estrategia de Crecimiento
- 40% en USD Fixed Income
- 60% en Global Equity
- Mayor tolerancia al riesgo
- Rendimiento anualizado desde inicio: 8.36%

## Fondos de Inversión Especializados

### Monex Operadora de Fondos
- Fondos de renta fija: Monex Deuda MX, Monex Global Bond USD
- Fondos de renta variable: Monex Equity Mexico, Monex Global Equity
- Fondos mixtos: Monex Balanced Fund

## Productos del Mercado de Capitales

### Trading de Valores
- Acciones nacionales e internacionales
- Instrumentos de deuda gubernamental y corporativa
- Más de 15,000 instrumentos disponibles
- Ejecución multi-mercado

### Notas Estructuradas
Monex líder en el mercado mexicano con más de 1,700 notas estructuradas emitidas por $41,216 millones de pesos:
- Certificados de Depósito Estructurados
- Bonos Bancarios Estructurados
- Protección total o parcial de capital

## Servicios Fiduciarios y Patrimoniales

### Fideicomisos Especializados
- Fideicomisos de administración
- Fideicomisos de garantía
- Fideicomisos inmobiliarios
- Administración profesional de carteras

### Cuenta Personal Especial de Ahorro (CPEA)
- Deducción anual hasta $152,000 MXN
- Exención de impuestos sobre rendimientos
- Retiro libre de impuestos después de 5 años

### Plan Personal de Retiro (PPR)
- Sistema complementario de pensiones
- Aportaciones voluntarias deducibles
- Cobertura de seguros incluida
- Múltiples opciones de inversión

## Contacto Banca Privada
Paseo de la Reforma 284, Piso 12, Col. Juárez, CDMX
Teléfono: 55 5231-4530
Email: bancaprivada@monex.com.mx
Mínimos de Inversión: USD $500,000',
    '02-productos-inversion-gestion-patrimonio-monex.pdf',
    ARRAY_CONSTRUCT('banca privada', 'inversión', 'patrimonio', 'fondos', 'estructurados', 'fiduciarios'),
    OBJECT_CONSTRUCT(
        'target_audience', 'banca privada',
        'language', 'español',
        'region', 'méxico',
        'document_version', '1.0',
        'approval_status', 'approved'
    );

-- Insertar documento 3: Servicios de Divisas
INSERT INTO MONEX_DOCUMENTS (
    document_id,
    document_title,
    document_type,
    business_area,
    content,
    file_name,
    tags,
    metadata
) 
SELECT 
    'MONEX-FX-003',
    'Servicios de Divisas y Pagos Internacionales Monex',
    'MANUAL_SERVICIOS',
    'DIVISAS_FX',
    '# SERVICIOS DE DIVISAS Y PAGOS INTERNACIONALES MONEX

## Monex: Pionero en el Mercado de Divisas Mexicano

Desde su fundación en 1985, Monex se ha consolidado como el líder indiscutible en el mercado mexicano de cambio de divisas con más de 35 años de experiencia.

### Cifras de Liderazgo
- Transacciones anuales: Más de 5 millones
- Volumen anual: USD $190,000 millones
- Participación de mercado: 35% del mercado retail mexicano
- Clientes activos: Más de 40,000 empresas e individuos

## Servicios de Cambio de Divisas

### Operaciones Spot (Entrega Inmediata)

#### USD/MXN - Par Estrella
- Spread típico: 1-3 centavos (dependiendo del monto)
- Monto mínimo: $1,000 USD
- Liquidación: T+0 (mismo día)
- Horarios: 8:00 - 17:00 hrs (horario México)

#### Otras Divisas Principales
- EUR/MXN: Euro peso mexicano
- GBP/MXN: Libra esterlina peso mexicano
- CAD/MXN: Dólar canadiense peso mexicano
- JPY/MXN: Yen japonés peso mexicano

### Operaciones a Plazo (Forward)
- Plazos: 1 día a 12 meses
- Divisas: Todas las principales y selectas emergentes
- Monto mínimo: USD $10,000 equivalente
- Garantías: Línea de crédito o colateral

### Opciones de Divisas
- Calls y Puts Europeas
- Opciones Barrera (Knock-in, Knock-out)
- Opciones Asiáticas (Average Rate)

## Pagos y Transferencias Internacionales

### Monex Global Payments

#### Red de Corresponsalías Bancarias
Estados Unidos:
- Wells Fargo: Cuenta principal para USD
- JPMorgan Chase: Backup y servicios especializados
- Bank of America: Pagos retail y corporate

Europa:
- Deutsche Bank (Alemania): Hub para EUR
- BNP Paribas (Francia): Servicios multi-divisa
- Santander (España): Especialización iberoamericana

Asia-Pacífico:
- HSBC Hong Kong: Gateway asiático
- Bank of Tokyo-Mitsubishi: Servicios JPY
- DBS Singapore: Hub del sudeste asiático

### Tipos de Transferencias
- Wire Transfers Tradicionales: SWIFT estándar global
- Transferencias Express: Same Day Value
- Bulk Payments: Hasta 10,000 beneficiarios

## Plataformas Tecnológicas FX

### Monex FX Pro - Plataforma Institucional
- Trading Engine: Latencia sub-10ms
- Price Feeds: Múltiples proveedores de liquidez
- Risk Management: Límites automáticos en tiempo real
- Conectividad: FIX Protocol, REST APIs, WebSocket

### Monex FX Retail - Plataforma para Empresas
- WebTrader: Acceso desde cualquier navegador
- Mobile App: iOS y Android nativo
- Deal Blotter: Historial completo de operaciones
- Market Data: Precios en tiempo real

## Presencia Internacional

### Monex USA
- Monex Securities Inc. (Houston, TX)
- Tempus Inc. (adquirida 2010)
- Regulación: FINRA member, SIPC protected
- AUM: USD $379 millones

### Monex Europe
- Monex Europe Limited (Londres, UK)
- Monex España (Madrid)
- Regulación: FCA regulated
- Volumen: EUR 500 millones anuales

## Centro de Análisis Monex

### Equipo de Research
- Chief Economist: PhD en Economía, 20+ años experiencia
- FX Strategist: CFA, especialista en mercados emergentes
- Technical Analyst: CMT, experto en análisis técnico

### Publicaciones
- Daily FX Commentary
- Weekly FX Outlook
- Monthly FX Strategy

## Contacto Mesa de Cambios
Dealing Room: +52 55 5231-4545
Institutional Sales: +52 55 5231-4550
WebTrader: portal.monex.com.mx
API Access: developers.monex.com.mx',
    '03-servicios-divisas-pagos-internacionales-monex.pdf',
    ARRAY_CONSTRUCT('divisas', 'FX', 'cambio', 'pagos internacionales', 'USD', 'EUR', 'forwards', 'opciones'),
    OBJECT_CONSTRUCT(
        'target_audience', 'tesoreros corporativos',
        'language', 'español',
        'region', 'méxico',
        'document_version', '1.0',
        'approval_status', 'approved'
    );

-- Insertar documento 4: Instrumentos Derivados
INSERT INTO MONEX_DOCUMENTS (
    document_id,
    document_title,
    document_type,
    business_area,
    content,
    file_name,
    tags,
    metadata
) 
SELECT 
    'MONEX-DER-004',
    'Instrumentos Derivados y Manejo de Riesgos Monex',
    'MANUAL_PRODUCTOS',
    'DERIVADOS_RIESGOS',
    '# INSTRUMENTOS DERIVADOS Y MANEJO DE RIESGOS MONEX

## Marco Conceptual de Riesgos Financieros

Monex se posiciona como líder en México en el desarrollo y estructuración de instrumentos derivados, habiendo establecido durante 2022 un área de manejo de riesgos como una de las divisiones más dinámicas del banco. Con la emisión de 1,705 notas estructuradas por un nocional de $41,216 millones de pesos.

### Tipos de Riesgos Financieros

#### Riesgo de Mercado
- Riesgo de Tasa de Interés: Variaciones en el valor de activos/pasivos
- Riesgo Cambiario: Exposición a fluctuaciones en tipos de cambio
- Riesgo de Precio de Commodities: Volatilidad en precios de materias primas

#### Riesgo de Crédito
- Riesgo de Contraparte: Probabilidad de incumplimiento
- Riesgo de Concentración: Exposición excesiva a un solo emisor

#### Riesgo de Liquidez
- Riesgo de Financiamiento: Incapacidad de cumplir obligaciones
- Riesgo de Mercado de Liquidez: Dificultad para liquidar posiciones

## Derivados de Tasas de Interés

### Interest Rate Swaps (IRS)
- Pata Fija: Cliente paga tasa fija anual
- Pata Flotante: Cliente recibe TIIE 28 días + spread
- Frecuencia: Pagos trimestrales o semestrales
- Nocional: $10 millones MXN mínimo

### Forward Rate Agreements (FRAs)
- Swap de un solo período sobre tasa futura
- Settlement: Cash settlement en fecha de inicio
- Benchmark: TIIE 28, TIIE 91, CETES 28
- Plazos estándar: 1x4, 2x5, 3x6, 6x9, 9x12

### Caps, Floors y Collars
- Interest Rate Caps: Protección contra alza de tasas
- Interest Rate Floors: Protección contra baja de tasas
- Interest Rate Collars: Compra cap + venta floor

### Derivados de Inflación
- UDI Swaps: Pata real vs pata nominal
- TIIE Real Swaps: Tasa real fija vs TIIE Real

## Derivados de Tipo de Cambio

### Cross Currency Swaps
- Intercambio inicial: Principal en ambas divisas
- Intercambio periódico: Intereses en monedas respectivas
- Intercambio final: Reintercambio de principales
- Divisas: USD/MXN, EUR/MXN, GBP/MXN

### Opciones de Divisas

#### Opciones Vanilla
- Call Options (USD/MXN): Right to Buy USD contra MXN
- Put Options (USD/MXN): Right to Sell USD contra MXN

#### Estrategias con Opciones
- Protective Put (Collar)
- Risk Reversal
- Straddle

#### Opciones Exóticas
- Opciones Barrera: Knock-Out, Knock-In
- Opciones Asiáticas: Average Rate Options

## Productos Estructurados OTC

### Notas Estructuradas
Monex lidera el mercado mexicano con más de 1,700 notas estructuradas emitidas en 2022:
- Capital Protegido: 85%-100% del principal
- Upside Participation: Exposición a subyacente específico
- Vencimiento: 6 meses a 5 años

#### Certificados Ligados a Equity
- S&P 500 Linked Certificate
- Autocall Equity Certificate
- Basket de acciones mexicanas

#### Certificados de Divisas
- USD/MXN Range Accrual
- Multi-Currency Worst-Of

### Bonos Bancarios Estructurados
- Step-Up Floating Rate Notes
- Inflation Plus Notes
- Credit-Linked Notes

### Derivados de Commodities
- WTI Crude Oil Participation Certificate
- Pemex vs WTI Spread Note
- Gold Participation Certificate
- Agricultural Basket Note

## Gestión Integral de Riesgos Corporativos

### Assessment de Riesgos Corporativos

#### Metodología de Evaluación
1. Identificación de Exposiciones
2. Cuantificación de Riesgos
3. Desarrollo de Estrategia

#### Herramientas de Medición
- Bloomberg Risk & Analytics
- Reuters Eikon
- Monex Risk Platform
- Monte Carlo Simulation

### Políticas de Hedging

#### Hedging de Riesgo Cambiario
- Hedge Ratio: 50%-90% de exposición neta
- Horizon: Rolling 12-month hedging
- Instruments: Forwards (60%), options (40%)

#### Hedging de Riesgo de Tasa
- Asset-Liability Management
- Duration Matching: Activos vs pasivos
- Gap Analysis: Vencimientos por períodos

## Contacto Derivados y Riesgos
Mesa de Derivados: +52 55 5231-4580
Email: derivados@monex.com.mx
Risk Advisory: +52 55 5231-4595
Email: riskadvisory@monex.com.mx',
    '04-instrumentos-derivados-manejo-riesgos-monex.pdf',
    ARRAY_CONSTRUCT('derivados', 'riesgos', 'swaps', 'opciones', 'estructurados', 'hedging', 'forwards'),
    OBJECT_CONSTRUCT(
        'target_audience', 'tesoreros corporativos',
        'language', 'español',
        'region', 'méxico',
        'document_version', '1.0',
        'approval_status', 'approved'
    );

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
-- 5. FUNCIONES DE BÚSQUEDA
-- =====================================================

-- Función para búsqueda básica en documentos
CREATE OR REPLACE FUNCTION search_monex_documents(query STRING)
RETURNS TABLE (
    document_id VARCHAR,
    document_title VARCHAR,
    business_area VARCHAR,
    relevance_score FLOAT,
    snippet VARCHAR
)
LANGUAGE SQL
AS
$$
    SELECT 
        document_id,
        document_title,
        business_area,
        GET_VALUE(search_result, 'score')::FLOAT AS relevance_score,
        SUBSTR(content, 1, 500) || '...' AS snippet
    FROM 
        TABLE(MONEX_CORTEX_SEARCH.DOCUMENTS.monex_documents_search(
            query => query
        )) AS search_result
    JOIN MONEX_DOCUMENTS d ON d.document_id = GET_VALUE(search_result, 'document_id')::VARCHAR
    ORDER BY relevance_score DESC
$$;

-- Función para búsqueda avanzada con filtros
CREATE OR REPLACE FUNCTION search_monex_documents_advanced(
    query STRING,
    business_area_filter STRING DEFAULT NULL,
    document_type_filter STRING DEFAULT NULL
)
RETURNS TABLE (
    document_id VARCHAR,
    document_title VARCHAR,
    business_area VARCHAR,
    document_type VARCHAR,
    relevance_score FLOAT,
    snippet VARCHAR,
    tags ARRAY
)
LANGUAGE SQL
AS
$$
    SELECT 
        d.document_id,
        d.document_title,
        d.business_area,
        d.document_type,
        GET_VALUE(search_result, 'score')::FLOAT AS relevance_score,
        SUBSTR(d.content, 1, 500) || '...' AS snippet,
        d.tags
    FROM 
        TABLE(MONEX_CORTEX_SEARCH.DOCUMENTS.monex_documents_search(
            query => query
        )) AS search_result
    JOIN MONEX_DOCUMENTS d ON d.document_id = GET_VALUE(search_result, 'document_id')::VARCHAR
    WHERE 
        (business_area_filter IS NULL OR d.business_area = business_area_filter)
        AND (document_type_filter IS NULL OR d.document_type = document_type_filter)
    ORDER BY relevance_score DESC
$$;

-- =====================================================
-- 6. VISTAS DE CONSULTA
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

-- =====================================================
-- 7. PROCEDIMIENTOS PARA MANTENIMIENTO
-- =====================================================

-- Procedimiento para actualizar el índice de búsqueda
CREATE OR REPLACE PROCEDURE refresh_search_service()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Refrescar el servicio de búsqueda
    ALTER CORTEX SEARCH SERVICE monex_documents_search REFRESH;
    
    RETURN 'Search service refreshed successfully';
END;
$$;

-- Procedimiento para agregar nuevo documento
CREATE OR REPLACE PROCEDURE add_document(
    doc_id STRING,
    title STRING,
    doc_type STRING,
    area STRING,
    content STRING,
    filename STRING,
    tags_array ARRAY DEFAULT NULL
)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    INSERT INTO MONEX_DOCUMENTS (
        document_id,
        document_title,
        document_type,
        business_area,
        content,
        file_name,
        tags,
        metadata
    ) VALUES (
        doc_id,
        title,
        doc_type,
        area,
        content,
        filename,
        COALESCE(tags_array, ARRAY_CONSTRUCT()),
        OBJECT_CONSTRUCT(
            'language', 'español',
            'region', 'méxico',
            'document_version', '1.0',
            'approval_status', 'pending'
        )
    );
    
    -- Refrescar índice
    CALL refresh_search_service();
    
    RETURN 'Document added successfully: ' || doc_id;
END;
$$;

-- =====================================================
-- 8. EJEMPLOS DE USO
-- =====================================================

-- Crear vista con ejemplos de búsqueda
CREATE OR REPLACE VIEW SEARCH_EXAMPLES AS
SELECT * FROM VALUES
    ('Búsqueda general', 'SELECT * FROM TABLE(search_monex_documents(''productos de inversión''))'),
    ('Búsqueda en banca corporativa', 'SELECT * FROM TABLE(search_monex_documents_advanced(''crédito empresarial'', ''BANCA_CORPORATIVA''))'),
    ('Búsqueda de derivados', 'SELECT * FROM TABLE(search_monex_documents(''swaps tasas interés''))'),
    ('Búsqueda de servicios FX', 'SELECT * FROM TABLE(search_monex_documents(''divisas USD EUR''))'),
    ('Productos estructurados', 'SELECT * FROM TABLE(search_monex_documents(''notas estructuradas certificados''))'),
    ('Gestión de riesgos', 'SELECT * FROM TABLE(search_monex_documents_advanced(''hedging cobertura'', ''DERIVADOS_RIESGOS''))'),
    ('Servicios fiduciarios', 'SELECT * FROM TABLE(search_monex_documents(''fideicomiso administración patrimonio''))'),
    ('Plataformas tecnológicas', 'SELECT * FROM TABLE(search_monex_documents(''API WebTrader plataforma digital''))')
AS examples(description, query_example);

-- =====================================================
-- 9. GRANTS Y PERMISOS
-- =====================================================

-- Crear rol para usuarios de búsqueda
CREATE ROLE IF NOT EXISTS MONEX_SEARCH_USER;

-- Otorgar permisos necesarios
GRANT USAGE ON DATABASE MONEX_CORTEX_SEARCH TO ROLE MONEX_SEARCH_USER;
GRANT USAGE ON SCHEMA DOCUMENTS TO ROLE MONEX_SEARCH_USER;
GRANT SELECT ON ALL TABLES IN SCHEMA DOCUMENTS TO ROLE MONEX_SEARCH_USER;
GRANT SELECT ON ALL VIEWS IN SCHEMA DOCUMENTS TO ROLE MONEX_SEARCH_USER;
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA DOCUMENTS TO ROLE MONEX_SEARCH_USER;
GRANT USAGE ON ALL PROCEDURES IN SCHEMA DOCUMENTS TO ROLE MONEX_SEARCH_USER;

-- Otorgar uso del servicio de búsqueda
GRANT USAGE ON CORTEX SEARCH SERVICE monex_documents_search TO ROLE MONEX_SEARCH_USER;

-- =====================================================
-- 10. VALIDACIÓN Y TESTING
-- =====================================================

-- Verificar que los documentos se insertaron correctamente
SELECT 'Documents inserted' as status, COUNT(*) as count FROM MONEX_DOCUMENTS;

-- Verificar que el servicio de búsqueda está funcionando
SELECT 'Search service status' as status, SYSTEM$GET_CORTEX_SEARCH_SERVICE_STATUS('monex_documents_search') as service_status;

-- Ejecutar búsqueda de prueba
SELECT 'Test search results' as status, COUNT(*) as results 
FROM TABLE(search_monex_documents('Monex banca corporativa'));

-- Mostrar estadísticas de documentos
SELECT * FROM DOCUMENT_STATS;

-- Mostrar distribución por área de negocio
SELECT * FROM DOCUMENTS_BY_BUSINESS_AREA;

-- Mostrar ejemplos de uso
SELECT * FROM SEARCH_EXAMPLES;

-- =====================================================
-- MENSAJE FINAL
-- =====================================================

SELECT '✅ CORTEX SEARCH SETUP COMPLETED SUCCESSFULLY! ✅' as message,
       'Ready to search Monex documents using semantic search' as description,
       'Use: SELECT * FROM TABLE(search_monex_documents(''your query here''))' as usage_example;
