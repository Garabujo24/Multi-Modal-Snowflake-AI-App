-- =====================================================
-- MONEX GRUPO FINANCIERO - CORTEX SEARCH SETUP V2
-- Versión actualizada con sintaxis correcta de Cortex Search
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
    '# SERVICIOS DE BANCA CORPORATIVA MONEX

Monex Grupo Financiero es una institución financiera mexicana especializada en servicios corporativos, con más de 35 años de experiencia en el mercado financiero nacional e internacional. Fundada en 1985 por Héctor Lagos Dondé, Monex se ha consolidado como uno de los principales proveedores de servicios de cambio de divisas y soluciones financieras empresariales en México.

## Estructura Organizacional
- Banco Monex, S.A. - Institución de Banca Múltiple
- Monex Casa de Bolsa, S.A. de C.V. - Intermediación bursátil  
- Monex Operadora de Fondos, S.A. de C.V. - Gestión de fondos de inversión

## Servicios de Captación Institucional

### Sistema de Ahorro Institucional
Monex ofrece soluciones de captación para empresas e instituciones:
- Tasas de rendimiento competitivas por encima del mercado
- Acceso inmediato a fondos cuando sea necesario
- Gestión eficiente a través de plataformas digitales
- Asesoría personalizada para optimizar recursos

### Cuenta Digital Empresarial
- Apertura 100% digital sin papeleos
- Transferencias instantáneas 24/7
- Consulta de saldos y movimientos en tiempo real
- Integración con sistemas contables empresariales
- Comisiones reducidas para operaciones frecuentes

### Certificados de Depósito a Plazo Corporativo
- Plazos desde 28 días hasta 360 días
- Tasas fijas garantizadas
- Esquemas de capitalización de intereses
- Montos desde $100,000 pesos

## Productos de Crédito Corporativo

### Créditos Comerciales Especializados
Monex otorga créditos comerciales adaptados a las necesidades específicas:
- Líneas de crédito revolventes
- Créditos para capital de trabajo
- Financiamiento de proyectos específicos
- Créditos puente para operaciones especiales
- Tasas preferenciales para clientes recurrentes
- Procesos de autorización expeditos

### Monex Leasing
Solución integral para la adquisición de activos fijos:
- Conservación del capital de trabajo
- Beneficios fiscales por deducibilidad  
- Flexibilidad en estructuración de pagos
- Opción de compra al final del contrato
- Activos financiables: maquinaria industrial, flotillas vehiculares, equipos de cómputo, inmuebles comerciales

## Servicios de Comercio Exterior

### Cartas de Crédito Comerciales
- Cartas de crédito de importación: Garantía de pago a proveedores extranjeros
- Cartas de crédito de exportación: Garantía de cobro para exportadores mexicanos
- Financiamiento del 100% de la operación
- Plazos de hasta 180 días

### Cadenas Productivas NAFIN
- Financiamiento de proveedores y compradores
- Factoraje de cuentas por cobrar de exportación
- Programas de desarrollo de proveedores
- Capacitación en comercio exterior

## Gestión de Efectivo y Tesorería

### Cash Management Integral
- Concentración de fondos: Barrido automático de cuentas
- Administración de pagos: Dispersión masiva de nóminas
- Optimización de rendimientos
- Reducción de costos operativos

### Plataformas Electrónicas de Divisas
- Cotizaciones en tiempo real 24/7
- Ejecución instantánea de operaciones
- Spreads competitivos en todas las divisas
- Acceso a mercados internacionales
- Límites de crédito preautorizados

## Contacto
Oficinas Corporativas: Av. Paseo de la Reforma 284, Piso 15, Colonia Juárez, CDMX 06600
Teléfono: 55 5231-4500
Email: corporativo@monex.com.mx
Web: www.monex.com.mx' as content,
    '01-servicios-banca-corporativa-monex.pdf' as file_name,
    LENGTH('# SERVICIOS DE BANCA CORPORATIVA MONEX...') as file_size_bytes,
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
    '# PRODUCTOS DE INVERSIÓN Y GESTIÓN DE PATRIMONIO MONEX

Monex Banca Privada se dedica a la preservación y crecimiento del patrimonio de individuos y familias de alto patrimonio neto, así como instituciones que buscan soluciones de inversión sofisticadas.

