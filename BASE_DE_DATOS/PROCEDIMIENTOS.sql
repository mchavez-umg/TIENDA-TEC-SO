CREATE OR REPLACE PROCEDURE PR_CREAR_FACTURA (
    p_id_sucursal IN NUMBER,
    p_id_cliente  IN NUMBER,
    p_id_empleado IN NUMBER,
    p_id_factura  OUT NUMBER
)
IS
    v_serie  FACTURA.SERIE%TYPE;
    v_numero FACTURA.NUMERO%TYPE;
BEGIN
    SELECT CODIGO INTO v_serie
    FROM SUCURSAL
    WHERE ID_SUCURSAL = p_id_sucursal;

    SELECT NVL(MAX(NUMERO), 0) + 1 INTO v_numero
    FROM FACTURA
    WHERE SERIE = v_serie;

    p_id_factura := SEQ_FACTURA.NEXTVAL;

    INSERT INTO FACTURA (ID_FACTURA, ID_SUCURSAL, ID_CLIENTE, ID_EMPLEADO, SERIE, NUMERO, SUBTOTAL, IVA, TOTAL, ID_ESTADO)
    VALUES (p_id_factura, p_id_sucursal, p_id_cliente, p_id_empleado, v_serie, v_numero, 0, 0, 0, FN_ID_ESTADO('FACTURA', 'EMITIDA'));
END;
/

CREATE OR REPLACE PROCEDURE PR_AGREGAR_DETALLE_FACTURA (
    p_id_factura  IN NUMBER,
    p_id_producto IN NUMBER,
    p_cantidad    IN NUMBER,
    p_descuento   IN NUMBER DEFAULT 0
)
IS
    v_precio   PRODUCTO.PRECIO_VENTA%TYPE;
    v_subtotal DETALLE_FACTURA.SUBTOTAL%TYPE;
    v_total    FACTURA.TOTAL%TYPE;
BEGIN
    IF FN_TOTAL_PAGADO(p_id_factura) > 0 THEN
        RAISE_APPLICATION_ERROR(-20030, 'No se agregan productos a una factura que ya tiene pagos');
    END IF;

    BEGIN
        SELECT PRECIO_VENTA INTO v_precio
        FROM PRODUCTO
        WHERE ID_PRODUCTO = p_id_producto
          AND ID_ESTADO = FN_ID_ESTADO('PRODUCTO', 'A');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20031, 'El producto no existe o está inactivo');
    END;

    v_subtotal := p_cantidad * v_precio - p_descuento;

    IF v_subtotal < 0 THEN
        RAISE_APPLICATION_ERROR(-20032, 'El descuento supera el valor de la línea');
    END IF;

    INSERT INTO DETALLE_FACTURA (ID_FACTURA, ID_PRODUCTO, CANTIDAD, PRECIO_UNITARIO, DESCUENTO, SUBTOTAL)
    VALUES (p_id_factura, p_id_producto, p_cantidad, v_precio, p_descuento, v_subtotal);

    SELECT SUM(SUBTOTAL) INTO v_total
    FROM DETALLE_FACTURA
    WHERE ID_FACTURA = p_id_factura;

    UPDATE FACTURA
    SET TOTAL = v_total,
        SUBTOTAL = ROUND(v_total / 1.12, 2),
        IVA = v_total - ROUND(v_total / 1.12, 2)
    WHERE ID_FACTURA = p_id_factura;
END;
/

CREATE OR REPLACE PROCEDURE PR_REGISTRAR_PAGO (
    p_id_factura      IN NUMBER,
    p_id_forma_pago   IN NUMBER,
    p_monto           IN NUMBER,
    p_id_banco        IN NUMBER DEFAULT NULL,
    p_no_referencia   IN VARCHAR2 DEFAULT NULL,
    p_no_autorizacion IN VARCHAR2 DEFAULT NULL
)
IS
    v_requiere FORMA_PAGO.REQUIERE_REFERENCIA%TYPE;
    v_total    FACTURA.TOTAL%TYPE;
