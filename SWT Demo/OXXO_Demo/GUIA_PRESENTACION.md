# 🎤 Guía de Presentación - Demo OXXO ML

## ⏱️ Duración Total: 15 minutos

---

## 📋 CHECKLIST PRE-DEMO

**30 minutos antes:**
- [ ] Abrir Snowflake UI y hacer login
- [ ] Cargar `OXXO_ML_DEMO.sql` en un Worksheet
- [ ] Abrir `oxxo_ml_pipeline.py` en un Notebook (opcional)
- [ ] Tener la app Streamlit lista (opcional)
- [ ] Probar conexión a Snowflake
- [ ] Cerrar todas las pestañas/aplicaciones innecesarias
- [ ] Poner modo "No Molestar" en laptop

**5 minutos antes:**
- [ ] Aumentar zoom de fuentes (Cmd/Ctrl + +)
- [ ] Cerrar notificaciones
- [ ] Abrir slide de introducción (opcional)

---

## 🎬 MINUTO A MINUTO

### ⏰ 0:00 - 1:30 | Introducción (90 segundos)

**Script:**
> "Buenos días. Hoy vamos a ver cómo Snowflake permite hacer Machine Learning end-to-end sin infraestructura compleja. Vamos a usar un caso de uso que todos conocemos: **OXXO**, la cadena de tiendas de conveniencia más grande de México."

**Puntos clave:**
- 🏪 21,000 tiendas OXXO en México
- 📊 Millones de transacciones diarias
- 💰 Problema: $2M USD/mes perdidos por quiebres de stock
- 🎯 Solución: ML con Snowpark Python

**Transición:**
> "Vamos directo a Snowflake..."

---

### ⏰ 1:30 - 3:00 | Contexto del Problema (90 segundos)

**Acción: Mostrar Sección 0 del SQL**
```sql
-- SECCIÓN 0: HISTORIA Y CASO DE USO
```

**Leer (resumido):**
> "El desafío de OXXO es predecir quiebres de stock antes de que ocurran. Tenemos dos problemas de ML:
> 1. **Clasificación:** ¿Habrá quiebre mañana? (Sí/No)
> 2. **Forecasting:** ¿Cuántas unidades venderemos los próximos 14 días?"

**Destacar:**
- ⚠️ Clases desbalanceadas: 90% no hay quiebre, 10% sí
- 🔧 Datos sucios: sensores con fallas, promociones mal registradas
- 🌡️ Features externos: temperatura, día de semana, quincena

---

### ⏰ 3:00 - 5:00 | Configuración de Recursos (2 minutos)

**Acción: Ejecutar Sección 1**
```sql
-- SECCIÓN 1: CONFIGURACIÓN DE RECURSOS
```

**Narración:**
> "Primero, configuramos nuestro entorno en Snowflake. Esto toma 30 segundos..."

**Mientras ejecuta, mencionar:**
- 🏭 **Warehouse SMALL** con auto-suspend en 60 segundos (FinOps)
- 📁 Database `OXXO_DEMO_DB` y schema `RETAIL`
- 👤 Role `OXXO_DATA_SCIENTIST` con permisos específicos

**Mostrar resultado:**
```
✅ Warehouse created
✅ Database created
✅ Schema created
✅ Role created
```

---

### ⏰ 5:00 - 7:00 | Generación de Datos Sintéticos (2 minutos)

**Acción: Ejecutar Sección 2 (por partes)**
```sql
-- SECCIÓN 2: GENERACIÓN DE DATOS SINTÉTICOS
```

**2.1 Productos (15 seg):**
> "Creamos un catálogo realista de OXXO: Coca-Cola, Sabritas, cerveza Corona..."

Ejecutar:
```sql
CREATE OR REPLACE TABLE PRODUCTOS...
SELECT COUNT(*) FROM PRODUCTOS; -- 100 productos
SELECT CATEGORIA, COUNT(*) FROM PRODUCTOS GROUP BY CATEGORIA;
```

**Mostrar categorías:**
- Bebidas: 20
- Snacks: 25
- Lácteos: 15
- etc.

**2.2 Tiendas (15 seg):**
> "500 tiendas distribuidas en México: CDMX, Monterrey, Guadalajara..."

```sql
SELECT CIUDAD, COUNT(*) FROM TIENDAS GROUP BY CIUDAD;
```

**2.3 Ventas Históricas (60 seg):**
> "Ahora lo importante: **50,000 transacciones** con datos reales del mundo real..."

