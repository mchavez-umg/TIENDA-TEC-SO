DECLARE
    v_fac NUMBER;
    v_nc  NUMBER;
    v_com NUMBER;
    v_tra NUMBER;
    v_gar NUMBER;
    v_aju NUMBER;

    FUNCTION FN_SUC (p_codigo VARCHAR2) RETURN NUMBER IS
        v NUMBER;
    BEGIN
        SELECT ID_SUCURSAL INTO v FROM SUCURSAL WHERE CODIGO = p_codigo;
        RETURN v;
    END;

    FUNCTION FN_PRO (p_codigo VARCHAR2) RETURN NUMBER IS
        v NUMBER;
    BEGIN
        SELECT ID_PRODUCTO INTO v FROM PRODUCTO WHERE CODIGO = p_codigo;
        RETURN v;
    END;

    FUNCTION FN_EMP (p_dpi VARCHAR2) RETURN NUMBER IS
        v NUMBER;
    BEGIN
        SELECT ID_EMPLEADO INTO v FROM EMPLEADO WHERE DPI = p_dpi;
        RETURN v;
    END;

    FUNCTION FN_CLI (p_nit VARCHAR2) RETURN NUMBER IS
        v NUMBER;
    BEGIN
        SELECT ID_CLIENTE INTO v FROM CLIENTE WHERE NIT = p_nit;
        RETURN v;
    END;

    FUNCTION FN_PRV (p_nit VARCHAR2) RETURN NUMBER IS
        v NUMBER;
    BEGIN
        SELECT ID_PROVEEDOR INTO v FROM PROVEEDOR WHERE NIT = p_nit;
        RETURN v;
    END;

    FUNCTION FN_FPA (p_nombre VARCHAR2) RETURN NUMBER IS
        v NUMBER;
    BEGIN
        SELECT ID_FORMA_PAGO INTO v FROM FORMA_PAGO WHERE NOMBRE = p_nombre;
        RETURN v;
    END;

    FUNCTION FN_BAN (p_nombre VARCHAR2) RETURN NUMBER IS
        v NUMBER;
    BEGIN
        SELECT ID_BANCO INTO v FROM BANCO WHERE NOMBRE = p_nombre;
        RETURN v;
    END;

    FUNCTION FN_DET (p_id_factura NUMBER, p_codigo VARCHAR2) RETURN NUMBER IS
        v NUMBER;
        v_producto NUMBER;
    BEGIN
        v_producto := FN_PRO(p_codigo);

        SELECT ID_DETALLE_FACTURA INTO v
        FROM DETALLE_FACTURA
        WHERE ID_FACTURA = p_id_factura
          AND ID_PRODUCTO = v_producto;
        RETURN v;
    END;

    PROCEDURE PR_VENDER (p_sucursal VARCHAR2, p_dpi VARCHAR2, p_nit VARCHAR2, p_dias NUMBER,
                         p_prod1 VARCHAR2, p_cant1 NUMBER, p_prod2 VARCHAR2, p_cant2 NUMBER,
                         p_forma VARCHAR2, p_id_factura OUT NUMBER) IS
        v_total NUMBER;
    BEGIN
        PR_CREAR_FACTURA(FN_SUC(p_sucursal), FN_CLI(p_nit), FN_EMP(p_dpi), p_id_factura);

        UPDATE FACTURA
        SET FECHA = TRUNC(SYSDATE) - p_dias + 10 / 24
        WHERE ID_FACTURA = p_id_factura;

        PR_AGREGAR_DETALLE_FACTURA(p_id_factura, FN_PRO(p_prod1), p_cant1);
        IF p_prod2 IS NOT NULL THEN
            PR_AGREGAR_DETALLE_FACTURA(p_id_factura, FN_PRO(p_prod2), p_cant2);
        END IF;

        SELECT TOTAL INTO v_total FROM FACTURA WHERE ID_FACTURA = p_id_factura;

        IF p_forma = 'EFECTIVO' THEN
            PR_REGISTRAR_PAGO(p_id_factura, FN_FPA('Efectivo'), v_total);
        ELSIF p_forma = 'TRANSFERENCIA' THEN
            PR_REGISTRAR_PAGO(p_id_factura, FN_FPA('Transferencia'), v_total, FN_BAN('Banco Industrial'), 'TRF-' || p_id_factura);
        ELSIF p_forma = 'TARJETA' THEN
            PR_REGISTRAR_PAGO(p_id_factura, FN_FPA('Tarjeta'), v_total, FN_BAN('BAC Credomatic'), NULL, 'AUT-' || p_id_factura);
        ELSE
            PR_REGISTRAR_PAGO(p_id_factura, FN_FPA('Efectivo'), 500);
            PR_REGISTRAR_PAGO(p_id_factura, FN_FPA('Tarjeta'), v_total - 500, FN_BAN('Banrural'), NULL, 'AUT-' || p_id_factura);
        END IF;

        PR_FINALIZAR_FACTURA(p_id_factura);
    END;

