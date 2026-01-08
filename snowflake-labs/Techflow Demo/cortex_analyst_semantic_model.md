# CORTEX ANALYST - MODELO SEMÁNTICO CONCEPTUAL
## TechFlow Solutions Demo Kit

### Descripción General del Modelo Semántico

El modelo semántico de Cortex Analyst para TechFlow Solutions está diseñado para democratizar el acceso a los datos empresariales, permitiendo a usuarios de negocio hacer preguntas en lenguaje natural sobre métricas clave de la empresa.

---

## ENTIDADES PRINCIPALES

### 1. **Productos** (`PRODUCTOS`)
- **Descripción**: Catálogo completo de productos y servicios
- **Atributos clave**: 
  - Categorías (Software, Servicios, Seguridad, IA/ML, Herramientas)
  - Precios, costos y márgenes
  - Estado del producto y fechas de lanzamiento

### 2. **Clientes** (`CLIENTES`) 
- **Descripción**: Base de clientes con segmentación empresarial
- **Atributos clave**:
  - Segmentos (Enterprise, Mid-Market, SMB, Education, Government)
  - Geografía (Norte América, Europa, Asia-Pacífico)
  - Industrias y tamaño de empresa

### 3. **Transacciones** (`TRANSACCIONES`)
- **Descripción**: Registro completo de ventas y transacciones
- **Atributos clave**:
  - Canales de venta (Venta Directa, Partner, Online)
  - Estados de pedidos y métodos de pago
  - Descuentos y vendedores asignados

### 4. **Marketing** (`CAMPANAS_MARKETING`)
- **Descripción**: Campañas de marketing y sus resultados
- **Atributos clave**:
  - Canales de marketing y presupuestos
  - Métricas de leads y conversiones
  - ROI calculado

### 5. **Soporte** (`TICKETS_SOPORTE`)
- **Descripción**: Sistema de atención al cliente y feedback
- **Atributos clave**:
  - Tipos de problemas y prioridades
  - Análisis de sentimiento
  - Tiempos de resolución y satisfacción

---

## DIMENSIONES PRINCIPALES

### 📅 **Dimensión Temporal**
- **Período**: Año, Trimestre, Mes, Semana, Día
- **Granularidad**: Desde diario hasta anual
- **Casos de uso**: Análisis de tendencias, comparaciones período sobre período

### 🌍 **Dimensión Geográfica** 
- **Regiones**: Norte América, Europa, Asia-Pacífico
- **Nivel de detalle**: Regional (extensible a país/ciudad)
- **Casos de uso**: Análisis de mercados, expansión geográfica

### 👥 **Dimensión Cliente**
- **Segmentación**: Enterprise, Mid-Market, SMB, Education, Government
- **Industria**: Manufactura, Servicios Financieros, Salud, Retail, etc.
- **Tamaño**: Grande, Mediana, Pequeña
- **Casos de uso**: Análisis de segmentos, targeting, personalización

### 📦 **Dimensión Producto**
- **Categorías**: Software, Servicios, Seguridad, IA/ML, Herramientas
- **Estado**: Activo, Beta, Descontinuado
- **Casos de uso**: Análisis de portfolio, rendimiento por categoría

### 🛒 **Dimensión Canal de Venta**
- **Canales**: Venta Directa, Partner, Online
- **Casos de uso**: Optimización de canales, análisis de efectividad

---

## MEDIDAS CLAVE (KPIs)

### 💰 **Medidas Financieras**
1. **Ingresos Totales** 
   - *Fórmula*: `SUM(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100))`
   - *Filtros*: Solo transacciones COMPLETADAS

2. **Margen Bruto**
   - *Fórmula*: `SUM(Ingresos - (CANTIDAD * COSTO_UNITARIO))`
   - *Uso*: Análisis de rentabilidad por producto/cliente

3. **Margen Bruto %**
   - *Fórmula*: `(Margen Bruto / Ingresos Totales) * 100`
   - *Benchmark*: Meta empresarial 35-45%

4. **Ticket Promedio**
   - *Fórmula*: `AVG(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100))`
   - *Uso*: Análisis de poder adquisitivo por segmento

### 📊 **Medidas Operacionales**
5. **Número de Transacciones**
   - *Fórmula*: `COUNT(TRANSACCION_ID)`
   - *Filtros*: Estado COMPLETADO

6. **Clientes Nuevos**
   - *Fórmula*: `COUNT(DISTINCT CLIENTE_ID) WHERE FECHA_REGISTRO IN PERIOD`
   - *Uso*: Métricas de crecimiento

7. **Clientes Únicos Activos**
   - *Fórmula*: `COUNT(DISTINCT CLIENTE_ID) FROM TRANSACCIONES`
   - *Uso*: Base de clientes activa

8. **Tasa de Conversión de Campañas**
   - *Fórmula*: `(CONVERSIONES / LEADS_GENERADOS) * 100`
   - *Benchmark*: Meta 8-12%

