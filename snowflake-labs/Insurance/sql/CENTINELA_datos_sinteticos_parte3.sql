-- ============================================================================
-- SEGUROS CENTINELA - DATOS SINTÉTICOS (PARTE 3)
-- ============================================================================
-- Planes GMM, Coberturas GMM y Pólizas GMM
-- ============================================================================

USE DATABASE CENTINELA_DB;
USE WAREHOUSE CENTINELA_WH;

-- ============================================================================
-- CATÁLOGO DE PLANES GMM
-- ============================================================================
USE SCHEMA CENTINELA_DB.GMM;

INSERT INTO CENTINELA_DB.GMM.PLANES_GMM 
(plan_id, nombre_plan, descripcion, nivel_hospital, suma_asegurada, deducible, coaseguro_porcentaje, tope_coaseguro, cobertura_internacional)
VALUES
    ('PLAN_BAS', 'Centinela Básico', 'Plan básico de gastos médicos con red hospitalaria estándar', 'Estandar', 5000000.00, 25000.00, 10.00, 150000.00, FALSE),
    ('PLAN_ESE', 'Centinela Esencial', 'Plan esencial con cobertura ampliada y hospitales de nivel ejecutivo', 'Ejecutivo', 10000000.00, 20000.00, 10.00, 200000.00, FALSE),
    ('PLAN_PLU', 'Centinela Plus', 'Plan plus con acceso a hospitales premium y especialistas', 'Premium', 20000000.00, 15000.00, 10.00, 250000.00, FALSE),
    ('PLAN_ELI', 'Centinela Elite', 'Plan elite con cobertura internacional y sin tope de coaseguro en México', 'Premium', 50000000.00, 10000.00, 10.00, 0.00, TRUE),
    ('PLAN_FAM', 'Centinela Familiar', 'Plan diseñado para familias con coberturas especiales para hijos', 'Ejecutivo', 15000000.00, 18000.00, 10.00, 200000.00, FALSE);

-- ============================================================================
-- CATÁLOGO DE COBERTURAS GMM
-- ============================================================================

INSERT INTO CENTINELA_DB.GMM.COBERTURAS_GMM 
(cobertura_id, nombre_cobertura, descripcion, tipo, suma_asegurada_default, periodo_espera_dias)
VALUES
    ('GMM_HOS', 'Hospitalización', 'Gastos de habitación, terapia intensiva, uso de quirófano', 'Basica', NULL, 0),
    ('GMM_CIR', 'Cirugía', 'Honorarios médicos y gastos de cirugía', 'Basica', NULL, 0),
    ('GMM_AMB', 'Ambulancia', 'Servicio de ambulancia terrestre y aérea', 'Basica', 50000.00, 0),
    ('GMM_MED', 'Medicamentos', 'Medicamentos durante hospitalización', 'Basica', NULL, 0),
    ('GMM_AUX', 'Auxiliares de Diagnóstico', 'Laboratorio, rayos X, resonancia, tomografía', 'Basica', NULL, 0),
    ('GMM_EXT', 'Consultas Externas', 'Consultas médicas ambulatorias post-hospitalización', 'Adicional', 30000.00, 0),
    ('GMM_DEN', 'Cobertura Dental', 'Tratamientos dentales preventivos y correctivos', 'Adicional', 15000.00, 90),
    ('GMM_VIS', 'Cobertura Visual', 'Exámenes de vista y anteojos', 'Adicional', 8000.00, 90),
    ('GMM_MAT', 'Maternidad', 'Parto normal, cesárea y complicaciones', 'Adicional', 150000.00, 300),
    ('GMM_INT', 'Cobertura Internacional', 'Atención médica en el extranjero', 'Adicional', NULL, 0),
    ('GMM_ONC', 'Oncología', 'Tratamiento integral de cáncer', 'Basica', NULL, 0),
    ('GMM_REH', 'Rehabilitación', 'Terapia física y rehabilitación post-operatoria', 'Adicional', 100000.00, 0);