## Perfil de Clientes
- Empresarios y profesionistas exitosos
- Patrimonio mínimo de USD $500,000
- Necesidades de diversificación internacional  
- Objetivos de preservación y crecimiento a largo plazo

## Estrategias de Inversión en USD

### USD Fixed Income - Estrategia Conservadora
- Inversión 100% en instrumentos de renta fija
- Perfil ideal para clientes conservadores
- 100% invertido en ETFs listados en México (SIC)
- Riesgo de duración bajo, riesgo crediticio mínimo
- Rendimiento anualizado desde inicio: 2.72%

### Global Equity - Estrategia de Crecimiento  
- Inversión hasta 100% en acciones
- Mínimo 90% en renta variable (principalmente ETFs)
- Máximo 10% en acciones individuales
- Portafolio activamente gestionado
- Horizonte de inversión de largo plazo
- Rendimiento anualizado desde inicio: 74.62%

### Conservative Global Strategy - Estrategia Defensiva
- 80% en USD Fixed Income Portfolio
- 20% en Global Equity Portfolio
- Orientada a protección de capital con crecimiento moderado
- Menor volatilidad en períodos de alta volatilidad
- Rendimiento anualizado desde inicio: 4.53%

### Moderate Global Strategy - Estrategia Balanceada
- 60% en USD Fixed Income
- 40% en Global Equity
- Participación activa en activos de riesgo
- Rebalanceo trimestral automático
- Rendimiento anualizado desde inicio: 6.01%

### Aggressive Global Strategy - Estrategia de Crecimiento
- 40% en USD Fixed Income
- 60% en Global Equity
- Mayor tolerancia al riesgo y exposición a capital
- Mejores rendimientos de largo plazo
- Rendimiento anualizado desde inicio: 8.36%

## Fondos de Inversión Especializados

### Monex Operadora de Fondos
- Fondos de renta fija: Monex Deuda MX, Monex Global Bond USD
- Fondos de renta variable: Monex Equity Mexico, Monex Global Equity  
- Fondos mixtos: Monex Balanced Fund
- Calculadora de fondos de inversión disponible

## Productos del Mercado de Capitales

### Trading de Valores
- Acciones nacionales: Todas las empresas listadas en BMV
- Acciones internacionales: NYSE, NASDAQ, LSE (más de 15,000 instrumentos)
- Instrumentos de deuda gubernamental y corporativa
- Ejecución multi-mercado en tiempo real
- Análisis fundamental y técnico

### Notas Estructuradas
Monex líder en el mercado mexicano con más de 1,700 notas estructuradas emitidas en 2022 por $41,216 millones de pesos:
- Certificados de Depósito Estructurados
- Bonos Bancarios Estructurados  
- Protección total o parcial de capital (85%-100%)
- Vencimientos de 6 meses a 5 años
- Denominación en MXN, USD, EUR

## Servicios Fiduciarios y Patrimoniales

### Fideicomisos Especializados
- Fideicomisos de administración: Gestión profesional de carteras
- Fideicomisos de garantía: Respaldo para emisiones bursátiles
- Fideicomisos inmobiliarios: Desarrollo de propiedades
- Administración de flujos de pago y reporting

### Cuenta Personal Especial de Ahorro (CPEA)
- Deducción anual hasta $152,000 MXN
- Exención de impuestos sobre rendimientos
- Retiro libre de impuestos después de 5 años
- Portabilidad entre instituciones

### Plan Personal de Retiro (PPR)
- Sistema complementario de pensiones
- Aportaciones voluntarias deducibles
- Cobertura de seguros incluida
- Múltiples opciones de inversión
- Portabilidad total del plan

## Contacto Banca Privada
Paseo de la Reforma 284, Piso 12, Col. Juárez, CDMX 06600
Teléfono: 55 5231-4530
Email: bancaprivada@monex.com.mx
Mínimos de Inversión: USD $500,000',
    '02-productos-inversion-gestion-patrimonio-monex.pdf',
    LENGTH('# PRODUCTOS DE INVERSIÓN...'),
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
    '# SERVICIOS DE DIVISAS Y PAGOS INTERNACIONALES MONEX

Desde su fundación en 1985, Monex se ha consolidado como el líder indiscutible en el mercado mexicano de cambio de divisas con más de 35 años de experiencia.

