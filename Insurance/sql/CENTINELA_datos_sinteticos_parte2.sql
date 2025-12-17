-- ============================================================================
-- SEGUROS CENTINELA - DATOS SINTÉTICOS (PARTE 2)
-- ============================================================================
-- Vehículos, Coberturas de Auto y Pólizas de Auto
-- ============================================================================

USE DATABASE CENTINELA_DB;
USE WAREHOUSE CENTINELA_WH;

-- ============================================================================
-- CATÁLOGO DE COBERTURAS DE AUTO
-- ============================================================================
USE SCHEMA CENTINELA_DB.AUTOS;

INSERT INTO CENTINELA_DB.AUTOS.COBERTURAS_AUTO 
(cobertura_id, nombre_cobertura, descripcion, tipo_cobertura, suma_asegurada_default, deducible_porcentaje)
VALUES
    ('COB_DM', 'Daños Materiales', 'Cobertura por daños al vehículo asegurado por colisión, volcadura u otros riesgos', 'Básica', NULL, 5.00),
    ('COB_RT', 'Robo Total', 'Cobertura en caso de robo total del vehículo', 'Básica', NULL, 10.00),
    ('COB_RC', 'Responsabilidad Civil', 'Daños a terceros en sus bienes y/o personas', 'Básica', 3000000.00, 0.00),
    ('COB_GM', 'Gastos Médicos Ocupantes', 'Gastos médicos para ocupantes del vehículo asegurado', 'Amplia', 500000.00, 0.00),
    ('COB_AL', 'Asistencia Legal', 'Defensa legal en caso de accidente de tránsito', 'Amplia', 500000.00, 0.00),
    ('COB_AV', 'Asistencia Vial', 'Servicio de grúa, paso de corriente, cerrajería, cambio de llanta', 'Básica', NULL, 0.00),
    ('COB_EQ', 'Equipo Especial', 'Cobertura para equipos y accesorios adicionales', 'Premium', 50000.00, 10.00),
    ('COB_CR', 'Cristales', 'Reparación o reemplazo de cristales', 'Amplia', NULL, 20.00),
    ('COB_AD', 'Auto de Depósito', 'Gastos de pensión del vehículo retenido por autoridad', 'Premium', 30000.00, 0.00),
    ('COB_AT', 'Auto en Tránsito', 'Extensión de cobertura para conducción en EE.UU.', 'Premium', NULL, 5.00);

-- ============================================================================
-- DATOS DE VEHÍCULOS (40 vehículos para pólizas de auto)
-- ============================================================================

