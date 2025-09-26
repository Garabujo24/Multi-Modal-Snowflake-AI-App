# INSTRUMENTOS DERIVADOS Y MANEJO DE RIESGOS MONEX
## Soluciones Avanzadas para la Gestión de Riesgos Financieros

---

### TABLA DE CONTENIDO

1. **Marco Conceptual de Riesgos Financieros**
2. **Derivados de Tasas de Interés**
3. **Derivados de Tipo de Cambio**
4. **Productos Estructurados OTC**
5. **Gestión Integral de Riesgos Corporativos**
6. **Casos Prácticos y Estrategias de Implementación**

---

## 1. MARCO CONCEPTUAL DE RIESGOS FINANCIEROS

### Filosofía de Gestión de Riesgos en Monex

Monex se posiciona como líder en México en el desarrollo y estructuración de instrumentos derivados, habiendo establecido durante 2022 un área de manejo de riesgos como una de las divisiones más dinámicas del banco. Con la emisión de 1,705 notas estructuradas por un nocional de $41,216 millones de pesos, Monex demuestra su capacidad para crear soluciones innovadoras que respondan a las necesidades específicas de gestión de riesgos de sus clientes.

### Tipos de Riesgos Financieros

#### Riesgo de Mercado

**Riesgo de Tasa de Interés:**
- **Impacto**: Variaciones en el valor de activos/pasivos por cambios en tasas
- **Medición**: Duration, PV01, simulación de escenarios
- **Instrumentos de cobertura**: IRS, FRAs, Caps, Floors, Collars

**Riesgo Cambiario:**
- **Impacto**: Exposición a fluctuaciones en tipos de cambio
- **Medición**: VaR, exposición neta por divisa, análisis de sensibilidad
- **Instrumentos de cobertura**: Forwards, Swaps, Opciones FX

**Riesgo de Precio de Commodities:**
- **Impacto**: Volatilidad en precios de materias primas
- **Medición**: Beta commodity, correlaciones históricas
- **Instrumentos de cobertura**: Futuros, Opciones, Swaps de commodities

#### Riesgo de Crédito

**Riesgo de Contraparte:**
- **Definición**: Probabilidad de incumplimiento del counterparty
- **Medición**: Credit VaR, Exposure at Default (EAD)
- **Mitigación**: Garantías, netting agreements, CSA

**Riesgo de Concentración:**
- **Definición**: Exposición excesiva a un solo emisor/sector
- **Medición**: Límites por contraparte, índice de Herfindahl
- **Mitigación**: Diversificación, credit default swaps

#### Riesgo de Liquidez

**Riesgo de Financiamiento:**
- **Definición**: Incapacidad de cumplir obligaciones de pago
- **Medición**: Gaps de liquidez, stress testing
- **Mitigación**: Líneas de crédito, repos, asset sales

**Riesgo de Mercado de Liquidez:**
- **Definición**: Dificultad para liquidar posiciones sin impacto adverso
- **Medición**: Bid-offer spreads, volúmenes históricos
- **Mitigación**: Market making agreements, diversificación

### Marco Regulatorio

#### Normativa Mexicana

**Circulares CNBV:**
- **Circular Única de Bancos**: Requerimientos de capital por riesgo de mercado
- **Metodologías de VaR**: Modelos internos vs estándar
- **Límites Regulatorios**: Capital Tier 1, exposiciones máximas

**Banco de México:**
- **Operaciones Derivadas**: Autorización y registro requeridos
- **Reportes Regulatorios**: R04 A (posiciones), R04 C (riesgos)
- **Provisiones**: Requerimientos de reservas por riesgo de crédito

#### Estándares Internacionales

**Basel III/IV:**
- **CVA (Credit Valuation Adjustment)**: Ajuste por riesgo de crédito
- **SA-CCR**: Standardized Approach for Counterparty Credit Risk
- **FRTB**: Fundamental Review of the Trading Book

