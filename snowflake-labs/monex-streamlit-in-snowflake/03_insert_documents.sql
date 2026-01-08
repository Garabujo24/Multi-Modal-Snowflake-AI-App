-- =================================================================
-- DOCUMENTOS PARA CORTEX SEARCH - MONEX GRUPO FINANCIERO
-- =================================================================

USE DATABASE MONEX_DB;
USE SCHEMA CORE;
USE WAREHOUSE MONEX_WH;

-- =================================================================
-- INSERTAR DOCUMENTOS PARA CORTEX SEARCH
-- =================================================================

INSERT INTO DOCUMENTOS VALUES
-- Manuales y Políticas Operativas
('DOC_001', NULL, 'Manual de Operaciones de Factoraje', 'MANUAL', 'FACTORAJE', 
'Manual de Operaciones de Factoraje - Monex Grupo Financiero

CAPÍTULO 1: INTRODUCCIÓN AL FACTORAJE
El factoraje es una herramienta financiera que permite a las empresas obtener liquidez inmediata mediante la cesión de sus cuentas por cobrar. En Monex, ofrecemos dos modalidades principales:

1. FACTORAJE SIN RECURSO: La empresa cedente transfiere completamente el riesgo crediticio al factor.
2. FACTORAJE CON RECURSO: La empresa cedente mantiene el riesgo crediticio.

CAPÍTULO 2: PROCESO DE EVALUACIÓN
Criterios de evaluación para clientes:
- Historial crediticio del cedente y deudor
- Antigüedad y relación comercial
- Sector económico y estabilidad
- Documentación legal completa

CAPÍTULO 3: TASAS Y COMISIONES
- Tasa de descuento: Entre 12% y 18% anual
- Comisión de estudio: 1.5% a 2.5%
- Comisión de cobranza: 1% del monto
- IVA aplicable según legislación vigente

CAPÍTULO 4: DOCUMENTACIÓN REQUERIDA
Documentos del cedente:
- Acta constitutiva
- RFC y CURP de representantes legales
- Estados financieros auditados
- Flujo de efectivo proyectado

Documentos del deudor:
- Información crediticia actualizada
- Historial de pagos
- Referencias comerciales

CAPÍTULO 5: CADENAS PRODUCTIVAS NAFIN
Programa especial para proveedores de grandes empresas:
- Tasas preferenciales desde 12%
- Proceso simplificado
- Plataforma digital integrada
- Confirmación electrónica

Para más información, contacte a su ejecutivo de factoraje.',
'2024-01-15', 'ACTIVO', 'ES', CURRENT_TIMESTAMP()),

('DOC_002', NULL, 'Guía de Inversiones USD Private Banking', 'MANUAL', 'INVERSION', 
'Guía de Estrategias de Inversión USD - Monex Private Banking

ESTRATEGIAS DISPONIBLES:

1. USD FIXED INCOME (Renta Fija USD)
- Objetivo: Preservación de capital con rendimiento estable
- Rendimiento histórico: 4.70% anual
- Duración promedio: Baja exposición al riesgo de tasas
- Instrumentos: ETFs de renta fija listados en México
- Perfil del inversionista: Conservador
- Inversión mínima: USD $10,000

2. GLOBAL EQUITY (Acciones Globales)
- Objetivo: Crecimiento de capital a largo plazo
- Rendimiento histórico: 12.82% anual
- Exposición: Hasta 100% en renta variable
- Instrumentos: ETFs globales diversificados
- Perfil del inversionista: Agresivo
- Inversión mínima: USD $25,000

3. CONSERVATIVE GLOBAL STRATEGY
- Composición: 80% renta fija USD + 20% renta variable
- Rendimiento histórico: 6.68% anual
- Objetivo: Protección de capital con crecimiento moderado
- Perfil del inversionista: Conservador-moderado
- Inversión mínima: USD $15,000

4. MODERATE GLOBAL STRATEGY
- Composición: 60% renta fija USD + 40% renta variable
- Rendimiento histórico: 8.58% anual
- Objetivo: Balance entre crecimiento y estabilidad
- Perfil del inversionista: Moderado
- Inversión mínima: USD $20,000

5. AGGRESSIVE GLOBAL STRATEGY
- Composición: 40% renta fija USD + 60% renta variable
- Rendimiento histórico: 10.63% anual
- Objetivo: Máximo potencial de crecimiento
- Perfil del inversionista: Agresivo
- Inversión mínima: USD $30,000

PROCESO DE INVERSIÓN:
1. Evaluación de perfil de riesgo
2. Definición de objetivos financieros
3. Selección de estrategia apropiada
4. Firma de contratos
5. Transferencia de recursos
6. Monitoreo continuo

REPORTES Y SEGUIMIENTO:
- Reportes mensuales de performance
- Acceso a plataforma digital 24/7
- Llamadas trimestrales con asesor
- Reuniones anuales de revisión

Para iniciar su inversión, contacte a su asesor de Private Banking.',
'2024-02-01', 'ACTIVO', 'ES', CURRENT_TIMESTAMP()),