-- ============================================================================
-- PÓLIZAS MAESTRAS - TIPO GMM (40 pólizas)
-- ============================================================================
USE SCHEMA CENTINELA_DB.CORE;

INSERT INTO CENTINELA_DB.CORE.POLIZAS
(poliza_id, numero_poliza, tipo_seguro, cliente_id, agente_id, fecha_emision, fecha_inicio_vigencia, fecha_fin_vigencia, estatus, forma_pago, prima_neta, derecho_poliza, recargo_pago_fraccionado, iva, prima_total, conducto_cobro)
VALUES
    ('POL_GMM_001', 'GMM-2024-000001', 'GMM', 'CLI0041', 'AGT001', '2024-01-10', '2024-01-11', '2025-01-11', 'Vigente', 'Anual', 28500.00, 650.00, 0.00, 4664.00, 33814.00, 'Domiciliación'),
    ('POL_GMM_002', 'GMM-2024-000002', 'GMM', 'CLI0042', 'AGT001', '2024-01-15', '2024-01-16', '2025-01-16', 'Vigente', 'Semestral', 45200.00, 650.00, 1356.00, 7552.96, 54758.96, 'Tarjeta'),
    ('POL_GMM_003', 'GMM-2024-000003', 'GMM', 'CLI0043', 'AGT002', '2024-01-20', '2024-01-21', '2025-01-21', 'Vigente', 'Anual', 62800.00, 650.00, 0.00, 10152.00, 73602.00, 'Transferencia'),
    ('POL_GMM_004', 'GMM-2024-000004', 'GMM', 'CLI0044', 'AGT002', '2024-02-01', '2024-02-02', '2025-02-02', 'Vigente', 'Trimestral', 18900.00, 650.00, 756.00, 3248.96, 23554.96, 'Domiciliación'),
    ('POL_GMM_005', 'GMM-2024-000005', 'GMM', 'CLI0045', 'AGT003', '2024-02-10', '2024-02-11', '2025-02-11', 'Vigente', 'Anual', 35600.00, 650.00, 0.00, 5800.00, 42050.00, 'Tarjeta'),
    ('POL_GMM_006', 'GMM-2024-000006', 'GMM', 'CLI0046', 'AGT003', '2024-02-15', '2024-02-16', '2025-02-16', 'Vigente', 'Mensual', 22400.00, 650.00, 1344.00, 3903.04, 28297.04, 'Domiciliación'),
    ('POL_GMM_007', 'GMM-2024-000007', 'GMM', 'CLI0047', 'AGT004', '2024-02-20', '2024-02-21', '2025-02-21', 'Vigente', 'Anual', 78500.00, 650.00, 0.00, 12664.00, 91814.00, 'Transferencia'),
    ('POL_GMM_008', 'GMM-2024-000008', 'GMM', 'CLI0048', 'AGT004', '2024-03-01', '2024-03-02', '2025-03-02', 'Vigente', 'Semestral', 52300.00, 650.00, 1569.00, 8723.04, 63242.04, 'Tarjeta'),
    ('POL_GMM_009', 'GMM-2024-000009', 'GMM', 'CLI0049', 'AGT005', '2024-03-10', '2024-03-11', '2025-03-11', 'Vigente', 'Anual', 24800.00, 650.00, 0.00, 4072.00, 29522.00, 'Domiciliación'),
    ('POL_GMM_010', 'GMM-2024-000010', 'GMM', 'CLI0050', 'AGT005', '2024-03-15', '2024-03-16', '2025-03-16', 'Vigente', 'Trimestral', 68200.00, 650.00, 2728.00, 11452.48, 83030.48, 'Transferencia'),
    ('POL_GMM_011', 'GMM-2024-000011', 'GMM', 'CLI0051', 'AGT006', '2024-03-20', '2024-03-21', '2025-03-21', 'Vigente', 'Anual', 42100.00, 650.00, 0.00, 6840.00, 49590.00, 'Tarjeta'),
    ('POL_GMM_012', 'GMM-2024-000012', 'GMM', 'CLI0052', 'AGT006', '2024-04-01', '2024-04-02', '2025-04-02', 'Vigente', 'Semestral', 19800.00, 650.00, 594.00, 3367.04, 24411.04, 'Domiciliación'),
    ('POL_GMM_013', 'GMM-2024-000013', 'GMM', 'CLI0053', 'AGT007', '2024-04-10', '2024-04-11', '2025-04-11', 'Vigente', 'Anual', 85600.00, 650.00, 0.00, 13800.00, 100050.00, 'Transferencia'),
    ('POL_GMM_014', 'GMM-2024-000014', 'GMM', 'CLI0054', 'AGT007', '2024-04-15', '2024-04-16', '2025-04-16', 'Vigente', 'Mensual', 56400.00, 650.00, 3384.00, 9669.44, 70103.44, 'Tarjeta'),
    ('POL_GMM_015', 'GMM-2024-000015', 'GMM', 'CLI0055', 'AGT008', '2024-04-20', '2024-04-21', '2025-04-21', 'Vigente', 'Anual', 31200.00, 650.00, 0.00, 5096.00, 36946.00, 'Domiciliación'),
    ('POL_GMM_016', 'GMM-2024-000016', 'GMM', 'CLI0056', 'AGT008', '2024-05-01', '2024-05-02', '2025-05-02', 'Vigente', 'Semestral', 72400.00, 650.00, 2172.00, 12035.52, 87257.52, 'Transferencia'),
    ('POL_GMM_017', 'GMM-2024-000017', 'GMM', 'CLI0057', 'AGT001', '2024-05-10', '2024-05-11', '2025-05-11', 'Vigente', 'Anual', 48900.00, 650.00, 0.00, 7928.00, 57478.00, 'Tarjeta'),
    ('POL_GMM_018', 'GMM-2024-000018', 'GMM', 'CLI0058', 'AGT002', '2024-05-15', '2024-05-16', '2025-05-16', 'Vigente', 'Trimestral', 21600.00, 650.00, 864.00, 3698.24, 26812.24, 'Domiciliación'),
    ('POL_GMM_019', 'GMM-2024-000019', 'GMM', 'CLI0059', 'AGT002', '2024-05-20', '2024-05-21', '2025-05-21', 'Vigente', 'Anual', 92500.00, 650.00, 0.00, 14904.00, 108054.00, 'Transferencia'),
    ('POL_GMM_020', 'GMM-2024-000020', 'GMM', 'CLI0060', 'AGT003', '2024-06-01', '2024-06-02', '2025-06-02', 'Vigente', 'Semestral', 38700.00, 650.00, 1161.00, 6481.76, 47092.76, 'Tarjeta'),
    ('POL_GMM_021', 'GMM-2024-000021', 'GMM', 'CLI0061', 'AGT003', '2024-06-10', '2024-06-11', '2025-06-11', 'Vigente', 'Anual', 26400.00, 650.00, 0.00, 4328.00, 31378.00, 'Domiciliación'),
    ('POL_GMM_022', 'GMM-2024-000022', 'GMM', 'CLI0062', 'AGT004', '2024-06-15', '2024-06-16', '2025-06-16', 'Vigente', 'Mensual', 17800.00, 650.00, 1068.00, 3122.88, 22640.88, 'Transferencia'),
    ('POL_GMM_023', 'GMM-2024-000023', 'GMM', 'CLI0063', 'AGT004', '2024-06-20', '2024-06-21', '2025-06-21', 'Vigente', 'Anual', 64200.00, 650.00, 0.00, 10376.00, 75226.00, 'Tarjeta'),
    ('POL_GMM_024', 'GMM-2024-000024', 'GMM', 'CLI0064', 'AGT005', '2024-07-01', '2024-07-02', '2025-07-02', 'Vigente', 'Semestral', 55800.00, 650.00, 1674.00, 9299.84, 67423.84, 'Domiciliación'),
    ('POL_GMM_025', 'GMM-2024-000025', 'GMM', 'CLI0065', 'AGT005', '2024-07-10', '2024-07-11', '2025-07-11', 'Vigente', 'Anual', 79800.00, 650.00, 0.00, 12872.00, 93322.00, 'Transferencia'),
    ('POL_GMM_026', 'GMM-2024-000026', 'GMM', 'CLI0066', 'AGT006', '2024-07-15', '2024-07-16', '2025-07-16', 'Vigente', 'Trimestral', 23500.00, 650.00, 940.00, 4014.40, 29104.40, 'Tarjeta'),
    ('POL_GMM_027', 'GMM-2024-000027', 'GMM', 'CLI0067', 'AGT006', '2024-07-20', '2024-07-21', '2025-07-21', 'Vigente', 'Anual', 98200.00, 650.00, 0.00, 15816.00, 114666.00, 'Domiciliación'),
    ('POL_GMM_028', 'GMM-2024-000028', 'GMM', 'CLI0068', 'AGT007', '2024-08-01', '2024-08-02', '2025-08-02', 'Vigente', 'Semestral', 41300.00, 650.00, 1239.00, 6910.24, 50099.24, 'Transferencia'),
    ('POL_GMM_029', 'GMM-2024-000029', 'GMM', 'CLI0069', 'AGT007', '2024-08-10', '2024-08-11', '2025-08-11', 'Vigente', 'Anual', 29800.00, 650.00, 0.00, 4872.00, 35322.00, 'Tarjeta'),
    ('POL_GMM_030', 'GMM-2024-000030', 'GMM', 'CLI0070', 'AGT008', '2024-08-15', '2024-08-16', '2025-08-16', 'Vigente', 'Mensual', 58600.00, 650.00, 3516.00, 10042.56, 72808.56, 'Domiciliación'),
    ('POL_GMM_031', 'GMM-2024-000031', 'GMM', 'CLI0071', 'AGT008', '2024-08-20', '2024-08-21', '2025-08-21', 'Vigente', 'Anual', 46500.00, 650.00, 0.00, 7544.00, 54694.00, 'Transferencia'),
    ('POL_GMM_032', 'GMM-2024-000032', 'GMM', 'CLI0072', 'AGT001', '2024-09-01', '2024-09-02', '2025-09-02', 'Vigente', 'Semestral', 82400.00, 650.00, 2472.00, 13683.52, 99205.52, 'Tarjeta'),
    ('POL_GMM_033', 'GMM-2024-000033', 'GMM', 'CLI0073', 'AGT002', '2024-09-10', '2024-09-11', '2025-09-11', 'Vigente', 'Anual', 33600.00, 650.00, 0.00, 5480.00, 39730.00, 'Domiciliación'),
    ('POL_GMM_034', 'GMM-2024-000034', 'GMM', 'CLI0074', 'AGT002', '2024-09-15', '2024-09-16', '2025-09-16', 'Vigente', 'Trimestral', 19200.00, 650.00, 768.00, 3298.88, 23916.88, 'Transferencia'),
    ('POL_GMM_035', 'GMM-2024-000035', 'GMM', 'CLI0075', 'AGT003', '2024-09-20', '2024-09-21', '2025-09-21', 'Vigente', 'Anual', 27600.00, 650.00, 0.00, 4520.00, 32770.00, 'Tarjeta'),
    ('POL_GMM_036', 'GMM-2024-000036', 'GMM', 'CLI0076', 'AGT003', '2024-10-01', '2024-10-02', '2025-10-02', 'Vigente', 'Semestral', 71200.00, 650.00, 2136.00, 11837.76, 85823.76, 'Domiciliación'),
    ('POL_GMM_037', 'GMM-2024-000037', 'GMM', 'CLI0077', 'AGT004', '2024-10-10', '2024-10-11', '2025-10-11', 'Vigente', 'Anual', 88900.00, 650.00, 0.00, 14328.00, 103878.00, 'Transferencia'),
    ('POL_GMM_038', 'GMM-2024-000038', 'GMM', 'CLI0078', 'AGT004', '2024-10-15', '2024-10-16', '2025-10-16', 'Vigente', 'Mensual', 16400.00, 650.00, 984.00, 2885.44, 20919.44, 'Tarjeta'),
    ('POL_GMM_039', 'GMM-2024-000039', 'GMM', 'CLI0079', 'AGT005', '2024-10-20', '2024-10-21', '2025-10-21', 'Vigente', 'Anual', 54200.00, 650.00, 0.00, 8776.00, 63626.00, 'Domiciliación'),
    ('POL_GMM_040', 'GMM-2024-000040', 'GMM', 'CLI0080', 'AGT005', '2024-11-01', '2024-11-02', '2025-11-02', 'Vigente', 'Semestral', 67800.00, 650.00, 2034.00, 11277.44, 81761.44, 'Transferencia');

