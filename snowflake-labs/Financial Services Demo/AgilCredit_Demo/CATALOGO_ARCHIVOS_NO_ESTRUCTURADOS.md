# 📂 Catálogo de Archivos No Estructurados - AgilCredit

## 📊 Resumen

- **Total archivos XML:** 11
- **Total archivos JSON:** 9
- **Total archivos PDF/TXT:** 10
- **Tamaño total:** ~220 KB

---

## 📄 Archivos XML (11 archivos)

### 1. **reporte_riesgo_cartera.xml** (10 KB)
- **Descripción:** Análisis completo de riesgo crediticio de la cartera total
- **Contenido:** 
  - Indicadores IMOR, cartera vencida, reservas preventivas
  - Distribución por calificación de riesgo (A-E)
  - Métricas de cobertura de morosidad
- **Uso:** Análisis regulatorio, reportes ejecutivos

### 2. **reporte_cnbv_operaciones_inusuales.xml** (19 KB)
- **Descripción:** Reporte regulatorio para CNBV sobre operaciones inusuales
- **Contenido:**
  - Operaciones sospechosas detectadas
  - Clientes involucrados y montos
  - Acciones tomadas por compliance
- **Uso:** Cumplimiento PLD, auditorías

### 3. **reporte_morosidad_mensual.xml** (4.2 KB)
- **Descripción:** Reporte mensual de gestión de morosidad
- **Contenido:**
  - Morosidad por tramos de días (1-30, 31-60, 61-90, 90+)
  - Morosidad por producto
  - Acciones de cobranza y recuperación
- **Uso:** Gestión de cobranza, KPIs operativos

### 4. **reporte_solvencia_capital.xml** (3.6 KB)
- **Descripción:** Índice de capitalización y cumplimiento Basilea III
- **Contenido:**
  - Capital contable (Nivel 1 y 2)
  - Activos ponderados por riesgo (APR)
  - ICAP y ratios financieros
- **Uso:** Reporting regulatorio, análisis de solvencia

### 5. **reporte_quejas_condusef.xml** (5.2 KB)
- **Descripción:** Reporte trimestral de atención a usuarios para CONDUSEF
- **Contenido:**
  - Quejas por causa y canal
  - Tasas de resolución
  - Acciones correctivas implementadas
- **Uso:** Cumplimiento regulatorio, mejora continua

### 6. **catalogo_productos_cnbv.xml** (4.0 KB)
- **Descripción:** Catálogo oficial de productos registrados ante CNBV
- **Contenido:**
  - 5 productos con características completas
  - Rangos de tasas, montos, plazos
  - Requisitos mínimos por producto
- **Uso:** Originación, compliance, marketing

### 7. **balance_general_q3.xml** (2.7 KB)
- **Descripción:** Balance general trimestral Q3 2025
- **Contenido:**
  - Activos (circulante y no circulante)
  - Pasivos (corto y largo plazo)
  - Capital contable
- **Uso:** Reporting financiero, análisis de solvencia

### 8. **estado_resultados_q3.xml** (2.1 KB)
- **Descripción:** Estado de resultados Q3 2025
- **Contenido:**
  - Ingresos por intereses y comisiones
  - Gastos operativos detallados
  - Utilidad neta e indicadores (ROE, ROA)
- **Uso:** Análisis de rentabilidad, presupuestos

### 9. **reporte_auditoria_interna.xml** (3.4 KB)
- **Descripción:** Informe de auditoría interna de procesos crediticios
- **Contenido:**
  - Hallazgos (alto, medio, bajo riesgo)
  - Recomendaciones y responsables
  - Plan de seguimiento
- **Uso:** Control interno, mejora de procesos

### 10. **reporte_operaciones_relevantes.xml** (2.7 KB)
- **Descripción:** Operaciones relevantes PLD reportadas
- **Contenido:**
  - Operaciones sospechosas individuales
  - Montos y justificaciones
  - Acciones y estatus
- **Uso:** Prevención de lavado de dinero

