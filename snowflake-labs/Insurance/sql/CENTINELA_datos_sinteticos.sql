-- ============================================================================
-- SEGUROS CENTINELA - DATOS SINTÉTICOS
-- ============================================================================
-- Descripción: Generación de datos realistas para demos
-- Autor: Ingeniero de Datos
-- ============================================================================

USE DATABASE CENTINELA_DB;
USE WAREHOUSE CENTINELA_WH;

-- ============================================================================
-- DATOS DE AGENTES
-- ============================================================================
USE SCHEMA CENTINELA_DB.CORE;

INSERT INTO CENTINELA_DB.CORE.AGENTES (agente_id, nombre, apellido_paterno, apellido_materno, email, telefono, fecha_ingreso, sucursal, region, nivel, comision_porcentaje)
VALUES
    ('AGT001', 'Carlos', 'Mendoza', 'Ruiz', 'carlos.mendoza@centinela.mx', '5551234567', '2018-03-15', 'CDMX Centro', 'Centro', 'Ejecutivo', 15.00),
    ('AGT002', 'María', 'González', 'Pérez', 'maria.gonzalez@centinela.mx', '5552345678', '2019-07-22', 'CDMX Sur', 'Centro', 'Senior', 12.50),
    ('AGT003', 'Roberto', 'Hernández', 'López', 'roberto.hernandez@centinela.mx', '5553456789', '2020-01-10', 'Guadalajara', 'Occidente', 'Senior', 12.00),
    ('AGT004', 'Ana', 'Martínez', 'Sánchez', 'ana.martinez@centinela.mx', '5554567890', '2021-05-18', 'Monterrey', 'Norte', 'Junior', 10.00),
    ('AGT005', 'Jorge', 'López', 'García', 'jorge.lopez@centinela.mx', '5555678901', '2017-11-03', 'CDMX Norte', 'Centro', 'Ejecutivo', 15.00),
    ('AGT006', 'Patricia', 'Ramírez', 'Torres', 'patricia.ramirez@centinela.mx', '5556789012', '2022-02-28', 'Puebla', 'Centro', 'Junior', 10.00),
    ('AGT007', 'Fernando', 'Díaz', 'Morales', 'fernando.diaz@centinela.mx', '5557890123', '2019-09-14', 'Querétaro', 'Bajío', 'Senior', 12.00),
    ('AGT008', 'Laura', 'Sánchez', 'Hernández', 'laura.sanchez@centinela.mx', '5558901234', '2020-08-07', 'León', 'Bajío', 'Senior', 12.00);

-- ============================================================================
-- DATOS DE CLIENTES (80 clientes para las 80 pólizas)
-- ============================================================================
-- Nota: CURP = 4 letras + 6 digitos + 1 sexo + 2 estado + 5 alfanum = 18 chars

