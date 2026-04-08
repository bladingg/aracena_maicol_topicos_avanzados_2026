-- Sesion 6

--Altero la sesión para conectarme a la base de datos correcta
ALTER SESSION SET CONTAINER = XEPDB1;
--Cambiar el esquema al curso topicos
ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;

SET SERVEROUTPUT ON;

--Se crean los tipos necesarios para el ejercicio
CREATE OR REPLACE TYPE cliente_obj_t AS OBJECT (
	cliente_id NUMBER,
	nombre VARCHAR2(50),
	ciudad VARCHAR2(50),
	fecha_nacimiento DATE
);
/

CREATE OR REPLACE TYPE cliente_param_t AS OBJECT (
	cliente_id NUMBER
);
/

DECLARE
	CURSOR c_clientes IS
		SELECT cliente_obj_t(c.clienteid, c.nombre, c.ciudad, c.fechanacimiento)
		FROM clientes c
		ORDER BY c.nombre;

	v_cliente cliente_obj_t;
BEGIN
	DBMS_OUTPUT.PUT_LINE('Listado de clientes (Nombre, Ciudad) ordenado por nombre:');

	OPEN c_clientes;
	LOOP
		FETCH c_clientes INTO v_cliente;
		EXIT WHEN c_clientes%NOTFOUND;

		DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_cliente.nombre || ' | Ciudad: ' || v_cliente.ciudad);
	END LOOP;
	CLOSE c_clientes;
END;
/

DECLARE
	v_param_cliente cliente_param_t := cliente_param_t(1); -- Cambiar ID si se requiere

	CURSOR c_pedidos(p_cliente cliente_param_t) IS
		SELECT p.pedidoid, p.total
		FROM pedidos p
		WHERE p.clienteid = p_cliente.cliente_id
		FOR UPDATE OF p.total;

	v_pedido_id NUMBER;
	v_total_original NUMBER;
	v_total_actualizado NUMBER;
	v_suma_original NUMBER := 0;
	v_suma_actualizada NUMBER := 0;
BEGIN
	DBMS_OUTPUT.PUT_LINE('Actualizando pedidos del ClienteID = ' || v_param_cliente.cliente_id);

	OPEN c_pedidos(v_param_cliente);
	LOOP
		FETCH c_pedidos INTO v_pedido_id, v_total_original;
		EXIT WHEN c_pedidos%NOTFOUND;

		v_total_actualizado := ROUND(v_total_original * 1.10, 2);

		UPDATE pedidos
		SET total = v_total_actualizado
		WHERE CURRENT OF c_pedidos;

		v_suma_original := v_suma_original + v_total_original;
		v_suma_actualizada := v_suma_actualizada + v_total_actualizado;

		DBMS_OUTPUT.PUT_LINE(
			'PedidoID: ' || v_pedido_id ||
        	'  Total original: ' || v_total_original ||
			'  Total actualizado: ' || v_total_actualizado
		);
	END LOOP;
	CLOSE c_pedidos;

	DBMS_OUTPUT.PUT_LINE('Suma original total   : ' || v_suma_original);
	DBMS_OUTPUT.PUT_LINE('Suma actualizada total: ' || v_suma_actualizada);

	COMMIT;
END;
/

