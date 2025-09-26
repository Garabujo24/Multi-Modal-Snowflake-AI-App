-- =====================================================
-- ESTRATEGIAS DE MODELOS PREDICTIVOS (CORREGIDAS)
-- TechFlow Solutions - Snowflake Cortex Demo Kit
-- =====================================================
-- ML SQL y Snowpark Python para análisis predictivo
-- Casos de uso: Forecasting, Detección de Anomalías, Clasificación
-- 
-- NOTA: Este archivo ha sido actualizado para usar métodos alternativos
-- cuando las funciones SNOWFLAKE.ML.* no están disponibles:
-- - FORECAST() → Análisis de tendencias lineales
-- - ANOMALY_DETECTION() → Análisis estadístico con Z-scores
-- =====================================================

-- Configuración inicial
USE DATABASE TECHFLOW_DEMO;
USE SCHEMA CORTEX_DEMO;

-- =====================================================
-- 1. PRONÓSTICOS DE VENTAS (FORECASTING)
-- =====================================================

-- A) Preparación de datos históricos para forecasting
CREATE OR REPLACE VIEW VENTAS_HISTORICAS_FORECAST AS
SELECT 
    DATE_TRUNC('MONTH', FECHA_TRANSACCION) AS MES,
    SUM(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100)) AS INGRESOS_MENSUALES,
    COUNT(DISTINCT TRANSACCION_ID) AS NUMERO_TRANSACCIONES,
    COUNT(DISTINCT CLIENTE_ID) AS CLIENTES_ACTIVOS,
    AVG(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100)) AS TICKET_PROMEDIO
FROM TRANSACCIONES 
WHERE ESTADO_PEDIDO = 'COMPLETADO'
  AND FECHA_TRANSACCION >= '2023-01-01'
GROUP BY DATE_TRUNC('MONTH', FECHA_TRANSACCION)
ORDER BY MES;

-- B) Pronóstico de ingresos mensuales usando análisis de tendencias (Simplificado)
CREATE OR REPLACE TABLE PRONOSTICO_VENTAS AS
WITH datos_historicos AS (
    SELECT 
        MES,
        INGRESOS_MENSUALES,
        ROW_NUMBER() OVER (ORDER BY MES) AS periodo_numero
    FROM VENTAS_HISTORICAS_FORECAST
),
estadisticas_base AS (
    SELECT 
        AVG(INGRESOS_MENSUALES) AS promedio_general,
        AVG(periodo_numero) AS promedio_periodo,
        COUNT(*) AS total_registros
    FROM datos_historicos
),
calculos_regresion AS (
    SELECT 
        dh.MES,
        dh.INGRESOS_MENSUALES,
        dh.periodo_numero,
        eb.promedio_general,
        eb.promedio_periodo,
        -- Calcular pendiente de regresión lineal
        SUM((dh.periodo_numero - eb.promedio_periodo) * (dh.INGRESOS_MENSUALES - eb.promedio_general)) 
        OVER () / NULLIF(SUM(POWER(dh.periodo_numero - eb.promedio_periodo, 2)) OVER (), 0) AS pendiente,
        -- Media móvil simple
        AVG(dh.INGRESOS_MENSUALES) OVER (
            ORDER BY dh.MES 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS media_movil_3
    FROM datos_historicos dh
    CROSS JOIN estadisticas_base eb
)
SELECT 
    MES,
    INGRESOS_MENSUALES AS INGRESOS_REALES,
    -- Pronóstico basado en regresión lineal
    OBJECT_CONSTRUCT(
        'forecast', ROUND(promedio_general + pendiente * periodo_numero, 2),
        'trend_forecast', ROUND(media_movil_3 + (pendiente * 0.8), 2),
        'lower_bound', ROUND((promedio_general + pendiente * periodo_numero) * 0.85, 2),
        'upper_bound', ROUND((promedio_general + pendiente * periodo_numero) * 1.15, 2),
        'confidence_interval', 0.95,
        'method', 'Linear Regression Analysis'
    ) AS PRONOSTICO_INGRESOS
FROM calculos_regresion;

-- C) Pronóstico por segmento de cliente
CREATE OR REPLACE VIEW VENTAS_POR_SEGMENTO AS
SELECT 
    DATE_TRUNC('MONTH', t.FECHA_TRANSACCION) AS MES,
    c.SEGMENTO,
    SUM(t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100)) AS INGRESOS_SEGMENTO,
    COUNT(DISTINCT t.CLIENTE_ID) AS CLIENTES_ACTIVOS_SEGMENTO
FROM TRANSACCIONES t
JOIN CLIENTES c ON t.CLIENTE_ID = c.CLIENTE_ID
WHERE t.ESTADO_PEDIDO = 'COMPLETADO'
  AND t.FECHA_TRANSACCION >= '2023-01-01'
GROUP BY DATE_TRUNC('MONTH', t.FECHA_TRANSACCION), c.SEGMENTO
ORDER BY MES, SEGMENTO;