-- Primeros 40 clientes (para pólizas AUTO)
INSERT INTO CENTINELA_DB.CORE.CLIENTES 
(cliente_id, tipo_persona, nombre, apellido_paterno, apellido_materno, rfc, curp, fecha_nacimiento, genero, estado_civil, email, telefono_celular, calle, numero_exterior, colonia, codigo_postal, municipio, estado, agente_id)
VALUES
    ('CLI0001', 'Fisica', 'Juan', 'Pérez', 'García', 'PEGJ850315ABC', 'PEGJ850315HDFRRC01', '1985-03-15', 'M', 'Casado', 'juan.perez@gmail.com', '5551001001', 'Av. Insurgentes Sur', '1234', 'Del Valle', '03100', 'Benito Juárez', 'Ciudad de México', 'AGT001'),
    ('CLI0002', 'Fisica', 'María', 'López', 'Hernández', 'LOHM900528DEF', 'LOHM900528MDFPNR02', '1990-05-28', 'F', 'Soltera', 'maria.lopez@outlook.com', '5551002002', 'Calle Durango', '567', 'Roma Norte', '06700', 'Cuauhtémoc', 'Ciudad de México', 'AGT001'),
    ('CLI0003', 'Fisica', 'Roberto', 'Martínez', 'Sánchez', 'MASR780812GHI', 'MASR780812HDFRNB03', '1978-08-12', 'M', 'Casado', 'roberto.mtz@yahoo.com', '5551003003', 'Paseo de la Reforma', '890', 'Juárez', '06600', 'Cuauhtémoc', 'Ciudad de México', 'AGT002'),
    ('CLI0004', 'Fisica', 'Ana', 'González', 'Ruiz', 'GORA920214JKL', 'GORA920214MDFNZN04', '1992-02-14', 'F', 'Casada', 'ana.gonzalez@gmail.com', '5551004004', 'Av. Universidad', '2345', 'Copilco', '04360', 'Coyoacán', 'Ciudad de México', 'AGT002'),
    ('CLI0005', 'Fisica', 'Carlos', 'Hernández', 'López', 'HELC880923MNO', 'HELC880923HDFRPR05', '1988-09-23', 'M', 'Soltero', 'carlos.hdz@hotmail.com', '5551005005', 'Blvd. Adolfo López Mateos', '678', 'San Ángel', '01000', 'Álvaro Obregón', 'Ciudad de México', 'AGT003'),
    ('CLI0006', 'Fisica', 'Patricia', 'Rodríguez', 'Morales', 'ROMP950607PQR', 'ROMP950607MJCDRT06', '1995-06-07', 'F', 'Soltera', 'patricia.rdz@gmail.com', '3331006006', 'Av. Chapultepec', '1011', 'Americana', '44160', 'Guadalajara', 'Jalisco', 'AGT003'),
    ('CLI0007', 'Fisica', 'Miguel', 'Sánchez', 'Torres', 'SATM820418STU', 'SATM820418HNLNNG07', '1982-04-18', 'M', 'Casado', 'miguel.sanchez@gmail.com', '8181007007', 'Av. Constitución', '1213', 'Centro', '64000', 'Monterrey', 'Nuevo León', 'AGT004'),
    ('CLI0008', 'Fisica', 'Laura', 'Díaz', 'García', 'DIGL870729VWX', 'DIGL870729MDFRRC08', '1987-07-29', 'F', 'Casada', 'laura.diaz@outlook.com', '5551008008', 'Calle Liverpool', '1415', 'Zona Rosa', '06600', 'Cuauhtémoc', 'Ciudad de México', 'AGT005'),
    ('CLI0009', 'Fisica', 'Fernando', 'Torres', 'Ramírez', 'TORF930310YZA', 'TORF930310HDFRRN09', '1993-03-10', 'M', 'Soltero', 'fernando.torres@gmail.com', '5551009009', 'Av. Revolución', '1617', 'Mixcoac', '03910', 'Benito Juárez', 'Ciudad de México', 'AGT005'),
    ('CLI0010', 'Fisica', 'Gabriela', 'Morales', 'Pérez', 'MOPG890521BCD', 'MOPG890521MPLRRL10', '1989-05-21', 'F', 'Casada', 'gabriela.morales@yahoo.com', '2221010010', 'Blvd. 5 de Mayo', '1819', 'Centro', '72000', 'Puebla', 'Puebla', 'AGT006'),
    ('CLI0011', 'Fisica', 'Alejandro', 'Ramírez', 'Mendoza', 'RAMA850714EFG', 'RAMA850714HQTMML11', '1985-07-14', 'M', 'Casado', 'alejandro.rmz@gmail.com', '4421011011', 'Av. Tecnológico', '2021', 'Carretas', '76050', 'Querétaro', 'Querétaro', 'AGT007'),
    ('CLI0012', 'Fisica', 'Verónica', 'Castro', 'Luna', 'CALV910826HIJ', 'CALV910826MGTSNR12', '1991-08-26', 'F', 'Soltera', 'veronica.castro@hotmail.com', '4771012012', 'Blvd. Juan Alonso de Torres', '2223', 'San Isidro', '37530', 'León', 'Guanajuato', 'AGT008'),
    ('CLI0013', 'Fisica', 'Ricardo', 'Flores', 'Ortiz', 'FLOR800103KLM', 'FLOR800103HDFLRC13', '1980-01-03', 'M', 'Divorciado', 'ricardo.flores@gmail.com', '5551013013', 'Calz. de Tlalpan', '2425', 'Portales', '03300', 'Benito Juárez', 'Ciudad de México', 'AGT001'),
    ('CLI0014', 'Fisica', 'Claudia', 'Vargas', 'Herrera', 'VAHC940215NOP', 'VAHC940215MDFRRL14', '1994-02-15', 'F', 'Soltera', 'claudia.vargas@outlook.com', '5551014014', 'Av. Coyoacán', '2627', 'Xoco', '03330', 'Benito Juárez', 'Ciudad de México', 'AGT002'),
    ('CLI0015', 'Fisica', 'Eduardo', 'Reyes', 'Silva', 'RESE860420QRS', 'RESE860420HDFYLD15', '1986-04-20', 'M', 'Casado', 'eduardo.reyes@gmail.com', '5551015015', 'Periférico Sur', '2829', 'Pedregal', '14010', 'Tlalpan', 'Ciudad de México', 'AGT002'),
    ('CLI0016', 'Fisica', 'Mónica', 'Aguilar', 'Rojas', 'AURM880630TUV', 'AURM880630MJCGJN16', '1988-06-30', 'F', 'Casada', 'monica.aguilar@yahoo.com', '3331016016', 'Av. Vallarta', '3031', 'Arcos Vallarta', '44130', 'Guadalajara', 'Jalisco', 'AGT003'),
    ('CLI0017', 'Fisica', 'Arturo', 'Jiménez', 'Cruz', 'JICA790815WXY', 'JICA790815HNLMNR17', '1979-08-15', 'M', 'Casado', 'arturo.jimenez@gmail.com', '8181017017', 'Av. Lázaro Cárdenas', '3233', 'Del Valle', '66220', 'San Pedro Garza García', 'Nuevo León', 'AGT004'),
    ('CLI0018', 'Fisica', 'Sandra', 'Medina', 'Vázquez', 'MEVS920925ZAB', 'MEVS920925MDFDNZ18', '1992-09-25', 'F', 'Soltera', 'sandra.medina@hotmail.com', '5551018018', 'Av. Patriotismo', '3435', 'Escandón', '11800', 'Miguel Hidalgo', 'Ciudad de México', 'AGT005'),
    ('CLI0019', 'Fisica', 'Héctor', 'Ortega', 'Navarro', 'OENH840505CDE', 'OENH840505HDFRTR19', '1984-05-05', 'M', 'Casado', 'hector.ortega@gmail.com', '5551019019', 'Calz. de la Viga', '3637', 'Jamaica', '15800', 'Venustiano Carranza', 'Ciudad de México', 'AGT005'),
    ('CLI0020', 'Fisica', 'Diana', 'Guerrero', 'Mendez', 'GUMD960710FGH', 'GUMD960710MPLRNN20', '1996-07-10', 'F', 'Soltera', 'diana.guerrero@outlook.com', '2221020020', 'Av. Juárez', '3839', 'Centro', '72000', 'Puebla', 'Puebla', 'AGT006'),
    ('CLI0021', 'Fisica', 'Pablo', 'Ríos', 'Delgado', 'RIDP870820IJK', 'RIDP870820HQTSBL21', '1987-08-20', 'M', 'Soltero', 'pablo.rios@gmail.com', '4421021021', 'Av. 5 de Febrero', '4041', 'La Pradera', '76120', 'Querétaro', 'Querétaro', 'AGT007'),
    ('CLI0022', 'Fisica', 'Lucía', 'Espinoza', 'Paredes', 'EIPL900930LMN', 'EIPL900930MGTSPC22', '1990-09-30', 'F', 'Casada', 'lucia.espinoza@yahoo.com', '4771022022', 'Blvd. Adolfo López Mateos', '4243', 'León I', '37238', 'León', 'Guanajuato', 'AGT008'),
    ('CLI0023', 'Fisica', 'Andrés', 'Campos', 'Serrano', 'CASA810110OPQ', 'CASA810110HDFMPR23', '1981-01-10', 'M', 'Casado', 'andres.campos@gmail.com', '5551023023', 'Av. División del Norte', '4445', 'Narvarte', '03020', 'Benito Juárez', 'Ciudad de México', 'AGT001'),
    ('CLI0024', 'Fisica', 'Teresa', 'Núñez', 'Ibarra', 'NUIT930220RST', 'NUIT930220MDFXBR24', '1993-02-20', 'F', 'Soltera', 'teresa.nunez@hotmail.com', '5551024024', 'Eje Central', '4647', 'Doctores', '06720', 'Cuauhtémoc', 'Ciudad de México', 'AGT002'),
    ('CLI0025', 'Fisica', 'Víctor', 'Cervantes', 'Molina', 'CEMV850405UVW', 'CEMV850405HDFRVC25', '1985-04-05', 'M', 'Divorciado', 'victor.cervantes@gmail.com', '5551025025', 'Calz. de los Misterios', '4849', 'Tepeyac', '07020', 'Gustavo A. Madero', 'Ciudad de México', 'AGT002'),
    ('CLI0026', 'Fisica', 'Beatriz', 'Pacheco', 'Ávila', 'PAAB880615XYZ', 'PAAB880615MJCCVL26', '1988-06-15', 'F', 'Casada', 'beatriz.pacheco@outlook.com', '3331026026', 'Av. México', '5051', 'Monraz', '44670', 'Guadalajara', 'Jalisco', 'AGT003'),
    ('CLI0027', 'Fisica', 'Enrique', 'Miranda', 'Cabrera', 'MICE790820ABC', 'MICE790820HNLRBN27', '1979-08-20', 'M', 'Casado', 'enrique.miranda@gmail.com', '8181027027', 'Av. Eugenio Garza Sada', '5253', 'Alta Vista', '64840', 'Monterrey', 'Nuevo León', 'AGT004'),
    ('CLI0028', 'Fisica', 'Adriana', 'Fuentes', 'Ochoa', 'FUOA910930DEF', 'FUOA910930MDFNCR28', '1991-09-30', 'F', 'Soltera', 'adriana.fuentes@yahoo.com', '5551028028', 'Av. Cuauhtémoc', '5455', 'Narvarte', '03020', 'Benito Juárez', 'Ciudad de México', 'AGT005'),
    ('CLI0029', 'Fisica', 'Gerardo', 'Salazar', 'Valdés', 'SAVG830108GHI', 'SAVG830108HDFLVR29', '1983-01-08', 'M', 'Casado', 'gerardo.salazar@gmail.com', '5551029029', 'Insurgentes Norte', '5657', 'Lindavista', '07300', 'Gustavo A. Madero', 'Ciudad de México', 'AGT005'),
    ('CLI0030', 'Fisica', 'Karla', 'Lara', 'Guzmán', 'LAGK950318JKL', 'LAGK950318MPLRZM30', '1995-03-18', 'F', 'Soltera', 'karla.lara@hotmail.com', '2221030030', 'Blvd. Atlixco', '5859', 'La Paz', '72160', 'Puebla', 'Puebla', 'AGT006'),
    ('CLI0031', 'Fisica', 'Raúl', 'Contreras', 'Peña', 'COPR860528MNO', 'COPR860528HQTNXL31', '1986-05-28', 'M', 'Soltero', 'raul.contreras@gmail.com', '4421031031', 'Av. Zaragoza', '6061', 'Centro', '76000', 'Querétaro', 'Querétaro', 'AGT007'),
    ('CLI0032', 'Fisica', 'Irene', 'Domínguez', 'Bautista', 'DOBI890708PQR', 'DOBI890708MGTMTR32', '1989-07-08', 'F', 'Casada', 'irene.dominguez@outlook.com', '4771032032', 'Av. Miguel Alemán', '6263', 'Centro', '37000', 'León', 'Guanajuato', 'AGT008'),
    ('CLI0033', 'Fisica', 'Sergio', 'Navarro', 'Escobedo', 'NAES800918STU', 'NAES800918HDFVCS33', '1980-09-18', 'M', 'Casado', 'sergio.navarro@gmail.com', '5551033033', 'Av. Taxqueña', '6465', 'Campestre Churubusco', '04200', 'Coyoacán', 'Ciudad de México', 'AGT001'),
    ('CLI0034', 'Fisica', 'Alicia', 'Herrera', 'Córdova', 'HECA920128VWX', 'HECA920128MDFRRR34', '1992-01-28', 'F', 'Soltera', 'alicia.herrera@yahoo.com', '5551034034', 'Calz. México-Tacuba', '6667', 'Popotla', '11400', 'Miguel Hidalgo', 'Ciudad de México', 'AGT002'),
    ('CLI0035', 'Fisica', 'Mario', 'Vega', 'Zamora', 'VEZM840308YZA', 'VEZM840308HDFGRR35', '1984-03-08', 'M', 'Divorciado', 'mario.vega@gmail.com', '5551035035', 'Av. de los Insurgentes', '6869', 'Florida', '01030', 'Álvaro Obregón', 'Ciudad de México', 'AGT002'),
    ('CLI0036', 'Fisica', 'Silvia', 'Orozco', 'Mejía', 'OOMS870518BCD', 'OOMS870518MJCRJL36', '1987-05-18', 'F', 'Casada', 'silvia.orozco@hotmail.com', '3331036036', 'Av. Federalismo', '7071', 'Centro', '44100', 'Guadalajara', 'Jalisco', 'AGT003'),
    ('CLI0037', 'Fisica', 'Oscar', 'Sandoval', 'Romo', 'SARO780728EFG', 'SARO780728HNLNMS37', '1978-07-28', 'M', 'Casado', 'oscar.sandoval@gmail.com', '8181037037', 'Av. Venustiano Carranza', '7273', 'Centro', '64000', 'Monterrey', 'Nuevo León', 'AGT004'),
    ('CLI0038', 'Fisica', 'Norma', 'Rangel', 'Estrada', 'RAEN900908HIJ', 'RAEN900908MDFNGS38', '1990-09-08', 'F', 'Soltera', 'norma.rangel@outlook.com', '5551038038', 'Calz. Ermita Iztapalapa', '7475', 'Santa María Aztahuacan', '09500', 'Iztapalapa', 'Ciudad de México', 'AGT005'),
    ('CLI0039', 'Fisica', 'Felipe', 'Cortés', 'Bravo', 'COBF820118KLM', 'COBF820118HDFRRV39', '1982-01-18', 'M', 'Casado', 'felipe.cortes@gmail.com', '5551039039', 'Av. Tláhuac', '7677', 'San Lorenzo Tezonco', '09900', 'Iztapalapa', 'Ciudad de México', 'AGT005'),
    ('CLI0040', 'Fisica', 'Leticia', 'Valencia', 'Montes', 'VAML940328NOP', 'VAML940328MPLNLT40', '1994-03-28', 'F', 'Casada', 'leticia.valencia@yahoo.com', '2221040040', 'Blvd. Norte', '7879', 'Los Volcanes', '72440', 'Puebla', 'Puebla', 'AGT006');

