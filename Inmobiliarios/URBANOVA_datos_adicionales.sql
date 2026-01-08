-- ============================================================================
-- URBANOVA - DATOS ADICIONALES
-- ============================================================================
-- Objetivo: Agregar ventas a 5 desarrollos más y ajustar costos para
--           lograr 70% de rentabilidad en los proyectos
-- ============================================================================

USE DATABASE URBANOVA_DB;
USE SCHEMA URBANOVA_SCHEMA;

-- ============================================================================
-- PARTE 1: Agregar más propiedades a desarrollos existentes
-- ============================================================================

-- Agregar propiedades adicionales para tener más inventario vendible
INSERT INTO URBANOVA_SCHEMA.PROPIEDADES
SELECT
    (SELECT MAX(PROPIEDAD_ID) FROM URBANOVA_SCHEMA.PROPIEDADES) + ROW_NUMBER() OVER (ORDER BY NULL) AS PROPIEDAD_ID,
    desarrollo_id,
    tipo_propiedad,
    numero_unidad,
    nivel_piso,
    superficie_m2,
    recamaras,
    banos,
    estacionamientos,
    precio_lista_mxn,
    ROUND(precio_lista_mxn / superficie_m2, 2) AS precio_m2_mxn,
    estatus_inventario,
    fecha_actualizacion,
    comentario
FROM (
    -- Desarrollo 6: Andares Residencial (Guadalajara) - Agregar unidades vendidas
    SELECT 6 AS desarrollo_id, 'Departamento' AS tipo_propiedad, 'A-301' AS numero_unidad, 3 AS nivel_piso, 115.0 AS superficie_m2, 2 AS recamaras, 2.0 AS banos, 2 AS estacionamientos, 5900000 AS precio_lista_mxn, 'Vendido' AS estatus_inventario, '2024-06-15'::DATE AS fecha_actualizacion, 'Vendido en preventa' AS comentario UNION ALL
    SELECT 6, 'Departamento', 'A-401', 4, 115.0, 2, 2.0, 2, 5900000, 'Vendido', '2024-07-20'::DATE, 'Vendido con descuento' UNION ALL
    SELECT 6, 'Departamento', 'A-501', 5, 125.0, 3, 2.5, 2, 6500000, 'Vendido', '2024-08-10'::DATE, 'Cliente inversionista' UNION ALL
    SELECT 6, 'Departamento', 'A-601', 6, 125.0, 3, 2.5, 2, 6500000, 'Vendido', '2024-09-05'::DATE, 'Pago de contado' UNION ALL
    SELECT 6, 'Departamento', 'B-301', 3, 140.0, 3, 3.0, 2, 7500000, 'Vendido', '2024-09-18'::DATE, 'Financiamiento bancario' UNION ALL
    SELECT 6, 'Departamento', 'B-401', 4, 140.0, 3, 3.0, 2, 7500000, 'Vendido', '2024-10-01'::DATE, 'Cliente frecuente' UNION ALL
    SELECT 6, 'Departamento', 'B-501', 5, 155.0, 3, 3.0, 2, 8200000, 'Apartado', '2024-10-15'::DATE, 'En proceso de cierre' UNION ALL
    
    -- Desarrollo 10: Altabrisa Towers (Mérida) - Agregar unidades vendidas
    SELECT 10, 'Departamento', 'T1-301', 3, 95.0, 2, 2.0, 1, 3400000, 'Vendido', '2024-05-10'::DATE, 'Primera venta del proyecto' UNION ALL
    SELECT 10, 'Departamento', 'T1-401', 4, 95.0, 2, 2.0, 1, 3400000, 'Vendido', '2024-05-25'::DATE, 'Preventa exitosa' UNION ALL
    SELECT 10, 'Departamento', 'T1-601', 6, 100.0, 2, 2.0, 2, 3650000, 'Vendido', '2024-06-15'::DATE, 'Vista panorámica' UNION ALL
    SELECT 10, 'Departamento', 'T1-701', 7, 100.0, 2, 2.0, 2, 3650000, 'Vendido', '2024-07-08'::DATE, 'Cliente de Mérida' UNION ALL
    SELECT 10, 'Departamento', 'T2-301', 3, 110.0, 3, 2.5, 2, 4200000, 'Vendido', '2024-08-20'::DATE, 'Torre 2' UNION ALL
    SELECT 10, 'Departamento', 'T2-401', 4, 110.0, 3, 2.5, 2, 4200000, 'Vendido', '2024-09-10'::DATE, 'Familia joven' UNION ALL
    SELECT 10, 'Departamento', 'T2-501', 5, 120.0, 3, 2.5, 2, 4600000, 'Vendido', '2024-09-28'::DATE, 'Vista al golf' UNION ALL
    SELECT 10, 'Departamento', 'T2-601', 6, 120.0, 3, 2.5, 2, 4600000, 'Apartado', '2024-10-10'::DATE, 'En negociación' UNION ALL
    
    -- Desarrollo 12: Departamentos Playa Caracol (Cancún) - Agregar unidades vendidas
    SELECT 12, 'Departamento', 'PC-102', 1, 90.0, 2, 2.0, 1, 6500000, 'Vendido', '2024-04-20'::DATE, 'Inversionista extranjero' UNION ALL
    SELECT 12, 'Departamento', 'PC-103', 1, 90.0, 2, 2.0, 1, 6500000, 'Vendido', '2024-05-05'::DATE, 'Cliente estadounidense' UNION ALL
    SELECT 12, 'Departamento', 'PC-201', 2, 95.0, 2, 2.0, 1, 7200000, 'Vendido', '2024-05-28'::DATE, 'Vista frontal al mar' UNION ALL
    SELECT 12, 'Departamento', 'PC-202', 2, 95.0, 2, 2.0, 1, 7200000, 'Vendido', '2024-06-15'::DATE, 'Pago de contado' UNION ALL
    SELECT 12, 'Departamento', 'PC-301', 3, 110.0, 2, 2.0, 2, 8500000, 'Vendido', '2024-07-10'::DATE, 'Esquina premium' UNION ALL
    SELECT 12, 'Departamento', 'PC-302', 3, 110.0, 2, 2.0, 2, 8500000, 'Vendido', '2024-08-05'::DATE, 'Cliente canadiense' UNION ALL
    SELECT 12, 'Departamento', 'PC-401', 4, 125.0, 3, 2.5, 2, 9800000, 'Vendido', '2024-09-01'::DATE, 'Vista panorámica' UNION ALL
    SELECT 12, 'Departamento', 'PC-402', 4, 125.0, 3, 2.5, 2, 9800000, 'Apartado', '2024-10-08'::DATE, 'En proceso de cierre' UNION ALL
    
    -- Desarrollo 9: Lofts Mérida Centro - Más ventas
    SELECT 9, 'Departamento', 'L-203', 2, 80.0, 1, 1.5, 1, 2250000, 'Vendido', '2024-06-10'::DATE, 'Loft con terraza' UNION ALL
    SELECT 9, 'Departamento', 'L-204', 2, 80.0, 1, 1.5, 1, 2250000, 'Vendido', '2024-07-05'::DATE, 'Inversionista local' UNION ALL
    SELECT 9, 'Departamento', 'L-301', 3, 90.0, 2, 2.0, 1, 2700000, 'Vendido', '2024-08-15'::DATE, 'Doble altura' UNION ALL
    SELECT 9, 'Departamento', 'L-302', 3, 90.0, 2, 2.0, 1, 2700000, 'Vendido', '2024-09-20'::DATE, 'Vista al centro' UNION ALL
    
    -- Desarrollo 7: Querétaro Business Park - Más ventas comerciales
    SELECT 7, 'Local Comercial', 'OF-103', 1, 90.0, 0, 1.0, 2, 3100000, 'Vendido', '2024-05-20'::DATE, 'Oficina corporativa' UNION ALL
    SELECT 7, 'Local Comercial', 'OF-201', 2, 100.0, 0, 1.0, 2, 3450000, 'Vendido', '2024-06-28'::DATE, 'Empresa de tecnología' UNION ALL
    SELECT 7, 'Local Comercial', 'OF-202', 2, 100.0, 0, 1.0, 2, 3450000, 'Vendido', '2024-08-10'::DATE, 'Consultora financiera' UNION ALL
    SELECT 7, 'Local Comercial', 'OF-203', 2, 110.0, 0, 2.0, 3, 3800000, 'Vendido', '2024-09-15'::DATE, 'Despacho de abogados' UNION ALL
    
    -- Desarrollo 11: Marina Cancún - Más ventas
    SELECT 11, 'Departamento', '203', 2, 105.0, 2, 2.0, 2, 5800000, 'Vendido', '2024-06-05'::DATE, 'Vista a marina' UNION ALL
    SELECT 11, 'Departamento', '204', 2, 105.0, 2, 2.0, 2, 5800000, 'Vendido', '2024-07-15'::DATE, 'Cliente de CDMX' UNION ALL
    SELECT 11, 'Departamento', '301', 3, 120.0, 3, 2.5, 2, 6900000, 'Vendido', '2024-08-22'::DATE, 'Inversionista' UNION ALL
    SELECT 11, 'Departamento', '302', 3, 120.0, 3, 2.5, 2, 6900000, 'Vendido', '2024-09-10'::DATE, 'Compra para renta' UNION ALL
    SELECT 11, 'Departamento', '401', 4, 135.0, 3, 2.5, 2, 7800000, 'Vendido', '2024-10-05'::DATE, 'Premium floor'
);

-- ============================================================================
-- PARTE 2: Agregar ventas para los 5 desarrollos adicionales
-- ============================================================================

INSERT INTO URBANOVA_SCHEMA.VENTAS
SELECT
    (SELECT MAX(VENTA_ID) FROM URBANOVA_SCHEMA.VENTAS) + ROW_NUMBER() OVER (ORDER BY NULL) AS VENTA_ID,
    propiedad_id,
    fecha_venta,
    precio_venta_mxn,
    descuento_aplicado_pct,
    metodo_financiamiento,
    enganche_mxn,
    meses_financiamiento,
    tipo_cliente,
    agente_id,
    comentario
