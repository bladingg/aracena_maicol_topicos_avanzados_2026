--Actividad 1:      

--Estrategia de Diseño (Desnormalización):
--Colección Principal: 'clientes'.
--Embebido (Embedding): 
--Se decide embeber el arreglo de "Pedidos" dentro
--del documento de cada cliente. A su vez, los "Detalles" y los datos 
--del "Producto" se embeben dentro de cada pedido.
--Justificación: 
--En NoSQL evitamos los JOINs para maximizar la velocidad. 
--Como generalmente consultamos un cliente junto con todo su historial 
--de compras, tener todo anidado en un solo documento JSON acelera 
--enormemente la lectura.

--Ejemplo de documento basado en los datos exactos del esquema inicial:
{
  "ClienteID": 1,
  "Nombre": "Juan Perez",
  "Ciudad": "Santiago",
  "FechaNacimiento": new Date("1990-05-15"),
  "Pedidos": [
    {
      "PedidoID": 101,
      "Total": 600,
      "FechaPedido": new Date("2025-03-01"),
      "Detalles": [
        { "ProductoID": 1, "Nombre": "Laptop", "Precio": 1200, "Cantidad": 2 },
        { "ProductoID": 2, "Nombre": "Mouse", "Precio": 25, "Cantidad": 5 }
      ]
    },
    {
      "PedidoID": 102,
      "Total": 300,
      "FechaPedido": new Date("2025-03-02"),
      "Detalles": []
    }
  ]
}

--Actividad 2:

-- CONSULTA A: Obtener los clientes de una ciudad específica (6).
db.clientes.find(
  { "Ciudad": "Valparaiso" },
  { "Nombre": 1, "Ciudad": 1, "_id": 0 }
);

--CONSULTA B: Calcular el número total de productos vendidos por producto (6).
db.clientes.aggregate([
  { $unwind: "$Pedidos" },
  { $unwind: "$Pedidos.Detalles" },
  {
    $group: {
      _id: "$Pedidos.Detalles.Nombre",
      TotalVendidos: { $sum: "$Pedidos.Detalles.Cantidad" }
    }
  },
  { $sort: { TotalVendidos: -1 } } 
]);