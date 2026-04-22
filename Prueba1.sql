--PRUEBA 1 MAICOL ARACENA

--PREGUNTAS TEORICAS 
-- 1 Una relación muchos a muchos es cuando dos tablas reciben literalmente mucho de alguna variable, por lo cual esto no es posible en sql ya que
--viola la regla de atomicidad que es que dos tablas tienen variables duplicadas, para aquello se debe crear una tabla intermediaria, dentro de la prueba
--se encuentra la tabla asignaciones con agentes, el cual para poder conllevar una relación se debe crear una tabla intermediaria, un nombre para esta seria DetallesAsignaciones, el cual tendría una PK con su respectivo ID, y recibiría como FOREIGN KEY las llaves primarias de las dos tablas que se quieren conecta


--2
--Una vista sirve para poder conujugar tablas sin necesidad de tener que estar llamándolas una por una, de esta forma gracias a las vistas el trabajo se hace más eficaz, ayudando al programador a no tener que escribir tanto código de forma redundante
--La vista seria
CREATE OR REPLACE VIEW vista_horas as
Select a.Horas, i.Descripcion, i.Severidad FROM * Asignaciones
Inner Join Incidentes i ON i.IncidenteID = a.IncidenteID;


--3 Una excepción es una parte del código donde nos entrega información de que sucede en caso de que el código tenga un error, se maneja mediante bloques anónimos o cursores, en cualquier se puede agregar y deben tener líneas explicitas de códigos para validar el error, existen varios tipos de excepciones, en este caso el NO_DATA_FOUND sirve para cuando entregamos una variable, como por ejemplo un ID al programa, y este al ejecutarlo no lo encuentra, aquello nos brindaría el NO_DATA_FOUND

--4
--Un cursor explicito es un segmento de código que sirve para poder realizar operaciones dentro de este código, se usa mediante las funciones CURSOR, OPEN, el cual le damos datos de nuestras tablas, de esta forma podemos iterar sobre ellas mediante cursores. El atributo %NOTFOUND, es cuando el cursor no encuentra lo solicitado, se escribe EXIT WHEN (nombre_cursor)%NOTFOUND
Por otra parte tenemos el atributo de UPDATE, que es cuando necesitamos setear dentro del código un valor que se debe actualizar.
 



--5
SET SERVEROUTPUT ON;
DECLARE
	CURSOR especialidades_cursor IS
	Select ag.Especialidad, a.horas FROM Asignaciones
	INNER JOIN Agentes ag ON ag.AgenteID = a.AgenteID;
	WHERE SUM(AVG(a.horas))>30;
	GROUP BY ag.Especialidad;

	v_especialidad Agentes.Especialidad%TYPE;
	v_horas NUMBER;
BEGIN
	OPEN especialidades_cursor;
	LOOP
	FETCH especialidades_cursor INTO v_especialidad, v_horas;
	EXIT WHEN especialidades_cursor%NOTFOUND;
	DBMS_OUTPUT.PUT_LINE('Lista de especialidades de agentes con promedio mayor a 30: ' || v_especialidad || ' Horas ' || v_horas);
	END LOOP;
	CLOSE especialidades_cursor;
END;
/


--6
DECLARE 
	CURSOR aumento_cursor AS
	Select as.Horas, i.Severidad FROM Asignaciones
	INNER JOIN Incidentes i ON i.IncidenteID = as.IncidenteID;
	WHERE i.Severidad = "Critical"
	FOR UDPATE;
	
	v_horas Asignaciones.Horas%TYPE;
	v_severidad Incidentes.Severidad%TYPE;
	v_horas_aumentadas NUMBER;
	
BEGIN
	Open aumento_cursor
	LOOP
	FETCH aumento_cursor INTO v_horas, v_severidad
	EXIT WHEN aumento_cursor%NOTFOUND;
	v_horas_aumentadas ;= v_horas + 10;
	UPDATE Asignaciones
	SET Horas = v_horas_aumentadas
	WHERE CURRENT OF aumento_cursor;
	DBMS_OUTPUT.PUT_LINE('Asignaciones asociadas con CRITICAL aumentadas en 10 horas ' || v_horas_aumentadas);
	END LOOP;
	CLOSE aumento_cursor;
EXCEPTION 
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
	IF aumento_cursor%ISOPEN THEN
	CLOSE aumento_cursor;
	ENDI IF;;
END;
/ 


--7

CREATE OR REPLACE TYPE INCIDENTE_OBJ AS OBJETCT
()
	 
	


 
	
	