**ISDA Master Agreements:**
- **1992/2002 ISDA**: Marco legal para derivados OTC
- **CSA (Credit Support Annex)**: Gestión de colateral
- **Dodd-Frank Compliance**: Clearing mandatory, reporting

---

## 2. DERIVADOS DE TASAS DE INTERÉS

### Interest Rate Swaps (IRS)

#### Swap de Tasa Fija vs Flotante

**Estructura Básica:**
- **Pata Fija**: Cliente paga tasa fija anual (e.g., 8.50%)
- **Pata Flotante**: Cliente recibe TIIE 28 días + spread
- **Frecuencia**: Pagos trimestrales o semestrales
- **Nocional**: $10 millones MXN mínimo

**Casos de Uso:**
- **Asset-Liability Matching**: Banco con créditos a tasa fija, funding flotante
- **Especulación Direccional**: Views sobre dirección de tasas
- **Arbitraje**: Aprovechamiento de ineficiencias de mercado

**Ejemplo Práctico:**
```
Nocional: $100 millones MXN
Plazo: 5 años
Cliente paga: 8.50% anual fijo
Cliente recibe: TIIE 28 + 0.25%
Fechas de pago: Trimestrales (28 mar, jun, sep, dic)
```

#### Forward Rate Agreements (FRAs)

**Características:**
- **Definición**: Swap de un solo período sobre tasa futura
- **Settlement**: Cash settlement en fecha de inicio
- **Benchmark**: TIIE 28, TIIE 91, CETES 28
- **Plazos estándar**: 1x4, 2x5, 3x6, 6x9, 9x12

**Pricing Formula:**
```
FRA Rate = [(1 + R2 × D2/360) / (1 + R1 × D1/360) - 1] × 360/DF
Donde:
R2 = Tasa larga (período total)
R1 = Tasa corta (período inicial)  
D2 = Días período total
D1 = Días período inicial
DF = Días del FRA
```

**Cash Settlement:**
```
Settlement = (FRA Rate - Fixing Rate) × Nocional × DF/360
             / (1 + Fixing Rate × DF/360)
```

#### Caps, Floors y Collars

**Interest Rate Caps:**
- **Función**: Protección contra alza de tasas
- **Strike**: Tasa máxima a pagar (e.g., 10.00%)
- **Premium**: Costo upfront del cap
- **Underlying**: TIIE 28, TIIE 91

**Interest Rate Floors:**
- **Función**: Protección contra baja de tasas  
- **Strike**: Tasa mínima a recibir (e.g., 6.00%)
- **Premium**: Costo upfront del floor
- **Estrategia**: Monetización de views bajistas

**Interest Rate Collars:**
- **Estructura**: Compra cap + venta floor (o viceversa)
- **Ventaja**: Menor costo (premium neto)
- **Rango**: Protección en banda específica
- **Zero-Cost Collar**: Premium neto = 0

### Derivados de Inflación

#### Inflation-Linked Swaps

**UDI Swaps:**
- **Pata Real**: Cliente paga tasa real fija
- **Pata Nominal**: Cliente recibe TIIE 28 + spread
- **Referencia**: UDIs (Unidades de Inversión)
- **Uso**: Hedge de exposición inflacionaria

**TIIE Real Swaps:**
- **Pata Fija**: Tasa real fija anual
- **Pata Flotante**: TIIE Real (TIIE - inflación esperada)
- **Ventaja**: Cobertura directa de poder adquisitivo

#### Breakeven Inflation Analysis

**Cálculo de Inflación Implícita:**
```
Breakeven = [(1 + TIIE Nominal) / (1 + TIIE Real)] - 1
```

**Interpretación:**
- **Breakeven > Inflación esperada**: Oportunidad de venta de inflación
- **Breakeven < Inflación esperada**: Oportunidad de compra de inflación

---

## 3. DERIVADOS DE TIPO DE CAMBIO

### Cross Currency Swaps

#### Estructura Básica

