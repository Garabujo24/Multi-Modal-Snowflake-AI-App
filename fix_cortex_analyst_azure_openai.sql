-- =====================================================
-- SOLUCIÓN PARA ERROR DE AZURE OPENAI LEGACY PATH
-- =====================================================
-- Error: "You are using the legacy Azure OpenAI path. This path is now deprecated..."
-- Solución: Deshabilitar el parámetro ENABLE_CORTEX_ANALYST_MODEL_AZURE_OPENAI

-- =====================================================
-- PASO 1: VERIFICAR EL ESTADO ACTUAL DEL PARÁMETRO
-- =====================================================
-- Ejecutar como ACCOUNTADMIN para ver el valor actual
USE ROLE ACCOUNTADMIN;

SHOW PARAMETERS LIKE 'ENABLE_CORTEX_ANALYST_MODEL_AZURE_OPENAI' IN ACCOUNT;

-- =====================================================
-- PASO 2: DESHABILITAR EL PARÁMETRO LEGACY
-- =====================================================
-- Según la documentación de Snowflake, este parámetro está deprecated
-- y se recomienda usar los modelos Snowflake-hosted en su lugar

USE ROLE ACCOUNTADMIN;

ALTER ACCOUNT SET ENABLE_CORTEX_ANALYST_MODEL_AZURE_OPENAI = FALSE;

-- =====================================================
-- PASO 3: VERIFICAR QUE EL CAMBIO SE APLICÓ CORRECTAMENTE
-- =====================================================
SHOW PARAMETERS LIKE 'ENABLE_CORTEX_ANALYST_MODEL_AZURE_OPENAI' IN ACCOUNT;

-- El valor debe mostrar FALSE

-- =====================================================
-- PASO 4: VERIFICAR QUE CORTEX ANALYST SIGUE FUNCIONANDO
-- =====================================================
-- Verificar que Cortex Analyst está habilitado en general
SHOW PARAMETERS LIKE 'ENABLE_CORTEX_ANALYST' IN ACCOUNT;

-- El valor debe mostrar TRUE

-- =====================================================
-- INFORMACIÓN ADICIONAL
-- =====================================================
/*
SEGÚN LA DOCUMENTACIÓN DE SNOWFLAKE:

1. PROBLEMA:
   - El parámetro ENABLE_CORTEX_ANALYST_MODEL_AZURE_OPENAI está deprecated
   - Snowflake recomienda NO usar el path de Azure OpenAI legacy
   - Soporte será removido en futuras versiones
   - Acceso a modelos nuevos no está disponible por este path

2. SOLUCIÓN RECOMENDADA:
   - Usar modelos Snowflake-hosted en su lugar
   - Los modelos disponibles incluyen:
     * Anthropic Claude Sonnet 4
     * Anthropic Claude Sonnet 3.7  
     * Anthropic Claude Sonnet 3.5
     * OpenAI GPT 4.1 (Snowflake-hosted)
     * Mistral Large 2 y Llama 3.1 70b

3. BENEFICIOS DEL CAMBIO:
   - Acceso a modelos más nuevos y mejores
   - Mejor integración con RBAC de Snowflake
   - Los datos permanecen dentro del boundary de Snowflake
   - Mejor performance y accuracy
   - Compatible con cross-region inference

4. ORDEN DE PREFERENCIA DE MODELOS:
   Cortex Analyst selecciona automáticamente en este orden:
   1. Anthropic Claude Sonnet 4
   2. Anthropic Claude Sonnet 3.7
   3. Anthropic Claude Sonnet 3.5
   4. OpenAI GPT 4.1
   5. Combinación de Mistral Large 2 y Llama 3.1 70b

5. CONSIDERACIONES DE SEGURIDAD:
   - Con Snowflake-hosted models: datos no salen del boundary de Snowflake
   - Con Azure OpenAI (legacy): metadata es procesado por Microsoft Azure
   - El cambio mejora la governance y security
*/

-- =====================================================
-- COMANDOS OPCIONALES PARA VERIFICAR ACCESO
-- =====================================================

-- Verificar roles de Cortex Analyst
SHOW GRANTS TO ROLE SNOWFLAKE.CORTEX_ANALYST_USER;

-- Verificar si el usuario actual tiene acceso
SHOW GRANTS TO USER CURRENT_USER();

-- =====================================================
-- NOTAS PARA EL ADMINISTRADOR
-- =====================================================
/*
1. Este script debe ejecutarse con rol ACCOUNTADMIN
2. El cambio afecta a toda la cuenta de Snowflake
3. Una vez deshabilitado, Cortex Analyst usará automáticamente 
   los modelos Snowflake-hosted más recientes
4. No requiere cambios en el semantic model YAML
5. Las aplicaciones existentes seguirán funcionando sin modificaciones
*/