('DOC_003', NULL, 'Política de Crédito Corporativo', 'POLITICA', 'CREDITO', 
'Política de Crédito Corporativo - Monex Grupo Financiero

OBJETIVO:
Establecer los lineamientos para el otorgamiento de créditos a empresas, garantizando la calidad crediticia y rentabilidad de la cartera.

SEGMENTACIÓN DE CLIENTES:
1. EMPRESAS GRANDES: Ventas anuales > $500 millones MXN
2. MEDIANAS EMPRESAS: Ventas anuales $50-500 millones MXN  
3. PEQUEÑAS EMPRESAS: Ventas anuales $5-50 millones MXN

TIPOS DE CRÉDITO:
- Crédito Simple: Para capital de trabajo
- Línea de Crédito Revolvente: Flexibilidad en disposiciones
- Crédito de Habilitación o Avío: Financiamiento productivo
- Crédito Refaccionario: Activos fijos y equipamiento

CRITERIOS DE EVALUACIÓN:
1. Capacidad de pago demostrada
2. Historial crediticio favorable
3. Garantías suficientes y liquidas
4. Viabilidad del proyecto o negocio
5. Experiencia y calidad del management

DOCUMENTACIÓN REQUERIDA:
- Estados financieros auditados (3 años)
- Proyecciones financieras
- Declaraciones fiscales
- Flujo de efectivo histórico y proyectado
- Documentos legales de constitución
- Referencias bancarias y comerciales

LÍMITES DE AUTORIZACIÓN:
- Comité de Crédito Local: Hasta $25 millones MXN
- Comité de Crédito Regional: $25-100 millones MXN
- Comité de Crédito Nacional: $100-500 millones MXN
- Consejo de Administración: Más de $500 millones MXN

TASAS DE INTERÉS:
Base: TIIE + spread según calificación crediticia
- Calificación AAA: TIIE + 2.5%
- Calificación AA: TIIE + 3.5%
- Calificación A: TIIE + 4.5%
- Calificación BBB: TIIE + 6.0%

GARANTÍAS:
- Garantía hipotecaria: 80% del valor de avalúo
- Garantía prendaria: 70% del valor de mercado
- Aval personal: Análisis patrimonial requerido
- Fiduciaria en garantía: 100% del valor

SEGUIMIENTO Y CONTROL:
- Revisión trimestral de estados financieros
- Visitas anuales a instalaciones
- Monitoreo de indicadores financieros
- Reportes de cartera vencida mensuales

Para solicitar un crédito corporativo, contacte a su ejecutivo comercial.',
'2024-01-20', 'ACTIVO', 'ES', CURRENT_TIMESTAMP()),

