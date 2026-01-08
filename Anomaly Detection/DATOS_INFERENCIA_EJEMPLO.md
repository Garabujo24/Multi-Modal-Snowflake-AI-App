# 📊 Datos de Inferencia - Semana Ejemplo

## 🎯 Objetivo
Datos sintéticos de **7 días** con **5 anomalías ocultas** para validar el modelo de detección.

---

## 📅 Tabla de Datos de Ejemplo

### **Día 1 (Hoy + 0)** - Datos normales

| Sucursal | Región | Tipo | Ventas | Transacciones | Ticket Promedio | Temp °C | Precipitación | Festivo | Promoción |
|----------|--------|------|--------|---------------|-----------------|---------|---------------|---------|-----------|
| MegaPlaza CDMX Reforma | Centro | MegaPlaza | 112,450.00 | 268 | 419.59 | 21.3 | 2.1 | No | No |
| CompraMax Monterrey San Pedro | Norte | CompraMax | 145,320.00 | 342 | 424.85 | 28.5 | 0.0 | No | No |
| Sabor Grill Monterrey Valle | Norte | Sabor Grill | 52,180.00 | 125 | 417.44 | 28.1 | 0.0 | No | No |
| MegaPlaza Cancún Plaza | Sur | MegaPlaza | 98,230.00 | 232 | 423.41 | 31.2 | 5.2 | No | Sí |
| CompraMax Guadalajara Centro | Sur | CompraMax | 138,650.00 | 328 | 422.71 | 29.8 | 3.1 | No | No |

---

### **Día 2 (Hoy + 1)** - 🚨 ANOMALÍA 1: Caída en CDMX Reforma

| Sucursal | Región | Tipo | Ventas | Transacciones | Ticket Promedio | Temp °C | Precipitación | Observación |
|----------|--------|------|--------|---------------|-----------------|---------|---------------|-------------|
| **MegaPlaza CDMX Reforma** ⚠️ | Centro | MegaPlaza | **22,890.00** ⬇️ | **67** ⬇️ | 341.64 | 20.8 | 1.5 | **Caída 80% - Sistema de pagos** |
| CompraMax Monterrey San Pedro | Norte | CompraMax | 148,720.00 | 351 | 423.70 | 27.9 | 0.0 | Normal |
| Sabor Grill Monterrey Valle | Norte | Sabor Grill | 54,320.00 | 130 | 417.85 | 27.5 | 0.0 | Normal |
| MegaPlaza Cancún Plaza | Sur | MegaPlaza | 96,540.00 | 228 | 423.51 | 31.5 | 4.8 | Normal |
| CompraMax Guadalajara Centro | Sur | CompraMax | 141,230.00 | 334 | 422.84 | 30.1 | 2.8 | Normal |

---

### **Día 3 (Hoy + 2)** - 🚨 ANOMALÍA 1 continúa + ANOMALÍA 2: Ticket bajo en Monterrey

| Sucursal | Región | Tipo | Ventas | Transacciones | Ticket Promedio | Temp °C | Precipitación | Observación |
|----------|--------|------|--------|---------------|-----------------|---------|---------------|-------------|
| **MegaPlaza CDMX Reforma** ⚠️ | Centro | MegaPlaza | **21,340.00** ⬇️ | **64** ⬇️ | 333.44 | 21.5 | 2.8 | **Caída continúa** |
| **CompraMax Monterrey San Pedro** ⚠️ | Norte | CompraMax | **66,924.00** ⬇️ | 352 ✓ | **190.13** ⬇️⬇️ | 28.2 | 0.0 | **Ticket 55% bajo - Error descuentos** |
| Sabor Grill Monterrey Valle | Norte | Sabor Grill | 53,890.00 | 129 | 417.75 | 28.3 | 0.0 | Normal |
| MegaPlaza Cancún Plaza | Sur | MegaPlaza | 99,120.00 | 234 | 423.59 | 31.8 | 6.1 | Normal |
| CompraMax Guadalajara Centro | Sur | CompraMax | 139,450.00 | 330 | 422.58 | 29.5 | 3.5 | Normal |

---

### **Día 4 (Hoy + 3)** - 🚨 ANOMALÍA 3: Caída generalizada Región Sur