FROM (
    -- =========================================================================
    -- VENTAS DESARROLLO 6: Andares Residencial (Guadalajara) - 6 ventas nuevas
    -- =========================================================================
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 6 AND NUMERO_UNIDAD = 'A-301' LIMIT 1) AS propiedad_id,
        '2024-06-15'::DATE AS fecha_venta, 
        5605000 AS precio_venta_mxn, -- 5% descuento preventa
        5.00 AS descuento_aplicado_pct, 
        'Hipoteca' AS metodo_financiamiento, 
        1681500 AS enganche_mxn, 
        240 AS meses_financiamiento, 
        'Usuario Final' AS tipo_cliente, 
        3 AS agente_id, 
        'Preventa con descuento especial' AS comentario 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 6 AND NUMERO_UNIDAD = 'A-401' LIMIT 1),
        '2024-07-20'::DATE, 5605000, 5.00, 'Mixto', 2242000, 180, 'Inversionista', 3, 'Inversionista de Guadalajara' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 6 AND NUMERO_UNIDAD = 'A-501' LIMIT 1),
        '2024-08-10'::DATE, 6500000, 0.00, 'Contado', 6500000, 0, 'Inversionista', 3, 'Pago en una exhibición' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 6 AND NUMERO_UNIDAD = 'A-601' LIMIT 1),
        '2024-09-05'::DATE, 6175000, 5.00, 'Contado', 6175000, 0, 'Usuario Final', 3, 'Descuento por pago inmediato' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 6 AND NUMERO_UNIDAD = 'B-301' LIMIT 1),
        '2024-09-18'::DATE, 7500000, 0.00, 'Hipoteca', 2250000, 240, 'Usuario Final', 3, 'Financiamiento bancario aprobado' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 6 AND NUMERO_UNIDAD = 'B-401' LIMIT 1),
        '2024-10-01'::DATE, 7125000, 5.00, 'Mixto', 2850000, 180, 'Usuario Final', 3, 'Cliente frecuente URBANOVA' 
    UNION ALL

    -- =========================================================================
    -- VENTAS DESARROLLO 10: Altabrisa Towers (Mérida) - 7 ventas nuevas
    -- =========================================================================
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 10 AND NUMERO_UNIDAD = 'T1-301' LIMIT 1),
        '2024-05-10'::DATE, 3230000, 5.00, 'Hipoteca', 969000, 180, 'Usuario Final', 5, 'Primera venta del proyecto' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 10 AND NUMERO_UNIDAD = 'T1-401' LIMIT 1),
        '2024-05-25'::DATE, 3230000, 5.00, 'Crédito Infonavit', 646000, 240, 'Usuario Final', 5, 'Preventa exitosa' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 10 AND NUMERO_UNIDAD = 'T1-601' LIMIT 1),
        '2024-06-15'::DATE, 3650000, 0.00, 'Hipoteca', 1095000, 200, 'Usuario Final', 5, 'Vista panorámica' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 10 AND NUMERO_UNIDAD = 'T1-701' LIMIT 1),
        '2024-07-08'::DATE, 3650000, 0.00, 'Contado', 3650000, 0, 'Inversionista', 5, 'Inversionista de Mérida' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 10 AND NUMERO_UNIDAD = 'T2-301' LIMIT 1),
        '2024-08-20'::DATE, 3990000, 5.00, 'Mixto', 1596000, 180, 'Usuario Final', 5, 'Torre 2 primera venta' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 10 AND NUMERO_UNIDAD = 'T2-401' LIMIT 1),
        '2024-09-10'::DATE, 4200000, 0.00, 'Hipoteca', 1260000, 240, 'Usuario Final', 5, 'Familia joven' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 10 AND NUMERO_UNIDAD = 'T2-501' LIMIT 1),
        '2024-09-28'::DATE, 4370000, 5.00, 'Contado', 4370000, 0, 'Inversionista', 5, 'Vista al golf, contado' 
    UNION ALL

    -- =========================================================================
    -- VENTAS DESARROLLO 12: Playa Caracol (Cancún) - 7 ventas nuevas
    -- =========================================================================
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 12 AND NUMERO_UNIDAD = 'PC-102' LIMIT 1),
        '2024-04-20'::DATE, 6500000, 0.00, 'Contado', 6500000, 0, 'Extranjero', 6, 'Inversionista estadounidense' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 12 AND NUMERO_UNIDAD = 'PC-103' LIMIT 1),
        '2024-05-05'::DATE, 6175000, 5.00, 'Contado', 6175000, 0, 'Extranjero', 6, 'Cliente de Texas' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 12 AND NUMERO_UNIDAD = 'PC-201' LIMIT 1),
        '2024-05-28'::DATE, 7200000, 0.00, 'Contado', 7200000, 0, 'Extranjero', 6, 'Vista frontal al mar' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 12 AND NUMERO_UNIDAD = 'PC-202' LIMIT 1),
        '2024-06-15'::DATE, 7200000, 0.00, 'Contado', 7200000, 0, 'Inversionista', 6, 'Para renta vacacional' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 12 AND NUMERO_UNIDAD = 'PC-301' LIMIT 1),
        '2024-07-10'::DATE, 8075000, 5.00, 'Contado', 8075000, 0, 'Extranjero', 6, 'Esquina premium' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 12 AND NUMERO_UNIDAD = 'PC-302' LIMIT 1),
        '2024-08-05'::DATE, 8500000, 0.00, 'Contado', 8500000, 0, 'Extranjero', 6, 'Cliente canadiense' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 12 AND NUMERO_UNIDAD = 'PC-401' LIMIT 1),
        '2024-09-01'::DATE, 9310000, 5.00, 'Contado', 9310000, 0, 'Extranjero', 6, 'Vista panorámica Caribe' 
    UNION ALL

    -- =========================================================================
    -- VENTAS DESARROLLO 9: Lofts Mérida Centro - 4 ventas adicionales
    -- =========================================================================
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 9 AND NUMERO_UNIDAD = 'L-203' LIMIT 1),
        '2024-06-10'::DATE, 2137500, 5.00, 'Hipoteca', 641250, 180, 'Usuario Final', 5, 'Loft con terraza' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 9 AND NUMERO_UNIDAD = 'L-204' LIMIT 1),
        '2024-07-05'::DATE, 2250000, 0.00, 'Contado', 2250000, 0, 'Inversionista', 5, 'Inversionista local' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 9 AND NUMERO_UNIDAD = 'L-301' LIMIT 1),
        '2024-08-15'::DATE, 2565000, 5.00, 'Hipoteca', 769500, 200, 'Usuario Final', 5, 'Doble altura hermosa' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 9 AND NUMERO_UNIDAD = 'L-302' LIMIT 1),
        '2024-09-20'::DATE, 2700000, 0.00, 'Mixto', 1080000, 120, 'Usuario Final', 5, 'Vista al centro histórico' 
    UNION ALL

    -- =========================================================================
    -- VENTAS DESARROLLO 7: Querétaro Business Park - 4 ventas adicionales
    -- =========================================================================
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 7 AND NUMERO_UNIDAD = 'OF-103' LIMIT 1),
        '2024-05-20'::DATE, 3100000, 0.00, 'Contado', 3100000, 0, 'Inversionista', 4, 'Empresa de tecnología' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 7 AND NUMERO_UNIDAD = 'OF-201' LIMIT 1),
        '2024-06-28'::DATE, 3277500, 5.00, 'Contado', 3277500, 0, 'Inversionista', 4, 'Consultora TI' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 7 AND NUMERO_UNIDAD = 'OF-202' LIMIT 1),
        '2024-08-10'::DATE, 3450000, 0.00, 'Contado', 3450000, 0, 'Inversionista', 4, 'Consultora financiera' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 7 AND NUMERO_UNIDAD = 'OF-203' LIMIT 1),
        '2024-09-15'::DATE, 3610000, 5.00, 'Contado', 3610000, 0, 'Inversionista', 4, 'Despacho legal' 
    UNION ALL

    -- =========================================================================
    -- VENTAS DESARROLLO 11: Marina Cancún - 5 ventas adicionales
    -- =========================================================================
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 11 AND NUMERO_UNIDAD = '203' LIMIT 1),
        '2024-06-05'::DATE, 5800000, 0.00, 'Contado', 5800000, 0, 'Extranjero', 6, 'Vista a marina' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 11 AND NUMERO_UNIDAD = '204' LIMIT 1),
        '2024-07-15'::DATE, 5510000, 5.00, 'Hipoteca', 1653000, 180, 'Usuario Final', 6, 'Cliente de CDMX' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 11 AND NUMERO_UNIDAD = '301' LIMIT 1),
        '2024-08-22'::DATE, 6900000, 0.00, 'Contado', 6900000, 0, 'Inversionista', 6, 'Inversionista mexicano' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 11 AND NUMERO_UNIDAD = '302' LIMIT 1),
        '2024-09-10'::DATE, 6555000, 5.00, 'Contado', 6555000, 0, 'Inversionista', 6, 'Compra para renta' 
    UNION ALL
    SELECT 
        (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 11 AND NUMERO_UNIDAD = '401' LIMIT 1),
        '2024-10-05'::DATE, 7800000, 0.00, 'Contado', 7800000, 0, 'Extranjero', 6, 'Premium floor vista mar'
);

-- ============================================================================
-- PARTE 3: Ajustar costos de construcción para lograr 70% de rentabilidad
-- ============================================================================

-- Eliminar costos anteriores de desarrollos que ajustaremos
DELETE FROM URBANOVA_SCHEMA.COSTOS_CONSTRUCCION 
WHERE DESARROLLO_ID IN (6, 9, 10);

-- Insertar nuevos costos optimizados para rentabilidad
INSERT INTO URBANOVA_SCHEMA.COSTOS_CONSTRUCCION
SELECT
    (SELECT COALESCE(MAX(COSTO_ID), 0) FROM URBANOVA_SCHEMA.COSTOS_CONSTRUCCION) + ROW_NUMBER() OVER (ORDER BY NULL) AS COSTO_ID,
    desarrollo_id,
    tipo_costo,
    descripcion,
    monto_mxn,
    porcentaje_total,
    fecha_registro,
    estatus_pago,
    comentario
FROM (
    -- =========================================================================
    -- Desarrollo 6: Andares Residencial (Guadalajara) - COSTOS OPTIMIZADOS
    -- Ingresos proyectados: ~$540M (75 unidades x $7.2M promedio)
    -- Costo objetivo: $380M (margen 30%)
    -- =========================================================================
    SELECT 6 AS desarrollo_id, 'Terreno' AS tipo_costo, 'Terreno premium Puerta de Hierro 3,800 m2' AS descripcion, 95000000 AS monto_mxn, 25.00 AS porcentaje_total, '2022-09-01'::DATE AS fecha_registro, 'Pagado' AS estatus_pago, 'Adquisición por debajo de mercado' AS comentario UNION ALL
    SELECT 6, 'Construcción', 'Torre residencial 75 unidades', 190000000, 50.00, '2023-02-14'::DATE, 'Parcial', 'Costos controlados' UNION ALL
    SELECT 6, 'Permisos', 'Licencias municipales Zapopan', 9500000, 2.50, '2022-11-20'::DATE, 'Pagado', 'Trámites eficientes' UNION ALL
    SELECT 6, 'Marketing', 'Preventa exclusiva', 19000000, 5.00, '2023-01-10'::DATE, 'Parcial', 'Marketing digital efectivo' UNION ALL
    SELECT 6, 'Financiero', 'Financiamiento', 38000000, 10.00, '2023-02-14'::DATE, 'Parcial', 'Tasa preferencial' UNION ALL
    SELECT 6, 'Otros', 'Contingencias', 28500000, 7.50, '2023-02-14'::DATE, 'Pendiente', 'Reserva controlada' UNION ALL
    
    -- =========================================================================
    -- Desarrollo 9: Lofts Mérida Centro - COSTOS OPTIMIZADOS
    -- Ingresos proyectados: ~$156M (60 unidades x $2.6M promedio)
    -- Costo objetivo: $105M (margen 33%)
    -- =========================================================================
    SELECT 9, 'Terreno', 'Terreno Centro Histórico 2,500 m2', 28000000, 26.67, '2022-01-10'::DATE, 'Pagado', 'Precio histórico favorable' UNION ALL
    SELECT 9, 'Construcción', 'Edificio de lofts 60 unidades', 52500000, 50.00, '2022-04-15'::DATE, 'Parcial', 'Rehabilitación eficiente' UNION ALL
    SELECT 9, 'Permisos', 'Licencias y permisos INAH', 3150000, 3.00, '2022-02-20'::DATE, 'Pagado', 'Zona patrimonial' UNION ALL
    SELECT 9, 'Marketing', 'Comercialización local', 5250000, 5.00, '2022-03-15'::DATE, 'Parcial', 'Marketing dirigido' UNION ALL
    SELECT 9, 'Financiero', 'Costos financieros', 10500000, 10.00, '2022-04-15'::DATE, 'Parcial', 'Financiamiento local' UNION ALL
    SELECT 9, 'Otros', 'Contingencias', 5600000, 5.33, '2022-04-15'::DATE, 'Pendiente', 'Reserva mínima' UNION ALL
    
    -- =========================================================================
    -- Desarrollo 10: Altabrisa Towers (Mérida) - COSTOS OPTIMIZADOS
    -- Ingresos proyectados: ~$520M (130 unidades x $4M promedio)
    -- Costo objetivo: $350M (margen 33%)
    -- =========================================================================
    SELECT 10, 'Terreno', 'Terreno Altabrisa 5,500 m2', 70000000, 20.00, '2023-01-15'::DATE, 'Pagado', 'Excelente ubicación' UNION ALL
    SELECT 10, 'Construcción', 'Torres gemelas 130 unidades', 175000000, 50.00, '2023-07-01'::DATE, 'Parcial', 'Economías de escala' UNION ALL
    SELECT 10, 'Permisos', 'Licencias municipales', 10500000, 3.00, '2023-04-10'::DATE, 'Pagado', 'Trámites ágiles' UNION ALL
    SELECT 10, 'Marketing', 'Preventa y comercialización', 17500000, 5.00, '2023-05-20'::DATE, 'Parcial', 'Campaña efectiva' UNION ALL
    SELECT 10, 'Financiero', 'Financiamiento construcción', 52500000, 15.00, '2023-07-01'::DATE, 'Parcial', 'Crédito puente' UNION ALL
    SELECT 10, 'Otros', 'Urbanización y amenidades', 24500000, 7.00, '2023-07-01'::DATE, 'Parcial', 'Áreas comunes premium'
);

