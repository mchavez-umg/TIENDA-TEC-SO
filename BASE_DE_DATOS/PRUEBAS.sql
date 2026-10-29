SET SERVEROUTPUT ON;

DECLARE
    v_suc NUMBER;
    v_cli NUMBER;
    v_emp NUMBER;
    v_pro NUMBER;
    v_fac NUMBER;
BEGIN
    SELECT ID_SUCURSAL INTO v_suc FROM SUCURSAL WHERE CODIGO = 'SUC-01';
    SELECT ID_CLIENTE INTO v_cli FROM CLIENTE WHERE NIT = 'CF';
    SELECT ID_EMPLEADO INTO v_emp FROM EMPLEADO WHERE DPI = '2789654120101';
    SELECT ID_PRODUCTO INTO v_pro FROM PRODUCTO WHERE CODIGO = 'PRD-0009';

    PR_CREAR_FACTURA(v_suc, v_cli, v_emp, v_fac);
    PR_AGREGAR_DETALLE_FACTURA(v_fac, v_pro, 9999);

    DBMS_OUTPUT.PUT_LINE('FALLA 1: se vendió más de la existencia');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20020 THEN
            DBMS_OUTPUT.PUT_LINE('OK 1: no se vende más de la existencia');
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALLA 1: ' || SQLERRM);
        END IF;
        ROLLBACK;
END;
/

DECLARE
    v_suc NUMBER;
    v_cli NUMBER;
    v_emp NUMBER;
    v_pro NUMBER;
    v_fpa NUMBER;
    v_fac NUMBER;
BEGIN
    SELECT ID_SUCURSAL INTO v_suc FROM SUCURSAL WHERE CODIGO = 'SUC-01';
    SELECT ID_CLIENTE INTO v_cli FROM CLIENTE WHERE NIT = 'CF';
    SELECT ID_EMPLEADO INTO v_emp FROM EMPLEADO WHERE DPI = '2789654120101';
    SELECT ID_PRODUCTO INTO v_pro FROM PRODUCTO WHERE CODIGO = 'PRD-0009';
    SELECT ID_FORMA_PAGO INTO v_fpa FROM FORMA_PAGO WHERE NOMBRE = 'Efectivo';

    PR_CREAR_FACTURA(v_suc, v_cli, v_emp, v_fac);
    PR_AGREGAR_DETALLE_FACTURA(v_fac, v_pro, 1);
    PR_REGISTRAR_PAGO(v_fac, v_fpa, 100000);

    DBMS_OUTPUT.PUT_LINE('FALLA 2: se pagó más que el total');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20035 THEN
            DBMS_OUTPUT.PUT_LINE('OK 2: los pagos no superan el total');
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALLA 2: ' || SQLERRM);
        END IF;
        ROLLBACK;
END;
/

DECLARE
    v_suc NUMBER;
    v_cli NUMBER;
    v_emp NUMBER;
    v_pro NUMBER;
    v_fpa NUMBER;
    v_fac NUMBER;
BEGIN
    SELECT ID_SUCURSAL INTO v_suc FROM SUCURSAL WHERE CODIGO = 'SUC-01';
    SELECT ID_CLIENTE INTO v_cli FROM CLIENTE WHERE NIT = 'CF';
    SELECT ID_EMPLEADO INTO v_emp FROM EMPLEADO WHERE DPI = '2789654120101';
    SELECT ID_PRODUCTO INTO v_pro FROM PRODUCTO WHERE CODIGO = 'PRD-0009';
    SELECT ID_FORMA_PAGO INTO v_fpa FROM FORMA_PAGO WHERE NOMBRE = 'Transferencia';

    PR_CREAR_FACTURA(v_suc, v_cli, v_emp, v_fac);
    PR_AGREGAR_DETALLE_FACTURA(v_fac, v_pro, 1);
    PR_REGISTRAR_PAGO(v_fac, v_fpa, 109);

    DBMS_OUTPUT.PUT_LINE('FALLA 3: se aceptó una transferencia sin banco ni referencia');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20033 THEN
            DBMS_OUTPUT.PUT_LINE('OK 3: la transferencia exige banco y referencia');
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALLA 3: ' || SQLERRM);
        END IF;
        ROLLBACK;
