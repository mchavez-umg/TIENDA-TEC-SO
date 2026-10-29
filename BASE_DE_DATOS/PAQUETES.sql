CREATE OR REPLACE PACKAGE PKG_SEGURIDAD AS
    FUNCTION FN_OBTENER_HASH (p_username IN VARCHAR2) RETURN VARCHAR2;
    PROCEDURE PR_LOGIN_EXITOSO (p_username IN VARCHAR2);
    PROCEDURE PR_LOGIN_FALLIDO (p_username IN VARCHAR2);
    PROCEDURE PR_CAMBIAR_PASSWORD (p_id_usuario IN NUMBER, p_hash_nuevo IN VARCHAR2);
    PROCEDURE PR_RESTABLECER_PASSWORD (p_id_usuario IN NUMBER, p_hash_nuevo IN VARCHAR2);
    FUNCTION FN_TIENE_PERMISO (p_id_usuario IN NUMBER, p_ruta IN VARCHAR2, p_accion IN VARCHAR2) RETURN VARCHAR2;
END PKG_SEGURIDAD;
/

CREATE OR REPLACE PACKAGE BODY PKG_SEGURIDAD AS

    FUNCTION FN_OBTENER_HASH (p_username IN VARCHAR2) RETURN VARCHAR2
    IS
        v_hash      USUARIO.PASSWORD_HASH%TYPE;
        v_id_estado USUARIO.ID_ESTADO%TYPE;
    BEGIN
        SELECT PASSWORD_HASH, ID_ESTADO INTO v_hash, v_id_estado
        FROM USUARIO
        WHERE USERNAME = p_username;

        IF v_id_estado <> FN_ID_ESTADO('USUARIO', 'A') THEN
            RAISE_APPLICATION_ERROR(-20051, 'El usuario está bloqueado o inactivo');
        END IF;

        RETURN v_hash;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20050, 'Usuario o contraseña incorrectos');
    END FN_OBTENER_HASH;

    PROCEDURE PR_LOGIN_EXITOSO (p_username IN VARCHAR2)
    IS
    BEGIN
        UPDATE USUARIO
        SET INTENTOS_FALLIDOS = 0,
            ULTIMO_ACCESO = SYSTIMESTAMP
        WHERE USERNAME = p_username;
    END PR_LOGIN_EXITOSO;

    PROCEDURE PR_LOGIN_FALLIDO (p_username IN VARCHAR2)
    IS
    BEGIN
        UPDATE USUARIO
        SET INTENTOS_FALLIDOS = INTENTOS_FALLIDOS + 1
        WHERE USERNAME = p_username;

        UPDATE USUARIO
        SET ID_ESTADO = FN_ID_ESTADO('USUARIO', 'B')
        WHERE USERNAME = p_username
          AND INTENTOS_FALLIDOS >= 3;
    END PR_LOGIN_FALLIDO;

    PROCEDURE PR_CAMBIAR_PASSWORD (p_id_usuario IN NUMBER, p_hash_nuevo IN VARCHAR2)
    IS
    BEGIN
        UPDATE USUARIO
        SET PASSWORD_HASH = p_hash_nuevo
        WHERE ID_USUARIO = p_id_usuario;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20052, 'El usuario no existe');
        END IF;
    END PR_CAMBIAR_PASSWORD;

    PROCEDURE PR_RESTABLECER_PASSWORD (p_id_usuario IN NUMBER, p_hash_nuevo IN VARCHAR2)
    IS
    BEGIN
        UPDATE USUARIO
        SET PASSWORD_HASH = p_hash_nuevo,
            INTENTOS_FALLIDOS = 0,
            ID_ESTADO = FN_ID_ESTADO('USUARIO', 'A')
        WHERE ID_USUARIO = p_id_usuario;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20052, 'El usuario no existe');
        END IF;
    END PR_RESTABLECER_PASSWORD;

    FUNCTION FN_TIENE_PERMISO (p_id_usuario IN NUMBER, p_ruta IN VARCHAR2, p_accion IN VARCHAR2) RETURN VARCHAR2
    IS
        v_consultar ROL_OPCION.PUEDE_CONSULTAR%TYPE;
        v_crear     ROL_OPCION.PUEDE_CREAR%TYPE;
        v_editar    ROL_OPCION.PUEDE_EDITAR%TYPE;
        v_eliminar  ROL_OPCION.PUEDE_ELIMINAR%TYPE;
    BEGIN
        SELECT RO.PUEDE_CONSULTAR, RO.PUEDE_CREAR, RO.PUEDE_EDITAR, RO.PUEDE_ELIMINAR
        INTO v_consultar, v_crear, v_editar, v_eliminar
        FROM USUARIO U
        JOIN ROL_OPCION RO ON RO.ID_ROL = U.ID_ROL
        JOIN OPCION_MENU O ON O.ID_OPCION = RO.ID_OPCION
        WHERE U.ID_USUARIO = p_id_usuario
          AND U.ID_ESTADO = FN_ID_ESTADO('USUARIO', 'A')
          AND O.RUTA = p_ruta;

        IF p_accion = 'C' THEN
            RETURN v_consultar;
        ELSIF p_accion = 'A' THEN
            RETURN v_crear;
        ELSIF p_accion = 'M' THEN
            RETURN v_editar;
        ELSIF p_accion = 'B' THEN
            RETURN v_eliminar;
        END IF;

        RETURN 'N';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'N';
    END FN_TIENE_PERMISO;

