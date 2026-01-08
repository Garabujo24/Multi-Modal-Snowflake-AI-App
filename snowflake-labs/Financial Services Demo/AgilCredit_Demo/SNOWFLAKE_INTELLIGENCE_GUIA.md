# 🤖 Guía de Snowflake Intelligence para AgilCredit

## Introducción a Snowflake Intelligence (Cortex Analyst)

Snowflake Intelligence utiliza el modelo semántico de AgilCredit para permitir **consultas en lenguaje natural** sobre los datos financieros. El agente de IA entiende el contexto del negocio y genera automáticamente consultas SQL precisas.

---

## 🎯 Componentes del Modelo Semántico

### 1. **Description** - Contexto del Negocio

El modelo incluye una descripción detallada que proporciona al agente:

#### Información de AgilCredit:
- ✅ Tipo de empresa: SOFOM (Sociedad Financiera de Objeto Múltiple)
- ✅ Fundación: 2020
- ✅ Especialización: Créditos personales, PyME, nómina, automotrices
- ✅ Mercado: México (CDMX, Guadalajara, Monterrey, etc.)

#### Los 4 Pilares de Análisis:

**1. ANÁLISIS DE RIESGO CREDITICIO**
```
- Score de riesgo: 0-100 (mayor es mejor)
- Buró de Crédito: 550-850
- Segmentos: Premium (>750), Oro (680-750), Plata (620-679), Bronce (<620)
- IMOR = Cartera Vencida / Cartera Total
- Estados: Vigente, Mora (1-89 días), Vencido (90+ días), Liquidado
```

**2. DETECCIÓN DE FRAUDE**
```
- Score de fraude: 0-100
- Niveles: Alto (>80), Medio (50-80), Bajo (<50)
- Patrones: ubicación sospechosa, dispositivo no reconocido, monto inusual
- Estados: Nueva, En Revisión, Confirmado Fraude, Falso Positivo
```

**3. RENTABILIDAD DE CLIENTES**
```
- LTV (Lifetime Value): Valor estimado del cliente
- CAC (Customer Acquisition Cost): Costo de adquisición
- Ratio LTV/CAC óptimo: > 3.0
- Segmentos: Alto Valor, Medio Valor, Valor Estándar, Bajo Valor
```

**4. CUMPLIMIENTO REGULATORIO**
```
- KYC: Know Your Customer
- PLD: Prevención de Lavado de Dinero
- Listas: OFAC, PEP, Bloqueados CNBV
- Actualización: Cada 12 meses
```

---

## 🎓 Orchestration Instructions - Guías de Análisis

### Priorización de Consultas

El agente sabe qué tablas usar según el tipo de pregunta:

| Tema | Tablas Principales |
|------|-------------------|
| **Riesgo/Morosidad** | `creditos`, `clientes` |
| **Fraude/Seguridad** | `alertas_fraude`, `transacciones` |
| **Rentabilidad/Valor** | `rentabilidad_clientes` |
| **Cumplimiento/KYC** | `eventos_cumplimiento` |
| **Análisis Ejecutivo** | Combinación de todas |

### Cálculos Importantes

El agente conoce las fórmulas exactas:

**IMOR (Índice de Morosidad)**
```sql
IMOR = (Cartera Vencida / Cartera Total) * 100
donde Cartera Vencida = SUM(saldo_actual) 
WHERE estatus IN ('MORA', 'VENCIDO')
```

**Ratio LTV/CAC**
```sql
Ratio = LTV_ESTIMADO / CAC
Interpretación:
  > 3.0 = Excelente
  1.0-3.0 = Aceptable
  < 1.0 = Problemático
```

**Tasa de Confirmación de Fraude**
```sql
Tasa = (Fraudes Confirmados / Total Alertas) * 100
```

### Filtros y Segmentación

El agente aplica automáticamente:
- ✅ Excluye créditos 'LIQUIDADO' para análisis de cartera activa
- ✅ Segmenta por: SEGMENTO_CLIENTE, ESTADO, OCUPACION
- ✅ Agrupa por: CALIFICACION_BURO, SCORE_RIESGO, DIAS_MORA

### Alertas y Umbrales

