CREATE OR REPLACE TRIGGER TRG_ESTADO
BEFORE INSERT OR UPDATE OR DELETE ON ESTADO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_ESTADO IS NULL THEN
            :NEW.ID_ESTADO := SEQ_ESTADO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_ESTADO=' || :NEW.ID_ESTADO
                  || ', ENTIDAD=' || :NEW.ENTIDAD
                  || ', CODIGO=' || :NEW.CODIGO
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', DESCRIPCION=' || :NEW.DESCRIPCION;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_ESTADO=' || :OLD.ID_ESTADO
                  || ', ENTIDAD=' || :OLD.ENTIDAD
                  || ', CODIGO=' || :OLD.CODIGO
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', DESCRIPCION=' || :OLD.DESCRIPCION;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('ESTADO', v_operacion, NVL(:NEW.ID_ESTADO, :OLD.ID_ESTADO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_DEPARTAMENTO
BEFORE INSERT OR UPDATE OR DELETE ON DEPARTAMENTO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_DEPARTAMENTO IS NULL THEN
            :NEW.ID_DEPARTAMENTO := SEQ_DEPARTAMENTO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'DEPARTAMENTO';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a DEPARTAMENTO');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_DEPARTAMENTO=' || :NEW.ID_DEPARTAMENTO
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_DEPARTAMENTO=' || :OLD.ID_DEPARTAMENTO
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('DEPARTAMENTO', v_operacion, NVL(:NEW.ID_DEPARTAMENTO, :OLD.ID_DEPARTAMENTO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_MUNICIPIO
BEFORE INSERT OR UPDATE OR DELETE ON MUNICIPIO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_MUNICIPIO IS NULL THEN
            :NEW.ID_MUNICIPIO := SEQ_MUNICIPIO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'MUNICIPIO';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a MUNICIPIO');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_MUNICIPIO=' || :NEW.ID_MUNICIPIO
                  || ', ID_DEPARTAMENTO=' || :NEW.ID_DEPARTAMENTO
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', ES_CABECERA=' || :NEW.ES_CABECERA
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_MUNICIPIO=' || :OLD.ID_MUNICIPIO
                  || ', ID_DEPARTAMENTO=' || :OLD.ID_DEPARTAMENTO
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', ES_CABECERA=' || :OLD.ES_CABECERA
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('MUNICIPIO', v_operacion, NVL(:NEW.ID_MUNICIPIO, :OLD.ID_MUNICIPIO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_SUCURSAL
BEFORE INSERT OR UPDATE OR DELETE ON SUCURSAL
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_SUCURSAL IS NULL THEN
            :NEW.ID_SUCURSAL := SEQ_SUCURSAL.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'SUCURSAL';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a SUCURSAL');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_SUCURSAL=' || :NEW.ID_SUCURSAL
                  || ', ID_MUNICIPIO=' || :NEW.ID_MUNICIPIO
                  || ', CODIGO=' || :NEW.CODIGO
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', DIRECCION=' || :NEW.DIRECCION
                  || ', TELEFONO=' || :NEW.TELEFONO
                  || ', CORREO=' || :NEW.CORREO
                  || ', FECHA_APERTURA=' || TO_CHAR(:NEW.FECHA_APERTURA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_SUCURSAL=' || :OLD.ID_SUCURSAL
                  || ', ID_MUNICIPIO=' || :OLD.ID_MUNICIPIO
                  || ', CODIGO=' || :OLD.CODIGO
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', DIRECCION=' || :OLD.DIRECCION
                  || ', TELEFONO=' || :OLD.TELEFONO
                  || ', CORREO=' || :OLD.CORREO
                  || ', FECHA_APERTURA=' || TO_CHAR(:OLD.FECHA_APERTURA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('SUCURSAL', v_operacion, NVL(:NEW.ID_SUCURSAL, :OLD.ID_SUCURSAL), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_PUESTO
BEFORE INSERT OR UPDATE OR DELETE ON PUESTO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_PUESTO IS NULL THEN
            :NEW.ID_PUESTO := SEQ_PUESTO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'PUESTO';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a PUESTO');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_PUESTO=' || :NEW.ID_PUESTO
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', DESCRIPCION=' || :NEW.DESCRIPCION
                  || ', SALARIO_BASE=' || :NEW.SALARIO_BASE
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_PUESTO=' || :OLD.ID_PUESTO
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', DESCRIPCION=' || :OLD.DESCRIPCION
                  || ', SALARIO_BASE=' || :OLD.SALARIO_BASE
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('PUESTO', v_operacion, NVL(:NEW.ID_PUESTO, :OLD.ID_PUESTO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_HORARIO
BEFORE INSERT OR UPDATE OR DELETE ON HORARIO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_HORARIO IS NULL THEN
            :NEW.ID_HORARIO := SEQ_HORARIO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'HORARIO';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a HORARIO');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_HORARIO=' || :NEW.ID_HORARIO
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', HORA_ENTRADA=' || :NEW.HORA_ENTRADA
                  || ', HORA_SALIDA=' || :NEW.HORA_SALIDA
                  || ', DIAS_SEMANA=' || :NEW.DIAS_SEMANA
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_HORARIO=' || :OLD.ID_HORARIO
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', HORA_ENTRADA=' || :OLD.HORA_ENTRADA
                  || ', HORA_SALIDA=' || :OLD.HORA_SALIDA
                  || ', DIAS_SEMANA=' || :OLD.DIAS_SEMANA
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('HORARIO', v_operacion, NVL(:NEW.ID_HORARIO, :OLD.ID_HORARIO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_EMPLEADO
BEFORE INSERT OR UPDATE OR DELETE ON EMPLEADO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_EMPLEADO IS NULL THEN
            :NEW.ID_EMPLEADO := SEQ_EMPLEADO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'EMPLEADO';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a EMPLEADO');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_EMPLEADO=' || :NEW.ID_EMPLEADO
                  || ', ID_SUCURSAL=' || :NEW.ID_SUCURSAL
                  || ', ID_PUESTO=' || :NEW.ID_PUESTO
                  || ', DPI=' || :NEW.DPI
                  || ', NOMBRES=' || :NEW.NOMBRES
                  || ', APELLIDOS=' || :NEW.APELLIDOS
                  || ', TELEFONO=' || :NEW.TELEFONO
                  || ', CORREO=' || :NEW.CORREO
                  || ', DIRECCION=' || :NEW.DIRECCION
                  || ', FECHA_INGRESO=' || TO_CHAR(:NEW.FECHA_INGRESO, 'YYYY-MM-DD HH24:MI:SS')
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_EMPLEADO=' || :OLD.ID_EMPLEADO
                  || ', ID_SUCURSAL=' || :OLD.ID_SUCURSAL
                  || ', ID_PUESTO=' || :OLD.ID_PUESTO
                  || ', DPI=' || :OLD.DPI
                  || ', NOMBRES=' || :OLD.NOMBRES
                  || ', APELLIDOS=' || :OLD.APELLIDOS
                  || ', TELEFONO=' || :OLD.TELEFONO
                  || ', CORREO=' || :OLD.CORREO
                  || ', DIRECCION=' || :OLD.DIRECCION
                  || ', FECHA_INGRESO=' || TO_CHAR(:OLD.FECHA_INGRESO, 'YYYY-MM-DD HH24:MI:SS')
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('EMPLEADO', v_operacion, NVL(:NEW.ID_EMPLEADO, :OLD.ID_EMPLEADO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_EMPLEADO_HORARIO
BEFORE INSERT OR UPDATE OR DELETE ON EMPLEADO_HORARIO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_EMPLEADO_HORARIO IS NULL THEN
            :NEW.ID_EMPLEADO_HORARIO := SEQ_EMPLEADO_HORARIO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'EMPLEADO_HORARIO';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a EMPLEADO_HORARIO');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_EMPLEADO_HORARIO=' || :NEW.ID_EMPLEADO_HORARIO
                  || ', ID_EMPLEADO=' || :NEW.ID_EMPLEADO
                  || ', ID_HORARIO=' || :NEW.ID_HORARIO
                  || ', FECHA_INICIO=' || TO_CHAR(:NEW.FECHA_INICIO, 'YYYY-MM-DD HH24:MI:SS')
                  || ', FECHA_FIN=' || TO_CHAR(:NEW.FECHA_FIN, 'YYYY-MM-DD HH24:MI:SS')
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_EMPLEADO_HORARIO=' || :OLD.ID_EMPLEADO_HORARIO
                  || ', ID_EMPLEADO=' || :OLD.ID_EMPLEADO
                  || ', ID_HORARIO=' || :OLD.ID_HORARIO
                  || ', FECHA_INICIO=' || TO_CHAR(:OLD.FECHA_INICIO, 'YYYY-MM-DD HH24:MI:SS')
                  || ', FECHA_FIN=' || TO_CHAR(:OLD.FECHA_FIN, 'YYYY-MM-DD HH24:MI:SS')
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('EMPLEADO_HORARIO', v_operacion, NVL(:NEW.ID_EMPLEADO_HORARIO, :OLD.ID_EMPLEADO_HORARIO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_ROL
BEFORE INSERT OR UPDATE OR DELETE ON ROL
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_ROL IS NULL THEN
            :NEW.ID_ROL := SEQ_ROL.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'ROL';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a ROL');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_ROL=' || :NEW.ID_ROL
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', DESCRIPCION=' || :NEW.DESCRIPCION
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_ROL=' || :OLD.ID_ROL
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', DESCRIPCION=' || :OLD.DESCRIPCION
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('ROL', v_operacion, NVL(:NEW.ID_ROL, :OLD.ID_ROL), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_USUARIO
BEFORE INSERT OR UPDATE OR DELETE ON USUARIO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_USUARIO IS NULL THEN
            :NEW.ID_USUARIO := SEQ_USUARIO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'USUARIO';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a USUARIO');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_USUARIO=' || :NEW.ID_USUARIO
                  || ', ID_EMPLEADO=' || :NEW.ID_EMPLEADO
                  || ', ID_ROL=' || :NEW.ID_ROL
                  || ', USERNAME=' || :NEW.USERNAME
                  || ', PASSWORD_HASH=' || :NEW.PASSWORD_HASH
                  || ', INTENTOS_FALLIDOS=' || :NEW.INTENTOS_FALLIDOS
                  || ', ULTIMO_ACCESO=' || TO_CHAR(:NEW.ULTIMO_ACCESO, 'YYYY-MM-DD HH24:MI:SS')
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_USUARIO=' || :OLD.ID_USUARIO
                  || ', ID_EMPLEADO=' || :OLD.ID_EMPLEADO
                  || ', ID_ROL=' || :OLD.ID_ROL
                  || ', USERNAME=' || :OLD.USERNAME
                  || ', PASSWORD_HASH=' || :OLD.PASSWORD_HASH
                  || ', INTENTOS_FALLIDOS=' || :OLD.INTENTOS_FALLIDOS
                  || ', ULTIMO_ACCESO=' || TO_CHAR(:OLD.ULTIMO_ACCESO, 'YYYY-MM-DD HH24:MI:SS')
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('USUARIO', v_operacion, NVL(:NEW.ID_USUARIO, :OLD.ID_USUARIO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_OPCION_MENU
BEFORE INSERT OR UPDATE OR DELETE ON OPCION_MENU
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_OPCION IS NULL THEN
            :NEW.ID_OPCION := SEQ_OPCION_MENU.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'OPCION_MENU';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a OPCION_MENU');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_OPCION=' || :NEW.ID_OPCION
                  || ', ID_OPCION_PADRE=' || :NEW.ID_OPCION_PADRE
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', RUTA=' || :NEW.RUTA
                  || ', ICONO=' || :NEW.ICONO
                  || ', ORDEN=' || :NEW.ORDEN
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_OPCION=' || :OLD.ID_OPCION
                  || ', ID_OPCION_PADRE=' || :OLD.ID_OPCION_PADRE
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', RUTA=' || :OLD.RUTA
                  || ', ICONO=' || :OLD.ICONO
                  || ', ORDEN=' || :OLD.ORDEN
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('OPCION_MENU', v_operacion, NVL(:NEW.ID_OPCION, :OLD.ID_OPCION), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_ROL_OPCION
BEFORE INSERT OR UPDATE OR DELETE ON ROL_OPCION
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_ROL_OPCION IS NULL THEN
            :NEW.ID_ROL_OPCION := SEQ_ROL_OPCION.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_ROL_OPCION=' || :NEW.ID_ROL_OPCION
                  || ', ID_ROL=' || :NEW.ID_ROL
                  || ', ID_OPCION=' || :NEW.ID_OPCION
                  || ', PUEDE_CONSULTAR=' || :NEW.PUEDE_CONSULTAR
                  || ', PUEDE_CREAR=' || :NEW.PUEDE_CREAR
                  || ', PUEDE_EDITAR=' || :NEW.PUEDE_EDITAR
                  || ', PUEDE_ELIMINAR=' || :NEW.PUEDE_ELIMINAR;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_ROL_OPCION=' || :OLD.ID_ROL_OPCION
                  || ', ID_ROL=' || :OLD.ID_ROL
                  || ', ID_OPCION=' || :OLD.ID_OPCION
                  || ', PUEDE_CONSULTAR=' || :OLD.PUEDE_CONSULTAR
                  || ', PUEDE_CREAR=' || :OLD.PUEDE_CREAR
                  || ', PUEDE_EDITAR=' || :OLD.PUEDE_EDITAR
                  || ', PUEDE_ELIMINAR=' || :OLD.PUEDE_ELIMINAR;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('ROL_OPCION', v_operacion, NVL(:NEW.ID_ROL_OPCION, :OLD.ID_ROL_OPCION), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_BITACORA_GENERAL
BEFORE INSERT ON BITACORA_GENERAL
FOR EACH ROW
BEGIN
    IF :NEW.ID_BITACORA IS NULL THEN
        :NEW.ID_BITACORA := SEQ_BITACORA_GENERAL.NEXTVAL;
    END IF;
    IF :NEW.USUARIO_APP IS NULL THEN
        :NEW.USUARIO_APP := SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_CATEGORIA
BEFORE INSERT OR UPDATE OR DELETE ON CATEGORIA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_CATEGORIA IS NULL THEN
            :NEW.ID_CATEGORIA := SEQ_CATEGORIA.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'CATEGORIA';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a CATEGORIA');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_CATEGORIA=' || :NEW.ID_CATEGORIA
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', DESCRIPCION=' || :NEW.DESCRIPCION
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_CATEGORIA=' || :OLD.ID_CATEGORIA
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', DESCRIPCION=' || :OLD.DESCRIPCION
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('CATEGORIA', v_operacion, NVL(:NEW.ID_CATEGORIA, :OLD.ID_CATEGORIA), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_MARCA
BEFORE INSERT OR UPDATE OR DELETE ON MARCA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_MARCA IS NULL THEN
            :NEW.ID_MARCA := SEQ_MARCA.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'MARCA';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a MARCA');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_MARCA=' || :NEW.ID_MARCA
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_MARCA=' || :OLD.ID_MARCA
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('MARCA', v_operacion, NVL(:NEW.ID_MARCA, :OLD.ID_MARCA), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_PRODUCTO
BEFORE INSERT OR UPDATE OR DELETE ON PRODUCTO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_PRODUCTO IS NULL THEN
            :NEW.ID_PRODUCTO := SEQ_PRODUCTO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'PRODUCTO';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a PRODUCTO');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_PRODUCTO=' || :NEW.ID_PRODUCTO
                  || ', ID_CATEGORIA=' || :NEW.ID_CATEGORIA
                  || ', ID_MARCA=' || :NEW.ID_MARCA
                  || ', CODIGO=' || :NEW.CODIGO
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', DESCRIPCION=' || :NEW.DESCRIPCION
                  || ', PRECIO_COSTO=' || :NEW.PRECIO_COSTO
                  || ', PRECIO_VENTA=' || :NEW.PRECIO_VENTA
                  || ', MESES_GARANTIA=' || :NEW.MESES_GARANTIA
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_PRODUCTO=' || :OLD.ID_PRODUCTO
                  || ', ID_CATEGORIA=' || :OLD.ID_CATEGORIA
                  || ', ID_MARCA=' || :OLD.ID_MARCA
                  || ', CODIGO=' || :OLD.CODIGO
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', DESCRIPCION=' || :OLD.DESCRIPCION
                  || ', PRECIO_COSTO=' || :OLD.PRECIO_COSTO
                  || ', PRECIO_VENTA=' || :OLD.PRECIO_VENTA
                  || ', MESES_GARANTIA=' || :OLD.MESES_GARANTIA
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('PRODUCTO', v_operacion, NVL(:NEW.ID_PRODUCTO, :OLD.ID_PRODUCTO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_INVENTARIO
BEFORE INSERT OR UPDATE OR DELETE ON INVENTARIO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_INVENTARIO IS NULL THEN
            :NEW.ID_INVENTARIO := SEQ_INVENTARIO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
        :NEW.FECHA_ACTUALIZACION := SYSTIMESTAMP;
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_INVENTARIO=' || :NEW.ID_INVENTARIO
                  || ', ID_SUCURSAL=' || :NEW.ID_SUCURSAL
                  || ', ID_PRODUCTO=' || :NEW.ID_PRODUCTO
                  || ', EXISTENCIA=' || :NEW.EXISTENCIA
                  || ', STOCK_MINIMO=' || :NEW.STOCK_MINIMO
                  || ', FECHA_ACTUALIZACION=' || TO_CHAR(:NEW.FECHA_ACTUALIZACION, 'YYYY-MM-DD HH24:MI:SS');
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_INVENTARIO=' || :OLD.ID_INVENTARIO
                  || ', ID_SUCURSAL=' || :OLD.ID_SUCURSAL
                  || ', ID_PRODUCTO=' || :OLD.ID_PRODUCTO
                  || ', EXISTENCIA=' || :OLD.EXISTENCIA
                  || ', STOCK_MINIMO=' || :OLD.STOCK_MINIMO
                  || ', FECHA_ACTUALIZACION=' || TO_CHAR(:OLD.FECHA_ACTUALIZACION, 'YYYY-MM-DD HH24:MI:SS');
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('INVENTARIO', v_operacion, NVL(:NEW.ID_INVENTARIO, :OLD.ID_INVENTARIO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_KARDEX
BEFORE INSERT OR UPDATE OR DELETE ON KARDEX
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_KARDEX IS NULL THEN
            :NEW.ID_KARDEX := SEQ_KARDEX.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_KARDEX=' || :NEW.ID_KARDEX
                  || ', ID_SUCURSAL=' || :NEW.ID_SUCURSAL
                  || ', ID_PRODUCTO=' || :NEW.ID_PRODUCTO
                  || ', TIPO_MOVIMIENTO=' || :NEW.TIPO_MOVIMIENTO
                  || ', CANTIDAD=' || :NEW.CANTIDAD
                  || ', EXISTENCIA_ANTERIOR=' || :NEW.EXISTENCIA_ANTERIOR
                  || ', EXISTENCIA_NUEVA=' || :NEW.EXISTENCIA_NUEVA
                  || ', DOCUMENTO_ORIGEN=' || :NEW.DOCUMENTO_ORIGEN
                  || ', ID_DOCUMENTO=' || :NEW.ID_DOCUMENTO
                  || ', FECHA=' || TO_CHAR(:NEW.FECHA, 'YYYY-MM-DD HH24:MI:SS');
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_KARDEX=' || :OLD.ID_KARDEX
                  || ', ID_SUCURSAL=' || :OLD.ID_SUCURSAL
                  || ', ID_PRODUCTO=' || :OLD.ID_PRODUCTO
                  || ', TIPO_MOVIMIENTO=' || :OLD.TIPO_MOVIMIENTO
                  || ', CANTIDAD=' || :OLD.CANTIDAD
                  || ', EXISTENCIA_ANTERIOR=' || :OLD.EXISTENCIA_ANTERIOR
                  || ', EXISTENCIA_NUEVA=' || :OLD.EXISTENCIA_NUEVA
                  || ', DOCUMENTO_ORIGEN=' || :OLD.DOCUMENTO_ORIGEN
                  || ', ID_DOCUMENTO=' || :OLD.ID_DOCUMENTO
                  || ', FECHA=' || TO_CHAR(:OLD.FECHA, 'YYYY-MM-DD HH24:MI:SS');
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('KARDEX', v_operacion, NVL(:NEW.ID_KARDEX, :OLD.ID_KARDEX), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_AJUSTE_INVENTARIO
BEFORE INSERT OR UPDATE OR DELETE ON AJUSTE_INVENTARIO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_AJUSTE IS NULL THEN
            :NEW.ID_AJUSTE := SEQ_AJUSTE_INVENTARIO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'AJUSTE_INVENTARIO';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a AJUSTE_INVENTARIO');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_AJUSTE=' || :NEW.ID_AJUSTE
                  || ', ID_SUCURSAL=' || :NEW.ID_SUCURSAL
                  || ', ID_PRODUCTO=' || :NEW.ID_PRODUCTO
                  || ', ID_EMPLEADO=' || :NEW.ID_EMPLEADO
                  || ', TIPO_AJUSTE=' || :NEW.TIPO_AJUSTE
                  || ', CANTIDAD=' || :NEW.CANTIDAD
                  || ', MOTIVO=' || :NEW.MOTIVO
                  || ', FECHA=' || TO_CHAR(:NEW.FECHA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_AJUSTE=' || :OLD.ID_AJUSTE
                  || ', ID_SUCURSAL=' || :OLD.ID_SUCURSAL
                  || ', ID_PRODUCTO=' || :OLD.ID_PRODUCTO
                  || ', ID_EMPLEADO=' || :OLD.ID_EMPLEADO
                  || ', TIPO_AJUSTE=' || :OLD.TIPO_AJUSTE
                  || ', CANTIDAD=' || :OLD.CANTIDAD
                  || ', MOTIVO=' || :OLD.MOTIVO
                  || ', FECHA=' || TO_CHAR(:OLD.FECHA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('AJUSTE_INVENTARIO', v_operacion, NVL(:NEW.ID_AJUSTE, :OLD.ID_AJUSTE), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_PROVEEDOR
BEFORE INSERT OR UPDATE OR DELETE ON PROVEEDOR
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_PROVEEDOR IS NULL THEN
            :NEW.ID_PROVEEDOR := SEQ_PROVEEDOR.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'PROVEEDOR';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a PROVEEDOR');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_PROVEEDOR=' || :NEW.ID_PROVEEDOR
                  || ', NIT=' || :NEW.NIT
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', CONTACTO=' || :NEW.CONTACTO
                  || ', TELEFONO=' || :NEW.TELEFONO
                  || ', CORREO=' || :NEW.CORREO
                  || ', DIRECCION=' || :NEW.DIRECCION
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_PROVEEDOR=' || :OLD.ID_PROVEEDOR
                  || ', NIT=' || :OLD.NIT
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', CONTACTO=' || :OLD.CONTACTO
                  || ', TELEFONO=' || :OLD.TELEFONO
                  || ', CORREO=' || :OLD.CORREO
                  || ', DIRECCION=' || :OLD.DIRECCION
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('PROVEEDOR', v_operacion, NVL(:NEW.ID_PROVEEDOR, :OLD.ID_PROVEEDOR), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_COMPRA
BEFORE INSERT OR UPDATE OR DELETE ON COMPRA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_COMPRA IS NULL THEN
            :NEW.ID_COMPRA := SEQ_COMPRA.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'COMPRA';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a COMPRA');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_COMPRA=' || :NEW.ID_COMPRA
                  || ', ID_PROVEEDOR=' || :NEW.ID_PROVEEDOR
                  || ', ID_SUCURSAL=' || :NEW.ID_SUCURSAL
                  || ', ID_EMPLEADO=' || :NEW.ID_EMPLEADO
                  || ', NO_DOCUMENTO=' || :NEW.NO_DOCUMENTO
                  || ', FECHA=' || TO_CHAR(:NEW.FECHA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', TOTAL=' || :NEW.TOTAL
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_COMPRA=' || :OLD.ID_COMPRA
                  || ', ID_PROVEEDOR=' || :OLD.ID_PROVEEDOR
                  || ', ID_SUCURSAL=' || :OLD.ID_SUCURSAL
                  || ', ID_EMPLEADO=' || :OLD.ID_EMPLEADO
                  || ', NO_DOCUMENTO=' || :OLD.NO_DOCUMENTO
                  || ', FECHA=' || TO_CHAR(:OLD.FECHA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', TOTAL=' || :OLD.TOTAL
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('COMPRA', v_operacion, NVL(:NEW.ID_COMPRA, :OLD.ID_COMPRA), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_DETALLE_COMPRA
BEFORE INSERT OR UPDATE OR DELETE ON DETALLE_COMPRA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_DETALLE_COMPRA IS NULL THEN
            :NEW.ID_DETALLE_COMPRA := SEQ_DETALLE_COMPRA.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_DETALLE_COMPRA=' || :NEW.ID_DETALLE_COMPRA
                  || ', ID_COMPRA=' || :NEW.ID_COMPRA
                  || ', ID_PRODUCTO=' || :NEW.ID_PRODUCTO
                  || ', CANTIDAD=' || :NEW.CANTIDAD
                  || ', COSTO_UNITARIO=' || :NEW.COSTO_UNITARIO
                  || ', SUBTOTAL=' || :NEW.SUBTOTAL;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_DETALLE_COMPRA=' || :OLD.ID_DETALLE_COMPRA
                  || ', ID_COMPRA=' || :OLD.ID_COMPRA
                  || ', ID_PRODUCTO=' || :OLD.ID_PRODUCTO
                  || ', CANTIDAD=' || :OLD.CANTIDAD
                  || ', COSTO_UNITARIO=' || :OLD.COSTO_UNITARIO
                  || ', SUBTOTAL=' || :OLD.SUBTOTAL;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('DETALLE_COMPRA', v_operacion, NVL(:NEW.ID_DETALLE_COMPRA, :OLD.ID_DETALLE_COMPRA), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_TRASLADO
BEFORE INSERT OR UPDATE OR DELETE ON TRASLADO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_TRASLADO IS NULL THEN
            :NEW.ID_TRASLADO := SEQ_TRASLADO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'TRASLADO';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a TRASLADO');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_TRASLADO=' || :NEW.ID_TRASLADO
                  || ', ID_SUCURSAL_ORIGEN=' || :NEW.ID_SUCURSAL_ORIGEN
                  || ', ID_SUCURSAL_DESTINO=' || :NEW.ID_SUCURSAL_DESTINO
                  || ', ID_EMPLEADO=' || :NEW.ID_EMPLEADO
                  || ', FECHA=' || TO_CHAR(:NEW.FECHA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', OBSERVACION=' || :NEW.OBSERVACION
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_TRASLADO=' || :OLD.ID_TRASLADO
                  || ', ID_SUCURSAL_ORIGEN=' || :OLD.ID_SUCURSAL_ORIGEN
                  || ', ID_SUCURSAL_DESTINO=' || :OLD.ID_SUCURSAL_DESTINO
                  || ', ID_EMPLEADO=' || :OLD.ID_EMPLEADO
                  || ', FECHA=' || TO_CHAR(:OLD.FECHA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', OBSERVACION=' || :OLD.OBSERVACION
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('TRASLADO', v_operacion, NVL(:NEW.ID_TRASLADO, :OLD.ID_TRASLADO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_DETALLE_TRASLADO
BEFORE INSERT OR UPDATE OR DELETE ON DETALLE_TRASLADO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_DETALLE_TRASLADO IS NULL THEN
            :NEW.ID_DETALLE_TRASLADO := SEQ_DETALLE_TRASLADO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_DETALLE_TRASLADO=' || :NEW.ID_DETALLE_TRASLADO
                  || ', ID_TRASLADO=' || :NEW.ID_TRASLADO
                  || ', ID_PRODUCTO=' || :NEW.ID_PRODUCTO
                  || ', CANTIDAD=' || :NEW.CANTIDAD;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_DETALLE_TRASLADO=' || :OLD.ID_DETALLE_TRASLADO
                  || ', ID_TRASLADO=' || :OLD.ID_TRASLADO
                  || ', ID_PRODUCTO=' || :OLD.ID_PRODUCTO
                  || ', CANTIDAD=' || :OLD.CANTIDAD;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('DETALLE_TRASLADO', v_operacion, NVL(:NEW.ID_DETALLE_TRASLADO, :OLD.ID_DETALLE_TRASLADO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_CLIENTE
BEFORE INSERT OR UPDATE OR DELETE ON CLIENTE
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_CLIENTE IS NULL THEN
            :NEW.ID_CLIENTE := SEQ_CLIENTE.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'CLIENTE';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a CLIENTE');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_CLIENTE=' || :NEW.ID_CLIENTE
                  || ', NIT=' || :NEW.NIT
                  || ', NOMBRES=' || :NEW.NOMBRES
                  || ', APELLIDOS=' || :NEW.APELLIDOS
                  || ', TELEFONO=' || :NEW.TELEFONO
                  || ', CORREO=' || :NEW.CORREO
                  || ', DIRECCION=' || :NEW.DIRECCION
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_CLIENTE=' || :OLD.ID_CLIENTE
                  || ', NIT=' || :OLD.NIT
                  || ', NOMBRES=' || :OLD.NOMBRES
                  || ', APELLIDOS=' || :OLD.APELLIDOS
                  || ', TELEFONO=' || :OLD.TELEFONO
                  || ', CORREO=' || :OLD.CORREO
                  || ', DIRECCION=' || :OLD.DIRECCION
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('CLIENTE', v_operacion, NVL(:NEW.ID_CLIENTE, :OLD.ID_CLIENTE), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_FORMA_PAGO
BEFORE INSERT OR UPDATE OR DELETE ON FORMA_PAGO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_FORMA_PAGO IS NULL THEN
            :NEW.ID_FORMA_PAGO := SEQ_FORMA_PAGO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'FORMA_PAGO';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a FORMA_PAGO');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_FORMA_PAGO=' || :NEW.ID_FORMA_PAGO
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', REQUIERE_REFERENCIA=' || :NEW.REQUIERE_REFERENCIA
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_FORMA_PAGO=' || :OLD.ID_FORMA_PAGO
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', REQUIERE_REFERENCIA=' || :OLD.REQUIERE_REFERENCIA
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('FORMA_PAGO', v_operacion, NVL(:NEW.ID_FORMA_PAGO, :OLD.ID_FORMA_PAGO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_BANCO
BEFORE INSERT OR UPDATE OR DELETE ON BANCO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_BANCO IS NULL THEN
            :NEW.ID_BANCO := SEQ_BANCO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'BANCO';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a BANCO');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_BANCO=' || :NEW.ID_BANCO
                  || ', NOMBRE=' || :NEW.NOMBRE
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_BANCO=' || :OLD.ID_BANCO
                  || ', NOMBRE=' || :OLD.NOMBRE
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('BANCO', v_operacion, NVL(:NEW.ID_BANCO, :OLD.ID_BANCO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_FACTURA
BEFORE INSERT OR UPDATE OR DELETE ON FACTURA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_FACTURA IS NULL THEN
            :NEW.ID_FACTURA := SEQ_FACTURA.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        RAISE_APPLICATION_ERROR(-20004, 'Una factura no se elimina, se revierte con nota de crédito');
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'FACTURA';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a FACTURA');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_FACTURA=' || :NEW.ID_FACTURA
                  || ', ID_SUCURSAL=' || :NEW.ID_SUCURSAL
                  || ', ID_CLIENTE=' || :NEW.ID_CLIENTE
                  || ', ID_EMPLEADO=' || :NEW.ID_EMPLEADO
                  || ', SERIE=' || :NEW.SERIE
                  || ', NUMERO=' || :NEW.NUMERO
                  || ', FECHA=' || TO_CHAR(:NEW.FECHA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', SUBTOTAL=' || :NEW.SUBTOTAL
                  || ', IVA=' || :NEW.IVA
                  || ', TOTAL=' || :NEW.TOTAL
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_FACTURA=' || :OLD.ID_FACTURA
                  || ', ID_SUCURSAL=' || :OLD.ID_SUCURSAL
                  || ', ID_CLIENTE=' || :OLD.ID_CLIENTE
                  || ', ID_EMPLEADO=' || :OLD.ID_EMPLEADO
                  || ', SERIE=' || :OLD.SERIE
                  || ', NUMERO=' || :OLD.NUMERO
                  || ', FECHA=' || TO_CHAR(:OLD.FECHA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', SUBTOTAL=' || :OLD.SUBTOTAL
                  || ', IVA=' || :OLD.IVA
                  || ', TOTAL=' || :OLD.TOTAL
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('FACTURA', v_operacion, NVL(:NEW.ID_FACTURA, :OLD.ID_FACTURA), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_DETALLE_FACTURA
BEFORE INSERT OR UPDATE OR DELETE ON DETALLE_FACTURA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_DETALLE_FACTURA IS NULL THEN
            :NEW.ID_DETALLE_FACTURA := SEQ_DETALLE_FACTURA.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_DETALLE_FACTURA=' || :NEW.ID_DETALLE_FACTURA
                  || ', ID_FACTURA=' || :NEW.ID_FACTURA
                  || ', ID_PRODUCTO=' || :NEW.ID_PRODUCTO
                  || ', CANTIDAD=' || :NEW.CANTIDAD
                  || ', PRECIO_UNITARIO=' || :NEW.PRECIO_UNITARIO
                  || ', DESCUENTO=' || :NEW.DESCUENTO
                  || ', SUBTOTAL=' || :NEW.SUBTOTAL
                  || ', FECHA_INICIO_GARANTIA=' || TO_CHAR(:NEW.FECHA_INICIO_GARANTIA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', FECHA_FIN_GARANTIA=' || TO_CHAR(:NEW.FECHA_FIN_GARANTIA, 'YYYY-MM-DD HH24:MI:SS');
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_DETALLE_FACTURA=' || :OLD.ID_DETALLE_FACTURA
                  || ', ID_FACTURA=' || :OLD.ID_FACTURA
                  || ', ID_PRODUCTO=' || :OLD.ID_PRODUCTO
                  || ', CANTIDAD=' || :OLD.CANTIDAD
                  || ', PRECIO_UNITARIO=' || :OLD.PRECIO_UNITARIO
                  || ', DESCUENTO=' || :OLD.DESCUENTO
                  || ', SUBTOTAL=' || :OLD.SUBTOTAL
                  || ', FECHA_INICIO_GARANTIA=' || TO_CHAR(:OLD.FECHA_INICIO_GARANTIA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', FECHA_FIN_GARANTIA=' || TO_CHAR(:OLD.FECHA_FIN_GARANTIA, 'YYYY-MM-DD HH24:MI:SS');
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('DETALLE_FACTURA', v_operacion, NVL(:NEW.ID_DETALLE_FACTURA, :OLD.ID_DETALLE_FACTURA), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_PAGO
BEFORE INSERT OR UPDATE OR DELETE ON PAGO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_PAGO IS NULL THEN
            :NEW.ID_PAGO := SEQ_PAGO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_PAGO=' || :NEW.ID_PAGO
                  || ', ID_FACTURA=' || :NEW.ID_FACTURA
                  || ', ID_FORMA_PAGO=' || :NEW.ID_FORMA_PAGO
                  || ', ID_BANCO=' || :NEW.ID_BANCO
                  || ', MONTO=' || :NEW.MONTO
                  || ', NO_REFERENCIA=' || :NEW.NO_REFERENCIA
                  || ', NO_AUTORIZACION=' || :NEW.NO_AUTORIZACION
                  || ', FECHA=' || TO_CHAR(:NEW.FECHA, 'YYYY-MM-DD HH24:MI:SS');
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_PAGO=' || :OLD.ID_PAGO
                  || ', ID_FACTURA=' || :OLD.ID_FACTURA
                  || ', ID_FORMA_PAGO=' || :OLD.ID_FORMA_PAGO
                  || ', ID_BANCO=' || :OLD.ID_BANCO
                  || ', MONTO=' || :OLD.MONTO
                  || ', NO_REFERENCIA=' || :OLD.NO_REFERENCIA
                  || ', NO_AUTORIZACION=' || :OLD.NO_AUTORIZACION
                  || ', FECHA=' || TO_CHAR(:OLD.FECHA, 'YYYY-MM-DD HH24:MI:SS');
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('PAGO', v_operacion, NVL(:NEW.ID_PAGO, :OLD.ID_PAGO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_NOTA_CREDITO
BEFORE INSERT OR UPDATE OR DELETE ON NOTA_CREDITO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_NOTA_CREDITO IS NULL THEN
            :NEW.ID_NOTA_CREDITO := SEQ_NOTA_CREDITO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'NOTA_CREDITO';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a NOTA_CREDITO');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_NOTA_CREDITO=' || :NEW.ID_NOTA_CREDITO
                  || ', ID_FACTURA=' || :NEW.ID_FACTURA
                  || ', ID_EMPLEADO=' || :NEW.ID_EMPLEADO
                  || ', SERIE=' || :NEW.SERIE
                  || ', NUMERO=' || :NEW.NUMERO
                  || ', FECHA=' || TO_CHAR(:NEW.FECHA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', MOTIVO=' || :NEW.MOTIVO
                  || ', TOTAL=' || :NEW.TOTAL
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_NOTA_CREDITO=' || :OLD.ID_NOTA_CREDITO
                  || ', ID_FACTURA=' || :OLD.ID_FACTURA
                  || ', ID_EMPLEADO=' || :OLD.ID_EMPLEADO
                  || ', SERIE=' || :OLD.SERIE
                  || ', NUMERO=' || :OLD.NUMERO
                  || ', FECHA=' || TO_CHAR(:OLD.FECHA, 'YYYY-MM-DD HH24:MI:SS')
                  || ', MOTIVO=' || :OLD.MOTIVO
                  || ', TOTAL=' || :OLD.TOTAL
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('NOTA_CREDITO', v_operacion, NVL(:NEW.ID_NOTA_CREDITO, :OLD.ID_NOTA_CREDITO), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_DETALLE_NOTA_CREDITO
BEFORE INSERT OR UPDATE OR DELETE ON DETALLE_NOTA_CREDITO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_DETALLE_NC IS NULL THEN
            :NEW.ID_DETALLE_NC := SEQ_DETALLE_NOTA_CREDITO.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_DETALLE_NC=' || :NEW.ID_DETALLE_NC
                  || ', ID_NOTA_CREDITO=' || :NEW.ID_NOTA_CREDITO
                  || ', ID_DETALLE_FACTURA=' || :NEW.ID_DETALLE_FACTURA
                  || ', CANTIDAD=' || :NEW.CANTIDAD
                  || ', MONTO=' || :NEW.MONTO
                  || ', REINGRESA_INVENTARIO=' || :NEW.REINGRESA_INVENTARIO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_DETALLE_NC=' || :OLD.ID_DETALLE_NC
                  || ', ID_NOTA_CREDITO=' || :OLD.ID_NOTA_CREDITO
                  || ', ID_DETALLE_FACTURA=' || :OLD.ID_DETALLE_FACTURA
                  || ', CANTIDAD=' || :OLD.CANTIDAD
                  || ', MONTO=' || :OLD.MONTO
                  || ', REINGRESA_INVENTARIO=' || :OLD.REINGRESA_INVENTARIO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('DETALLE_NOTA_CREDITO', v_operacion, NVL(:NEW.ID_DETALLE_NC, :OLD.ID_DETALLE_NC), v_antes, v_despues);
END;
/

CREATE OR REPLACE TRIGGER TRG_GARANTIA
BEFORE INSERT OR UPDATE OR DELETE ON GARANTIA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
    v_antes     VARCHAR2(4000);
    v_despues   VARCHAR2(4000);
    v_total     NUMBER;
    v_codigo    VARCHAR2(15);
BEGIN
    IF INSERTING THEN
        v_operacion := 'INSERT';
        IF :NEW.ID_GARANTIA IS NULL THEN
            :NEW.ID_GARANTIA := SEQ_GARANTIA.NEXTVAL;
        END IF;
        :NEW.CREADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSIF UPDATING THEN
        v_operacion := 'UPDATE';
        :NEW.FECHA_MODIFICACION := SYSDATE;
        :NEW.MODIFICADO_POR := NVL(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'), USER);
    ELSE
        v_operacion := 'DELETE';
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT COUNT(*) INTO v_total
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO
          AND ENTIDAD = 'GARANTIA';
        IF v_total = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El estado no pertenece a GARANTIA');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        SELECT CODIGO INTO v_codigo
        FROM ESTADO
        WHERE ID_ESTADO = :NEW.ID_ESTADO;
        IF v_codigo = 'CAMBIADA' AND (NVL(:NEW.TIPO_RESOLUCION, ' ') <> 'CAMBIO' OR :NEW.ID_PRODUCTO_REEMPLAZO IS NULL) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Una garantía cambiada debe tener resolución CAMBIO y producto de reemplazo');
        END IF;
        IF v_codigo = 'REPARADA' AND NVL(:NEW.TIPO_RESOLUCION, ' ') <> 'REPARACION' THEN
            RAISE_APPLICATION_ERROR(-20003, 'Una garantía reparada debe tener resolución REPARACION');
        END IF;
    END IF;

    IF INSERTING OR UPDATING THEN
        v_despues := 'ID_GARANTIA=' || :NEW.ID_GARANTIA
                  || ', ID_DETALLE_FACTURA=' || :NEW.ID_DETALLE_FACTURA
                  || ', ID_EMPLEADO=' || :NEW.ID_EMPLEADO
                  || ', ID_PRODUCTO_REEMPLAZO=' || :NEW.ID_PRODUCTO_REEMPLAZO
                  || ', FECHA_RECLAMO=' || TO_CHAR(:NEW.FECHA_RECLAMO, 'YYYY-MM-DD HH24:MI:SS')
                  || ', DESCRIPCION_FALLA=' || :NEW.DESCRIPCION_FALLA
                  || ', TIPO_RESOLUCION=' || :NEW.TIPO_RESOLUCION
                  || ', FECHA_RESOLUCION=' || TO_CHAR(:NEW.FECHA_RESOLUCION, 'YYYY-MM-DD HH24:MI:SS')
                  || ', OBSERVACIONES=' || :NEW.OBSERVACIONES
                  || ', ID_ESTADO=' || :NEW.ID_ESTADO;
    END IF;

    IF UPDATING OR DELETING THEN
        v_antes := 'ID_GARANTIA=' || :OLD.ID_GARANTIA
                  || ', ID_DETALLE_FACTURA=' || :OLD.ID_DETALLE_FACTURA
                  || ', ID_EMPLEADO=' || :OLD.ID_EMPLEADO
                  || ', ID_PRODUCTO_REEMPLAZO=' || :OLD.ID_PRODUCTO_REEMPLAZO
                  || ', FECHA_RECLAMO=' || TO_CHAR(:OLD.FECHA_RECLAMO, 'YYYY-MM-DD HH24:MI:SS')
                  || ', DESCRIPCION_FALLA=' || :OLD.DESCRIPCION_FALLA
                  || ', TIPO_RESOLUCION=' || :OLD.TIPO_RESOLUCION
                  || ', FECHA_RESOLUCION=' || TO_CHAR(:OLD.FECHA_RESOLUCION, 'YYYY-MM-DD HH24:MI:SS')
                  || ', OBSERVACIONES=' || :OLD.OBSERVACIONES
                  || ', ID_ESTADO=' || :OLD.ID_ESTADO;
    END IF;

    INSERT INTO BITACORA_GENERAL (TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS)
    VALUES ('GARANTIA', v_operacion, NVL(:NEW.ID_GARANTIA, :OLD.ID_GARANTIA), v_antes, v_despues);
END;
/

SELECT trigger_name, table_name, status FROM user_triggers ORDER BY table_name;