-- ============================================================================
-- PARTE 4: Actualizar proyecciones de ventas
-- ============================================================================

INSERT INTO URBANOVA_SCHEMA.PROYECCIONES_VENTAS
SELECT
    (SELECT MAX(PROYECCION_ID) FROM URBANOVA_SCHEMA.PROYECCIONES_VENTAS) + ROW_NUMBER() OVER (ORDER BY NULL) AS PROYECCION_ID,
    desarrollo_id,
    mes_proyeccion,
    unidades_proyectadas,
    ingresos_proyectados_mxn,
    unidades_reales,
    ingresos_reales_mxn,
    variacion_unidades,
    variacion_ingresos_mxn,
    comentario
FROM (
    -- Desarrollo 6: Andares Residencial
    SELECT 6 AS desarrollo_id, '2024-08-01'::DATE AS mes_proyeccion, 3 AS unidades_proyectadas, 19500000 AS ingresos_proyectados_mxn, 2 AS unidades_reales, 13000000 AS ingresos_reales_mxn, -1 AS variacion_unidades, -6500000 AS variacion_ingresos_mxn, 'Agosto ligeramente bajo meta' AS comentario UNION ALL
    SELECT 6, '2024-09-01'::DATE, 3, 21000000, 3, 20800000, 0, -200000, 'Septiembre en meta' UNION ALL
    SELECT 6, '2024-10-01'::DATE, 4, 28000000, 1, 7125000, -3, -20875000, 'Octubre pendiente' UNION ALL
    
    -- Desarrollo 10: Altabrisa Towers
    SELECT 10, '2024-07-01'::DATE, 2, 7300000, 1, 3650000, -1, -3650000, 'Julio arrancando ventas' UNION ALL
    SELECT 10, '2024-08-01'::DATE, 3, 12600000, 1, 3990000, -2, -8610000, 'Agosto en ramp-up' UNION ALL
    SELECT 10, '2024-09-01'::DATE, 4, 17000000, 2, 8570000, -2, -8430000, 'Septiembre mejorando' UNION ALL
    
    -- Desarrollo 12: Playa Caracol
    SELECT 12, '2024-05-01'::DATE, 3, 21000000, 2, 13375000, -1, -7625000, 'Mayo inicio de ventas' UNION ALL
    SELECT 12, '2024-06-01'::DATE, 3, 22000000, 2, 14400000, -1, -7600000, 'Junio estable' UNION ALL
    SELECT 12, '2024-07-01'::DATE, 2, 17000000, 1, 8075000, -1, -8925000, 'Julio temporada baja' UNION ALL
    SELECT 12, '2024-08-01'::DATE, 2, 17000000, 1, 8500000, -1, -8500000, 'Agosto recuperando' UNION ALL
    SELECT 12, '2024-09-01'::DATE, 3, 28000000, 1, 9310000, -2, -18690000, 'Septiembre temporada alta'
);

-- ============================================================================
-- PARTE 5: Ventas Históricas 2023 y más ventas 2024
-- ============================================================================

-- Agregar más propiedades vendidas para el historial 2023
INSERT INTO URBANOVA_SCHEMA.PROPIEDADES
SELECT
    (SELECT MAX(PROPIEDAD_ID) FROM URBANOVA_SCHEMA.PROPIEDADES) + ROW_NUMBER() OVER (ORDER BY NULL) AS PROPIEDAD_ID,
    desarrollo_id,
    tipo_propiedad,
    numero_unidad,
    nivel_piso,
    superficie_m2,
    recamaras,
    banos,
    estacionamientos,
    precio_lista_mxn,
    ROUND(precio_lista_mxn / superficie_m2, 2) AS precio_m2_mxn,
    estatus_inventario,
    fecha_actualizacion,
    comentario