INSERT INTO CENTINELA_DB.AUTOS.VEHICULOS
(vehiculo_id, cliente_id, marca, submarca, modelo, anio, version, numero_serie, numero_motor, placas, color, tipo_vehiculo, numero_puertas, transmision, combustible, valor_factura, valor_comercial, uso_vehiculo)
VALUES
    ('VEH0001', 'CLI0001', 'Nissan', 'Sentra', 'Sentra Sense', 2023, 'Sense CVT', '3N1AB8CV5PY234567', 'MR20DE234567', 'ABC-12-34', 'Blanco', 'Sedan', 4, 'Automatica', 'Gasolina', 389000.00, 365000.00, 'Particular'),
    ('VEH0002', 'CLI0002', 'Volkswagen', 'Jetta', 'Jetta Comfortline', 2024, 'Comfortline TSI', 'WVWZZZ16ZRY123456', 'TSI1400123456', 'DEF-56-78', 'Gris Oxford', 'Sedan', 4, 'Automatica', 'Gasolina', 498000.00, 485000.00, 'Particular'),
    ('VEH0003', 'CLI0003', 'Toyota', 'Camry', 'Camry XLE', 2023, 'XLE V6', '4T1B11HK5PU234567', '2GR-FE234567', 'GHI-90-12', 'Negro', 'Sedan', 4, 'Automatica', 'Gasolina', 689000.00, 645000.00, 'Particular'),
    ('VEH0004', 'CLI0004', 'Honda', 'CR-V', 'CR-V Touring', 2024, 'Touring AWD', '7FARW2H93RE123456', 'K24W5123456', 'JKL-34-56', 'Rojo', 'SUV', 5, 'Automatica', 'Gasolina', 729000.00, 715000.00, 'Particular'),
    ('VEH0005', 'CLI0005', 'Mazda', 'CX-5', 'CX-5 Signature', 2023, 'Signature AWD', 'JM3KFBDM5P1234567', 'SkyActiv234567', 'MNO-78-90', 'Azul', 'SUV', 5, 'Automatica', 'Gasolina', 659000.00, 620000.00, 'Particular'),
    ('VEH0006', 'CLI0006', 'Kia', 'Sportage', 'Sportage SXL', 2024, 'SXL AWD', 'KNDPRCAC5R7123456', 'Gamma2.0123456', 'PQR-12-34', 'Blanco Perla', 'SUV', 5, 'Automatica', 'Gasolina', 579000.00, 565000.00, 'Particular'),
    ('VEH0007', 'CLI0007', 'Chevrolet', 'Equinox', 'Equinox RS', 2023, 'RS Turbo', '3GNAXKEV5PS123456', 'Ecotec1.5T123', 'STU-56-78', 'Gris Acero', 'SUV', 5, 'Automatica', 'Gasolina', 619000.00, 585000.00, 'Particular'),
    ('VEH0008', 'CLI0008', 'Ford', 'Escape', 'Escape Titanium', 2024, 'Titanium AWD', '1FMCU9J94RUB12345', 'EcoBoost2.0123', 'VWX-90-12', 'Verde Oscuro', 'SUV', 5, 'Automatica', 'Gasolina', 689000.00, 670000.00, 'Particular'),
    ('VEH0009', 'CLI0009', 'Hyundai', 'Tucson', 'Tucson Limited', 2023, 'Limited Hybrid', 'KM8J33A25PU123456', 'Theta2.5H123', 'YZA-34-56', 'Plateado', 'SUV', 5, 'Automatica', 'Hibrido', 729000.00, 695000.00, 'Particular'),
    ('VEH0010', 'CLI0010', 'Nissan', 'Kicks', 'Kicks Exclusive', 2024, 'Exclusive CVT', '3N1CP5DV5RL123456', 'HR16DE123456', 'BCD-78-90', 'Naranja', 'SUV', 5, 'Automatica', 'Gasolina', 429000.00, 415000.00, 'Particular'),
    ('VEH0011', 'CLI0011', 'Toyota', 'RAV4', 'RAV4 XLE Premium', 2023, 'XLE Premium AWD', 'JTMW1RFV5PD123456', 'A25A-FXS1234', 'EFG-12-34', 'Blanco', 'SUV', 5, 'Automatica', 'Hibrido', 789000.00, 755000.00, 'Particular'),
    ('VEH0012', 'CLI0012', 'Volkswagen', 'Tiguan', 'Tiguan R-Line', 2024, 'R-Line 4Motion', 'WVGZZZ5NZRW123456', 'TSI2000123456', 'HIJ-56-78', 'Negro', 'SUV', 5, 'Automatica', 'Gasolina', 759000.00, 740000.00, 'Particular'),
    ('VEH0013', 'CLI0013', 'Honda', 'Civic', 'Civic Sport Plus', 2023, 'Sport Plus CVT', '19XFL1H50PE123456', 'L15B7123456', 'KLM-90-12', 'Azul', 'Sedan', 4, 'Automatica', 'Gasolina', 489000.00, 460000.00, 'Particular'),
    ('VEH0014', 'CLI0014', 'Mazda', '3', 'Mazda 3 Grand Touring', 2024, 'i Grand Touring', '3MZBPBDM5RM123456', 'SkyActiv-G2.5', 'NOP-34-56', 'Rojo Cristal', 'Sedan', 4, 'Automatica', 'Gasolina', 519000.00, 505000.00, 'Particular'),
    ('VEH0015', 'CLI0015', 'BMW', 'Serie 3', '330i Sport Line', 2023, '330i Sport Line', 'WBA8E9C55P5123456', 'B48B20123456', 'QRS-78-90', 'Gris Mineral', 'Sedan', 4, 'Automatica', 'Gasolina', 989000.00, 920000.00, 'Particular'),
    ('VEH0016', 'CLI0016', 'Mercedes-Benz', 'Clase C', 'C200 Exclusive', 2024, 'C200 Exclusive', 'W1KZF8DB4RA123456', 'M264E20123', 'TUV-12-34', 'Blanco Polar', 'Sedan', 4, 'Automatica', 'Gasolina', 1089000.00, 1050000.00, 'Particular'),
    ('VEH0017', 'CLI0017', 'Audi', 'A4', 'A4 40 TFSI Sport', 2023, '40 TFSI S Line', 'WAUENAF45PA123456', 'EA8882.0TFSI', 'WXY-56-78', 'Negro Phantom', 'Sedan', 4, 'Automatica', 'Gasolina', 899000.00, 850000.00, 'Particular'),
    ('VEH0018', 'CLI0018', 'Toyota', 'Corolla', 'Corolla SE', 2024, 'SE CVT', '5YFS4RCE3RP123456', 'M20A-FXS1234', 'ZAB-90-12', 'Gris Celestita', 'Sedan', 4, 'Automatica', 'Gasolina', 469000.00, 455000.00, 'Particular'),
    ('VEH0019', 'CLI0019', 'Ford', 'Ranger', 'Ranger XLT', 2023, 'XLT 4x4', '8AFDR5DA6R6123456', 'Diesel3.2TD123', 'CDE-34-56', 'Gris Carbono', 'Pickup', 4, 'Automatica', 'Diesel', 789000.00, 745000.00, 'Particular'),
    ('VEH0020', 'CLI0020', 'Chevrolet', 'Cheyenne', 'Cheyenne High Country', 2024, 'High Country 4x4', '3GCUYHEL5RG123456', 'Duramax6.2L123', 'FGH-78-90', 'Blanco Nevado', 'Pickup', 4, 'Automatica', 'Gasolina', 1189000.00, 1150000.00, 'Particular'),
    ('VEH0021', 'CLI0021', 'Nissan', 'Versa', 'Versa Advance', 2023, 'Advance CVT', '3N1CN8BV5PL123456', 'HR16DE789012', 'IJK-12-34', 'Azul Acero', 'Sedan', 4, 'Automatica', 'Gasolina', 339000.00, 320000.00, 'Particular'),
    ('VEH0022', 'CLI0022', 'Volkswagen', 'Taos', 'Taos Highline', 2024, 'Highline TSI', 'WVGZZZ5NZ4W567890', 'TSI1500TAOS12', 'LMN-56-78', 'Gris Platino', 'SUV', 5, 'Automatica', 'Gasolina', 629000.00, 610000.00, 'Particular'),
    ('VEH0023', 'CLI0023', 'Jeep', 'Compass', 'Compass Limited', 2023, 'Limited 4x4', 'ZACNJEAB7PPB12345', 'Tigershark2.4L', 'OPQ-90-12', 'Verde Olivo', 'SUV', 5, 'Automatica', 'Gasolina', 719000.00, 685000.00, 'Particular'),
    ('VEH0024', 'CLI0024', 'Suzuki', 'Grand Vitara', 'Grand Vitara Turbo', 2024, 'Turbo GLX', 'JS3JB4BV5R4123456', 'BoosterJet1.4L', 'RST-34-56', 'Blanco Perla', 'SUV', 5, 'Automatica', 'Gasolina', 509000.00, 495000.00, 'Particular'),
    ('VEH0025', 'CLI0025', 'Mitsubishi', 'Outlander', 'Outlander SEL', 2023, 'SEL AWC PHEV', 'JA4J25A5XPZ123456', 'PHEV2.4L12345', 'UVW-78-90', 'Plata', 'SUV', 5, 'Automatica', 'Hibrido', 849000.00, 810000.00, 'Particular'),
    ('VEH0026', 'CLI0026', 'Renault', 'Koleos', 'Koleos Iconic', 2024, 'Iconic CVT', 'MFDMF1D70RU123456', '2TR25DE123456', 'XYZ-12-34', 'Negro Estrella', 'SUV', 5, 'Automatica', 'Gasolina', 609000.00, 590000.00, 'Particular'),
    ('VEH0027', 'CLI0027', 'Subaru', 'Forester', 'Forester Sport', 2023, 'Sport EyeSight', 'JF2SKHOC5PH123456', 'FB25D1234567', 'ABC-56-78', 'Azul Océano', 'SUV', 5, 'Automatica', 'Gasolina', 699000.00, 665000.00, 'Particular'),
    ('VEH0028', 'CLI0028', 'Peugeot', '3008', '3008 GT', 2024, 'GT Pack THP', 'VFAYCPHNZNW123456', 'THP1.6L123456', 'DEF-90-12', 'Gris Artense', 'SUV', 5, 'Automatica', 'Gasolina', 679000.00, 655000.00, 'Particular'),
    ('VEH0029', 'CLI0029', 'Seat', 'Tarraco', 'Tarraco Xcellence', 2023, 'Xcellence DSG', 'VSSZZZ5FZPR123456', 'TSI2.0DSG1234', 'GHI-34-56', 'Rojo Merlot', 'SUV', 5, 'Automatica', 'Gasolina', 749000.00, 715000.00, 'Particular'),
    ('VEH0030', 'CLI0030', 'MG', 'HS', 'MG HS Excite', 2024, 'Excite DCT', 'LSJW25R36RG123456', '1.5T-GDI12345', 'JKL-78-90', 'Blanco Dover', 'SUV', 5, 'Automatica', 'Gasolina', 489000.00, 475000.00, 'Particular'),
    ('VEH0031', 'CLI0031', 'Nissan', 'X-Trail', 'X-Trail Exclusive', 2023, 'Exclusive CVT', 'JN1TANT32Z0123456', 'QR25DE123456', 'MNO-12-34', 'Bronce', 'SUV', 5, 'Automatica', 'Gasolina', 699000.00, 665000.00, 'Particular'),
    ('VEH0032', 'CLI0032', 'Honda', 'HR-V', 'HR-V Touring', 2024, 'Touring CVT', '3CZRU5H52RM123456', 'L15B8CVT1234', 'PQR-56-78', 'Gris Sonic', 'SUV', 5, 'Automatica', 'Gasolina', 539000.00, 520000.00, 'Particular'),
    ('VEH0033', 'CLI0033', 'Toyota', 'Highlander', 'Highlander Limited', 2023, 'Limited AWD', 'JTEKA5CV5PA123456', '2GR-FKS12345', 'STU-90-12', 'Blanco Celestial', 'SUV', 7, 'Automatica', 'Gasolina', 989000.00, 945000.00, 'Particular'),
    ('VEH0034', 'CLI0034', 'Volkswagen', 'Passat', 'Passat R-Line', 2024, 'R-Line TSI', 'WVWZZZ3CZRE123456', 'TSI2.0RLine12', 'VWX-34-56', 'Azul Atlántico', 'Sedan', 4, 'Automatica', 'Gasolina', 689000.00, 665000.00, 'Particular'),
    ('VEH0035', 'CLI0035', 'Kia', 'Seltos', 'Seltos SX', 2023, 'SX Turbo DCT', 'KNDEU2AA5P7123456', 'T-GDi1.6L1234', 'YZA-78-90', 'Negro Cherry', 'SUV', 5, 'Automatica', 'Gasolina', 489000.00, 465000.00, 'Particular'),
    ('VEH0036', 'CLI0036', 'Chevrolet', 'Tracker', 'Tracker RS', 2024, 'RS Turbo AT', '9BG116SC5R0123456', 'Ecotec1.2T123', 'BCD-12-34', 'Rojo Chili', 'SUV', 5, 'Automatica', 'Gasolina', 459000.00, 445000.00, 'Particular'),
    ('VEH0037', 'CLI0037', 'Ford', 'Bronco Sport', 'Bronco Sport Outer Banks', 2023, 'Outer Banks 4x4', '3FMCR9C92PR123456', 'EcoBoost2.0OB', 'EFG-56-78', 'Verde Cactus', 'SUV', 5, 'Automatica', 'Gasolina', 789000.00, 755000.00, 'Particular'),
    ('VEH0038', 'CLI0038', 'Hyundai', 'Creta', 'Creta Limited', 2024, 'Limited AT', 'MALC381AARM123456', 'Smartstream1.5', 'HIJ-90-12', 'Plateado Sleek', 'SUV', 5, 'Automatica', 'Gasolina', 459000.00, 445000.00, 'Particular'),
    ('VEH0039', 'CLI0039', 'Mazda', 'CX-30', 'CX-30 i Grand Touring', 2023, 'Grand Touring MT', 'JM3DKADL5P1123456', 'SkyActiv-G2.5', 'KLM-34-56', 'Gris Polymetal', 'SUV', 5, 'Automatica', 'Gasolina', 549000.00, 525000.00, 'Particular'),
    ('VEH0040', 'CLI0040', 'Toyota', 'Yaris', 'Yaris Sedan S', 2024, 'S CVT', 'MXBJ2AEK5R0123456', '2NR-FE1234567', 'NOP-78-90', 'Blanco', 'Sedan', 4, 'Automatica', 'Gasolina', 359000.00, 345000.00, 'Particular');

