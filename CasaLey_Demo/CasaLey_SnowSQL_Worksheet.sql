-- Sección 0: Historia y Caso de Uso -------------------------------------------------------
-- Contexto: Como Ingeniero de Datos en Casa Ley, buscamos unificar analítica operacional y de merchandising
-- dentro de Snowflake para responder con rapidez a la demanda regional y mejorar la eficiencia de inventario.
-- Objetivo: Demostrar cómo Snowflake habilita escalamiento inmediato, gobierno centralizado y monitoreo de costos
-- para respaldar decisiones comerciales en supermercados Casa Ley en México.

-- Sección 1: Configuración de Recursos -----------------------------------------------------
use role ACCOUNTADMIN;

create or replace role CASALEY_DEMO_ROLE;
grant role CASALEY_DEMO_ROLE to role SYSADMIN;
grant role CASALEY_DEMO_ROLE to role SECURITYADMIN;

grant create warehouse on account to role CASALEY_DEMO_ROLE;
grant create database on account to role CASALEY_DEMO_ROLE;
grant manage grants on account to role CASALEY_DEMO_ROLE;

create or replace warehouse CASALEY_WH
  warehouse_size = 'X-SMALL'
  auto_suspend = 60
  auto_resume = true
  initially_suspended = true
  comment = 'Warehouse dedicado a la demo Casa Ley';

grant operate, usage on warehouse CASALEY_WH to role CASALEY_DEMO_ROLE;

create or replace database CASALEY_DB;
create or replace schema CASALEY_DB.CASALEY_RAW;
create or replace schema CASALEY_DB.CASALEY_ANALYTICS;

grant usage on database CASALEY_DB to role CASALEY_DEMO_ROLE;
grant usage on all schemas in database CASALEY_DB to role CASALEY_DEMO_ROLE;
grant create table, create view, create stage, create stream, create task on schema CASALEY_DB.CASALEY_ANALYTICS to role CASALEY_DEMO_ROLE;

create or replace file format CASALEY_DB.CASALEY_ANALYTICS.CASALEY_CSV_FORMAT
  type = csv
  skip_header = 1
  field_delimiter = ','
  field_optionally_enclosed_by = '"';

create or replace stage CASALEY_DB.CASALEY_ANALYTICS.CASALEY_INTERNAL_STAGE
  file_format = CASALEY_DB.CASALEY_ANALYTICS.CASALEY_CSV_FORMAT
  comment = 'Stage interno para cargas controladas de Casa Ley';

grant usage on stage CASALEY_DB.CASALEY_ANALYTICS.CASALEY_INTERNAL_STAGE to role CASALEY_DEMO_ROLE;

-- Sección 2: Generación de Datos Sintéticos -----------------------------------------------
use role CASALEY_DEMO_ROLE;
use warehouse CASALEY_WH;
use database CASALEY_DB;
use schema CASALEY_ANALYTICS;

create or replace transient table CASALEY_DB.CASALEY_ANALYTICS.CLIENTES_DIM as
with base as (
  select
    row_number() over (order by seq4()) as cliente_id,
    initcap(array_construct('culiacán','mazatlán','los mochis','hermosillo','tijuana','guadalajara','monterrey','mexicali')[1 + uniform(0,7,random())]) as ciudad_residencia,
    initcap(array_construct('sinaloa','sonora','baja california','jalisco','nuevo león')[1 + uniform(0,4,random())]) as estado_residencia,
    dateadd(year, - (18 + uniform(0,35,random())), current_date()) as fecha_registro,
    iff(uniform(0,1,random()) < 0.55, 'Programa Oro', 'Programa Verde') as segmento_fidelidad
  from table(generator(rowcount => 1000))
)
select * from base;

create or replace transient table CASALEY_DB.CASALEY_ANALYTICS.VENTAS_SINTETICAS as
select
  seq4() + 1 as venta_id,
  dateadd(day, - uniform(0, 120, random()), current_date()) as fecha_venta,
  ceil(uniform(1, 1000, random())) as tienda_id,
  ceil(uniform(1, 1000, random())) as cliente_id,
  initcap(array_construct('abarrotes','productos frescos','limpieza','bebés','cuidado personal','hogar')[1 + uniform(0,5,random())]) as categoria,
  round(uniform(50, 1500, random())::numeric(12,2), 2) as monto_ticket,
  round(uniform(1, 60, random()), 0) as articulos,
  iff(uniform(0,1,random()) < 0.2, 'Promoción Regional', 'Precio Lista') as tipo_transaccion
from table(generator(rowcount => 12000));

create or replace transient table CASALEY_DB.CASALEY_ANALYTICS.INVENTARIO_SINTETICO as
select
  seq4() + 1 as inventario_id,
  ceil(uniform(1, 1000, random())) as tienda_id,
  initcap(array_construct('abarrotes','productos frescos','limpieza','bebés','cuidado personal','hogar')[1 + uniform(0,5,random())]) as categoria,
  round(uniform(1000, 5000, random()), 0) as unidades_disponibles,
  dateadd(day, - uniform(0, 14, random()), current_date()) as fecha_corte