END PKG_SEGURIDAD;
/

CREATE OR REPLACE PACKAGE PKG_INVENTARIO AS
    PROCEDURE PR_REGISTRAR_AJUSTE (p_id_sucursal IN NUMBER, p_id_producto IN NUMBER, p_id_empleado IN NUMBER,
                                   p_tipo_ajuste IN VARCHAR2, p_cantidad IN NUMBER, p_motivo IN VARCHAR2, p_id_ajuste OUT NUMBER);
    PROCEDURE PR_ANULAR_AJUSTE (p_id_ajuste IN NUMBER);
    PROCEDURE PR_DEFINIR_STOCK_MINIMO (p_id_sucursal IN NUMBER, p_id_producto IN NUMBER, p_stock_minimo IN NUMBER);
END PKG_INVENTARIO;
/

CREATE OR REPLACE PACKAGE BODY PKG_INVENTARIO AS

    PROCEDURE PR_REGISTRAR_AJUSTE (p_id_sucursal IN NUMBER, p_id_producto IN NUMBER, p_id_empleado IN NUMBER,
                                   p_tipo_ajuste IN VARCHAR2, p_cantidad IN NUMBER, p_motivo IN VARCHAR2, p_id_ajuste OUT NUMBER)
    IS
    BEGIN
        p_id_ajuste := SEQ_AJUSTE_INVENTARIO.NEXTVAL;

        INSERT INTO AJUSTE_INVENTARIO (ID_AJUSTE, ID_SUCURSAL, ID_PRODUCTO, ID_EMPLEADO, TIPO_AJUSTE, CANTIDAD, MOTIVO, ID_ESTADO)
        VALUES (p_id_ajuste, p_id_sucursal, p_id_producto, p_id_empleado, p_tipo_ajuste, p_cantidad, p_motivo, FN_ID_ESTADO('AJUSTE_INVENTARIO', 'APLICADO'));
    END PR_REGISTRAR_AJUSTE;

    PROCEDURE PR_ANULAR_AJUSTE (p_id_ajuste IN NUMBER)
    IS
    BEGIN
        UPDATE AJUSTE_INVENTARIO
        SET ID_ESTADO = FN_ID_ESTADO('AJUSTE_INVENTARIO', 'ANULADO')
        WHERE ID_AJUSTE = p_id_ajuste;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20055, 'El ajuste no existe');
        END IF;
    END PR_ANULAR_AJUSTE;

    PROCEDURE PR_DEFINIR_STOCK_MINIMO (p_id_sucursal IN NUMBER, p_id_producto IN NUMBER, p_stock_minimo IN NUMBER)
    IS
    BEGIN
        UPDATE INVENTARIO
        SET STOCK_MINIMO = p_stock_minimo
        WHERE ID_SUCURSAL = p_id_sucursal
          AND ID_PRODUCTO = p_id_producto;

        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO INVENTARIO (ID_SUCURSAL, ID_PRODUCTO, EXISTENCIA, STOCK_MINIMO)
            VALUES (p_id_sucursal, p_id_producto, 0, p_stock_minimo);
        END IF;
    END PR_DEFINIR_STOCK_MINIMO;

