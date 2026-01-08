# Reglas de Usuario para Cursor - Snowflake SQL

Copia y pega estas reglas en tu configuración de Cursor (Settings > Cursor Settings > Rules for AI).

---

```
## Reglas para Desarrollo con Snowflake SQL

### 1. Generación de Secuencias y Datos Sintéticos

NUNCA uses `SEQ4()` directamente para generar índices o secuencias porque genera números enormes que causan overflow.

SIEMPRE usa esta sintaxis:
```sql
WITH NUMEROS AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY NULL)) - 1 as num 
    FROM TABLE(GENERATOR(ROWCOUNT => N))
)
```

**Razón:** `SEQ4()` genera valores como 7232500604009141220, mientras que `ROW_NUMBER()` genera 0, 1, 2, 3... N-1.

---

### 2. Operador Módulo

NUNCA uses el operador `%` para operaciones de módulo en Snowflake.

SIEMPRE usa la función `MOD()`:
- ✅ Correcto: `MOD(num, 26)`
- ❌ Evitar: `num % 26`
- ❌ Evitar: `MOD(num * 7, 30)` (la multiplicación puede causar overflow)
- ✅ Correcto: `MOD(num + 7, 30)` (usa suma en lugar de multiplicación)

**Razón:** El operador `%` puede causar overflow en cálculos intermedios antes de aplicar el módulo.

---

### 3. Números Aleatorios

NUNCA uses `RANDOM() * N` para generar números aleatorios en rangos.

SIEMPRE usa `UNIFORM()`:
- ✅ Correcto: `UNIFORM(0.0::FLOAT, 100.0::FLOAT, RANDOM())`
- ✅ Correcto: `FLOOR(UNIFORM(0, 60, RANDOM()))`
- ❌ Evitar: `RANDOM() * 100`
- ❌ Evitar: `FLOOR(RANDOM() * 60)`

**Razón:** `UNIFORM()` es más explícito, preciso y maneja mejor los tipos de datos.

---

### 4. Referencias a Tablas con Múltiples Schemas

Cuando un proyecto usa múltiples schemas (ej. CORE, COMPLIANCE, ANALYTICS):

SIEMPRE usa nombres completos con prefijo de schema en:
- INSERT INTO statements: `INSERT INTO SCHEMA.TABLA`
- SELECT statements: `FROM SCHEMA.TABLA`
- JOINs: `JOIN SCHEMA.TABLA ON ...`
- CREATE VIEW: `CREATE VIEW SCHEMA.VISTA AS ...`

NUNCA asumas que `USE SCHEMA X;` aplicará a todas las tablas del script.

**Ejemplo:**
```sql
USE SCHEMA CORE;

-- ❌ MAL: Falla si la tabla está en otro schema
INSERT INTO EVENTOS_CUMPLIMIENTO ...

-- ✅ BIEN: Explícito y claro
INSERT INTO COMPLIANCE.EVENTOS_CUMPLIMIENTO ...
FROM CORE.CLIENTES c
JOIN CORE.CREDITOS cr ON c.CLIENTE_ID = cr.CLIENTE_ID
```

---

### 5. Diferencias Sintácticas PostgreSQL vs Snowflake

Snowflake NO soporta las siguientes sintaxis de PostgreSQL:

**FILTER (WHERE ...):**
- ❌ PostgreSQL: `SUM(monto) FILTER (WHERE tipo = 'PAGO')`
- ✅ Snowflake: `SUM(CASE WHEN tipo = 'PAGO' THEN monto ELSE 0 END)`

**ARRAY_GET:**
- ❌ PostgreSQL: `ARRAY_GET(mi_array, 0)`
- ✅ Snowflake: `GET(mi_array, 0)` o `mi_array[0]`

**DISTINCT en agregados con GROUP BY:**
- ❌ Redundante: `SELECT DISTINCT col, COUNT(*) FROM tabla GROUP BY col`
- ✅ Correcto: `SELECT col, COUNT(*) FROM tabla GROUP BY col`

---

### 6. Coherencia de Datos en Demos Sintéticas

SIEMPRE verifica que los rangos de datos sintéticos sean coherentes con la lógica de negocio:

**Ejemplo de error común:**
```sql
-- ❌ MAL: Clientes con scores que nunca califican
SCORE_RIESGO = 50 + MOD(num, 50)  -- Rango: 50-100
-- vs
PRODUCTOS.SCORE_MINIMO_REQUERIDO = 580-650
-- Resultado: 0 solicitudes aprobadas → demo sin datos