-- Crear tabla con pronósticos por segmento (Simplificado para evitar funciones anidadas)
CREATE OR REPLACE TABLE PRONOSTICO_POR_SEGMENTO AS
WITH datos_por_segmento AS (
    SELECT 
        MES,
        SEGMENTO,
        INGRESOS_SEGMENTO,
        ROW_NUMBER() OVER (PARTITION BY SEGMENTO ORDER BY MES) AS periodo_numero
    FROM VENTAS_POR_SEGMENTO
),
estadisticas_por_segmento AS (
    SELECT 
        SEGMENTO,
        AVG(INGRESOS_SEGMENTO) AS promedio_segmento,
        AVG(periodo_numero) AS promedio_periodo_segmento,
        COUNT(*) AS total_registros_segmento
    FROM datos_por_segmento
    GROUP BY SEGMENTO
),
calculos_por_segmento AS (
    SELECT 
        dps.MES,
        dps.SEGMENTO,
        dps.INGRESOS_SEGMENTO,
        dps.periodo_numero,
        eps.promedio_segmento,
        eps.promedio_periodo_segmento,
        -- Calcular pendiente por segmento usando agregación
        SUM((dps.periodo_numero - eps.promedio_periodo_segmento) * 
            (dps.INGRESOS_SEGMENTO - eps.promedio_segmento)) 
        OVER (PARTITION BY dps.SEGMENTO) / 
        NULLIF(SUM(POWER(dps.periodo_numero - eps.promedio_periodo_segmento, 2)) 
               OVER (PARTITION BY dps.SEGMENTO), 0) AS pendiente_segmento,
        -- Media móvil por segmento
        AVG(dps.INGRESOS_SEGMENTO) OVER (
            PARTITION BY dps.SEGMENTO 
            ORDER BY dps.MES 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS media_movil_segmento
    FROM datos_por_segmento dps
    JOIN estadisticas_por_segmento eps ON dps.SEGMENTO = eps.SEGMENTO
)
SELECT 
    MES,
    SEGMENTO,
    INGRESOS_SEGMENTO AS INGRESOS_REALES,
    OBJECT_CONSTRUCT(
        'forecast', ROUND(promedio_segmento + pendiente_segmento * periodo_numero, 2),
        'trend_forecast', ROUND(media_movil_segmento + (pendiente_segmento * 0.8), 2),
        'lower_bound', ROUND((promedio_segmento + pendiente_segmento * periodo_numero) * 0.9, 2),
        'upper_bound', ROUND((promedio_segmento + pendiente_segmento * periodo_numero) * 1.1, 2),
        'confidence_interval', 0.90,
        'method', 'Segment Regression Analysis'
    ) AS PRONOSTICO_INGRESOS
FROM calculos_por_segmento
ORDER BY SEGMENTO, MES;

-- D) Pronóstico de demanda por producto
CREATE OR REPLACE VIEW DEMANDA_PRODUCTOS AS
SELECT 
    DATE_TRUNC('MONTH', t.FECHA_TRANSACCION) AS MES,
    p.PRODUCTO_ID,
    p.NOMBRE AS PRODUCTO_NOMBRE,
    p.CATEGORIA,
    SUM(t.CANTIDAD) AS CANTIDAD_VENDIDA,
    COUNT(DISTINCT t.CLIENTE_ID) AS CLIENTES_UNICOS_PRODUCTO
FROM TRANSACCIONES t
JOIN PRODUCTOS p ON t.PRODUCTO_ID = p.PRODUCTO_ID
WHERE t.ESTADO_PEDIDO = 'COMPLETADO'
  AND t.FECHA_TRANSACCION >= '2023-01-01'
GROUP BY DATE_TRUNC('MONTH', t.FECHA_TRANSACCION), p.PRODUCTO_ID, p.NOMBRE, p.CATEGORIA
ORDER BY MES, PRODUCTO_ID;

-- =====================================================
-- 2. DETECCIÓN DE ANOMALÍAS
-- =====================================================