('DOC_004', NULL, 'Procedimientos de Cambio de Divisas', 'MANUAL', 'CAMBIO_DIVISAS', 
'Manual de Operaciones de Cambio de Divisas - Monex

INTRODUCCIÓN:
Monex es una de las casas de cambio más importantes de México, especializada en operaciones de compra-venta de divisas y derivados cambiarios.

PRODUCTOS DISPONIBLES:

1. OPERACIONES SPOT (Al Contado)
- Liquidación: T+0 o T+2
- Monto mínimo: USD $100
- Horario: 8:00 AM - 5:00 PM hora del centro
- Comisión: 0.01% del monto operado

2. CONTRATOS FORWARD
- Plazo: 1 día hasta 1 año
- Monto mínimo: USD $1,000
- Finalidad: Cobertura de riesgo cambiario
- Garantía: 10% del monto nominal

3. OPCIONES FINANCIERAS
- Call y Put sobre USD/MXN
- Ejercicio europeo y americano
- Prima: Pagadera al inicio

PROCESO OPERATIVO:

PASO 1: SOLICITUD
- Cliente solicita cotización
- Mesa de cambios proporciona precio
- Vigencia: 30 segundos para spot, 2 minutos para forward

PASO 2: CONFIRMACIÓN
- Cliente acepta operación
- Se genera confirmación por escrito
- Registro en sistemas internos

PASO 3: LIQUIDACIÓN
- Transferencia de fondos
- Entrega de divisas
- Comprobante de operación

DOCUMENTACIÓN REQUERIDA:
- Identificación oficial vigente
- RFC o CURP
- Comprobante de domicilio
- Origen lícito de fondos

LÍMITES OPERATIVOS:
- Persona física: USD $10,000 diarios
- Persona moral: USD $100,000 diarios
- Montos superiores: Autorización especial

PREVENCIÓN DE LAVADO DE DINERO:
- Identificación de cliente (KYC)
- Reporte de operaciones > USD $10,000
- Lista de personas bloqueadas
- Monitoreo continuo de transacciones

HORARIOS DE OPERACIÓN:
- Lunes a viernes: 8:00 AM - 5:00 PM
- Sábados: Solo operaciones limitadas
- Días festivos: Cerrado

CONTACTO:
Mesa de Cambios: 55-5231-4500 ext. 2580
Email: mesacambios@monex.com.mx',
'2024-03-01', 'ACTIVO', 'ES', CURRENT_TIMESTAMP()),

('DOC_005', 'CORP_001', 'Contrato de Crédito Simple - Grupo Televisa', 'CONTRATO', 'CREDITO',
'CONTRATO DE CRÉDITO SIMPLE
Monex Grupo Financiero S.A. de C.V.

ACREDITANTE: Monex Grupo Financiero S.A. de C.V.
ACREDITADO: Grupo Televisa S.A.B. de C.V.
MONTO: $50,000,000.00 MXN (Cincuenta millones de pesos)
PLAZO: 24 meses
TASA: TIIE 28 días + 3.5% anual

CLÁUSULAS PRINCIPALES:

PRIMERA.- OBJETO
El presente contrato tiene por objeto el otorgamiento de un crédito simple por la cantidad señalada, destinado exclusivamente a capital de trabajo.

SEGUNDA.- DISPOSICIONES
El acreditado podrá disponer del crédito en una sola exhibición, previa notificación con 48 horas de anticipación.

TERCERA.- INTERESES
El crédito devengará intereses ordinarios a la tasa variable señalada, calculados sobre saldos insolutos y pagaderos mensualmente.

CUARTA.- GARANTÍAS
El presente crédito se encuentra garantizado con:
- Aval de los principales accionistas
- Garantía fiduciaria sobre flujos futuros
- Seguro de vida por el monto total

QUINTA.- COMISIONES
- Comisión por apertura: 1.5% sobre monto autorizado
- Comisión por no disposición: 0.5% mensual sobre saldo no dispuesto
- Comisión por pago anticipado: 2% sobre monto prepagado

SEXTA.- OBLIGACIONES DEL ACREDITADO
- Mantener estados financieros auditados
- No exceder nivel de endeudamiento 3:1
- Entregar información financiera trimestral
- Mantener seguros vigentes

SÉPTIMA.- CAUSALES DE VENCIMIENTO ANTICIPADO
- Incumplimiento en pagos por más de 30 días
- Deterioro significativo en situación financiera
- Incumplimiento de obligaciones de hacer o no hacer
- Cambio de control accionario sin autorización

OCTAVA.- JURISDICCIÓN
Las partes se someten a la jurisdicción de los tribunales de la Ciudad de México.

Fecha: 15 de enero de 2024
Lugar: Ciudad de México

Firmas autorizadas adjuntas.',
'2024-01-15', 'ACTIVO', 'ES', CURRENT_TIMESTAMP()),

