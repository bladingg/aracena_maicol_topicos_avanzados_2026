
--Maicol Aracena
/*
================================================================================
PRUEBA 3 - TÓPICOS AVANZADOS DE BASES DE DATOS
================================================================================

INSTRUCCIONES GENERALES:
- Tiempo: 90 minutos
- Puntaje total: 100 puntos
- Parte 1 (teórica): 40 puntos | Parte 2 (práctica): 60 puntos
- Ejecute el script de datos antes de comenzar la parte práctica
- En la parte teórica, la lógica y el concepto son lo que se evalúa;
  errores menores de sintaxis no penalizan si la idea es correcta

================================================================================
PARTE 1 - PREGUNTAS TEÓRICAS (40 puntos, 10 puntos cada una)
================================================================================
*/
--PREGUNTA 1 (10 puntos)
--Explica qué es una transacción en una base de datos y describe las propiedades
--ACID. Luego, muestra a través de un ejemplo cómo usarías múltiples savepoints
--para manejar errores parciales en un procedimiento que asigna un agente a un
--incidente y actualiza simultáneamente el estado del incidente. ¿Qué ocurre si
--falla solo la actualización del estado?

--Una transacción en una base de datos es una unidad de trabajo que se ejecuta de manera completa o no se ejecuta en absoluto. Las propiedades ACID son:
--1. Atomicidad: La transacción se ejecuta en su totalidad o no se ejecuta.
--2. Consistencia: La base de datos pasa de un estado válido a otro estado válido.
--3. Aislamiento: Las transacciones concurrentes no interfieren entre sí.
--4. Durabilidad: Una vez que la transacción se ha confirmado, los cambios son permanentes, incluso en caso de fallos del sistema.
--Ejemplo de uso de savepoints:
CREATE OR REPLACE PROCEDURE asignar_agente_a_incidente ( 
    p_AgenteID IN NUMBER, 
    p_IncidenteID IN NUMBER, 
    p_Horas IN NUMBER 
) AS 
BEGIN 
    SAVEPOINT sp_asignacion; 
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol) 
    VALUES (Asignaciones_seq.NEXTVAL, p_AgenteID, p_IncidenteID, p_Horas, 'Apoyo'); 

    UPDATE Incidentes SET Estado = 'En Progreso' WHERE IncidenteID = p_IncidenteID; 

    COMMIT; 
EXCEPTION 
    WHEN OTHERS THEN 
        ROLLBACK TO sp_asignacion; 
        DBMS_OUTPUT.PUT_LINE('Error al asignar agente o actualizar estado: ' || SQLERRM); 
END;
/

--Si la sentencia UPDATE falla, el bloque de excepciones captura el error (mediante WHEN OTHERS) y ejecuta 
--el comando ROLLBACK TO sp_asignacion. Esto hace que se deshaga inmediatamente el INSERT de la asignación 
--que se había realizado un paso antes. De esta forma, la base de datos vuelve a su estado original 
--sin dejar datos a medias, cumpliendo con el principio de atomicidad.

--PREGUNTA 2 (10 puntos)
--¿Qué es un Data Warehouse y cómo se diferencia de una base de datos
--transaccional? Describe cómo diseñarías un modelo dimensional (tabla de hechos
--y al menos dos dimensiones) para analizar las horas trabajadas por agente y
--por severidad de incidente. ¿Qué ventajas tiene este modelo para consultas
--analíticas versus consultar directamente las tablas transaccionales?

--Data warehouse es un sistema de almacenamiento de datos diseñado para facilitar el análisis y la toma de 
--decisiones. Se diferencia de una base de datos transaccional en que está optimizado para consultas complejas 
--y análisis de grandes volúmenes de datos, mientras que las bases de datos transaccionales están optimizadas
--para operaciones de lectura y escritura rápidas y consistentes. 

--Data warehouse es un sistema de almacenamiento de datos diseñado para facilitar el análisis y la toma de 
--decisiones. Se diferencia de una base de datos transaccional en que está optimizado para consultas complejas 
--y análisis de grandes volúmenes de datos, mientras que las bases de datos transaccionales están optimizadas
--para operaciones de lectura y escritura rápidas y consistentes. 