**Cross Currency Interest Rate Swap:**
- **Intercambio inicial**: Principal en ambas divisas
- **Intercambio periódico**: Intereses en monedas respectivas
- **Intercambio final**: Reintercambio de principales
- **Divisas**: USD/MXN, EUR/MXN, GBP/MXN

**Ejemplo USD/MXN:**
```
Fecha inicio: 15 enero 2024
Fecha vencimiento: 15 enero 2029
Principal USD: $10 millones
Principal MXN: $180 millones (TC inicial: 18.00)
Cliente paga: 5.25% anual en USD
Cliente recibe: 9.75% anual en MXN
Frecuencia: Semestral
```

#### Aplicaciones Corporativas

**Financiamiento en Divisa Extranjera:**
- **Problema**: Empresa necesita USD pero solo tiene acceso a MXN
- **Solución**: CCS para sintetizar funding en USD
- **Beneficio**: Tasa potencialmente menor que préstamo directo USD

**Natural Hedging:**
- **Exposición**: Ingresos en USD, costos en MXN
- **Estrategia**: CCS que replique flujos naturales
- **Resultado**: Eliminación de riesgo cambiario

### Opciones de Divisas

#### Opciones Vanilla

**Call Options (USD/MXN):**
- **Right to Buy**: USD contra MXN
- **Strike**: Tipo de cambio de ejercicio (e.g., 19.00)
- **Expiry**: Fecha de vencimiento
- **Premium**: Costo de la opción (% del nocional)

**Put Options (USD/MXN):**
- **Right to Sell**: USD contra MXN  
- **Protection**: Contra depreciación del USD
- **Uso**: Exportadores mexicanos, inversionistas en USD

#### Estrategias con Opciones

**Protective Put (Collar):**
```
Posición: Long USD 10 millones
Compra: Put USD/MXN strike 18.50
Vende: Call USD/MXN strike 19.50
Resultado: Protección 18.50-19.50, costo reducido
```

**Risk Reversal:**
```
View: USD alcista vs MXN
Compra: Call USD/MXN strike 19.00
Vende: Put USD/MXN strike 18.00
Resultado: Exposición direccional, premium mínimo
```

**Straddle:**
```
View: Alta volatilidad esperada
Compra: Call USD/MXN strike 18.50
Compra: Put USD/MXN strike 18.50
Resultado: Profit si |movimiento| > premium pagado
```

### Opciones Exóticas

#### Opciones Barrera

**Knock-Out Options:**
- **Up-and-Out Call**: Se desactiva si USD/MXN > barrera
- **Down-and-Out Put**: Se desactiva si USD/MXN < barrera
- **Ventaja**: Premium significativamente menor
- **Riesgo**: Protección puede desaparecer

**Knock-In Options:**
- **Up-and-In Call**: Se activa si USD/MXN > barrera
- **Down-and-In Put**: Se activa si USD/MXN < barrera
- **Uso**: Protección contingente, reducción de costo

#### Opciones Asiáticas

**Average Rate Options:**
- **Settlement**: Basado en promedio de observaciones
- **Frecuencia**: Diaria, semanal, mensual
- **Ventaja**: Menor volatilidad, costo reducido
- **Uso**: Hedging de flujos recurrentes

**Average Strike Options:**
- **Strike**: Promedio de spot durante período observación
- **Uso**: Protección cuando entrada es gradual
- **Beneficio**: Optimización de nivel de protección

---

## 4. PRODUCTOS ESTRUCTURADOS OTC

### Notas Estructuradas

#### Certificados de Depósito Estructurados

Monex lidera el mercado mexicano con más de 1,700 notas estructuradas emitidas en 2022, representando $41,216 millones de pesos en nocional.

**Estructura Típica:**
- **Capital Protegido**: 85%-100% del principal
- **Upside Participation**: Exposición a subyacente específico
- **Vencimiento**: 6 meses a 5 años
- **Denominación**: MXN, USD, EUR

#### Certificados Ligados a Equity

