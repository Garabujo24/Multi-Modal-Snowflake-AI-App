# Validación de Verified Queries - AgilCredit

## ✅ Estado de las Queries

### 1. cartera_total_y_morosidad
- **Tipo:** Query sin GROUP BY (agregaciones simples)
- **Tablas:** `__creditos`
- **Estado:** ✅ **VÁLIDA**
- **Motivo:** Solo agregaciones globales, sin GROUP BY requerido

---

### 2. top_clientes_rentables
- **Tipo:** Query con ORDER BY y LIMIT, sin GROUP BY
- **Tablas:** `__clientes`, `__rentabilidad_clientes`
- **Join:** INNER JOIN
- **Estado:** ✅ **VÁLIDA**
- **Motivo:** No usa GROUP BY, solo selecciona columnas directamente

---

### 3. alertas_fraude_activas
- **Tipo:** Query con GROUP BY
- **Tablas:** `__alertas_fraude`
- **GROUP BY:** `__alertas_fraude.NIVEL_RIESGO`
- **Estado:** ✅ **VÁLIDA**
- **Motivo:** 
  - Columna no agregada: `NIVEL_RIESGO` → está en GROUP BY ✓
  - Resto son agregaciones: `COUNT()`, `AVG()`, `SUM()` ✓

---

### 4. analisis_productos_desempeno
- **Tipo:** Query con LEFT JOIN y GROUP BY
- **Tablas:** `__productos`, `__creditos`
- **GROUP BY:** `__productos.NOMBRE_PRODUCTO, __productos.TIPO_CREDITO`
- **Estado:** ✅ **VÁLIDA** (Simplificada)
- **Motivo:**
  - Columnas no agregadas: `NOMBRE_PRODUCTO`, `TIPO_CREDITO` → están en GROUP BY ✓
  - Resto son agregaciones: `COUNT()`, `SUM()`, `AVG()` ✓
  - Filtro movido al JOIN para mantener LEFT JOIN ✓

---

### 5. cumplimiento_kyc_pendientes
- **Tipo:** Query con CTE, múltiples LEFT JOINs y GROUP BY
- **Tablas:** `__clientes`, `__eventos_cumplimiento`
- **GROUP BY:** `__clientes.SEGMENTO_CLIENTE`
- **Estado:** ✅ **VÁLIDA** (Con CTE)
- **Motivo:**
  - CTE pre-calcula `MAX(FECHA_EVENTO)` por cliente ✓
  - Columna no agregada: `SEGMENTO_CLIENTE` → está en GROUP BY ✓
  - Resto son agregaciones con `COUNT(DISTINCT CASE...)` ✓

---

### 6. tendencia_originacion_mensual
- **Tipo:** Query con GROUP BY temporal
- **Tablas:** `__creditos`
- **GROUP BY:** `DATE_TRUNC('month', __creditos.FECHA_DESEMBOLSO)`
- **Estado:** ✅ **VÁLIDA** (Simplificada)
- **Motivo:**
  - Columna temporal en SELECT también en GROUP BY ✓
  - Todas las demás son agregaciones ✓
  - Eliminado `AVG(__clientes.SCORE_RIESGO)` que causaba problemas ✓

---

### 7. concentracion_geografica_cartera
- **Tipo:** Query con LEFT JOIN y GROUP BY
- **Tablas:** `__clientes`, `__creditos`
- **GROUP BY:** `__clientes.ESTADO`
- **Estado:** ✅ **VÁLIDA** (Simplificada - sin window functions)
- **Motivo:**
  - Columna no agregada: `ESTADO` → está en GROUP BY ✓
  - Todas las demás son agregaciones básicas ✓
  - Eliminadas window functions que causaban problemas ✓
  - Filtro en el JOIN: `AND __creditos.ESTATUS_CREDITO IN (...)` ✓

---

## 🔑 Reglas Aplicadas

### Regla 1: GROUP BY
- **Todas las columnas en SELECT deben estar:**
  - En GROUP BY, **O**
  - Dentro de función de agregación (SUM, COUNT, AVG, MAX, MIN)

### Regla 2: LEFT JOIN con filtros
```sql
-- ❌ MAL: WHERE convierte LEFT JOIN en INNER JOIN
LEFT JOIN tabla ON ... WHERE tabla.columna = valor

-- ✅ BIEN: Filtro en la condición del JOIN
LEFT JOIN tabla ON ... AND tabla.columna = valor
```

### Regla 3: Window Functions con GROUP BY
- **Evitar cuando sea posible** en queries complejas
- Si es necesario, usar CTEs o subconsultas

### Regla 4: Agregaciones de tablas joinadas
- **Evitar** `AVG(tabla_joinada.columna)` cuando la tabla no está en GROUP BY
- **Usar CTE** para pre-calcular agregaciones si es necesario

---

## 📊 Resumen

| Query | Complejidad | Estado | Notas |
|-------|-------------|--------|-------|
| cartera_total_y_morosidad | Baja | ✅ | Sin GROUP BY |
| top_clientes_rentables | Baja | ✅ | Sin GROUP BY |
| alertas_fraude_activas | Media | ✅ | GROUP BY simple |
| analisis_productos_desempeno | Media | ✅ | LEFT JOIN + GROUP BY |
| cumplimiento_kyc_pendientes | Alta | ✅ | CTE + múltiples JOINs |
| tendencia_originacion_mensual | Media | ✅ | GROUP BY temporal |
| concentracion_geografica_cartera | Media | ✅ | LEFT JOIN simplificado |

---

## ✅ Conclusión

**Todas las 7 verified queries han sido validadas y simplificadas** para evitar:
- Errores de GROUP BY
- Problemas con window functions
- Conflictos con LEFT JOIN + WHERE

Las queries están optimizadas para Snowflake y deberían ejecutarse sin errores.

---

**Fecha:** 2025-10-21  
**Proyecto:** AgilCredit Demo - Financial Services  
**Archivo:** agilcredit_modelo_semantico.yaml




