--Ejercicio 1:

-- 1 Crear el índice compuesto
CREATE INDEX idx_detped_compuesto ON DetallesPedidos(PedidoID, ProductoID);

-- 2 Preparar el analisis del plan de ejecución usando alias d
EXPLAIN PLAN FOR
SELECT d.* 
FROM DetallesPedidos d
WHERE d.PedidoID = 108 AND d.ProductoID = 1;

-- 3 Visualizar el reporte del plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 4 Ejecutar la consulta real para ver el resultado
SELECT d.* 
FROM DetallesPedidos d
WHERE d.PedidoID = 108 AND d.ProductoID = 1;

--Ejercicio 2:

--Creacion de tabla particionada por hash
-- 1 Crear la tabla Ventas particionada por Hash
CREATE TABLE Ventas (
    VentaID NUMBER PRIMARY KEY,
    ClienteID NUMBER,
    Total NUMBER,
    FechaVenta DATE
)
PARTITION BY HASH (ClienteID)
PARTITIONS 4;

-- 2 Insertar los datos directamente desde la tabla Pedidos usando alias
INSERT INTO Ventas (VentaID, ClienteID, Total, FechaVenta)
SELECT p.PedidoID, p.ClienteID, p.Total, p.FechaPedido
FROM Pedidos p;

-- 3 Preparar el analisis del plan de ejecucion para la consulta agrupada usando alias v
EXPLAIN PLAN FOR
SELECT v.ClienteID, SUM(v.Total) AS TotalVentas
FROM Ventas v
GROUP BY v.ClienteID
ORDER BY v.ClienteID; -- Agregamos ORDER BY para mejor presentación

-- 4 Visualización
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 5 Ejecutar la consulta agrupada real
SELECT v.ClienteID, SUM(v.Total) AS TotalVentas
FROM Ventas v
GROUP BY v.ClienteID
ORDER BY v.ClienteID;