-- A) Detección de transacciones anómalas usando análisis estadístico
CREATE OR REPLACE TABLE ANOMALIAS_TRANSACCIONES AS
WITH estadisticas_base AS (
    SELECT 
        CANAL_VENTA,
        REGION,
        AVG(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100)) AS promedio_valor,
        STDDEV(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100)) AS desviacion_valor,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100)) AS percentil_95,
        PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100)) AS percentil_05
    FROM TRANSACCIONES
    WHERE ESTADO_PEDIDO = 'COMPLETADO'
      AND FECHA_TRANSACCION >= '2023-01-01'
    GROUP BY CANAL_VENTA, REGION
),
calculos_anomalia AS (
    SELECT 
        t.TRANSACCION_ID,
        t.FECHA_TRANSACCION,
        t.CLIENTE_ID,
        t.PRODUCTO_ID,
        t.CANTIDAD,
        t.PRECIO_UNITARIO,
        (t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100)) AS VALOR_TRANSACCION,
        t.CANAL_VENTA,
        t.REGION,
        eb.promedio_valor,
        eb.desviacion_valor,
        eb.percentil_95,
        eb.percentil_05,
        -- Calcular z-score
        ABS((t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100)) - eb.promedio_valor) / 
        NULLIF(eb.desviacion_valor, 0) AS z_score,
        -- Determinar si está fuera de rango normal
        CASE 
            WHEN (t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100)) > eb.percentil_95 THEN 1
            WHEN (t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100)) < eb.percentil_05 THEN 1
            ELSE 0
        END AS fuera_percentiles
    FROM TRANSACCIONES t
    JOIN estadisticas_base eb ON t.CANAL_VENTA = eb.CANAL_VENTA AND t.REGION = eb.REGION
    WHERE t.ESTADO_PEDIDO = 'COMPLETADO'
      AND t.FECHA_TRANSACCION >= '2024-01-01'
)
SELECT 
    TRANSACCION_ID,
    FECHA_TRANSACCION,
    CLIENTE_ID,
    PRODUCTO_ID,
    CANTIDAD,
    PRECIO_UNITARIO,
    VALOR_TRANSACCION,
    CANAL_VENTA,
    REGION,
    -- Calcular score de anomalía combinado (0-1)
    LEAST(1.0, GREATEST(0.0, 
        (z_score / 3.0) + -- Z-score normalizado
        (fuera_percentiles * 0.3) + -- Boost si está fuera de percentiles
        (CASE WHEN VALOR_TRANSACCION > promedio_valor * 5 THEN 0.4 ELSE 0 END) -- Boost para valores extremos
    )) AS ANOMALY_SCORE
FROM calculos_anomalia;

-- B) Identificar transacciones con scores de anomalía altos
CREATE OR REPLACE VIEW TRANSACCIONES_SOSPECHOSAS AS
SELECT 
    *,
    CASE 
        WHEN ANOMALY_SCORE > 0.8 THEN 'ALTA ANOMALÍA'
        WHEN ANOMALY_SCORE > 0.6 THEN 'ANOMALÍA MODERADA'
        WHEN ANOMALY_SCORE > 0.4 THEN 'ANOMALÍA LEVE'
        ELSE 'NORMAL'
    END AS NIVEL_ANOMALIA
FROM ANOMALIAS_TRANSACCIONES
WHERE ANOMALY_SCORE > 0.4
ORDER BY ANOMALY_SCORE DESC;

-- C) Detección de anomalías en tickets de soporte usando análisis estadístico
CREATE OR REPLACE TABLE ANOMALIAS_SOPORTE AS
WITH estadisticas_soporte AS (
    SELECT 
        TIPO_PROBLEMA,
        PRIORIDAD,
        AVG(TIEMPO_RESOLUCION_HORAS) AS promedio_tiempo,
        STDDEV(TIEMPO_RESOLUCION_HORAS) AS desviacion_tiempo,
        AVG(SATISFACCION_CLIENTE) AS promedio_satisfaccion,
        STDDEV(SATISFACCION_CLIENTE) AS desviacion_satisfaccion,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY TIEMPO_RESOLUCION_HORAS) AS percentil_95_tiempo,
        PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY SATISFACCION_CLIENTE) AS percentil_05_satisfaccion
    FROM TICKETS_SOPORTE
    WHERE ESTADO = 'RESUELTO'
      AND TIEMPO_RESOLUCION_HORAS IS NOT NULL
      AND SATISFACCION_CLIENTE IS NOT NULL
    GROUP BY TIPO_PROBLEMA, PRIORIDAD
),
calculos_anomalias_soporte AS (
    SELECT 
        ts.TICKET_ID,
        ts.FECHA_CREACION,
        ts.CLIENTE_ID,
        ts.PRODUCTO_ID,
        ts.TIPO_PROBLEMA,
        ts.PRIORIDAD,
        ts.TIEMPO_RESOLUCION_HORAS,
        ts.SATISFACCION_CLIENTE,
        es.promedio_tiempo,
        es.desviacion_tiempo,
        es.promedio_satisfaccion,
        es.desviacion_satisfaccion,
        -- Z-scores para tiempo de resolución
        ABS(ts.TIEMPO_RESOLUCION_HORAS - es.promedio_tiempo) / NULLIF(es.desviacion_tiempo, 0) AS z_score_tiempo,
        -- Z-scores para satisfacción
        ABS(ts.SATISFACCION_CLIENTE - es.promedio_satisfaccion) / NULLIF(es.desviacion_satisfaccion, 0) AS z_score_satisfaccion,
        -- Anomalías por umbral
        CASE WHEN ts.TIEMPO_RESOLUCION_HORAS > es.percentil_95_tiempo THEN 1 ELSE 0 END AS tiempo_anomalo,
        CASE WHEN ts.SATISFACCION_CLIENTE < es.percentil_05_satisfaccion THEN 1 ELSE 0 END AS satisfaccion_anomala
    FROM TICKETS_SOPORTE ts
    JOIN estadisticas_soporte es ON ts.TIPO_PROBLEMA = es.TIPO_PROBLEMA AND ts.PRIORIDAD = es.PRIORIDAD
    WHERE ts.ESTADO = 'RESUELTO'
      AND ts.TIEMPO_RESOLUCION_HORAS IS NOT NULL
      AND ts.SATISFACCION_CLIENTE IS NOT NULL
)
SELECT 
    TICKET_ID,
    FECHA_CREACION,
    CLIENTE_ID,
    PRODUCTO_ID,
    TIPO_PROBLEMA,
    PRIORIDAD,
    TIEMPO_RESOLUCION_HORAS,
    SATISFACCION_CLIENTE,
    -- Score de anomalía para tiempo de resolución (0-1)
    LEAST(1.0, GREATEST(0.0, 
        (z_score_tiempo / 3.0) + (tiempo_anomalo * 0.3)
    )) AS ANOMALY_SCORE_TIEMPO,
    -- Score de anomalía para satisfacción (0-1)
    LEAST(1.0, GREATEST(0.0, 
        (z_score_satisfaccion / 2.0) + (satisfaccion_anomala * 0.4)
    )) AS ANOMALY_SCORE_SATISFACCION