-- ============================================================================
-- DETALLE DE PÓLIZAS GMM
-- ============================================================================
USE SCHEMA CENTINELA_DB.GMM;

INSERT INTO CENTINELA_DB.GMM.POLIZAS_GMM
(poliza_gmm_id, poliza_id, plan_id, tipo_poliza, suma_asegurada, deducible, coaseguro_porcentaje, tope_coaseguro, nivel_hospitalario, cobertura_internacional, cobertura_dental, cobertura_vision, cobertura_maternidad, red_medica, zona_cobertura, numero_asegurados, edad_promedio)
VALUES
    ('PG001', 'POL_GMM_001', 'PLAN_BAS', 'Individual', 5000000.00, 25000.00, 10.00, 150000.00, 'Estandar', FALSE, FALSE, FALSE, FALSE, 'Red Amplia', 'Nacional', 1, 39.00),
    ('PG002', 'POL_GMM_002', 'PLAN_ESE', 'Familiar', 10000000.00, 20000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, FALSE, FALSE, 'Red Amplia', 'Nacional', 3, 35.00),
    ('PG003', 'POL_GMM_003', 'PLAN_PLU', 'Familiar', 20000000.00, 15000.00, 10.00, 250000.00, 'Premium', FALSE, TRUE, TRUE, FALSE, 'Red Selecta', 'Nacional', 4, 38.00),
    ('PG004', 'POL_GMM_004', 'PLAN_BAS', 'Individual', 5000000.00, 25000.00, 10.00, 150000.00, 'Estandar', FALSE, FALSE, FALSE, FALSE, 'Red Amplia', 'Nacional', 1, 33.00),
    ('PG005', 'POL_GMM_005', 'PLAN_ESE', 'Individual', 10000000.00, 20000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, FALSE, FALSE, 'Red Amplia', 'Nacional', 1, 41.00),
    ('PG006', 'POL_GMM_006', 'PLAN_BAS', 'Individual', 5000000.00, 25000.00, 10.00, 150000.00, 'Estandar', FALSE, FALSE, FALSE, FALSE, 'Red Amplia', 'Nacional', 1, 30.00),
    ('PG007', 'POL_GMM_007', 'PLAN_ELI', 'Familiar', 50000000.00, 10000.00, 10.00, 0.00, 'Premium', TRUE, TRUE, TRUE, TRUE, 'Red Selecta', 'Internacional', 4, 40.00),
    ('PG008', 'POL_GMM_008', 'PLAN_PLU', 'Familiar', 20000000.00, 15000.00, 10.00, 250000.00, 'Premium', FALSE, TRUE, TRUE, FALSE, 'Red Selecta', 'Nacional', 3, 36.00),
    ('PG009', 'POL_GMM_009', 'PLAN_BAS', 'Individual', 5000000.00, 25000.00, 10.00, 150000.00, 'Estandar', FALSE, FALSE, FALSE, FALSE, 'Red Amplia', 'Nacional', 1, 38.00),
    ('PG010', 'POL_GMM_010', 'PLAN_FAM', 'Familiar', 15000000.00, 18000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, TRUE, TRUE, 'Red Amplia', 'Nacional', 5, 32.00),
    ('PG011', 'POL_GMM_011', 'PLAN_ESE', 'Familiar', 10000000.00, 20000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, FALSE, FALSE, 'Red Amplia', 'Nacional', 2, 34.00),
    ('PG012', 'POL_GMM_012', 'PLAN_BAS', 'Individual', 5000000.00, 25000.00, 10.00, 150000.00, 'Estandar', FALSE, FALSE, FALSE, FALSE, 'Red Amplia', 'Nacional', 1, 34.00),
    ('PG013', 'POL_GMM_013', 'PLAN_ELI', 'Familiar', 50000000.00, 10000.00, 10.00, 0.00, 'Premium', TRUE, TRUE, TRUE, FALSE, 'Red Selecta', 'Internacional', 5, 42.00),
    ('PG014', 'POL_GMM_014', 'PLAN_PLU', 'Familiar', 20000000.00, 15000.00, 10.00, 250000.00, 'Premium', FALSE, TRUE, TRUE, TRUE, 'Red Selecta', 'Nacional', 4, 33.00),
    ('PG015', 'POL_GMM_015', 'PLAN_ESE', 'Individual', 10000000.00, 20000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, FALSE, FALSE, FALSE, 'Red Amplia', 'Nacional', 1, 40.00),
    ('PG016', 'POL_GMM_016', 'PLAN_FAM', 'Familiar', 15000000.00, 18000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, TRUE, TRUE, 'Red Amplia', 'Nacional', 4, 37.00),
    ('PG017', 'POL_GMM_017', 'PLAN_PLU', 'Familiar', 20000000.00, 15000.00, 10.00, 250000.00, 'Premium', FALSE, TRUE, TRUE, FALSE, 'Red Selecta', 'Nacional', 3, 45.00),
    ('PG018', 'POL_GMM_018', 'PLAN_BAS', 'Individual', 5000000.00, 25000.00, 10.00, 150000.00, 'Estandar', FALSE, FALSE, FALSE, FALSE, 'Red Amplia', 'Nacional', 1, 32.00),
    ('PG019', 'POL_GMM_019', 'PLAN_ELI', 'Familiar', 50000000.00, 10000.00, 10.00, 0.00, 'Premium', TRUE, TRUE, TRUE, TRUE, 'Red Selecta', 'Internacional', 4, 39.00),
    ('PG020', 'POL_GMM_020', 'PLAN_ESE', 'Familiar', 10000000.00, 20000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, FALSE, FALSE, 'Red Amplia', 'Nacional', 2, 36.00),
    ('PG021', 'POL_GMM_021', 'PLAN_BAS', 'Individual', 5000000.00, 25000.00, 10.00, 150000.00, 'Estandar', FALSE, FALSE, FALSE, FALSE, 'Red Amplia', 'Nacional', 1, 43.00),
    ('PG022', 'POL_GMM_022', 'PLAN_BAS', 'Individual', 5000000.00, 25000.00, 10.00, 150000.00, 'Estandar', FALSE, FALSE, FALSE, FALSE, 'Red Amplia', 'Nacional', 1, 30.00),
    ('PG023', 'POL_GMM_023', 'PLAN_PLU', 'Familiar', 20000000.00, 15000.00, 10.00, 250000.00, 'Premium', FALSE, TRUE, TRUE, FALSE, 'Red Selecta', 'Nacional', 3, 38.00),
    ('PG024', 'POL_GMM_024', 'PLAN_FAM', 'Familiar', 15000000.00, 18000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, TRUE, TRUE, 'Red Amplia', 'Nacional', 4, 35.00),
    ('PG025', 'POL_GMM_025', 'PLAN_ELI', 'Familiar', 50000000.00, 10000.00, 10.00, 0.00, 'Premium', TRUE, TRUE, TRUE, FALSE, 'Red Selecta', 'Internacional', 3, 42.00),
    ('PG026', 'POL_GMM_026', 'PLAN_BAS', 'Individual', 5000000.00, 25000.00, 10.00, 150000.00, 'Estandar', FALSE, FALSE, FALSE, FALSE, 'Red Amplia', 'Nacional', 1, 33.00),
    ('PG027', 'POL_GMM_027', 'PLAN_ELI', 'Familiar', 50000000.00, 10000.00, 10.00, 0.00, 'Premium', TRUE, TRUE, TRUE, TRUE, 'Red Selecta', 'Internacional', 5, 38.00),
    ('PG028', 'POL_GMM_028', 'PLAN_ESE', 'Familiar', 10000000.00, 20000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, FALSE, FALSE, 'Red Amplia', 'Nacional', 2, 37.00),
    ('PG029', 'POL_GMM_029', 'PLAN_ESE', 'Individual', 10000000.00, 20000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, TRUE, FALSE, 'Red Amplia', 'Nacional', 1, 44.00),
    ('PG030', 'POL_GMM_030', 'PLAN_FAM', 'Familiar', 15000000.00, 18000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, TRUE, TRUE, 'Red Amplia', 'Nacional', 4, 31.00),
    ('PG031', 'POL_GMM_031', 'PLAN_PLU', 'Familiar', 20000000.00, 15000.00, 10.00, 250000.00, 'Premium', FALSE, TRUE, TRUE, FALSE, 'Red Selecta', 'Nacional', 3, 38.00),
    ('PG032', 'POL_GMM_032', 'PLAN_ELI', 'Familiar', 50000000.00, 10000.00, 10.00, 0.00, 'Premium', TRUE, TRUE, TRUE, FALSE, 'Red Selecta', 'Internacional', 4, 36.00),
    ('PG033', 'POL_GMM_033', 'PLAN_ESE', 'Familiar', 10000000.00, 20000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, FALSE, FALSE, 'Red Amplia', 'Nacional', 2, 43.00),
    ('PG034', 'POL_GMM_034', 'PLAN_BAS', 'Individual', 5000000.00, 25000.00, 10.00, 150000.00, 'Estandar', FALSE, FALSE, FALSE, FALSE, 'Red Amplia', 'Nacional', 1, 30.00),
    ('PG035', 'POL_GMM_035', 'PLAN_ESE', 'Individual', 10000000.00, 20000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, TRUE, FALSE, 'Red Amplia', 'Nacional', 1, 37.00),
    ('PG036', 'POL_GMM_036', 'PLAN_FAM', 'Familiar', 15000000.00, 18000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, TRUE, TRUE, 'Red Amplia', 'Nacional', 4, 34.00),
    ('PG037', 'POL_GMM_037', 'PLAN_ELI', 'Familiar', 50000000.00, 10000.00, 10.00, 0.00, 'Premium', TRUE, TRUE, TRUE, TRUE, 'Red Selecta', 'Internacional', 5, 41.00),
    ('PG038', 'POL_GMM_038', 'PLAN_BAS', 'Individual', 5000000.00, 25000.00, 10.00, 150000.00, 'Estandar', FALSE, FALSE, FALSE, FALSE, 'Red Amplia', 'Nacional', 1, 29.00),
    ('PG039', 'POL_GMM_039', 'PLAN_PLU', 'Familiar', 20000000.00, 15000.00, 10.00, 250000.00, 'Premium', FALSE, TRUE, TRUE, FALSE, 'Red Selecta', 'Nacional', 3, 38.00),
    ('PG040', 'POL_GMM_040', 'PLAN_FAM', 'Familiar', 15000000.00, 18000.00, 10.00, 200000.00, 'Ejecutivo', FALSE, TRUE, TRUE, TRUE, 'Red Amplia', 'Nacional', 4, 36.00);

