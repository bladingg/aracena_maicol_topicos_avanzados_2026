--Prueba 2
--Maicol Aracena
--PRIMERA PARTE: TEORIA

--1.Explica la diferencia entre un procedimiento almacenado y una función almacenada en PL/SQL. 
--Da un ejemplo de cuándo usarías cada uno en el contexto de la base de datos de la prueba.

--la diferencia principal entre un procedimiento almacenado y una función almacenada en PL/SQL es que un procedimiento no devuelve un valor directamente, mientras que una función si lo hace. 
--Un procedimiento se utiliza para realizar una accion o un conjunto de acciones, como insertar o actualizar datos, sin necesidad de devolver un resultado. Por otro lado, una función se utiliza cuando necesitas realizar un cálculo o 
--transformación y devolver un valor específico.

--Por ejemplo:
Create or replace procedure ajustar_horas_asignacion (
    p_AsignacionID IN NUMBER,
    p_HorasAjuste IN NUMBER,
    p_HorasTotales IN OUT NUMBER
) IS
BEGIN
    SELECT Horas INTO p_HorasTotales FROM Asignaciones WHERE AsignacionID = p_AsignacionID;
    p_HorasTotales := p_HorasTotales + p_HorasAjuste
    UPDATE Asignaciones SET Horas = p_HorasTotales WHERE AsignacionID = p_AsignacionID;
END;
/
--2-Describe cómo usarías un parámetro IN OUT en un procedimiento almacenado. 
--Escribe un ejemplo de un procedimiento que use un parámetro IN OUT para actualizar y devolver las horas de una asignación después de un ajuste.

--Un parámetro IN OUT en un procedimiento almacenado permite que el valor del parámetro sea tanto de entrada como de salida. Esto significa que se puede pasar un valor al
--procedimiento, modificarlo dentro del procedimiento y luego devolver el valor modificado.
Create or replace procedure ajustar_horas_asignacion (
    p_AsignacionID IN NUMBER,
    p_HorasAjuste IN NUMBER,
    p_HorasTotales IN OUT NUMBER
) IS
BEGIN
    SELECT Horas INTO p_HorasTotales FROM Asignaciones WHERE AsignacionID = p_AsignacionID;
    p_HorasTotales := p_HorasTotales + p_HorasAjuste
    UPDATE Asignaciones SET Horas = p_HorasTotales WHERE AsignacionID
END;
/
 
--3-¿Cómo se puede usar una función almacenada dentro de una consulta SQL? Escribe un ejemplo de una función que calcule el total de horas asignadas a un incidente y usala en 
--una consulta para listar los incidentes con su total de horas

--Una función almacenada puede ser llamada dentro de una consulta SQL para realizar cálculos o transformaciones y devolver un valor.
--Ejemplo:
Create or replace function total_horas_incidente (
    p_IncidenteID IN NUMBER
) RETURN NUMBER IS
    v_TotalHoras NUMBER;
BEGIN
    SELECT SUM(Horas) INTO v_TotalHoras FROM Asignaciones WHERE IncidenteID = p_IncidenteID;
    RETURN NVL(v_TotalHoras, 0);
END;


--4-Explica qué es un trigger y menciona dos tipos de eventos que pueden dispararlo. Da un ejemplo de un trigger que se dispare después de insertar una asignación en la tabla 
--Asignaciones y actualice el estado del incidente a 'En Proceso' si estaba en 'Abierto'.

--Un trigger es un bloque de código PL/SQL que se ejecuta automáticamente en respuesta a ciertos eventos en la base de datos, como inserciones, actualizaciones o 
--eliminaciones. Dos tipos de eventos que pueden disparar un trigger son AFTER INSERT y BEFORE UPDATE.

CREATE OR REPLACE TRIGGER trg_actualizar_estado_incidente
AFTER INSERT ON Asignaciones
FOR EACH ROW
DECLARE
    v_EstadoIncidente VARCHAR2(20);
BEGIN
    SELECT Estado INTO v_EstadoIncidente FROM Incidentes WHERE IncidenteID = :NEW.IncidenteID;
    IF v_EstadoIncidente = 'Abierto' THEN
        UPDATE Incidentes SET Estado = 'En Proceso' WHERE IncidenteID = :NEW.IncidenteID;
    END IF;
END;
/ 

SEGUNDA PARTE: PRÁCTICA

--1-Escribe un procedimiento registrar_asignacion que reciba un AgenteID, IncidenteID, Horas y Rol (parámetros IN). 
--El procedimiento debe:
--Insertar una nueva asignación en la tabla Asignaciones (usa el próximo AsignacionID disponible).
--Actualizar el estado del incidente a 'En Proceso' si estaba en 'Abierto'.
--Manejar excepciones si el agente o incidente no existen, o si el agente ya está asignado a ese incidente.