El agente reconoce situaciones críticas:
- 🚨 IMOR > 5%: Requiere atención inmediata
- 🚨 Alertas fraude ALTO: Prioridad máxima
- 🚨 Ratio LTV/CAC < 1.0: Modelo insostenible
- ⚠️ KYC > 365 días: Requiere actualización
- ⚠️ Concentración > 10%: Riesgo alto

---

## 💬 Response Instructions - Formato de Respuestas

### Estructura de Respuestas

El agente proporciona respuestas estructuradas:

```
1. Resumen ejecutivo (1-2 oraciones)
2. Métricas clave
3. Contexto e interpretación
4. Recomendaciones (cuando aplica)
5. Consideraciones importantes
```

### Formateo de Números

| Tipo | Formato | Ejemplo |
|------|---------|---------|
| **Montos** | "$X,XXX.XX MXN" | "$148,750.25 MXN" |
| **Millones** | "$X.XM MXN" | "$148.8M MXN" |
| **Porcentajes** | "XX.XX%" | "4.35%" |
| **Conteos** | "X,XXX clientes" | "1,200 clientes" |
| **Ratios** | "X.Xx" | "3.5x" |
| **Scores** | "XX.X de 100" | "85.3 de 100" |

### Interpretación de Métricas

#### IMOR (Índice de Morosidad)
- ✅ **< 3%**: Excelente
- ✅ **3-5%**: Bueno (objetivo)
- ⚠️ **5-8%**: Aceptable, requiere monitoreo
- 🚨 **> 8%**: Problemático, acción inmediata

#### Ratio LTV/CAC
- ✅ **> 5.0**: Excelente, muy saludable
- ✅ **3.0-5.0**: Bueno, sostenible
- ⚠️ **1.0-3.0**: Aceptable, mejorable
- 🚨 **< 1.0**: Crítico, revisar estrategia

#### Score de Riesgo
- ✅ **80-100**: Riesgo muy bajo
- ✅ **60-79**: Riesgo bajo
- ⚠️ **40-59**: Riesgo medio
- 🚨 **20-39**: Riesgo alto
- 🚨 **0-19**: Riesgo muy alto

#### Score de Fraude
- 🚨 **80-100**: Muy alta probabilidad, BLOQUEAR
- 🚨 **60-79**: Alta probabilidad, revisión urgente
- ⚠️ **40-59**: Sospechoso, investigar
- ✅ **< 40**: Bajo riesgo

### Uso de Alertas Visuales

El agente usa emojis para destacar información:
- ⚠️ Métricas fuera de rango
- 🚨 Situaciones urgentes
- ✅ Oportunidades positivas
- 📉 Tendencias preocupantes
- 📈 Mejoras significativas

---

## 🎯 Ejemplos de Uso

### Ejemplo 1: Análisis de Morosidad

**Pregunta**:
```
¿Cuál es la morosidad actual de AgilCredit?
```

**Respuesta esperada del agente**:
```
La cartera de AgilCredit presenta un IMOR del 4.35%, dentro del 
rango objetivo (< 5%). Esto representa $6.47M MXN en cartera 
vencida sobre una cartera total de $148.75M MXN.

Análisis por segmento:
- Premium: 2.1% ✅
- Oro: 3.8% ✅
- Plata: 5.2% ⚠️
- Bronce: 7.8% 🚨

Recomendación: Reforzar cobranza preventiva en segmento Bronce 
para mantener el IMOR general bajo control.
```

---

### Ejemplo 2: Clientes Rentables

**Pregunta**:
```
Muéstrame los 5 clientes más rentables y su LTV/CAC
```

**Respuesta esperada del agente**:
```
Los 5 clientes más rentables han generado $127K MXN en utilidad 
neta acumulada:

1. CLI000287 (Premium) - Utilidad: $34.5K, LTV/CAC: 4.8x ✅
2. CLI000145 (Oro) - Utilidad: $28.3K, LTV/CAC: 4.2x ✅
3. CLI000521 (Premium) - Utilidad: $25.1K, LTV/CAC: 5.1x ✅
4. CLI000678 (Oro) - Utilidad: $21.8K, LTV/CAC: 3.9x ✅
5. CLI000892 (Premium) - Utilidad: $17.5K, LTV/CAC: 4.5x ✅

Todos pertenecen a segmentos Oro o Premium, pagan puntualmente 
y tienen múltiples productos.

✅ Oportunidad: Implementar programa VIP para retener estos 
clientes de alto valor y fomentar cross-selling.
```

