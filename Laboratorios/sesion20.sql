--Actividad 1:

-- 1. FUNCIÓN: Calcula el promedio de ventas de un producto
CREATE OR REPLACE FUNCTION calcular_promedio_pedido(p_id_producto IN NUMBER) RETURN NUMBER AS
    v_promedio_calculado NUMBER;
BEGIN
    SELECT AVG(p.Precio * dp.Cantidad) INTO v_promedio_calculado
    FROM DetallesPedidos dp 
    INNER JOIN Productos p ON dp.ProductoID = p.ProductoID
    WHERE dp.ProductoID = p_id_producto;

    RETURN NVL(v_promedio_calculado, 0);
END;
/

-- 2. PROCEDIMIENTO PRINCIPAL: Actualiza precios usando la función anterior
CREATE OR REPLACE PROCEDURE actualizar_precios_por_categoria(p_porcentaje_aumento IN NUMBER) AS
    -- Declaramos el cursor con un nombre estándar (c_productos)
    CURSOR c_productos IS
        SELECT ProductoID, Precio
        FROM Productos;
BEGIN
    FOR reg_prod IN c_productos LOOP
        IF calcular_promedio_pedido(reg_prod.ProductoID) > 500 THEN
            UPDATE Productos
            SET Precio = reg_prod.Precio * (1 + (p_porcentaje_aumento / 100))
            WHERE ProductoID = reg_prod.ProductoID;
            DBMS_OUTPUT.PUT_LINE('Alerta de Sistema: Precio del Producto ID ' || reg_prod.ProductoID || ' ha sido actualizado.');
        END IF;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Proceso de actualización masiva finalizado.');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Fallo crítico en la actualización: ' || SQLERRM);
        ROLLBACK;
END;
/
-- 3. PRUEBA DEL CÓDIGO
EXEC actualizar_precios_por_categoria(10);

--Actividad 2:

-- 1. CREACIÓN DE LA TABLA DE AUDITORÍA 
CREATE TABLE AuditoriaPedidos (
    AuditoriaID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    PedidoID NUMBER,
    ClienteID NUMBER,
    Total NUMBER,
    FechaEliminacion DATE
);

-- 2. CREACIÓN DEL TRIGGER DE SEGURIDAD
CREATE OR REPLACE TRIGGER auditar_eliminacion_pedido
AFTER DELETE ON Pedidos
FOR EACH ROW
BEGIN
    INSERT INTO AuditoriaPedidos (PedidoID, ClienteID, Total, FechaEliminacion)
    VALUES (:OLD.PedidoID, :OLD.ClienteID, :OLD.Total, SYSDATE);
END;
/

-- 3. PRUEBA DEL CÓDIGO
DELETE FROM Pedidos WHERE PedidoID = 102;
SELECT * FROM AuditoriaPedidos;