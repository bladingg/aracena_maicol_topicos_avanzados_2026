--Actividad 1:

--Creación de Roles 
CREATE ROLE rol_analista_datos;
CREATE ROLE rol_gerente_tienda;

--Asignación de Permisos (Principio de Privilegio Mínimo) el analista solo puede leer datos y registrar nuevos detalles, nada más.
GRANT SELECT ON Clientes TO rol_analista_datos;
GRANT SELECT ON Productos TO rol_analista_datos;
GRANT SELECT, INSERT ON DetallesPedidos TO rol_analista_datos;

--El gerente tiene control total sobre las tablas principales de negocio.
GRANT ALL PRIVILEGES ON Clientes, Pedidos, Productos, DetallesPedidos TO rol_gerente_tienda;

--Creación de Usuarios y Asignación de Roles
CREATE USER analista_jr IDENTIFIED BY analista2026;
GRANT rol_analista_datos TO analista_jr;

CREATE USER gerente_gral IDENTIFIED BY gerente2026;
GRANT rol_gerente_tienda TO gerente_gral;

DBMS_OUTPUT.PUT_LINE('Roles y usuarios configurados exitosamente.');

--Actividad 2:

--Análisis de la consulta original (Cruce entre Clientes y Pedidos)
EXPLAIN PLAN FOR
SELECT c.Nombre, 
       SUM(p.Total) AS Monto_Total_Comprado
FROM Clientes c
INNER JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Nombre
ORDER BY Monto_Total_Comprado DESC;

--Mostrar el plan de ejecución
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Creación de Índice en la llave foránea para acelerar el JOIN
CREATE INDEX idx_ped_cli_optimizacion ON Pedidos(ClienteID);

--Reevaluación de la consulta optimizada
EXPLAIN PLAN FOR
SELECT c.Nombre, 
       SUM(p.Total) AS Monto_Total_Comprado
FROM Clientes c
INNER JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Nombre
ORDER BY Monto_Total_Comprado DESC;

--Mostrar el nuevo plan de ejecución
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);