FROM (
    -- =========================================================================
    -- VENTAS 2023 - Desarrollo 5: Punto Sao Paulo (ENTREGADO)
    -- =========================================================================
    SELECT 5 AS desarrollo_id, 'Departamento' AS tipo_propiedad, '101' AS numero_unidad, 1 AS nivel_piso, 85.0 AS superficie_m2, 2 AS recamaras, 2.0 AS banos, 1 AS estacionamientos, 2950000 AS precio_lista_mxn, 'Escriturado' AS estatus_inventario, '2023-02-15'::DATE AS fecha_actualizacion, 'Vendido 2023' AS comentario UNION ALL
    SELECT 5, 'Departamento', '102', 1, 85.0, 2, 2.0, 1, 2950000, 'Escriturado', '2023-03-10'::DATE, 'Vendido 2023' UNION ALL
    SELECT 5, 'Departamento', '103', 1, 90.0, 2, 2.0, 1, 3100000, 'Escriturado', '2023-04-20'::DATE, 'Vendido 2023' UNION ALL
    SELECT 5, 'Departamento', '201', 2, 88.0, 2, 2.0, 1, 3050000, 'Escriturado', '2023-05-15'::DATE, 'Vendido 2023' UNION ALL
    SELECT 5, 'Departamento', '202', 2, 88.0, 2, 2.0, 1, 3050000, 'Escriturado', '2023-06-08'::DATE, 'Vendido 2023' UNION ALL
    SELECT 5, 'Departamento', '203', 2, 92.0, 2, 2.0, 2, 3300000, 'Escriturado', '2023-07-22'::DATE, 'Vendido 2023' UNION ALL
    SELECT 5, 'Departamento', '302', 3, 90.0, 2, 2.0, 1, 3150000, 'Escriturado', '2023-08-14'::DATE, 'Vendido 2023' UNION ALL
    SELECT 5, 'Departamento', '303', 3, 95.0, 2, 2.0, 2, 3500000, 'Escriturado', '2023-09-05'::DATE, 'Vendido 2023' UNION ALL
    SELECT 5, 'Departamento', '401', 4, 88.0, 2, 2.0, 1, 3200000, 'Escriturado', '2023-10-18'::DATE, 'Vendido 2023' UNION ALL
    SELECT 5, 'Departamento', '402', 4, 95.0, 2, 2.0, 2, 3600000, 'Escriturado', '2023-11-25'::DATE, 'Vendido 2023' UNION ALL
    SELECT 5, 'Departamento', '403', 4, 100.0, 3, 2.5, 2, 3900000, 'Escriturado', '2023-12-10'::DATE, 'Vendido 2023' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2023 - Desarrollo 1: Bosques de Santa Fe (CDMX)
    -- =========================================================================
    SELECT 1, 'Departamento', '103', 1, 88.0, 2, 2.0, 1, 4350000, 'Vendido', '2023-06-15'::DATE, 'Vendido preventa 2023' UNION ALL
    SELECT 1, 'Departamento', '104', 1, 88.0, 2, 2.0, 1, 4350000, 'Vendido', '2023-07-20'::DATE, 'Vendido preventa 2023' UNION ALL
    SELECT 1, 'Departamento', '202', 2, 95.0, 2, 2.0, 2, 5100000, 'Vendido', '2023-08-10'::DATE, 'Vendido 2023' UNION ALL
    SELECT 1, 'Departamento', '203', 2, 100.0, 3, 2.5, 2, 5500000, 'Vendido', '2023-09-25'::DATE, 'Vendido 2023' UNION ALL
    SELECT 1, 'Departamento', '302', 3, 115.0, 3, 2.5, 2, 6500000, 'Vendido', '2023-10-15'::DATE, 'Vendido 2023' UNION ALL
    SELECT 1, 'Departamento', '303', 3, 120.0, 3, 2.5, 2, 6800000, 'Vendido', '2023-11-08'::DATE, 'Vendido 2023' UNION ALL
    SELECT 1, 'Departamento', '401', 4, 125.0, 3, 3.0, 2, 7200000, 'Vendido', '2023-12-05'::DATE, 'Cierre de año 2023' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2023 - Desarrollo 2: Torre Polanco (CDMX)
    -- =========================================================================
    SELECT 2, 'Departamento', 'A-601', 6, 115.0, 2, 2.0, 2, 7500000, 'Vendido', '2023-03-18'::DATE, 'Vendido preventa 2023' UNION ALL
    SELECT 2, 'Departamento', 'A-701', 7, 115.0, 2, 2.0, 2, 7800000, 'Vendido', '2023-05-22'::DATE, 'Vendido 2023' UNION ALL
    SELECT 2, 'Departamento', 'A-801', 8, 120.0, 3, 2.5, 2, 8500000, 'Vendido', '2023-07-14'::DATE, 'Vendido 2023' UNION ALL
    SELECT 2, 'Departamento', 'B-601', 6, 130.0, 3, 2.5, 2, 9200000, 'Vendido', '2023-09-08'::DATE, 'Vendido 2023' UNION ALL
    SELECT 2, 'Departamento', 'B-701', 7, 130.0, 3, 2.5, 2, 9500000, 'Vendido', '2023-11-12'::DATE, 'Vendido 2023' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2023 - Desarrollo 3: Residencial Valle Oriente (Monterrey)
    -- =========================================================================
    SELECT 3, 'Departamento', '103', 1, 95.0, 2, 2.0, 2, 3950000, 'Vendido', '2023-04-12'::DATE, 'Vendido 2023' UNION ALL
    SELECT 3, 'Departamento', '104', 1, 95.0, 2, 2.0, 2, 3950000, 'Vendido', '2023-05-28'::DATE, 'Vendido 2023' UNION ALL
    SELECT 3, 'Departamento', '201', 2, 100.0, 3, 2.5, 2, 4300000, 'Vendido', '2023-07-15'::DATE, 'Vendido 2023' UNION ALL
    SELECT 3, 'Departamento', '202', 2, 100.0, 3, 2.5, 2, 4300000, 'Vendido', '2023-09-20'::DATE, 'Vendido 2023' UNION ALL
    SELECT 3, 'Departamento', '301', 3, 108.0, 3, 2.5, 2, 4700000, 'Vendido', '2023-11-05'::DATE, 'Vendido 2023' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2023 - Desarrollo 4: Cumbres Platinum (Monterrey)
    -- =========================================================================
    SELECT 4, 'Casa', 'C-01', 0, 175.0, 3, 3.0, 2, 5700000, 'Vendido', '2023-06-10'::DATE, 'Primera venta 2023' UNION ALL
    SELECT 4, 'Casa', 'C-02', 0, 175.0, 3, 3.0, 2, 5700000, 'Vendido', '2023-07-25'::DATE, 'Vendido 2023' UNION ALL
    SELECT 4, 'Casa', 'C-03', 0, 180.0, 3, 3.0, 2, 5900000, 'Vendido', '2023-08-18'::DATE, 'Vendido 2023' UNION ALL
    SELECT 4, 'Townhouse', 'T-01', 0, 140.0, 3, 2.5, 2, 4600000, 'Vendido', '2023-09-22'::DATE, 'Vendido 2023' UNION ALL
    SELECT 4, 'Townhouse', 'T-02', 0, 140.0, 3, 2.5, 2, 4600000, 'Vendido', '2023-10-30'::DATE, 'Vendido 2023' UNION ALL
    SELECT 4, 'Casa', 'C-04', 0, 185.0, 4, 3.5, 2, 6200000, 'Vendido', '2023-12-15'::DATE, 'Cierre año 2023' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2023 - Desarrollo 8: Villas del Marqués (Querétaro)
    -- =========================================================================
    SELECT 8, 'Casa', 'V-01', 0, 160.0, 3, 2.5, 2, 3650000, 'Vendido', '2023-05-08'::DATE, 'Primera venta 2023' UNION ALL
    SELECT 8, 'Casa', 'V-02', 0, 160.0, 3, 2.5, 2, 3650000, 'Vendido', '2023-06-22'::DATE, 'Vendido 2023' UNION ALL
    SELECT 8, 'Casa', 'V-03', 0, 165.0, 3, 2.5, 2, 3800000, 'Vendido', '2023-07-18'::DATE, 'Vendido 2023' UNION ALL
    SELECT 8, 'Townhouse', 'TH-01', 0, 130.0, 2, 2.5, 2, 3050000, 'Vendido', '2023-08-25'::DATE, 'Vendido 2023' UNION ALL
    SELECT 8, 'Townhouse', 'TH-02', 0, 130.0, 2, 2.5, 2, 3050000, 'Vendido', '2023-09-15'::DATE, 'Vendido 2023' UNION ALL
    SELECT 8, 'Casa', 'V-04', 0, 170.0, 3, 3.0, 2, 4000000, 'Vendido', '2023-10-28'::DATE, 'Vendido 2023' UNION ALL
    SELECT 8, 'Casa', 'V-05', 0, 175.0, 4, 3.0, 2, 4200000, 'Vendido', '2023-11-20'::DATE, 'Vendido 2023' UNION ALL
    SELECT 8, 'Casa', 'V-06', 0, 180.0, 4, 3.0, 3, 4500000, 'Vendido', '2023-12-08'::DATE, 'Cierre año 2023' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2024 ADICIONALES - Desarrollo 1: Bosques de Santa Fe
    -- =========================================================================
    SELECT 1, 'Departamento', '402', 4, 125.0, 3, 3.0, 2, 7200000, 'Vendido', '2024-01-20'::DATE, 'Inicio 2024' UNION ALL
    SELECT 1, 'Departamento', '403', 4, 130.0, 3, 3.0, 2, 7500000, 'Vendido', '2024-02-15'::DATE, 'Vendido 2024' UNION ALL
    SELECT 1, 'Departamento', '501', 5, 135.0, 3, 3.0, 2, 7800000, 'Vendido', '2024-03-22'::DATE, 'Vendido 2024' UNION ALL
    SELECT 1, 'Departamento', '502', 5, 140.0, 3, 3.0, 2, 8200000, 'Vendido', '2024-05-10'::DATE, 'Vendido 2024' UNION ALL
    SELECT 1, 'Departamento', '601', 6, 145.0, 3, 3.5, 2, 8600000, 'Vendido', '2024-06-28'::DATE, 'Vendido 2024' UNION ALL
    SELECT 1, 'Departamento', '602', 6, 150.0, 4, 3.5, 2, 9000000, 'Apartado', '2024-08-15'::DATE, 'En proceso' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2024 ADICIONALES - Desarrollo 2: Torre Polanco
    -- =========================================================================
    SELECT 2, 'Departamento', 'A-901', 9, 125.0, 3, 2.5, 2, 9000000, 'Vendido', '2024-01-25'::DATE, 'Inicio 2024' UNION ALL
    SELECT 2, 'Departamento', 'A-1001', 10, 130.0, 3, 3.0, 2, 9500000, 'Vendido', '2024-03-12'::DATE, 'Vendido 2024' UNION ALL
    SELECT 2, 'Departamento', 'B-901', 9, 145.0, 3, 3.0, 2, 10500000, 'Vendido', '2024-05-08'::DATE, 'Vendido 2024' UNION ALL
    SELECT 2, 'Departamento', 'B-1001', 10, 150.0, 4, 3.0, 2, 11000000, 'Vendido', '2024-07-18'::DATE, 'Vendido 2024' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2024 ADICIONALES - Desarrollo 3: Valle Oriente
    -- =========================================================================
    SELECT 3, 'Departamento', '302', 3, 108.0, 3, 2.5, 2, 4700000, 'Vendido', '2024-01-15'::DATE, 'Inicio 2024' UNION ALL
    SELECT 3, 'Departamento', '303', 3, 110.0, 3, 2.5, 2, 4850000, 'Vendido', '2024-02-28'::DATE, 'Vendido 2024' UNION ALL
    SELECT 3, 'Departamento', '401', 4, 112.0, 3, 2.5, 2, 5000000, 'Vendido', '2024-04-10'::DATE, 'Vendido 2024' UNION ALL
    SELECT 3, 'Departamento', '402', 4, 115.0, 3, 2.5, 2, 5200000, 'Vendido', '2024-06-05'::DATE, 'Vendido 2024' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2024 ADICIONALES - Desarrollo 4: Cumbres Platinum
    -- =========================================================================
    SELECT 4, 'Casa', 'C-05', 0, 185.0, 4, 3.5, 2, 6200000, 'Vendido', '2024-01-28'::DATE, 'Inicio 2024' UNION ALL
    SELECT 4, 'Casa', 'C-06', 0, 190.0, 4, 3.5, 3, 6500000, 'Vendido', '2024-03-15'::DATE, 'Vendido 2024' UNION ALL
    SELECT 4, 'Townhouse', 'T-03', 0, 145.0, 3, 2.5, 2, 4800000, 'Vendido', '2024-04-22'::DATE, 'Vendido 2024' UNION ALL
    SELECT 4, 'Townhouse', 'T-04', 0, 145.0, 3, 2.5, 2, 4800000, 'Vendido', '2024-06-18'::DATE, 'Vendido 2024' UNION ALL
    SELECT 4, 'Casa', 'C-07', 0, 195.0, 4, 3.5, 3, 6800000, 'Vendido', '2024-08-10'::DATE, 'Vendido 2024' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2024 ADICIONALES - Desarrollo 8: Villas del Marqués
    -- =========================================================================
    SELECT 8, 'Casa', 'V-07', 0, 180.0, 4, 3.0, 3, 4500000, 'Vendido', '2024-01-18'::DATE, 'Inicio 2024' UNION ALL
    SELECT 8, 'Casa', 'V-08', 0, 185.0, 4, 3.0, 3, 4700000, 'Vendido', '2024-02-25'::DATE, 'Vendido 2024' UNION ALL
    SELECT 8, 'Townhouse', 'TH-03', 0, 135.0, 2, 2.5, 2, 3200000, 'Vendido', '2024-03-20'::DATE, 'Vendido 2024' UNION ALL
    SELECT 8, 'Townhouse', 'TH-04', 0, 135.0, 2, 2.5, 2, 3200000, 'Vendido', '2024-04-28'::DATE, 'Vendido 2024' UNION ALL
    SELECT 8, 'Casa', 'V-09', 0, 190.0, 4, 3.5, 3, 4900000, 'Vendido', '2024-06-12'::DATE, 'Vendido 2024' UNION ALL
    SELECT 8, 'Casa', 'V-12', 0, 195.0, 4, 3.5, 3, 5100000, 'Vendido', '2024-08-05'::DATE, 'Vendido 2024' UNION ALL
    SELECT 8, 'Casa', 'V-13', 0, 200.0, 4, 4.0, 3, 5400000, 'Apartado', '2024-10-01'::DATE, 'En proceso'
);

-- =========================================================================
-- INSERTAR VENTAS HISTÓRICAS 2023
-- =========================================================================
INSERT INTO URBANOVA_SCHEMA.VENTAS
SELECT
    (SELECT MAX(VENTA_ID) FROM URBANOVA_SCHEMA.VENTAS) + ROW_NUMBER() OVER (ORDER BY NULL) AS VENTA_ID,
    propiedad_id,
    fecha_venta,
    precio_venta_mxn,
    descuento_aplicado_pct,
    metodo_financiamiento,
    enganche_mxn,
    meses_financiamiento,
    tipo_cliente,
    agente_id,
    comentario
