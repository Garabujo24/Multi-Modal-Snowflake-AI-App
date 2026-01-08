# REGLAS PARA MODELOS SEMÁNTICOS DE SNOWFLAKE CORTEX ANALYST

## ESTRUCTURA DE TABLAS

### 1. Primary Key (OBLIGATORIO)
```yaml
# ❌ INCORRECTO
primary_key: COLUMNA_ID

# ✅ CORRECTO
primary_key:
  columns:
    - COLUMNA_ID
```
- **Regla:** SIEMPRE usar estructura de objeto con campo `columns` que contenga un array
- **Razón:** El parser espera un objeto tipo `PrimaryKey` con campo `columns`, no un string directo

### 2. Columnas Unique
```yaml
dimensions:
  - name: ID_COLUMNA
    unique: true  # Para Primary Keys y columnas únicas
```
- **Regla:** Marcar SIEMPRE la columna PK con `unique: true` además de definir `primary_key` a nivel tabla

---

## RELACIONES (RELATIONSHIPS)

### 3. Nomenclatura camelCase
```yaml
# ❌ INCORRECTO
relationships:
  - name: MI_RELACION
    relationship_type: many_to_one
    left_table:
      name: TABLA_A
    right_table:
      name: TABLA_B

# ✅ CORRECTO
relationships:
  - name: MI_RELACION
    relationshipType: many_to_one
    leftTable: TABLA_A
    rightTable: TABLA_B
    relationshipColumns:
      - leftColumn: COLUMNA_FK
        rightColumn: COLUMNA_PK
```

**Reglas obligatorias:**
- `relationshipType` (NO `relationship_type`)
- `leftTable` como STRING directo (NO como objeto con `name`)
- `rightTable` como STRING directo (NO como objeto con `name`)
- `relationshipColumns` (NO `left_join_columns` ni `right_join_columns`)
- Cada elemento en `relationshipColumns` debe tener `leftColumn` y `rightColumn`

### 4. Foreign Keys explícitas
```yaml
# En la tabla con FK, agregar la columna FK como dimensión
dimensions:
  - name: DESARROLLO_ID
    synonyms:
      - id de desarrollo
    description: Identificador del desarrollo al que pertenece
    data_type: NUMBER
    expr: DESARROLLO_ID
```
- **Regla:** SIEMPRE agregar las columnas FK como dimensiones en las tablas hijas

---

## VERIFIED QUERIES (CONSULTAS VERIFICADAS)

### 5. Usar nombres lógicos de tablas
```yaml
# ❌ INCORRECTO - Tablas físicas
verified_queries:
  - name: Mi Consulta
    question: ¿Pregunta?
    sql: >
      SELECT columna 
      FROM MIDB.MISCHEMA.MITABLA
      WHERE condicion = 'valor'

# ✅ CORRECTO - Tablas lógicas
verified_queries:
  - name: Mi Consulta
    question: ¿Pregunta?
    sql: >
      SELECT columna 
      FROM __mitabla AS t
      WHERE condicion = 'valor'
```

**Reglas obligatorias:**
- Usar prefijo `__` antes del nombre lógico de tabla (minúsculas)
- NO incluir database.schema en las referencias
- Columnas en minúsculas
- Alias en minúsculas
- NO usar campos `verified_at` ni `verified_by` (causan errores de parseo)

### 6. Formato de consultas verificadas
```yaml
verified_queries:
  - name: Nombre de la consulta
    question: ¿Pregunta en lenguaje natural?
    sql: >
      SELECT 
        t1.columna_1,
        COUNT(t2.columna_2) AS alias_resultado
      FROM __tabla1 AS t1
      INNER JOIN __tabla2 AS t2
        ON t1.id = t2.fk_id
      WHERE t1.condicion = 'valor'
      GROUP BY t1.columna_1
      ORDER BY alias_resultado DESC
```
- **Regla:** Solo incluir 3-5 consultas ultra-simples
- **Regla:** Evitar agregaciones complejas

---

## SINÓNIMOS