--Modelo dimensional:
-- -Tabla de hechos: Fact_Asignaciones
--  - Atributos: AsignacionID, AgenteID, IncidenteID,
--    Horas, FechaAsignacion
-- - Dimensiones:
--   - Dim_Agente: AgenteID, Nombre, Especialidad
--   - Dim_Incidente: IncidenteID, Severidad, Estado, FechaDeteccion

--Ventajas del modelo dimensional: 
-- 1. Facilita la comprensión de los datos para los usuarios finales.
-- 2. Optimiza las consultas analíticas mediante el uso de agregaciones y jerarquías.
-- 3. Permite un mejor rendimiento en consultas complejas al reducir la necesidad de joins múltiples.



--PREGUNTA 3 (10 puntos)
--Explica cómo se implementa la herencia en Oracle usando tipos de objetos.
--Da un ejemplo de una jerarquía de dos niveles: Agente → AgenteEspecialista →
--AgentePentester, donde cada nivel agrega atributos y sobreescribe un método
--calcular_costo(). ¿Qué implicancias tiene declarar un tipo como NOT
--INSTANTIABLE?

--La herencia en Oracle se implementa mediante tipos de objetos, donde un tipo puede heredar atributos y 
--métodos de otro tipo. Esto permite crear jerarquías de objetos y reutilizar código.
--Ejemplo de jerarquía de dos niveles:
CREATE OR REPLACE TYPE Agente AS OBJECT (
    AgenteID NUMBER,
    Nombre VARCHAR2(50),
    MEMBER FUNCTION calcular_costo RETURN NUMBER
);
-- Tipo AgenteEspecialista que hereda de Agente
CREATE OR REPLACE TYPE AgenteEspecialista UNDER Agente (
    Especialidad VARCHAR2(50),
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
);
-- Tipo AgentePentester que hereda de AgenteEspecialista
CREATE OR REPLACE TYPE AgentePentester UNDER AgenteEspecialista (
    Certificacion VARCHAR2(50),
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
);
--Declarar un tipo como NOT INSTANTIABLE significa que no se pueden crear instancias directas de 
--ese tipo, sino que solo se pueden crear instancias de sus subtipos. Esto es útil para definir una clase 
--base abstracta que proporciona una interfaz común para sus subtipos, pero no tiene sentido crear instancias
--de la clase base por sí sola.

--PREGUNTA 4 (10 puntos)
--Describe las ventajas y desventajas de usar índices y particiones en una base
--de datos. ¿Cómo usarías un índice compuesto y una partición por rango para
--mejorar el rendimiento de consultas en la tabla Incidentes filtradas por
--Severidad y FechaDeteccion? Explica qué es el partition pruning y cómo
--impacta en el plan de ejecución.

--Las ventajas de usar indices incluyen:
-- - Mejora el rendimiento de las consultas al permitir búsquedas más rápidas.
-- - Facilita la recuperación de datos específicos sin necesidad de escanear toda la tabla.
--Las desventajas de usar indices incluyen:
-- - Aumenta el tiempo de inserción, actualización y eliminación de registros debido a la necesidad de mantener el índice.
-- - Ocupa espacio adicional en disco.
--Las ventajas de usar particiones incluyen:
-- - Mejora el rendimiento de las consultas al permitir que solo se escaneen las particiones relevantes.
-- - Facilita la gestión de grandes volúmenes de datos al permitir operaciones de mantenimiento en particiones individuales.
--Las desventajas de usar particiones incluyen:
-- - Aumenta la complejidad del diseño y mantenimiento de la base de datos.
--¿Cómo usarías un índice compuesto y una partición por rango para
--mejorar el rendimiento de consultas en la tabla Incidentes filtradas por
--Severidad y FechaDeteccion? Explica qué es el partition pruning y cómo
--impacta en el plan de ejecución:

--Lo usaría creando primero la tabla Incidentes particionada por rango según la columna FechaDeteccion. 
--Esto dividirá físicamente los datos por trimestres. Luego, crearía un índice compuesto en las columnas 
--(Severidad, FechaDeteccion). Esto permitiría que la base de datos encuentre inmediatamente los incidentes 
--de una severidad y rango de fechas específico, actuando como un directorio rápido dentro de cada partición.
--Ejemplo:
CREATE TABLE Incidentes (
    IncidenteID NUMBER PRIMARY KEY,
    Descripcion VARCHAR2(100),
    Severidad VARCHAR2(20),
    Estado VARCHAR2(20),
    FechaDeteccion DATE
) PARTITION BY RANGE (FechaDeteccion) (
    PARTITION p_q1_2026 VALUES LESS THAN (TO_DATE('2026-04-01','YYYY-MM-DD')),
    PARTITION p_q2_2026 VALUES LESS THAN (TO_DATE('2026-07-01','YYYY-MM-DD')),
    PARTITION p_q3_2026 VALUES LESS THAN (TO_DATE('2026-10-01','YYYY-MM-DD')),
    PARTITION p_q4_2026 VALUES LESS THAN (TO_DATE('2027-01-01','YYYY-MM-DD'))
);
CREATE INDEX idx_severidad_fecha ON Incidentes (Severidad, FechaDeteccion);

--El Partition Pruning (poda de particiones) es la capacidad que tiene la base de datos para identificar y 
--leer de forma inteligente solo las particiones que contienen los datos relevantes para tu consulta, 
--ignorando por completo el resto de la tabla. Esto impacta positivamente en el plan de ejecución, ya que 
--reduce significativamente el tiempo de respuesta de la consulta al minimizar la cantidad de datos que se 
--deben escanear y procesar.


/*
================================================================================
PARTE 2 - EJERCICIOS PRÁCTICOS (60 puntos)
================================================================================

EJERCICIO 1 (20 puntos)
Escribe un procedimiento registrar_asignacion que reciba un AgenteID,
IncidenteID, Horas y Rol (parámetros IN). El procedimiento debe:
  a) Insertar una nueva asignación en Asignaciones (usa el próximo
     AsignacionID disponible).
  b) Validar que el agente no supere 100 horas totales asignadas en
     incidentes con Estado 'Abierto'.
  c) Validar que el incidente no tenga ya 3 o más agentes asignados.
  d) Usar savepoints independientes para cada validación, de modo que un
     fallo en una no deshaga operaciones previas válidas.
  e) Manejar todas las excepciones con mensajes descriptivos.
*/

CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_AgenteID IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas IN NUMBER,
    p_Rol IN VARCHAR2
) AS
    v_nuevo_id NUMBER;
    v_horas_totales NUMBER;
    v_cant_agentes NUMBER;
    e_horas_excedidas EXCEPTION;
    e_max_agentes EXCEPTION;
BEGIN
    SAVEPOINT sp_inicio;
    
    SELECT NVL(MAX(AsignacionID), 0) + 1 INTO v_nuevo_id FROM Asignaciones;

    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (v_nuevo_id, p_AgenteID, p_IncidenteID, p_Horas, p_Rol);

    SAVEPOINT sp_val_horas;
    
    SELECT NVL(SUM(a.Horas), 0) INTO v_horas_totales
    FROM Asignaciones a
    INNER JOIN Incidentes i ON a.IncidenteID = i.IncidenteID
    WHERE a.AgenteID = p_AgenteID AND i.Estado = 'Abierto';

    IF v_horas_totales > 100 THEN
        RAISE e_horas_excedidas;
    END IF;

    SAVEPOINT sp_val_agentes;
    
    SELECT COUNT(AgenteID) INTO v_cant_agentes
    FROM Asignaciones
    WHERE IncidenteID = p_IncidenteID;

    IF v_cant_agentes > 3 THEN
        RAISE e_max_agentes;
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Exito: Asignacion ' || v_nuevo_id || ' registrada correctamente.');

EXCEPTION
    WHEN e_horas_excedidas THEN
        DBMS_OUTPUT.PUT_LINE('Rechazado: El agente supera las 100 horas en incidentes abiertos.');
        ROLLBACK TO sp_inicio;
    WHEN e_max_agentes THEN
        DBMS_OUTPUT.PUT_LINE('Rechazado: El incidente ya alcanzo el limite de 3 agentes asignados.');
        ROLLBACK TO sp_inicio;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error critico inesperado: ' || SQLERRM);
        ROLLBACK TO sp_inicio;