FROM calculos_anomalias_soporte;

-- D) Detección de patrones anómalos en campañas de marketing
CREATE OR REPLACE VIEW ANOMALIAS_MARKETING AS
SELECT 
    CAMPANA_ID,
    NOMBRE,
    PRESUPUESTO,
    LEADS_GENERADOS,
    CONVERSIONES,
    ROI_CALCULADO,
    (CONVERSIONES::FLOAT / NULLIF(LEADS_GENERADOS, 0)) * 100 AS TASA_CONVERSION,
    PRESUPUESTO / NULLIF(LEADS_GENERADOS, 0) AS COSTO_POR_LEAD,
    CASE 
        WHEN ROI_CALCULADO > 5.0 THEN 'ROI EXCEPCIONALMENTE ALTO'
        WHEN ROI_CALCULADO < 1.0 THEN 'ROI BAJO - INVESTIGAR'
        WHEN (CONVERSIONES::FLOAT / NULLIF(LEADS_GENERADOS, 0)) > 0.15 THEN 'CONVERSION EXCEPCIONAL'
        WHEN (CONVERSIONES::FLOAT / NULLIF(LEADS_GENERADOS, 0)) < 0.03 THEN 'CONVERSION BAJA'
        ELSE 'RENDIMIENTO NORMAL'
    END AS EVALUACION_RENDIMIENTO
FROM CAMPANAS_MARKETING
WHERE LEADS_GENERADOS > 0
ORDER BY ROI_CALCULADO DESC;

-- =====================================================
-- 3. ANÁLISIS PREDICTIVO AVANZADO CON SNOWPARK PYTHON
-- =====================================================

-- A) Configuración para Snowpark Python
-- Crear stage para archivos Python
CREATE OR REPLACE STAGE ML_PYTHON_STAGE
URL = 's3://techflow-cortex-demo/ml-models/'
CREDENTIALS = (AWS_KEY_ID = 'AKIA...' AWS_SECRET_KEY = '...');

-- B) Función Python para análisis de churn de clientes
CREATE OR REPLACE FUNCTION ANALYZE_CUSTOMER_CHURN(cliente_features VARIANT)
RETURNS VARIANT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('scikit-learn', 'pandas', 'numpy')
HANDLER = 'analyze_churn'
AS $$
import json
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler

def analyze_churn(cliente_features):
    """
    Analiza la probabilidad de churn basado en características del cliente
    """
    # Simular modelo preentrenado (en producción se cargaría desde stage)
    features = json.loads(cliente_features)
    
    # Características de entrada esperadas
    feature_vector = [
        features.get('total_transacciones', 0),
        features.get('valor_total_cliente', 0),
        features.get('dias_desde_ultima_compra', 0),
        features.get('tickets_soporte_total', 0),
        features.get('satisfaccion_promedio', 5.0),
        features.get('productos_distintos', 0),
        1 if features.get('segmento') == 'Enterprise' else 0,
        1 if features.get('segmento') == 'Mid-Market' else 0
    ]
    
    # Simular predicción (en producción usaría modelo real)
    # Score más alto = mayor probabilidad de churn
    churn_score = min(max(
        0.1 + 
        (0.3 if features.get('dias_desde_ultima_compra', 0) > 180 else 0) +
        (0.2 if features.get('satisfaccion_promedio', 5.0) < 3.0 else 0) +
        (0.15 if features.get('tickets_soporte_total', 0) > 10 else 0) +
        (0.1 if features.get('total_transacciones', 0) < 3 else 0)
    , 0), 1)
    
    # Clasificación de riesgo
    if churn_score > 0.7:
        risk_level = 'ALTO'
        recommendation = 'Contacto inmediato del Customer Success Manager'
    elif churn_score > 0.4:
        risk_level = 'MEDIO'
        recommendation = 'Programa de retención proactiva'
    else:
        risk_level = 'BAJO'
        recommendation = 'Monitoreo estándar'
    
    return {
        'churn_probability': round(churn_score, 3),
        'risk_level': risk_level,
        'recommendation': recommendation,
        'features_importance': {
            'dias_inactividad': 0.3,
            'satisfaccion': 0.25,
            'tickets_soporte': 0.2,
            'frecuencia_compras': 0.15,
            'valor_cliente': 0.1
        }
    }