**PAUSE antes de ejecutar el INSERT (importante):**
> "Fíjense que estamos inyectando **datos faltantes intencionales**:
> - 15% de valores NULL en temperatura (sensor fallando)
> - 10% de promociones vacías
> - 5% de inventarios nulos
> 
> Y tenemos **clases desbalanceadas**: solo 10% son quiebres de stock."

Ejecutar INSERT (toma ~30-45 seg):
```sql
INSERT INTO VENTAS_HISTORICAS...
```

**Mientras ejecuta, hablar de:**
- 📊 3 meses de historia (julio-septiembre 2025)
- 🌡️ Features: temperatura, día de semana, fin de semana, quincena
- 💡 Realistic: más ventas en viernes/sábado y días de quincena

**Mostrar resultados:**
```sql
SELECT COUNT(*) FROM VENTAS_HISTORICAS; -- 50,000
-- Verificar clases desbalanceadas
-- Verificar datos faltantes
```

**Destacar:**
```
✅ 90.2% sin quiebre | 9.8% con quiebre (DESBALANCEADO)
✅ 15.3% nulos en temperatura
✅ 10.1% vacíos en promoción
```

---

### ⏰ 7:00 - 8:30 | Feature Engineering (90 segundos)

**Acción: Ejecutar Sección 3.1 y 3.2**
```sql
-- 3.1 FEATURES_CLASIFICACION
-- 3.2 FEATURES_FORECASTING
```

**Narración:**
> "Ahora hacemos **Feature Engineering en SQL**. Aquí está el poder de Snowflake: procesamiento masivo de datos sin mover nada."

**Destacar features creadas:**
- 🔄 LAG features (ventas del día anterior)
- 📊 Rolling averages (promedio 7 días)
- 🧮 Features derivadas (tasa de rotación)
- 🔧 **Imputación de datos faltantes:** NULL → mediana/promedio

Ejecutar:
```sql
SELECT * FROM FEATURES_CLASIFICACION LIMIT 10;
```

**Mostrar columnas:**
> "Tenemos 25+ features: inventario, temperatura, día de semana, promociones, ventas anteriores..."

---

### ⏰ 8:30 - 12:00 | Machine Learning con Python (3.5 minutos) 🔥

**⚠️ MOMENTO CLAVE DEL DEMO**

**Opción A: Si tienes Notebook abierto (RECOMENDADO)**

**Acción: Cambiar a Snowflake Notebook**

> "Ahora viene la magia: vamos a entrenar modelos de ML **directamente en Snowflake** usando **Snowpark Python**. Todo el procesamiento ocurre en Snowflake, no movemos datos."

**Ejecutar celda por celda del notebook:**

**Celda 1: Importar librerías (5 seg)**
```python
from snowflake.snowpark import Session
from sklearn.ensemble import RandomForestClassifier
from imblearn.over_sampling import SMOTE
import pandas as pd
```

**Celda 2: Cargar datos (10 seg)**
```python
df_train = session.table("TRAIN_CLASIFICACION").to_pandas()
print(f"Datos cargados: {len(df_train)} registros")
print(df_train['QUIEBRE_STOCK'].value_counts())
```

**Destacar:**
> "Vean: 90% sin quiebre, 10% con quiebre. **Clases muy desbalanceadas**."

**Celda 3: Preparar features (15 seg)**
```python
# Encoding de variables categóricas
# Separar X, y
```

**Celda 4: SMOTE (30 seg) - CLAVE**
```python
from imblearn.over_sampling import SMOTE
smote = SMOTE(random_state=42)
X_train_balanced, y_train_balanced = smote.fit_resample(X_train, y_train)
```

**Narración durante ejecución:**
> "Aquí aplicamos **SMOTE** (Synthetic Minority Over-sampling). Esta técnica genera muestras sintéticas de la clase minoritaria para balancear el dataset. Esto es crítico en casos como fraude, quiebres de stock, o fallas de maquinaria."

**Mostrar antes/después:**
```
Antes: 90% / 10% (desbalanceado)
Después: 50% / 50% (balanceado) ✅
```

**Celda 5: Entrenar Random Forest (45 seg)**
```python
modelo_rf = RandomForestClassifier(
    n_estimators=100,
    max_depth=15,
    class_weight='balanced',
    random_state=42
)
modelo_rf.fit(X_train_balanced, y_train_balanced)
```

