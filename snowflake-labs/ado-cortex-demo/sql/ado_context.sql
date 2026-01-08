-- Script para crear el contexto de la demo ADO en Snowflake

-- Crear warehouse (pequeño y económico)
CREATE OR REPLACE WAREHOUSE ADO_WH
  WITH WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

-- Crear base de datos
CREATE OR REPLACE DATABASE ADO_DEMO_DB;

-- Crear schema
CREATE OR REPLACE SCHEMA ADO_DEMO_DB.PUBLIC;

-- Usar el contexto creado
USE WAREHOUSE ADO_WH;
USE DATABASE ADO_DEMO_DB;
USE SCHEMA PUBLIC;