$$;

-- C) Vista para análisis de churn de clientes
CREATE OR REPLACE VIEW ANALISIS_CHURN_CLIENTES AS
SELECT 
    c.CLIENTE_ID,
    c.NOMBRE,
    c.SEGMENTO,
    c.REGION_GEOGRAFICA,
    
    -- Características para el modelo
    COUNT(t.TRANSACCION_ID) AS TOTAL_TRANSACCIONES,
    COALESCE(SUM(t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100)), 0) AS VALOR_TOTAL_CLIENTE,
    COALESCE(DATEDIFF('day', MAX(t.FECHA_TRANSACCION), CURRENT_DATE()), 365) AS DIAS_DESDE_ULTIMA_COMPRA,
    COUNT(ts.TICKET_ID) AS TICKETS_SOPORTE_TOTAL,
    COALESCE(AVG(ts.SATISFACCION_CLIENTE), 5.0) AS SATISFACCION_PROMEDIO,
    COUNT(DISTINCT t.PRODUCTO_ID) AS PRODUCTOS_DISTINTOS,
    
    -- Aplicar función de análisis de churn
    ANALYZE_CUSTOMER_CHURN(
        OBJECT_CONSTRUCT(
            'total_transacciones', COUNT(t.TRANSACCION_ID),
            'valor_total_cliente', COALESCE(SUM(t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100)), 0),
            'dias_desde_ultima_compra', COALESCE(DATEDIFF('day', MAX(t.FECHA_TRANSACCION), CURRENT_DATE()), 365),
            'tickets_soporte_total', COUNT(ts.TICKET_ID),
            'satisfaccion_promedio', COALESCE(AVG(ts.SATISFACCION_CLIENTE), 5.0),
            'productos_distintos', COUNT(DISTINCT t.PRODUCTO_ID),
            'segmento', c.SEGMENTO
        )
    ) AS CHURN_ANALYSIS

FROM CLIENTES c
LEFT JOIN TRANSACCIONES t ON c.CLIENTE_ID = t.CLIENTE_ID AND t.ESTADO_PEDIDO = 'COMPLETADO'
LEFT JOIN TICKETS_SOPORTE ts ON c.CLIENTE_ID = ts.CLIENTE_ID AND ts.ESTADO = 'RESUELTO'
GROUP BY c.CLIENTE_ID, c.NOMBRE, c.SEGMENTO, c.REGION_GEOGRAFICA;

-- D) Función para predicción de valor de vida del cliente (CLV)
CREATE OR REPLACE FUNCTION PREDICT_CUSTOMER_LTV(historical_data VARIANT)
RETURNS VARIANT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('scikit-learn', 'pandas', 'numpy')
HANDLER = 'predict_ltv'
AS $$
import json
import numpy as np

def predict_ltv(historical_data):
    """
    Predice el valor de vida del cliente basado en datos históricos
    """
    data = json.loads(historical_data)
    
    # Características del cliente
    monthly_revenue = data.get('ingresos_mensuales_promedio', 0)
    tenure_months = data.get('meses_como_cliente', 1)
    growth_rate = data.get('tasa_crecimiento_mensual', 0)
    churn_probability = data.get('probabilidad_churn', 0.1)
    
    # Calcular tasa de retención
    retention_rate = 1 - churn_probability
    
    # Predicción de meses restantes como cliente
    if retention_rate > 0:
        expected_lifetime_months = 1 / churn_probability if churn_probability > 0 else 60
    else:
        expected_lifetime_months = 1
    
    # Proyección de crecimiento
    future_monthly_value = monthly_revenue * (1 + growth_rate) ** min(expected_lifetime_months / 12, 5)
    
    # Cálculo de CLV
    predicted_ltv = future_monthly_value * expected_lifetime_months * retention_rate
    
    # Segmentación de valor
    if predicted_ltv > 50000:
        value_segment = 'PREMIUM'
        strategy = 'Dedicar Customer Success Manager exclusivo'
    elif predicted_ltv > 20000:
        value_segment = 'HIGH_VALUE'
        strategy = 'Programa de upselling personalizado'
    elif predicted_ltv > 5000:
        value_segment = 'STANDARD'
        strategy = 'Marketing automation dirigido'
    else:
        value_segment = 'LOW_VALUE'
        strategy = 'Eficiencia operacional'
    
    return {
        'predicted_ltv': round(predicted_ltv, 2),
        'expected_lifetime_months': round(expected_lifetime_months, 1),
        'future_monthly_value': round(future_monthly_value, 2),
        'value_segment': value_segment,
        'retention_strategy': strategy,
        'confidence_score': min(0.9, retention_rate + 0.1)
    }