-- ============================================================================
-- PÓLIZAS MAESTRAS - TIPO AUTO (40 pólizas)
-- ============================================================================
USE SCHEMA CENTINELA_DB.CORE;

INSERT INTO CENTINELA_DB.CORE.POLIZAS
(poliza_id, numero_poliza, tipo_seguro, cliente_id, agente_id, fecha_emision, fecha_inicio_vigencia, fecha_fin_vigencia, estatus, forma_pago, prima_neta, derecho_poliza, recargo_pago_fraccionado, iva, prima_total, conducto_cobro)
VALUES
    ('POL_AUTO_001', 'AUTO-2024-000001', 'AUTO', 'CLI0001', 'AGT001', '2024-01-15', '2024-01-16', '2025-01-16', 'Vigente', 'Anual', 12500.00, 450.00, 0.00, 2072.00, 15022.00, 'Tarjeta'),
    ('POL_AUTO_002', 'AUTO-2024-000002', 'AUTO', 'CLI0002', 'AGT001', '2024-01-20', '2024-01-21', '2025-01-21', 'Vigente', 'Semestral', 18750.00, 450.00, 562.50, 3162.00, 22924.50, 'Domiciliación'),
    ('POL_AUTO_003', 'AUTO-2024-000003', 'AUTO', 'CLI0003', 'AGT002', '2024-02-01', '2024-02-02', '2025-02-02', 'Vigente', 'Anual', 22300.00, 450.00, 0.00, 3640.00, 26390.00, 'Transferencia'),
    ('POL_AUTO_004', 'AUTO-2024-000004', 'AUTO', 'CLI0004', 'AGT002', '2024-02-10', '2024-02-11', '2025-02-11', 'Vigente', 'Trimestral', 24500.00, 450.00, 980.00, 4148.80, 30078.80, 'Tarjeta'),
    ('POL_AUTO_005', 'AUTO-2024-000005', 'AUTO', 'CLI0005', 'AGT003', '2024-02-15', '2024-02-16', '2025-02-16', 'Vigente', 'Anual', 21800.00, 450.00, 0.00, 3560.00, 25810.00, 'Domiciliación'),
    ('POL_AUTO_006', 'AUTO-2024-000006', 'AUTO', 'CLI0006', 'AGT003', '2024-02-20', '2024-02-21', '2025-02-21', 'Vigente', 'Mensual', 19200.00, 450.00, 1152.00, 3328.32, 24130.32, 'Tarjeta'),
    ('POL_AUTO_007', 'AUTO-2024-000007', 'AUTO', 'CLI0007', 'AGT004', '2024-03-01', '2024-03-02', '2025-03-02', 'Vigente', 'Anual', 20500.00, 450.00, 0.00, 3352.00, 24302.00, 'Transferencia'),
    ('POL_AUTO_008', 'AUTO-2024-000008', 'AUTO', 'CLI0008', 'AGT005', '2024-03-10', '2024-03-11', '2025-03-11', 'Vigente', 'Semestral', 23100.00, 450.00, 693.00, 3878.88, 28121.88, 'Domiciliación'),
    ('POL_AUTO_009', 'AUTO-2024-000009', 'AUTO', 'CLI0009', 'AGT005', '2024-03-15', '2024-03-16', '2025-03-16', 'Vigente', 'Anual', 25800.00, 450.00, 0.00, 4200.00, 30450.00, 'Tarjeta'),
    ('POL_AUTO_010', 'AUTO-2024-000010', 'AUTO', 'CLI0010', 'AGT006', '2024-03-20', '2024-03-21', '2025-03-21', 'Vigente', 'Trimestral', 14200.00, 450.00, 568.00, 2434.88, 17652.88, 'Transferencia'),
    ('POL_AUTO_011', 'AUTO-2024-000011', 'AUTO', 'CLI0011', 'AGT007', '2024-04-01', '2024-04-02', '2025-04-02', 'Vigente', 'Anual', 28500.00, 450.00, 0.00, 4632.00, 33582.00, 'Domiciliación'),
    ('POL_AUTO_012', 'AUTO-2024-000012', 'AUTO', 'CLI0012', 'AGT008', '2024-04-10', '2024-04-11', '2025-04-11', 'Vigente', 'Semestral', 26700.00, 450.00, 801.00, 4472.16, 32423.16, 'Tarjeta'),
    ('POL_AUTO_013', 'AUTO-2024-000013', 'AUTO', 'CLI0013', 'AGT001', '2024-04-15', '2024-04-16', '2025-04-16', 'Vigente', 'Anual', 16800.00, 450.00, 0.00, 2760.00, 20010.00, 'Transferencia'),
    ('POL_AUTO_014', 'AUTO-2024-000014', 'AUTO', 'CLI0014', 'AGT002', '2024-04-20', '2024-04-21', '2025-04-21', 'Vigente', 'Mensual', 17900.00, 450.00, 1074.00, 3107.84, 22531.84, 'Domiciliación'),
    ('POL_AUTO_015', 'AUTO-2024-000015', 'AUTO', 'CLI0015', 'AGT002', '2024-05-01', '2024-05-02', '2025-05-02', 'Vigente', 'Anual', 35200.00, 450.00, 0.00, 5704.00, 41354.00, 'Tarjeta'),
    ('POL_AUTO_016', 'AUTO-2024-000016', 'AUTO', 'CLI0016', 'AGT003', '2024-05-10', '2024-05-11', '2025-05-11', 'Vigente', 'Semestral', 38900.00, 450.00, 1167.00, 6482.72, 47099.72, 'Transferencia'),
    ('POL_AUTO_017', 'AUTO-2024-000017', 'AUTO', 'CLI0017', 'AGT004', '2024-05-15', '2024-05-16', '2025-05-16', 'Vigente', 'Anual', 32100.00, 450.00, 0.00, 5208.00, 37758.00, 'Domiciliación'),
    ('POL_AUTO_018', 'AUTO-2024-000018', 'AUTO', 'CLI0018', 'AGT005', '2024-05-20', '2024-05-21', '2025-05-21', 'Vigente', 'Trimestral', 15600.00, 450.00, 624.00, 2667.84, 19341.84, 'Tarjeta'),
    ('POL_AUTO_019', 'AUTO-2024-000019', 'AUTO', 'CLI0019', 'AGT005', '2024-06-01', '2024-06-02', '2025-06-02', 'Vigente', 'Anual', 27800.00, 450.00, 0.00, 4520.00, 32770.00, 'Transferencia'),
    ('POL_AUTO_020', 'AUTO-2024-000020', 'AUTO', 'CLI0020', 'AGT006', '2024-06-10', '2024-06-11', '2025-06-11', 'Vigente', 'Semestral', 42500.00, 450.00, 1275.00, 7076.00, 51301.00, 'Domiciliación'),
    ('POL_AUTO_021', 'AUTO-2024-000021', 'AUTO', 'CLI0021', 'AGT007', '2024-06-15', '2024-06-16', '2025-06-16', 'Vigente', 'Anual', 11200.00, 450.00, 0.00, 1864.00, 13514.00, 'Tarjeta'),
    ('POL_AUTO_022', 'AUTO-2024-000022', 'AUTO', 'CLI0022', 'AGT008', '2024-06-20', '2024-06-21', '2025-06-21', 'Vigente', 'Mensual', 20900.00, 450.00, 1254.00, 3616.64, 26220.64, 'Transferencia'),
    ('POL_AUTO_023', 'AUTO-2024-000023', 'AUTO', 'CLI0023', 'AGT001', '2024-07-01', '2024-07-02', '2025-07-02', 'Vigente', 'Anual', 24200.00, 450.00, 0.00, 3944.00, 28594.00, 'Domiciliación'),
    ('POL_AUTO_024', 'AUTO-2024-000024', 'AUTO', 'CLI0024', 'AGT002', '2024-07-10', '2024-07-11', '2025-07-11', 'Vigente', 'Semestral', 17100.00, 450.00, 513.00, 2890.08, 20953.08, 'Tarjeta'),
    ('POL_AUTO_025', 'AUTO-2024-000025', 'AUTO', 'CLI0025', 'AGT002', '2024-07-15', '2024-07-16', '2025-07-16', 'Vigente', 'Anual', 30200.00, 450.00, 0.00, 4904.00, 35554.00, 'Transferencia'),
    ('POL_AUTO_026', 'AUTO-2024-000026', 'AUTO', 'CLI0026', 'AGT003', '2024-07-20', '2024-07-21', '2025-07-21', 'Vigente', 'Trimestral', 20100.00, 450.00, 804.00, 3416.64, 24770.64, 'Domiciliación'),
    ('POL_AUTO_027', 'AUTO-2024-000027', 'AUTO', 'CLI0027', 'AGT004', '2024-08-01', '2024-08-02', '2025-08-02', 'Vigente', 'Anual', 23400.00, 450.00, 0.00, 3816.00, 27666.00, 'Tarjeta'),
    ('POL_AUTO_028', 'AUTO-2024-000028', 'AUTO', 'CLI0028', 'AGT005', '2024-08-10', '2024-08-11', '2025-08-11', 'Vigente', 'Semestral', 22700.00, 450.00, 681.00, 3812.96, 27643.96, 'Transferencia'),
    ('POL_AUTO_029', 'AUTO-2024-000029', 'AUTO', 'CLI0029', 'AGT005', '2024-08-15', '2024-08-16', '2025-08-16', 'Vigente', 'Anual', 25100.00, 450.00, 0.00, 4088.00, 29638.00, 'Domiciliación'),
    ('POL_AUTO_030', 'AUTO-2024-000030', 'AUTO', 'CLI0030', 'AGT006', '2024-08-20', '2024-08-21', '2025-08-21', 'Vigente', 'Mensual', 16400.00, 450.00, 984.00, 2853.44, 20687.44, 'Tarjeta'),
    ('POL_AUTO_031', 'AUTO-2024-000031', 'AUTO', 'CLI0031', 'AGT007', '2024-09-01', '2024-09-02', '2025-09-02', 'Vigente', 'Anual', 23200.00, 450.00, 0.00, 3784.00, 27434.00, 'Transferencia'),
    ('POL_AUTO_032', 'AUTO-2024-000032', 'AUTO', 'CLI0032', 'AGT008', '2024-09-10', '2024-09-11', '2025-09-11', 'Vigente', 'Semestral', 18100.00, 450.00, 543.00, 3054.88, 22147.88, 'Domiciliación'),
    ('POL_AUTO_033', 'AUTO-2024-000033', 'AUTO', 'CLI0033', 'AGT001', '2024-09-15', '2024-09-16', '2025-09-16', 'Vigente', 'Anual', 35600.00, 450.00, 0.00, 5768.00, 41818.00, 'Tarjeta'),
    ('POL_AUTO_034', 'AUTO-2024-000034', 'AUTO', 'CLI0034', 'AGT002', '2024-09-20', '2024-09-21', '2025-09-21', 'Vigente', 'Trimestral', 22800.00, 450.00, 912.00, 3865.92, 28027.92, 'Transferencia'),
    ('POL_AUTO_035', 'AUTO-2024-000035', 'AUTO', 'CLI0035', 'AGT002', '2024-10-01', '2024-10-02', '2025-10-02', 'Vigente', 'Anual', 16200.00, 450.00, 0.00, 2664.00, 19314.00, 'Domiciliación'),
    ('POL_AUTO_036', 'AUTO-2024-000036', 'AUTO', 'CLI0036', 'AGT003', '2024-10-10', '2024-10-11', '2025-10-11', 'Vigente', 'Semestral', 15100.00, 450.00, 453.00, 2560.48, 18563.48, 'Tarjeta'),
    ('POL_AUTO_037', 'AUTO-2024-000037', 'AUTO', 'CLI0037', 'AGT004', '2024-10-15', '2024-10-16', '2025-10-16', 'Vigente', 'Anual', 27600.00, 450.00, 0.00, 4488.00, 32538.00, 'Transferencia'),
    ('POL_AUTO_038', 'AUTO-2024-000038', 'AUTO', 'CLI0038', 'AGT005', '2024-10-20', '2024-10-21', '2025-10-21', 'Vigente', 'Mensual', 15200.00, 450.00, 912.00, 2649.92, 19211.92, 'Domiciliación'),
    ('POL_AUTO_039', 'AUTO-2024-000039', 'AUTO', 'CLI0039', 'AGT005', '2024-11-01', '2024-11-02', '2025-11-02', 'Vigente', 'Anual', 18400.00, 450.00, 0.00, 3016.00, 21866.00, 'Tarjeta'),
    ('POL_AUTO_040', 'AUTO-2024-000040', 'AUTO', 'CLI0040', 'AGT006', '2024-11-10', '2024-11-11', '2025-11-11', 'Vigente', 'Semestral', 11800.00, 450.00, 354.00, 2016.64, 14620.64, 'Transferencia');