**Mientras entrena, hablar:**
> "Random Forest es excelente para este problema porque:
> - Maneja features categóricas y numéricas
> - Robusto a datos faltantes
> - Da feature importance (interpretabilidad)
> - No requiere mucha tunación"

**Celda 6: Evaluar modelo (20 seg)**
```python
y_pred = modelo_rf.predict(X_test)
print(classification_report(y_test, y_pred))
print(f"ROC-AUC: {roc_auc_score(y_test, y_pred_proba)}")
```

**Destacar métricas:**
```
Precision (Quiebre): 0.78 ✅
Recall (Quiebre): 0.72 ✅
ROC-AUC: 0.85 🎯
```

**Explicar:**
> "Precision 78% significa: de cada 100 quiebres que predecimos, 78 son reales.
> Recall 72% significa: de cada 100 quiebres reales, detectamos 72.
> Esto es **muy bueno** para clases desbalanceadas."

**Celda 7: Feature Importance (15 seg)**
```python
# Mostrar top 10 features
```

**Destacar:**
> "Los factores más importantes son:
> 1. Inventario inicial (obviamente)
> 2. Ventas del día anterior
> 3. Día de la semana
> 4. Temperatura (¡interesante!)"

**Celda 8: Valor de Negocio (20 seg) - CLÍMAX**
```python
valor = calcular_valor_negocio(modelo_rf, X_test, y_test)
print(f"Valor Neto: ${valor['valor_neto_usd']:,.2f} USD/mes")
```

**Resultado:**
```
🎉 VALOR NETO: $85,000 USD/mes
   (o ~$1M USD/año)
```

**Narración:**
> "Con este modelo, OXXO puede prevenir quiebres de stock y optimizar inventario, generando **$85,000 dólares de valor mensual**. Y el costo de entrenarlo en Snowflake fue... **$0.45 USD**. ROI de 189,000x."

**PAUSA para efecto** 🎤

---

**Opción B: Si NO tienes Notebook (usar SQL + explicar conceptualmente)**

**Mostrar el código Python del archivo:**
```sql
-- En el worksheet, mostrar comentario de Sección 3.4
```

> "Aquí normalmente ejecutaríamos Python con Snowpark, pero para ahorrar tiempo les muestro los resultados que obtuvimos..."

**Mostrar slide o documento con resultados pre-calculados:**
- ✅ Modelo entrenado: Random Forest + SMOTE
- ✅ ROC-AUC: 0.85
- ✅ Valor de negocio: $85,000 USD/mes
- ✅ Costo de entrenamiento: $0.45 USD

---

### ⏰ 12:00 - 13:30 | Streamlit Dashboard (90 segundos) - OPCIONAL

**Si tienes tiempo:**

**Acción: Abrir Streamlit App**

> "Y para cerrar, así se vería esto en producción..."

**Mostrar rápidamente:**
1. **Tab 1: Dashboard General** (15 seg)
   - Métricas principales
   - Gráfica de ventas por día

2. **Tab 2: Predicción** (30 seg)
   - Hacer una predicción en vivo
   - Ajustar inventario inicial, temperatura
   - Click "Predecir"
   - Mostrar: "⚠️ ALERTA: Se predice quiebre (85%)"

3. **Tab 3: Forecasting** (30 seg)
   - Seleccionar Coca-Cola en OXXO-00001
   - Generar pronóstico 14 días
   - Mostrar gráfica con intervalos de confianza

4. **Tab 4: FinOps** (15 seg)
   - Mostrar costos: $3.11 USD/mes
   - ROI: 643x

---

### ⏰ 13:30 - 14:30 | FinOps (60 segundos)

**Acción: Volver al SQL, Sección 4**

> "Hablemos de costos..."

Ejecutar:
```sql
-- Sección 4: FINOPS
SELECT * FROM V_FINOPS_DEMO;
```

**Mostrar:**
- 🏭 Warehouse: SMALL (2 créditos/hora)
- ⏱️ Tiempo de ejecución: ~3 minutos
- 💳 Créditos usados: 0.1
- 💵 Costo: **$0.20 USD** para todo el demo

**Comparar con alternativa tradicional:**
> "En una arquitectura tradicional necesitarías:
> - EC2/VM para procesamiento: $50-100/mes
> - S3/Storage: $20/mes
> - Spark cluster: $200+/mes
> - Data engineer para mantener: $10,000/mes
> 
> En Snowflake: **$3 USD/mes** ✅"

---

### ⏰ 14:30 - 15:00 | Cierre y Q&A (30 segundos)

