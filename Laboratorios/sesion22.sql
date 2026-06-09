--Actividad 1:

--Arquitectura y Ubicación:
--Nodo Principal (Primary): Centro de Datos en Santiago.
--Nodo Secundario (Standby): Centro de Datos en Viña del Mar.
--Método de Replicación:
--Replicación Asíncrona utilizando Oracle Data Guard.
--Justificación: Evita el retraso (latencia) en las transacciones del 
--nodo principal en Santiago, asegurando un rendimiento fluido para los clientes.
--Uso del Nodo Secundario y Balanceo de Carga:
--Se utilizará Active Data Guard para mantener el nodo en modo "Solo Lectura".
--Recibirá todas las consultas pesadas y generación de reportes gerenciales.
--Mecanismo de Failover (Tolerancia a fallos):
--Se implementará Fast-Start Failover. Si el servidor en Santiago falla, 
--Viña del Mar asume el rol principal automáticamente con un MTTR < 5 minutos.

--Actividad 2:

SELECT c.ClienteID, 
       c.Nombre, 
       COUNT(p.PedidoID) AS Cantidad_De_Compras,
       SUM(p.Total) AS Dinero_Total_Gastado
FROM Clientes c
INNER JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE p.FechaPedido >= TO_DATE('2025-01-01', 'YYYY-MM-DD')
GROUP BY c.ClienteID, c.Nombre
ORDER BY Dinero_Total_Gastado DESC;

--Balanceo de Carga: 
--Al ejecutar este reporte pesado (con SUM, COUNT y GROUP BY) 
--en el nodo Standby, liberamos la CPU y la memoria del Nodo Principal, 
--dejándolo 100% disponible para procesar nuevos INSERTs y UPDATEs.
--Datos Frescos: 
--Al usar Active Data Guard, el nodo Standby se sincroniza 
--mientras permite consultas, por lo que el reporte mostrará ventas casi en tiempo real.