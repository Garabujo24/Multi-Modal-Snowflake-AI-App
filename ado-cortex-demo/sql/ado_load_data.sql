-- Script para poblar las tablas de la demo ADO con datos ficticios

-- Rutas
INSERT INTO Rutas (ID, Origen, Destino, Distancia_KM, Duracion_Estimada_Horas) VALUES
(1, 'Ciudad de México', 'Puebla', 130, 2.5),
(2, 'Ciudad de México', 'Veracruz', 400, 6.5),
(3, 'Puebla', 'Veracruz', 270, 4.0),
(4, 'Ciudad de México', 'Oaxaca', 460, 7.0),
(5, 'Oaxaca', 'Tuxtla Gutiérrez', 540, 8.5),
(6, 'Ciudad de México', 'Tuxtla Gutiérrez', 970, 15.0),
(7, 'Veracruz', 'Tuxtla Gutiérrez', 670, 10.5),
(8, 'Puebla', 'Oaxaca', 340, 5.5),
(9, 'Veracruz', 'Oaxaca', 420, 7.0),
(10, 'Ciudad de México', 'Acapulco', 380, 5.5),
(11, 'Acapulco', 'Oaxaca', 500, 8.0),
(12, 'Puebla', 'Acapulco', 350, 6.0),
(13, 'Tuxtla Gutiérrez', 'Veracruz', 670, 10.5),
(14, 'Oaxaca', 'Veracruz', 420, 7.0),
(15, 'Acapulco', 'Ciudad de México', 380, 5.5),
(16, 'Tuxtla Gutiérrez', 'Oaxaca', 540, 8.5),
(17, 'Veracruz', 'Puebla', 270, 4.0),
(18, 'Oaxaca', 'Puebla', 340, 5.5),
(19, 'Acapulco', 'Veracruz', 500, 8.0),
(20, 'Tuxtla Gutiérrez', 'Acapulco', 900, 14.0);

-- Autobuses
INSERT INTO Autobuses (ID, Numero_Economico, Capacidad_Asientos, Tipo_Servicio) VALUES
(1, 'ADO123', 44, 'Primera'),
(2, 'ADO456', 36, 'GL'),
(3, 'ADO789', 30, 'Platino'),
(4, 'ADO321', 44, 'Primera'),
(5, 'ADO654', 36, 'GL'),
(6, 'ADO987', 30, 'Platino'),
(7, 'ADO111', 44, 'Primera'),
(8, 'ADO222', 36, 'GL'),
(9, 'ADO333', 30, 'Platino'),
(10, 'ADO444', 44, 'Primera');

-- Terminales
INSERT INTO Terminales (ID, Nombre, Ciudad, Estado) VALUES
(1, 'TAPO', 'Ciudad de México', 'Ciudad de México'),
(2, '4 Poniente', 'Puebla', 'Puebla'),
(3, 'Central de Autobuses', 'Veracruz', 'Veracruz'),
(4, 'ADO Oaxaca', 'Oaxaca', 'Oaxaca'),
(5, 'ADO Tuxtla', 'Tuxtla Gutiérrez', 'Chiapas'),
(6, 'Terminal Acapulco', 'Acapulco', 'Guerrero');

-- Corridas
INSERT INTO Corridas (ID, Ruta_ID, Autobus_ID, Fecha_Hora_Salida, Fecha_Hora_Llegada, Precio_Boleto) VALUES
(1,1,1,'2024-07-01 08:00','2024-07-01 10:30',350.00),
(2,2,2,'2024-07-01 09:00','2024-07-01 15:30',700.00),
(3,3,1,'2024-07-01 12:00','2024-07-01 16:00',500.00),
(4,4,3,'2024-07-01 07:00','2024-07-01 14:00',800.00),
(5,5,4,'2024-07-01 10:00','2024-07-01 18:30',900.00),
(6,6,5,'2024-07-01 06:00','2024-07-01 21:00',1500.00),
(7,7,6,'2024-07-01 13:00','2024-07-01 23:30',1200.00),
(8,8,7,'2024-07-01 15:00','2024-07-01 20:30',600.00),
(9,9,8,'2024-07-01 11:00','2024-07-01 18:00',750.00),
(10,10,9,'2024-07-01 16:00','2024-07-01 21:30',650.00),
(11,11,10,'2024-07-01 18:00','2024-07-02 02:00',950.00),
(12,12,1,'2024-07-01 20:00','2024-07-02 02:00',700.00),
(13,13,2,'2024-07-01 22:00','2024-07-02 08:30',1300.00),
(14,14,3,'2024-07-01 23:00','2024-07-02 06:00',850.00),
(15,15,4,'2024-07-02 06:00','2024-07-02 11:30',650.00),
(16,16,5,'2024-07-02 08:00','2024-07-02 16:30',900.00),
(17,17,6,'2024-07-02 10:00','2024-07-02 14:00',500.00),
(18,18,7,'2024-07-02 12:00','2024-07-02 17:30',600.00),
(19,19,8,'2024-07-02 14:00','2024-07-02 22:00',950.00),
(20,20,9,'2024-07-02 16:00','2024-07-03 06:00',1400.00);

-- Boletos
INSERT INTO Boletos (ID, Corrida_ID, Pasajero_Nombre, Asiento, Fecha_Compra, Estatus) VALUES
(1,1,'Juan Pérez',12,'2024-06-25 14:00','Vendido'),
(2,1,'Ana Gómez',15,'2024-06-25 15:00','Vendido'),
(3,2,'Luis Martínez',5,'2024-06-26 10:00','Cancelado'),
(4,2,'María López',8,'2024-06-26 11:00','Vendido'),
(5,3,'Pedro Sánchez',20,'2024-06-27 09:00','Vendido'),
(6,3,'Lucía Torres',22,'2024-06-27 10:00','Vendido'),
(7,4,'José Ramírez',3,'2024-06-28 12:00','Vendido'),
(8,4,'Elena Ruiz',7,'2024-06-28 13:00','Vendido'),
(9,5,'Andrés Castro',18,'2024-06-29 14:00','Vendido'),
(10,5,'Paola Díaz',21,'2024-06-29 15:00','Vendido'),
(11,6,'Roberto Silva',2,'2024-06-30 16:00','Vendido'),
(12,6,'Carla Méndez',6,'2024-06-30 17:00','Vendido'),
(13,7,'Alberto Reyes',11,'2024-07-01 08:00','Vendido'),
(14,7,'Daniela Flores',14,'2024-07-01 09:00','Vendido'),
(15,8,'Raúl Ortega',19,'2024-07-01 10:00','Vendido'),
(16,8,'Patricia Vega',23,'2024-07-01 11:00','Vendido'),
(17,9,'Ernesto Ramos',4,'2024-07-01 12:00','Vendido'),
(18,9,'Silvia Morales',9,'2024-07-01 13:00','Vendido'),
(19,10,'Manuel Herrera',16,'2024-07-01 14:00','Vendido'),
(20,10,'Laura Jiménez',25,'2024-07-01 15:00','Vendido');

