# 🚀 Inicio Rápido - Demo OXXO ML

## ⚡ Ejecución en 3 Pasos

### 1️⃣ **Configurar Snowflake** (5 minutos)

Abre Snowflake UI y ejecuta:

```sql
-- Abrir archivo: OXXO_ML_DEMO.sql
-- Ejecutar secciones en orden:
-- Sección 1: Configuración (30 seg)
-- Sección 2: Datos sintéticos (2 min)
-- Sección 3: Feature engineering (1 min)
```

✅ **Resultado:** Base de datos con 50,000 registros listos para ML

---

### 2️⃣ **Entrenar Modelos** (3 minutos)

**Opción A - Snowflake Notebook (Recomendado):**
1. Crear nuevo Notebook en Snowflake
2. Copiar código de `notebook_ejemplo.py`
3. Ejecutar celda por celda

**Opción B - Script Python:**
```bash
pip install -r requirements.txt
python oxxo_ml_pipeline.py
```

✅ **Resultado:** 
- Modelo de clasificación (ROC-AUC ~0.85)
- Modelo de forecasting (MAPE ~8%)
- Valor de negocio: $1M USD/año

---

### 3️⃣ **Visualizar (Opcional)** (2 minutos)

**Streamlit in Snowflake:**
1. Subir `streamlit_app.py` a Snowflake
2. Ejecutar app
3. Explorar dashboards interactivos

✅ **Resultado:** Dashboard profesional con predicciones en tiempo real

---

## 📁 Estructura de Archivos

```
OXXO_Demo/
│
├── 📘 README.md                    # Documentación completa del proyecto
├── 🚀 INICIO_RAPIDO.md             # Este archivo (guía express)
├── 🎤 GUIA_PRESENTACION.md         # Guía minuto a minuto para evento
│
├── 📊 SQL Scripts
│   ├── OXXO_ML_DEMO.sql            # Script principal (generación de datos)
│   └── VERIFICACION_DEMO.sql       # Verificar que todo funcione
│
├── 🐍 Python Scripts
│   ├── oxxo_ml_pipeline.py         # Pipeline completo de ML
│   └── notebook_ejemplo.py         # Código para Snowflake Notebook
│
├── 🎨 Aplicación
│   └── streamlit_app.py            # Dashboard interactivo
│
└── ⚙️ Configuración
    ├── requirements.txt            # Dependencias Python
    └── .gitignore                  # Archivos a ignorar en Git
```

---

## 🎯 ¿Qué hace cada archivo?

### 📊 **OXXO_ML_DEMO.sql** (ARCHIVO PRINCIPAL)
**Ejecutar primero**. Crea:
- ✅ Warehouse `OXXO_ML_WH`
- ✅ Database `OXXO_DEMO_DB` 
- ✅ 100 productos realistas de OXXO
- ✅ 500 tiendas en México
- ✅ 50,000 transacciones con:
  - Clases desbalanceadas (90/10)
  - Datos faltantes (15% temperatura, 10% promociones)
  - Features realistas (día de semana, quincena, clima)

**Tiempo:** ~5 minutos

---

### 🐍 **notebook_ejemplo.py** (RECOMENDADO PARA DEMO)
**Ejecutar en Snowflake Notebook**. Incluye:
- ✅ Carga de datos con Snowpark
- ✅ Feature engineering
- ✅ Balanceo con SMOTE (clave para clases desbalanceadas)
- ✅ Entrenamiento Random Forest
- ✅ Evaluación completa (ROC-AUC, confusion matrix)
- ✅ Feature importance
- ✅ Cálculo de valor de negocio
- ✅ Visualizaciones profesionales

**Tiempo:** ~3 minutos

---

### 🐍 **oxxo_ml_pipeline.py** (ALTERNATIVA COMPLETA)
Pipeline standalone que incluye:
- ✅ Clasificación (quiebre de stock)
- ✅ Forecasting (ventas diarias)
- ✅ Todo automatizado
- ✅ Guarda modelos en archivos .pkl

**Uso:**
```bash
python oxxo_ml_pipeline.py
```

**Tiempo:** ~5 minutos

---

### 🎨 **streamlit_app.py** (OPCIONAL - PARA WOW FACTOR)
Dashboard con:
- ✅ Métricas generales de ventas
- ✅ Predicción interactiva de quiebres
- ✅ Forecasting de ventas con gráficas
- ✅ Dashboard de FinOps

**Uso en Streamlit in Snowflake:**
1. Ir a Streamlit → Create
2. Subir archivo
3. Run

**Tiempo:** ~2 minutos (setup) + demo

---

### 🎤 **GUIA_PRESENTACION.md** (PARA EL EVENTO)
Guía **minuto a minuto** para presentar en 15 minutos:
- ✅ Script completo
- ✅ Timing exacto
- ✅ Frases potentes
- ✅ Troubleshooting
- ✅ Tips por audiencia

**Léelo antes del evento**

---

### 🔍 **VERIFICACION_DEMO.sql** (TROUBLESHOOTING)
Ejecutar DESPUÉS de `OXXO_ML_DEMO.sql` para verificar:
- ✅ Todos los objetos existen
- ✅ Datos cargados correctamente
- ✅ Clases desbalanceadas (~90/10)
- ✅ Datos faltantes (~15%, ~10%, ~5%)
- ✅ Features preparadas

**Uso:** Si algo falla, ejecuta esto para diagnosticar

---

## 🎬 Flujo Recomendado para el Evento