### 7. Evitar sinónimos duplicados
```yaml
# ❌ INCORRECTO - "identificador de unidad" repetido
dimensions:
  - name: PROPIEDAD_ID
    synonyms:
      - id de propiedad
      - identificador de unidad  # ❌ Duplicado
  
  - name: NUMERO_UNIDAD
    synonyms:
      - número de unidad
      - identificador de unidad  # ❌ Duplicado

# ✅ CORRECTO
dimensions:
  - name: PROPIEDAD_ID
    synonyms:
      - id de propiedad
      - código de propiedad  # ✅ Único
  
  - name: NUMERO_UNIDAD
    synonyms:
      - número de unidad
      - identificador de unidad  # ✅ Único
```
- **Regla:** Verificar que NO haya sinónimos duplicados en la misma tabla
- **Regla:** Usar sinónimos específicos para cada columna

---

## DIMENSIONES Y MEDIDAS

### 8. Solo dimensions y time_dimensions
```yaml
# ✅ CORRECTO - Siguiendo regla 18 del proyecto
tables:
  - name: MI_TABLA
    dimensions:
      - name: COLUMNA_TEXTO
        data_type: TEXT
        expr: COLUMNA_TEXTO
      
      - name: COLUMNA_NUMERO
        data_type: NUMBER
        expr: COLUMNA_NUMERO
    
    time_dimensions:
      - name: COLUMNA_FECHA
        data_type: DATE
        expr: COLUMNA_FECHA
```
- **Regla:** NUNCA usar `kind: measure` (sin excepciones)
- **Regla:** Solo usar `dimensions` y `time_dimensions`

---

## CHECKLIST RÁPIDO ANTES DE VALIDAR

✅ Todas las tablas tienen `primary_key` con estructura `columns: [...]`  
✅ Todas las PKs tienen `unique: true` en dimensions  
✅ Todas las FKs están definidas como dimensions en tablas hijas  
✅ Relationships usan `relationshipType`, `leftTable`, `rightTable`, `relationshipColumns`  
✅ RelationshipColumns usan `leftColumn` y `rightColumn`  
✅ Verified queries usan `__tablename` (minúsculas) NO tablas físicas  
✅ Verified queries NO tienen campos `verified_at` ni `verified_by`  
✅ Columnas y aliases en queries están en minúsculas  
✅ NO hay sinónimos duplicados en la misma tabla  
✅ Solo se usan `dimensions` y `time_dimensions` (NO measures)  

---

## ERRORES COMUNES Y SOLUCIONES

| Error | Causa | Solución |
|-------|-------|----------|
| `expected string or bytes-like object` | `left_table` como objeto | Usar string directo: `leftTable: NOMBRE` |
| `has no field named "left_join_columns"` | Campo inexistente | Usar `relationshipColumns` con `leftColumn`/`rightColumn` |
| `invalid literal for int()` en verified_at | Campo no soportado | Eliminar `verified_at` y `verified_by` |
| `has no field named "0"` en primary_key | PK como string | Usar objeto: `primary_key:\n  columns:\n    - ID` |
| `has no primary key` | Falta definir PK | Agregar `primary_key` con estructura correcta |
| `referred to physical tables` | Usar tablas físicas | Usar `__tablename` en minúsculas |
| `synonyms are duplicated` | Sinónimos repetidos | Usar sinónimos únicos por columna |

---

## PLANTILLA BÁSICA

```yaml
name: NOMBRE_MODELO
description: Descripción del modelo

tables:
  - name: TABLA_PRINCIPAL
    description: Descripción de la tabla
    base_table:
      database: MIDB
      schema: MISCHEMA
      table: TABLA_PRINCIPAL
    primary_key:
      columns:
        - ID_COLUMNA
    dimensions:
      - name: ID_COLUMNA
        synonyms:
          - identificador
        description: ID único
        data_type: NUMBER
        expr: ID_COLUMNA
        unique: true
      
      - name: COLUMNA_FK
        synonyms:
          - fk
        description: Foreign key
        data_type: NUMBER
        expr: COLUMNA_FK
    
    time_dimensions:
      - name: FECHA
        synonyms:
          - fecha
        description: Fecha
        data_type: DATE
        expr: FECHA

relationships:
  - name: RELACION_NOMBRE
    relationshipType: many_to_one
    leftTable: TABLA_HIJA
    rightTable: TABLA_PADRE
    relationshipColumns:
      - leftColumn: COLUMNA_FK
        rightColumn: ID_COLUMNA

verified_queries:
  - name: Consulta simple
    question: ¿Pregunta?
    sql: >
      SELECT 
        t.columna,
        COUNT(*) AS total
      FROM __tabla AS t
      GROUP BY t.columna
      ORDER BY total DESC
```



