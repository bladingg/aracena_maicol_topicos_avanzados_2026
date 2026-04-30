-- Ejercicio 1:
--La Función
CREATE OR REPLACE FUNCTION calcular_total_con_descuento(p_pedido_id IN NUMBER) RETURN NUMBER AS
    v_monto_actual NUMBER;
BEGIN
    SELECT Total INTO v_monto_actual
    FROM Pedidos
    WHERE PedidoID = p_pedido_id;
    --SE AGREGA IF ELSE PARA CONTROLAR EL DESCUENTO SOLO SI EL MONTO ACTUAL SUPERA LOS 1000
    IF v_monto_actual > 1000 THEN
        RETURN v_monto_actual - (v_monto_actual * 0.10); 
    ELSE
        dbms_output.put_line('El pedido ' || p_pedido_id || ' no supera los 1000, no se aplica el descuento.');
        RETURN v_monto_actual; 

    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No existe el pedido ' || p_pedido_id);
        RETURN 0; -- Retorna 0 si no se encuentra el pedido
END;
/
--PROCEDIMIENTO QUE USA LA FUNCIÓN
CREATE OR REPLACE PROCEDURE aplicar_descuento_pedido(p_pedido_id IN NUMBER) AS
    v_total_calculado NUMBER;
BEGIN
    v_total_calculado := calcular_total_con_descuento(p_pedido_id);
    --Agregue este if para evitar actualizar el pedido si no se encontro o si el total calculado es 0
    IF v_total_calculado > 0 THEN
        UPDATE Pedidos
        SET Total = v_total_calculado
        WHERE PedidoID = p_pedido_id;
        
        DBMS_OUTPUT.PUT_LINE('El pedido ' || p_pedido_id || ' quedo con un total de ' || v_total_calculado);
        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrio un error: ' || SQLERRM);
        ROLLBACK;
END;
/

--Ejercicio 2:
CREATE OR REPLACE TRIGGER validar_cantidad_detalle
BEFORE INSERT OR UPDATE ON DetallesPedidos
FOR EACH ROW
BEGIN
    IF :NEW.Cantidad < 1 OR :NEW.Cantidad IS NULL THEN
        RAISE_APPLICATION_ERROR(-20005, 'Error! La cantidad de un producto debe ser al menos 1.');
    END IF;
END;
/