from table(generator(rowcount => 3000));

create or replace view CASALEY_DB.CASALEY_ANALYTICS.VW_VENTAS_RESUMEN as
select
  fecha_venta,
  categoria,
  sum(monto_ticket) as ventas_totales,
  sum(articulos) as articulos_vendidos,
  count(distinct cliente_id) as clientes_activos
from CASALEY_DB.CASALEY_ANALYTICS.VENTAS_SINTETICAS
group by fecha_venta, categoria;

-- Sección 3: La Demo ----------------------------------------------------------------------
-- 3.1 Elasticidad Inmediata en Snowflake --------------------------------------------------
alter warehouse CASALEY_WH set warehouse_size = 'SMALL';
select categoria, sum(monto_ticket) as ventas_mxn
from CASALEY_DB.CASALEY_ANALYTICS.VENTAS_SINTETICAS
group by categoria
order by ventas_mxn desc;

-- 3.2 Analítica Continua con Streams y Tasks ----------------------------------------------
create or replace stream CASALEY_DB.CASALEY_ANALYTICS.CASALEY_VENTAS_STREAM
  on table CASALEY_DB.CASALEY_ANALYTICS.VENTAS_SINTETICAS;

create or replace table CASALEY_DB.CASALEY_ANALYTICS.METRICAS_HORA (
  ventana_inicio timestamp_ntz,
  ventana_fin timestamp_ntz,
  categoria string,
  ventas_hora number(12,2)
);

create or replace task CASALEY_DB.CASALEY_ANALYTICS.CASALEY_TASK_VENTAS_HORA
  warehouse = CASALEY_WH
  schedule = '60 minute'
as
merge into CASALEY_DB.CASALEY_ANALYTICS.METRICAS_HORA tgt
using (
  select
    date_trunc(hour, fecha_venta)::timestamp_ntz as ventana_inicio,
    dateadd(hour, 1, date_trunc(hour, fecha_venta))::timestamp_ntz as ventana_fin,
    categoria,
    sum(monto_ticket) as ventas_hora
  from CASALEY_DB.CASALEY_ANALYTICS.CASALEY_VENTAS_STREAM
  group by 1,2,3
) src
on tgt.ventana_inicio = src.ventana_inicio and tgt.categoria = src.categoria
when matched then update set ventas_hora = src.ventas_hora, ventana_fin = src.ventana_fin
when not matched then insert (ventana_inicio, ventana_fin, categoria, ventas_hora)
values (src.ventana_inicio, src.ventana_fin, src.categoria, src.ventas_hora);

alter task CASALEY_DB.CASALEY_ANALYTICS.CASALEY_TASK_VENTAS_HORA suspend;

-- 3.3 Gobierno y Protección de Datos -------------------------------------------------------
use role SECURITYADMIN;

create or replace masking policy CASALEY_DB.CASALEY_ANALYTICS.CASALEY_SEGMENTO_MASK as (valor string) returns string ->
  case
    when current_role() in ('ACCOUNTADMIN','SECURITYADMIN','CASALEY_DEMO_ROLE') then valor
    else 'Confidencial'
  end;

alter table CASALEY_DB.CASALEY_ANALYTICS.CLIENTES_DIM modify column segmento_fidelidad set masking policy CASALEY_DB.CASALEY_ANALYTICS.CASALEY_SEGMENTO_MASK;

-- 3.4 Colaboración Segura con Vistas Seguras ----------------------------------------------
use role CASALEY_DEMO_ROLE;

create or replace secure view CASALEY_DB.CASALEY_ANALYTICS.VW_VENTAS_SEGMENTO as
select
  v.fecha_venta,
  v.categoria,
  c.segmento_fidelidad,
  sum(v.monto_ticket) as ventas_segmento
from CASALEY_DB.CASALEY_ANALYTICS.VENTAS_SINTETICAS v
join CASALEY_DB.CASALEY_ANALYTICS.CLIENTES_DIM c on v.cliente_id = c.cliente_id
group by 1,2,3;

-- 3.5 FinOps: Monitoreo de Costos ----------------------------------------------------------
use role ACCOUNTADMIN;

create or replace resource monitor CASALEY_COST_MONITOR
  with credit_quota = 20
  frequency = daily
  start_timestamp = immediate
  notify_triggers = (80, 90, 100);

alter warehouse CASALEY_WH set resource_monitor = CASALEY_COST_MONITOR;

select
  usage_date,
  sum(credits_used) as creditos_consumidos,
  sum(credits_used) * current_account()::variant:"DATA_TRANSFER_CURRENCY_RATE" as costo_estimado
from snowflake.account_usage.warehouse_metering_history
where warehouse_name = 'CASALEY_WH'
  and usage_date >= dateadd(day, -7, current_date())
group by usage_date
order by usage_date;

-- Fin de la Hoja de Trabajo ---------------------------------------------------------------

