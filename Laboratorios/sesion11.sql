--Ejercicio 1:
CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_cliente_id IN NUMBER) RETURN NUMBER AS
    v_nacimiento DATE;
    v_edad_calculada NUMBER;
BEGIN
    SELECT FechaNacimiento INTO v_nacimiento
    FROM Clientes
    WHERE ClienteID = p_cliente_id;
    
    v_edad_calculada := FLOOR(MONTHS_BETWEEN(SYSDATE, v_nacimiento) / 12);
    
    RETURN v_edad_calculada;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'ERROR! No existe un cliente registrado con el ID ' || p_cliente_id);
END;
/

--Forma de probar la función:
DECLARE
    v_edad_del_cliente NUMBER;
BEGIN
    v_edad_del_cliente := calcular_edad_cliente(1);
    DBMS_OUTPUT.PUT_LINE('El cliente tiene ' || v_edad_del_cliente || ' años.');
END;
/

--Ejercicio 2:
CREATE OR REPLACE FUNCTION obtener_precio_promedio RETURN NUMBER AS
    v_precio_promedio NUMBER;
BEGIN
    SELECT AVG(Precio) INTO v_precio_promedio
    FROM Productos;
    
    RETURN v_precio_promedio;
END;
/

--CONSULTA SQL para listar los productos con precio superior al promedio calculado por la función:
SELECT Nombre, Precio FROM Productos
WHERE Precio > obtener_precio_promedio();