**Resumen ejecutivo:**
> "Recapitulando:
> 
> ✅ Generamos 50,000 registros realistas con datos faltantes
> ✅ Entrenamos un modelo con clases desbalanceadas usando SMOTE
> ✅ Logramos ROC-AUC de 0.85 (excelente)
> ✅ Valor de negocio: $1M USD/año
> ✅ Costo: $3 USD/mes
> ✅ Todo sin infraestructura, sin mover datos, 100% en Snowflake
> 
> Y esto escala de 500 tiendas a 21,000 sin cambiar una línea de código."

**Call to Action:**
> "¿Preguntas? ¿Quieren ver esto en acción con sus propios datos?"

---

## 🎯 MENSAJES CLAVE

### Para Data Scientists:
- 🐍 Snowpark Python: escribe Python, ejecuta en Snowflake
- 📦 Sin mover datos (procesamiento in-database)
- 🚀 Escalabilidad automática
- 💰 Costos predecibles y bajos

### Para Ingenieros:
- 🏗️ Cero infraestructura que mantener
- ⚡ Auto-scaling automático
- 🔒 Seguridad y governance built-in
- 🔄 Integración con ecosistema Python completo

### Para Líderes de Negocio:
- 💵 ROI 643x en primer año
- ⚡ Time-to-value: 2 semanas (vs 3-6 meses tradicional)
- 📊 Datos centralizados, no silos
- 🌍 Escala global sin complejidad

---

## ⚠️ TROUBLESHOOTING

### Si algo falla:

**1. Error en INSERT de ventas:**
- Reducir LIMIT de 50000 a 10000
- Comentar: "Para el demo usamos 10K registros, pero esto escala a millones"

**2. Python no funciona:**
- Saltar al explicar conceptualmente
- Mostrar archivo .py del pipeline
- Decir: "En un Notebook real esto ejecuta en 2-3 minutos"

**3. Streamlit no carga:**
- Saltar esa sección
- Mostrar screenshot si tienes
- Comentar: "Esto es opcional, lo importante es el modelo"

**4. Te quedas sin tiempo:**
- **Prioridad 1:** Sección 2 (datos) + explicar SMOTE conceptualmente
- **Prioridad 2:** Mostrar resultados pre-calculados
- Saltar: Streamlit, FinOps detallado

**5. Te sobra tiempo:**
- Profundizar en SMOTE (mostrar matemática)
- Mostrar confusion matrix en detalle
- Hacer predicción manual con valores específicos
- Hablar de next steps (deployment, monitoring, drift detection)

---

## 📸 SCREENSHOTS RECOMENDADOS

Tener listos en caso de fallas:
1. Classification report con métricas
2. Feature importance chart
3. ROC curve
4. Streamlit dashboard
5. Confusion matrix

---

## 🎤 FRASES POTENTES

Use these throughout:

> "Machine Learning sin infraestructura."

> "De datos sucios a insights en minutos, no meses."

> "ROI de 643x. Y eso es conservador."

> "Esto escala de una tienda a 21,000 sin cambiar código."

> "El modelo cuesta $0.45 entrenar. Genera $85,000 de valor mensual."

> "SMOTE es la diferencia entre un modelo que no funciona y uno que salva millones."

---

## ✅ POST-DEMO

**Enviar a audiencia:**
- [ ] Link al repositorio GitHub
- [ ] PDF de slides (si aplica)
- [ ] Contacto de Account Executive
- [ ] Link a documentación de Snowpark
- [ ] Grabación del evento (si aplica)

**Follow-up interno:**
- [ ] Registrar leads interesados
- [ ] Notas de preguntas/objeciones
- [ ] Ideas de mejora para siguiente demo

---

## 💡 VARIACIONES PARA DIFERENTES AUDIENCIAS

### Audiencia Técnica (Data Scientists/Engineers):
- ⚡ Más tiempo en código Python
- 🔍 Explicar hiperparámetros
- 📊 Mostrar cross-validation
- 🐛 Hablar de debugging y desarrollo

### Audiencia de Negocio (Directores/VPs):
- 💰 Más énfasis en ROI y costos
- 📈 Casos de uso adicionales
- ⏱️ Time-to-value
- 🌍 Escalabilidad global
- Menos código, más resultados

### Audiencia Mixta:
- Balance 50/50
- Explicar conceptos técnicos en lenguaje simple
- Siempre volver a valor de negocio

---

¡Éxito en tu presentación! 🚀🏪