Create or replace Procedure registrar_asignacion (
    p_AgenteID IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas IN NUMBER,
    p_Rol IN VARCHAR2
) IS
    v_AsigID NUMBER;
    v_EstadoIncidente VARCHAR2(20);
BEGIN
    SELECT COUNT(*) INTO v_AsigID FROM Agentes WHERE AgenteID = p_AgenteID;
    IF v_AsigID = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Agente no existe');
    END IF;
    SELECT COUNT(*) INTO v_AsigID FROM Incidentes WHERE IncidenteID = p_IncidenteID;
    IF v_AsigID = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Incidente no existe');
    END IF;
    SELECT COUNT(*) INTO v_AsigID FROM Asignaciones WHERE AgenteID = p_AgenteID AND IncidenteID = p_IncidenteID;
    IF v_AsigID > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Agente ya asignado a este incidente');
    END IF;
    SELECT NVL(MAX(AsignacionID), 0) + 1 INTO v_AsigID FROM Asignaciones;
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol) VALUES (v_AsigID, p_AgenteID, p_IncidenteID, p_Horas, p_Rol);
    SELECT Estado INTO v_EstadoIncidente FROM Incidentes WHERE IncidenteID = p_IncidenteID;
    IF v_EstadoIncidente = 'Abierto' THEN
        UPDATE Incidentes SET Estado = 'En Proceso' WHERE IncidenteID = p_IncidenteID;
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

--2-Escribe una función para calcular_horas_agente que reciba AgenteID(parámetro IN) y devuelva el total de horas asignadas a ese agente en todos los
--incidentes. Luego, usa la función en un procedimiento mostrar_carga_agentes que muestre el total de horas por agente, para todos los agentes indicando su nombre y 
--especialidad.
Create or replace Function calcular_horas_agente (
    p_AgenteID IN NUMBER
) RETURN NUMBER IS
    v_TotalHoras NUMBER;
BEGIN
    SELECT SUM(Horas) INTO v_TotalHoras FROM Asignaciones WHERE AgenteID = p_AgenteID;
    RETURN NVL(v_TotalHoras, 0);
END;
/ 
Create or replace Procedure mostrar_carga_agentes IS
BEGIN
    FOR mostr IN (SELECT AgenteID, Nombre, Especialidad FROM Agentes) LOOP
        DBMS_OUTPUT.PUT_LINE('Agente: ' || mostr.Nombre || ' | Especialidad: ' || mostr.Especialidad || ' | Total Horas: ' || calcular_horas_agente(mostr.AgenteID));
    END LOOP;
END;
/
-- Ejecutar el procedimiento para mostrar la carga de los agentes
BEGIN
    mostrar_carga_agentes;
END;
/

--3-Implementa un sistema de auditoria manual usando un trigger. Para esto, primero crea una tabla llamada AuditoriaAsignaciones con las columnas necesarias. 
--Luego, crea un trigger auditar_asignaciones que se dispare después de insertar o eliminar una asignación en la tabla Asignaciones. El trigger debe registrar en la tabla de 
--auditoría el AsignacionID, AgenteID, IncidenteID, Horas, la acción realizada ('INSERT' o 'DELETE') y la fecha del registro.

CREATE TABLE AuditoriaAsignaciones (
    AuditoriaID NUMBER PRIMARY KEY,
    AsignacionID NUMBER,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Accion VARCHAR2(10),
    FechaRegistro DATE
); 
-- Crear trigger de auditoría
CREATE OR REPLACE TRIGGER auditar_asignaciones
AFTER INSERT OR DELETE ON Asignaciones
FOR EACH ROW
DECLARE
    v_AuditoriaID NUMBER;
BEGIN
    -- Obtener el próximo AuditoriaID disponible
    SELECT NVL(MAX(AuditoriaID), 0) + 1 INTO v_AuditoriaID FROM AuditoriaAsignaciones;
    IF INSERTING THEN
        INSERT INTO AuditoriaAsignaciones (AuditoriaID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro) VALUES 	(v_AuditoriaID, :NEW.AsignacionID, :NEW.AgenteID, :NEW.IncidenteID, :NEW.Horas, 'INSERT', SYSDATE);
    ELSIF DELETING THEN
        INSERT INTO AuditoriaAsignaciones (AuditoriaID, AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro) VALUES 	(v_AuditoriaID, :OLD.AsignacionID, :OLD.AgenteID, :OLD.IncidenteID, :OLD.Horas, 'DELETE', SYSDATE);
    END IF;
END;
/   