### 11. **reporte_provision_reservas.xml** (3.7 KB)
- **Descripción:** Detalle de provisiones y reservas preventivas
- **Contenido:**
  - Reservas por calificación de riesgo
  - Cumplimiento de reservas requeridas
  - Movimientos del periodo
- **Uso:** Contabilidad, análisis de riesgo

---

## 📋 Archivos JSON (9 archivos)

### 1. **perfiles_clientes_detallados.json** (16 KB) - 10 registros
- **Descripción:** Perfiles enriquecidos de clientes con +30 campos por cliente
- **Contenido:**
  - Datos personales y contacto
  - Información laboral y financiera
  - Historial crediticio y scoring ML
  - Segmentación y comportamiento
- **Uso:** Análisis de clientes, modelos ML, CRM

### 2. **transacciones_logs.json** (9.9 KB) - 100 registros
- **Descripción:** Logs detallados de transacciones
- **Contenido:**
  - Metadata de dispositivo y ubicación GPS
  - Checks de fraude en tiempo real
  - Detalles de procesamiento
- **Uso:** Detección de fraude, análisis de comportamiento

### 3. **logs_aplicacion_movil.json** (4.0 KB) - 5 registros
- **Descripción:** Eventos de la aplicación móvil
- **Contenido:**
  - Login, pagos, solicitudes de crédito
  - Información de dispositivo y rendimiento
  - Errores y problemas técnicos
- **Uso:** Product analytics, debugging, UX

### 4. **eventos_scoring_ml.json** (5.1 KB) - 5 registros
- **Descripción:** Eventos del sistema de scoring con ML
- **Contenido:**
  - Cálculos de scores (crédito, fraude, churn)
  - Features utilizados y resultados
  - Recomendaciones automáticas
- **Uso:** ML ops, análisis de modelos, auditoría

### 5. **historial_cambios_creditos.json** (2.0 KB) - 3 registros
- **Descripción:** Registro de modificaciones a créditos
- **Contenido:**
  - Ajustes de tasa, extensiones, reestructuras
  - Valores anteriores vs nuevos
  - Aprobadores y razones
- **Uso:** Auditoría, compliance, análisis de cartera

### 6. **datos_cobranza_gestion.json** (1.9 KB) - 3 registros
- **Descripción:** Gestiones de cobranza realizadas
- **Contenido:**
  - Llamadas, SMS, visitas domiciliarias
  - Compromisos de pago
  - Notas y seguimientos
- **Uso:** Gestión de cobranza, recuperación

### 7. **configuracion_productos_reglas.json** (2.8 KB) - 2 registros
- **Descripción:** Configuración de reglas de negocio por producto
- **Contenido:**
  - Reglas de originación y aprobación
  - Fórmulas de cálculo de tasas y montos
  - Políticas de cobranza
- **Uso:** Motor de reglas, originación, compliance

### 8. **eventos_seguridad_accesos.json** (2.5 KB) - 3 registros
- **Descripción:** Eventos de seguridad y accesos sospechosos
- **Contenido:**
  - Intentos de login fallidos
  - Accesos no autorizados
  - Escalamiento de privilegios
- **Uso:** Seguridad, SOC, auditoría

### 9. **metricas_performance_sistema.json** (3.3 KB) - 4 registros
- **Descripción:** Métricas de rendimiento de sistemas
- **Contenido:**
  - API gateway, base de datos, app móvil
  - Tiempos de respuesta, tasa de errores
  - Uso de recursos (CPU, memoria)
- **Uso:** DevOps, monitoreo, optimización

---

## 📑 Archivos PDF/TXT (10 archivos)

### 1. **contrato_credito_template.txt** (14 KB)
- **Descripción:** Template de contrato de crédito personal
- **Contenido:**
  - Términos y condiciones contractuales
  - Obligaciones del acreditado
  - Tabla de pagos y amortización
- **Uso:** Generación de contratos, referencia legal