## Cifras de Liderazgo
- Transacciones anuales: Más de 5 millones
- Volumen anual: USD $190,000 millones  
- Participación de mercado: 35% del mercado retail mexicano
- Clientes activos: Más de 40,000 empresas e individuos
- Reconocimiento: Mejor Casa de Cambio por Global Finance (2020-2023)

## Servicios de Cambio de Divisas

### Operaciones Spot (Entrega Inmediata)

#### USD/MXN - Par Estrella
- Spread típico: 1-3 centavos (dependiendo del monto)
- Monto mínimo: $1,000 USD
- Liquidación: T+0 (mismo día)
- Horarios: 8:00 - 17:00 hrs (horario México)
- Cut-off diario: 16:30 hrs para liquidación misma fecha

#### Otras Divisas Principales
- EUR/MXN: Euro peso mexicano (spread 8-15 centavos)
- GBP/MXN: Libra esterlina peso mexicano
- CAD/MXN: Dólar canadiense peso mexicano
- JPY/MXN: Yen japonés peso mexicano
- CHF/MXN: Franco suizo peso mexicano

#### Divisas Emergentes y Exóticas
Latinoamericanas: COP, BRL, CLP, PEN, ARS
Asiáticas: CNY, KRW, SGD, HKD
Europeas: SEK, NOK, DKK, PLN

### Operaciones a Plazo (Forward)
- Plazos: 1 día a 12 meses
- Divisas: Todas las principales y selectas emergentes
- Monto mínimo: USD $10,000 equivalente
- Garantías: Línea de crédito o colateral
- Metodología: Tasa spot + diferencial de tasas de interés

### Opciones de Divisas
- Calls y Puts Europeas (ejercicio solo al vencimiento)
- Opciones Barrera: Knock-in, Knock-out
- Opciones Asiáticas: Average Rate Options
- Vencimientos: 1 semana a 12 meses

## Pagos y Transferencias Internacionales

### Monex Global Payments

#### Red de Corresponsalías Bancarias
Estados Unidos:
- Wells Fargo: Cuenta principal para USD
- JPMorgan Chase: Backup y servicios especializados  
- Bank of America: Pagos retail y corporate
- Citibank: Servicios de tesorería avanzados

Europa:
- Deutsche Bank (Alemania): Hub para EUR
- BNP Paribas (Francia): Servicios multi-divisa
- Santander (España): Especialización iberoamericana
- UBS (Suiza): Private banking y wealth management

Asia-Pacífico:
- HSBC Hong Kong: Gateway asiático
- Bank of Tokyo-Mitsubishi: Servicios JPY
- DBS Singapore: Hub del sudeste asiático
- ANZ Australia: Servicios AUD y NZD

#### Tipos de Transferencias
- Wire Transfers Tradicionales: SWIFT estándar global (1-3 días)
- Transferencias Express: Same Day Value, Next Day Value
- Bulk Payments: Hasta 10,000 beneficiarios (nóminas, proveedores)
- Validación AML y compliance automatizado

### Monex Remittances
- Transferencias a familiares: $1 USD a $50,000 USD
- Destinos: Estados Unidos, Canadá, Europa, Centroamérica
- Red de entrega: 25,500 puntos globalmente
- Costos competitivos desde $5 USD

## Plataformas Tecnológicas FX

### Monex FX Pro - Plataforma Institucional
- Trading Engine: Latencia sub-10ms
- Price Feeds: Múltiples proveedores de liquidez
- Risk Management: Límites automáticos en tiempo real
- Conectividad: FIX Protocol, REST APIs, WebSocket
- Algoritmos: TWAP, VWAP, Implementation Shortfall

### Monex FX Retail - Plataforma para Empresas
- WebTrader: Acceso desde cualquier navegador
- Mobile App: iOS y Android nativo  
- Deal Blotter: Historial completo de operaciones
- Market Data: Precios en tiempo real
- Análisis técnico: 50+ indicadores, pattern recognition

## Presencia Internacional

### Monex USA
- Monex Securities Inc. (Houston, TX): FINRA member, SIPC protected
- Tempus Inc. (adquirida 2010): Corporate FX and payments
- AUM: USD $379 millones
- Volumen: USD $2.5 mil millones anuales

### Monex Europe  
- Monex Europe Limited (Londres, UK): FCA regulated
- Monex España (Madrid): Empresas hispanas en Europa
- Volumen: EUR 500 millones anuales
- Productos: SEPA, TARGET2, Instant Payments

## Centro de Análisis Monex

