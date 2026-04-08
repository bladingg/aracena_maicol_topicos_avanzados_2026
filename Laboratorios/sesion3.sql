-- SESION 3
-- Ejercicio: calcular el gasto total de un cliente y clasificarlo.
--
-- Criterios usados:
-- ALTO  : total >= 800
-- MEDIO : total >= 300 y < 800
-- BAJO  : total < 300

-- Altero sesion para usar el contenedor correcto
ALTER SESSION SET CONTAINER = XEPDB1;

-- Cambio de esquema
ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;

-- Activa la salida de DBMS_OUTPUT
SET SERVEROUTPUT ON;

-- Variables del bloque
DECLARE
    -- Cliente a evaluar
    v_cliente_id NUMBER := 1;
    -- Suma total de pedidos del cliente
    v_total_gasto NUMBER;
    -- Resultado final: ALTO, MEDIO o BAJO
    v_clasificacion VARCHAR2(20);
BEGIN
    -- Obtiene el total gastado por el cliente
    SELECT SUM(Total) INTO v_total_gasto
    FROM Pedidos
    WHERE ClienteID = v_cliente_id;
    
    -- Clasificacion por rangos
    IF v_total_gasto >= 800 THEN
        v_clasificacion := 'ALTO';
    ELSIF v_total_gasto >= 300 THEN
        v_clasificacion := 'MEDIO';
    ELSE
        v_clasificacion := 'BAJO';
    END IF;
    
    -- Muestra resultado
    DBMS_OUTPUT.PUT_LINE('Total gasto del cliente ' || v_cliente_id || ': ' || v_total_gasto);
    DBMS_OUTPUT.PUT_LINE('Clasificación: ' || v_clasificacion);
    EXCEPTION
        -- Mensaje en caso de no encontrar datos
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No se encontraron pedidos para el cliente ' || v_cliente_id);
END;
/

--Se realiza commit
COMMIT;