-- ============================================================================
-- ASEGURADOS GMM (Ejemplos para pólizas familiares)
-- ============================================================================

-- Asegurados para POL_GMM_002 (Familiar con 3 asegurados)
INSERT INTO CENTINELA_DB.GMM.ASEGURADOS_GMM
(asegurado_id, poliza_gmm_id, parentesco, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, genero, curp, peso_kg, estatura_cm, ocupacion, deportes_riesgo, fumador, enfermedades_preexistentes, prima_individual)
VALUES
    ('ASG0001', 'PG002', 'Titular', 'Rosa', 'Padilla', 'Quintana', '1988-07-18', 'F', 'PAQR880718MDFDNS42', 62.00, 165.00, 'Contadora', FALSE, FALSE, NULL, 18000.00),
    ('ASG0002', 'PG002', 'Conyuge', 'Miguel', 'Torres', 'Vega', '1985-03-22', 'M', 'TOVM850322HDFRRG01', 78.00, 175.00, 'Ingeniero', FALSE, FALSE, NULL, 16000.00),
    ('ASG0003', 'PG002', 'Hijo', 'Sofia', 'Torres', 'Padilla', '2015-09-10', 'F', 'TOPS150910MDFRRD02', 28.00, 120.00, 'Estudiante', FALSE, FALSE, NULL, 11200.00);

