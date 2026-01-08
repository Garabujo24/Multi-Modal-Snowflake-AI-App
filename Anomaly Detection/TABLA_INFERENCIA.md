# 📊 Tabla de Datos de Inferencia - 7 Días

## Estructura: Exactamente igual que VENTAS_DIARIAS
**Total registros:** 35 (5 sucursales × 7 días)  
**Anomalías ocultas:** 5 (sin etiquetar)

---

## 📅 DÍA 1 - LUNES (Todo Normal)

| FECHA | REGION | TIPO_TIENDA | SUCURSAL | SUCURSAL_ID | VENTAS_TOTALES | NUM_TRANSACCIONES | TICKET_PROMEDIO | NUM_CLIENTES | TEMP_C | PRECIP_MM | HUMEDAD | FESTIVO | PROMOCION | DIA_SEMANA | FIN_SEMANA |
|-------|--------|-------------|----------|-------------|----------------|-------------------|-----------------|--------------|--------|-----------|---------|---------|-----------|------------|------------|
| HOY+0 | Norte | MegaPlaza | MegaPlaza Monterrey Centro | 1 | 95,420.00 | 228 | 418.51 | 210 | 28.5 | 0.0 | 42 | No | No | 2 | No |
| HOY+0 | Norte | CompraMax | CompraMax Monterrey San Pedro | 2 | 142,850.00 | 338 | 422.63 | 315 | 28.2 | 0.0 | 40 | No | No | 2 | No |
| HOY+0 | Centro | MegaPlaza | MegaPlaza CDMX Reforma | 6 | 118,240.00 | 282 | 419.43 | 260 | 21.5 | 2.1 | 55 | No | No | 2 | No |
| HOY+0 | Centro | CompraMax | CompraMax CDMX Polanco | 7 | 157,630.00 | 374 | 421.47 | 350 | 21.8 | 1.8 | 53 | No | No | 2 | No |
| HOY+0 | Sur | MegaPlaza | MegaPlaza Guadalajara Zapopan | 10 | 102,340.00 | 244 | 419.43 | 225 | 29.5 | 3.2 | 62 | No | No | 2 | No |

---

## 📅 DÍA 2 - MARTES 🚨 ANOMALÍA 1

| FECHA | REGION | TIPO_TIENDA | SUCURSAL | SUCURSAL_ID | VENTAS_TOTALES | NUM_TRANSACCIONES | TICKET_PROMEDIO | NUM_CLIENTES | TEMP_C | PRECIP_MM | HUMEDAD | Observación |
|-------|--------|-------------|----------|-------------|----------------|-------------------|-----------------|--------------|--------|-----------|---------|-------------|
| HOY+1 | Norte | MegaPlaza | MegaPlaza Monterrey Centro | 1 | 93,280.00 | 223 | 418.30 | 205 | 27.8 | 0.0 | 45 | ✅ Normal |
| HOY+1 | Norte | CompraMax | CompraMax Monterrey San Pedro | 2 | 145,230.00 | 344 | 422.18 | 320 | 27.5 | 0.0 | 43 | ✅ Normal |
| HOY+1 | Centro | MegaPlaza | **MegaPlaza CDMX Reforma** | 6 | **17,736.00** ⬇️ | **56** ⬇️ | 316.71 | 52 | 20.8 | 1.5 | 58 | **🚨 Caída 85%** |
| HOY+1 | Centro | CompraMax | CompraMax CDMX Polanco | 7 | 159,840.00 | 379 | 421.74 | 355 | 20.5 | 2.3 | 56 | ✅ Normal |
| HOY+1 | Sur | MegaPlaza | MegaPlaza Guadalajara Zapopan | 10 | 104,120.00 | 248 | 419.84 | 230 | 30.1 | 2.8 | 60 | ✅ Normal |

**🚨 ANOMALÍA 1:** MegaPlaza CDMX Reforma - Caída del 85% ($118,240 → $17,736)  
**Causa oculta:** Problema con sistema de pagos  
**Z-Score esperado:** > 4.0

