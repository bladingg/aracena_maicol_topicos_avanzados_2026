-- Sesion 7:

ALTER SESSION SET CONTAINER = XEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;

SET SERVEROUTPUT ON;

-- 1) Procedimiento para incrementar precio de un producto
CREATE OR REPLACE PROCEDURE ajustar_valor_producto(
	p_id_articulo   IN NUMBER,
	p_incremento_pct IN NUMBER
) AS
	v_precio_previo Productos.Precio%TYPE;
	v_precio_nuevo  Productos.Precio%TYPE;
BEGIN
	SELECT Precio
	INTO v_precio_previo
	FROM Productos
	WHERE ProductoID = p_id_articulo;

	v_precio_nuevo := ROUND(v_precio_previo * (1 + (p_incremento_pct / 100)), 2);

	UPDATE Productos
	SET Precio = v_precio_nuevo
	WHERE ProductoID = p_id_articulo;

	DBMS_OUTPUT.PUT_LINE(
		'Producto ' || p_id_articulo ||
		' | Precio anterior: ' || v_precio_previo ||
		' | Precio nuevo: ' || v_precio_nuevo
	);

	COMMIT;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20031, 'No existe ProductoID = ' || p_id_articulo);
	WHEN OTHERS THEN
		ROLLBACK;
		DBMS_OUTPUT.PUT_LINE('Fallo al ajustar precio: ' || SQLERRM);
END;
/

-- Prueba del procedimiento 1
BEGIN
	ajustar_valor_producto(2, 10);
END;
/


-- 2) Procedimiento para contar pedidos de un cliente
CREATE OR REPLACE PROCEDURE obtener_total_pedidos_cliente(
	p_id_cliente IN NUMBER,
	p_total_pedidos OUT NUMBER
) AS
BEGIN
	SELECT NVL(COUNT(*), 0)
	INTO p_total_pedidos
	FROM Pedidos
	WHERE ClienteID = p_id_cliente;

	DBMS_OUTPUT.PUT_LINE(
		'Cliente ' || p_id_cliente ||
		' tiene ' || p_total_pedidos || ' pedido(s).'
	);
END;
/

-- Prueba del procedimiento 2
DECLARE
	v_cantidad_pedidos NUMBER;
BEGIN
	obtener_total_pedidos_cliente(1, v_cantidad_pedidos);
	DBMS_OUTPUT.PUT_LINE('Cantidad devuelta por OUT: ' || v_cantidad_pedidos);
END;
/

