--Actividad 1: 

CREATE OR REPLACE PACKAGE gestion_clientes AS
    g_total_registros NUMBER := 0;

    PROCEDURE registrar_cliente(
        p_id_cli IN NUMBER,
        p_nom_cli IN VARCHAR2,
        p_ciudad_cli IN VARCHAR2,
        p_fecha_nac IN DATE
    );

    -- Función para obtener la edad exacta
    FUNCTION obtener_edad(
        p_id_cli IN NUMBER
    ) RETURN NUMBER;
END gestion_clientes;
/
CREATE OR REPLACE PACKAGE BODY gestion_clientes AS

    PROCEDURE registrar_cliente(
        p_id_cli IN NUMBER,
        p_nom_cli IN VARCHAR2,
        p_ciudad_cli IN VARCHAR2,
        p_fecha_nac IN DATE
    ) IS
    BEGIN
        IF p_fecha_nac >= SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error: La fecha de nacimiento no puede ser mayor o igual a hoy.');
        END IF;

        INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
        VALUES (p_id_cli, p_nom_cli, p_ciudad_cli, p_fecha_nac);

   
        g_total_registros := g_total_registros + 1;
        DBMS_OUTPUT.PUT_LINE('Cliente ' || p_nom_cli || ' registrado. Total actual: ' || g_total_registros);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Fallo al registrar: ' || SQLERRM);
            RAISE;
    END registrar_cliente;

    FUNCTION obtener_edad(
        p_id_cli IN NUMBER
    ) RETURN NUMBER IS
        v_nacimiento DATE;
        v_edad NUMBER;
    BEGIN
        -- Buscamos al cliente usando el alias "c" 
        SELECT c.FechaNacimiento INTO v_nacimiento
        FROM Clientes c
        WHERE c.ClienteID = p_id_cli;

        -- Cálculo de la edad
        v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_nacimiento) / 12);
        RETURN v_edad;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'El ClienteID ' || p_id_cli || ' no existe.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Fallo al calcular edad: ' || SQLERRM);
            RAISE;
    END obtener_edad;

END gestion_clientes;
/
--Probando el procedimiento y la funcion:
EXEC gestion_clientes.registrar_cliente(4, 'Pedro Pascal', 'Santiago', TO_DATE('1975-04-02', 'YYYY-MM-DD'));

--Actividad 2:
CREATE OR REPLACE PACKAGE gestion_clientes AS
    --Excepción personalizada
    e_menor_edad EXCEPTION; 
    
    g_total_registros NUMBER := 0;

    PROCEDURE registrar_cliente(
        p_id_cli IN NUMBER,
        p_nom_cli IN VARCHAR2,
        p_ciudad_cli IN VARCHAR2,
        p_fecha_nac IN DATE
    );

    FUNCTION obtener_edad(
        p_id_cli IN NUMBER
    ) RETURN NUMBER;
END gestion_clientes;
/
CREATE OR REPLACE PACKAGE BODY gestion_clientes AS

    PROCEDURE registrar_cliente(
        p_id_cli IN NUMBER,
        p_nom_cli IN VARCHAR2,
        p_ciudad_cli IN VARCHAR2,
        p_fecha_nac IN DATE
    ) IS
        --Variable para chequear la edad antes de guardar
        v_edad_check NUMBER;
    BEGIN
        IF p_fecha_nac >= SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error: La fecha de nacimiento no puede ser mayor o igual a hoy.');
        END IF;

        --Comprobación de la edad para la excepción personalizada
        v_edad_check := FLOOR(MONTHS_BETWEEN(SYSDATE, p_fecha_nac) / 12);
        IF v_edad_check < 18 THEN
            RAISE e_menor_edad;
        END IF;

        INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
        VALUES (p_id_cli, p_nom_cli, p_ciudad_cli, p_fecha_nac);

        g_total_registros := g_total_registros + 1;
        DBMS_OUTPUT.PUT_LINE('Cliente ' || p_nom_cli || ' registrado. Total actual: ' || g_total_registros);
        
    EXCEPTION
        WHEN e_menor_edad THEN
            DBMS_OUTPUT.PUT_LINE('Rechazado: El cliente ' || p_nom_cli || ' es menor de 18 años.');
            RAISE;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Fallo al registrar: ' || SQLERRM);
            RAISE;
    END registrar_cliente;


    FUNCTION obtener_edad(
        p_id_cli IN NUMBER
    ) RETURN NUMBER IS
        v_nacimiento DATE;
        v_edad NUMBER;
    BEGIN
        SELECT c.FechaNacimiento INTO v_nacimiento
        FROM Clientes c
        WHERE c.ClienteID = p_id_cli;

        v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_nacimiento) / 12);
        RETURN v_edad;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'El ClienteID ' || p_id_cli || ' no existe.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Fallo al calcular edad: ' || SQLERRM);
            RAISE;
    END obtener_edad;

END gestion_clientes;
/
--Probando el procedimiento con la nueva excepción personalizada:
EXEC gestion_clientes.registrar_cliente(5, 'Seba Joven', 'Valparaiso', TO_DATE('2012-06-15', 'YYYY-MM-DD'));
