# Lecciones Aprendidas: Errores Comunes en Snowflake SQL

Este documento resume los errores encontrados y corregidos durante el desarrollo de la demo de AgilCredit, para evitar repetirlos en futuros proyectos.

---

## 1. 🚨 CRÍTICO: Generación de Secuencias y Overflow Numérico

### ❌ Error Común
```sql
-- NUNCA usar SEQ4() directamente para índices
WITH SECUENCIA AS (
    SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 as num 
    FROM TABLE(GENERATOR(ROWCOUNT => 1000))
)
```

**Problema:** `SEQ4()` genera números ENORMES (ej. 7232500604009141220) que causan:
- Error: `Number out of representable range`
- Overflow en operaciones aritméticas intermedias
- Fallas en conversión de tipos de datos

### ✅ Solución Correcta
```sql
-- Usar ROW_NUMBER() con ORDER BY NULL para secuencias simples
WITH NUMEROS AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY NULL)) - 1 as num 
    FROM TABLE(GENERATOR(ROWCOUNT => 1000))
)
```

**Por qué funciona:** Genera números pequeños y secuenciales (0, 1, 2, 3... N-1) que no causan overflow.

---

## 2. 🔢 Operador Módulo: Usar MOD() en lugar de %

### ❌ Error Común
```sql
-- El operador % puede causar overflow en cálculos intermedios
SELECT 
    num % 26,
    (num * 7) % 30,
    num % PLAZO_MESES
FROM tabla;
```

**Problema:** El operador `%` en Snowflake puede generar números intermedios enormes antes de aplicar el módulo, causando overflow.

### ✅ Solución Correcta
```sql
-- SIEMPRE usar la función MOD()
SELECT 
    MOD(num, 26),
    MOD(num + 7, 30),  -- Evitar multiplicaciones: num*7 → num+7
    MOD(num, PLAZO_MESES)
FROM tabla;
```

**Reglas:**
- ✅ `MOD(num, X)` - Correcto
- ❌ `num % X` - Evitar
- ❌ `MOD(num * X, Y)` - Puede causar overflow si num es grande
- ✅ `MOD(num + X, Y)` - Usar sumas en lugar de multiplicaciones cuando sea posible

---

## 3. 🎲 Generación de Números Aleatorios

### ❌ Error Común
```sql
-- Sintaxis inconsistente y propensa a errores
SELECT 
    RANDOM() * 100,
    FLOOR(RANDOM() * 60)
FROM tabla;
```

**Problema:** `RANDOM()` solo genera valores entre 0 y 1, multiplicar puede no dar la precisión esperada.

### ✅ Solución Correcta
```sql
-- Usar UNIFORM() para rangos específicos
SELECT 
    UNIFORM(0.0::FLOAT, 100.0::FLOAT, RANDOM()),
    FLOOR(UNIFORM(0, 60, RANDOM()))
FROM tabla;
```

**Por qué es mejor:**
- Más explícito y legible
- Mejor control sobre tipos de datos (FLOAT vs INTEGER)
- Menos conversiones implícitas

---

## 4. 🗂️ Nombres de Tablas con Múltiples Schemas

### ❌ Error Común
```sql
-- Asumir que USE SCHEMA aplica a todo
USE SCHEMA CORE;

INSERT INTO EVENTOS_CUMPLIMIENTO ...  -- ❌ Error: tabla no existe
INSERT INTO RENTABILIDAD_CLIENTES ... -- ❌ Error: tabla no existe
```

**Problema:** Si las tablas están en diferentes schemas (CORE, COMPLIANCE, ANALYTICS), el `USE SCHEMA` solo afecta a tablas sin prefijo.

### ✅ Solución Correcta
```sql
-- SIEMPRE usar nombres completos con prefijo de schema
INSERT INTO CORE.CLIENTES ...
INSERT INTO COMPLIANCE.EVENTOS_CUMPLIMIENTO ...
INSERT INTO ANALYTICS.RENTABILIDAD_CLIENTES ...

-- También en SELECTs y JOINs
FROM CORE.CLIENTES c
JOIN CORE.CREDITOS cr ON c.CLIENTE_ID = cr.CLIENTE_ID
```

**Regla de oro:** Cuando trabajas con múltiples schemas, **siempre** usa `SCHEMA.TABLA` en:
- INSERT INTO
- SELECT FROM
- JOIN
- CREATE VIEW
- Queries de diagnóstico

---

## 5. 🔍 Sintaxis SQL: Diferencias PostgreSQL vs Snowflake

### ❌ Error Común (Sintaxis PostgreSQL)
```sql
-- FILTER (WHERE ...) no existe en Snowflake
SELECT 
    SUM(monto) FILTER (WHERE tipo = 'PAGO')
FROM transacciones;
```

**Problema:** La cláusula `FILTER` es específica de PostgreSQL y no está soportada en Snowflake.

### ✅ Solución Correcta (Sintaxis Snowflake)
```sql
-- Usar CASE WHEN dentro de funciones agregadas
SELECT 
    SUM(CASE WHEN tipo = 'PAGO' THEN monto ELSE 0 END)
FROM transacciones;
```

---

## 6. 📊 Coherencia en Datos Sintéticos

### ❌ Error de Lógica de Negocio
```sql
-- Clientes con scores bajos que no califican para ningún producto
SCORE_RIESGO = 50 + MOD(num, 50) -- Rango: 50-100
-- vs
PRODUCTOS.SCORE_MINIMO_REQUERIDO = 580-650

-- Resultado: 0 solicitudes aprobadas → 0 créditos → 0 transacciones
```