$$;

-- =====================================================
-- 4. ANÁLISIS DE SERIES TEMPORALES AVANZADO
-- =====================================================

-- A) Análisis de estacionalidad en ventas
CREATE OR REPLACE VIEW ANALISIS_ESTACIONALIDAD AS
SELECT 
    EXTRACT(MONTH FROM FECHA_TRANSACCION) AS MES_NUMERO,
    MONTHNAME(FECHA_TRANSACCION) AS MES_NOMBRE,
    EXTRACT(QUARTER FROM FECHA_TRANSACCION) AS TRIMESTRE,
    EXTRACT(YEAR FROM FECHA_TRANSACCION) AS ANO,
    
    COUNT(*) AS NUMERO_TRANSACCIONES,
    SUM(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100)) AS INGRESOS_TOTALES,
    AVG(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100)) AS TICKET_PROMEDIO,
    
    -- Cálculo de índices estacionales
    AVG(SUM(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100))) 
        OVER (PARTITION BY EXTRACT(MONTH FROM FECHA_TRANSACCION)) AS PROMEDIO_MENSUAL,
    AVG(SUM(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100))) 
        OVER () AS PROMEDIO_GENERAL,
    
    (AVG(SUM(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100))) 
        OVER (PARTITION BY EXTRACT(MONTH FROM FECHA_TRANSACCION)) /
     AVG(SUM(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100))) 
        OVER ()) * 100 AS INDICE_ESTACIONAL
        
FROM TRANSACCIONES
WHERE ESTADO_PEDIDO = 'COMPLETADO'
  AND FECHA_TRANSACCION >= '2023-01-01'
GROUP BY EXTRACT(MONTH FROM FECHA_TRANSACCION), MONTHNAME(FECHA_TRANSACCION), 
         EXTRACT(QUARTER FROM FECHA_TRANSACCION), EXTRACT(YEAR FROM FECHA_TRANSACCION)
ORDER BY MES_NUMERO;

-- B) Detección de tendencias por producto
CREATE OR REPLACE VIEW TENDENCIAS_PRODUCTOS AS
SELECT 
    p.PRODUCTO_ID,
    p.NOMBRE,
    p.CATEGORIA,
    
    -- Métricas de tendencia (últimos 6 meses vs 6 meses anteriores)
    SUM(CASE WHEN t.FECHA_TRANSACCION >= DATEADD('month', -6, CURRENT_DATE()) 
             THEN t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100) 
             ELSE 0 END) AS INGRESOS_ULTIMOS_6M,
             
    SUM(CASE WHEN t.FECHA_TRANSACCION >= DATEADD('month', -12, CURRENT_DATE()) 
                  AND t.FECHA_TRANSACCION < DATEADD('month', -6, CURRENT_DATE())
             THEN t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100) 
             ELSE 0 END) AS INGRESOS_6M_ANTERIORES,
    
    -- Cálculo de crecimiento
    CASE 
        WHEN SUM(CASE WHEN t.FECHA_TRANSACCION >= DATEADD('month', -12, CURRENT_DATE()) 
                           AND t.FECHA_TRANSACCION < DATEADD('month', -6, CURRENT_DATE())
                      THEN t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100) 
                      ELSE 0 END) > 0
        THEN ((SUM(CASE WHEN t.FECHA_TRANSACCION >= DATEADD('month', -6, CURRENT_DATE()) 
                        THEN t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100) 
                        ELSE 0 END) / 
               SUM(CASE WHEN t.FECHA_TRANSACCION >= DATEADD('month', -12, CURRENT_DATE()) 
                            AND t.FECHA_TRANSACCION < DATEADD('month', -6, CURRENT_DATE())
                        THEN t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100) 
                        ELSE 0 END)) - 1) * 100
        ELSE NULL
    END AS PORCENTAJE_CRECIMIENTO,
    
    -- Clasificación de tendencia
    CASE 
        WHEN ((SUM(CASE WHEN t.FECHA_TRANSACCION >= DATEADD('month', -6, CURRENT_DATE()) 
                        THEN t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100) 
                        ELSE 0 END) / 
               NULLIF(SUM(CASE WHEN t.FECHA_TRANSACCION >= DATEADD('month', -12, CURRENT_DATE()) 
                                AND t.FECHA_TRANSACCION < DATEADD('month', -6, CURRENT_DATE())
                            THEN t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100) 
                            ELSE 0 END), 0)) - 1) * 100 > 20 THEN 'CRECIMIENTO FUERTE'
        WHEN ((SUM(CASE WHEN t.FECHA_TRANSACCION >= DATEADD('month', -6, CURRENT_DATE()) 
                        THEN t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100) 
                        ELSE 0 END) / 
               NULLIF(SUM(CASE WHEN t.FECHA_TRANSACCION >= DATEADD('month', -12, CURRENT_DATE()) 
                                AND t.FECHA_TRANSACCION < DATEADD('month', -6, CURRENT_DATE())
                            THEN t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100) 
                            ELSE 0 END), 0)) - 1) * 100 > 5 THEN 'CRECIMIENTO MODERADO'
        WHEN ((SUM(CASE WHEN t.FECHA_TRANSACCION >= DATEADD('month', -6, CURRENT_DATE()) 
                        THEN t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100) 
                        ELSE 0 END) / 
               NULLIF(SUM(CASE WHEN t.FECHA_TRANSACCION >= DATEADD('month', -12, CURRENT_DATE()) 
                                AND t.FECHA_TRANSACCION < DATEADD('month', -6, CURRENT_DATE())
                            THEN t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100) 
                            ELSE 0 END), 0)) - 1) * 100 > -5 THEN 'ESTABLE'
        WHEN ((SUM(CASE WHEN t.FECHA_TRANSACCION >= DATEADD('month', -6, CURRENT_DATE()) 
                        THEN t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100) 
                        ELSE 0 END) / 
               NULLIF(SUM(CASE WHEN t.FECHA_TRANSACCION >= DATEADD('month', -12, CURRENT_DATE()) 
                                AND t.FECHA_TRANSACCION < DATEADD('month', -6, CURRENT_DATE())
                            THEN t.CANTIDAD * t.PRECIO_UNITARIO * (1 - t.DESCUENTO_APLICADO/100) 
                            ELSE 0 END), 0)) - 1) * 100 > -20 THEN 'DECLIVE MODERADO'
        ELSE 'DECLIVE FUERTE'
    END AS CLASIFICACION_TENDENCIA