### Equipo de Research
- Chief Economist: PhD en Economía, 20+ años experiencia
- FX Strategist: CFA, especialista en mercados emergentes
- Technical Analyst: CMT, experto en análisis técnico
- Risk Analyst: FRM, especialista en derivatives

### Publicaciones de Research
- Daily FX Commentary: Análisis de apertura y eventos del día
- Weekly FX Outlook: Revisión semanal y outlook
- Monthly FX Strategy: Análisis macroeconómico profundo y forecasts

### Modelos de Valoración
- Purchasing Power Parity: USD/MXN fair value 18.50-19.20
- Interest Rate Differential: Spread actual 575 bp
- Real Effective Exchange Rate: 15% sobre promedio histórico

## Contacto Especializado FX
Mesa de Cambios: +52 55 5231-4545
Institutional Sales: +52 55 5231-4550  
Research Desk: +52 55 5231-4555
WebTrader: portal.monex.com.mx
API Access: developers.monex.com.mx

Horarios de Operación:
- Mercado México: 8:00 - 17:00 hrs
- Mercado USA: 7:00 - 16:00 hrs (Chicago time)
- Mercado Europa: 3:00 - 12:00 hrs (Londres time)',
    '03-servicios-divisas-pagos-internacionales-monex.pdf',
    LENGTH('# SERVICIOS DE DIVISAS...'),
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
    '# INSTRUMENTOS DERIVADOS Y MANEJO DE RIESGOS MONEX

Monex se posiciona como líder en México en el desarrollo y estructuración de instrumentos derivados, habiendo establecido durante 2022 un área de manejo de riesgos como una de las divisiones más dinámicas del banco. Con la emisión de 1,705 notas estructuradas por un nocional de $41,216 millones de pesos.

## Marco Conceptual de Riesgos Financieros

### Tipos de Riesgos Financieros

#### Riesgo de Mercado
- Riesgo de Tasa de Interés: Variaciones en el valor de activos/pasivos por cambios en tasas
- Riesgo Cambiario: Exposición a fluctuaciones en tipos de cambio  
- Riesgo de Precio de Commodities: Volatilidad en precios de materias primas
- Medición: VaR, exposición neta por divisa, análisis de sensibilidad

#### Riesgo de Crédito
- Riesgo de Contraparte: Probabilidad de incumplimiento del counterparty
- Riesgo de Concentración: Exposición excesiva a un solo emisor/sector
- Medición: Credit VaR, Exposure at Default (EAD)
- Mitigación: Garantías, netting agreements, CSA

#### Riesgo de Liquidez
- Riesgo de Financiamiento: Incapacidad de cumplir obligaciones de pago
- Riesgo de Mercado de Liquidez: Dificultad para liquidar posiciones sin impacto adverso
- Medición: Gaps de liquidez, stress testing
- Mitigación: Líneas de crédito, repos, asset sales

## Derivados de Tasas de Interés

### Interest Rate Swaps (IRS)
- Pata Fija: Cliente paga tasa fija anual (ej. 8.50%)
- Pata Flotante: Cliente recibe TIIE 28 días + spread
- Frecuencia: Pagos trimestrales o semestrales
- Nocional: $10 millones MXN mínimo
- Casos de uso: Asset-Liability Matching, especulación direccional

### Forward Rate Agreements (FRAs)
- Definición: Swap de un solo período sobre tasa futura
- Settlement: Cash settlement en fecha de inicio
- Benchmark: TIIE 28, TIIE 91, CETES 28
- Plazos estándar: 1x4, 2x5, 3x6, 6x9, 9x12
- Pricing: Basado en curva de rendimientos

### Caps, Floors y Collars
- Interest Rate Caps: Protección contra alza de tasas (tasa máxima)
- Interest Rate Floors: Protección contra baja de tasas (tasa mínima)  
- Interest Rate Collars: Compra cap + venta floor (menor costo)
- Zero-Cost Collar: Premium neto = 0

### Derivados de Inflación
- UDI Swaps: Pata real fija vs pata nominal
- TIIE Real Swaps: Tasa real fija vs TIIE Real
- Uso: Hedge de exposición inflacionaria, cobertura poder adquisitivo

## Derivados de Tipo de Cambio

### Cross Currency Swaps
- Intercambio inicial: Principal en ambas divisas
- Intercambio periódico: Intereses en monedas respectivas
- Intercambio final: Reintercambio de principales
- Divisas: USD/MXN, EUR/MXN, GBP/MXN
- Aplicaciones: Financiamiento en divisa extranjera, natural hedging