**S&P 500 Linked Certificate:**
```
Principal: $1 millón USD
Protección: 90% del principal
Participación: 120% del performance S&P 500
Barrera: Down-and-in put a 70% del nivel inicial
Vencimiento: 2 años
Cupón: 0% (solo upside equity)
```

**Autocall Equity Certificate:**
```
Subyacente: Basket de 5 acciones mexicanas
Observación: Trimestral
Autocall: 105% del nivel inicial
Cupón autocall: 8.5% anual
Protección: 70% barrera americana
Vencimiento: 3 años máximo
```

#### Certificados de Divisas

**USD/MXN Range Accrual:**
```
Nocional: $500,000 USD
Rango: 17.50 - 19.50
Cupón diario: Si USD/MXN dentro del rango: 0.025%
Cupón máximo: 9.125% anual (365 días × 0.025%)
Observación: Diaria (días hábiles México)
Vencimiento: 1 año
```

**Multi-Currency Worst-Of:**
```
Basket: EUR/USD, GBP/USD, USD/JPY
Performance: Worst performing currency pair
Participación: 100% del worst performance (si positivo)
Protección: 80% barrera europea
Cupón: Memory coupon 2.5% trimestral
Vencimiento: 18 meses
```

### Bonos Bancarios Estructurados

#### Productos de Tasa

**Step-Up Floating Rate Notes:**
- **Año 1**: TIIE 28 + 100 bp
- **Año 2**: TIIE 28 + 150 bp  
- **Año 3**: TIIE 28 + 200 bp
- **Call Option**: Banco puede redimir a partir año 2
- **Protection**: Principal 100% protegido

**Inflation Plus Notes:**
- **Base Rate**: Inflación México (INPC)
- **Spread**: +300 basis points
- **Floor**: 4.0% anual mínimo
- **Cap**: 12.0% anual máximo
- **Vencimiento**: 5 años

#### Productos de Crédito

**Credit-Linked Notes:**
- **Reference Entity**: Gobierno de México
- **Credit Event**: Default, restructuring, acceleration
- **Coupon**: 200 bp sobre TIIE 28
- **Recovery**: Physical delivery o cash settlement
- **Rating**: Investment grade requerido

### Derivados de Commodities

#### Oil-Linked Products

**WTI Crude Oil Participation Certificate:**
```
Underlying: WTI Crude Oil ($/barrel)
Participation: 75% del performance WTI
Observation: Precio promedio mensual
Protection: 90% del principal
Cap: 25% máximo retorno
Tenor: 2 años
```

**Pemex vs WTI Spread Note:**
```
Underlying: Spread entre Pemex bond yield vs Oil price
Strategy: Benefit si spread se contrae
Protection: Capital preservation si spread > trigger
Payout: Linear participation in spread convergence
Maturity: 18 meses
```

#### Metals and Agriculture

**Gold Participation Certificate:**
- **Underlying**: Oro USD/onza troy
- **Participation**: 100% del performance oro
- **Currency**: MXN (incluye hedge USD/MXN)
- **Protection**: 95% del principal
- **Observation**: Fixing diario London PM

**Agricultural Basket Note:**
- **Underlying**: Maíz, trigo, soya (igual peso)
- **Participation**: 80% del mejor performer
- **Protection**: 85% capital protection
- **Seasonality**: Adjusted para ciclos agrícolas

---

## 5. GESTIÓN INTEGRAL DE RIESGOS CORPORATIVOS

### Assessment de Riesgos Corporativos

#### Metodología de Evaluación

**Fase 1: Identificación de Exposiciones**
1. **Mapeo de flujos de efectivo**: Ingresos, egresos, timing
2. **Análisis de balance**: Activos/pasivos por divisa y tasa
3. **Evaluación de competidores**: Riesgos relativos del sector
4. **Stress testing**: Escenarios extremos de mercado

**Fase 2: Cuantificación de Riesgos**
1. **Value at Risk (VaR)**: Pérdida potencial en condiciones normales
2. **Expected Shortfall**: Pérdida esperada en tail events
3. **Scenario Analysis**: Impacto de eventos específicos
4. **Sensitivity Analysis**: Efectos de movimientos graduales