---

## 📅 DÍA 3 - MIÉRCOLES 🚨 ANOMALÍAS 1 + 2

| FECHA | REGION | TIPO_TIENDA | SUCURSAL | SUCURSAL_ID | VENTAS_TOTALES | NUM_TRANSACCIONES | TICKET_PROMEDIO | NUM_CLIENTES | TEMP_C | PRECIP_MM | HUMEDAD | Observación |
|-------|--------|-------------|----------|-------------|----------------|-------------------|-----------------|--------------|--------|-----------|---------|-------------|
| HOY+2 | Norte | MegaPlaza | **MegaPlaza Monterrey Centro** | 1 | **37,312.00** ⬇️ | 223 | **167.32** ⬇️⬇️ | 205 | 28.1 | 0.0 | 41 | **🚨 Ticket -60%** |
| HOY+2 | Norte | CompraMax | CompraMax Monterrey San Pedro | 2 | 143,560.00 | 340 | 422.24 | 318 | 28.4 | 0.0 | 44 | ✅ Normal |
| HOY+2 | Centro | MegaPlaza | **MegaPlaza CDMX Reforma** | 6 | **18,943.00** ⬇️ | **60** ⬇️ | 315.72 | 55 | 21.2 | 1.8 | 57 | **🚨 Continúa** |
| HOY+2 | Centro | CompraMax | CompraMax CDMX Polanco | 7 | 161,250.00 | 382 | 422.12 | 358 | 21.0 | 2.0 | 55 | ✅ Normal |
| HOY+2 | Sur | MegaPlaza | MegaPlaza Guadalajara Zapopan | 10 | 103,890.00 | 247 | 420.53 | 228 | 29.8 | 3.5 | 63 | ✅ Normal |

**🚨 ANOMALÍA 2:** MegaPlaza Monterrey - Ticket 60% más bajo ($418 → $167)  
**Causa oculta:** Error en sistema de descuentos  
**Z-Score esperado:** > 3.5

---

## 📅 DÍA 4 - JUEVES 🚨 ANOMALÍA 3

| FECHA | REGION | TIPO_TIENDA | SUCURSAL | SUCURSAL_ID | VENTAS_TOTALES | NUM_TRANSACCIONES | TICKET_PROMEDIO | NUM_CLIENTES | TEMP_C | PRECIP_MM | HUMEDAD | Observación |
|-------|--------|-------------|----------|-------------|----------------|-------------------|-----------------|--------------|--------|-----------|---------|-------------|
| HOY+3 | Norte | MegaPlaza | MegaPlaza Monterrey Centro | 1 | 94,820.00 | 226 | 419.56 | 208 | 27.5 | 0.0 | 46 | ✅ Recuperado |
| HOY+3 | Norte | CompraMax | CompraMax Monterrey San Pedro | 2 | 146,720.00 | 347 | 422.83 | 325 | 27.2 | 0.0 | 42 | ✅ Normal |
| HOY+3 | Centro | MegaPlaza | MegaPlaza CDMX Reforma | 6 | 119,560.00 | 285 | 419.51 | 263 | 22.1 | 1.2 | 54 | ✅ Recuperado |
| HOY+3 | Centro | CompraMax | CompraMax CDMX Polanco | 7 | 158,940.00 | 377 | 421.59 | 352 | 22.3 | 1.5 | 52 | ✅ Normal |
| HOY+3 | Sur | MegaPlaza | **MegaPlaza Guadalajara Zapopan** | 10 | **51,170.00** ⬇️ | **146** ⬇️ | 350.48 | 135 | 28.5 | **65.0** 🌧️ | **85** | **🚨 Caída 50%** |

**🚨 ANOMALÍA 3:** MegaPlaza Guadalajara - Caída del 50% ($102,340 → $51,170)  
**Causa oculta:** Tormenta tropical  
**Z-Score esperado:** > 3.0

---

## 📅 DÍA 5 - VIERNES 🚨 ANOMALÍAS 3 + 4