END;
/

DECLARE
    v_suc NUMBER;
    v_cli NUMBER;
    v_emp NUMBER;
    v_pro NUMBER;
    v_fac NUMBER;
BEGIN
    SELECT ID_SUCURSAL INTO v_suc FROM SUCURSAL WHERE CODIGO = 'SUC-01';
    SELECT ID_CLIENTE INTO v_cli FROM CLIENTE WHERE NIT = 'CF';
    SELECT ID_EMPLEADO INTO v_emp FROM EMPLEADO WHERE DPI = '2789654120101';
    SELECT ID_PRODUCTO INTO v_pro FROM PRODUCTO WHERE CODIGO = 'PRD-0009';

    PR_CREAR_FACTURA(v_suc, v_cli, v_emp, v_fac);
    PR_AGREGAR_DETALLE_FACTURA(v_fac, v_pro, 1);
    PR_FINALIZAR_FACTURA(v_fac);

    DBMS_OUTPUT.PUT_LINE('FALLA 4: se finalizó una factura sin pagos');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20037 THEN
            DBMS_OUTPUT.PUT_LINE('OK 4: una factura sin pagos completos no se finaliza');
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALLA 4: ' || SQLERRM);
        END IF;
        ROLLBACK;
END;
/

DECLARE
    v_suc NUMBER;
    v_cli NUMBER;
    v_emp NUMBER;
    v_pro NUMBER;
    v_fpa NUMBER;
    v_fac NUMBER;
    v_det NUMBER;
    v_nc  NUMBER;
BEGIN
    SELECT ID_SUCURSAL INTO v_suc FROM SUCURSAL WHERE CODIGO = 'SUC-01';
    SELECT ID_CLIENTE INTO v_cli FROM CLIENTE WHERE NIT = 'CF';
    SELECT ID_EMPLEADO INTO v_emp FROM EMPLEADO WHERE DPI = '2789654120101';
    SELECT ID_PRODUCTO INTO v_pro FROM PRODUCTO WHERE CODIGO = 'PRD-0009';
    SELECT ID_FORMA_PAGO INTO v_fpa FROM FORMA_PAGO WHERE NOMBRE = 'Efectivo';

    PR_CREAR_FACTURA(v_suc, v_cli, v_emp, v_fac);
    PR_AGREGAR_DETALLE_FACTURA(v_fac, v_pro, 1);
    PR_REGISTRAR_PAGO(v_fac, v_fpa, 109);
    SELECT ID_DETALLE_FACTURA INTO v_det FROM DETALLE_FACTURA WHERE ID_FACTURA = v_fac;

    PR_CREAR_NOTA_CREDITO(v_fac, v_emp, 'Prueba', v_nc);
    PR_AGREGAR_DETALLE_NC(v_nc, v_det, 5);

    DBMS_OUTPUT.PUT_LINE('FALLA 5: se devolvió más de lo vendido');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20022 THEN
            DBMS_OUTPUT.PUT_LINE('OK 5: no se devuelve más de lo vendido');
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALLA 5: ' || SQLERRM);
        END IF;
        ROLLBACK;
END;
/

DECLARE
    v_suc NUMBER;
    v_cli NUMBER;
    v_emp NUMBER;
    v_pro NUMBER;
    v_fpa NUMBER;
    v_fac NUMBER;
    v_det NUMBER;
    v_nc  NUMBER;
    v_gar NUMBER;