### Opciones de Divisas

#### Opciones Vanilla
- Call Options (USD/MXN): Right to Buy USD contra MXN
- Put Options (USD/MXN): Right to Sell USD contra MXN
- Strike: Tipo de cambio de ejercicio
- Premium: Costo de la opción (% del nocional)

#### Estrategias con Opciones
- Protective Put (Collar): Protección 18.50-19.50, costo reducido
- Risk Reversal: Exposición direccional, premium mínimo
- Straddle: Profit si movimiento > premium pagado

#### Opciones Exóticas
- Opciones Barrera: Knock-Out (se desactiva), Knock-In (se activa)
- Opciones Asiáticas: Settlement basado en promedio de observaciones
- Ventajas: Premium significativamente menor, menor volatilidad

## Productos Estructurados OTC

### Notas Estructuradas
Monex lidera el mercado mexicano con más de 1,700 notas estructuradas emitidas en 2022:
- Capital Protegido: 85%-100% del principal
- Upside Participation: Exposición a subyacente específico
- Vencimiento: 6 meses a 5 años
- Denominación: MXN, USD, EUR

#### Certificados Ligados a Equity
- S&P 500 Linked Certificate: Participación 120%, barrera 70%
- Autocall Equity Certificate: Observación trimestral, cupón 8.5%
- Basket de acciones mexicanas: Diversificación local

#### Certificados de Divisas  
- USD/MXN Range Accrual: Cupón diario si dentro del rango
- Multi-Currency Worst-Of: Performance del peor par de divisas

### Bonos Bancarios Estructurados
- Step-Up Floating Rate Notes: Cupón incremental por año
- Inflation Plus Notes: Base inflación + spread, floor y cap
- Credit-Linked Notes: Ligados a eventos crediticios

### Derivados de Commodities
- WTI Crude Oil Participation Certificate: 75% participación WTI
- Pemex vs WTI Spread Note: Beneficio si spread se contrae  
- Gold Participation Certificate: 100% performance oro en MXN
- Agricultural Basket Note: Maíz, trigo, soya (igual peso)

## Gestión Integral de Riesgos Corporativos

### Assessment de Riesgos Corporativos

#### Metodología de Evaluación
1. Identificación de Exposiciones: Mapeo de flujos, análisis de balance
2. Cuantificación de Riesgos: VaR, Expected Shortfall, scenario analysis
3. Desarrollo de Estrategia: Risk tolerance, cost-benefit, hedging strategy

#### Herramientas de Medición
- Bloomberg Risk & Analytics: Análisis de portafolios
- Reuters Eikon: Data feeds y analytics
- Monex Risk Platform: Desarrollos internos propietarios
- Monte Carlo Simulation: Modelado de escenarios (10,000 escenarios)

### Políticas de Hedging

#### Hedging de Riesgo Cambiario
- Hedge Ratio: 50%-90% de exposición neta
- Horizon: Rolling 12-month hedging
- Instruments: Forwards (60%), options (40%)
- Triggers: Exposición >$5MM USD (cobertura mandatoria)

#### Hedging de Riesgo de Tasa
- Asset-Liability Management: Duration matching activos vs pasivos
- Gap Analysis: Vencimientos por períodos
- Interest Rate Sensitivity: PV01 por bucket
- Immunization: Estrategias duration-neutral

### Implementación y Monitoring

#### Proceso de Implementación
- Pre-Trade: Committee review, pricing validation, legal documentation
- Trade Execution: Best execution, competitive pricing, confirmación 30 min
- Post-Trade: Mark-to-market diario, risk reporting, P&L attribution

#### Reporting y Governance
- Daily Risk Report: Exposiciones, P&L, VaR vs limits
- Monthly Board Report: ROI programa hedging, outlook, compliance
- Hedge Effectiveness: Testing ASC 815/IFRS 9

## Casos Prácticos de Implementación

### Empresa Manufacturera Exportadora
- Exposición: Net long USD $50 millones anuales
- Estrategia: 60% forwards, 30% collar, 10% opciones
- Resultado: 85% hedge effectiveness, 60% reducción volatilidad