END PKG_INVENTARIO;
/

CREATE OR REPLACE PACKAGE PKG_GARANTIAS AS
    PROCEDURE PR_REGISTRAR_RECLAMO (p_id_detalle_factura IN NUMBER, p_id_empleado IN NUMBER,
                                    p_descripcion_falla IN VARCHAR2, p_id_garantia OUT NUMBER);
    PROCEDURE PR_PASAR_A_REVISION (p_id_garantia IN NUMBER);
    PROCEDURE PR_RESOLVER_REPARACION (p_id_garantia IN NUMBER, p_observaciones IN VARCHAR2);
    PROCEDURE PR_RESOLVER_CAMBIO (p_id_garantia IN NUMBER, p_id_producto_reemplazo IN NUMBER, p_observaciones IN VARCHAR2);
    PROCEDURE PR_RECHAZAR (p_id_garantia IN NUMBER, p_observaciones IN VARCHAR2);
    PROCEDURE PR_ENTREGAR (p_id_garantia IN NUMBER);
END PKG_GARANTIAS;
/

CREATE OR REPLACE PACKAGE BODY PKG_GARANTIAS AS

    FUNCTION FN_CODIGO_ESTADO (p_id_garantia IN NUMBER) RETURN VARCHAR2
    IS
        v_codigo ESTADO.CODIGO%TYPE;
    BEGIN
        SELECT E.CODIGO INTO v_codigo
        FROM GARANTIA G
        JOIN ESTADO E ON E.ID_ESTADO = G.ID_ESTADO
        WHERE G.ID_GARANTIA = p_id_garantia;

        RETURN v_codigo;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20060, 'La garantía no existe');
    END FN_CODIGO_ESTADO;

    PROCEDURE PR_REGISTRAR_RECLAMO (p_id_detalle_factura IN NUMBER, p_id_empleado IN NUMBER,
                                    p_descripcion_falla IN VARCHAR2, p_id_garantia OUT NUMBER)
    IS
    BEGIN
        p_id_garantia := SEQ_GARANTIA.NEXTVAL;

        INSERT INTO GARANTIA (ID_GARANTIA, ID_DETALLE_FACTURA, ID_EMPLEADO, DESCRIPCION_FALLA, ID_ESTADO)
        VALUES (p_id_garantia, p_id_detalle_factura, p_id_empleado, p_descripcion_falla, FN_ID_ESTADO('GARANTIA', 'RECIBIDA'));
    END PR_REGISTRAR_RECLAMO;

    PROCEDURE PR_PASAR_A_REVISION (p_id_garantia IN NUMBER)
    IS
    BEGIN
        IF FN_CODIGO_ESTADO(p_id_garantia) <> 'RECIBIDA' THEN
            RAISE_APPLICATION_ERROR(-20061, 'Solo una garantía RECIBIDA pasa a revisión');
        END IF;

        UPDATE GARANTIA
        SET ID_ESTADO = FN_ID_ESTADO('GARANTIA', 'EN_REVISION')
        WHERE ID_GARANTIA = p_id_garantia;
    END PR_PASAR_A_REVISION;

    PROCEDURE PR_RESOLVER_REPARACION (p_id_garantia IN NUMBER, p_observaciones IN VARCHAR2)
    IS
    BEGIN
        IF FN_CODIGO_ESTADO(p_id_garantia) <> 'EN_REVISION' THEN
            RAISE_APPLICATION_ERROR(-20062, 'Solo una garantía EN_REVISION se puede resolver');
        END IF;

        UPDATE GARANTIA
        SET TIPO_RESOLUCION = 'REPARACION',
            FECHA_RESOLUCION = SYSDATE,
            OBSERVACIONES = p_observaciones,
            ID_ESTADO = FN_ID_ESTADO('GARANTIA', 'REPARADA')
        WHERE ID_GARANTIA = p_id_garantia;
    END PR_RESOLVER_REPARACION;

    PROCEDURE PR_RESOLVER_CAMBIO (p_id_garantia IN NUMBER, p_id_producto_reemplazo IN NUMBER, p_observaciones IN VARCHAR2)
    IS
    BEGIN
        IF FN_CODIGO_ESTADO(p_id_garantia) <> 'EN_REVISION' THEN
            RAISE_APPLICATION_ERROR(-20062, 'Solo una garantía EN_REVISION se puede resolver');
        END IF;

        UPDATE GARANTIA
        SET TIPO_RESOLUCION = 'CAMBIO',
            ID_PRODUCTO_REEMPLAZO = p_id_producto_reemplazo,
            FECHA_RESOLUCION = SYSDATE,
            OBSERVACIONES = p_observaciones,
            ID_ESTADO = FN_ID_ESTADO('GARANTIA', 'CAMBIADA')
        WHERE ID_GARANTIA = p_id_garantia;
    END PR_RESOLVER_CAMBIO;

    PROCEDURE PR_RECHAZAR (p_id_garantia IN NUMBER, p_observaciones IN VARCHAR2)
    IS
    BEGIN
        IF FN_CODIGO_ESTADO(p_id_garantia) <> 'EN_REVISION' THEN
            RAISE_APPLICATION_ERROR(-20062, 'Solo una garantía EN_REVISION se puede resolver');
        END IF;

        UPDATE GARANTIA
        SET FECHA_RESOLUCION = SYSDATE,
            OBSERVACIONES = p_observaciones,
            ID_ESTADO = FN_ID_ESTADO('GARANTIA', 'RECHAZADA')
        WHERE ID_GARANTIA = p_id_garantia;
    END PR_RECHAZAR;

    PROCEDURE PR_ENTREGAR (p_id_garantia IN NUMBER)
    IS
    BEGIN
        IF FN_CODIGO_ESTADO(p_id_garantia) NOT IN ('REPARADA', 'CAMBIADA', 'RECHAZADA') THEN
            RAISE_APPLICATION_ERROR(-20063, 'Solo se entrega una garantía ya resuelta');
        END IF;

        UPDATE GARANTIA
        SET ID_ESTADO = FN_ID_ESTADO('GARANTIA', 'ENTREGADA')
        WHERE ID_GARANTIA = p_id_garantia;
    END PR_ENTREGAR;