### 🎯 **Medidas de Satisfacción**
9. **Satisfacción Promedio del Cliente**
   - *Fórmula*: `AVG(SATISFACCION_CLIENTE) FROM TICKETS_SOPORTE`
   - *Escala*: 1-5 (Meta: >4.0)

10. **Tiempo Promedio de Resolución**
    - *Fórmula*: `AVG(TIEMPO_RESOLUCION_HORAS)`
    - *Meta*: <24 horas para prioridad ALTA

11. **Tickets por Sentimiento**
    - *Fórmula*: `COUNT(*) GROUP BY SENTIMIENTO`
    - *Meta*: >70% POSITIVO + NEUTRO

### 📈 **Medidas de Marketing**
12. **ROI de Marketing**
    - *Fórmula*: `AVG(ROI_CALCULADO) FROM CAMPANAS_MARKETING`
    - *Meta*: >2.5x

13. **Costo por Lead**
    - *Fórmula*: `PRESUPUESTO / LEADS_GENERADOS`
    - *Benchmark*: Varía por canal

---

## RELACIONES Y JERARQUÍAS

### **Jerarquía Temporal**
```
Año → Trimestre → Mes → Semana → Día
```

### **Jerarquía de Productos**
```
Categoría → Producto Individual → Especificaciones
```

### **Jerarquía de Clientes**
```
Segmento → Industria → Cliente Individual
```

### **Jerarquía Geográfica**
```
Global → Región → (Extensible a País → Ciudad)
```

---

## EJEMPLOS DE PREGUNTAS DE NEGOCIO

### 📊 **Análisis de Ventas**
- *"¿Cuáles fueron nuestros ingresos totales el último trimestre?"*
- *"¿Qué producto tuvo el mejor desempeño en Europa este año?"*
- *"¿Cuál es el margen bruto por categoría de producto?"*
- *"¿Cómo se comparan las ventas de este mes vs el mes anterior?"*

### 👥 **Análisis de Clientes**
- *"¿Cuántos clientes nuevos adquirimos en Q1?"*
- *"¿Cuál es el valor promedio de transacción por segmento de cliente?"*
- *"¿Qué industria genera más ingresos?"*
- *"¿Cuáles son nuestros top 5 clientes por valor?"*

### 🛒 **Análisis de Canales**
- *"¿Qué canal de venta es más efectivo para productos de software?"*
- *"¿Cuál es la diferencia en ticket promedio entre venta directa y partners?"*
- *"¿Qué porcentaje de ventas viene de cada canal?"*

### 📈 **Análisis de Marketing**
- *"¿Cuál fue el ROI de nuestras campañas digitales en Q1?"*
- *"¿Qué campaña generó más leads calificados?"*
- *"¿Cuál es el costo promedio por lead por canal?"*

### 🎯 **Análisis de Soporte**
- *"¿Cuál es nuestra satisfacción promedio del cliente este mes?"*
- *"¿Qué tipo de problemas son más frecuentes?"*
- *"¿Cuál es el tiempo promedio de resolución por prioridad?"*
- *"¿Qué productos generan más tickets de soporte?"*

---

## CONFIGURACIÓN TÉCNICA PARA CORTEX ANALYST

### **Tablas de Hechos (Fact Tables)**
- `TRANSACCIONES` - Tabla principal de hechos
- `TICKETS_SOPORTE` - Hechos de servicio al cliente
- `CAMPANAS_MARKETING` - Hechos de marketing

### **Tablas de Dimensiones (Dimension Tables)**
- `PRODUCTOS` - Dimensión de productos
- `CLIENTES` - Dimensión de clientes

### **Vistas Analíticas Precomputadas**
- `VISTA_VENTAS_RESUMEN` - Métricas agregadas por período
- `VISTA_PRODUCTOS_RENDIMIENTO` - KPIs por producto
- `VISTA_CLIENTES_ANALISIS` - Análisis de valor de clientes

### **Consideraciones de Rendimiento**
- Índices en columnas de fecha para queries temporales
- Particionado mensual en `TRANSACCIONES`
- Clustering por `REGION` y `SEGMENTO` para queries geográficas
- Materialización de vistas para cálculos complejos

---

## GOBERNANZA Y SEGURIDAD

### **Niveles de Acceso**
- **Ejecutivos**: Acceso completo a todas las métricas
- **Gerentes de Producto**: Métricas de productos específicos
- **Gerentes Regionales**: Datos filtrados por región
- **Analistas**: Acceso a datos agregados, sin información de clientes individuales

### **Políticas de Datos**
- Enmascaramiento de información sensible de clientes
- Retención de datos históricos: 5 años
- Actualización de métricas: Tiempo real para transacciones, diario para análisis

---

*Este modelo semántico está diseñado para ser intuitivo para usuarios de negocio mientras mantiene la robustez técnica necesaria para análisis empresariales complejos.*