FROM PRODUCTOS p
LEFT JOIN TRANSACCIONES t ON p.PRODUCTO_ID = t.PRODUCTO_ID 
    AND t.ESTADO_PEDIDO = 'COMPLETADO'
    AND t.FECHA_TRANSACCION >= DATEADD('month', -12, CURRENT_DATE())
GROUP BY p.PRODUCTO_ID, p.NOMBRE, p.CATEGORIA
ORDER BY PORCENTAJE_CRECIMIENTO DESC NULLS LAST;

-- =====================================================
-- 5. ALERTAS Y MONITOREO AUTOMATIZADO
-- =====================================================

-- A) Procedimiento para alertas de anomalías
CREATE OR REPLACE PROCEDURE GENERAR_ALERTAS_ANOMALIAS()
RETURNS VARCHAR
LANGUAGE SQL
AS $$
DECLARE
    alertas_generadas INT DEFAULT 0;
BEGIN
    
    -- Crear tabla de alertas si no existe
    CREATE TABLE IF NOT EXISTS ALERTAS_SISTEMA (
        ALERTA_ID VARCHAR(50),
        FECHA_ALERTA TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
        TIPO_ALERTA VARCHAR(50),
        SEVERIDAD VARCHAR(20),
        DESCRIPCION VARCHAR(500),
        ENTIDAD_AFECTADA VARCHAR(100),
        ESTADO_ALERTA VARCHAR(20) DEFAULT 'NUEVA',
        DATOS_CONTEXTO VARIANT
    );
    
    -- Alertas por transacciones anómalas
    INSERT INTO ALERTAS_SISTEMA (ALERTA_ID, TIPO_ALERTA, SEVERIDAD, DESCRIPCION, ENTIDAD_AFECTADA, DATOS_CONTEXTO)
    SELECT 
        'ANOMALY_TXN_' || TRANSACCION_ID || '_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'),
        'TRANSACCION_ANOMALA',
        CASE WHEN ANOMALY_SCORE > 0.8 THEN 'CRITICA' 
             WHEN ANOMALY_SCORE > 0.6 THEN 'ALTA' 
             ELSE 'MEDIA' END,
        'Transacción con comportamiento anómalo detectado - Score: ' || ROUND(ANOMALY_SCORE, 3),
        TRANSACCION_ID,
        OBJECT_CONSTRUCT(
            'cliente_id', CLIENTE_ID,
            'valor_transaccion', VALOR_TRANSACCION,
            'anomaly_score', ANOMALY_SCORE,
            'canal_venta', CANAL_VENTA
        )
    FROM TRANSACCIONES_SOSPECHOSAS
    WHERE NIVEL_ANOMALIA IN ('ALTA ANOMALÍA', 'ANOMALÍA MODERADA')
      AND FECHA_TRANSACCION >= DATEADD('day', -1, CURRENT_TIMESTAMP());
    
    GET DIAGNOSTICS alertas_generadas = ROW_COUNT;
    
    -- Alertas por clientes en riesgo de churn
    INSERT INTO ALERTAS_SISTEMA (ALERTA_ID, TIPO_ALERTA, SEVERIDAD, DESCRIPCION, ENTIDAD_AFECTADA, DATOS_CONTEXTO)
    SELECT 
        'CHURN_RISK_' || CLIENTE_ID || '_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'),
        'RIESGO_CHURN',
        'ALTA',
        'Cliente con alto riesgo de churn - Probabilidad: ' || 
        (CHURN_ANALYSIS:churn_probability::VARCHAR),
        CLIENTE_ID,
        CHURN_ANALYSIS
    FROM ANALISIS_CHURN_CLIENTES
    WHERE CHURN_ANALYSIS:risk_level::VARCHAR = 'ALTO'
      AND VALOR_TOTAL_CLIENTE > 10000; -- Solo alertar para clientes valiosos
    
    GET DIAGNOSTICS alertas_generadas = alertas_generadas + ROW_COUNT;
    
    RETURN 'Generadas ' || alertas_generadas || ' alertas nuevas';