---

### Ejemplo 3: Alertas de Fraude

**Pregunta**:
```
¿Cuántas alertas de fraude de nivel alto tenemos sin resolver?
```

**Respuesta esperada del agente**:
```
🚨 Situación de alertas de fraude:

Alertas activas nivel ALTO: 12
- Nuevas: 5 (< 24 hrs)
- En revisión: 7 (requieren seguimiento)

Clientes afectados: 10
Score promedio de fraude: 86.3 de 100

Tipos principales:
1. Ubicación geográfica sospechosa: 5 casos
2. Dispositivo no reconocido: 4 casos
3. Monto inusual: 3 casos

🚨 Acción requerida: Todas las alertas nivel ALTO deben 
revisarse en < 24 horas según política de seguridad. 
Priorizar las 5 alertas nuevas.
```

---

### Ejemplo 4: Cumplimiento KYC

**Pregunta**:
```
¿Qué porcentaje de clientes necesita actualizar su KYC?
```

**Respuesta esperada del agente**:
```
Status de cumplimiento KYC:

Total clientes activos: 950
- Cumple (< 365 días): 742 clientes (78.1%) ✅
- Requiere actualización (> 365 días): 143 clientes (15.1%) ⚠️
- Pendiente de revisión: 48 clientes (5.1%) ⚠️
- Rechazado/Incompleto: 17 clientes (1.8%) 🚨

Prioridad por exposición:
- Alto riesgo (> $100K): 23 clientes requieren actualización urgente
- Medio riesgo ($50K-$100K): 58 clientes
- Bajo riesgo (< $50K): 62 clientes

Recomendación: Iniciar campaña de actualización KYC priorizando 
los 23 clientes de alta exposición. Meta: 90% de cumplimiento.
```

---

### Ejemplo 5: Análisis de Producto

**Pregunta**:
```
¿Qué producto crediticio tiene mejor desempeño?
```

**Respuesta esperada del agente**:
```
Análisis comparativo de productos (por rentabilidad y riesgo):

Mejor desempeño general: Crédito Nómina Plus
- Cartera: $18.95M MXN (12.7% del total)
- IMOR: 2.45% ✅ (el más bajo)
- Utilidad neta: $7.2M MXN
- Margen: 38% ✅

Ranking completo:
1. Crédito Nómina Plus: Rentable + Bajo riesgo ✅
2. Crédito PyME Crecimiento: Alta rentabilidad, riesgo moderado
3. Crédito Personal Express: Volumen alto, riesgo medio
4. Crédito Auto Fácil: Rentable, riesgo controlado
5. Línea Flexible: Baja rentabilidad, riesgo alto ⚠️

📈 Oportunidad: Expandir Crédito Nómina Plus. Revisar criterios 
de Línea Flexible (IMOR 8.92%).
```

---

## 🚀 Cómo Usar en Snowflake

### Paso 1: Cargar el Modelo Semántico

1. Ve a **Snowflake UI** → **Data** → **Semantic Models**
2. Click en **"Create Semantic Model"**
3. Sube el archivo `agilcredit_modelo_semantico.yaml`
4. Valida que no haya errores
5. **Publish** el modelo

### Paso 2: Usar Snowflake Intelligence

1. Ve a **AI & ML** → **Cortex Analyst**
2. Selecciona el modelo: `AgilCredit_Modelo_Analitico`
3. Escribe tu pregunta en lenguaje natural
4. El agente generará:
   - Consulta SQL
   - Resultados
   - Interpretación
   - Recomendaciones

### Paso 3: Preguntas Sugeridas para Probar

**Análisis Ejecutivo**:
- "Dame un resumen ejecutivo de AgilCredit"
- "¿Cuáles son los principales KPIs del negocio?"
- "Muestra la evolución de la originación en los últimos 6 meses"

**Riesgo**:
- "¿Cuál es el IMOR actual?"
- "Top 10 clientes de mayor riesgo"
- "Concentración de cartera por estado"

**Fraude**:
- "Alertas de fraude activas por nivel de riesgo"
- "Patrones de fraude más comunes"
- "Tasa de confirmación de fraude"