FROM (
    -- =========================================================================
    -- VENTAS 2023 - Desarrollo 5: Punto Sao Paulo (Guadalajara) - 11 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 5 AND NUMERO_UNIDAD = '101' AND COMENTARIO LIKE '%2023%' LIMIT 1) AS propiedad_id,
        '2023-02-15'::DATE AS fecha_venta, 2802500 AS precio_venta_mxn, 5.00 AS descuento_aplicado_pct, 
        'Hipoteca' AS metodo_financiamiento, 840750 AS enganche_mxn, 180 AS meses_financiamiento, 
        'Usuario Final' AS tipo_cliente, 3 AS agente_id, 'Preventa 2023' AS comentario UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 5 AND NUMERO_UNIDAD = '102' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-03-10'::DATE, 2950000, 0.00, 'Crédito Infonavit', 590000, 240, 'Usuario Final', 3, 'Infonavit 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 5 AND NUMERO_UNIDAD = '103' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-04-20'::DATE, 3100000, 0.00, 'Hipoteca', 930000, 200, 'Usuario Final', 3, 'Venta 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 5 AND NUMERO_UNIDAD = '201' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-05-15'::DATE, 2897500, 5.00, 'Mixto', 1159000, 180, 'Usuario Final', 3, 'Descuento mayo' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 5 AND NUMERO_UNIDAD = '202' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-06-08'::DATE, 3050000, 0.00, 'Hipoteca', 915000, 240, 'Usuario Final', 3, 'Venta junio' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 5 AND NUMERO_UNIDAD = '203' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-07-22'::DATE, 3135000, 5.00, 'Contado', 3135000, 0, 'Inversionista', 3, 'Contado julio' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 5 AND NUMERO_UNIDAD = '302' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-08-14'::DATE, 3150000, 0.00, 'Hipoteca', 945000, 180, 'Usuario Final', 3, 'Venta agosto' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 5 AND NUMERO_UNIDAD = '303' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-09-05'::DATE, 3500000, 0.00, 'Mixto', 1400000, 120, 'Usuario Final', 3, 'Septiembre' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 5 AND NUMERO_UNIDAD = '401' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-10-18'::DATE, 3040000, 5.00, 'Crédito Infonavit', 608000, 240, 'Usuario Final', 3, 'Octubre' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 5 AND NUMERO_UNIDAD = '402' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-11-25'::DATE, 3600000, 0.00, 'Contado', 3600000, 0, 'Inversionista', 3, 'Contado noviembre' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 5 AND NUMERO_UNIDAD = '403' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-12-10'::DATE, 3705000, 5.00, 'Hipoteca', 1111500, 180, 'Usuario Final', 3, 'Cierre 2023' UNION ALL

    -- =========================================================================
    -- VENTAS 2023 - Desarrollo 1: Bosques de Santa Fe (CDMX) - 7 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '103' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-06-15'::DATE, 4132500, 5.00, 'Hipoteca', 1239750, 240, 'Usuario Final', 1, 'Preventa 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '104' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-07-20'::DATE, 4350000, 0.00, 'Mixto', 1740000, 180, 'Usuario Final', 1, 'Julio 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '202' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-08-10'::DATE, 4845000, 5.00, 'Hipoteca', 1453500, 240, 'Usuario Final', 1, 'Agosto 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '203' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-09-25'::DATE, 5500000, 0.00, 'Contado', 5500000, 0, 'Inversionista', 1, 'Contado sept' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '302' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-10-15'::DATE, 6175000, 5.00, 'Mixto', 2470000, 180, 'Usuario Final', 7, 'Octubre 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '303' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-11-08'::DATE, 6800000, 0.00, 'Hipoteca', 2040000, 240, 'Usuario Final', 7, 'Noviembre 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '401' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-12-05'::DATE, 6840000, 5.00, 'Contado', 6840000, 0, 'Inversionista', 7, 'Cierre 2023' UNION ALL

    -- =========================================================================
    -- VENTAS 2023 - Desarrollo 2: Torre Polanco (CDMX) - 5 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 2 AND NUMERO_UNIDAD = 'A-601' LIMIT 1),
        '2023-03-18'::DATE, 7125000, 5.00, 'Hipoteca', 2137500, 240, 'Usuario Final', 1, 'Preventa 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 2 AND NUMERO_UNIDAD = 'A-701' LIMIT 1),
        '2023-05-22'::DATE, 7800000, 0.00, 'Contado', 7800000, 0, 'Inversionista', 1, 'Contado mayo' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 2 AND NUMERO_UNIDAD = 'A-801' LIMIT 1),
        '2023-07-14'::DATE, 8075000, 5.00, 'Mixto', 3230000, 180, 'Usuario Final', 1, 'Julio 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 2 AND NUMERO_UNIDAD = 'B-601' LIMIT 1),
        '2023-09-08'::DATE, 9200000, 0.00, 'Hipoteca', 2760000, 240, 'Usuario Final', 7, 'Sept 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 2 AND NUMERO_UNIDAD = 'B-701' LIMIT 1),
        '2023-11-12'::DATE, 9025000, 5.00, 'Contado', 9025000, 0, 'Extranjero', 7, 'Inversionista extranjero' UNION ALL

    -- =========================================================================
    -- VENTAS 2023 - Desarrollo 3: Valle Oriente (Monterrey) - 5 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 3 AND NUMERO_UNIDAD = '103' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-04-12'::DATE, 3752500, 5.00, 'Crédito Infonavit', 750500, 240, 'Usuario Final', 2, 'Infonavit 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 3 AND NUMERO_UNIDAD = '104' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-05-28'::DATE, 3950000, 0.00, 'Hipoteca', 1185000, 200, 'Usuario Final', 2, 'Mayo 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 3 AND NUMERO_UNIDAD = '201' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-07-15'::DATE, 4085000, 5.00, 'Mixto', 1634000, 180, 'Usuario Final', 2, 'Julio 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 3 AND NUMERO_UNIDAD = '202' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-09-20'::DATE, 4300000, 0.00, 'Hipoteca', 1290000, 240, 'Usuario Final', 2, 'Sept 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 3 AND NUMERO_UNIDAD = '301' AND COMENTARIO LIKE '%2023%' LIMIT 1),
        '2023-11-05'::DATE, 4465000, 5.00, 'Contado', 4465000, 0, 'Inversionista', 2, 'Noviembre 2023' UNION ALL

    -- =========================================================================
    -- VENTAS 2023 - Desarrollo 4: Cumbres Platinum (Monterrey) - 6 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'C-01' LIMIT 1),
        '2023-06-10'::DATE, 5415000, 5.00, 'Hipoteca', 1624500, 240, 'Usuario Final', 2, 'Primera venta' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'C-02' LIMIT 1),
        '2023-07-25'::DATE, 5700000, 0.00, 'Mixto', 2280000, 180, 'Usuario Final', 2, 'Julio 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'C-03' LIMIT 1),
        '2023-08-18'::DATE, 5605000, 5.00, 'Crédito Infonavit', 1121000, 240, 'Usuario Final', 2, 'Agosto 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'T-01' LIMIT 1),
        '2023-09-22'::DATE, 4370000, 5.00, 'Hipoteca', 1311000, 200, 'Usuario Final', 2, 'Townhouse sept' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'T-02' LIMIT 1),
        '2023-10-30'::DATE, 4600000, 0.00, 'Hipoteca', 1380000, 180, 'Usuario Final', 2, 'Octubre 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'C-04' LIMIT 1),
        '2023-12-15'::DATE, 5890000, 5.00, 'Contado', 5890000, 0, 'Inversionista', 2, 'Cierre año 2023' UNION ALL

    -- =========================================================================
    -- VENTAS 2023 - Desarrollo 8: Villas del Marqués (Querétaro) - 8 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'V-01' LIMIT 1),
        '2023-05-08'::DATE, 3467500, 5.00, 'Crédito Infonavit', 693500, 240, 'Usuario Final', 4, 'Primera venta 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'V-02' LIMIT 1),
        '2023-06-22'::DATE, 3650000, 0.00, 'Hipoteca', 1095000, 200, 'Usuario Final', 4, 'Junio 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'V-03' LIMIT 1),
        '2023-07-18'::DATE, 3610000, 5.00, 'Mixto', 1444000, 180, 'Usuario Final', 4, 'Julio 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'TH-01' LIMIT 1),
        '2023-08-25'::DATE, 2897500, 5.00, 'Crédito Infonavit', 579500, 240, 'Usuario Final', 4, 'Townhouse agosto' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'TH-02' LIMIT 1),
        '2023-09-15'::DATE, 3050000, 0.00, 'Hipoteca', 915000, 180, 'Usuario Final', 4, 'Sept 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'V-04' LIMIT 1),
        '2023-10-28'::DATE, 3800000, 5.00, 'Mixto', 1520000, 180, 'Usuario Final', 4, 'Octubre 2023' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'V-05' LIMIT 1),
        '2023-11-20'::DATE, 4200000, 0.00, 'Contado', 4200000, 0, 'Inversionista', 4, 'Contado nov' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'V-06' LIMIT 1),
        '2023-12-08'::DATE, 4275000, 5.00, 'Hipoteca', 1282500, 240, 'Usuario Final', 4, 'Cierre 2023' UNION ALL

    -- =========================================================================
    -- VENTAS 2024 ADICIONALES - Desarrollo 1: Bosques de Santa Fe - 5 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '402' AND COMENTARIO LIKE '%2024%' LIMIT 1),
        '2024-01-20'::DATE, 6840000, 5.00, 'Hipoteca', 2052000, 240, 'Usuario Final', 1, 'Inicio 2024' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '403' AND COMENTARIO LIKE '%2024%' LIMIT 1),
        '2024-02-15'::DATE, 7500000, 0.00, 'Mixto', 3000000, 180, 'Usuario Final', 1, 'Febrero 2024' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '501' AND COMENTARIO LIKE '%2024%' LIMIT 1),
        '2024-03-22'::DATE, 7410000, 5.00, 'Hipoteca', 2223000, 240, 'Usuario Final', 1, 'Marzo 2024' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '502' AND COMENTARIO LIKE '%2024%' LIMIT 1),
        '2024-05-10'::DATE, 8200000, 0.00, 'Contado', 8200000, 0, 'Inversionista', 7, 'Mayo contado' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '601' AND COMENTARIO LIKE '%2024%' LIMIT 1),
        '2024-06-28'::DATE, 8170000, 5.00, 'Mixto', 3268000, 180, 'Usuario Final', 7, 'Junio 2024' UNION ALL

    -- =========================================================================
    -- VENTAS 2024 ADICIONALES - Desarrollo 2: Torre Polanco - 4 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 2 AND NUMERO_UNIDAD = 'A-901' LIMIT 1),
        '2024-01-25'::DATE, 8550000, 5.00, 'Hipoteca', 2565000, 240, 'Usuario Final', 1, 'Enero 2024' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 2 AND NUMERO_UNIDAD = 'A-1001' LIMIT 1),
        '2024-03-12'::DATE, 9500000, 0.00, 'Contado', 9500000, 0, 'Extranjero', 1, 'Contado marzo' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 2 AND NUMERO_UNIDAD = 'B-901' LIMIT 1),
        '2024-05-08'::DATE, 9975000, 5.00, 'Mixto', 3990000, 180, 'Inversionista', 7, 'Mayo 2024' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 2 AND NUMERO_UNIDAD = 'B-1001' LIMIT 1),
        '2024-07-18'::DATE, 11000000, 0.00, 'Contado', 11000000, 0, 'Extranjero', 7, 'Julio contado' UNION ALL

    -- =========================================================================
    -- VENTAS 2024 ADICIONALES - Desarrollo 3: Valle Oriente - 4 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 3 AND NUMERO_UNIDAD = '302' AND COMENTARIO LIKE '%2024%' LIMIT 1),
        '2024-01-15'::DATE, 4465000, 5.00, 'Hipoteca', 1339500, 200, 'Usuario Final', 2, 'Enero 2024' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 3 AND NUMERO_UNIDAD = '303' AND COMENTARIO LIKE '%2024%' LIMIT 1),
        '2024-02-28'::DATE, 4850000, 0.00, 'Mixto', 1940000, 180, 'Usuario Final', 2, 'Febrero 2024' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 3 AND NUMERO_UNIDAD = '401' AND COMENTARIO LIKE '%2024%' LIMIT 1),
        '2024-04-10'::DATE, 4750000, 5.00, 'Crédito Infonavit', 950000, 240, 'Usuario Final', 2, 'Abril 2024' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 3 AND NUMERO_UNIDAD = '402' AND COMENTARIO LIKE '%2024%' LIMIT 1),
        '2024-06-05'::DATE, 5200000, 0.00, 'Hipoteca', 1560000, 240, 'Usuario Final', 2, 'Junio 2024' UNION ALL

    -- =========================================================================
    -- VENTAS 2024 ADICIONALES - Desarrollo 4: Cumbres Platinum - 5 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'C-05' LIMIT 1),
        '2024-01-28'::DATE, 5890000, 5.00, 'Hipoteca', 1767000, 240, 'Usuario Final', 2, 'Enero 2024' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'C-06' LIMIT 1),
        '2024-03-15'::DATE, 6175000, 5.00, 'Mixto', 2470000, 180, 'Usuario Final', 2, 'Marzo 2024' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'T-03' LIMIT 1),
        '2024-04-22'::DATE, 4560000, 5.00, 'Crédito Infonavit', 912000, 240, 'Usuario Final', 2, 'Abril TH' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'T-04' LIMIT 1),
        '2024-06-18'::DATE, 4800000, 0.00, 'Hipoteca', 1440000, 200, 'Usuario Final', 2, 'Junio TH' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'C-07' LIMIT 1),
        '2024-08-10'::DATE, 6460000, 5.00, 'Contado', 6460000, 0, 'Inversionista', 2, 'Agosto contado' UNION ALL

    -- =========================================================================
    -- VENTAS 2024 ADICIONALES - Desarrollo 8: Villas del Marqués - 6 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'V-07' LIMIT 1),
        '2024-01-18'::DATE, 4275000, 5.00, 'Hipoteca', 1282500, 240, 'Usuario Final', 4, 'Enero 2024' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'V-08' LIMIT 1),
        '2024-02-25'::DATE, 4465000, 5.00, 'Mixto', 1786000, 180, 'Usuario Final', 4, 'Febrero 2024' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'TH-03' LIMIT 1),
        '2024-03-20'::DATE, 3040000, 5.00, 'Crédito Infonavit', 608000, 240, 'Usuario Final', 4, 'Marzo TH' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'TH-04' LIMIT 1),
        '2024-04-28'::DATE, 3200000, 0.00, 'Hipoteca', 960000, 200, 'Usuario Final', 4, 'Abril TH' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'V-09' LIMIT 1),
        '2024-06-12'::DATE, 4655000, 5.00, 'Mixto', 1862000, 180, 'Usuario Final', 4, 'Junio 2024' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'V-12' LIMIT 1),
        '2024-08-05'::DATE, 5100000, 0.00, 'Contado', 5100000, 0, 'Inversionista', 4, 'Agosto contado'
);