| Sucursal | Región | Tipo | Ventas | Transacciones | Ticket Promedio | Temp °C | Precipitación | Observación |
|----------|--------|------|--------|---------------|-----------------|---------|---------------|-------------|
| MegaPlaza CDMX Reforma | Centro | MegaPlaza | 115,680.00 | 276 | 419.13 | 22.1 | 1.2 | Normal (recuperado) |
| CompraMax Monterrey San Pedro | Norte | CompraMax | 147,920.00 | 349 | 423.84 | 27.6 | 0.0 | Normal (recuperado) |
| Sabor Grill Monterrey Valle | Norte | Sabor Grill | 55,120.00 | 132 | 417.58 | 27.8 | 0.0 | Normal |
| **MegaPlaza Cancún Plaza** ⚠️ | **Sur** | MegaPlaza | **54,516.00** ⬇️ | **140** ⬇️ | 389.40 | 30.2 | **65.0** 🌧️ | **Tormenta tropical** |
| **CompraMax Guadalajara Centro** ⚠️ | **Sur** | CompraMax | **76,258.00** ⬇️ | **197** ⬇️ | 387.00 | 28.5 | **65.0** 🌧️ | **Tormenta tropical** |
| **Sabor Grill Guadalajara** ⚠️ | **Sur** | Sabor Grill | **28,270.00** ⬇️ | **73** ⬇️ | 387.26 | 28.1 | **65.0** 🌧️ | **Tormenta tropical** |
| **MegaPlaza Oaxaca Centro** ⚠️ | **Sur** | MegaPlaza | **50,820.00** ⬇️ | **131** ⬇️ | 387.94 | 29.3 | **65.0** 🌧️ | **Tormenta tropical** |

---

### **Día 5 (Hoy + 4)** - 🚨 ANOMALÍA 3 continúa + ANOMALÍA 5: Ticket alto en Cancún

| Sucursal | Región | Tipo | Ventas | Transacciones | Ticket Promedio | Temp °C | Precipitación | Observación |
|----------|--------|------|--------|---------------|-----------------|---------|---------------|-------------|
| MegaPlaza CDMX Reforma | Centro | MegaPlaza | 113,230.00 | 270 | 419.37 | 21.7 | 2.5 | Normal |
| CompraMax Monterrey San Pedro | Norte | CompraMax | 146,540.00 | 346 | 423.53 | 28.4 | 0.0 | Normal |
| Sabor Grill Monterrey Valle | Norte | Sabor Grill | 54,680.00 | 131 | 417.40 | 28.0 | 0.0 | Normal |
| **MegaPlaza Cancún Plaza** ⚠️ | **Sur** | MegaPlaza | **225,036.00** ⬆️⬆️ | 241 | **933.76** ⬆️⬆️ | 30.8 | **65.0** 🌧️ | **Compras turísticas masivas + tormenta** |
| **CompraMax Guadalajara Centro** ⚠️ | **Sur** | CompraMax | **74,195.00** ⬇️ | **192** ⬇️ | 386.43 | 28.9 | **65.0** 🌧️ | **Tormenta continúa** |
| **MegaPlaza Oaxaca Centro** ⚠️ | **Sur** | MegaPlaza | **51,340.00** ⬇️ | **132** ⬇️ | 388.94 | 29.5 | **65.0** 🌧️ | **Tormenta continúa** |

---

### **Día 6 (Hoy + 5)** - 🚨 ANOMALÍA 4: Pico inusual Sabor Grill Monterrey

| Sucursal | Región | Tipo | Ventas | Transacciones | Ticket Promedio | Temp °C | Precipitación | Observación |
|----------|--------|------|--------|---------------|-----------------|---------|---------------|-------------|
| MegaPlaza CDMX Reforma | Centro | MegaPlaza | 114,890.00 | 274 | 419.23 | 22.3 | 1.8 | Normal |
| CompraMax Monterrey San Pedro | Norte | CompraMax | 149,320.00 | 353 | 423.12 | 27.2 | 0.0 | Normal |
| **Sabor Grill Monterrey Valle** ⚠️ | **Norte** | Sabor Grill | **153,104.00** ⬆️⬆️ | **249** ⬆️ | **614.88** ⬆️ | 27.9 | 0.0 | **Evento corporativo no registrado** |
| MegaPlaza Cancún Plaza | Sur | MegaPlaza | 97,850.00 | 231 | 423.59 | 31.4 | 4.2 | Normal (recuperado) |
| CompraMax Guadalajara Centro | Sur | CompraMax | 140,120.00 | 331 | 423.32 | 29.7 | 2.5 | Normal (recuperado) |

---

### **Día 7 (Hoy + 6)** - Todo normal

| Sucursal | Región | Tipo | Ventas | Transacciones | Ticket Promedio | Temp °C | Precipitación | Observación |
|----------|--------|------|--------|---------------|-----------------|---------|---------------|-------------|
| MegaPlaza CDMX Reforma | Centro | MegaPlaza | 116,230.00 | 277 | 419.67 | 21.9 | 2.2 | Normal |
| CompraMax Monterrey San Pedro | Norte | CompraMax | 147,850.00 | 349 | 423.64 | 28.1 | 0.0 | Normal |
| Sabor Grill Monterrey Valle | Norte | Sabor Grill | 54,320.00 | 130 | 417.85 | 27.7 | 0.0 | Normal (recuperado) |
| MegaPlaza Cancún Plaza | Sur | MegaPlaza | 98,640.00 | 233 | 423.35 | 31.6 | 5.5 | Normal |
| CompraMax Guadalajara Centro | Sur | CompraMax | 141,560.00 | 335 | 422.57 | 30.0 | 3.2 | Normal |

---

## 🎯 Resumen de Anomalías Ocultas

