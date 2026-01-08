# ⚡ Snowflake SQL Cheat Sheet - Errores Comunes

Referencia rápida de los errores más comunes en Snowflake SQL y sus soluciones.

---

## 🚨 Error: "Number out of representable range"

### ❌ Causa
```sql
-- Usar SEQ4() genera números ENORMES
SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 as num
FROM TABLE(GENERATOR(ROWCOUNT => 1000))

-- Resultado: 7232500604009141220 → OVERFLOW!
```

### ✅ Solución
```sql
-- Usar ORDER BY NULL para secuencias simples
SELECT (ROW_NUMBER() OVER (ORDER BY NULL)) - 1 as num
FROM TABLE(GENERATOR(ROWCOUNT => 1000))

-- Resultado: 0, 1, 2, 3... 999 ✓
```

---

## 🔢 Operador Módulo

### ❌ Evitar
```sql
num % 26              -- Puede causar overflow
(num * 7) % 30        -- Multiplicación antes de módulo = OVERFLOW
```

### ✅ Usar
```sql
MOD(num, 26)          -- Seguro
MOD(num + 7, 30)      -- Suma en lugar de multiplicación
```

---

## 🎲 Números Aleatorios

### ❌ Evitar
```sql
RANDOM() * 100        -- Impreciso
FLOOR(RANDOM() * 60)  -- Conversión implícita
```

### ✅ Usar
```sql
UNIFORM(0.0::FLOAT, 100.0::FLOAT, RANDOM())  -- Explícito y preciso
FLOOR(UNIFORM(0, 60, RANDOM()))              -- Rango de enteros
```

---

## 🗂️ Múltiples Schemas

### ❌ Error
```sql
USE SCHEMA CORE;
INSERT INTO EVENTOS_CUMPLIMIENTO ...  -- ❌ Tabla no encontrada
```

### ✅ Solución
```sql
-- SIEMPRE usar prefijo completo
INSERT INTO COMPLIANCE.EVENTOS_CUMPLIMIENTO ...
FROM CORE.CLIENTES
JOIN CORE.CREDITOS ON ...
```

---

## 🔍 Agregados con Filtro

### ❌ PostgreSQL (no funciona)
```sql
SUM(monto) FILTER (WHERE tipo = 'PAGO')
```

### ✅ Snowflake
```sql
SUM(CASE WHEN tipo = 'PAGO' THEN monto ELSE 0 END)
```

---

## 📊 Funciones de Array

### ❌ Evitar
```sql
ARRAY_GET(mi_array, 0)  -- No existe en Snowflake
```

### ✅ Usar
```sql
GET(mi_array, 0)        -- Función correcta
mi_array[0]             -- Sintaxis de bracket también funciona
```

---

## 🔑 Reglas de Oro

1. **Secuencias:** `ROW_NUMBER() OVER (ORDER BY NULL)` ✅
2. **Módulo:** `MOD(x, y)` ✅
3. **Random:** `UNIFORM(min, max, RANDOM())` ✅
4. **Schemas:** `SCHEMA.TABLA` siempre ✅
5. **Filtros:** `CASE WHEN ... THEN ... ELSE 0 END` ✅
6. **Arrays:** `GET(array, index)` ✅

---

## 🧪 Queries de Diagnóstico

```sql
-- Verificar conteos
SELECT COUNT(*) FROM schema.tabla;

-- Verificar rangos
SELECT MIN(col), MAX(col), AVG(col) FROM schema.tabla;

-- Verificar distribución
SELECT columna, COUNT(*) 
FROM schema.tabla 
GROUP BY columna;
```

---

## ⚙️ Checklist Rápido

Antes de ejecutar, verifica:

- [ ] ¿Usas `ROW_NUMBER() OVER (ORDER BY NULL)`?
- [ ] ¿Usas `MOD()` en lugar de `%`?
- [ ] ¿Usas `UNIFORM()` para aleatorios?
- [ ] ¿Todas las tablas tienen `SCHEMA.TABLA`?
- [ ] ¿Evitaste sintaxis de PostgreSQL?

---

**Documento completo:** [LECCIONES_APRENDIDAS_SNOWFLAKE.md](./LECCIONES_APRENDIDAS_SNOWFLAKE.md)