END;
$$;

-- B) Vista de dashboard ejecutivo con KPIs predictivos
CREATE OR REPLACE VIEW DASHBOARD_EJECUTIVO_PREDICTIVO AS
SELECT 
    -- Métricas actuales
    (SELECT COUNT(*) FROM TRANSACCIONES WHERE ESTADO_PEDIDO = 'COMPLETADO' 
     AND DATE_TRUNC('month', FECHA_TRANSACCION) = DATE_TRUNC('month', CURRENT_DATE())) AS TRANSACCIONES_MES_ACTUAL,
     
    (SELECT SUM(CANTIDAD * PRECIO_UNITARIO * (1 - DESCUENTO_APLICADO/100)) FROM TRANSACCIONES 
     WHERE ESTADO_PEDIDO = 'COMPLETADO' 
     AND DATE_TRUNC('month', FECHA_TRANSACCION) = DATE_TRUNC('month', CURRENT_DATE())) AS INGRESOS_MES_ACTUAL,
    
    -- Predicciones
    (SELECT AVG(PRONOSTICO_INGRESOS:forecast::FLOAT) FROM PRONOSTICO_VENTAS 
     WHERE MES = DATEADD('month', 1, DATE_TRUNC('month', CURRENT_DATE()))) AS PRONOSTICO_PROXIMO_MES,
    
    -- Alertas activas
    (SELECT COUNT(*) FROM ALERTAS_SISTEMA WHERE ESTADO_ALERTA = 'NUEVA') AS ALERTAS_PENDIENTES,
    
    -- Clientes en riesgo
    (SELECT COUNT(*) FROM ANALISIS_CHURN_CLIENTES 
     WHERE CHURN_ANALYSIS:risk_level::VARCHAR = 'ALTO') AS CLIENTES_RIESGO_CHURN,
    
    -- Anomalías detectadas (últimas 24h)
    (SELECT COUNT(*) FROM TRANSACCIONES_SOSPECHOSAS 
     WHERE FECHA_TRANSACCION >= DATEADD('day', -1, CURRENT_TIMESTAMP())) AS ANOMALIAS_RECIENTES,
    
    -- Tendencia general
    (SELECT AVG(PORCENTAJE_CRECIMIENTO) FROM TENDENCIAS_PRODUCTOS 
     WHERE PORCENTAJE_CRECIMIENTO IS NOT NULL) AS CRECIMIENTO_PROMEDIO_PRODUCTOS;

-- =====================================================
-- CONSULTAS DE VALIDACIÓN Y TESTING
-- =====================================================

-- Verificar que las funciones ML están funcionando
SELECT 'Forecast Table' AS TEST, COUNT(*) AS RECORDS FROM PRONOSTICO_VENTAS;
SELECT 'Anomalies Table' AS TEST, COUNT(*) AS RECORDS FROM ANOMALIAS_TRANSACCIONES;
SELECT 'Churn Analysis' AS TEST, COUNT(*) AS RECORDS FROM ANALISIS_CHURN_CLIENTES;
SELECT 'Trends Analysis' AS TEST, COUNT(*) AS RECORDS FROM TENDENCIAS_PRODUCTOS;

-- Ejecutar procedimiento de alertas
CALL GENERAR_ALERTAS_ANOMALIAS();

-- Ver dashboard ejecutivo
SELECT * FROM DASHBOARD_EJECUTIVO_PREDICTIVO;

-- =====================================================
-- FIN DE ESTRATEGIAS ML PREDICTIVO
-- =====================================================