### Banco Comercial Regional  
- Gap de Tasa: +1.6 años duration gap
- Estrategia: Pay-Fixed IRS, Interest Rate Collar, Swaptions
- Resultado: Duration gap reducido a +/- 0.5 años

### Corporativo de Infraestructura
- Proyecto: Parque eólico $300MM USD
- Riesgos: FX, tasas, inflación construcción  
- Estrategia: Forward program, forward starting IRS, UDI contracts
- Resultado: 95% costos cubiertos, DSCR >1.3x mantenido

## Contacto Derivados y Riesgos
Mesa de Derivados: +52 55 5231-4580
Email: derivados@monex.com.mx
Risk Advisory: +52 55 5231-4595
Email: riskadvisory@monex.com.mx

Documentación requerida:
- ISDA Master Agreement: Template legal requerido
- CSA (Credit Support Annex): Gestión de colateral
- Confirmaciones: Plataforma electrónica disponible

Límites operativos:
- Spot FX: Sin límite con línea aprobada
- Forwards: Hasta 12 meses, sujeto a línea
- Options: Premium máximo 5% del notional',
    '04-instrumentos-derivados-manejo-riesgos-monex.pdf',
    LENGTH('# INSTRUMENTOS DERIVADOS...'),
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
-- 4. CREAR CORTEX SEARCH SERVICE (SINTAXIS ACTUALIZADA)
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
-- 5. FUNCIONES DE BÚSQUEDA (SINTAXIS CORREGIDA)
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
        d.document_id,
        d.document_title,
        d.business_area,
        results.value:score::FLOAT AS relevance_score,
        SUBSTR(d.content, 1, 500) || '...' AS snippet
    FROM 
        TABLE(
            SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
                'monex_documents_search',
                query
            )
        ) AS results
    JOIN MONEX_DOCUMENTS d ON d.document_id = results.value:chunk_id::VARCHAR
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
        results.value:score::FLOAT AS relevance_score,
        SUBSTR(d.content, 1, 500) || '...' AS snippet,
        d.tags
    FROM 
        TABLE(
            SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
                'monex_documents_search',
                query
            )
        ) AS results
    JOIN MONEX_DOCUMENTS d ON d.document_id = results.value:chunk_id::VARCHAR
    WHERE 
        (business_area_filter IS NULL OR d.business_area = business_area_filter)
        AND (document_type_filter IS NULL OR d.document_type = document_type_filter)
    ORDER BY relevance_score DESC
$$;

-- =====================================================
-- 6. VISTAS Y UTILIDADES
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
-- 7. GRANTS Y PERMISOS
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
-- 8. VALIDACIÓN Y TESTING
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
-- 9. EJEMPLOS DE USO
-- =====================================================

-- Crear vista con ejemplos de búsqueda
CREATE OR REPLACE VIEW SEARCH_EXAMPLES AS
SELECT * FROM VALUES
    ('Búsqueda general', 'SELECT * FROM TABLE(search_monex_documents(''productos de inversión''))'),
    ('Búsqueda filtrada', 'SELECT * FROM TABLE(search_monex_documents_advanced(''crédito empresarial'', ''BANCA_CORPORATIVA''))'),
    ('Búsqueda de derivados', 'SELECT * FROM TABLE(search_monex_documents(''swaps tasas interés hedging''))'),
    ('Búsqueda de FX', 'SELECT * FROM TABLE(search_monex_documents(''divisas USD EUR forward''))'),
    ('Productos estructurados', 'SELECT * FROM TABLE(search_monex_documents(''notas estructuradas certificados''))'),
    ('Gestión de riesgos', 'SELECT * FROM TABLE(search_monex_documents_advanced(''VaR exposición riesgo'', ''DERIVADOS_RIESGOS''))'),
    ('Servicios fiduciarios', 'SELECT * FROM TABLE(search_monex_documents(''fideicomiso patrimonio administración''))'),
    ('Tecnología y APIs', 'SELECT * FROM TABLE(search_monex_documents(''API WebTrader plataforma digital''))')
AS examples(description, query_example);

-- Mostrar ejemplos
SELECT * FROM SEARCH_EXAMPLES;

-- =====================================================
-- MENSAJE FINAL
-- =====================================================

SELECT '✅ CORTEX SEARCH V2 SETUP COMPLETED! ✅' as message,
       'Ready to search Monex documents using Cortex Search' as description,
       'Use: SELECT * FROM TABLE(search_monex_documents(''your query''))' as usage_example;