-- ============================================================================
-- PARTE 6: Ventas y Costos 2025
-- ============================================================================

-- =========================================================================
-- 6.1 PROPIEDADES VENDIDAS EN 2025
-- =========================================================================
INSERT INTO URBANOVA_SCHEMA.PROPIEDADES
SELECT
    (SELECT MAX(PROPIEDAD_ID) FROM URBANOVA_SCHEMA.PROPIEDADES) + ROW_NUMBER() OVER (ORDER BY NULL) AS PROPIEDAD_ID,
    desarrollo_id,
    tipo_propiedad,
    numero_unidad,
    nivel_piso,
    superficie_m2,
    recamaras,
    banos,
    estacionamientos,
    precio_lista_mxn,
    ROUND(precio_lista_mxn / superficie_m2, 2) AS precio_m2_mxn,
    estatus_inventario,
    fecha_actualizacion,
    comentario
FROM (
    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 1: Bosques de Santa Fe (CDMX)
    -- Precios con incremento ~5% vs 2024
    -- =========================================================================
    SELECT 1 AS desarrollo_id, 'Departamento' AS tipo_propiedad, '603' AS numero_unidad, 6 AS nivel_piso, 155.0 AS superficie_m2, 4 AS recamaras, 3.5 AS banos, 2 AS estacionamientos, 9450000 AS precio_lista_mxn, 'Vendido' AS estatus_inventario, '2025-01-18'::DATE AS fecha_actualizacion, 'Vendido 2025' AS comentario UNION ALL
    SELECT 1, 'Departamento', '701', 7, 160.0, 4, 3.5, 2, 9800000, 'Vendido', '2025-02-25'::DATE, 'Vendido 2025' UNION ALL
    SELECT 1, 'Departamento', '702', 7, 165.0, 4, 4.0, 3, 10200000, 'Vendido', '2025-04-10'::DATE, 'Vendido 2025' UNION ALL
    SELECT 1, 'Departamento', '801', 8, 170.0, 4, 4.0, 3, 10800000, 'Vendido', '2025-05-22'::DATE, 'Penthouse vendido' UNION ALL
    SELECT 1, 'Departamento', '802', 8, 175.0, 4, 4.0, 3, 11200000, 'Apartado', '2025-07-15'::DATE, 'En proceso 2025' UNION ALL
    SELECT 1, 'Departamento', 'PH-01', 9, 220.0, 5, 4.5, 3, 15500000, 'Apartado', '2025-09-01'::DATE, 'Penthouse premium' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 2: Torre Polanco (CDMX)
    -- =========================================================================
    SELECT 2, 'Departamento', 'A-1101', 11, 135.0, 3, 3.0, 2, 10000000, 'Vendido', '2025-01-28'::DATE, 'Inicio 2025' UNION ALL
    SELECT 2, 'Departamento', 'A-1201', 12, 140.0, 3, 3.0, 2, 10500000, 'Vendido', '2025-03-15'::DATE, 'Vendido 2025' UNION ALL
    SELECT 2, 'Departamento', 'B-1101', 11, 155.0, 4, 3.5, 2, 11800000, 'Vendido', '2025-05-08'::DATE, 'Vendido 2025' UNION ALL
    SELECT 2, 'Departamento', 'B-1201', 12, 160.0, 4, 3.5, 2, 12200000, 'Vendido', '2025-07-20'::DATE, 'Vendido 2025' UNION ALL
    SELECT 2, 'Departamento', 'PH-A', 13, 200.0, 4, 4.0, 3, 16500000, 'Apartado', '2025-09-10'::DATE, 'Penthouse torre A' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 3: Valle Oriente (Monterrey)
    -- =========================================================================
    SELECT 3, 'Departamento', '403', 4, 118.0, 3, 2.5, 2, 5450000, 'Vendido', '2025-01-22'::DATE, 'Inicio 2025' UNION ALL
    SELECT 3, 'Departamento', '501', 5, 120.0, 3, 2.5, 2, 5600000, 'Vendido', '2025-02-18'::DATE, 'Vendido 2025' UNION ALL
    SELECT 3, 'Departamento', '502', 5, 125.0, 3, 3.0, 2, 5900000, 'Vendido', '2025-04-05'::DATE, 'Vendido 2025' UNION ALL
    SELECT 3, 'Departamento', '503', 5, 130.0, 3, 3.0, 2, 6200000, 'Vendido', '2025-06-12'::DATE, 'Vendido 2025' UNION ALL
    SELECT 3, 'Departamento', '601', 6, 135.0, 4, 3.0, 2, 6600000, 'Apartado', '2025-08-25'::DATE, 'En proceso' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 4: Cumbres Platinum (Monterrey)
    -- =========================================================================
    SELECT 4, 'Casa', 'C-08', 0, 200.0, 4, 3.5, 3, 7200000, 'Vendido', '2025-01-15'::DATE, 'Primera venta 2025' UNION ALL
    SELECT 4, 'Casa', 'C-09', 0, 205.0, 4, 4.0, 3, 7500000, 'Vendido', '2025-03-08'::DATE, 'Vendido 2025' UNION ALL
    SELECT 4, 'Townhouse', 'T-05', 0, 150.0, 3, 2.5, 2, 5100000, 'Vendido', '2025-04-20'::DATE, 'Townhouse 2025' UNION ALL
    SELECT 4, 'Townhouse', 'T-06', 0, 150.0, 3, 2.5, 2, 5100000, 'Vendido', '2025-06-10'::DATE, 'Vendido 2025' UNION ALL
    SELECT 4, 'Casa', 'C-10', 0, 210.0, 4, 4.0, 3, 7800000, 'Vendido', '2025-08-15'::DATE, 'Casa premium' UNION ALL
    SELECT 4, 'Casa', 'C-11', 0, 215.0, 5, 4.5, 3, 8200000, 'Apartado', '2025-10-01'::DATE, 'En proceso' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 6: Andares Residencial (Guadalajara)
    -- =========================================================================
    SELECT 6, 'Departamento', 'A-701', 7, 130.0, 3, 2.5, 2, 6900000, 'Vendido', '2025-01-20'::DATE, 'Vendido 2025' UNION ALL
    SELECT 6, 'Departamento', 'A-801', 8, 135.0, 3, 3.0, 2, 7300000, 'Vendido', '2025-03-12'::DATE, 'Vendido 2025' UNION ALL
    SELECT 6, 'Departamento', 'B-601', 6, 160.0, 3, 3.0, 2, 8700000, 'Vendido', '2025-05-18'::DATE, 'Vendido 2025' UNION ALL
    SELECT 6, 'Departamento', 'B-701', 7, 165.0, 4, 3.5, 2, 9100000, 'Vendido', '2025-07-25'::DATE, 'Vendido 2025' UNION ALL
    SELECT 6, 'Departamento', 'PH-01', 10, 200.0, 4, 4.0, 3, 12500000, 'Apartado', '2025-09-15'::DATE, 'Penthouse' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 8: Villas del Marqués (Querétaro)
    -- =========================================================================
    SELECT 8, 'Casa', 'V-14', 0, 205.0, 4, 4.0, 3, 5700000, 'Vendido', '2025-01-25'::DATE, 'Vendido 2025' UNION ALL
    SELECT 8, 'Casa', 'V-15', 0, 210.0, 4, 4.0, 3, 5900000, 'Vendido', '2025-03-10'::DATE, 'Vendido 2025' UNION ALL
    SELECT 8, 'Townhouse', 'TH-05', 0, 140.0, 3, 2.5, 2, 3500000, 'Vendido', '2025-04-22'::DATE, 'Vendido 2025' UNION ALL
    SELECT 8, 'Townhouse', 'TH-06', 0, 140.0, 3, 2.5, 2, 3500000, 'Vendido', '2025-06-05'::DATE, 'Vendido 2025' UNION ALL
    SELECT 8, 'Casa', 'V-16', 0, 215.0, 4, 4.5, 3, 6200000, 'Vendido', '2025-08-18'::DATE, 'Vendido 2025' UNION ALL
    SELECT 8, 'Casa', 'V-17', 0, 220.0, 5, 4.5, 3, 6500000, 'Apartado', '2025-10-05'::DATE, 'En proceso' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 10: Altabrisa Towers (Mérida)
    -- =========================================================================
    SELECT 10, 'Departamento', 'T1-801', 8, 105.0, 2, 2.0, 2, 3900000, 'Vendido', '2025-02-05'::DATE, 'Vendido 2025' UNION ALL
    SELECT 10, 'Departamento', 'T1-901', 9, 110.0, 2, 2.0, 2, 4100000, 'Vendido', '2025-03-20'::DATE, 'Vendido 2025' UNION ALL
    SELECT 10, 'Departamento', 'T2-701', 7, 125.0, 3, 2.5, 2, 5000000, 'Vendido', '2025-05-12'::DATE, 'Vendido 2025' UNION ALL
    SELECT 10, 'Departamento', 'T2-801', 8, 130.0, 3, 3.0, 2, 5300000, 'Vendido', '2025-07-08'::DATE, 'Vendido 2025' UNION ALL
    SELECT 10, 'Departamento', 'T2-901', 9, 135.0, 3, 3.0, 2, 5600000, 'Apartado', '2025-09-20'::DATE, 'En proceso' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 11: Marina Cancún
    -- =========================================================================
    SELECT 11, 'Departamento', '403', 4, 140.0, 3, 2.5, 2, 8300000, 'Vendido', '2025-01-30'::DATE, 'Vendido 2025' UNION ALL
    SELECT 11, 'Departamento', '501', 5, 145.0, 3, 3.0, 2, 8800000, 'Vendido', '2025-04-15'::DATE, 'Vendido 2025' UNION ALL
    SELECT 11, 'Departamento', '502', 5, 150.0, 3, 3.0, 2, 9200000, 'Vendido', '2025-06-22'::DATE, 'Vendido 2025' UNION ALL
    SELECT 11, 'Departamento', 'PH-01', 6, 180.0, 4, 3.5, 2, 12500000, 'Apartado', '2025-08-30'::DATE, 'Penthouse marina' UNION ALL
    
    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 12: Playa Caracol (Cancún)
    -- =========================================================================
    SELECT 12, 'Departamento', 'PC-403', 4, 130.0, 3, 2.5, 2, 10500000, 'Vendido', '2025-02-10'::DATE, 'Vendido 2025' UNION ALL
    SELECT 12, 'Departamento', 'PC-501', 5, 135.0, 3, 3.0, 2, 11200000, 'Vendido', '2025-04-05'::DATE, 'Vendido 2025' UNION ALL
    SELECT 12, 'Departamento', 'PC-502', 5, 140.0, 3, 3.0, 2, 11800000, 'Vendido', '2025-06-18'::DATE, 'Vendido 2025' UNION ALL
    SELECT 12, 'Departamento', 'PC-601', 6, 150.0, 3, 3.0, 2, 13000000, 'Vendido', '2025-08-25'::DATE, 'Vista premium' UNION ALL
    SELECT 12, 'Departamento', 'PH-01', 7, 200.0, 4, 4.0, 3, 18500000, 'Apartado', '2025-10-10'::DATE, 'Penthouse Caribe'
);