**Fase 3: Desarrollo de Estrategia**
1. **Risk tolerance**: Definición de límites aceptables
2. **Cost-benefit analysis**: Evaluación cobertura vs exposición
3. **Hedging strategy**: Selección de instrumentos óptimos
4. **Implementation plan**: Timing y ejecución gradual

#### Herramientas de Medición

**Software Especializado:**
- **Bloomberg Risk & Analytics**: Análisis de portafolios
- **Reuters Eikon**: Data feeds y analytics
- **Monex Risk Platform**: Desarrollos internos propietarios
- **Monte Carlo Simulation**: Modelado de escenarios

**Métricas Clave:**
- **VaR 1-día 95%**: Pérdida máxima probable diaria
- **VaR 1-día 99%**: Pérdida en eventos extremos
- **Expected Shortfall**: Promedio pérdidas > VaR
- **Conditional VaR**: Peor 5% de outcomes

### Políticas de Hedging

#### Hedging de Riesgo Cambiario

**Policy Framework:**
- **Hedge Ratio**: 50%-90% de exposición neta
- **Horizon**: Rolling 12-month hedging
- **Instruments**: Forwards (60%), options (40%)
- **Rebalancing**: Mensual o por triggers específicos

**Triggers de Hedging:**
- **Exposición >$5 millones USD**: Cobertura mandatoria
- **Volatilidad >20% anualizada**: Incremento hedge ratio
- **Events**: Earnings, M&A, capex significativo

**Ejemplo de Política:**
```
Empresa exportadora:
- Cobertura mínima: 60% de ventas próximos 6 meses
- Cobertura máxima: 90% de ventas próximos 12 meses
- Instrumentos permitidos: Forwards, vanilla options
- Prohibido: Especulación, apalancamiento
- Reporting: Mensual al CFO, trimestral al board
```

#### Hedging de Riesgo de Tasa

**Asset-Liability Management:**
- **Duration Matching**: Activos vs pasivos
- **Gap Analysis**: Vencimientos por períodos
- **Interest Rate Sensitivity**: PV01 por bucket
- **Immunization**: Estrategias duration-neutral

**Estrategias Corporativas:**
- **Deuda Variable → Fija**: Swaps pay-fixed
- **Activos Fijos, Funding Variable**: Receive-fixed swaps
- **Anticipated Financing**: FRAs o caps para protección

### Implementación y Monitoring

#### Proceso de Implementación

**Pre-Trade Analysis:**
1. **Approval Process**: Committee review requerido
2. **Pricing Validation**: Multiple dealer quotes
3. **Legal Documentation**: ISDA agreements actualizados
4. **Credit Assessment**: Líneas de crédito disponibles

**Trade Execution:**
1. **Best Execution**: Competitive pricing process
2. **Trade Confirmation**: Matching dentro 30 minutos
3. **Settlement Instructions**: SSI validation
4. **Trade Capture**: Risk systems actualizados

**Post-Trade Management:**
1. **Mark-to-Market**: Valuación diaria
2. **Risk Reporting**: Dashboard actualizado
3. **P&L Attribution**: Análisis de drivers
4. **Hedge Effectiveness**: Testing ASC 815/IFRS 9

#### Reporting y Governance

**Daily Risk Report:**
- **Position Summary**: Exposiciones por tipo de riesgo
- **P&L Summary**: MTM, realized, unrealized
- **VaR Summary**: Actual vs limits
- **Limit Monitoring**: Excesos y near-misses

**Monthly Board Report:**
- **Strategy Performance**: ROI del programa hedging
- **Market Commentary**: Outlook y positioning
- **Policy Compliance**: Adherencia a políticas
- **Recommendations**: Ajustes estratégicos

---

## 6. CASOS PRÁCTICOS Y ESTRATEGIAS DE IMPLEMENTACIÓN

### Caso 1: Empresa Manufacturera Exportadora