END;
/

/*
EJERCICIO 2 (20 puntos)
Diseña las tablas Fact_Asignaciones, Dim_Agente y Dim_Incidente para un
Data Warehouse basado en la base de datos de la prueba. Luego, escribe una
consulta analítica sobre las tablas transaccionales que muestre, para cada
agente, el total de horas trabajadas y el número de incidentes atendidos,
ordenado de mayor a menor por total de horas
*/

CREATE TABLE Dim_Agente (
    AgenteID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50),
    Especialidad VARCHAR2(50)
);

CREATE TABLE Dim_Incidente (
    IncidenteID NUMBER PRIMARY KEY,
    Descripcion VARCHAR2(100),
    Severidad VARCHAR2(20)
);

CREATE TABLE Fact_Asignaciones (
    AsignacionID NUMBER PRIMARY KEY,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    CONSTRAINT fk_fact_agente FOREIGN KEY (AgenteID) REFERENCES Dim_Agente(AgenteID),
    CONSTRAINT fk_fact_incidente FOREIGN KEY (IncidenteID) REFERENCES Dim_Incidente(IncidenteID)
);

SELECT ag.Nombre, 
       SUM(a.Horas) AS Total_Horas_Trabajadas, 
       COUNT(a.IncidenteID) AS Numero_Incidentes_Atendidos
FROM Agentes ag
INNER JOIN Asignaciones a ON ag.AgenteID = a.AgenteID
GROUP BY ag.Nombre
ORDER BY Total_Horas_Trabajadas DESC;

/*
EJERCICIO 3 (20 puntos)
Crea un índice compuesto en Incidentes para las columnas Severidad y
FechaDeteccion. Luego, crea la tabla Incidentes particionada por rango de
FechaDeteccion (trimestral para 2026). Escribe una consulta que muestre el
total de horas asignadas por incidente para incidentes 'Critical' detectados
en el primer trimestre de 2026. Finalmente, muestra el plan de ejecución
con EXPLAIN PLAN e indica qué ventaja aporta la partición para esta consulta.
*/

--Drop table para evitar errores si ya existe
DROP TABLE Incidentes CASCADE CONSTRAINTS;

CREATE TABLE Incidentes (
    IncidenteID NUMBER PRIMARY KEY,
    Descripcion VARCHAR2(100),
    Severidad VARCHAR2(20),
    Estado VARCHAR2(20),
    FechaDeteccion DATE
) PARTITION BY RANGE (FechaDeteccion) (
    PARTITION p_q1_2026 VALUES LESS THAN (TO_DATE('2026-04-01','YYYY-MM-DD')),
    PARTITION p_q2_2026 VALUES LESS THAN (TO_DATE('2026-07-01','YYYY-MM-DD')),
    PARTITION p_q3_2026 VALUES LESS THAN (TO_DATE('2026-10-01','YYYY-MM-DD')), 
    PARTITION p_q4_2026 VALUES LESS THAN (TO_DATE('2027-01-01','YYYY-MM-DD'))
);    

CREATE INDEX idx_severidad_fecha ON Incidentes (Severidad, FechaDeteccion);


SELECT i.IncidenteID, i.Descripcion, SUM(a.Horas) AS Total_Horas_Asignadas
FROM Incidentes i
INNER JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
WHERE i.Severidad = 'Critical' 
  AND i.FechaDeteccion BETWEEN TO_DATE('2026-01-01','YYYY-MM-DD') AND TO_DATE('2026-03-31','YYYY-MM-DD')
GROUP BY i.IncidenteID, i.Descripcion; 


EXPLAIN PLAN FOR
SELECT i.IncidenteID, i.Descripcion, SUM(a.Horas) AS Total_Horas_Asignadas
FROM Incidentes i
INNER JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
WHERE i.Severidad = 'Critical' 
  AND i.FechaDeteccion BETWEEN TO_DATE('2026-01-01','YYYY-MM-DD') AND TO_DATE('2026-03-31','YYYY-MM-DD')
GROUP BY i.IncidenteID, i.Descripcion;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
