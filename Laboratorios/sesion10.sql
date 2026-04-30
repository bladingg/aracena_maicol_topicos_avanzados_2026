--Ejercicio 1:
CREATE OR REPLACE PROCEDURE actualizar_total_pedidos(p_cliente_id IN NUMBER, p_porcentaje IN NUMBER DEFAULT 10) AS
    --Se declara nuevas variables para almacenar el nuevo total calculado
    v_total NUMBER; 
    v_nuevo_total NUMBER;

    CURSOR c_pedidos IS
        SELECT PedidoID, Total
        FROM Pedidos
        WHERE ClienteID = p_cliente_id
        FOR UPDATE;
BEGIN
    FOR reg_pedido IN c_pedidos LOOP
        --CAMBIO: Se realiza el calculo del nuevo total antes del UPDATE
        v_total := reg_pedido.Total;
        v_nuevo_total := v_total + (v_total * p_porcentaje / 100); 
        
        UPDATE Pedidos
        SET Total = v_nuevo_total
        WHERE CURRENT OF c_pedidos;
        
        DBMS_OUTPUT.PUT_LINE('Al pedido ' || reg_pedido.PedidoID || ' se le asigno el nuevo total de: ' || v_nuevo_total);
    END LOOP;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se encontraron pedidos para el cliente ' || p_cliente_id);
    ELSE
        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrio un error: ' || SQLERRM);
        ROLLBACK;
END;
/

--Ejercicio 2:
CREATE OR REPLACE PROCEDURE calcular_costo_detalle(p_detalle_id IN NUMBER, p_costo IN OUT NUMBER) AS
BEGIN
    --CAMBIO: Se realiza el calculo del costo total en el SELECT y se asigna directamente a la variable de salida p_costo
    SELECT (p.Precio * d.Cantidad) INTO p_costo
    FROM DetallesPedidos d
    JOIN Productos p ON d.ProductoID = p.ProductoID
    WHERE d.DetalleID = p_detalle_id;
    
    DBMS_OUTPUT.PUT_LINE('El costo total del detalle ' || p_detalle_id || ' es: ' || p_costo);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error: No existe el detalle de pedido con ID ' || p_detalle_id);
END;
/