| FECHA | REGION | TIPO_TIENDA | SUCURSAL | SUCURSAL_ID | VENTAS_TOTALES | NUM_TRANSACCIONES | TICKET_PROMEDIO | NUM_CLIENTES | TEMP_C | PRECIP_MM | HUMEDAD | Observación |
|-------|--------|-------------|----------|-------------|----------------|-------------------|-----------------|--------------|--------|-----------|---------|-------------|
| HOY+4 | Norte | MegaPlaza | **MegaPlaza Monterrey Centro** | 1 | **238,550.00** ⬆️⬆️ | **385** ⬆️ | **619.61** ⬆️ | 356 | 28.8 | 0.0 | 40 | **🚨 Pico +150%** |
| HOY+4 | Norte | CompraMax | CompraMax Monterrey San Pedro | 2 | 168,945.00 | 399 | 423.42 | 373 | 28.5 | 0.0 | 38 | ✅ Normal (promo) |
| HOY+4 | Centro | MegaPlaza | MegaPlaza CDMX Reforma | 6 | 120,840.00 | 288 | 419.58 | 266 | 21.7 | 2.5 | 56 | ✅ Normal |
| HOY+4 | Centro | CompraMax | CompraMax CDMX Polanco | 7 | 160,320.00 | 380 | 421.89 | 355 | 21.5 | 2.1 | 54 | ✅ Normal |
| HOY+4 | Sur | MegaPlaza | **MegaPlaza Guadalajara Zapopan** | 10 | **49,860.00** ⬇️ | **142** ⬇️ | 351.13 | 131 | 29.2 | **65.0** 🌧️ | **88** | **🚨 Continúa** |

**🚨 ANOMALÍA 4:** MegaPlaza Monterrey - Pico del 150% ($95,000 → $238,550)  
**Causa oculta:** Evento corporativo grande no registrado  
**Z-Score esperado:** > 3.5

---

## 📅 DÍA 6 - SÁBADO 🚨 ANOMALÍA 5

| FECHA | REGION | TIPO_TIENDA | SUCURSAL | SUCURSAL_ID | VENTAS_TOTALES | NUM_TRANSACCIONES | TICKET_PROMEDIO | NUM_CLIENTES | TEMP_C | PRECIP_MM | HUMEDAD | Observación |
|-------|--------|-------------|----------|-------------|----------------|-------------------|-----------------|--------------|--------|-----------|---------|-------------|
| HOY+5 | Norte | MegaPlaza | MegaPlaza Monterrey Centro | 1 | 119,275.00 | 284 | 420.12 | 262 | 27.9 | 0.0 | 43 | ✅ Recuperado |
| HOY+5 | Norte | CompraMax | **CompraMax Monterrey San Pedro** | 2 | **358,475.00** ⬆️⬆️ | 342 | **1,048.10** ⬆️⬆️ | 320 | 28.0 | 0.0 | 45 | **🚨 Ticket +150%** |
| HOY+5 | Centro | MegaPlaza | MegaPlaza CDMX Reforma | 6 | 148,800.00 | 354 | 420.34 | 328 | 22.5 | 1.8 | 51 | ✅ Normal |
| HOY+5 | Centro | CompraMax | CompraMax CDMX Polanco | 7 | 197,550.00 | 468 | 422.12 | 438 | 22.0 | 2.2 | 53 | ✅ Normal |
| HOY+5 | Sur | MegaPlaza | MegaPlaza Guadalajara Zapopan | 10 | 127,925.00 | 305 | 419.43 | 282 | 30.5 | 4.2 | 65 | ✅ Recuperado |

**🚨 ANOMALÍA 5:** CompraMax Monterrey - Ticket +150% ($422 → $1,048)  
**Causa oculta:** Compras turísticas masivas (fin de semana largo)  
**Z-Score esperado:** > 4.0

---

## 📅 DÍA 7 - DOMINGO (Todo Normal)