BEGIN
    SELECT ID_SUCURSAL INTO v_suc FROM SUCURSAL WHERE CODIGO = 'SUC-01';
    SELECT ID_CLIENTE INTO v_cli FROM CLIENTE WHERE NIT = 'CF';
    SELECT ID_EMPLEADO INTO v_emp FROM EMPLEADO WHERE DPI = '2789654120101';
    SELECT ID_PRODUCTO INTO v_pro FROM PRODUCTO WHERE CODIGO = 'PRD-0009';
    SELECT ID_FORMA_PAGO INTO v_fpa FROM FORMA_PAGO WHERE NOMBRE = 'Efectivo';

    PR_CREAR_FACTURA(v_suc, v_cli, v_emp, v_fac);
    PR_AGREGAR_DETALLE_FACTURA(v_fac, v_pro, 1);
    PR_REGISTRAR_PAGO(v_fac, v_fpa, 109);
    SELECT ID_DETALLE_FACTURA INTO v_det FROM DETALLE_FACTURA WHERE ID_FACTURA = v_fac;

    PR_CREAR_NOTA_CREDITO(v_fac, v_emp, 'Prueba', v_nc);
    PR_AGREGAR_DETALLE_NC(v_nc, v_det, 1);
    PKG_GARANTIAS.PR_REGISTRAR_RECLAMO(v_det, v_emp, 'Prueba', v_gar);

    DBMS_OUTPUT.PUT_LINE('FALLA 6: se aceptó garantía de un producto devuelto');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20029 THEN
            DBMS_OUTPUT.PUT_LINE('OK 6: no hay garantía de un producto devuelto');
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALLA 6: ' || SQLERRM);
        END IF;
        ROLLBACK;
END;
/

DECLARE
    v_suc NUMBER;
    v_cli NUMBER;
    v_emp NUMBER;
    v_pro NUMBER;
    v_fpa NUMBER;
    v_fac NUMBER;
    v_det NUMBER;
    v_nc  NUMBER;
BEGIN
    SELECT ID_SUCURSAL INTO v_suc FROM SUCURSAL WHERE CODIGO = 'SUC-01';
    SELECT ID_CLIENTE INTO v_cli FROM CLIENTE WHERE NIT = 'CF';
    SELECT ID_EMPLEADO INTO v_emp FROM EMPLEADO WHERE DPI = '2789654120101';
    SELECT ID_PRODUCTO INTO v_pro FROM PRODUCTO WHERE CODIGO = 'PRD-0009';
    SELECT ID_FORMA_PAGO INTO v_fpa FROM FORMA_PAGO WHERE NOMBRE = 'Efectivo';

    PR_CREAR_FACTURA(v_suc, v_cli, v_emp, v_fac);
    PR_AGREGAR_DETALLE_FACTURA(v_fac, v_pro, 2);
    PR_REGISTRAR_PAGO(v_fac, v_fpa, 218);
    SELECT ID_DETALLE_FACTURA INTO v_det FROM DETALLE_FACTURA WHERE ID_FACTURA = v_fac;

    PR_CREAR_NOTA_CREDITO(v_fac, v_emp, 'Prueba', v_nc);
    PR_AGREGAR_DETALLE_NC(v_nc, v_det, 1);
    PKG_VENTAS.PR_APLICAR_NOTA_CREDITO(v_nc);
    PR_AGREGAR_DETALLE_NC(v_nc, v_det, 1);

    DBMS_OUTPUT.PUT_LINE('FALLA 7: se modificó una nota de crédito aplicada');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20044 THEN
            DBMS_OUTPUT.PUT_LINE('OK 7: una nota de crédito aplicada no se modifica');
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALLA 7: ' || SQLERRM);
        END IF;
        ROLLBACK;
END;
/

DECLARE
    v_fac NUMBER;
BEGIN
    SELECT MIN(ID_FACTURA) INTO v_fac FROM FACTURA;

    DELETE FROM FACTURA WHERE ID_FACTURA = v_fac;

    DBMS_OUTPUT.PUT_LINE('FALLA 8: se eliminó una factura');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20004 THEN
            DBMS_OUTPUT.PUT_LINE('OK 8: una factura no se elimina');
        ELSE
            DBMS_OUTPUT.PUT_LINE('FALLA 8: ' || SQLERRM);
        END IF;
        ROLLBACK;
END;
/