-- Siguientes 40 clientes (para pólizas GMM)
INSERT INTO CENTINELA_DB.CORE.CLIENTES 
(cliente_id, tipo_persona, nombre, apellido_paterno, apellido_materno, rfc, curp, fecha_nacimiento, genero, estado_civil, email, telefono_celular, calle, numero_exterior, colonia, codigo_postal, municipio, estado, agente_id)
VALUES
    ('CLI0041', 'Fisica', 'José', 'Aguirre', 'Solís', 'AUSJ850508QRS', 'AUSJ850508HDFGSL41', '1985-05-08', 'M', 'Casado', 'jose.aguirre@gmail.com', '5552041041', 'Av. Presidente Masaryk', '100', 'Polanco', '11560', 'Miguel Hidalgo', 'Ciudad de México', 'AGT001'),
    ('CLI0042', 'Fisica', 'Rosa', 'Padilla', 'Quintana', 'PAQR880718TUV', 'PAQR880718MDFDNS42', '1988-07-18', 'F', 'Casada', 'rosa.padilla@outlook.com', '5552042042', 'Paseo de las Palmas', '200', 'Lomas de Chapultepec', '11000', 'Miguel Hidalgo', 'Ciudad de México', 'AGT001'),
    ('CLI0043', 'Fisica', 'Alberto', 'Peña', 'Vázquez', 'PEVA790928WXY', 'PEVA790928HDFXZB43', '1979-09-28', 'M', 'Casado', 'alberto.pena@gmail.com', '5552043043', 'Av. Santa Fe', '300', 'Santa Fe', '01210', 'Cuajimalpa', 'Ciudad de México', 'AGT002'),
    ('CLI0044', 'Fisica', 'Margarita', 'Castillo', 'Luna', 'CALM910208ZAB', 'CALM910208MDFSNT44', '1991-02-08', 'F', 'Soltera', 'margarita.castillo@yahoo.com', '5552044044', 'Calz. Desierto de los Leones', '400', 'San Ángel Inn', '01060', 'Álvaro Obregón', 'Ciudad de México', 'AGT002'),
    ('CLI0045', 'Fisica', 'Francisco', 'Mendez', 'Robles', 'MERF830418CDE', 'MERF830418HJCNBS45', '1983-04-18', 'M', 'Divorciado', 'francisco.mendez@hotmail.com', '3332045045', 'Av. Pablo Neruda', '500', 'Providencia', '44630', 'Guadalajara', 'Jalisco', 'AGT003'),
    ('CLI0046', 'Fisica', 'Carmen', 'Escobar', 'Ruiz', 'ESRC940628FGH', 'ESRC940628MJCSCR46', '1994-06-28', 'F', 'Soltera', 'carmen.escobar@gmail.com', '3332046046', 'Av. Américas', '600', 'Country Club', '44610', 'Guadalajara', 'Jalisco', 'AGT003'),
    ('CLI0047', 'Fisica', 'Antonio', 'Chávez', 'Ibarra', 'CHIA800808IJK', 'CHIA800808HNLHVN47', '1980-08-08', 'M', 'Casado', 'antonio.chavez@outlook.com', '8182047047', 'Calz. del Valle', '700', 'Del Valle', '66220', 'San Pedro Garza García', 'Nuevo León', 'AGT004'),
    ('CLI0048', 'Fisica', 'Elena', 'Gutiérrez', 'Ponce', 'GUPE890918LMN', 'GUPE890918MNLTRL48', '1989-09-18', 'F', 'Casada', 'elena.gutierrez@gmail.com', '8182048048', 'Av. Morones Prieto', '800', 'Los Doctores', '64710', 'Monterrey', 'Nuevo León', 'AGT004'),
    ('CLI0049', 'Fisica', 'Rafael', 'Delgado', 'Cruz', 'DECR860128OPQ', 'DECR860128HDFLGR49', '1986-01-28', 'M', 'Soltero', 'rafael.delgado@yahoo.com', '5552049049', 'Av. Vasco de Quiroga', '900', 'Zedec', '01210', 'Cuajimalpa', 'Ciudad de México', 'AGT005'),
    ('CLI0050', 'Fisica', 'Juana', 'Montes', 'Galván', 'MOGJ920308RST', 'MOGJ920308MDFNTN50', '1992-03-08', 'F', 'Casada', 'juana.montes@hotmail.com', '5552050050', 'Av. Barranca del Muerto', '1000', 'Guadalupe Inn', '01020', 'Álvaro Obregón', 'Ciudad de México', 'AGT005'),
    ('CLI0051', 'Fisica', 'Javier', 'Villanueva', 'Correa', 'VICJ870518UVW', 'VICJ870518HPLLLN51', '1987-05-18', 'M', 'Casado', 'javier.villanueva@gmail.com', '2222051051', 'Av. Forjadores', '1100', 'San Baltazar Campeche', '72550', 'Puebla', 'Puebla', 'AGT006'),
    ('CLI0052', 'Fisica', 'Yolanda', 'Coronado', 'Torres', 'COTY900728XYZ', 'COTY900728MPLRRY52', '1990-07-28', 'F', 'Soltera', 'yolanda.coronado@outlook.com', '2222052052', 'Blvd. Hermanos Serdán', '1200', 'Aquiles Serdán', '72140', 'Puebla', 'Puebla', 'AGT006'),
    ('CLI0053', 'Fisica', 'Daniel', 'Bernal', 'Arriaga', 'BEAD810908ABC', 'BEAD810908HQTRNN53', '1981-09-08', 'M', 'Casado', 'daniel.bernal@gmail.com', '4422053053', 'Blvd. Bernardo Quintana', '1300', 'Carretas', '76050', 'Querétaro', 'Querétaro', 'AGT007'),
    ('CLI0054', 'Fisica', 'Gloria', 'Cisneros', 'Velasco', 'CIVG930118DEF', 'CIVG930118MQTSNL54', '1993-01-18', 'F', 'Casada', 'gloria.cisneros@yahoo.com', '4422054054', 'Av. Universidad', '1400', 'Juriquilla', '76230', 'Querétaro', 'Querétaro', 'AGT007'),
    ('CLI0055', 'Fisica', 'Rubén', 'Estrada', 'Nava', 'ESNR840328GHI', 'ESNR840328HGTSTN55', '1984-03-28', 'M', 'Soltero', 'ruben.estrada@hotmail.com', '4772055055', 'Blvd. Torres Landa', '1500', 'Los Álamos', '37579', 'León', 'Guanajuato', 'AGT008'),
    ('CLI0056', 'Fisica', 'Martha', 'Franco', 'Osorio', 'FAOM870608JKL', 'FAOM870608MGTRNR56', '1987-06-08', 'F', 'Casada', 'martha.franco@gmail.com', '4772056056', 'Av. López Mateos', '1600', 'Jardines del Moral', '37160', 'León', 'Guanajuato', 'AGT008'),
    ('CLI0057', 'Fisica', 'Guillermo', 'Garza', 'Saldaña', 'GASG790818MNO', 'GASG790818HDFRZL57', '1979-08-18', 'M', 'Casado', 'guillermo.garza@outlook.com', '5552057057', 'Av. Cuauhtémoc', '1700', 'Roma Sur', '06760', 'Cuauhtémoc', 'Ciudad de México', 'AGT001'),
    ('CLI0058', 'Fisica', 'Adriana', 'Huerta', 'Benítez', 'HUBA920928PQR', 'HUBA920928MDFRTN58', '1992-09-28', 'F', 'Soltera', 'adriana.huerta@yahoo.com', '5552058058', 'Av. Eje Central', '1800', 'Centro', '06040', 'Cuauhtémoc', 'Ciudad de México', 'AGT002'),
    ('CLI0059', 'Fisica', 'Ignacio', 'Islas', 'Montoya', 'ISMI850108STU', 'ISMI850108HDFSLN59', '1985-01-08', 'M', 'Casado', 'ignacio.islas@gmail.com', '5552059059', 'Av. Miguel Ángel de Quevedo', '1900', 'Chimalistac', '01070', 'Álvaro Obregón', 'Ciudad de México', 'AGT002'),
    ('CLI0060', 'Fisica', 'Elvira', 'Jurado', 'Castro', 'JUCE880318VWX', 'JUCE880318MJCRRL60', '1988-03-18', 'F', 'Casada', 'elvira.jurado@hotmail.com', '3332060060', 'Av. Patria', '2000', 'Zapopan Centro', '45100', 'Zapopan', 'Jalisco', 'AGT003'),
    ('CLI0061', 'Fisica', 'Mauricio', 'Leal', 'Durán', 'LEDM810528YZA', 'LEDM810528HJCLDR61', '1981-05-28', 'M', 'Divorciado', 'mauricio.leal@gmail.com', '3332061061', 'Av. López Mateos Sur', '2100', 'Ciudad del Sol', '45050', 'Zapopan', 'Jalisco', 'AGT003'),
    ('CLI0062', 'Fisica', 'Fabiola', 'Manzano', 'Quiroz', 'MAQF940808BCD', 'MAQF940808MNLNZR62', '1994-08-08', 'F', 'Soltera', 'fabiola.manzano@outlook.com', '8182062062', 'Av. Alfonso Reyes', '2200', 'Cumbres', '64610', 'Monterrey', 'Nuevo León', 'AGT004'),
    ('CLI0063', 'Fisica', 'Octavio', 'Narvaez', 'Velázquez', 'NAVO861018EFG', 'NAVO861018HNLRRC63', '1986-10-18', 'M', 'Casado', 'octavio.narvaez@yahoo.com', '8182063063', 'Av. Revolución', '2300', 'Miravalle', '64660', 'Monterrey', 'Nuevo León', 'AGT004'),
    ('CLI0064', 'Fisica', 'Rocío', 'Olivares', 'Suárez', 'OISR890228HIJ', 'OISR890228MDFSLR64', '1989-02-28', 'F', 'Casada', 'rocio.olivares@gmail.com', '5552064064', 'Av. Toluca', '2400', 'Olivar de los Padres', '01780', 'Álvaro Obregón', 'Ciudad de México', 'AGT005'),
    ('CLI0065', 'Fisica', 'Tomás', 'Pineda', 'Uribe', 'PIUT820508KLM', 'PIUT820508HDFNRR65', '1982-05-08', 'M', 'Casado', 'tomas.pineda@hotmail.com', '5552065065', 'Calz. de las Águilas', '2500', 'Las Águilas', '01710', 'Álvaro Obregón', 'Ciudad de México', 'AGT005'),
    ('CLI0066', 'Fisica', 'Susana', 'Quintero', 'Landa', 'QULS910718NOP', 'QULS910718MPLNNS66', '1991-07-18', 'F', 'Soltera', 'susana.quintero@outlook.com', '2222066066', 'Av. Reforma', '2600', 'Amor', '72140', 'Puebla', 'Puebla', 'AGT006'),
    ('CLI0067', 'Fisica', 'Ernesto', 'Rico', 'Mena', 'RIME840928QRS', 'RIME840928HPLCNR67', '1984-09-28', 'M', 'Casado', 'ernesto.rico@gmail.com', '2222067067', 'Blvd. Xonaca', '2700', 'Bugambilias', '72580', 'Puebla', 'Puebla', 'AGT006'),
    ('CLI0068', 'Fisica', 'Lorena', 'Solano', 'Téllez', 'SOTL870208TUV', 'SOTL870208MQTLNR68', '1987-02-08', 'F', 'Casada', 'lorena.solano@yahoo.com', '4422068068', 'Av. Constituyentes', '2800', 'El Jacal', '76180', 'Querétaro', 'Querétaro', 'AGT007'),
    ('CLI0069', 'Fisica', 'Adrián', 'Tapia', 'Zavala', 'TAZA800418WXY', 'TAZA800418HQTPVD69', '1980-04-18', 'M', 'Soltero', 'adrian.tapia@gmail.com', '4422069069', 'Blvd. Centro Sur', '2900', 'Centro Sur', '76090', 'Querétaro', 'Querétaro', 'AGT007'),
    ('CLI0070', 'Fisica', 'Cecilia', 'Uriarte', 'Bermúdez', 'UIBC930628ZAB', 'UIBC930628MGTRRC70', '1993-06-28', 'F', 'Casada', 'cecilia.uriarte@hotmail.com', '4772070070', 'Blvd. Campestre', '3000', 'Jardines del Campestre', '37128', 'León', 'Guanajuato', 'AGT008'),
    ('CLI0071', 'Fisica', 'Samuel', 'Valdez', 'Carrillo', 'VACS860908CDE', 'VACS860908HGTLDR71', '1986-09-08', 'M', 'Casado', 'samuel.valdez@outlook.com', '4772071071', 'Blvd. Juan José Torres Landa', '3100', 'Solares', '37377', 'León', 'Guanajuato', 'AGT008'),
    ('CLI0072', 'Fisica', 'Norma', 'Wences', 'Paz', 'WEPN880118FGH', 'WEPN880118MDFNZR72', '1988-01-18', 'F', 'Casada', 'norma.wences@gmail.com', '5552072072', 'Av. Churubusco', '3200', 'Country Club', '04220', 'Coyoacán', 'Ciudad de México', 'AGT001'),
    ('CLI0073', 'Fisica', 'Ramón', 'Yáñez', 'Solís', 'YASR810328IJK', 'YASR810328HDFXNM73', '1981-03-28', 'M', 'Casado', 'ramon.yanez@yahoo.com', '5552073073', 'Av. Popocatépetl', '3300', 'Portales', '03300', 'Benito Juárez', 'Ciudad de México', 'AGT002'),
    ('CLI0074', 'Fisica', 'Olivia', 'Zaragoza', 'Macías', 'ZAMO940608LMN', 'ZAMO940608MDFRGR74', '1994-06-08', 'F', 'Soltera', 'olivia.zaragoza@hotmail.com', '5552074074', 'Av. Cuitláhuac', '3400', 'Azcapotzalco', '02000', 'Azcapotzalco', 'Ciudad de México', 'AGT002'),
    ('CLI0075', 'Fisica', 'Leonardo', 'Acosta', 'Rivas', 'AORL870818OPQ', 'AORL870818HJCCSN75', '1987-08-18', 'M', 'Soltero', 'leonardo.acosta@gmail.com', '3332075075', 'Av. Hidalgo', '3500', 'Ladrón de Guevara', '44600', 'Guadalajara', 'Jalisco', 'AGT003'),
    ('CLI0076', 'Fisica', 'Marcela', 'Barrera', 'Nájera', 'BANM900928RST', 'BANM900928MJCRRR76', '1990-09-28', 'F', 'Casada', 'marcela.barrera@outlook.com', '3332076076', 'Av. Niños Héroes', '3600', 'Sector Juárez', '44100', 'Guadalajara', 'Jalisco', 'AGT003'),
    ('CLI0077', 'Fisica', 'Hugo', 'Cárdenas', 'Oropeza', 'CAOH830208UVW', 'CAOH830208HNLRRG77', '1983-02-08', 'M', 'Casado', 'hugo.cardenas@yahoo.com', '8182077077', 'Av. San Jerónimo', '3700', 'San Jerónimo', '64630', 'Monterrey', 'Nuevo León', 'AGT004'),
    ('CLI0078', 'Fisica', 'Paola', 'Domínguez', 'Salinas', 'DOSP950418XYZ', 'DOSP950418MNLMNL78', '1995-04-18', 'F', 'Soltera', 'paola.dominguez@gmail.com', '8182078078', 'Av. Gómez Morín', '3800', 'Del Valle', '66220', 'San Pedro Garza García', 'Nuevo León', 'AGT004'),
    ('CLI0079', 'Fisica', 'Rodrigo', 'Elizondo', 'Trejo', 'EITR860628ABC', 'EITR860628HDFLZD79', '1986-06-28', 'M', 'Casado', 'rodrigo.elizondo@hotmail.com', '5552079079', 'Av. Centenario', '3900', 'Álvaro Obregón', '01860', 'Álvaro Obregón', 'Ciudad de México', 'AGT005'),
    ('CLI0080', 'Fisica', 'Vanessa', 'Figueroa', 'Urbina', 'FIUV880908DEF', 'FIUV880908MDFGRV80', '1988-09-08', 'F', 'Casada', 'vanessa.figueroa@outlook.com', '5552080080', 'Av. Las Palmas', '4000', 'Reforma Social', '11650', 'Miguel Hidalgo', 'Ciudad de México', 'AGT005');