| FECHA | REGION | TIPO_TIENDA | SUCURSAL | SUCURSAL_ID | VENTAS_TOTALES | NUM_TRANSACCIONES | TICKET_PROMEDIO | NUM_CLIENTES | TEMP_C | PRECIP_MM | HUMEDAD | Observación |
|-------|--------|-------------|----------|-------------|----------------|-------------------|-----------------|--------------|--------|-----------|---------|-------------|
| HOY+6 | Norte | MegaPlaza | MegaPlaza Monterrey Centro | 1 | 121,850.00 | 290 | 420.17 | 268 | 28.3 | 0.0 | 41 | ✅ Normal |
| HOY+6 | Norte | CompraMax | CompraMax Monterrey San Pedro | 2 | 181,575.00 | 430 | 422.27 | 402 | 28.7 | 0.0 | 39 | ✅ Recuperado |
| HOY+6 | Centro | MegaPlaza | MegaPlaza CDMX Reforma | 6 | 150,240.00 | 358 | 419.66 | 331 | 21.9 | 2.2 | 55 | ✅ Normal |
| HOY+6 | Centro | CompraMax | CompraMax CDMX Polanco | 7 | 199,620.00 | 473 | 422.03 | 442 | 22.2 | 1.9 | 52 | ✅ Normal |
| HOY+6 | Sur | MegaPlaza | MegaPlaza Guadalajara Zapopan | 10 | 129,350.00 | 308 | 420.13 | 285 | 29.9 | 3.8 | 64 | ✅ Normal |

---

## 📊 Resumen de Anomalías Ocultas

| # | Día | Sucursal | Tipo | Magnitud | Z-Score Esperado | Causa Oculta |
|---|-----|----------|------|----------|------------------|--------------|
| **1** | +1, +2 | MegaPlaza CDMX Reforma | Caída ventas | **-85%** | > 4.0 | Sistema de pagos |
| **2** | +3 | MegaPlaza Monterrey | Ticket bajo | **-60%** | > 3.5 | Error descuentos |
| **3** | +4, +5 | MegaPlaza Guadalajara | Caída ventas | **-50%** | > 3.0 | Tormenta tropical |
| **4** | +5 | MegaPlaza Monterrey | Pico ventas | **+150%** | > 3.5 | Evento corporativo |
| **5** | +6 | CompraMax Monterrey | Ticket alto | **+150%** | > 4.0 | Compras turísticas |

---

## 🎯 Cómo Usar

### 1. Insertar los datos
```sql
-- Ejecutar el archivo:
@DATOS_INFERENCIA_SIMPLE.sql
```

### 2. Verificar inserción
```sql
SELECT COUNT(*) 
FROM MEGAMART_DB.ANALYTICS.VENTAS_DIARIAS
WHERE FECHA >= CURRENT_DATE()
  AND FECHA < DATEADD(DAY, 7, CURRENT_DATE());
-- Debe retornar: 35
```

### 3. Ejecutar detección
```sql
-- Ejecutar las queries de detección del script principal
-- RESULTADO_ANOMALIAS_VENTAS se regenerará con los nuevos datos
```

### 4. Ver anomalías detectadas
```sql
SELECT 
    FECHA,
    SUCURSAL,
    VALOR_REAL,
    MEDIA_ESPERADA,
    ROUND(ANOMALY_SCORE, 2) AS Z_SCORE,
    CLASIFICACION_ANOMALIA,
    DIRECCION_ANOMALIA
FROM MEGAMART_DB.ANALYTICS.RESULTADO_ANOMALIAS_VENTAS
WHERE FECHA >= CURRENT_DATE()
ORDER BY ANOMALY_SCORE DESC;
```

---

## ✅ Validación Esperada

El modelo debería detectar:
- ✅ 5 anomalías principales
- ✅ Clasificación correcta (Alta/Media/Baja)
- ✅ Dirección correcta (Pico/Caída)
- ✅ Z-Score > 2.0 para todas

**Total registros:** 35  
**Anomalías ocultas:** 5 (14.3%)  
**Campos:** 21 columnas (idénticos a VENTAS_DIARIAS)