-- Asegurados para POL_GMM_003 (Familiar con 4 asegurados)
INSERT INTO CENTINELA_DB.GMM.ASEGURADOS_GMM
(asegurado_id, poliza_gmm_id, parentesco, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, genero, curp, peso_kg, estatura_cm, ocupacion, deportes_riesgo, fumador, enfermedades_preexistentes, prima_individual)
VALUES
    ('ASG0004', 'PG003', 'Titular', 'Alberto', 'Peña', 'Vázquez', '1979-09-28', 'M', 'PEVA790928HDFXZB43', 82.00, 178.00, 'Director General', FALSE, FALSE, 'Hipertensión controlada', 22000.00),
    ('ASG0005', 'PG003', 'Conyuge', 'Carmen', 'Rios', 'Luna', '1982-04-15', 'F', 'RILC820415MDFSNN01', 58.00, 162.00, 'Arquitecta', FALSE, FALSE, NULL, 18000.00),
    ('ASG0006', 'PG003', 'Hijo', 'Diego', 'Peña', 'Rios', '2010-11-20', 'M', 'PERD101120HDFNSG02', 42.00, 145.00, 'Estudiante', FALSE, FALSE, NULL, 12000.00),
    ('ASG0007', 'PG003', 'Hijo', 'Valentina', 'Peña', 'Rios', '2014-06-08', 'F', 'PERV140608MDFNSL03', 32.00, 128.00, 'Estudiante', FALSE, FALSE, NULL, 10800.00);

