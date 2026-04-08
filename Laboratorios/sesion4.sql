-- SESION 4 - PRACTICA (MANEJO DE EXCEPCIONES)

-- Altero sesion para usar el contenedor correcto
ALTER SESSION SET CONTAINER = XEPDB1;
-- Cambio de esquema
ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;
-- Activa la salida de DBMS_OUTPUT
SET SERVEROUTPUT ON;

-- 1) Verificar valor numerico y lanzar excepcion personalizada
DECLARE
    v_precio NUMBER;
    precio_bajo EXCEPTION;
BEGIN
    SELECT Precio INTO v_precio
    FROM Productos
    WHERE ProductoID = 2;

    IF v_precio < 30 THEN
        RAISE precio_bajo;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Precio valido: ' || v_precio);
EXCEPTION
    WHEN precio_bajo THEN
        DBMS_OUTPUT.PUT_LINE('Error: precio demasiado bajo (' || v_precio || ').');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: producto no encontrado.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

-- 2) Intentar insertar tupla con ID duplicado y manejar excepcion
DECLARE
BEGIN
    INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
    VALUES (1, 'Cliente Duplicado', 'Santiago', TO_DATE('2000-01-01', 'YYYY-MM-DD'));

    DBMS_OUTPUT.PUT_LINE('Insercion realizada correctamente.');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: ID duplicado, no se puede insertar ClienteID = 1.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/
-- Se realiza commit
COMMIT;