-- ✅ BIEN: Alinear rangos con requisitos
SCORE_RIESGO = 550 + MOD(num, 300) + UNIFORM(-20::FLOAT, 20::FLOAT, RANDOM())
-- Rango: 530-870 (cubre requisitos de 580-650)
```

SIEMPRE piensa en la cascada de dependencias:
1. Clientes → deben tener scores válidos
2. Solicitudes → deben poder ser aprobadas
3. Créditos → deben existir solicitudes aprobadas
4. Transacciones → deben existir créditos activos

---

### 7. Ambigüedad en Nombres de Columnas

NUNCA combines `SELECT *` con columnas individuales del mismo origen:

```sql
-- ❌ MAL: CLIENTE_ID aparece dos veces
SELECT 
    s.*,              -- Ya incluye CLIENTE_ID
    c.CLIENTE_ID,     -- Duplicado → error de ambigüedad
    ROW_NUMBER() OVER (...) as rn
FROM SOLICITUDES s
JOIN CLIENTES c ON s.CLIENTE_ID = c.CLIENTE_ID

-- ✅ BIEN: Solo s.* o columnas específicas con alias
SELECT 
    s.*,
    ROW_NUMBER() OVER (...) as rn
FROM SOLICITUDES s
WHERE s.ESTATUS_SOLICITUD = 'APROBADA'
```

---

### 8. Queries de Diagnóstico Obligatorias

Para TODA demo o script de generación de datos, SIEMPRE incluye una sección final con queries de diagnóstico:

```sql
-- Verificar conteos
SELECT 'TABLA_X' as TABLA, COUNT(*) as REGISTROS FROM SCHEMA.TABLA_X
UNION ALL
SELECT 'TABLA_Y', COUNT(*) FROM SCHEMA.TABLA_Y;

-- Verificar rangos de valores críticos
SELECT 
    MIN(columna_critica) as MIN_VAL,
    MAX(columna_critica) as MAX_VAL,
    ROUND(AVG(columna_critica), 2) as AVG_VAL
FROM SCHEMA.TABLA;

-- Verificar distribución de categorías
SELECT 
    categoria,
    COUNT(*) as CANTIDAD,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as PORCENTAJE
FROM SCHEMA.TABLA
GROUP BY categoria
ORDER BY CANTIDAD DESC;
```

---

### 9. Errores Comunes a Prevenir

Antes de ejecutar cualquier script SQL en Snowflake, verifica:

1. ✅ ¿Usas `ROW_NUMBER() OVER (ORDER BY NULL)` en lugar de `SEQ4()`?
2. ✅ ¿Todos los `%` están reemplazados por `MOD()`?
3. ✅ ¿Usas `UNIFORM()` en lugar de `RANDOM() * N`?
4. ✅ ¿Todas las referencias a tablas incluyen el prefijo `SCHEMA.TABLA`?
5. ✅ ¿Evitaste sintaxis de PostgreSQL (`FILTER`, `ARRAY_GET`)?
6. ✅ ¿Los rangos de datos sintéticos son coherentes con la lógica de negocio?
7. ✅ ¿Incluiste queries de diagnóstico al final del script?
8. ✅ ¿Evitaste ambigüedad en nombres de columnas con `SELECT *`?

---

### 10. Modelos Semánticos de Snowflake (Cortex Analyst)

Para crear semantic models en YAML para Snowflake Cortex Analyst:

**NUNCA definas columnas tipo `measure` con agregaciones:**
```yaml
# ❌ MAL: Causa errores de GROUP BY validation
- name: MONTO_CREDITO
  kind: measure
  expr: "SUM(MONTO_CREDITO)"

# ✅ BIEN: Solo dimensions simples
- name: MONTO_CREDITO
  kind: dimension
  expr: MONTO_CREDITO
```

**NUNCA uses relaciones `one_to_many`:**
```yaml
# ❌ MAL: No soportado
relationships:
  - name: clientes_to_creditos
    leftTable: clientes
    rightTable: creditos
    relationshipType: one_to_many

# ✅ BIEN: Invertir a many_to_one
relationships:
  - name: creditos_to_clientes
    leftTable: creditos
    rightTable: clientes
    relationshipType: many_to_one
```

**NUNCA uses campos no soportados:**
```yaml
# ❌ MAL: orchestrationInstructions no existe
orchestrationInstructions: |
  ...

# ✅ BIEN: Solo customInstructions
customInstructions: |
  ...