-- =========================================================================
-- 6.2 VENTAS 2025
-- =========================================================================
INSERT INTO URBANOVA_SCHEMA.VENTAS
SELECT
    (SELECT MAX(VENTA_ID) FROM URBANOVA_SCHEMA.VENTAS) + ROW_NUMBER() OVER (ORDER BY NULL) AS VENTA_ID,
    propiedad_id,
    fecha_venta,
    precio_venta_mxn,
    descuento_aplicado_pct,
    metodo_financiamiento,
    enganche_mxn,
    meses_financiamiento,
    tipo_cliente,
    agente_id,
    comentario
FROM (
    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 1: Bosques de Santa Fe (CDMX) - 4 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '603' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1) AS propiedad_id,
        '2025-01-18'::DATE AS fecha_venta, 8977500 AS precio_venta_mxn, 5.00 AS descuento_aplicado_pct, 
        'Hipoteca' AS metodo_financiamiento, 2693250 AS enganche_mxn, 240 AS meses_financiamiento, 
        'Usuario Final' AS tipo_cliente, 1 AS agente_id, 'Primera venta 2025' AS comentario UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '701' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-02-25'::DATE, 9800000, 0.00, 'Mixto', 3920000, 180, 'Usuario Final', 1, 'Febrero 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '702' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-04-10'::DATE, 9690000, 5.00, 'Hipoteca', 2907000, 240, 'Usuario Final', 7, 'Abril 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 1 AND NUMERO_UNIDAD = '801' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-05-22'::DATE, 10800000, 0.00, 'Contado', 10800000, 0, 'Inversionista', 7, 'Penthouse contado' UNION ALL

    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 2: Torre Polanco (CDMX) - 4 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 2 AND NUMERO_UNIDAD = 'A-1101' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-01-28'::DATE, 9500000, 5.00, 'Hipoteca', 2850000, 240, 'Usuario Final', 1, 'Enero 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 2 AND NUMERO_UNIDAD = 'A-1201' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-03-15'::DATE, 10500000, 0.00, 'Contado', 10500000, 0, 'Extranjero', 1, 'Contado marzo' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 2 AND NUMERO_UNIDAD = 'B-1101' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-05-08'::DATE, 11210000, 5.00, 'Mixto', 4484000, 180, 'Inversionista', 7, 'Mayo 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 2 AND NUMERO_UNIDAD = 'B-1201' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-07-20'::DATE, 12200000, 0.00, 'Contado', 12200000, 0, 'Extranjero', 7, 'Julio contado' UNION ALL

    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 3: Valle Oriente (Monterrey) - 4 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 3 AND NUMERO_UNIDAD = '403' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-01-22'::DATE, 5177500, 5.00, 'Crédito Infonavit', 1035500, 240, 'Usuario Final', 2, 'Infonavit 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 3 AND NUMERO_UNIDAD = '501' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-02-18'::DATE, 5600000, 0.00, 'Hipoteca', 1680000, 200, 'Usuario Final', 2, 'Febrero 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 3 AND NUMERO_UNIDAD = '502' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-04-05'::DATE, 5605000, 5.00, 'Mixto', 2242000, 180, 'Usuario Final', 2, 'Abril 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 3 AND NUMERO_UNIDAD = '503' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-06-12'::DATE, 6200000, 0.00, 'Contado', 6200000, 0, 'Inversionista', 2, 'Junio contado' UNION ALL

    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 4: Cumbres Platinum (Monterrey) - 5 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'C-08' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-01-15'::DATE, 6840000, 5.00, 'Hipoteca', 2052000, 240, 'Usuario Final', 2, 'Primera 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'C-09' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-03-08'::DATE, 7500000, 0.00, 'Mixto', 3000000, 180, 'Usuario Final', 2, 'Marzo 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'T-05' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-04-20'::DATE, 4845000, 5.00, 'Crédito Infonavit', 969000, 240, 'Usuario Final', 2, 'Abril TH' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'T-06' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-06-10'::DATE, 5100000, 0.00, 'Hipoteca', 1530000, 200, 'Usuario Final', 2, 'Junio TH' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 4 AND NUMERO_UNIDAD = 'C-10' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-08-15'::DATE, 7410000, 5.00, 'Contado', 7410000, 0, 'Inversionista', 2, 'Agosto contado' UNION ALL

    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 6: Andares Residencial (Guadalajara) - 4 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 6 AND NUMERO_UNIDAD = 'A-701' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-01-20'::DATE, 6555000, 5.00, 'Hipoteca', 1966500, 240, 'Usuario Final', 3, 'Enero 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 6 AND NUMERO_UNIDAD = 'A-801' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-03-12'::DATE, 7300000, 0.00, 'Mixto', 2920000, 180, 'Usuario Final', 3, 'Marzo 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 6 AND NUMERO_UNIDAD = 'B-601' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-05-18'::DATE, 8265000, 5.00, 'Contado', 8265000, 0, 'Inversionista', 3, 'Mayo contado' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 6 AND NUMERO_UNIDAD = 'B-701' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-07-25'::DATE, 9100000, 0.00, 'Hipoteca', 2730000, 240, 'Usuario Final', 3, 'Julio 2025' UNION ALL

    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 8: Villas del Marqués (Querétaro) - 5 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'V-14' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-01-25'::DATE, 5415000, 5.00, 'Hipoteca', 1624500, 240, 'Usuario Final', 4, 'Enero 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'V-15' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-03-10'::DATE, 5900000, 0.00, 'Mixto', 2360000, 180, 'Usuario Final', 4, 'Marzo 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'TH-05' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-04-22'::DATE, 3325000, 5.00, 'Crédito Infonavit', 665000, 240, 'Usuario Final', 4, 'Abril TH' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'TH-06' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-06-05'::DATE, 3500000, 0.00, 'Hipoteca', 1050000, 200, 'Usuario Final', 4, 'Junio TH' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 8 AND NUMERO_UNIDAD = 'V-16' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-08-18'::DATE, 5890000, 5.00, 'Contado', 5890000, 0, 'Inversionista', 4, 'Agosto contado' UNION ALL

    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 10: Altabrisa Towers (Mérida) - 4 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 10 AND NUMERO_UNIDAD = 'T1-801' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-02-05'::DATE, 3705000, 5.00, 'Hipoteca', 1111500, 180, 'Usuario Final', 5, 'Febrero 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 10 AND NUMERO_UNIDAD = 'T1-901' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-03-20'::DATE, 4100000, 0.00, 'Mixto', 1640000, 180, 'Usuario Final', 5, 'Marzo 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 10 AND NUMERO_UNIDAD = 'T2-701' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-05-12'::DATE, 4750000, 5.00, 'Contado', 4750000, 0, 'Inversionista', 5, 'Mayo contado' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 10 AND NUMERO_UNIDAD = 'T2-801' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-07-08'::DATE, 5300000, 0.00, 'Hipoteca', 1590000, 240, 'Usuario Final', 5, 'Julio 2025' UNION ALL

    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 11: Marina Cancún - 3 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 11 AND NUMERO_UNIDAD = '403' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-01-30'::DATE, 7885000, 5.00, 'Contado', 7885000, 0, 'Extranjero', 6, 'Enero contado' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 11 AND NUMERO_UNIDAD = '501' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-04-15'::DATE, 8800000, 0.00, 'Contado', 8800000, 0, 'Extranjero', 6, 'Abril contado' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 11 AND NUMERO_UNIDAD = '502' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-06-22'::DATE, 8740000, 5.00, 'Contado', 8740000, 0, 'Inversionista', 6, 'Junio 2025' UNION ALL

    -- =========================================================================
    -- VENTAS 2025 - Desarrollo 12: Playa Caracol (Cancún) - 4 ventas
    -- =========================================================================
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 12 AND NUMERO_UNIDAD = 'PC-403' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-02-10'::DATE, 9975000, 5.00, 'Contado', 9975000, 0, 'Extranjero', 6, 'Febrero 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 12 AND NUMERO_UNIDAD = 'PC-501' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-04-05'::DATE, 11200000, 0.00, 'Contado', 11200000, 0, 'Extranjero', 6, 'Abril contado' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 12 AND NUMERO_UNIDAD = 'PC-502' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-06-18'::DATE, 11210000, 5.00, 'Contado', 11210000, 0, 'Extranjero', 6, 'Junio 2025' UNION ALL
    SELECT (SELECT PROPIEDAD_ID FROM URBANOVA_SCHEMA.PROPIEDADES WHERE DESARROLLO_ID = 12 AND NUMERO_UNIDAD = 'PC-601' AND FECHA_ACTUALIZACION >= '2025-01-01' LIMIT 1),
        '2025-08-25'::DATE, 13000000, 0.00, 'Contado', 13000000, 0, 'Inversionista', 6, 'Agosto premium'
);