| # | Día | Sucursal | Tipo de Anomalía | Magnitud | Z-Score Esperado | Causa Oculta |
|---|-----|----------|------------------|----------|------------------|--------------|
| **1** | +1, +2 | MegaPlaza CDMX Reforma | Caída ventas | -80% | > 3.5 | Falla sistema de pagos |
| **2** | +3 | CompraMax Monterrey | Ticket bajo | -55% | > 3.0 | Error descuentos |
| **3** | +4, +5 | Región Sur (todas) | Caída ventas | -45% | > 2.8 | Tormenta tropical |
| **4** | +6 | Sabor Grill MTY | Pico ventas | +180% | > 3.5 | Evento corporativo |
| **5** | +5 | MegaPlaza Cancún | Ticket alto | +120% | > 2.5 | Compras turísticas |

---

## 📈 Métricas Esperadas del Modelo

### Detección Esperada
- **Anomalías detectadas**: 5/5 (100%)
- **Falsos positivos**: 0-2 (< 5%)
- **Sensibilidad**: Alta (Z-Score > 2.0)
- **Especificidad**: Alta (pocos falsos positivos)

### Valores Normales de Referencia
| Tipo Tienda | Ventas Promedio | Ticket Promedio | Transacciones Promedio |
|-------------|-----------------|-----------------|------------------------|
| MegaPlaza | $85,000 - $120,000 | $400 - $450 | 200 - 280 |
| CompraMax | $120,000 - $160,000 | $410 - $450 | 280 - 380 |
| Sabor Grill | $45,000 - $65,000 | $400 - $450 | 100 - 150 |

---

## 🔍 Cómo Usar Estos Datos

### 1. **Cargar los datos**
```sql
-- Ejecutar el script MEGAMART_datos_inferencia.sql
```

### 2. **Ejecutar detección**
```sql
-- El script automáticamente ejecuta el modelo Z-Score
-- y genera la tabla RESULTADO_ANOMALIAS_VENTAS
```

### 3. **Revisar resultados**
```sql
SELECT 
    FECHA,
    SUCURSAL,
    VALOR_REAL AS VENTAS_REALES,
    MEDIA_ESPERADA AS VENTAS_ESPERADAS,
    ANOMALY_SCORE AS Z_SCORE,
    CLASIFICACION_ANOMALIA,
    DIRECCION_ANOMALIA
FROM MEGAMART_DB.ANALYTICS.RESULTADO_ANOMALIAS_VENTAS
WHERE FECHA >= CURRENT_DATE()
ORDER BY ANOMALY_SCORE DESC;
```

### 4. **Validar detección**
- ✅ ¿Detectó las 5 anomalías ocultas?
- ✅ ¿Los Z-Scores son correctos (> 2.0)?
- ✅ ¿La dirección es correcta (pico vs caída)?
- ✅ ¿Hay falsos positivos?

---

## 📊 Visualización Recomendada

### Gráfico 1: Timeline de Anomalías
```
Z-Score
  4.0 |              ●                    ●
  3.5 |        ●                          
  3.0 |              ●     ●              
  2.5 |                    ●              
  2.0 |_____|_____|_____|_____|_____|_____|_____
      D+0   D+1   D+2   D+3   D+4   D+5   D+6
```

### Gráfico 2: Mapa de Calor por Región
```
Región    | D+0 | D+1 | D+2 | D+3 | D+4 | D+5 | D+6 |
----------|-----|-----|-----|-----|-----|-----|-----|
Norte     | 🟢  | 🟢  | 🟡  | 🟢  | 🟢  | 🔴  | 🟢  |
Centro    | 🟢  | 🔴  | 🔴  | 🟢  | 🟢  | 🟢  | 🟢  |
Sur       | 🟢  | 🟢  | 🟢  | 🔴  | 🔴  | 🟢  | 🟢  |

🟢 Normal  🟡 Anomalía Baja  🔴 Anomalía Alta
```

---

## 💡 Notas Importantes

1. **Datos Realistas**: Los valores están basados en patrones reales de retail
2. **Variabilidad Natural**: Incluye ruido aleatorio del 15% para simular realidad
3. **Variables Exógenas**: Clima y eventos están correlacionados con las anomalías
4. **Sin Etiquetas**: Los datos NO tienen `TIENE_ANOMALIA = TRUE` (escenario real)
5. **Validación**: Permite medir precisión del modelo en datos no vistos

---

## 🚀 Próximos Pasos

1. ✅ Ejecutar script de inferencia
2. ✅ Validar detecciones del modelo
3. ✅ Analizar falsos positivos/negativos
4. 📊 Crear dashboard de monitoreo
5. 🔔 Configurar alertas automáticas
6. 📈 Ajustar umbrales si es necesario

---

**Creado para**: Grupo Retail MegaMart (Empresa Ficticia)  
**Fecha**: Enero 2025  
**Versión**: 1.0  
**Nota**: Todos los datos son ficticios con fines educativos