('DOC_006', 'PYME_001', 'Contrato de Factoraje - Distribuidora El Águila', 'CONTRATO', 'FACTORAJE',
'CONTRATO DE FACTORAJE SIN RECURSO
Monex Grupo Financiero S.A. de C.V.

CEDENTE: Distribuidora El Águila S.A. de C.V.
FACTOR: Monex Grupo Financiero S.A. de C.V.
LÍNEA AUTORIZADA: $5,000,000.00 MXN

OBJETO:
La cesión de derechos de crédito derivados de facturas por venta de mercancías a cargo de deudores aprobados por el Factor.

CONDICIONES FINANCIERAS:
- Tasa de descuento: 15% anual
- Comisión de apertura: 2%
- Adelanto: Hasta 85% del valor nominal
- Plazo máximo por factura: 90 días

DEUDORES AUTORIZADOS:
- OXXO (Femsa Comercio)
- Walmart de México
- Soriana
- Chedraui
- Liverpool

PROCESO OPERATIVO:
1. Cedente presenta facturas para descuento
2. Factor verifica autenticidad y deudor autorizado
3. Se realiza adelanto del 85%
4. A vencimiento, deudor paga directamente al Factor
5. Factor entrega saldo restante menos comisiones

OBLIGACIONES DEL CEDENTE:
- Garantizar existencia y legitimidad del crédito
- Notificar al deudor sobre la cesión
- Proporcionar documentación soporte
- Mantener póliza de seguro de crédito

DOCUMENTACIÓN REQUERIDA POR OPERACIÓN:
- Factura original
- Comprobante de entrega
- Aceptación o conformidad del deudor
- Evidencia de relación comercial

CAUSALES DE TERMINACIÓN:
- Incumplimiento de obligaciones
- Deterioro en calidad crediticia
- Cambio en línea de negocio
- Solicitud de cualquiera de las partes

Vigencia: 12 meses renovables
Fecha: 18 de abril de 2024',
'2024-04-18', 'ACTIVO', 'ES', CURRENT_TIMESTAMP()),

('DOC_007', 'PRIV_001', 'Contrato de Inversión Private Banking - Roberto González', 'CONTRATO', 'INVERSION',
'CONTRATO DE PRESTACIÓN DE SERVICIOS DE INVERSIÓN
Monex Private Banking

CLIENTE: Roberto González Martínez
ASESOR: Monex Operadora de Fondos S.A. de C.V.
ESTRATEGIA: Moderate Global Strategy
MONTO INICIAL: USD $500,000

OBJETIVO DE INVERSIÓN:
Crecimiento de capital a mediano plazo con exposición moderada al riesgo, buscando preservar capital con potencial de apreciación superior a instrumentos de renta fija.

COMPOSICIÓN OBJETIVO:
- 60% Renta Fija USD (ETFs de bonos)
- 40% Renta Variable Global (ETFs de acciones)

TÉRMINOS Y CONDICIONES:

COMISIONES:
- Comisión de administración: 0.85% anual
- Comisión por entrada: 0%
- Comisión por salida: 0% después de 6 meses

REBALANCEO:
- Frecuencia: Trimestral o cuando desviaciones excedan 5%
- Sin costo adicional para el cliente
- Notificación previa de cambios

REPORTERÍA:
- Estado de cuenta mensual
- Reporte de performance trimestral
- Reunión de revisión semestral
- Acceso a plataforma digital 24/7

PERFIL DE RIESGO:
Evaluado como: MODERADO
- Tolerancia a pérdidas: Hasta 15% anual
- Horizonte de inversión: 3-5 años
- Experiencia en inversiones: Alta

CONDICIONES ESPECIALES:
- Retiros parciales: Permitidos con notificación 5 días hábiles
- Retiro total: Sin penalización después de 6 meses
- Aportaciones adicionales: Mínimo USD $25,000

DECLARACIONES DEL CLIENTE:
- Los recursos tienen origen lícito
- Acepta los riesgos inherentes a la inversión
- Ha recibido y comprende toda la documentación

VIGENCIA:
Indefinida, terminable por cualquiera de las partes con notificación 30 días.

Fecha: 20 de enero de 2024
Firma: Roberto González Martínez',
'2024-01-20', 'ACTIVO', 'ES', CURRENT_TIMESTAMP()),

