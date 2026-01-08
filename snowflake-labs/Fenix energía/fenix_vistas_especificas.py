"""
Código Python para crear 4 vistas específicas e interesantes 
sobre los datos de Fénix Energía

Vistas Creadas:
1. Vista de Alertas Energéticas
2. Vista de Rentabilidad por Segmento  
3. Vista de Predicción de Demanda
4. Vista de Eficiencia Operacional

Autor: Generado para análisis energético de Fénix Energía
"""

import snowflake.connector
import pandas as pd
from datetime import datetime
import os
from typing import Dict, Optional

class FenixVistasEspecificas:
    """
    Clase para crear vistas específicas e interesantes sobre los datos de Fénix Energía
    """
    
    def __init__(self, connection_params: Dict[str, str]):
        """
        Inicializa la clase con parámetros de conexión
        """
        self.connection_params = connection_params
        self.database = "FENIX_DB"
        self.schema = "FENIX_ENERGY_SCHEMA"
        self.full_schema = f"{self.database}.{self.schema}"
        
    def connect(self):
        """Establece conexión con Snowflake"""
        try:
            self.conn = snowflake.connector.connect(**self.connection_params)
            self.cursor = self.conn.cursor()
            print("🔌 Conexión establecida con Snowflake")
            return True
        except Exception as e:
            print(f"❌ Error de conexión: {e}")
            return False
    
    def execute_sql(self, sql: str, description: str = ""):
        """Ejecuta una consulta SQL con manejo de errores"""
        try:
            print(f"🔄 Creando: {description}")
            self.cursor.execute(sql)
            print(f"✅ {description} - Completado")
            return True
        except Exception as e:
            print(f"❌ Error en {description}: {e}")
            return False
    
    def create_vista_alertas_energeticas(self):
        """
        VISTA 1: Alertas Energéticas
        Identifica situaciones críticas que requieren atención inmediata
        """
        sql = f"""
        CREATE OR REPLACE VIEW {self.full_schema}.VW_ALERTAS_ENERGETICAS AS
        SELECT 
            f.FECHA,
            c.ESTADO,
            c.INDUSTRIA,
            c.NOMBRE_CLIENTE,
            f.CONSUMO_MWH,
            f.PRECIO_MONOMICO_MXN,
            
            -- Datos contextuales
            h.TEMPERATURA_PROMEDIO_C,
            h.NIVEL_PRESA_PORCENTAJE,
            m.PRECIO_GAS_NATURAL_HHm,
            m.TIPO_DE_CAMBIO_FIX,
            
            -- ALERTAS CRÍTICAS
            CASE 
                WHEN f.CONSUMO_MWH > 3000 AND h.TEMPERATURA_PROMEDIO_C > 35 THEN 'CRÍTICO: Sobrecarga por Calor Extremo'
                WHEN h.NIVEL_PRESA_PORCENTAJE < 25 THEN 'CRÍTICO: Nivel de Presa Peligrosamente Bajo'
                WHEN f.PRECIO_MONOMICO_MXN > 3.5 AND m.PRECIO_GAS_NATURAL_HHm > 5.0 THEN 'CRÍTICO: Precios Excesivamente Altos'
                WHEN f.CONSUMO_MWH > 2500 AND c.INDUSTRIA = 'Minería' THEN 'ADVERTENCIA: Consumo Minero Elevado'
                WHEN m.TIPO_DE_CAMBIO_FIX > 22 AND f.PRECIO_MONOMICO_MXN > 2.8 THEN 'ADVERTENCIA: Impacto Tipo de Cambio'
                WHEN h.TEMPERATURA_PROMEDIO_C < 5 AND f.CONSUMO_MWH > 2000 THEN 'ADVERTENCIA: Alta Demanda Invernal'
                ELSE 'NORMAL'
            END AS TIPO_ALERTA,
            
            -- Nivel de prioridad
            CASE 
                WHEN f.CONSUMO_MWH > 3000 AND h.TEMPERATURA_PROMEDIO_C > 35 THEN 1
                WHEN h.NIVEL_PRESA_PORCENTAJE < 25 THEN 1
                WHEN f.PRECIO_MONOMICO_MXN > 3.5 AND m.PRECIO_GAS_NATURAL_HHm > 5.0 THEN 1
                WHEN f.CONSUMO_MWH > 2500 AND c.INDUSTRIA = 'Minería' THEN 2
                WHEN m.TIPO_DE_CAMBIO_FIX > 22 AND f.PRECIO_MONOMICO_MXN > 2.8 THEN 2
                WHEN h.TEMPERATURA_PROMEDIO_C < 5 AND f.CONSUMO_MWH > 2000 THEN 2
                ELSE 3
            END AS PRIORIDAD,
            
            -- Indicadores de riesgo
            ROUND((f.CONSUMO_MWH / 4000.0) * 100, 1) AS PORCENTAJE_CAPACIDAD_MAX,
            ROUND((h.NIVEL_PRESA_PORCENTAJE / 100.0) * 100, 1) AS SALUD_HIDRICA,
            ROUND((f.PRECIO_MONOMICO_MXN / 4.0) * 100, 1) AS INDICE_PRECIO_ALTO,
            
            -- Impacto económico estimado
            CASE 
                WHEN f.PRECIO_MONOMICO_MXN > 3.0 THEN 
                    (f.CONSUMO_MWH * (f.PRECIO_MONOMICO_MXN - 2.0))
                ELSE 0
            END AS SOBRECOSTO_ESTIMADO_MXN,
            
            -- Recomendaciones automáticas
            CASE 
                WHEN f.CONSUMO_MWH > 3000 AND h.TEMPERATURA_PROMEDIO_C > 35 THEN 'Implementar plan de emergencia para alta demanda'
                WHEN h.NIVEL_PRESA_PORCENTAJE < 25 THEN 'Activar fuentes alternativas de energía'
                WHEN f.PRECIO_MONOMICO_MXN > 3.5 THEN 'Revisar contratos de suministro'
                WHEN m.TIPO_DE_CAMBIO_FIX > 22 THEN 'Evaluar cobertura cambiaria'
                ELSE 'Continuar monitoreo normal'
            END AS RECOMENDACION
            
        FROM {self.full_schema}.FACT_CONSUMO_DIARIO f
        JOIN {self.full_schema}.DIM_CLIENTES c ON f.ID_CLIENTE = c.ID_CLIENTE
        LEFT JOIN {self.full_schema}.DIM_CONDICIONES_HIDROCLIMATICAS h ON f.FECHA = h.FECHA
        LEFT JOIN {self.full_schema}.DIM_CONDICIONES_MERCADO m ON f.FECHA = m.FECHA
        WHERE f.FECHA >= DATEADD('MONTH', -6, CURRENT_DATE())
        """
        
        return self.execute_sql(sql, "Vista de Alertas Energéticas")
    
    def create_vista_rentabilidad_segmento(self):
        """
        VISTA 2: Rentabilidad por Segmento
        Analiza la rentabilidad por estado, industria y tipo de cliente
        """
        sql = f"""
        CREATE OR REPLACE VIEW {self.full_schema}.VW_RENTABILIDAD_SEGMENTO AS
        SELECT 
            c.ESTADO,
            c.INDUSTRIA,
            DATE_TRUNC('MONTH', f.FECHA) AS MES,
            
            -- Métricas básicas
            COUNT(DISTINCT c.ID_CLIENTE) AS TOTAL_CLIENTES,
            SUM(f.CONSUMO_MWH) AS CONSUMO_TOTAL_MWH,
            SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) AS INGRESOS_TOTALES_MXN,
            AVG(f.PRECIO_MONOMICO_MXN) AS PRECIO_PROMEDIO_MXN,
            
            -- Métricas de rentabilidad
            SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(COUNT(DISTINCT c.ID_CLIENTE), 0) AS INGRESOS_POR_CLIENTE,
            SUM(f.CONSUMO_MWH) / NULLIF(COUNT(DISTINCT c.ID_CLIENTE), 0) AS CONSUMO_POR_CLIENTE,
            SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(SUM(f.CONSUMO_MWH), 0) AS PRECIO_EFECTIVO,
            
            -- Clasificación de rentabilidad
            CASE 
                WHEN SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(COUNT(DISTINCT c.ID_CLIENTE), 0) > 250000 THEN 'Muy Rentable'
                WHEN SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(COUNT(DISTINCT c.ID_CLIENTE), 0) > 150000 THEN 'Rentable'
                WHEN SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(COUNT(DISTINCT c.ID_CLIENTE), 0) > 75000 THEN 'Moderadamente Rentable'
                ELSE 'Baja Rentabilidad'
            END AS CATEGORIA_RENTABILIDAD,
            
            -- Potencial de crecimiento
            PERCENT_RANK() OVER (
                PARTITION BY DATE_TRUNC('MONTH', f.FECHA) 
                ORDER BY SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN)
            ) AS PERCENTIL_INGRESOS,
            
            -- Estabilidad del segmento
            STDDEV(f.PRECIO_MONOMICO_MXN) AS VOLATILIDAD_PRECIOS,
            STDDEV(f.CONSUMO_MWH) AS VOLATILIDAD_CONSUMO,
            
            -- Indicadores de concentración
            MAX(f.CONSUMO_MWH) / NULLIF(AVG(f.CONSUMO_MWH), 0) AS RATIO_CONCENTRACION,
            
            -- Tendencia (comparación mes anterior)
            LAG(SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN), 1) OVER (
                PARTITION BY c.ESTADO, c.INDUSTRIA 
                ORDER BY DATE_TRUNC('MONTH', f.FECHA)
            ) AS INGRESOS_MES_ANTERIOR,
            
            -- Crecimiento mensual
            CASE 
                WHEN LAG(SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN), 1) OVER (
                    PARTITION BY c.ESTADO, c.INDUSTRIA 
                    ORDER BY DATE_TRUNC('MONTH', f.FECHA)
                ) > 0 THEN
                    ((SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) - 
                      LAG(SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN), 1) OVER (
                          PARTITION BY c.ESTADO, c.INDUSTRIA 
                          ORDER BY DATE_TRUNC('MONTH', f.FECHA)
                      )) / 
                      LAG(SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN), 1) OVER (
                          PARTITION BY c.ESTADO, c.INDUSTRIA 
                          ORDER BY DATE_TRUNC('MONTH', f.FECHA)
                      )) * 100
                ELSE NULL
            END AS CRECIMIENTO_PORCENTUAL,
            
            -- Score de atractivo del segmento (0-100)
            LEAST(100, GREATEST(0,
                (PERCENT_RANK() OVER (
                    PARTITION BY DATE_TRUNC('MONTH', f.FECHA) 
                    ORDER BY SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN)
                ) * 40) +
                (CASE WHEN STDDEV(f.PRECIO_MONOMICO_MXN) < 0.5 THEN 30 ELSE 10 END) +
                (COUNT(DISTINCT c.ID_CLIENTE) / 50.0 * 30)
            )) AS SCORE_ATRACTIVO_SEGMENTO
            
        FROM {self.full_schema}.FACT_CONSUMO_DIARIO f
        JOIN {self.full_schema}.DIM_CLIENTES c ON f.ID_CLIENTE = c.ID_CLIENTE
        GROUP BY c.ESTADO, c.INDUSTRIA, DATE_TRUNC('MONTH', f.FECHA)
        """
        
        return self.execute_sql(sql, "Vista de Rentabilidad por Segmento")
    
    def create_vista_prediccion_demanda(self):
        """
        VISTA 3: Predicción de Demanda
        Analiza patrones para predecir la demanda futura
        """
        sql = f"""
        CREATE OR REPLACE VIEW {self.full_schema}.VW_PREDICCION_DEMANDA AS
        SELECT 
            c.ESTADO,
            c.INDUSTRIA,
            f.FECHA,
            DAYOFWEEK(f.FECHA) AS DIA_SEMANA,
            MONTH(f.FECHA) AS MES_NUMERO,
            QUARTER(f.FECHA) AS TRIMESTRE,
            
            -- Métricas actuales
            SUM(f.CONSUMO_MWH) AS CONSUMO_ACTUAL_MWH,
            AVG(f.PRECIO_MONOMICO_MXN) AS PRECIO_ACTUAL_MXN,
            
            -- Contexto climático y económico
            AVG(h.TEMPERATURA_PROMEDIO_C) AS TEMP_PROMEDIO,
            AVG(h.PRECIPITACION_MENSUAL_MM) AS PRECIPITACION_PROMEDIO,
            AVG(h.NIVEL_PRESA_PORCENTAJE) AS NIVEL_PRESA_PROMEDIO,
            AVG(m.PRECIO_GAS_NATURAL_HHm) AS PRECIO_GAS_PROMEDIO,
            
            -- Promedios históricos (misma época)
            AVG(SUM(f.CONSUMO_MWH)) OVER (
                PARTITION BY c.ESTADO, c.INDUSTRIA, DAYOFWEEK(f.FECHA)
                ORDER BY f.FECHA
                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            ) AS CONSUMO_PROMEDIO_7_DIAS,
            
            AVG(SUM(f.CONSUMO_MWH)) OVER (
                PARTITION BY c.ESTADO, c.INDUSTRIA, MONTH(f.FECHA)
                ORDER BY YEAR(f.FECHA)
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ) AS CONSUMO_PROMEDIO_MISMO_MES_3_ANOS,
            
            -- Tendencias
            SUM(f.CONSUMO_MWH) - LAG(SUM(f.CONSUMO_MWH), 7) OVER (
                PARTITION BY c.ESTADO, c.INDUSTRIA 
                ORDER BY f.FECHA
            ) AS CAMBIO_SEMANAL_MWH,
            
            SUM(f.CONSUMO_MWH) - LAG(SUM(f.CONSUMO_MWH), 30) OVER (
                PARTITION BY c.ESTADO, c.INDUSTRIA 
                ORDER BY f.FECHA
            ) AS CAMBIO_MENSUAL_MWH,
            
            -- Factores de estacionalidad
            SUM(f.CONSUMO_MWH) / NULLIF(
                AVG(SUM(f.CONSUMO_MWH)) OVER (
                    PARTITION BY c.ESTADO, c.INDUSTRIA
                    ORDER BY f.FECHA
                    ROWS BETWEEN 365 PRECEDING AND CURRENT ROW
                ), 0
            ) AS FACTOR_ESTACIONAL,
            
            -- Correlación con temperatura
            CASE 
                WHEN AVG(h.TEMPERATURA_PROMEDIO_C) > 30 THEN SUM(f.CONSUMO_MWH) * 1.15
                WHEN AVG(h.TEMPERATURA_PROMEDIO_C) > 25 THEN SUM(f.CONSUMO_MWH) * 1.08
                WHEN AVG(h.TEMPERATURA_PROMEDIO_C) < 10 THEN SUM(f.CONSUMO_MWH) * 1.12
                WHEN AVG(h.TEMPERATURA_PROMEDIO_C) < 15 THEN SUM(f.CONSUMO_MWH) * 1.05
                ELSE SUM(f.CONSUMO_MWH)
            END AS DEMANDA_AJUSTADA_CLIMA,
            
            -- Predicción simple de demanda (próximos 7 días)
            (
                AVG(SUM(f.CONSUMO_MWH)) OVER (
                    PARTITION BY c.ESTADO, c.INDUSTRIA, DAYOFWEEK(f.FECHA)
                    ORDER BY f.FECHA
                    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
                ) * 
                (SUM(f.CONSUMO_MWH) / NULLIF(
                    AVG(SUM(f.CONSUMO_MWH)) OVER (
                        PARTITION BY c.ESTADO, c.INDUSTRIA
                        ORDER BY f.FECHA
                        ROWS BETWEEN 365 PRECEDING AND CURRENT ROW
                    ), 0
                ))
            ) AS PREDICCION_DEMANDA_7_DIAS,
            
            -- Nivel de confianza de la predicción
            CASE 
                WHEN STDDEV(SUM(f.CONSUMO_MWH)) OVER (
                    PARTITION BY c.ESTADO, c.INDUSTRIA
                    ORDER BY f.FECHA
                    ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
                ) < 200 THEN 'Alta'
                WHEN STDDEV(SUM(f.CONSUMO_MWH)) OVER (
                    PARTITION BY c.ESTADO, c.INDUSTRIA
                    ORDER BY f.FECHA
                    ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
                ) < 500 THEN 'Media'
                ELSE 'Baja'
            END AS CONFIANZA_PREDICCION,
            
            -- Alertas de demanda anómala
            CASE 
                WHEN SUM(f.CONSUMO_MWH) > (
                    AVG(SUM(f.CONSUMO_MWH)) OVER (
                        PARTITION BY c.ESTADO, c.INDUSTRIA
                        ORDER BY f.FECHA
                        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
                    ) * 1.3
                ) THEN 'Demanda Anómalamente Alta'
                WHEN SUM(f.CONSUMO_MWH) < (
                    AVG(SUM(f.CONSUMO_MWH)) OVER (
                        PARTITION BY c.ESTADO, c.INDUSTRIA
                        ORDER BY f.FECHA
                        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
                    ) * 0.7
                ) THEN 'Demanda Anómalamente Baja'
                ELSE 'Demanda Normal'
            END AS ANOMALIA_DEMANDA
            
        FROM {self.full_schema}.FACT_CONSUMO_DIARIO f
        JOIN {self.full_schema}.DIM_CLIENTES c ON f.ID_CLIENTE = c.ID_CLIENTE
        LEFT JOIN {self.full_schema}.DIM_CONDICIONES_HIDROCLIMATICAS h ON f.FECHA = h.FECHA
        LEFT JOIN {self.full_schema}.DIM_CONDICIONES_MERCADO m ON f.FECHA = m.FECHA
        GROUP BY c.ESTADO, c.INDUSTRIA, f.FECHA
        """
        
        return self.execute_sql(sql, "Vista de Predicción de Demanda")
    
    def create_vista_eficiencia_operacional(self):
        """
        VISTA 4: Eficiencia Operacional
        Analiza la eficiencia operativa del sistema energético
        """
        sql = f"""
        CREATE OR REPLACE VIEW {self.full_schema}.VW_EFICIENCIA_OPERACIONAL AS
        SELECT 
            DATE_TRUNC('WEEK', f.FECHA) AS SEMANA,
            c.ESTADO,
            c.INDUSTRIA,
            
            -- KPIs operacionales básicos
            COUNT(DISTINCT c.ID_CLIENTE) AS CLIENTES_ACTIVOS,
            SUM(f.CONSUMO_MWH) AS CONSUMO_TOTAL_SEMANAL,
            AVG(f.CONSUMO_MWH) AS CONSUMO_PROMEDIO_DIARIO,
            SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) AS INGRESOS_TOTALES,
            
            -- Eficiencia energética
            SUM(f.CONSUMO_MWH) / NULLIF(COUNT(DISTINCT c.ID_CLIENTE), 0) AS MWH_POR_CLIENTE,
            SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(SUM(f.CONSUMO_MWH), 0) AS PRECIO_PROMEDIO_EFECTIVO,
            STDDEV(f.CONSUMO_MWH) / NULLIF(AVG(f.CONSUMO_MWH), 0) AS COEFICIENTE_VARIACION_CONSUMO,
            
            -- Eficiencia hidroeléctrica
            AVG(h.NIVEL_PRESA_PORCENTAJE) AS NIVEL_PRESA_PROMEDIO,
            SUM(f.CONSUMO_MWH) / NULLIF(AVG(h.NIVEL_PRESA_PORCENTAJE), 0) AS EFICIENCIA_HIDRICA,
            
            -- Correlación clima-eficiencia
            CORR(h.TEMPERATURA_PROMEDIO_C, f.CONSUMO_MWH) AS CORRELACION_TEMP_CONSUMO,
            CORR(h.PRECIPITACION_MENSUAL_MM, f.CONSUMO_MWH) AS CORRELACION_LLUVIA_CONSUMO,
            
            -- Eficiencia económica
            AVG(m.PRECIO_GAS_NATURAL_HHm) AS PRECIO_GAS_PROMEDIO,
            SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(AVG(m.PRECIO_GAS_NATURAL_HHm) * SUM(f.CONSUMO_MWH), 0) AS RATIO_EFICIENCIA_GAS,
            
            -- Factor de carga
            AVG(f.CONSUMO_MWH) / NULLIF(MAX(f.CONSUMO_MWH), 0) AS FACTOR_CARGA,
            
            -- Utilización de capacidad
            SUM(f.CONSUMO_MWH) / (COUNT(*) * 4000.0) AS UTILIZACION_CAPACIDAD_ESTIMADA,
            
            -- Indicadores de estabilidad
            CASE 
                WHEN STDDEV(f.CONSUMO_MWH) / NULLIF(AVG(f.CONSUMO_MWH), 0) < 0.2 THEN 'Muy Estable'
                WHEN STDDEV(f.CONSUMO_MWH) / NULLIF(AVG(f.CONSUMO_MWH), 0) < 0.4 THEN 'Estable'
                WHEN STDDEV(f.CONSUMO_MWH) / NULLIF(AVG(f.CONSUMO_MWH), 0) < 0.6 THEN 'Moderadamente Volátil'
                ELSE 'Muy Volátil'
            END AS ESTABILIDAD_OPERACIONAL,
            
            -- Score de eficiencia integral (0-100)
            LEAST(100, GREATEST(0,
                -- Eficiencia de utilización (30%)
                (AVG(f.CONSUMO_MWH) / NULLIF(MAX(f.CONSUMO_MWH), 0) * 30) +
                -- Estabilidad operacional (25%)
                (CASE 
                    WHEN STDDEV(f.CONSUMO_MWH) / NULLIF(AVG(f.CONSUMO_MWH), 0) < 0.2 THEN 25
                    WHEN STDDEV(f.CONSUMO_MWH) / NULLIF(AVG(f.CONSUMO_MWH), 0) < 0.4 THEN 20
                    WHEN STDDEV(f.CONSUMO_MWH) / NULLIF(AVG(f.CONSUMO_MWH), 0) < 0.6 THEN 15
                    ELSE 10
                END) +
                -- Eficiencia hídrica (25%)
                (LEAST(25, AVG(h.NIVEL_PRESA_PORCENTAJE) / 4.0)) +
                -- Eficiencia económica (20%)
                (LEAST(20, (SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(SUM(f.CONSUMO_MWH), 0)) / 0.15))
            )) AS SCORE_EFICIENCIA_INTEGRAL,
            
            -- Clasificación operacional
            CASE 
                WHEN LEAST(100, GREATEST(0,
                    (AVG(f.CONSUMO_MWH) / NULLIF(MAX(f.CONSUMO_MWH), 0) * 30) +
                    (CASE 
                        WHEN STDDEV(f.CONSUMO_MWH) / NULLIF(AVG(f.CONSUMO_MWH), 0) < 0.2 THEN 25
                        WHEN STDDEV(f.CONSUMO_MWH) / NULLIF(AVG(f.CONSUMO_MWH), 0) < 0.4 THEN 20
                        ELSE 15
                    END) +
                    (LEAST(25, AVG(h.NIVEL_PRESA_PORCENTAJE) / 4.0)) +
                    (LEAST(20, (SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(SUM(f.CONSUMO_MWH), 0)) / 0.15))
                )) > 80 THEN 'Excelente'
                WHEN LEAST(100, GREATEST(0,
                    (AVG(f.CONSUMO_MWH) / NULLIF(MAX(f.CONSUMO_MWH), 0) * 30) +
                    (CASE 
                        WHEN STDDEV(f.CONSUMO_MWH) / NULLIF(AVG(f.CONSUMO_MWH), 0) < 0.2 THEN 25
                        ELSE 15
                    END) +
                    (LEAST(25, AVG(h.NIVEL_PRESA_PORCENTAJE) / 4.0)) +
                    (LEAST(20, (SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(SUM(f.CONSUMO_MWH), 0)) / 0.15))
                )) > 65 THEN 'Buena'
                WHEN LEAST(100, GREATEST(0,
                    (AVG(f.CONSUMO_MWH) / NULLIF(MAX(f.CONSUMO_MWH), 0) * 30) +
                    (CASE 
                        WHEN STDDEV(f.CONSUMO_MWH) / NULLIF(AVG(f.CONSUMO_MWH), 0) < 0.4 THEN 20
                        ELSE 10
                    END) +
                    (LEAST(25, AVG(h.NIVEL_PRESA_PORCENTAJE) / 4.0)) +
                    (LEAST(20, (SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(SUM(f.CONSUMO_MWH), 0)) / 0.15))
                )) > 50 THEN 'Regular'
                ELSE 'Necesita Mejora'
            END AS CATEGORIA_EFICIENCIA,
            
            -- Recomendaciones operacionales
            CASE 
                WHEN STDDEV(f.CONSUMO_MWH) / NULLIF(AVG(f.CONSUMO_MWH), 0) > 0.6 THEN 'Mejorar estabilidad operacional'
                WHEN AVG(h.NIVEL_PRESA_PORCENTAJE) < 40 THEN 'Optimizar gestión hídrica'
                WHEN SUM(f.CONSUMO_MWH * f.PRECIO_MONOMICO_MXN) / NULLIF(SUM(f.CONSUMO_MWH), 0) > 3.0 THEN 'Revisar eficiencia de costos'
                WHEN AVG(f.CONSUMO_MWH) / NULLIF(MAX(f.CONSUMO_MWH), 0) < 0.6 THEN 'Optimizar factor de carga'
                ELSE 'Mantener operación actual'
            END AS RECOMENDACION_OPERACIONAL
            
        FROM {self.full_schema}.FACT_CONSUMO_DIARIO f
        JOIN {self.full_schema}.DIM_CLIENTES c ON f.ID_CLIENTE = c.ID_CLIENTE
        LEFT JOIN {self.full_schema}.DIM_CONDICIONES_HIDROCLIMATICAS h ON f.FECHA = h.FECHA
        LEFT JOIN {self.full_schema}.DIM_CONDICIONES_MERCADO m ON f.FECHA = m.FECHA
        GROUP BY DATE_TRUNC('WEEK', f.FECHA), c.ESTADO, c.INDUSTRIA
        """
        
        return self.execute_sql(sql, "Vista de Eficiencia Operacional")
    
    def create_all_vistas_especificas(self):
        """Crea todas las 4 vistas específicas"""
        print("🚀 CREANDO 4 VISTAS ESPECÍFICAS PARA FÉNIX ENERGÍA")
        print("=" * 70)
        
        vistas_creadas = 0
        total_vistas = 4
        
        vistas = [
            ("🚨 Alertas Energéticas", self.create_vista_alertas_energeticas),
            ("💰 Rentabilidad por Segmento", self.create_vista_rentabilidad_segmento),
            ("📈 Predicción de Demanda", self.create_vista_prediccion_demanda),
            ("⚡ Eficiencia Operacional", self.create_vista_eficiencia_operacional)
        ]
        
        for descripcion, create_function in vistas:
            print(f"\n{descripcion}")
            print("-" * 50)
            if create_function():
                vistas_creadas += 1
            else:
                print(f"❌ Error creando {descripcion}")
        
        print("\n" + "=" * 70)
        print(f"📊 RESUMEN: {vistas_creadas}/{total_vistas} vistas creadas exitosamente")
        
        if vistas_creadas == total_vistas:
            print("🎉 ¡Todas las vistas específicas fueron creadas correctamente!")
            self.mostrar_ejemplos_uso()
        
        return vistas_creadas == total_vistas
    
    def mostrar_ejemplos_uso(self):
        """Muestra ejemplos de uso de las vistas creadas"""
        print("\n📋 EJEMPLOS DE USO DE LAS VISTAS ESPECÍFICAS:")
        print("=" * 70)
        
        ejemplos = [
            {
                "vista": "🚨 VW_ALERTAS_ENERGETICAS",
                "descripcion": "Alertas críticas y de advertencia",
                "sql": f"SELECT TIPO_ALERTA, COUNT(*) as FRECUENCIA FROM {self.full_schema}.VW_ALERTAS_ENERGETICAS WHERE PRIORIDAD <= 2 GROUP BY TIPO_ALERTA ORDER BY FRECUENCIA DESC;"
            },
            {
                "vista": "💰 VW_RENTABILIDAD_SEGMENTO", 
                "descripcion": "Segmentos más rentables",
                "sql": f"SELECT ESTADO, INDUSTRIA, CATEGORIA_RENTABILIDAD, INGRESOS_POR_CLIENTE FROM {self.full_schema}.VW_RENTABILIDAD_SEGMENTO WHERE CATEGORIA_RENTABILIDAD = 'Muy Rentable' ORDER BY INGRESOS_POR_CLIENTE DESC LIMIT 10;"
            },
            {
                "vista": "📈 VW_PREDICCION_DEMANDA",
                "descripcion": "Predicciones de demanda anómala", 
                "sql": f"SELECT ESTADO, FECHA, ANOMALIA_DEMANDA, CONSUMO_ACTUAL_MWH, PREDICCION_DEMANDA_7_DIAS FROM {self.full_schema}.VW_PREDICCION_DEMANDA WHERE ANOMALIA_DEMANDA != 'Demanda Normal' ORDER BY FECHA DESC LIMIT 20;"
            },
            {
                "vista": "⚡ VW_EFICIENCIA_OPERACIONAL",
                "descripcion": "Análisis de eficiencia por región",
                "sql": f"SELECT ESTADO, CATEGORIA_EFICIENCIA, SCORE_EFICIENCIA_INTEGRAL, RECOMENDACION_OPERACIONAL FROM {self.full_schema}.VW_EFICIENCIA_OPERACIONAL GROUP BY ESTADO, CATEGORIA_EFICIENCIA, SCORE_EFICIENCIA_INTEGRAL, RECOMENDACION_OPERACIONAL ORDER BY SCORE_EFICIENCIA_INTEGRAL DESC;"
            }
        ]
        
        for ejemplo in ejemplos:
            print(f"\n{ejemplo['vista']}:")
            print(f"📝 {ejemplo['descripcion']}")
            print(f"SQL: {ejemplo['sql']}")
            print("-" * 40)
    
    def generar_reporte_insights(self):
        """Genera un reporte con insights de las 4 vistas"""
        print("\n📊 GENERANDO REPORTE DE INSIGHTS...")
        print("=" * 70)
        
        try:
            # Alertas críticas
            alertas = self.cursor.execute(f"""
                SELECT TIPO_ALERTA, COUNT(*) as FRECUENCIA 
                FROM {self.full_schema}.VW_ALERTAS_ENERGETICAS 
                WHERE PRIORIDAD <= 2 
                GROUP BY TIPO_ALERTA 
                ORDER BY FRECUENCIA DESC 
                LIMIT 5
            """).fetchall()
            
            print("🚨 ALERTAS MÁS FRECUENTES:")
            for row in alertas:
                print(f"   • {row[0]}: {row[1]} ocurrencias")
                
        except Exception as e:
            print(f"❌ Error generando insights: {e}")
    
    def close_connection(self):
        """Cierra la conexión con Snowflake"""
        if hasattr(self, 'cursor'):
            self.cursor.close()
        if hasattr(self, 'conn'):
            self.conn.close()
        print("🔌 Conexión cerrada")


