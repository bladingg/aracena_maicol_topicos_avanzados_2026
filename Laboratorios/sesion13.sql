--Ejercicio 1:
-- 1 Crear tabla Inventario y poblarla con un stock inicial
CREATE TABLE Inventario (
    ProductoID NUMBER PRIMARY KEY,
    Cantidad NUMBER
);
-- Se agregan productos con un stock inicial de 50 unidades cada uno
INSERT INTO Inventario VALUES (1, 50); 
INSERT INTO Inventario VALUES (2, 50);
COMMIT;

-- 2 Procedimiento para actualizar el stock de forma segura
CREATE OR REPLACE PROCEDURE actualizar_inventario_pedido(p_pedido_id IN NUMBER) AS
    -- Cursor usando alias "dp" para mejor lectura
    CURSOR c_detalles IS
        SELECT dp.ProductoID, dp.Cantidad
        FROM DetallesPedidos dp
        WHERE dp.PedidoID = p_pedido_id;
        
    v_stock_disponible NUMBER;
BEGIN
    FOR reg_detalle IN c_detalles LOOP
        -- Verificar el stock actual del producto
        SELECT i.Cantidad INTO v_stock_disponible
        FROM Inventario i
        WHERE i.ProductoID = reg_detalle.ProductoID;
        
        -- Se crea un punto de guardado antes de intentar el descuento
        SAVEPOINT sp_antes_descuento;
        
        -- Si se detecta que el stock es insuficiente, se lanza un error y se cancela solo esta operación
        IF v_stock_disponible < reg_detalle.Cantidad THEN
            RAISE_APPLICATION_ERROR(-20001, 'Stock insuficiente para el ProductoID: ' || reg_detalle.ProductoID);
        END IF;
        
        -- Si hay stock, realiza el descuento
        UPDATE Inventario
        SET Cantidad = Cantidad - reg_detalle.Cantidad
        WHERE ProductoID = reg_detalle.ProductoID;
        
        DBMS_OUTPUT.PUT_LINE('Éxito: Se descontaron ' || reg_detalle.Cantidad || ' unidades del Producto ' || reg_detalle.ProductoID);
    END LOOP;
    
    -- Si el bucle termina sin errores, se confirma la transacción completa
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inventario actualizado completamente para el pedido ' || p_pedido_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error crítico: El producto no existe en la bodega.');
        ROLLBACK; -- Cancela TODO
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un problema: ' || SQLERRM);
        ROLLBACK TO sp_antes_descuento; 
        COMMIT; 
END;
/
EXEC actualizar_inventario_pedido(101);

--Ejercicio 2:
-- 1 Dimensión Ciudad y su carga de datos
CREATE TABLE Dim_Ciudad (
    CiudadID NUMBER PRIMARY KEY,
    NombreCiudad VARCHAR2(50) 
);

INSERT INTO Dim_Ciudad (CiudadID, NombreCiudad)
SELECT ROWNUM, Ciudad
FROM (SELECT DISTINCT Ciudad FROM Clientes);

-- 2 Tabla de Hechos
CREATE TABLE Fact_Pedidos (
    PedidoID NUMBER,
    ClienteID NUMBER,
    CiudadID NUMBER,
    FechaID NUMBER,
    MontoTotal NUMBER, 
    CONSTRAINT fk_fact_cliente FOREIGN KEY (ClienteID) REFERENCES Dim_Cliente(ClienteID),
    CONSTRAINT fk_fact_ciudad FOREIGN KEY (CiudadID) REFERENCES Dim_Ciudad(CiudadID),
    CONSTRAINT fk_fact_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);

-- 3 Carga de Datos
INSERT INTO Fact_Pedidos (PedidoID, ClienteID, CiudadID, FechaID, MontoTotal)
SELECT p.PedidoID, 
       p.ClienteID, 
       dc.CiudadID, 
       dt.FechaID, 
       p.Total
FROM Pedidos p
INNER JOIN Clientes c ON p.ClienteID = c.ClienteID
INNER JOIN Dim_Ciudad dc ON c.Ciudad = dc.NombreCiudad
INNER JOIN Dim_Tiempo dt ON p.FechaPedido = dt.Fecha;

-- 4 Consulta Analítica: Total de ventas por ciudad y año
SELECT dc.NombreCiudad AS Ciudad, 
       dt.Año, 
       SUM(fp.MontoTotal) AS Total_Ventas
FROM Fact_Pedidos fp
INNER JOIN Dim_Ciudad dc ON fp.CiudadID = dc.CiudadID
INNER JOIN Dim_Tiempo dt ON fp.FechaID = dt.FechaID
GROUP BY dc.NombreCiudad, dt.Año
ORDER BY Total_Ventas DESC; 