BEGIN
    SELECT REQUIERE_REFERENCIA INTO v_requiere
    FROM FORMA_PAGO
    WHERE ID_FORMA_PAGO = p_id_forma_pago;

    IF v_requiere = 'S' AND (p_id_banco IS NULL OR (p_no_referencia IS NULL AND p_no_autorizacion IS NULL)) THEN
        RAISE_APPLICATION_ERROR(-20033, 'Esta forma de pago requiere banco y número de referencia o autorización');
    END IF;

    SELECT TOTAL INTO v_total
    FROM FACTURA
    WHERE ID_FACTURA = p_id_factura;

    IF FN_TOTAL_PAGADO(p_id_factura) + p_monto > v_total THEN
        RAISE_APPLICATION_ERROR(-20035, 'Los pagos superan el total de la factura');
    END IF;

    INSERT INTO PAGO (ID_FACTURA, ID_FORMA_PAGO, ID_BANCO, MONTO, NO_REFERENCIA, NO_AUTORIZACION)
    VALUES (p_id_factura, p_id_forma_pago, p_id_banco, p_monto, p_no_referencia, p_no_autorizacion);
END;
/

CREATE OR REPLACE PROCEDURE PR_FINALIZAR_FACTURA (
    p_id_factura IN NUMBER
)
IS
    v_total  FACTURA.TOTAL%TYPE;
    v_pagado NUMBER;
BEGIN
    SELECT TOTAL INTO v_total
    FROM FACTURA
    WHERE ID_FACTURA = p_id_factura;

    IF v_total = 0 THEN
        RAISE_APPLICATION_ERROR(-20036, 'La factura no tiene productos');
    END IF;

    v_pagado := FN_TOTAL_PAGADO(p_id_factura);

    IF v_pagado <> v_total THEN
        RAISE_APPLICATION_ERROR(-20037, 'Los pagos (Q' || v_pagado || ') no cuadran con el total de la factura (Q' || v_total || ')');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE PR_CREAR_NOTA_CREDITO (
    p_id_factura      IN NUMBER,
    p_id_empleado     IN NUMBER,
    p_motivo          IN VARCHAR2,
    p_id_nota_credito OUT NUMBER
)
IS
    v_serie  NOTA_CREDITO.SERIE%TYPE;
    v_numero NOTA_CREDITO.NUMERO%TYPE;
BEGIN
    SELECT SERIE INTO v_serie
    FROM FACTURA
    WHERE ID_FACTURA = p_id_factura;

    SELECT NVL(MAX(NUMERO), 0) + 1 INTO v_numero
    FROM NOTA_CREDITO
    WHERE SERIE = v_serie;

    p_id_nota_credito := SEQ_NOTA_CREDITO.NEXTVAL;

    INSERT INTO NOTA_CREDITO (ID_NOTA_CREDITO, ID_FACTURA, ID_EMPLEADO, SERIE, NUMERO, MOTIVO, TOTAL, ID_ESTADO)
    VALUES (p_id_nota_credito, p_id_factura, p_id_empleado, v_serie, v_numero, p_motivo, 0, FN_ID_ESTADO('NOTA_CREDITO', 'EMITIDA'));
END;
/

CREATE OR REPLACE PROCEDURE PR_AGREGAR_DETALLE_NC (
    p_id_nota_credito      IN NUMBER,
    p_id_detalle_factura   IN NUMBER,
    p_cantidad             IN NUMBER,
    p_reingresa_inventario IN VARCHAR2 DEFAULT 'S'
)
IS
    v_cantidad   DETALLE_FACTURA.CANTIDAD%TYPE;
    v_subtotal   DETALLE_FACTURA.SUBTOTAL%TYPE;
    v_id_factura DETALLE_FACTURA.ID_FACTURA%TYPE;
    v_monto      DETALLE_NOTA_CREDITO.MONTO%TYPE;
    v_pendiente  NUMBER;
    v_id_estado  NOTA_CREDITO.ID_ESTADO%TYPE;
