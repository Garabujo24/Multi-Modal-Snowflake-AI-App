# Reporte FinOps Demo Casa Ley

## Resumen Ejecutivo
Esta guía resume cómo un Category Manager con experiencia en data engineering puede seguir en tiempo real el costo de la demo sobre Snowflake. Imagina el warehouse como una flotilla de camiones repartidores: cada crédito consumido es un litro de diésel. El objetivo es entregar promociones personalizadas y eficiencia de inventario sin exceder el combustible disponible.

## Inventario de Recursos
- `CASALEY_WH` (X-Small, auto-suspend 60 seg, auto-resume activado).
- Base de datos `CASALEY_DB` con esquemas `RAW` y `ANALYTICS`.
- Servicio Cortex Search `CASALEY_PROMO_SEARCH` y modelo Cortex Analyst `CASALEY_ANALYST_MODEL`.

## Límites y Alertas Sugeridos
- Presupuesto diario de créditos: **40 créditos** (aprox. 4 horas efectivas de warehouse X-Small activo).
- Alerta amarilla: consumo > 30 créditos en las últimas 24 horas.
- Alerta roja: consumo > 40 créditos o warehouse activo continuo > 90 minutos.

## Métricas Operativas Clave
- Créditos por hora (`creditos_usados`) usando la consulta 3.7 de la hoja SQL.
- Costo por ticket promocional vs margen (consulta 3.3) para garantizar retorno.
- Costo estimado de reabasto crítico (consulta 3.6) para vincular inventario con gasto de capital.

## Rutina de Monitoreo Diario
1. **8:00 AM** – Ejecutar la consulta 3.7 para validar consumo nocturno. Registrar en tabla auxiliar o dashboard simple.
2. **12:00 PM** – Revisar consulta 3.3. Si `retorno_por_peso_invertido < 3`, ajustar campañas o suspender warehouse temporalmente.
3. **5:00 PM** – Revisar consulta 3.6. Priorizar productos que implican mayor `costo_estimado_reabasto` y sincronizar con promociones activas.

## Automatización Recomendada
- Crear alerta en Snowflake con `TASK` + `NOTIFICATION INTEGRATION` para disparar correo si créditos diarios > 35.
- Registrar métricas en `ANALYTICS.FINOPS_DAILY` con resultados de las consultas anteriores para análisis histórico.

## Buenas Prácticas
- Mantener warehouse en X-Small mientras sea demo. Escalar solo durante ejecuciones masivas de datos sintéticos.
- Limitar sesiones de Cortex Analyst concurrentes para evitar consumo inesperado.
- Depurar tableros o notebooks inactivos que empleen el mismo warehouse.

## Próximos Pasos
- Integrar consultas FinOps en dashboard ligero (Streamlit o Snowsight) para visibilidad inmediata.
- Evaluar segmentación de warehouse si se amplía el alcance de la demo.
- Documentar aprendizajes de crédito por promoción para retroalimentar estrategias comerciales.