('DOC_008', NULL, 'Reporte Anual de Sustentabilidad Monex 2023', 'REPORTE', 'NORMATIVO',
'REPORTE ANUAL DE SUSTENTABILIDAD 2023
Monex Grupo Financiero

MENSAJE DEL DIRECTOR GENERAL:
En Monex continuamos nuestro compromiso con el desarrollo sustentable, manteniendo las mejores prácticas en gobierno corporativo, responsabilidad social y cuidado del medio ambiente.

PRINCIPALES LOGROS 2023:

GOBIERNO CORPORATIVO:
- Certificación ISO 27001 renovada
- Cero incidentes de lavado de dinero
- 100% cumplimiento normativo
- Consejo de Administración con 40% mujeres

RESPONSABILIDAD SOCIAL:
- 500 becas educativas otorgadas
- 20,000 horas de voluntariado corporativo
- 50 programas de educación financiera
- Alianza con 25 organizaciones civiles

SUSTENTABILIDAD AMBIENTAL:
- 30% reducción en consumo energético
- 100% energía renovable en oficinas principales
- Digitalización de 95% de procesos
- Programa de reciclaje en todas las sucursales

INCLUSION FINANCIERA:
- 15,000 nuevas cuentas para segmentos no bancarizados
- Productos específicos para mujeres emprendedoras
- Créditos para vivienda sustentable
- Microcréditos en zonas rurales

EDUCACIÓN FINANCIERA:
- 50,000 personas capacitadas
- 200 talleres presenciales
- Plataforma digital con 100,000 usuarios
- Alianzas con 15 universidades

INNOVACIÓN TECNOLÓGICA:
- Lanzamiento de banca móvil renovada
- Inteligencia artificial en evaluación crediticia
- Blockchain para operaciones internacionales
- Ciberseguridad mejorada

METAS 2024:
- Carbono neutral en operaciones
- 60,000 personas en educación financiera
- 25% crecimiento en banca digital
- Certificación B-Corp

RECONOCIMIENTOS:
- Empresa Socialmente Responsable (CEMEFI)
- Great Place to Work
- Top Employer México
- Premio Nacional de Calidad

Monex reafirma su compromiso con México y el desarrollo sustentable para las futuras generaciones.',
'2023-12-31', 'ACTIVO', 'ES', CURRENT_TIMESTAMP()),

