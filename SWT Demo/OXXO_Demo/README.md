# 🏪 Demo OXXO - Predicción de Demanda y Stock con Snowflake ML

## 📋 Descripción General

Este demo ilustra las capacidades end-to-end de Snowflake para Machine Learning usando Python/Snowpark, aplicado a un caso de uso retail mexicano: **OXXO**.

### 🎯 Objetivos del Demo

1. **Clasificación**: Predecir quiebres de stock (clases desbalanceadas: ~90% sin quiebre, ~10% con quiebre)
2. **Series de Tiempo**: Pronosticar ventas diarias por producto y tienda
3. **Data Quality**: Demostrar técnicas de imputación de datos nulos y vacíos
4. **FinOps**: Monitorear costos de compute y almacenamiento

---

## 🏗️ Arquitectura del Demo

```
┌─────────────────────────────────────────────────────────┐
│  Sección 1: Configuración de Recursos Snowflake         │
│  - Warehouse, Database, Schema, Role                    │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  Sección 2: Generación de Datos Sintéticos              │
│  - Catálogo de productos (bebidas, snacks, etc.)        │
│  - Red de 500 tiendas OXXO en México                    │
│  - 50,000+ transacciones con datos faltantes            │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  Sección 3: ML Pipeline con Snowpark Python             │
│  - Feature Engineering                                   │
│  - Imputación de datos faltantes                        │
│  - Modelo de Clasificación (Random Forest)              │
│  - Modelo de Forecasting (Prophet/XGBoost)              │
│  - Evaluación y Métricas                                │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  Visualización y FinOps                                  │
│  - Dashboard de métricas del modelo                     │
│  - Reporte de costos de compute                         │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Datasets Generados

### 1. `PRODUCTOS` - Catálogo de productos OXXO
- **Registros**: ~100 productos
- **Categorías**: Bebidas, Snacks, Lácteos, Cuidado Personal, etc.
- **Campos**: ID, nombre, categoría, precio, margen

### 2. `TIENDAS` - Red de tiendas OXXO
- **Registros**: 500 tiendas
- **Cobertura**: Ciudad de México, Monterrey, Guadalajara, Puebla, etc.
- **Campos**: ID, ciudad, estado, tipo (urbana/suburbana), tamaño

### 3. `VENTAS_HISTORICAS` - Transacciones con datos reales
- **Registros**: ~50,000 transacciones (3 meses)
- **Desbalanceo**: 90% sin quiebre, 10% con quiebre de stock
- **Datos Faltantes**: 
  - ~15% valores nulos en temperatura
  - ~10% valores vacíos en promociones
  - ~5% nulos en nivel de inventario
- **Campos**: fecha, tienda_id, producto_id, ventas, inventario, quiebre_stock, temperatura, día_semana, promoción, etc.

---

## 🚀 Cómo Ejecutar el Demo

### Opción 1: Worksheet SQL Completo
1. Abre `OXXO_ML_DEMO.sql` en Snowflake
2. Ejecuta secuencialmente las secciones 0, 1, 2, 3
3. Todo está comentado y listo para presentar

### Opción 2: Notebook Python (Snowpark)
1. Abre `oxxo_ml_pipeline.py` 
2. Ejecuta en Snowflake Notebook o localmente con Snowpark
3. Contiene el pipeline ML completo

### Opción 3: Streamlit App
1. Abre la carpeta `streamlit_app/`
2. Sube a Snowflake como Streamlit in Snowflake
3. Dashboard interactivo con predicciones en tiempo real

---

## 🎤 Puntos Clave para la Presentación

### Minuto 1-2: Contexto del Problema
> "OXXO es la cadena de tiendas de conveniencia más grande de México con más de 21,000 tiendas. Su principal reto: predecir quiebres de stock para productos de alta rotación como Coca-Cola, Sabritas y cigarros."

### Minuto 3-5: Calidad de Datos
> "En el mundo real, los datos nunca son perfectos. Aquí vemos sensores de temperatura con fallas (15% nulos), promociones mal registradas (10% vacíos), y conteos de inventario faltantes (5% nulos). Snowflake + Python nos permite limpiar esto eficientemente."

### Minuto 6-10: Modelado con Snowpark
> "Con Snowpark Python, entrenamos directamente en Snowflake sin mover datos. Usamos Random Forest para clasificación de quiebres (problema desbalanceado con SMOTE) y XGBoost para forecasting de ventas."

### Minuto 11-12: Valor de Negocio
> "Este modelo puede prevenir pérdidas de hasta $2M USD mensuales en ventas perdidas por quiebres de stock, mientras optimizamos inventario en $5M USD."

### Minuto 13-15: FinOps
> "Y como Data Scientists responsables, monitoreamos costos. Este pipeline completo cuesta ~$10 USD en compute para entrenar 50K registros."

---

## 💰 Métricas de FinOps

### Warehouse Sizing
- **Desarrollo**: XSMALL (1 crédito/hora)
- **Producción**: SMALL (2 créditos/hora)
- **Costo estimado del demo**: $0.50 - $2.00 USD

### Storage
- **Tablas raw**: ~100 MB
- **Tablas de features**: ~50 MB
- **Modelos serializados**: ~10 MB
- **Costo mensual**: ~$0.02 USD

---

## 🧠 Conceptos Técnicos Demostrados

- ✅ Snowpark Python para ML end-to-end
- ✅ Feature Engineering en SQL/Python
- ✅ Manejo de datos faltantes (imputación)
- ✅ Balanceo de clases desbalanceadas (SMOTE)
- ✅ Time Series Forecasting con features externos
- ✅ Model Registry y versionado
- ✅ Inferencia en batch
- ✅ FinOps y monitoreo de costos

---

## 📚 Dependencias

```python
snowflake-snowpark-python
pandas
numpy
scikit-learn
imbalanced-learn
xgboost
matplotlib
seaborn
```

---

## 👥 Audiencia Objetivo

- Data Scientists interesados en ML en Snowflake
- Ingenieros de ML buscando reducir infraestructura
- Líderes técnicos evaluando plataformas de datos
- Equipos de retail/FMCG con problemas similares

---

## 📞 Contacto

**Snowflake México**  
¿Preguntas? Contacta a tu Account Executive de Snowflake

---

**Creado para**: Evento Snowflake  
**Última actualización**: Octubre 2025  
**Versión**: 1.0