BEGIN
    SELECT ID_ESTADO INTO v_id_estado
    FROM NOTA_CREDITO
    WHERE ID_NOTA_CREDITO = p_id_nota_credito;

    IF v_id_estado <> FN_ID_ESTADO('NOTA_CREDITO', 'EMITIDA') THEN
        RAISE_APPLICATION_ERROR(-20044, 'Solo se agregan líneas a una nota de crédito EMITIDA');
    END IF;

    SELECT CANTIDAD, SUBTOTAL, ID_FACTURA INTO v_cantidad, v_subtotal, v_id_factura
    FROM DETALLE_FACTURA
    WHERE ID_DETALLE_FACTURA = p_id_detalle_factura;

    IF p_cantidad = FN_CANTIDAD_PENDIENTE_NC(p_id_detalle_factura) THEN
        v_monto := FN_MONTO_PENDIENTE_NC(p_id_detalle_factura);
    ELSE
        v_monto := ROUND(v_subtotal / v_cantidad * p_cantidad, 2);
    END IF;

    INSERT INTO DETALLE_NOTA_CREDITO (ID_NOTA_CREDITO, ID_DETALLE_FACTURA, CANTIDAD, MONTO, REINGRESA_INVENTARIO)
    VALUES (p_id_nota_credito, p_id_detalle_factura, p_cantidad, v_monto, p_reingresa_inventario);

    UPDATE NOTA_CREDITO
    SET TOTAL = (SELECT SUM(MONTO) FROM DETALLE_NOTA_CREDITO WHERE ID_NOTA_CREDITO = p_id_nota_credito)
    WHERE ID_NOTA_CREDITO = p_id_nota_credito;

    SELECT SUM(FN_CANTIDAD_PENDIENTE_NC(ID_DETALLE_FACTURA)) INTO v_pendiente
    FROM DETALLE_FACTURA
    WHERE ID_FACTURA = v_id_factura;

    IF v_pendiente = 0 THEN
        UPDATE FACTURA SET ID_ESTADO = FN_ID_ESTADO('FACTURA', 'NC_TOTAL') WHERE ID_FACTURA = v_id_factura;
    ELSE
        UPDATE FACTURA SET ID_ESTADO = FN_ID_ESTADO('FACTURA', 'NC_PARCIAL') WHERE ID_FACTURA = v_id_factura;
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE PR_FINALIZAR_NOTA_CREDITO (
    p_id_nota_credito IN NUMBER
)
IS
    v_total NOTA_CREDITO.TOTAL%TYPE;
BEGIN
    SELECT TOTAL INTO v_total
    FROM NOTA_CREDITO
    WHERE ID_NOTA_CREDITO = p_id_nota_credito;

    IF v_total = 0 THEN
        RAISE_APPLICATION_ERROR(-20038, 'La nota de crédito no tiene líneas');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE PR_CREAR_COMPRA (
    p_id_proveedor IN NUMBER,
    p_id_sucursal  IN NUMBER,
    p_id_empleado  IN NUMBER,
    p_no_documento IN VARCHAR2,
    p_id_compra    OUT NUMBER
)
IS
BEGIN
    p_id_compra := SEQ_COMPRA.NEXTVAL;

    INSERT INTO COMPRA (ID_COMPRA, ID_PROVEEDOR, ID_SUCURSAL, ID_EMPLEADO, NO_DOCUMENTO, TOTAL, ID_ESTADO)
    VALUES (p_id_compra, p_id_proveedor, p_id_sucursal, p_id_empleado, p_no_documento, 0, FN_ID_ESTADO('COMPRA', 'PENDIENTE'));
END;
/

CREATE OR REPLACE PROCEDURE PR_AGREGAR_DETALLE_COMPRA (
    p_id_compra      IN NUMBER,
    p_id_producto    IN NUMBER,
    p_cantidad       IN NUMBER,
    p_costo_unitario IN NUMBER
)
IS
    v_id_estado COMPRA.ID_ESTADO%TYPE;