#### Perfil de la Empresa

**Sector**: Automotriz (autopartes)
**Ingresos**: 60% USD, 40% MXN  
**Costos**: 20% USD, 80% MXN
**Exposición neta**: Long USD $50 millones anuales
**Estacionalidad**: Q4 representa 40% de ventas anuales

#### Análisis de Riesgos

**Exposure Mapping:**
```
Q1: Net long USD $8 millones
Q2: Net long USD $10 millones  
Q3: Net long USD $12 millones
Q4: Net long USD $20 millones
```

**Sensitivity Analysis:**
- **USD/MXN +1.00**: Impacto positivo $50 millones MXN
- **USD/MXN -1.00**: Impacto negativo $50 millones MXN
- **Volatilidad**: 15% anualizada histórica

#### Estrategia de Hedging Implementada

**Phase 1: Core Hedging (Months 1-6)**
```
Instrument: USD/MXN Forward
Notional: $30 millones USD (60% de exposición)
Maturity: Rolling 6-month forwards
Strike: 18.25 promedio ponderado
Objective: Base protection para cash flows
```

**Phase 2: Collar Strategy (Months 7-12)**
```
Instrument: USD/MXN Collar  
Notional: $15 millones USD (30% exposición restante)
Put Strike: 17.50 (protección downside)
Call Strike: 19.50 (renuncia upside)
Premium: Zero-cost collar
Objective: Protección asimétrica
```

**Phase 3: Seasonal Adjustment (Q4)**
```
Instrument: USD/MXN Call Options
Notional: $5 millones USD adicional
Strike: 18.00 (at-the-money)
Premium: 1.5% del nocional
Objective: Participación en upside estacional
```

#### Resultados Obtenidos

**Año 1 Performance:**
- **Hedge Effectiveness**: 85% de la exposición cubierta
- **Cost of Hedging**: 0.8% de ingresos anuales
- **Earnings Volatility**: Reducción del 60%
- **Cash Flow Predictability**: Improved planning accuracy

### Caso 2: Banco Comercial Regional

#### Perfil de la Institución

**Activos**: $15,000 millones MXN
**Cartera Crédito**: 70% tasa variable, 30% tasa fija
**Captación**: 80% tasa variable, 20% tasa fija
**Gap de Tasa**: Asset sensitive (beneficia de alzas)
**Regulatory**: Sujeto a requerimientos Basel III

#### Análisis ALM (Asset-Liability Management)

**Interest Rate Gap Analysis:**
```
0-3 meses: Gap positivo $2,500 millones (asset sensitive)
3-6 meses: Gap positivo $1,800 millones  
6-12 meses: Gap negativo $800 millones (liability sensitive)
1-3 años: Gap negativo $1,200 millones
3+ años: Gap neutral $0 millones
```

**Duration Analysis:**
- **Asset Duration**: 2.8 años promedio
- **Liability Duration**: 1.2 años promedio
- **Duration Gap**: +1.6 años (riesgo a baja de tasas)

#### Estrategia de Hedging

**Objective**: Reducir sensitivity a movimientos de tasas, mantener spread positivo

**Tactical Implementation:**
```
Instrument 1: Pay-Fixed IRS
Notional: $3,000 millones MXN
Tenor: 2 años
Fixed Rate: 9.25%
Floating: TIIE 28 + 0%
Effect: Reduce asset sensitivity corto plazo
```

```
Instrument 2: Interest Rate Collar
Notional: $2,000 millones MXN  
Cap Strike: 11.00% (venta para generar premium)
Floor Strike: 7.00% (compra para protección)
Effect: Monetizar view range-bound en tasas
```

```
Instrument 3: Swaption Strategy
Type: 1Y x 3Y Receiver Swaption
Strike: 8.50%
Premium: 0.45% del nocional
Rationale: Protección contra caída abrupta tasas
```

#### Risk Management Framework

