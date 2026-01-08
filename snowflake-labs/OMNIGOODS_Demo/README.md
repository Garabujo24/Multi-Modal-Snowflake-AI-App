# Demo de Snowflake Cortex para OMNIGOODS

## Resumen

Este proyecto contiene una demostración completa y genérica diseñada para mostrar las capacidades de Snowflake Cortex. La demo utiliza un conjunto de datos sintéticos de una empresa ficticia de retail y comercio electrónico llamada `OMNIGOODS`.

El objetivo es ilustrar cómo un cliente puede utilizar las funciones de IA y ML de Snowflake para analizar datos estructurados y no estructurados, generar pronósticos, analizar sentimientos y mucho más, todo dentro de su cuenta de Snowflake.

## Contenido

-   `OMNIGOODS_worksheet.sql`: El script SQL principal que contiene toda la lógica de la demo, dividida en cuatro secciones claras:
    1.  **Historia y Caso de Uso**: Contexto de negocio.
    2.  **Configuración de Recursos**: Creación de la base de datos, tablas, etc.
    3.  **Generación de Datos Sintéticos**: Creación de datos realistas.
    4.  **La Demo**: Ejemplos prácticos de las funciones de Cortex.

-   `omnigoods_semantic_model.yaml`: Un modelo semántico que define las tablas, dimensiones, métricas y relaciones. Este archivo es utilizado por Snowflake Cortex Analyst para entender los datos y responder a preguntas en lenguaje natural.

-   `data/`: Una carpeta que contiene archivos de ejemplo para la demo.
    -   `OMNIGOODS_Product_Manual_Smartwatch.txt`: Un manual de producto de ejemplo en texto plano para demostrar las capacidades de Cortex Search.

## Cómo Ejecutar la Demo

1.  **Configuración**: Asegúrate de tener los permisos necesarios en tu cuenta de Snowflake para crear bases de datos, warehouses y roles.
2.  **Ejecutar el Worksheet**: Abre el archivo `OMNIGOODS_worksheet.sql` en un worksheet de Snowsight.
3.  **Ejecución Secuencial**: Ejecuta los comandos del worksheet en orden, sección por sección. El script está diseñado para ser auto-contenido y creará todos los recursos y datos necesarios.
4.  **Cargar Archivos**: El script te guiará para cargar el archivo de `data/` a un stage interno de Snowflake para la demo de Cortex Search.

