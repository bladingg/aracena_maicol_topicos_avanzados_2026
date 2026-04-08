-- SESION 5 - PRACTICA (CURSORES EXPLICITOS)
-- Altero sesion para usar el contenedor correcto
ALTER SESSION SET CONTAINER = XEPDB1;
-- Cambio de esquema
ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;
SET SERVEROUTPUT ON;

-- Inicio del Bloque Anónimo (Ejercicio 1)
DECLARE
    -- Declaración del cursor explícito con ORDER BY
    CURSOR producto_cursor IS
        SELECT Nombre, Precio
        FROM Productos
        ORDER BY Precio DESC;
        
    -- Variables para almacenar los datos del FETCH
    v_nombre VARCHAR2(50);
    v_precio NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- LISTA DE PRODUCTOS ORDENADOS POR PRECIO ---');
    
    OPEN producto_cursor;
    LOOP
        FETCH producto_cursor INTO v_nombre, v_precio;
        EXIT WHEN producto_cursor%NOTFOUND;
        
        -- Salida por pantalla de los dos atributos
        DBMS_OUTPUT.PUT_LINE('Producto: ' || v_nombre || ' | Precio: $' || v_precio);
    END LOOP;
    CLOSE producto_cursor;
END;
/
-- Inicio del Bloque Anónimo (Ejercicio 2)
DECLARE
    -- Declaración del cursor explícito con parámetro y FOR UPDATE
    CURSOR pedido_cursor(p_cliente_id NUMBER) IS
        SELECT PedidoID, Total
        FROM Pedidos
        WHERE ClienteID = p_cliente_id
        FOR UPDATE;
        
    -- Variables
    v_pedido_id NUMBER;
    v_total_original NUMBER;
    v_total_nuevo NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- ACTUALIZACIÓN DE PEDIDOS (+10%) ---');
    
    -- Abrimos el cursor pasándole el ClienteID = 1 como parámetro
    OPEN pedido_cursor(1);
    LOOP
        FETCH pedido_cursor INTO v_pedido_id, v_total_original;
        EXIT WHEN pedido_cursor%NOTFOUND;
        
        -- Calculamos el nuevo total (aumento del 10%)
        v_total_nuevo := v_total_original * 1.1;
        
        -- Actualizamos la fila actual del cursor (sintaxis del profesor)
        UPDATE Pedidos
        SET Total = v_total_nuevo
        WHERE CURRENT OF pedido_cursor;
        
        -- Mostramos el valor original y el actualizado
        DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || v_pedido_id);
        DBMS_OUTPUT.PUT_LINE('  - Total Original: $' || v_total_original);
        DBMS_OUTPUT.PUT_LINE('  - Total Actualizado: $' || v_total_nuevo);
        
    END LOOP;
    CLOSE pedido_cursor;
    
    -- Hacemos COMMIT para guardar los cambios en la base de datos
    COMMIT;
EXCEPTION
    -- Manejo de errores basico como en la diapositiva 14
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        IF pedido_cursor%ISOPEN THEN
            CLOSE pedido_cursor;
        END IF;
END;
/
-- Se realiza commit
COMMIT;