### Preparación (1 día antes):
1. ✅ Ejecutar `OXXO_ML_DEMO.sql` completo
2. ✅ Ejecutar `VERIFICACION_DEMO.sql` 
3. ✅ Probar `notebook_ejemplo.py` (al menos hasta CELDA 10)
4. ✅ (Opcional) Configurar Streamlit app
5. ✅ Leer `GUIA_PRESENTACION.md`
6. ✅ Practicar timing

### Durante el Evento (15 minutos):
1. **Min 0-3:** Contexto del problema (slides + SQL Sección 0)
2. **Min 3-5:** Mostrar datos generados (SQL Sección 2)
3. **Min 5-7:** Feature engineering (SQL Sección 3)
4. **Min 7-12:** 🔥 ML con Python (Notebook CELDAS 7-10)
   - Explicar SMOTE
   - Mostrar entrenamiento
   - Evaluar resultados
   - **CLÍMAX:** Valor de negocio $1M USD/año
5. **Min 12-14:** (Opcional) Streamlit demo
6. **Min 14-15:** Cierre + Q&A

---

## 💡 Tips para el Éxito

### ✅ **DO:**
- Aumentar tamaño de fuente (Cmd/Ctrl + +)
- Modo "No Molestar" en laptop
- Tener agua a mano
- Hacer PAUSA después de mostrar ROI
- Sonreír y hacer contacto visual
- Decir "¿Preguntas hasta aquí?" cada 3-4 min

### ❌ **DON'T:**
- No leer código línea por línea
- No disculparse por errores técnicos
- No usar jerga sin explicar
- No apresurarse en la parte de SMOTE (es clave)
- No olvidar mencionar costos ($3 USD/mes vs $1000+)

---

## 🆘 Troubleshooting Rápido

### ❌ **Error: Warehouse no existe**
```sql
USE ROLE ACCOUNTADMIN;
-- Re-ejecutar Sección 1
```

### ❌ **Error: Tabla vacía**
```sql
-- Re-ejecutar INSERT de Sección 2
-- Si falla, reducir LIMIT de 50000 a 10000
```

### ❌ **Error: Python import falla**
```bash
pip install --upgrade snowflake-snowpark-python
pip install -r requirements.txt
```

### ❌ **Error: SMOTE toma mucho tiempo**
- Reducir tamaño de muestra
- Comentar: "En producción esto toma ~2 min"
- Mostrar resultados pre-calculados

---

## 📊 Métricas Esperadas (para verificar)

Si tus resultados están cerca de estos, ¡todo está bien!

```
✅ DATOS:
   - Productos: 100
   - Tiendas: 500
   - Transacciones: 50,000
   - Tasa de quiebre: 9-11%

✅ CALIDAD:
   - Nulos temperatura: 14-16%
   - Nulos promoción: 9-11%
   - Nulos inventario: 4-6%

✅ MODELO:
   - ROC-AUC: 0.80-0.90
   - Precision (Quiebre): 0.70-0.85
   - Recall (Quiebre): 0.65-0.80

✅ NEGOCIO:
   - Valor mensual: $50K-$100K MXN
   - Valor anual: $600K-$1.2M MXN
```

---

## 🎓 Conceptos Clave a Explicar

### 1. **Clases Desbalanceadas**
> "En la vida real, 90% del tiempo NO hay quiebre. Si entrenamos sin balancear, el modelo aprende a siempre decir 'NO quiebre' y tiene 90% accuracy... pero no sirve de nada."

### 2. **SMOTE**
> "SMOTE genera muestras sintéticas de la clase minoritaria interpolando entre vecinos cercanos. Así balanceamos sin simplemente duplicar registros."

### 3. **Feature Importance**
> "Random Forest nos dice qué variables importan más. Vemos que inventario inicial, ventas del día anterior y temperatura son clave."

### 4. **ROC-AUC**
> "ROC-AUC de 0.85 significa que el modelo distingue muy bien entre quiebres y no-quiebres. 0.5 sería aleatorio, 1.0 perfecto."

### 5. **Valor de Negocio**
> "Cada falso negativo (quiebre no detectado) cuesta $1,000 MXN en ventas perdidas. Con 1,000 falsos negativos menos al mes, ahorramos $1M MXN."

---

## 🔗 Recursos Adicionales

- 📚 [Snowpark Python Docs](https://docs.snowflake.com/en/developer-guide/snowpark/python/index.html)
- 🎓 [Snowflake ML Tutorial](https://quickstarts.snowflake.com/guide/getting_started_with_machine_learning_in_snowflake/index.html)
- 💬 [Snowflake Community](https://community.snowflake.com/)
- 📺 [Snowflake YouTube](https://www.youtube.com/c/SnowflakeInc)

---

## 📞 Soporte

¿Problemas? Revisa en orden:
1. `VERIFICACION_DEMO.sql` - Diagnosticar
2. `GUIA_PRESENTACION.md` - Sección Troubleshooting
3. README.md - Documentación completa

---

## ✅ Checklist Final

**1 día antes del evento:**
- [ ] Base de datos creada y verificada
- [ ] Modelos entrenados al menos una vez
- [ ] Streamlit app funcionando (opcional)
- [ ] Guía de presentación leída
- [ ] Timing practicado

**1 hora antes:**
- [ ] Laptop cargada
- [ ] Conexión a internet verificada
- [ ] Snowflake UI abierta y funcionando
- [ ] Fuentes aumentadas
- [ ] Modo "No Molestar" activado

**5 minutos antes:**
- [ ] Respiro profundo 🧘
- [ ] Sonrisa 😊
- [ ] ¡A romperla! 🚀

---

¡Éxito en tu presentación! 🏪❄️🐍

**Recuerda:** El mensaje clave es **"ML sin infraestructura, del dato sucio al valor de negocio en minutos"**