**Rentabilidad**:
- "Clientes más rentables"
- "Ratio LTV/CAC por segmento"
- "Margen de rentabilidad por producto"

**Cumplimiento**:
- "Status de KYC por segmento"
- "Clientes que requieren actualización"
- "Eventos de cumplimiento del último mes"

---

## 📚 Glosario para el Agente

El modelo incluye un glosario completo de términos que el agente entiende:

### Métricas
- **CAT**: Costo Anual Total
- **IMOR**: Índice de Morosidad
- **LTV**: Lifetime Value
- **CAC**: Customer Acquisition Cost
- **CURP**: Clave Única de Registro de Población
- **RFC**: Registro Federal de Contribuyentes

### Regulación
- **CNBV**: Comisión Nacional Bancaria y de Valores
- **CONDUSEF**: Comisión Nacional para Protección de Usuarios
- **SOFOM**: Sociedad Financiera de Objeto Múltiple
- **KYC**: Know Your Customer
- **PLD**: Prevención de Lavado de Dinero
- **PEP**: Personas Políticamente Expuestas
- **OFAC**: Office of Foreign Assets Control

### Estados
- **VIGENTE**: Al corriente, sin atrasos
- **MORA**: 1-89 días de atraso
- **VENCIDO**: 90+ días de atraso
- **LIQUIDADO**: Pagado completamente

---

## ✅ Mejores Prácticas

### Para Hacer Preguntas:

1. **Sé específico**: En lugar de "dame datos", pregunta "¿cuál es el IMOR del segmento Premium?"
2. **Usa términos del dominio**: El agente entiende IMOR, LTV, CAC, KYC, etc.
3. **Pide interpretación**: Pregunta "¿es bueno?" o "¿qué significa esto?"
4. **Solicita recomendaciones**: Agrega "¿qué debería hacer?" a tu pregunta
5. **Combina métricas**: "Muéstrame morosidad Y rentabilidad por segmento"

### Para Obtener Mejores Respuestas:

1. ✅ "¿Cuál es el IMOR y cómo se compara con el objetivo?"
2. ✅ "Top 10 clientes de alto riesgo con su exposición"
3. ✅ "Distribución de alertas de fraude por tipo y nivel"
4. ✅ "Rentabilidad por producto, ordenado de mejor a peor"

### Evita Preguntas Demasiado Vagas:

1. ❌ "Dame información"
2. ❌ "¿Qué pasa?"
3. ❌ "Muestra datos"

---

## 🎯 Casos de Uso Avanzados

### 1. Análisis de Tendencias
```
"Muéstrame la tendencia de morosidad por mes en los últimos 12 meses"
```

### 2. Comparaciones
```
"Compara la rentabilidad del segmento Premium vs Bronce"
```

### 3. Análisis Drill-Down
```
"¿Qué producto tiene mayor morosidad? Ahora muéstrame qué 
segmento de cliente tiene más problemas en ese producto"
```

### 4. Análisis What-If
```
"Si el IMOR aumenta 2 puntos porcentuales, ¿cuánto afecta 
la utilidad neta?"
```

### 5. Detección de Anomalías
```
"¿Hay algún cliente o producto con métricas inusuales?"
```

---

## 🔍 Troubleshooting

### Si el agente no entiende:
1. Reformula usando términos del glosario
2. Divide preguntas complejas en simples
3. Verifica que el modelo semántico esté publicado
4. Asegúrate de tener permisos en las tablas

### Si los resultados son inesperados:
1. Revisa la consulta SQL generada
2. Verifica los filtros aplicados
3. Confirma que los datos existan en las tablas
4. Valida las fórmulas de cálculo

---

## 📞 Soporte

Para más información sobre Snowflake Intelligence:
- [Documentación Oficial](https://docs.snowflake.com/en/user-guide/ml-powered-analysis)
- [Cortex Analyst Guide](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [Semantic Model Specification](https://docs.snowflake.com/en/user-guide/snowflake-cortex/semantic-model-spec)

---

<div align="center">

**¡El agente de IA está listo para ayudarte a analizar AgilCredit!** 🚀

Pregunta en lenguaje natural y obtén insights accionables

</div>




