--Ejercicio 1:
-- PASO 1: Creación del usuario y permiso de conexión
CREATE USER user_analista IDENTIFIED BY analista123;
GRANT CONNECT TO user_analista;

-- PASO 2: Creación del rol (agrupador de permisos)
CREATE ROLE rol_analista;

-- PASO 3: Asignar permisos específicos de lectura al rol
GRANT SELECT ON Clientes TO rol_analista;
GRANT SELECT ON Pedidos TO rol_analista;
GRANT SELECT ON Productos TO rol_analista;
GRANT SELECT ON DetallesPedidos TO rol_analista;

-- Asignar permiso específico de escritura al rol
GRANT INSERT ON Pedidos TO rol_analista;

-- PASO 4: Entregar el rol configurado al usuario analista
GRANT rol_analista TO user_analista;

-- PRUEBAS DE SEGURIDAD
CONNECT user_analista/analista123;

-- Prueba A: Lectura exitosa (Tiene permiso)
SELECT * FROM Clientes; 

-- Prueba B: Inserción exitosa en Pedidos con un dato personalizado
INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
VALUES (999, 3, 2500, TO_DATE('2025-05-15', 'YYYY-MM-DD')); 

-- Prueba C: Operación rechazada por falta de permiso
UPDATE Clientes SET Nombre = 'Intento Hacker' WHERE ClienteID = 1;

--Ejercicio 2:
-- PASO 1: Habilitar la auditoría para el usuario analista
CONNECT sys AS sysdba;

-- Ordenar a Oracle que registre estas acciones específicas
AUDIT SELECT ON Clientes BY user_analista;
AUDIT INSERT ON Pedidos BY user_analista;

-- PASO 2: Generar actividad 
CONNECT user_analista/analista123;

-- Se realizan algunas consultas y una inserción para generar registros de auditoría
SELECT * FROM Clientes WHERE Ciudad = 'Santiago';

INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
VALUES (888, 2, 450, SYSDATE);

-- PASO 3: Revisar el reporte del "espía" (Volvemos a ser Administrador)
CONNECT sys AS sysdba;

-- Consultar el registro de auditoría para ver las acciones del usuario analista
SELECT username, action_name, timestamp
FROM dba_audit_trail
WHERE username = 'USER_ANALISTA'
ORDER BY timestamp DESC; 