END PKG_GARANTIAS;
/

CREATE OR REPLACE PACKAGE PKG_VENTAS AS
    PROCEDURE PR_APLICAR_NOTA_CREDITO (p_id_nota_credito IN NUMBER);
    FUNCTION FN_TOTAL_VENDIDO (p_desde IN DATE, p_hasta IN DATE, p_id_sucursal IN NUMBER DEFAULT NULL) RETURN NUMBER;
    FUNCTION FN_NUMERO_FACTURAS (p_desde IN DATE, p_hasta IN DATE, p_id_sucursal IN NUMBER DEFAULT NULL) RETURN NUMBER;
    FUNCTION FN_TICKET_PROMEDIO (p_desde IN DATE, p_hasta IN DATE, p_id_sucursal IN NUMBER DEFAULT NULL) RETURN NUMBER;
    FUNCTION FN_MONTO_NOTAS_CREDITO (p_desde IN DATE, p_hasta IN DATE, p_id_sucursal IN NUMBER DEFAULT NULL) RETURN NUMBER;
    FUNCTION FN_GARANTIAS_ABIERTAS (p_id_sucursal IN NUMBER DEFAULT NULL) RETURN NUMBER;
END PKG_VENTAS;
/

CREATE OR REPLACE PACKAGE BODY PKG_VENTAS AS

    PROCEDURE PR_APLICAR_NOTA_CREDITO (p_id_nota_credito IN NUMBER)
    IS
        v_id_estado NOTA_CREDITO.ID_ESTADO%TYPE;
    BEGIN
        SELECT ID_ESTADO INTO v_id_estado
        FROM NOTA_CREDITO
        WHERE ID_NOTA_CREDITO = p_id_nota_credito;

        IF v_id_estado <> FN_ID_ESTADO('NOTA_CREDITO', 'EMITIDA') THEN
            RAISE_APPLICATION_ERROR(-20070, 'Solo una nota de crédito EMITIDA se puede aplicar');
        END IF;

        UPDATE NOTA_CREDITO
        SET ID_ESTADO = FN_ID_ESTADO('NOTA_CREDITO', 'APLICADA')
        WHERE ID_NOTA_CREDITO = p_id_nota_credito;
    END PR_APLICAR_NOTA_CREDITO;

    FUNCTION FN_TOTAL_VENDIDO (p_desde IN DATE, p_hasta IN DATE, p_id_sucursal IN NUMBER DEFAULT NULL) RETURN NUMBER
    IS
        v_total NUMBER;
    BEGIN
        SELECT NVL(SUM(TOTAL), 0) INTO v_total
        FROM FACTURA
        WHERE TRUNC(FECHA) BETWEEN TRUNC(p_desde) AND TRUNC(p_hasta)
          AND (p_id_sucursal IS NULL OR ID_SUCURSAL = p_id_sucursal)
          AND ID_ESTADO <> FN_ID_ESTADO('FACTURA', 'NC_TOTAL');

        RETURN v_total;
    END FN_TOTAL_VENDIDO;

    FUNCTION FN_NUMERO_FACTURAS (p_desde IN DATE, p_hasta IN DATE, p_id_sucursal IN NUMBER DEFAULT NULL) RETURN NUMBER
    IS
        v_numero NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_numero
        FROM FACTURA
        WHERE TRUNC(FECHA) BETWEEN TRUNC(p_desde) AND TRUNC(p_hasta)
          AND (p_id_sucursal IS NULL OR ID_SUCURSAL = p_id_sucursal)
          AND ID_ESTADO <> FN_ID_ESTADO('FACTURA', 'NC_TOTAL');

        RETURN v_numero;
    END FN_NUMERO_FACTURAS;

    FUNCTION FN_TICKET_PROMEDIO (p_desde IN DATE, p_hasta IN DATE, p_id_sucursal IN NUMBER DEFAULT NULL) RETURN NUMBER
    IS
        v_numero NUMBER;
    BEGIN
        v_numero := FN_NUMERO_FACTURAS(p_desde, p_hasta, p_id_sucursal);

        IF v_numero = 0 THEN
            RETURN 0;
        END IF;

        RETURN ROUND(FN_TOTAL_VENDIDO(p_desde, p_hasta, p_id_sucursal) / v_numero, 2);
    END FN_TICKET_PROMEDIO;

    FUNCTION FN_MONTO_NOTAS_CREDITO (p_desde IN DATE, p_hasta IN DATE, p_id_sucursal IN NUMBER DEFAULT NULL) RETURN NUMBER
    IS
        v_total NUMBER;
    BEGIN
        SELECT NVL(SUM(N.TOTAL), 0) INTO v_total
        FROM NOTA_CREDITO N
        JOIN FACTURA F ON F.ID_FACTURA = N.ID_FACTURA
        WHERE TRUNC(N.FECHA) BETWEEN TRUNC(p_desde) AND TRUNC(p_hasta)
          AND (p_id_sucursal IS NULL OR F.ID_SUCURSAL = p_id_sucursal);

        RETURN v_total;
    END FN_MONTO_NOTAS_CREDITO;

    FUNCTION FN_GARANTIAS_ABIERTAS (p_id_sucursal IN NUMBER DEFAULT NULL) RETURN NUMBER
    IS
        v_numero NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_numero
        FROM GARANTIA G
        JOIN ESTADO E ON E.ID_ESTADO = G.ID_ESTADO
        JOIN DETALLE_FACTURA D ON D.ID_DETALLE_FACTURA = G.ID_DETALLE_FACTURA
        JOIN FACTURA F ON F.ID_FACTURA = D.ID_FACTURA
        WHERE E.CODIGO IN ('RECIBIDA', 'EN_REVISION')
          AND (p_id_sucursal IS NULL OR F.ID_SUCURSAL = p_id_sucursal);

        RETURN v_numero;
    END FN_GARANTIAS_ABIERTAS;

END PKG_VENTAS;
/

SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
ORDER BY object_name, object_type;