-- =========================================================================
-- 6.3 COSTOS ADICIONALES 2025 (Ajustes por inflación y avance de obra)
-- =========================================================================
INSERT INTO URBANOVA_SCHEMA.COSTOS_CONSTRUCCION
SELECT
    (SELECT COALESCE(MAX(COSTO_ID), 0) FROM URBANOVA_SCHEMA.COSTOS_CONSTRUCCION) + ROW_NUMBER() OVER (ORDER BY NULL) AS COSTO_ID,
    desarrollo_id,
    tipo_costo,
    descripcion,
    monto_mxn,
    porcentaje_total,
    fecha_registro,
    estatus_pago,
    comentario
FROM (
    -- Costos adicionales 2025 por desarrollo
    SELECT 1 AS desarrollo_id, 'Construcción' AS tipo_costo, 'Avance de obra Q1-Q3 2025' AS descripcion, 45000000 AS monto_mxn, 12.00 AS porcentaje_total, '2025-06-30'::DATE AS fecha_registro, 'Parcial' AS estatus_pago, 'Fase final construcción' AS comentario UNION ALL
    SELECT 1, 'Marketing', 'Campaña cierre de ventas 2025', 8500000, 2.50, '2025-03-15'::DATE, 'Pagado', 'Marketing digital premium' UNION ALL
    
    SELECT 2, 'Construcción', 'Terminados premium 2025', 38000000, 10.00, '2025-05-20'::DATE, 'Parcial', 'Acabados de lujo' UNION ALL
    SELECT 2, 'Otros', 'Certificaciones LEED 2025', 5500000, 1.50, '2025-04-10'::DATE, 'Pagado', 'Sustentabilidad' UNION ALL
    
    SELECT 3, 'Construcción', 'Fase final 2025', 28000000, 8.00, '2025-07-15'::DATE, 'Parcial', 'Últimos pisos' UNION ALL
    SELECT 3, 'Marketing', 'Promoción cierre 2025', 4200000, 1.20, '2025-02-28'::DATE, 'Pagado', 'Campaña regional' UNION ALL
    
    SELECT 4, 'Construcción', 'Casas fase 3 2025', 32000000, 9.00, '2025-06-01'::DATE, 'Parcial', 'Nuevas unidades' UNION ALL
    SELECT 4, 'Otros', 'Urbanización adicional', 6500000, 1.80, '2025-04-15'::DATE, 'Parcial', 'Amenidades extra' UNION ALL
    
    SELECT 6, 'Construcción', 'Torre B avance 2025', 42000000, 11.00, '2025-08-01'::DATE, 'Parcial', 'Construcción activa' UNION ALL
    SELECT 6, 'Financiero', 'Intereses Q1-Q2 2025', 9500000, 2.50, '2025-06-30'::DATE, 'Pagado', 'Servicio de deuda' UNION ALL
    
    SELECT 8, 'Construcción', 'Nuevas casas 2025', 22000000, 7.00, '2025-07-20'::DATE, 'Parcial', 'Expansión proyecto' UNION ALL
    SELECT 8, 'Otros', 'Casa club terminada', 8500000, 2.50, '2025-05-15'::DATE, 'Pagado', 'Amenidades' UNION ALL
    
    SELECT 10, 'Construcción', 'Torre 2 avance 2025', 35000000, 10.00, '2025-08-15'::DATE, 'Parcial', 'Fase intermedia' UNION ALL
    SELECT 10, 'Marketing', 'Campaña Yucatán 2025', 3800000, 1.10, '2025-03-01'::DATE, 'Pagado', 'Marketing regional' UNION ALL
    
    SELECT 11, 'Construcción', 'Terminados marina 2025', 25000000, 8.00, '2025-06-20'::DATE, 'Parcial', 'Acabados premium' UNION ALL
    SELECT 11, 'Otros', 'Muelles adicionales', 12000000, 3.80, '2025-04-01'::DATE, 'Parcial', 'Infraestructura marina' UNION ALL
    
    SELECT 12, 'Construcción', 'Fase final beachfront', 48000000, 12.00, '2025-07-10'::DATE, 'Parcial', 'Últimos pisos' UNION ALL
    SELECT 12, 'Permisos', 'Renovación concesión zona federal', 8500000, 2.20, '2025-02-15'::DATE, 'Pagado', 'Zona federal marítima'
);

-- =========================================================================
-- 6.4 PROYECCIONES 2025
-- =========================================================================
INSERT INTO URBANOVA_SCHEMA.PROYECCIONES_VENTAS
SELECT
    (SELECT MAX(PROYECCION_ID) FROM URBANOVA_SCHEMA.PROYECCIONES_VENTAS) + ROW_NUMBER() OVER (ORDER BY NULL) AS PROYECCION_ID,
    desarrollo_id,
    mes_proyeccion,
    unidades_proyectadas,
    ingresos_proyectados_mxn,
    unidades_reales,
    ingresos_reales_mxn,
    variacion_unidades,
    variacion_ingresos_mxn,
    comentario
FROM (
    -- Proyecciones 2025 - Desarrollo 1
    SELECT 1 AS desarrollo_id, '2025-01-01'::DATE AS mes_proyeccion, 2 AS unidades_proyectadas, 19000000 AS ingresos_proyectados_mxn, 1 AS unidades_reales, 8977500 AS ingresos_reales_mxn, -1 AS variacion_unidades, -10022500 AS variacion_ingresos_mxn, 'Enero arranque lento' AS comentario UNION ALL
    SELECT 1, '2025-02-01'::DATE, 2, 20000000, 1, 9800000, -1, -10200000, 'Febrero mejorando' UNION ALL
    SELECT 1, '2025-04-01'::DATE, 2, 21000000, 1, 9690000, -1, -11310000, 'Abril en meta parcial' UNION ALL
    SELECT 1, '2025-05-01'::DATE, 2, 22000000, 1, 10800000, -1, -11200000, 'Mayo penthouse' UNION ALL
    
    -- Proyecciones 2025 - Desarrollo 2
    SELECT 2, '2025-01-01'::DATE, 2, 20000000, 1, 9500000, -1, -10500000, 'Enero 2025' UNION ALL
    SELECT 2, '2025-03-01'::DATE, 2, 21000000, 1, 10500000, -1, -10500000, 'Marzo contado' UNION ALL
    SELECT 2, '2025-05-01'::DATE, 2, 24000000, 1, 11210000, -1, -12790000, 'Mayo inversión' UNION ALL
    SELECT 2, '2025-07-01'::DATE, 2, 25000000, 1, 12200000, -1, -12800000, 'Julio extranjero' UNION ALL
    
    -- Proyecciones 2025 - Desarrollo 6
    SELECT 6, '2025-01-01'::DATE, 2, 14000000, 1, 6555000, -1, -7445000, 'Enero GDL' UNION ALL
    SELECT 6, '2025-03-01'::DATE, 2, 15000000, 1, 7300000, -1, -7700000, 'Marzo 2025' UNION ALL
    SELECT 6, '2025-05-01'::DATE, 2, 17000000, 1, 8265000, -1, -8735000, 'Mayo inversionista' UNION ALL
    SELECT 6, '2025-07-01'::DATE, 2, 18000000, 1, 9100000, -1, -8900000, 'Julio 2025' UNION ALL
    
    -- Proyecciones 2025 - Desarrollo 12
    SELECT 12, '2025-02-01'::DATE, 2, 21000000, 1, 9975000, -1, -11025000, 'Febrero Caribe' UNION ALL
    SELECT 12, '2025-04-01'::DATE, 2, 22000000, 1, 11200000, -1, -10800000, 'Abril contado' UNION ALL
    SELECT 12, '2025-06-01'::DATE, 2, 23000000, 1, 11210000, -1, -11790000, 'Junio 2025' UNION ALL
    SELECT 12, '2025-08-01'::DATE, 2, 26000000, 1, 13000000, -1, -13000000, 'Agosto premium'
);

-- ============================================================================
-- CONSULTAS DE VERIFICACIÓN
-- ============================================================================

-- Verificar ventas por desarrollo
SELECT 
    d.DESARROLLO_ID,
    d.NOMBRE_DESARROLLO,
    c.NOMBRE_CIUDAD,
    COUNT(v.VENTA_ID) AS TOTAL_VENTAS,
    ROUND(SUM(v.PRECIO_VENTA_MXN), 0) AS INGRESOS_TOTALES,
    d.TOTAL_UNIDADES,
    ROUND((COUNT(v.VENTA_ID) * 100.0) / d.TOTAL_UNIDADES, 2) AS PCT_VENDIDO
FROM URBANOVA_SCHEMA.DESARROLLOS d
INNER JOIN URBANOVA_SCHEMA.CIUDADES c ON d.CIUDAD_ID = c.CIUDAD_ID
LEFT JOIN URBANOVA_SCHEMA.PROPIEDADES p ON d.DESARROLLO_ID = p.DESARROLLO_ID
LEFT JOIN URBANOVA_SCHEMA.VENTAS v ON p.PROPIEDAD_ID = v.PROPIEDAD_ID
GROUP BY d.DESARROLLO_ID, d.NOMBRE_DESARROLLO, c.NOMBRE_CIUDAD, d.TOTAL_UNIDADES
ORDER BY TOTAL_VENTAS DESC;

-- Verificar rentabilidad por desarrollo
SELECT 
    d.NOMBRE_DESARROLLO,
    c.NOMBRE_CIUDAD,
    ROUND(SUM(cc.MONTO_MXN), 0) AS COSTO_TOTAL,
    ROUND(SUM(v.PRECIO_VENTA_MXN), 0) AS INGRESOS_ACTUALES,
    ROUND(AVG(p.PRECIO_LISTA_MXN) * d.TOTAL_UNIDADES, 0) AS INGRESOS_PROYECTADOS,
    ROUND((AVG(p.PRECIO_LISTA_MXN) * d.TOTAL_UNIDADES) - SUM(cc.MONTO_MXN), 0) AS UTILIDAD_PROYECTADA,
    ROUND(
        ((AVG(p.PRECIO_LISTA_MXN) * d.TOTAL_UNIDADES) - SUM(cc.MONTO_MXN)) * 100.0 / 
        (AVG(p.PRECIO_LISTA_MXN) * d.TOTAL_UNIDADES),
        2
    ) AS MARGEN_PROYECTADO_PCT,
    CASE 
        WHEN ((AVG(p.PRECIO_LISTA_MXN) * d.TOTAL_UNIDADES) - SUM(cc.MONTO_MXN)) > 0 THEN '✅ Rentable'
        ELSE '❌ No Rentable'
    END AS ESTATUS_RENTABILIDAD
FROM URBANOVA_SCHEMA.DESARROLLOS d
INNER JOIN URBANOVA_SCHEMA.CIUDADES c ON d.CIUDAD_ID = c.CIUDAD_ID
INNER JOIN URBANOVA_SCHEMA.PROPIEDADES p ON d.DESARROLLO_ID = p.DESARROLLO_ID
INNER JOIN URBANOVA_SCHEMA.COSTOS_CONSTRUCCION cc ON d.DESARROLLO_ID = cc.DESARROLLO_ID
LEFT JOIN URBANOVA_SCHEMA.VENTAS v ON p.PROPIEDAD_ID = v.PROPIEDAD_ID
GROUP BY d.NOMBRE_DESARROLLO, c.NOMBRE_CIUDAD, d.TOTAL_UNIDADES
ORDER BY MARGEN_PROYECTADO_PCT DESC;

-- ============================================================================
-- FIN DEL SCRIPT DE DATOS ADICIONALES
-- ============================================================================