BEGIN
    PR_CREAR_COMPRA(FN_PRV('4567891'), FN_SUC('SUC-02'), FN_EMP('3569874120901'), 'FAC-A-1001', v_com);
    PR_AGREGAR_DETALLE_COMPRA(v_com, FN_PRO('PRD-0001'), 5, 4200);
    PR_AGREGAR_DETALLE_COMPRA(v_com, FN_PRO('PRD-0006'), 5, 2800);
    PR_RECIBIR_COMPRA(v_com);

    PR_CREAR_COMPRA(FN_PRV('3216549'), FN_SUC('SUC-03'), FN_EMP('3347851290301'), 'FAC-B-2001', v_com);
    PR_AGREGAR_DETALLE_COMPRA(v_com, FN_PRO('PRD-0007'), 3, 6800);
    PR_AGREGAR_DETALLE_COMPRA(v_com, FN_PRO('PRD-0010'), 10, 320);
    PR_RECIBIR_COMPRA(v_com);

    PR_CREAR_COMPRA(FN_PRV('6543217'), FN_SUC('SUC-01'), FN_EMP('2974185260101'), 'FAC-C-3001', v_com);
    PR_AGREGAR_DETALLE_COMPRA(v_com, FN_PRO('PRD-0008'), 10, 180);

    PR_CREAR_COMPRA(FN_PRV('6543217'), FN_SUC('SUC-02'), FN_EMP('3569874120901'), 'FAC-C-3002', v_com);
    PR_AGREGAR_DETALLE_COMPRA(v_com, FN_PRO('PRD-0009'), 6, 70);
    PR_ANULAR_COMPRA(v_com);

    PR_CREAR_TRASLADO(FN_SUC('SUC-01'), FN_SUC('SUC-02'), FN_EMP('2974185260101'), 'Reabastecimiento de celulares y monitores', v_tra);
    PR_AGREGAR_DETALLE_TRASLADO(v_tra, FN_PRO('PRD-0007'), 3);
    PR_AGREGAR_DETALLE_TRASLADO(v_tra, FN_PRO('PRD-0004'), 2);
    PR_RECIBIR_TRASLADO(v_tra);

    PR_CREAR_TRASLADO(FN_SUC('SUC-01'), FN_SUC('SUC-03'), FN_EMP('2974185260101'), 'Envío de monitores', v_tra);
    PR_AGREGAR_DETALLE_TRASLADO(v_tra, FN_PRO('PRD-0004'), 4);

    PR_CREAR_TRASLADO(FN_SUC('SUC-01'), FN_SUC('SUC-03'), FN_EMP('2974185260101'), 'Envío cancelado por error en pedido', v_tra);
    PR_AGREGAR_DETALLE_TRASLADO(v_tra, FN_PRO('PRD-0009'), 5);
    PR_CANCELAR_TRASLADO(v_tra);

    PR_VENDER('SUC-01', '2789654120101', 'CF', 175, 'PRD-0001', 1, 'PRD-0009', 1, 'EFECTIVO', v_fac);

    PR_VENDER('SUC-01', '2896541230101', '12345678', 160, 'PRD-0007', 1, NULL, NULL, 'TARJETA', v_fac);
    PKG_GARANTIAS.PR_REGISTRAR_RECLAMO(FN_DET(v_fac, 'PRD-0007'), FN_EMP('3015748960101'), 'La pantalla no enciende', v_gar);
    PKG_GARANTIAS.PR_PASAR_A_REVISION(v_gar);
    PKG_GARANTIAS.PR_RESOLVER_REPARACION(v_gar, 'Se reemplazó el conector de la pantalla');
    PKG_GARANTIAS.PR_ENTREGAR(v_gar);

    PR_VENDER('SUC-03', '3347851290301', '23456789', 150, 'PRD-0006', 1, 'PRD-0010', 1, 'MIXTO', v_fac);

    PR_VENDER('SUC-02', '3569874120901', '34567891', 140, 'PRD-0003', 1, 'PRD-0008', 1, 'TRANSFERENCIA', v_fac);
    PKG_GARANTIAS.PR_REGISTRAR_RECLAMO(FN_DET(v_fac, 'PRD-0003'), FN_EMP('3569874120901'), 'El equipo no carga la batería', v_gar);
    PKG_GARANTIAS.PR_PASAR_A_REVISION(v_gar);
    PKG_GARANTIAS.PR_RECHAZAR(v_gar, 'Daño por líquido, no cubierto por la garantía');
    PKG_GARANTIAS.PR_ENTREGAR(v_gar);

    PR_VENDER('SUC-01', '2789654120101', '23456789', 130, 'PRD-0003', 2, 'PRD-0004', 2, 'TRANSFERENCIA', v_fac);
    PKG_GARANTIAS.PR_REGISTRAR_RECLAMO(FN_DET(v_fac, 'PRD-0003'), FN_EMP('3015748960101'), 'Falla de tarjeta madre', v_gar);
    PKG_GARANTIAS.PR_PASAR_A_REVISION(v_gar);
    PKG_GARANTIAS.PR_RESOLVER_CAMBIO(v_gar, FN_PRO('PRD-0003'), 'Se cambió por un equipo nuevo');
    PKG_GARANTIAS.PR_ENTREGAR(v_gar);

    PR_VENDER('SUC-01', '2896541230101', 'CF', 120, 'PRD-0009', 4, 'PRD-0010', 2, 'EFECTIVO', v_fac);
    PR_CREAR_NOTA_CREDITO(v_fac, FN_EMP('2896541230101'), 'Devolución de mouse', v_nc);
    PR_AGREGAR_DETALLE_NC(v_nc, FN_DET(v_fac, 'PRD-0009'), 2, 'S');
    PR_FINALIZAR_NOTA_CREDITO(v_nc);
    PKG_VENTAS.PR_APLICAR_NOTA_CREDITO(v_nc);

    PR_VENDER('SUC-03', '3347851290301', 'CF', 110, 'PRD-0006', 1, NULL, NULL, 'EFECTIVO', v_fac);
    PR_CREAR_NOTA_CREDITO(v_fac, FN_EMP('3347851290301'), 'El cliente desistió de la compra', v_nc);
    PR_AGREGAR_DETALLE_NC(v_nc, FN_DET(v_fac, 'PRD-0006'), 1, 'S');
    PR_FINALIZAR_NOTA_CREDITO(v_nc);

    PR_VENDER('SUC-02', '3569874120901', '12345678', 90, 'PRD-0005', 1, 'PRD-0010', 1, 'TARJETA', v_fac);

    PR_VENDER('SUC-01', '2789654120101', '34567891', 75, 'PRD-0002', 1, NULL, NULL, 'TARJETA', v_fac);
    PKG_GARANTIAS.PR_REGISTRAR_RECLAMO(FN_DET(v_fac, 'PRD-0002'), FN_EMP('3015748960101'), 'El teclado tiene teclas que no responden', v_gar);
    PKG_GARANTIAS.PR_PASAR_A_REVISION(v_gar);

    PR_VENDER('SUC-03', '3347851290301', '12345678', 60, 'PRD-0002', 1, 'PRD-0009', 2, 'TRANSFERENCIA', v_fac);
    PKG_GARANTIAS.PR_REGISTRAR_RECLAMO(FN_DET(v_fac, 'PRD-0002'), FN_EMP('3347851290301'), 'Pantalla con píxeles muertos', v_gar);
    PKG_GARANTIAS.PR_PASAR_A_REVISION(v_gar);
    PKG_GARANTIAS.PR_RESOLVER_CAMBIO(v_gar, FN_PRO('PRD-0002'), 'Se cambió por una laptop nueva');

    PR_VENDER('SUC-01', '2896541230101', 'CF', 40, 'PRD-0005', 1, 'PRD-0008', 1, 'MIXTO', v_fac);
    PKG_GARANTIAS.PR_REGISTRAR_RECLAMO(FN_DET(v_fac, 'PRD-0005'), FN_EMP('3015748960101'), 'El monitor parpadea', v_gar);
    PR_CREAR_NOTA_CREDITO(v_fac, FN_EMP('2896541230101'), 'Combo de teclado dañado en la entrega', v_nc);
    PR_AGREGAR_DETALLE_NC(v_nc, FN_DET(v_fac, 'PRD-0008'), 1, 'N');
    PR_FINALIZAR_NOTA_CREDITO(v_nc);

    PR_VENDER('SUC-02', '3569874120901', 'CF', 25, 'PRD-0006', 1, NULL, NULL, 'EFECTIVO', v_fac);
    PR_VENDER('SUC-01', '2789654120101', 'CF', 10, 'PRD-0010', 2, NULL, NULL, 'EFECTIVO', v_fac);
    PR_VENDER('SUC-03', '3347851290301', '34567891', 3, 'PRD-0001', 1, NULL, NULL, 'MIXTO', v_fac);

    PKG_INVENTARIO.PR_REGISTRAR_AJUSTE(FN_SUC('SUC-01'), FN_PRO('PRD-0009'), FN_EMP('2974185260101'), 'SALIDA', 1, 'Producto dañado en exhibición', v_aju);
    PKG_INVENTARIO.PR_REGISTRAR_AJUSTE(FN_SUC('SUC-02'), FN_PRO('PRD-0008'), FN_EMP('3569874120901'), 'ENTRADA', 2, 'Diferencia en conteo físico', v_aju);
    PKG_INVENTARIO.PR_ANULAR_AJUSTE(v_aju);

    PKG_INVENTARIO.PR_DEFINIR_STOCK_MINIMO(FN_SUC('SUC-02'), FN_PRO('PRD-0007'), 15);
    PKG_INVENTARIO.PR_DEFINIR_STOCK_MINIMO(FN_SUC('SUC-02'), FN_PRO('PRD-0005'), 12);

    COMMIT;
END;
/

SELECT 'FACTURA' AS TABLA, COUNT(*) AS REGISTROS FROM FACTURA
UNION ALL SELECT 'PAGO', COUNT(*) FROM PAGO
UNION ALL SELECT 'NOTA_CREDITO', COUNT(*) FROM NOTA_CREDITO
UNION ALL SELECT 'GARANTIA', COUNT(*) FROM GARANTIA
UNION ALL SELECT 'COMPRA', COUNT(*) FROM COMPRA
UNION ALL SELECT 'TRASLADO', COUNT(*) FROM TRASLADO
UNION ALL SELECT 'AJUSTE_INVENTARIO', COUNT(*) FROM AJUSTE_INVENTARIO
UNION ALL SELECT 'KARDEX', COUNT(*) FROM KARDEX;