**Governance Structure:**
- **ALCO Committee**: Reunión mensual, decisiones estratégicas
- **Risk Committee**: Oversight independiente, límites
- **Trading Committee**: Ejecución táctica, day-to-day
- **Audit Function**: Validación independiente de modelos

**Limit Structure:**
- **VaR Limit**: 2% del Tier 1 Capital
- **Duration Gap**: +/- 1 año máximo
- **Basis Point Value**: $500,000 MXN por 1 bp
- **Concentration**: Máximo 25% con un counterparty

### Caso 3: Corporativo de Infraestructura

#### Perfil del Proyecto

**Sector**: Energía renovable (parque eólico)
**Investment**: $300 millones USD total
**Financing**: 70% deuda, 30% equity
**Revenue**: Contratos PPA en USD, 20 años
**Construction**: 24 meses, exposición a inflación

#### Estructura de Riesgos

**Currency Risk:**
- **Revenue**: 100% USD (contratos PPA)
- **Capex**: 60% USD (equipment), 40% MXN (labor, local)
- **Opex**: 30% USD (maintenance), 70% MXN (operations)
- **Debt Service**: 100% USD (project finance)

**Interest Rate Risk:**
- **Construction Loan**: SOFR + 300 bp (floating)
- **Term Loan**: 7-year bullet, rate to be fixed
- **Exposure**: $210 millones USD debt

**Inflation Risk:**
- **Construction Costs**: Indexed to local inflation
- **O&M Escalation**: 3% annual real increase
- **PPA Escalation**: 2.5% USD inflation adjustment

#### Comprehensive Hedging Strategy

**Phase 1: Construction Period Hedging**

**FX Strategy:**
```
Objective: Match currency of costs with natural hedge
Instrument: MXN/USD Forward Program
Schedule: Monthly forwards for MXN capex requirements
Notional: $120 millones USD equivalent over 24 months
Execution: Rolling 6-month forward strip
```

**Interest Rate Strategy:**
```
Objective: Lock financing cost for term loan
Instrument: Forward Starting Interest Rate Swap
Start Date: Month 24 (construction completion)
Notional: $210 millones USD
Tenor: 7 years
Fixed Rate: 6.75% (locked during construction)
```

**Inflation Protection:**
```
Objective: Protect against Mexico construction inflation
Instrument: UDI-linked Cost Plus Contract
Coverage: 40% of construction costs (MXN portion)
Mechanism: Automatic adjustment per UDI variation
Cap: 8% annual inflation (catastrophic protection)
```

**Phase 2: Operational Period Strategy**

**Long-term FX Management:**
```
Natural Hedge: USD revenue vs USD debt service
Residual Exposure: Net USD 15 millones annual (operations)
Strategy: Quarterly forward sales of excess USD
Flexibility: 25% unhedged for USD appreciation upside
```

**Operational Cost Inflation:**
```
Challenge: O&M costs in MXN, revenue escalation in USD
Solution: Inflation swap (MXN inflation vs USD inflation)
Notional: $20 millones USD equivalent annually
Tenor: 15 years (after construction)
```

#### Risk Monitoring and KPIs

**Financial KPIs:**
- **DSCR (Debt Service Coverage Ratio)**: Maintain > 1.3x
- **Hedge Effectiveness**: ASC 815 compliance testing
- **Cash Flow at Risk**: 5% VaR < $10 millones USD
- **Unhedged Exposure**: Maximum 25% of any risk factor

**Operational KPIs:**
- **Availability Factor**: >95% (affects revenue)
- **O&M Cost/MWh**: Benchmark vs industry
- **Inflation Pass-through**: Actual vs contracted escalation

### Caso 4: Multinacional Farmacéutica

#### Perfil Corporativo

**Geografía**: México (manufacturing), LATAM sales
**Revenue Mix**: 40% MXN, 35% USD, 15% BRL, 10% COP
**Cost Structure**: 60% MXN, 30% USD, 10% EUR (IP/royalties)
**Seasonality**: Q4 = 35% annual sales (flu season)
**Regulatory**: FDA-approved facility, export quality

