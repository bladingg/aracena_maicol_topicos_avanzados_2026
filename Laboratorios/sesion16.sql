--Ejercicio 1:
-- 1 Creamos índices estratégicos (con nombres cortos y claros)
-- Indice para buscar clientes por ciudad
CREATE INDEX idx_cli_ciudad ON Clientes(Ciudad);
-- Indice para Pedidos y su relación con Clientes
CREATE INDEX idx_ped_cliente ON Pedidos(ClienteID);

-- 2 Se genera el plan de ejecución con el Hint para usar los índices
EXPLAIN PLAN FOR
SELECT /*+ INDEX(c idx_cli_ciudad) INDEX(p idx_ped_cliente) */
       c.Nombre, 
       COUNT(p.PedidoID) AS Total_Pedidos
FROM Clientes c
INNER JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE c.Ciudad = 'Santiago'
  AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre
ORDER BY Total_Pedidos DESC; 

-- 3 Vizualizar el plan de ejecución para confirmar el uso de índices
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 4 Ejecutar la consulta real con los índices aplicados
SELECT /*+ INDEX(c idx_cli_ciudad) INDEX(p idx_ped_cliente) */
       c.Nombre, 
       COUNT(p.PedidoID) AS Total_Pedidos
FROM Clientes c
INNER JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE c.Ciudad = 'Santiago'
  AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre
ORDER BY Total_Pedidos DESC;

--Ejercicio 2:
-- 1 asegurar que la tabla DetallesPedidos tenga un índice en ProductoID para optimizar el JOIN
CREATE INDEX idx_det_producto ON DetallesPedidos(ProductoID);

-- 2 Generar el plan de ejecución para la consulta que calcula los ingresos totales por producto, usando el índice creado
EXPLAIN PLAN FOR
SELECT /*+ INDEX(dp idx_det_producto) */
       p.Nombre AS Producto, 
       SUM(dp.Cantidad * p.Precio) AS Ingresos_Totales
FROM Productos p
INNER JOIN DetallesPedidos dp ON p.ProductoID = dp.ProductoID
GROUP BY p.Nombre
ORDER BY Ingresos_Totales DESC;

-- 3 Ver el reporte 
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 4 Ejcutar la consulta real con el índice aplicado
SELECT /*+ INDEX(dp idx_det_producto) */
       p.Nombre AS Producto, 
       SUM(dp.Cantidad * p.Precio) AS Ingresos_Totales
FROM Productos p
INNER JOIN DetallesPedidos dp ON p.ProductoID = dp.ProductoID
GROUP BY p.Nombre
ORDER BY Ingresos_Totales DESC;