-- ============================================================================
-- DETALLE DE PÓLIZAS DE AUTO
-- ============================================================================
USE SCHEMA CENTINELA_DB.AUTOS;

INSERT INTO CENTINELA_DB.AUTOS.POLIZAS_AUTO
(poliza_auto_id, poliza_id, vehiculo_id, paquete_cobertura, suma_asegurada, deducible_dm, deducible_robo, cobertura_rc, cobertura_gm, cobertura_al, cobertura_av, conductor_habitual, edad_conductor, anios_experiencia, zona_circulacion, historial_siniestros, descuento_aplicado)
VALUES
    ('PA001', 'POL_AUTO_001', 'VEH0001', 'Amplia', 365000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Juan Pérez García', 39, 20, 'CDMX', 0, 15.00),
    ('PA002', 'POL_AUTO_002', 'VEH0002', 'Amplia', 485000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'María López Hernández', 34, 12, 'CDMX', 1, 10.00),
    ('PA003', 'POL_AUTO_003', 'VEH0003', 'Premium', 645000.00, 3.00, 5.00, 5000000.00, 750000.00, 750000.00, 1.00, 'Roberto Martínez Sánchez', 46, 28, 'CDMX', 0, 20.00),
    ('PA004', 'POL_AUTO_004', 'VEH0004', 'Amplia', 715000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Ana González Ruiz', 32, 10, 'CDMX', 0, 15.00),
    ('PA005', 'POL_AUTO_005', 'VEH0005', 'Amplia', 620000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Carlos Hernández López', 36, 15, 'Guadalajara', 0, 15.00),
    ('PA006', 'POL_AUTO_006', 'VEH0006', 'Limitada', 565000.00, 5.00, 10.00, 3000000.00, 300000.00, 300000.00, 1.00, 'Patricia Rodríguez Morales', 29, 8, 'Guadalajara', 0, 10.00),
    ('PA007', 'POL_AUTO_007', 'VEH0007', 'Amplia', 585000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Miguel Sánchez Torres', 42, 22, 'Monterrey', 1, 10.00),
    ('PA008', 'POL_AUTO_008', 'VEH0008', 'Premium', 670000.00, 3.00, 5.00, 5000000.00, 750000.00, 750000.00, 1.00, 'Laura Díaz García', 37, 16, 'CDMX', 0, 20.00),
    ('PA009', 'POL_AUTO_009', 'VEH0009', 'Premium', 695000.00, 3.00, 5.00, 5000000.00, 750000.00, 750000.00, 1.00, 'Fernando Torres Ramírez', 31, 10, 'CDMX', 0, 15.00),
    ('PA010', 'POL_AUTO_010', 'VEH0010', 'Limitada', 415000.00, 5.00, 10.00, 3000000.00, 300000.00, 300000.00, 1.00, 'Gabriela Morales Pérez', 35, 12, 'Puebla', 0, 10.00),
    ('PA011', 'POL_AUTO_011', 'VEH0011', 'Premium', 755000.00, 3.00, 5.00, 5000000.00, 750000.00, 750000.00, 1.00, 'Alejandro Ramírez Mendoza', 39, 18, 'Querétaro', 0, 20.00),
    ('PA012', 'POL_AUTO_012', 'VEH0012', 'Premium', 740000.00, 3.00, 5.00, 5000000.00, 750000.00, 750000.00, 1.00, 'Verónica Castro Luna', 33, 11, 'León', 0, 15.00),
    ('PA013', 'POL_AUTO_013', 'VEH0013', 'Amplia', 460000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Ricardo Flores Ortiz', 44, 25, 'CDMX', 2, 5.00),
    ('PA014', 'POL_AUTO_014', 'VEH0014', 'Amplia', 505000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Claudia Vargas Herrera', 30, 9, 'CDMX', 0, 15.00),
    ('PA015', 'POL_AUTO_015', 'VEH0015', 'Premium', 920000.00, 3.00, 5.00, 5000000.00, 1000000.00, 1000000.00, 1.00, 'Eduardo Reyes Silva', 38, 17, 'CDMX', 0, 25.00),
    ('PA016', 'POL_AUTO_016', 'VEH0016', 'Premium', 1050000.00, 3.00, 5.00, 5000000.00, 1000000.00, 1000000.00, 1.00, 'Mónica Aguilar Rojas', 36, 14, 'Guadalajara', 0, 25.00),
    ('PA017', 'POL_AUTO_017', 'VEH0017', 'Premium', 850000.00, 3.00, 5.00, 5000000.00, 1000000.00, 1000000.00, 1.00, 'Arturo Jiménez Cruz', 45, 26, 'Monterrey', 0, 25.00),
    ('PA018', 'POL_AUTO_018', 'VEH0018', 'Limitada', 455000.00, 5.00, 10.00, 3000000.00, 300000.00, 300000.00, 1.00, 'Sandra Medina Vázquez', 32, 10, 'CDMX', 0, 10.00),
    ('PA019', 'POL_AUTO_019', 'VEH0019', 'Amplia', 745000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Héctor Ortega Navarro', 40, 20, 'CDMX', 0, 15.00),
    ('PA020', 'POL_AUTO_020', 'VEH0020', 'Premium', 1150000.00, 3.00, 5.00, 5000000.00, 1000000.00, 1000000.00, 1.00, 'Diana Guerrero Mendez', 28, 7, 'Puebla', 0, 10.00),
    ('PA021', 'POL_AUTO_021', 'VEH0021', 'RC', 320000.00, 0.00, 0.00, 3000000.00, 0.00, 0.00, 1.00, 'Pablo Ríos Delgado', 37, 15, 'Querétaro', 0, 5.00),
    ('PA022', 'POL_AUTO_022', 'VEH0022', 'Amplia', 610000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Lucía Espinoza Paredes', 34, 12, 'León', 1, 10.00),
    ('PA023', 'POL_AUTO_023', 'VEH0023', 'Amplia', 685000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Andrés Campos Serrano', 43, 24, 'CDMX', 0, 20.00),
    ('PA024', 'POL_AUTO_024', 'VEH0024', 'Limitada', 495000.00, 5.00, 10.00, 3000000.00, 300000.00, 300000.00, 1.00, 'Teresa Núñez Ibarra', 31, 10, 'CDMX', 0, 10.00),
    ('PA025', 'POL_AUTO_025', 'VEH0025', 'Premium', 810000.00, 3.00, 5.00, 5000000.00, 750000.00, 750000.00, 1.00, 'Víctor Cervantes Molina', 39, 18, 'CDMX', 0, 20.00),
    ('PA026', 'POL_AUTO_026', 'VEH0026', 'Amplia', 590000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Beatriz Pacheco Ávila', 36, 14, 'Guadalajara', 0, 15.00),
    ('PA027', 'POL_AUTO_027', 'VEH0027', 'Amplia', 665000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Enrique Miranda Cabrera', 45, 26, 'Monterrey', 0, 20.00),
    ('PA028', 'POL_AUTO_028', 'VEH0028', 'Amplia', 655000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Adriana Fuentes Ochoa', 33, 11, 'CDMX', 0, 15.00),
    ('PA029', 'POL_AUTO_029', 'VEH0029', 'Amplia', 715000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Gerardo Salazar Valdés', 41, 21, 'CDMX', 1, 10.00),
    ('PA030', 'POL_AUTO_030', 'VEH0030', 'Limitada', 475000.00, 5.00, 10.00, 3000000.00, 300000.00, 300000.00, 1.00, 'Karla Lara Guzmán', 29, 8, 'Puebla', 0, 10.00),
    ('PA031', 'POL_AUTO_031', 'VEH0031', 'Amplia', 665000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Raúl Contreras Peña', 38, 16, 'Querétaro', 0, 15.00),
    ('PA032', 'POL_AUTO_032', 'VEH0032', 'Amplia', 520000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Irene Domínguez Bautista', 35, 13, 'León', 0, 15.00),
    ('PA033', 'POL_AUTO_033', 'VEH0033', 'Premium', 945000.00, 3.00, 5.00, 5000000.00, 1000000.00, 1000000.00, 1.00, 'Sergio Navarro Escobedo', 44, 25, 'CDMX', 0, 25.00),
    ('PA034', 'POL_AUTO_034', 'VEH0034', 'Amplia', 665000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Alicia Herrera Córdova', 32, 10, 'CDMX', 0, 15.00),
    ('PA035', 'POL_AUTO_035', 'VEH0035', 'Limitada', 465000.00, 5.00, 10.00, 3000000.00, 300000.00, 300000.00, 1.00, 'Mario Vega Zamora', 40, 19, 'CDMX', 1, 5.00),
    ('PA036', 'POL_AUTO_036', 'VEH0036', 'Limitada', 445000.00, 5.00, 10.00, 3000000.00, 300000.00, 300000.00, 1.00, 'Silvia Orozco Mejía', 37, 15, 'Guadalajara', 0, 10.00),
    ('PA037', 'POL_AUTO_037', 'VEH0037', 'Amplia', 755000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Oscar Sandoval Romo', 46, 27, 'Monterrey', 0, 20.00),
    ('PA038', 'POL_AUTO_038', 'VEH0038', 'Limitada', 445000.00, 5.00, 10.00, 3000000.00, 300000.00, 300000.00, 1.00, 'Norma Rangel Estrada', 34, 12, 'CDMX', 0, 10.00),
    ('PA039', 'POL_AUTO_039', 'VEH0039', 'Amplia', 525000.00, 5.00, 10.00, 3000000.00, 500000.00, 500000.00, 1.00, 'Felipe Cortés Bravo', 42, 22, 'CDMX', 0, 15.00),
    ('PA040', 'POL_AUTO_040', 'VEH0040', 'RC', 345000.00, 0.00, 0.00, 3000000.00, 0.00, 0.00, 1.00, 'Leticia Valencia Montes', 30, 9, 'Puebla', 0, 5.00);