-- Asegurados para POL_GMM_007 (Elite Familiar con 4 asegurados)
INSERT INTO CENTINELA_DB.GMM.ASEGURADOS_GMM
(asegurado_id, poliza_gmm_id, parentesco, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, genero, curp, peso_kg, estatura_cm, ocupacion, deportes_riesgo, fumador, enfermedades_preexistentes, prima_individual)
VALUES
    ('ASG0008', 'PG007', 'Titular', 'Antonio', 'Chávez', 'Ibarra', '1980-08-08', 'M', 'CHIA800808HDFHVN47', 85.00, 180.00, 'CEO', TRUE, FALSE, NULL, 28000.00),
    ('ASG0009', 'PG007', 'Conyuge', 'Patricia', 'Mendez', 'Solis', '1983-12-03', 'F', 'MESP831203MDFNLT01', 60.00, 168.00, 'Médico', FALSE, FALSE, NULL, 22000.00),
    ('ASG0010', 'PG007', 'Hijo', 'Antonio Jr', 'Chávez', 'Mendez', '2008-02-14', 'M', 'CHMA080214HDFHVN02', 48.00, 155.00, 'Estudiante', FALSE, FALSE, NULL, 15000.00),
    ('ASG0011', 'PG007', 'Hijo', 'Isabella', 'Chávez', 'Mendez', '2012-07-22', 'F', 'CHMI120722MDFHVN03', 35.00, 138.00, 'Estudiante', FALSE, FALSE, NULL, 13500.00);