('DOC_009', NULL, 'Manual de Prevención de Lavado de Dinero', 'MANUAL', 'NORMATIVO',
'MANUAL DE PREVENCIÓN DE LAVADO DE DINERO
Monex Grupo Financiero

OBJETIVO:
Establecer las políticas y procedimientos para prevenir, detectar y reportar operaciones que pudieran estar relacionadas con lavado de dinero y financiamiento al terrorismo.

MARCO LEGAL:
- Ley Federal para la Prevención e Identificación de Operaciones con Recursos de Procedencia Ilícita
- Disposiciones CNBV
- Reglas generales SHCP
- Estándares internacionales GAFI

IDENTIFICACIÓN DE CLIENTES (KYC):

PERSONAS FÍSICAS:
- Identificación oficial vigente
- CURP
- Comprobante de domicilio (máximo 3 meses)
- Declaración de origen lícito de recursos
- Declaración de actividad económica

PERSONAS MORALES:
- Acta constitutiva certificada
- RFC
- Poderes del representante legal
- Estados financieros dictaminados
- Identificación de beneficiarios controladores

OPERACIONES SUJETAS A REPORTE:

OPERACIONES RELEVANTES:
- Efectivo por más de USD $10,000 o equivalente
- Transferencias internacionales
- Cambio de divisas > USD $3,000
- Inversiones en instrumentos al portador

OPERACIONES INUSUALES:
- Patrones atípicos de transacciones
- Montos inconsistentes con perfil del cliente
- Operaciones fraccionadas para evitar límites
- Clientes renuentes a proporcionar información

LISTA DE PERSONAS BLOQUEADAS:
- Consulta diaria contra listas oficiales
- OFAC (Office of Foreign Assets Control)
- ONU (Naciones Unidas)
- Lista nacional de personas bloqueadas

CAPACITACIÓN:
- Curso obligatorio anual para todo el personal
- Evaluaciones trimestrales
- Actualizaciones sobre nuevas tipologías
- Certificación para áreas críticas

REPORTES:
- Operaciones relevantes: 17 del mes siguiente
- Operaciones inusuales: 2 días hábiles
- Transferencias internacionales: Tiempo real
- Reporte anual de cumplimiento

SANCIONES:
- Multas hasta por $5,000,000 UDIS
- Suspensión de operaciones
- Responsabilidad penal individual
- Pérdida de licencia

OFICIAL DE CUMPLIMIENTO:
Responsable del programa PLD/FT
Email: cumplimiento@monex.com.mx
Teléfono: 55-5231-4500 ext. 1200

Todo el personal debe conocer y cumplir estas disposiciones.',
'2024-01-01', 'ACTIVO', 'ES', CURRENT_TIMESTAMP()),

('DOC_010', NULL, 'Comunicado - Nuevas Tasas de Interés Marzo 2024', 'COMUNICADO', 'OPERATIVO',
'COMUNICADO OFICIAL
Monex Grupo Financiero

Fecha: 1 de marzo de 2024
Para: Todos los clientes y prospectos

NUEVAS TASAS DE INTERÉS VIGENTES A PARTIR DEL 4 DE MARZO 2024

Estimados clientes:

Como parte de nuestro compromiso de mantenerlos informados sobre las condiciones del mercado financiero, les comunicamos los siguientes ajustes en nuestras tasas de interés:

CRÉDITOS CORPORATIVOS:
- Líneas de crédito revolvente: TIIE + 3.5% a 5.5%
- Créditos simples: TIIE + 3.0% a 5.0%  
- Créditos en USD: Prime Rate + 2.0% a 4.0%

FACTORAJE:
- Sin recurso: 14.5% a 17.5% anual
- Con recurso: 12.5% a 15.5% anual
- Cadenas productivas: 12.0% a 14.0% anual

INVERSIONES:
- Fondos de renta fija MXN: 9.25% proyectado
- Mercado de dinero: 7.80% proyectado
- Estrategias USD: Mantienen proyecciones actuales

CUENTAS DE DEPÓSITO:
- Cuenta empresarial: 2.5% anual
- Cuenta USD: 1.2% anual
- Private Banking: 3.0% anual

CAMBIO DE DIVISAS:
- Spread USD/MXN: 10 centavos (compra-venta)
- Comisión: 0.01% del monto operado
- Forwards: Pricing según plazo y volatilidad

JUSTIFICACIÓN:
Estos ajustes responden a:
- Cambios en la política monetaria del Banco de México
- Condiciones de liquidez en el mercado
- Evolución de las tasas de referencia internacionales
- Perspectivas económicas 2024

Las nuevas condiciones aplicarán para:
- Nuevos contratos a partir del 4 de marzo
- Renovaciones de líneas existentes
- Contratos con tasa variable según fecha de revisión

Para mayor información, contacte a su ejecutivo de cuenta o visite nuestras sucursales.

Atentamente,
Dirección Comercial
Monex Grupo Financiero',
'2024-03-01', 'ACTIVO', 'ES', CURRENT_TIMESTAMP());

COMMIT;

SELECT 'Documentos para Cortex Search insertados exitosamente!' AS STATUS;


