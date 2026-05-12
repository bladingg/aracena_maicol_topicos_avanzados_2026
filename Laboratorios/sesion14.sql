
--Ejercicio 1:
-- 1. CREACIÓN DEL SUPERTIPO (El padre)
CREATE OR REPLACE TYPE Vehiculo AS OBJECT (
    Marca VARCHAR2(50),
    Año NUMBER,
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
) NOT FINAL; 
/

CREATE OR REPLACE TYPE BODY Vehiculo AS
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
        v_edad NUMBER;
    BEGIN
        v_edad := 2025 - Año; 
        RETURN v_edad;
    END;
END;
/

-- 2. CREACIÓN DEL SUBTIPO AUTOMOVIL (El hijo)
CREATE OR REPLACE TYPE Automovil UNDER Vehiculo (
    NumeroPuertas NUMBER,
    MEMBER FUNCTION descripcion RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY Automovil AS
    MEMBER FUNCTION descripcion RETURN VARCHAR2 IS
        v_texto_detalle VARCHAR2(150); --Se crea una variable para el detalle del automóvil
    BEGIN
        v_texto_detalle := 'Tipo: Automóvil | Marca: ' || Marca || ' | Año: ' || Año || ' | Puertas: ' || NumeroPuertas;
        RETURN v_texto_detalle;
    END;
END;
/

--Ejercicio 2:
-- 3. CREACIÓN DEL SUBTIPO CAMION (Otro hijo)
CREATE OR REPLACE TYPE Camion UNDER Vehiculo (
    CapacidadCarga NUMBER,
    OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY Camion AS
    OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
        v_edad_alterada NUMBER;
    BEGIN
        -- Se calcula la edad normal y se le suma 2 años adicionales para reflejar un desgaste mayor
        v_edad_alterada := (2025 - Año) + 2; 
        RETURN v_edad_alterada;
    END;
END;
/