```

**SIMPLIFICA las verified queries al máximo:**
```sql
-- ❌ MAL: CASE WHEN con columnas de estado
SUM(CASE WHEN ESTATUS_CREDITO IN ('MORA', 'VENCIDO') THEN SALDO ELSE 0 END)

-- ✅ BIEN: Queries simples sin lógica condicional compleja
SELECT COUNT(*) as total
FROM __creditos

-- ✅ BIEN: ORDER BY y LIMIT sin GROUP BY
SELECT CLIENTE_ID, UTILIDAD_NETA
FROM __rentabilidad_clientes
ORDER BY UTILIDAD_NETA DESC
LIMIT 10
```

**Estructura YAML requerida:**
- Todas las columnas necesitan `expr: NOMBRE_COLUMNA`
- Relaciones usan `left_column` y `right_column` (NO `left` y `right`)
- Solo soporta: `many_to_one` y `one_to_one` (NO `one_to_many`)
- Campos válidos: `name`, `description`, `tables`, `relationships`, `verifiedQueries`, `customInstructions`

**Estrategia si hay errores de validación SQL:**
1. Eliminar TODAS las columnas `kind: measure`
2. Convertir todo a `kind: dimension` con `expr: COLUMNA` simple
3. Simplificar verified queries (máximo 3-5 queries ultra-básicas)
4. Eliminar CASE WHEN, subconsultas, filtros complejos
5. Solo usar: SELECT, FROM, JOIN simple, ORDER BY, LIMIT

---

### 11. Manejo de Errores Comunes

**Error: "Number out of representable range"**
→ Causa: Usar `SEQ4()` o `%` con números grandes
→ Solución: Usar `ROW_NUMBER() OVER (ORDER BY NULL)` y `MOD()`

**Error: "Table does not exist or not authorized"**
→ Causa: Falta prefijo de schema cuando la tabla está en otro schema
→ Solución: Usar `SCHEMA.TABLA` explícitamente

**Error: "ambiguous column name"**
→ Causa: Columna duplicada en SELECT (común con `SELECT *`)
→ Solución: Eliminar columnas redundantes o usar alias distintos

**Error: "syntax error unexpected 'FILTER'"**
→ Causa: Sintaxis de PostgreSQL no soportada
→ Solución: Reemplazar con `CASE WHEN ... THEN ... ELSE 0 END`

**Error: "[COLUMNA] is not a valid group by expression" (Semantic Model)**
→ Causa: Definiciones `kind: measure` con agregaciones o queries complejas
→ Solución: Cambiar TODAS las measures a dimensions simples

**Error: "unsupported relationship type" (Semantic Model)**
→ Causa: Usar `one_to_many` en relationships
→ Solución: Invertir relación a `many_to_one`

**Error: "has no field named 'orchestration_instructions'" (Semantic Model)**
→ Causa: Campo no válido en el YAML
→ Solución: Solo usar campos soportados (`customInstructions`, `name`, `tables`, etc.)

---

### Resumen de Reglas de Oro

Para desarrollo en Snowflake SQL, memoriza estas 10 reglas:

1. **Secuencias:** `ROW_NUMBER() OVER (ORDER BY NULL)` - NO `SEQ4()`
2. **Módulo:** `MOD(x, y)` - NO `x % y`
3. **Random:** `UNIFORM(min, max, RANDOM())` - NO `RANDOM() * max`
4. **Schemas:** `SCHEMA.TABLA` - NO asumir `USE SCHEMA`
5. **Filtros:** `SUM(CASE WHEN ... THEN x END)` - NO `FILTER (WHERE ...)`
6. **Arrays:** `GET(array, idx)` - NO `ARRAY_GET()`
7. **Coherencia:** Verificar rangos y lógica de negocio
8. **Testing:** Incluir queries de diagnóstico
9. **Semantic Models:** `kind: dimension` + `expr: COLUMNA` - NO `measure` con agregaciones
10. **Relationships:** `many_to_one` - NO `one_to_many`

---

## Aplicación de Estas Reglas

Cuando generes código SQL para Snowflake:
1. Revisa estas reglas ANTES de escribir el código
2. Aplica el checklist de verificación ANTES de presentar el código
3. Si encuentras un error de "Number out of representable range" o similar, consulta estas reglas inmediatamente
4. Para demos financieras o con datos sintéticos, verifica SIEMPRE la coherencia de rangos

---

**Documentación completa:** Ver `LECCIONES_APRENDIDAS_SNOWFLAKE.md` y `SNOWFLAKE_SQL_CHEATSHEET.md` en el proyecto.
```