BEGIN
    SELECT ID_ESTADO INTO v_id_estado
    FROM COMPRA
    WHERE ID_COMPRA = p_id_compra;

    IF v_id_estado <> FN_ID_ESTADO('COMPRA', 'PENDIENTE') THEN
        RAISE_APPLICATION_ERROR(-20039, 'Solo se agregan productos a una compra PENDIENTE');
    END IF;

    INSERT INTO DETALLE_COMPRA (ID_COMPRA, ID_PRODUCTO, CANTIDAD, COSTO_UNITARIO, SUBTOTAL)
    VALUES (p_id_compra, p_id_producto, p_cantidad, p_costo_unitario, p_cantidad * p_costo_unitario);

    UPDATE COMPRA
    SET TOTAL = (SELECT SUM(SUBTOTAL) FROM DETALLE_COMPRA WHERE ID_COMPRA = p_id_compra)
    WHERE ID_COMPRA = p_id_compra;
END;
/

CREATE OR REPLACE PROCEDURE PR_RECIBIR_COMPRA (
    p_id_compra IN NUMBER
)
IS
    v_lineas NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_lineas
    FROM DETALLE_COMPRA
    WHERE ID_COMPRA = p_id_compra;

    IF v_lineas = 0 THEN
        RAISE_APPLICATION_ERROR(-20040, 'La compra no existe o no tiene productos');
    END IF;

    UPDATE COMPRA
    SET ID_ESTADO = FN_ID_ESTADO('COMPRA', 'RECIBIDA')
    WHERE ID_COMPRA = p_id_compra;
END;
/

CREATE OR REPLACE PROCEDURE PR_ANULAR_COMPRA (
    p_id_compra IN NUMBER
)
IS
BEGIN
    UPDATE COMPRA
    SET ID_ESTADO = FN_ID_ESTADO('COMPRA', 'ANULADA')
    WHERE ID_COMPRA = p_id_compra;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20041, 'La compra no existe');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE PR_CREAR_TRASLADO (
    p_id_sucursal_origen  IN NUMBER,
    p_id_sucursal_destino IN NUMBER,
    p_id_empleado         IN NUMBER,
    p_observacion         IN VARCHAR2,
    p_id_traslado         OUT NUMBER
)
IS
BEGIN
    p_id_traslado := SEQ_TRASLADO.NEXTVAL;

    INSERT INTO TRASLADO (ID_TRASLADO, ID_SUCURSAL_ORIGEN, ID_SUCURSAL_DESTINO, ID_EMPLEADO, OBSERVACION, ID_ESTADO)
    VALUES (p_id_traslado, p_id_sucursal_origen, p_id_sucursal_destino, p_id_empleado, p_observacion, FN_ID_ESTADO('TRASLADO', 'ENVIADO'));
END;
/

CREATE OR REPLACE PROCEDURE PR_AGREGAR_DETALLE_TRASLADO (
    p_id_traslado IN NUMBER,
    p_id_producto IN NUMBER,
    p_cantidad    IN NUMBER
)
IS
BEGIN
    INSERT INTO DETALLE_TRASLADO (ID_TRASLADO, ID_PRODUCTO, CANTIDAD)
    VALUES (p_id_traslado, p_id_producto, p_cantidad);
END;
/

CREATE OR REPLACE PROCEDURE PR_RECIBIR_TRASLADO (
    p_id_traslado IN NUMBER
)
IS
    v_lineas NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_lineas
    FROM DETALLE_TRASLADO
    WHERE ID_TRASLADO = p_id_traslado;

    IF v_lineas = 0 THEN
        RAISE_APPLICATION_ERROR(-20042, 'El traslado no existe o no tiene productos');
    END IF;

    UPDATE TRASLADO
    SET ID_ESTADO = FN_ID_ESTADO('TRASLADO', 'RECIBIDO')
    WHERE ID_TRASLADO = p_id_traslado;
END;
/

CREATE OR REPLACE PROCEDURE PR_CANCELAR_TRASLADO (
    p_id_traslado IN NUMBER
)
IS
BEGIN
    UPDATE TRASLADO
    SET ID_ESTADO = FN_ID_ESTADO('TRASLADO', 'CANCELADO')
    WHERE ID_TRASLADO = p_id_traslado;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20043, 'El traslado no existe');
    END IF;
END;
/

SELECT object_name, status FROM user_objects WHERE object_type = 'PROCEDURE' ORDER BY object_name;