### 2. **estado_cuenta_mensual.txt** (10 KB)
- **Descripción:** Estado de cuenta mensual de cliente
- **Contenido:**
  - Resumen de saldo y movimientos del mes
  - Tabla de amortización
  - Opciones de pago y fechas
- **Uso:** Comunicación con clientes, extracto de transacciones

### 3. **politica_prevencion_lavado_dinero.txt** (17 KB)
- **Descripción:** Política interna de PLD/FT
- **Contenido:**
  - Marco legal y regulatorio
  - Procedimientos KYC
  - Detección de operaciones inusuales
  - Estructura de gobierno
- **Uso:** Compliance, auditorías, capacitación

### 4. **carta_aprobacion_credito.txt** (12 KB)
- **Descripción:** Notificación de aprobación de crédito
- **Contenido:**
  - Condiciones del crédito aprobado
  - Tabla de amortización
  - Requisitos para desembolso
  - Beneficios adicionales
- **Uso:** Comunicación con clientes, onboarding

### 5. **manual_politicas_credito.txt** (9.9 KB)
- **Descripción:** Manual de políticas de otorgamiento de crédito
- **Contenido:**
  - Criterios de evaluación (5 C's)
  - Facultades de aprobación
  - Causales de rechazo
  - Condiciones por producto
- **Uso:** Originación, capacitación, auditoría

### 6. **carta_rechazo_credito.txt** (7.6 KB)
- **Descripción:** Notificación de rechazo de solicitud
- **Contenido:**
  - Motivos del dictamen
  - Recomendaciones de mejora
  - Derechos del usuario
  - Opciones de reevaluación
- **Uso:** Comunicación con clientes, cumplimiento

### 7. **terminos_condiciones_app_movil.txt** (14 KB)
- **Descripción:** Términos y condiciones de la app móvil
- **Contenido:**
  - Descripción de servicios
  - Privacidad y protección de datos
  - Seguridad y responsabilidades
  - Propiedad intelectual
- **Uso:** Legal, compliance, onboarding digital

### 8. **notificacion_atraso_pago.txt** (5.1 KB)
- **Descripción:** Carta de notificación de pago atrasado
- **Contenido:**
  - Detalle del adeudo
  - Consecuencias del atraso
  - Opciones de pago
  - Apoyo para dificultades
- **Uso:** Gestión de cobranza, comunicación

### 9. **comprobante_pago.txt** (4.9 KB)
- **Descripción:** Comprobante de pago realizado
- **Contenido:**
  - Datos de la transacción
  - Distribución capital/intereses
  - Resumen de crédito actualizado
- **Uso:** Confirmación de transacciones, contabilidad

### 10. **reporte_ejecutivo_trimestral.txt** (11 KB)
- **Descripción:** Reporte ejecutivo para consejo Q3 2025
- **Contenido:**
  - KPIs financieros y operativos
  - Originación y cartera
  - Rentabilidad y solvencia
  - Perspectivas y riesgos
- **Uso:** Gobierno corporativo, reporting ejecutivo

### 11. **guia_usuario_plataforma.txt** (15 KB)
- **Descripción:** Manual de usuario de plataforma web
- **Contenido:**
  - Instrucciones paso a paso
  - Funcionalidades disponibles
  - Preguntas frecuentes
  - Soporte técnico
- **Uso:** Atención a clientes, capacitación, UX

---

## 🎯 Casos de Uso por Archivo

### Análisis de Riesgo y Compliance
- `reporte_riesgo_cartera.xml`
- `reporte_solvencia_capital.xml`
- `reporte_provision_reservas.xml`
- `reporte_cnbv_operaciones_inusuales.xml`
- `reporte_operaciones_relevantes.xml`

### Gestión de Cobranza
- `reporte_morosidad_mensual.xml`
- `datos_cobranza_gestion.json`
- `historial_cambios_creditos.json`
- `notificacion_atraso_pago.txt`

### Comunicación con Clientes
- `estado_cuenta_mensual.txt`
- `carta_aprobacion_credito.txt`
- `carta_rechazo_credito.txt`
- `comprobante_pago.txt`

### Legal y Cumplimiento
- `contrato_credito_template.txt`
- `politica_prevencion_lavado_dinero.txt`
- `terminos_condiciones_app_movil.txt`
- `manual_politicas_credito.txt`

### Reporting Ejecutivo
- `reporte_ejecutivo_trimestral.txt`

### Atención al Cliente
- `guia_usuario_plataforma.txt`

### Atención al Cliente y Calidad
- `reporte_quejas_condusef.xml`

### Análisis Financiero
- `balance_general_q3.xml`
- `estado_resultados_q3.xml`

### Machine Learning y Analytics
- `perfiles_clientes_detallados.json`
- `eventos_scoring_ml.json`
- `transacciones_logs.json`

### Operaciones y Tecnología
- `logs_aplicacion_movil.json`
- `metricas_performance_sistema.json`
- `eventos_seguridad_accesos.json`

### Configuración y Reglas de Negocio
- `catalogo_productos_cnbv.xml`
- `configuracion_productos_reglas.json`

### Auditoría y Control
- `reporte_auditoria_interna.xml`
- `eventos_seguridad_accesos.json`
- `historial_cambios_creditos.json`

---

## 📊 Estadísticas

### Por Formato
| Formato | Cantidad | Tamaño Total | Tamaño Promedio |
|---------|----------|--------------|-----------------|
| XML | 11 | ~61 KB | ~5.5 KB |
| JSON | 9 | ~47 KB | ~5.2 KB |
| PDF/TXT | 10 | ~110 KB | ~11 KB |
| **Total** | **30** | **~218 KB** | **~7.3 KB** |

### Por Categoría
| Categoría | Archivos | Porcentaje |
|-----------|----------|------------|
| Compliance/Regulatorio | 10 | 33% |
| Comunicación Clientes | 5 | 17% |
| Analytics/ML | 4 | 13% |
| Legal/Políticas | 4 | 13% |
| Finanzas | 3 | 10% |
| Operaciones/Cobranza | 3 | 10% |
| Seguridad | 2 | 7% |
| Auditoría | 2 | 7% |

---

## 🚀 Cómo Procesar Estos Archivos

### 1. Subir al Stage de Snowflake
```bash
# JSON
PUT file://./datos_no_estructurados/json/*.json 
    @AGILCREDIT_UNSTRUCTURED_DATA/json/ 
    AUTO_COMPRESS=FALSE;

# XML
PUT file://./datos_no_estructurados/xml/*.xml 
    @AGILCREDIT_UNSTRUCTURED_DATA/xml/ 
    AUTO_COMPRESS=FALSE;

# PDF/TXT
PUT file://./datos_no_estructurados/pdfs/*.txt 
    @AGILCREDIT_UNSTRUCTURED_DATA/pdfs/ 
    AUTO_COMPRESS=FALSE;
```

### 2. Verificar
```sql
LIST @AGILCREDIT_UNSTRUCTURED_DATA;
```

### 3. Procesar con los Scripts
- **`AgilCredit_Parse_Unstructured_Data.sql`** - Script principal
- **`GUIA_DATOS_NO_ESTRUCTURADOS.md`** - Tutorial completo

---

## 🎓 Aprendizajes Clave

1. **Variedad de Datos:** 30 archivos cubren todas las áreas de una fintech (riesgo, compliance, operaciones, tecnología, legal, comunicación)
2. **Formatos Múltiples:** XML para reportes regulatorios, JSON para logs/eventos, PDF/TXT para documentos y contratos
3. **Datos Realistas:** Estructura y contenido reflejan datos reales de una SOFOM ENR mexicana
4. **Interconectados:** Los archivos se relacionan entre sí (ej: cliente en JSON tiene crédito en XML y estado de cuenta en TXT)
5. **Procesamiento Completo:** Ejemplos de procesamiento de texto no estructurado con NLP y análisis de sentimiento

---

**Creado:** Octubre 22, 2025  
**Autor:** AgilCredit Data Engineering Team  
**Versión:** 1.0