**Problema:** Los datos sintéticos deben ser **coherentes** con la lógica de negocio.

### ✅ Solución Correcta
```sql
-- Asegurar que los rangos de datos sean compatibles
SCORE_RIESGO = 550 + MOD(num, 300) + UNIFORM(-20::FLOAT, 20::FLOAT, RANDOM())
-- Rango: 530-870 (cubre los requisitos de 580-650)

-- Resultado: ~70% de solicitudes aprobadas ✓
```

**Lecciones:**
1. **Verifica rangos:** Asegúrate que los datos generados sean realistas y compatibles
2. **Usa queries de diagnóstico:** Siempre verifica los datos generados con queries de validación
3. **Piensa en cascada:** Clientes → Solicitudes → Créditos → Transacciones (cada nivel depende del anterior)

---

## 7. 🔄 Ambigüedad en Columnas con CROSS JOIN

### ❌ Error Común
```sql
WITH SOLICITUDES_APROBADAS AS (
    SELECT 
        s.*,
        c.CLIENTE_ID,  -- ❌ Duplicado: s.* ya incluye CLIENTE_ID
        ROW_NUMBER() OVER (...) as rn
    FROM SOLICITUDES s
    JOIN CLIENTES c ON s.CLIENTE_ID = c.CLIENTE_ID
)
```

**Problema:** `s.*` ya incluye todas las columnas de SOLICITUDES (incluyendo `CLIENTE_ID`), crear otra con el mismo nombre causa ambigüedad.

### ✅ Solución Correcta
```sql
WITH SOLICITUDES_APROBADAS AS (
    SELECT 
        s.*,
        ROW_NUMBER() OVER (...) as rn
    FROM SOLICITUDES s
    WHERE s.ESTATUS_SOLICITUD = 'APROBADA'
)
```

**Regla:** Si usas `SELECT *`, NO agregues columnas individuales a menos que tengas un alias diferente.

---

## 8. 🧪 Estrategia de Debugging

### Proceso Efectivo para Resolver Errores

1. **Lee el mensaje de error completo:**
   - `Number out of representable range` → Problema de overflow numérico
   - `Table does not exist` → Problema de schema/naming
   - `ambiguous column name` → Problema de alias duplicados

2. **Identifica el patrón:**
   - Si el error se repite en múltiples secciones → Es un problema sistemático
   - Aplica el fix a TODAS las secciones afectadas

3. **Usa queries de diagnóstico:**
   ```sql
   -- Verificar conteos
   SELECT COUNT(*) FROM tabla;
   
   -- Verificar rangos de valores
   SELECT MIN(columna), MAX(columna), AVG(columna) FROM tabla;
   
   -- Verificar distribución
   SELECT columna, COUNT(*) FROM tabla GROUP BY columna;
   ```

4. **Prueba incremental:**
   - No ejecutes todo el script de una vez
   - Ejecuta sección por sección
   - Verifica los datos después de cada INSERT

---

## 📝 Checklist Pre-Ejecución para Demos

Antes de ejecutar un script SQL de demo en Snowflake:

- [ ] ¿Usas `ROW_NUMBER() OVER (ORDER BY NULL)` en lugar de `SEQ4()` para secuencias?
- [ ] ¿Reemplazaste TODOS los `%` por `MOD()`?
- [ ] ¿Usas `UNIFORM()` en lugar de `RANDOM() * N`?
- [ ] ¿Todas las tablas tienen prefijo de schema cuando usas múltiples schemas?
- [ ] ¿Evitaste sintaxis de PostgreSQL (`FILTER`, `ARRAY_GET`, etc.)?
- [ ] ¿Los rangos de datos sintéticos son coherentes con la lógica de negocio?
- [ ] ¿Tienes queries de diagnóstico para verificar los datos generados?
- [ ] ¿Evitaste ambigüedad en nombres de columnas (especialmente con `SELECT *`)?

---

## 🎯 Reglas de Oro para Snowflake SQL

1. **Secuencias:** `ROW_NUMBER() OVER (ORDER BY NULL)` - NO `SEQ4()`
2. **Módulo:** `MOD(x, y)` - NO `x % y`
3. **Random:** `UNIFORM(min, max, RANDOM())` - NO `RANDOM() * max`
4. **Schemas:** `SCHEMA.TABLA` - NO asumir `USE SCHEMA`
5. **Agregados con filtro:** `SUM(CASE WHEN ... THEN x ELSE 0 END)` - NO `SUM(x) FILTER (WHERE ...)`
6. **Arrays:** `GET(array, index)` - NO `ARRAY_GET(array, index)`
7. **Coherencia de datos:** Verifica que los rangos y relaciones tengan sentido de negocio
8. **Testing:** Queries de diagnóstico SIEMPRE

---

## 🔗 Referencias Útiles

- [Snowflake SQL Reference](https://docs.snowflake.com/en/sql-reference)
- [Snowflake vs PostgreSQL: Key Differences](https://docs.snowflake.com/en/sql-reference/sql-differences)
- [Data Generation with GENERATOR](https://docs.snowflake.com/en/sql-reference/functions/generator)
- [MOD Function](https://docs.snowflake.com/en/sql-reference/functions/mod)
- [UNIFORM Function](https://docs.snowflake.com/en/sql-reference/functions/uniform)

---

**Fecha de creación:** 2025-10-21  
**Proyecto:** AgilCredit Demo - Financial Services  
**Contexto:** Generación de datos sintéticos para demo de Snowflake




