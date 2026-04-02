--1 Sentencias SELECT SIMPLES
--Consulta de clientes ordenada cronologicamente por año (valor númerico)
SELECT Nombre, FechaNacimiento FROM Clientes ORDER BY FechaNacimiento DESC;

--Consulta para ver la ubicación de los clientes
SELECT Nombre, Ciudad FROM Clientes;

--2 FUNCIONES AGREGADAS
--Agrupación de clientes por ciudad
SELECT Ciudad, COUNT(ClienteID) AS total_por_zona
FROM Clientes
GROUP BY Ciudad;

--Cálculo total del monto de los pedidos realizados
Select SUM(Total) as monto_total FROM Pedidos;

--3 EXPRESIONES REGULARES
--Clientes que contengan la letra a, con uso de case insensitive para las mayúsculas
SELECT Nombre FROM Clientes WHERE REGEXP_LIKE(Nombre, 'a', 'i');

--Productos que inician con la letra L 
SELECT Nombre FROM Productos WHERE REGEXP_LIKE(Nombre, '^L');

--4 CREACIÓN DE VISTAS
--Vista para ver el catálogo de precios
CREATE OR REPLACE VIEW catalogo_precio AS
SELECT Nombre, Precio FROM Productos;

-- Vista simple con información de contacto de clientes
CREATE OR REPLACE VIEW info_clientes AS
SELECT Nombre, Ciudad FROM Clientes;

--5
--Se realiza commit
COMMIT;