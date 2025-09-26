# Solución para Error de Azure OpenAI Legacy Path en Cortex Analyst

## 🚨 **Problema Identificado**

Estás recibiendo este error al usar Cortex Analyst:

```
You are using the legacy Azure OpenAI path. This path is now deprecated and support will be removed in the future. Further, access to newer models is not available through this path. Please unset the ENABLE_CORTEX_ANALYST_MODEL_AZURE_OPENAI parameter.
```

## 🔧 **Solución Rápida**

Ejecuta los siguientes comandos como **ACCOUNTADMIN**:

```sql
-- 1. Verificar estado actual
USE ROLE ACCOUNTADMIN;
SHOW PARAMETERS LIKE 'ENABLE_CORTEX_ANALYST_MODEL_AZURE_OPENAI' IN ACCOUNT;

-- 2. Deshabilitar el parámetro legacy
ALTER ACCOUNT SET ENABLE_CORTEX_ANALYST_MODEL_AZURE_OPENAI = FALSE;

-- 3. Verificar el cambio
SHOW PARAMETERS LIKE 'ENABLE_CORTEX_ANALYST_MODEL_AZURE_OPENAI' IN ACCOUNT;
```

## 📋 **Explicación Detallada**

### **¿Por qué ocurre este error?**

Según la [documentación oficial de Snowflake](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst#enabling-use-of-azure-openai-models-legacy-path), el parámetro `ENABLE_CORTEX_ANALYST_MODEL_AZURE_OPENAI` es una **configuración legacy deprecated** que:

- ❌ Está marcada para eliminación en futuras versiones
- ❌ No permite acceso a los modelos más nuevos
- ❌ Requiere que metadata sea procesado por Microsoft Azure (fuera del boundary de Snowflake)
- ❌ No es compatible con model-level RBAC

### **¿Qué mejora al deshabilitarlo?**

Al deshabilitar este parámetro, Cortex Analyst automáticamente usa **modelos Snowflake-hosted** que ofrecen:

- ✅ **Mejores modelos** con mayor accuracy y performance
- ✅ **Seguridad mejorada** - datos permanecen en Snowflake
- ✅ **RBAC completo** - control granular de acceso a modelos
- ✅ **Acceso a modelos nuevos** según se lancen

## 🤖 **Modelos Disponibles Después del Cambio**

Cortex Analyst seleccionará automáticamente el mejor modelo en este orden de preferencia:

1. **Anthropic Claude Sonnet 4** (más reciente)
2. **Anthropic Claude Sonnet 3.7**
3. **Anthropic Claude Sonnet 3.5**
4. **OpenAI GPT 4.1** (Snowflake-hosted)
5. **Mistral Large 2 + Llama 3.1 70b** (combinación)

## 🔒 **Implicaciones de Seguridad**

### **Antes (Azure OpenAI Legacy):**
- Metadata enviado a Microsoft Azure
- Procesamiento fuera del governance boundary de Snowflake
- Sin RBAC a nivel de modelo

### **Después (Snowflake-hosted):**
- Todo procesamiento dentro de Snowflake
- Governance completo bajo políticas de Snowflake
- RBAC granular disponible

## ✅ **Verificación Post-Cambio**

Después de ejecutar la solución, verifica que todo funciona:

```sql
-- Verificar que Cortex Analyst sigue habilitado
SHOW PARAMETERS LIKE 'ENABLE_CORTEX_ANALYST' IN ACCOUNT;

-- Verificar acceso a roles necesarios
SHOW GRANTS TO ROLE SNOWFLAKE.CORTEX_ANALYST_USER;

-- Probar Cortex Analyst con tu semantic model
-- (usar la API REST de Cortex Analyst)
```

## 🎯 **Impacto en tu Modelo Semántico**

**✅ Buenas noticias:** Tu modelo semántico de Fénix Energía (`fenix_energia_semantic_model.yaml`) **NO requiere cambios**. El archivo seguirá funcionando exactamente igual con los nuevos modelos.

## 📞 **Si Necesitas Ayuda**

Si después de ejecutar estos comandos sigues teniendo problemas:

1. Verifica que tienes rol **ACCOUNTADMIN**
2. Confirma que el parámetro muestra `FALSE`
3. Prueba el semantic model con una consulta simple
4. Revisa los logs de Cortex Analyst

## 🔗 **Referencias**

- [Documentación oficial de Snowflake - Cortex Analyst](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [Azure OpenAI Legacy Path (Deprecated)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst#enabling-use-of-azure-openai-models-legacy-path)
- [Model Selection in Cortex Analyst](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst#control-models-used-by-cortex-analyst)

---

**📝 Nota:** Esta solución fue generada basándose en la documentación oficial de Snowflake y las mejores prácticas recomendadas para Cortex Analyst.