#### Multi-Currency Risk Assessment

**Translation Risk:**
- **Subsidiaries**: 5 countries, different functional currencies
- **Consolidation**: Monthly USD reporting
- **Volatility**: Earnings affected by FX translation
- **Hedge Accounting**: CTA hedge designation consideration

**Transaction Risk:**
```
Exposure Matrix (Monthly, USD millions):
          Inflows    Outflows    Net Position
MXN         15         -20          -5
USD         12          -8          +4  
BRL          6          -1          +5
COP          3          -1          +2
EUR          0          -3          -3
```

**Economic Risk:**
- **Competitive Position**: Currency-driven pricing pressure
- **Market Share**: FX impact on relative positioning
- **Input Costs**: Active pharmaceutical ingredients (APIs)

#### Multi-Layered Hedging Approach

**Layer 1: Transaction Hedging (Rolling 12-month)**
```
Objective: Hedge confirmed exposures
Coverage: 90% of net exposures by currency
Instruments: Forwards (70%), options (30%)
Rebalancing: Monthly, based on updated forecasts
```

**Layer 2: Forecasted Hedging (12-18 months)**
```
Objective: Hedge highly probable transactions
Coverage: 60% of forecasted exposures
Instruments: Options-heavy (maintain flexibility)
Probability Threshold: >80% confidence level
```

**Layer 3: Strategic Hedging (2-3 years)**
```
Objective: Hedge translation and economic exposures
Coverage: 25% of net investment in subsidiaries
Instruments: Long-dated forwards, debt in foreign currency
Accounting: Net investment hedge designation
```

**Collar Strategy for BRL Exposure:**
```
Background: High BRL volatility, significant exposure
Structure: BRL/USD Collar (monthly rolling)
Put Strike: 5.20 (protection level)
Call Strike: 5.80 (participate until this level)  
Premium: Zero cost (strikes adjusted monthly)
Notional: $5 millones USD equivalent
```

#### Advanced Strategies

**Natural Hedging Enhancement:**
- **Supply Chain Optimization**: Source APIs in export markets
- **Pricing Mechanisms**: Currency adjustment clauses
- **Netting Programs**: Inter-company exposures offset
- **Leading/Lagging**: Timing of receivables/payables

**Exotic Structures for Tail Risk:**
- **Worst-of Basket Options**: Protection against correlated EM selloff
- **Himalayan Options**: Sequential best performer elimination
- **Barrier Options**: Knock-in protection for extreme moves

**ESG-Aligned Hedging:**
- **Sustainable Finance Framework**: Green bond proceeds hedging
- **Carbon Credit Exposure**: USD/Carbon price correlation
- **Social Impact Bonds**: Currency-hedged impact investments

---

### Información de Contacto - Derivados y Riesgos

**Mesa de Derivados:**
- **Teléfono**: +52 55 5231-4580
- **Email**: derivados@monex.com.mx
- **Horarios**: 8:00 - 17:00 hrs (México)

**Structured Products:**
- **Teléfono**: +52 55 5231-4590  
- **Email**: estructurados@monex.com.mx
- **Minimum**: $1 millón MXN / $250,000 USD

**Risk Advisory:**
- **Teléfono**: +52 55 5231-4595
- **Email**: riskadvisory@monex.com.mx
- **Consultation**: Complimentary assessment

**Documentation:**
- **ISDA Master Agreement**: Legal template required
- **CSA (Credit Support Annex)**: Collateral management
- **Confirmations**: Electronic platform available
- **Netting**: Close-out netting agreements

**Regulatory Compliance:**
- **MiFID II**: European clients coverage
- **Dodd-Frank**: US persons compliance  
- **EMIR**: European Market Infrastructure
- **Local**: CNBV, Banco de México adherence

---

*La información contenida es solo para fines educativos. Los derivados conllevan riesgo sustancial de pérdida. Consulte con profesionales calificados antes de implementar estrategias. Monex no garantiza resultados específicos de las estrategias descritas.*