def main():
    """Función principal"""
    # Configuración de conexión
    connection_params = {
        'user': os.getenv('SNOWFLAKE_USER', 'tu_usuario'),
        'password': os.getenv('SNOWFLAKE_PASSWORD', 'tu_password'),
        'account': os.getenv('SNOWFLAKE_ACCOUNT', 'tu_account'),
        'warehouse': os.getenv('SNOWFLAKE_WAREHOUSE', 'FENIX_WH'),
        'database': os.getenv('SNOWFLAKE_DATABASE', 'FENIX_DB'),
        'schema': os.getenv('SNOWFLAKE_SCHEMA', 'FENIX_ENERGY_SCHEMA'),
        'role': os.getenv('SNOWFLAKE_ROLE', 'FENIX_ANALYST_ROLE')
    }
    
    # Crear instancia y ejecutar
    creador_vistas = FenixVistasEspecificas(connection_params)
    
    try:
        if creador_vistas.connect():
            creador_vistas.create_all_vistas_especificas()
            creador_vistas.generar_reporte_insights()
        else:
            print("❌ No se pudo establecer conexión con Snowflake")
            
    except Exception as e:
        print(f"❌ Error general: {e}")
        
    finally:
        creador_vistas.close_connection()


if __name__ == "__main__":
    print("🏭 CREADOR DE VISTAS ESPECÍFICAS - FÉNIX ENERGÍA")
    print("=" * 70)
    print("📅 Fecha de ejecución:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print("🎯 Objetivo: Crear 4 vistas especializadas para análisis avanzado")
    print("=" * 70)
    
    main()


