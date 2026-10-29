BEGIN
    FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN (
                                                                      'GARANTIA',
                                                                      'DETALLE_NOTA_CREDITO',
                                                                      'NOTA_CREDITO',
                                                                      'PAGO',
                                                                      'DETALLE_FACTURA',
                                                                      'FACTURA',
                                                                      'BANCO',
                                                                      'FORMA_PAGO',
                                                                      'CLIENTE',
                                                                      'DETALLE_TRASLADO',
                                                                      'TRASLADO',
                                                                      'DETALLE_COMPRA',
                                                                      'COMPRA',
                                                                      'PROVEEDOR',
                                                                      'AJUSTE_INVENTARIO',
                                                                      'KARDEX',
                                                                      'INVENTARIO',
                                                                      'PRODUCTO',
                                                                      'MARCA',
                                                                      'CATEGORIA',
                                                                      'BITACORA_GENERAL',
                                                                      'ROL_OPCION',
                                                                      'OPCION_MENU',
                                                                      'USUARIO',
                                                                      'ROL',
                                                                      'EMPLEADO_HORARIO',
                                                                      'EMPLEADO',
                                                                      'HORARIO',
                                                                      'PUESTO',
                                                                      'SUCURSAL',
                                                                      'MUNICIPIO',
                                                                      'DEPARTAMENTO',
                                                                      'ESTADO'
        )) LOOP
            EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
        END LOOP;
END;
/

CREATE TABLE ESTADO (
                        ID_ESTADO           NUMBER(10)     NOT NULL,
                        ENTIDAD             VARCHAR2(30)   NOT NULL,
                        CODIGO              VARCHAR2(15)   NOT NULL,
                        NOMBRE              VARCHAR2(50)   NOT NULL,
                        DESCRIPCION         VARCHAR2(200),
                        FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                        CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                        FECHA_MODIFICACION  DATE,
                        MODIFICADO_POR      VARCHAR2(30),
                        CONSTRAINT PK_ESTADO PRIMARY KEY (ID_ESTADO),
                        CONSTRAINT UK_EST_01 UNIQUE (ENTIDAD, CODIGO),
                        CONSTRAINT CK_EST_01 CHECK (ENTIDAD = UPPER(ENTIDAD) AND CODIGO = UPPER(CODIGO))
);

COMMENT ON TABLE ESTADO IS 'Catálogo de estados por entidad (tabla a la que pertenece el estado)';

INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (1, 'DEPARTAMENTO', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (2, 'DEPARTAMENTO', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (3, 'MUNICIPIO', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (4, 'MUNICIPIO', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (5, 'SUCURSAL', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (6, 'SUCURSAL', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (7, 'PUESTO', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (8, 'PUESTO', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (9, 'HORARIO', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (10, 'HORARIO', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (11, 'EMPLEADO', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (12, 'EMPLEADO', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (13, 'EMPLEADO_HORARIO', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (14, 'EMPLEADO_HORARIO', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (15, 'ROL', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (16, 'ROL', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (17, 'USUARIO', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (18, 'USUARIO', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (19, 'USUARIO', 'B', 'Bloqueado');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (20, 'OPCION_MENU', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (21, 'OPCION_MENU', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (22, 'CATEGORIA', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (23, 'CATEGORIA', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (24, 'MARCA', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (25, 'MARCA', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (26, 'PRODUCTO', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (27, 'PRODUCTO', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (28, 'PROVEEDOR', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (29, 'PROVEEDOR', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (30, 'CLIENTE', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (31, 'CLIENTE', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (32, 'FORMA_PAGO', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (33, 'FORMA_PAGO', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (34, 'BANCO', 'A', 'Activo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (35, 'BANCO', 'I', 'Inactivo');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (36, 'COMPRA', 'PENDIENTE', 'Pendiente');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (37, 'COMPRA', 'RECIBIDA', 'Recibida');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (38, 'COMPRA', 'ANULADA', 'Anulada');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (39, 'TRASLADO', 'ENVIADO', 'Enviado');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (40, 'TRASLADO', 'RECIBIDO', 'Recibido');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (41, 'TRASLADO', 'CANCELADO', 'Cancelado');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (42, 'FACTURA', 'EMITIDA', 'Emitida');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (43, 'FACTURA', 'NC_PARCIAL', 'Nota de crédito parcial');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (44, 'FACTURA', 'NC_TOTAL', 'Nota de crédito total');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (45, 'NOTA_CREDITO', 'EMITIDA', 'Emitida');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (46, 'NOTA_CREDITO', 'APLICADA', 'Aplicada');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (47, 'GARANTIA', 'RECIBIDA', 'Recibida');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (48, 'GARANTIA', 'EN_REVISION', 'En revisión');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (49, 'GARANTIA', 'REPARADA', 'Reparada');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (50, 'GARANTIA', 'CAMBIADA', 'Cambiada');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (51, 'GARANTIA', 'RECHAZADA', 'Rechazada');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (52, 'GARANTIA', 'ENTREGADA', 'Entregada');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (53, 'AJUSTE_INVENTARIO', 'APLICADO', 'Aplicado');
INSERT INTO ESTADO (ID_ESTADO, ENTIDAD, CODIGO, NOMBRE) VALUES (54, 'AJUSTE_INVENTARIO', 'ANULADO', 'Anulado');
COMMIT;

CREATE TABLE DEPARTAMENTO (
                              ID_DEPARTAMENTO     NUMBER(10)     NOT NULL,
                              NOMBRE              VARCHAR2(60)   NOT NULL,
                              ID_ESTADO           NUMBER(10)     NOT NULL,
                              FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                              CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                              FECHA_MODIFICACION  DATE,
                              MODIFICADO_POR      VARCHAR2(30),
                              CONSTRAINT PK_DEPARTAMENTO PRIMARY KEY (ID_DEPARTAMENTO),
                              CONSTRAINT UK_DEP_01 UNIQUE (NOMBRE),
                              CONSTRAINT FK_DEP_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE DEPARTAMENTO IS 'Catálogo de departamentos de Guatemala';

CREATE TABLE MUNICIPIO (
                           ID_MUNICIPIO        NUMBER(10)     NOT NULL,
                           ID_DEPARTAMENTO     NUMBER(10)     NOT NULL,
                           NOMBRE              VARCHAR2(80)   NOT NULL,
                           ES_CABECERA         CHAR(1)        DEFAULT 'N' NOT NULL,
                           ID_ESTADO           NUMBER(10)     NOT NULL,
                           FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                           CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                           FECHA_MODIFICACION  DATE,
                           MODIFICADO_POR      VARCHAR2(30),
                           CONSTRAINT PK_MUNICIPIO PRIMARY KEY (ID_MUNICIPIO),
                           CONSTRAINT UK_MUN_01 UNIQUE (ID_DEPARTAMENTO, NOMBRE),
                           CONSTRAINT CK_MUN_01 CHECK (ES_CABECERA IN ('S','N')),
                           CONSTRAINT FK_MUN_DEPARTAMENTO FOREIGN KEY (ID_DEPARTAMENTO) REFERENCES DEPARTAMENTO (ID_DEPARTAMENTO),
                           CONSTRAINT FK_MUN_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE MUNICIPIO IS 'Catálogo de municipios por departamento';

CREATE TABLE SUCURSAL (
                          ID_SUCURSAL         NUMBER(10)     NOT NULL,
                          ID_MUNICIPIO        NUMBER(10)     NOT NULL,
                          CODIGO              VARCHAR2(10)   NOT NULL,
                          NOMBRE              VARCHAR2(100)  NOT NULL,
                          DIRECCION           VARCHAR2(200)  NOT NULL,
                          TELEFONO            VARCHAR2(15),
                          CORREO              VARCHAR2(100),
                          FECHA_APERTURA      DATE           NOT NULL,
                          ID_ESTADO           NUMBER(10)     NOT NULL,
                          FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                          CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                          FECHA_MODIFICACION  DATE,
                          MODIFICADO_POR      VARCHAR2(30),
                          CONSTRAINT PK_SUCURSAL PRIMARY KEY (ID_SUCURSAL),
                          CONSTRAINT UK_SUC_01 UNIQUE (CODIGO),
                          CONSTRAINT CK_SUC_01 CHECK (CORREO IS NULL OR CORREO LIKE '%_@_%._%'),
                          CONSTRAINT FK_SUC_MUNICIPIO FOREIGN KEY (ID_MUNICIPIO) REFERENCES MUNICIPIO (ID_MUNICIPIO),
                          CONSTRAINT FK_SUC_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE SUCURSAL IS 'Sucursales de la cadena, ubicadas en un municipio';
CREATE INDEX IX_SUC_MUNICIPIO ON SUCURSAL (ID_MUNICIPIO);

CREATE TABLE PUESTO (
                        ID_PUESTO           NUMBER(10)     NOT NULL,
                        NOMBRE              VARCHAR2(60)   NOT NULL,
                        DESCRIPCION         VARCHAR2(200),
                        SALARIO_BASE        NUMBER(10,2)   NOT NULL,
                        ID_ESTADO           NUMBER(10)     NOT NULL,
                        FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                        CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                        FECHA_MODIFICACION  DATE,
                        MODIFICADO_POR      VARCHAR2(30),
                        CONSTRAINT PK_PUESTO PRIMARY KEY (ID_PUESTO),
                        CONSTRAINT UK_PUE_01 UNIQUE (NOMBRE),
                        CONSTRAINT CK_PUE_01 CHECK (SALARIO_BASE >= 0),
                        CONSTRAINT FK_PUE_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE PUESTO IS 'Catálogo de puestos de trabajo';

CREATE TABLE HORARIO (
                         ID_HORARIO          NUMBER(10)     NOT NULL,
                         NOMBRE              VARCHAR2(50)   NOT NULL,
                         HORA_ENTRADA        VARCHAR2(5)    NOT NULL,
                         HORA_SALIDA         VARCHAR2(5)    NOT NULL,
                         DIAS_SEMANA         VARCHAR2(30)   NOT NULL,
                         ID_ESTADO           NUMBER(10)     NOT NULL,
                         FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                         CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                         FECHA_MODIFICACION  DATE,
                         MODIFICADO_POR      VARCHAR2(30),
                         CONSTRAINT PK_HORARIO PRIMARY KEY (ID_HORARIO),
                         CONSTRAINT UK_HOR_01 UNIQUE (NOMBRE),
                         CONSTRAINT FK_HOR_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE HORARIO IS 'Catálogo de horarios/turnos laborales';

CREATE TABLE EMPLEADO (
                          ID_EMPLEADO         NUMBER(10)     NOT NULL,
                          ID_SUCURSAL         NUMBER(10)     NOT NULL,
                          ID_PUESTO           NUMBER(10)     NOT NULL,
                          DPI                 VARCHAR2(13)   NOT NULL,
                          NOMBRES             VARCHAR2(80)   NOT NULL,
                          APELLIDOS           VARCHAR2(80)   NOT NULL,
                          TELEFONO            VARCHAR2(15),
                          CORREO              VARCHAR2(100),
                          DIRECCION           VARCHAR2(200),
                          FECHA_INGRESO       DATE           NOT NULL,
                          ID_ESTADO           NUMBER(10)     NOT NULL,
                          FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                          CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                          FECHA_MODIFICACION  DATE,
                          MODIFICADO_POR      VARCHAR2(30),
                          CONSTRAINT PK_EMPLEADO PRIMARY KEY (ID_EMPLEADO),
                          CONSTRAINT UK_EMP_01 UNIQUE (DPI),
                          CONSTRAINT CK_EMP_01 CHECK (LENGTH(DPI) = 13),
                          CONSTRAINT CK_EMP_02 CHECK (CORREO IS NULL OR CORREO LIKE '%_@_%._%'),
                          CONSTRAINT FK_EMP_SUCURSAL FOREIGN KEY (ID_SUCURSAL) REFERENCES SUCURSAL (ID_SUCURSAL),
                          CONSTRAINT FK_EMP_PUESTO FOREIGN KEY (ID_PUESTO) REFERENCES PUESTO (ID_PUESTO),
                          CONSTRAINT FK_EMP_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE EMPLEADO IS 'Empleados asignados a una sucursal y un puesto';
CREATE INDEX IX_EMP_SUCURSAL ON EMPLEADO (ID_SUCURSAL);
CREATE INDEX IX_EMP_PUESTO ON EMPLEADO (ID_PUESTO);

CREATE TABLE EMPLEADO_HORARIO (
                                  ID_EMPLEADO_HORARIO  NUMBER(10)     NOT NULL,
                                  ID_EMPLEADO          NUMBER(10)     NOT NULL,
                                  ID_HORARIO           NUMBER(10)     NOT NULL,
                                  FECHA_INICIO         DATE           NOT NULL,
                                  FECHA_FIN            DATE,
                                  ID_ESTADO            NUMBER(10)     NOT NULL,
                                  FECHA_CREACION       DATE           DEFAULT SYSDATE NOT NULL,
                                  CREADO_POR           VARCHAR2(30)   DEFAULT USER NOT NULL,
                                  FECHA_MODIFICACION   DATE,
                                  MODIFICADO_POR       VARCHAR2(30),
                                  CONSTRAINT PK_EMPLEADO_HORARIO PRIMARY KEY (ID_EMPLEADO_HORARIO),
                                  CONSTRAINT UK_EHO_01 UNIQUE (ID_EMPLEADO, ID_HORARIO, FECHA_INICIO),
                                  CONSTRAINT CK_EHO_01 CHECK (FECHA_FIN IS NULL OR FECHA_FIN >= FECHA_INICIO),
                                  CONSTRAINT FK_EHO_EMPLEADO FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADO (ID_EMPLEADO),
                                  CONSTRAINT FK_EHO_HORARIO FOREIGN KEY (ID_HORARIO) REFERENCES HORARIO (ID_HORARIO),
                                  CONSTRAINT FK_EHO_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE EMPLEADO_HORARIO IS 'Asignación de horarios a empleados por rango de fechas';
CREATE INDEX IX_EHO_HORARIO ON EMPLEADO_HORARIO (ID_HORARIO);

CREATE TABLE ROL (
                     ID_ROL              NUMBER(10)     NOT NULL,
                     NOMBRE              VARCHAR2(50)   NOT NULL,
                     DESCRIPCION         VARCHAR2(200),
                     ID_ESTADO           NUMBER(10)     NOT NULL,
                     FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                     CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                     FECHA_MODIFICACION  DATE,
                     MODIFICADO_POR      VARCHAR2(30),
                     CONSTRAINT PK_ROL PRIMARY KEY (ID_ROL),
                     CONSTRAINT UK_ROL_01 UNIQUE (NOMBRE),
                     CONSTRAINT FK_ROL_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE ROL IS 'Roles de seguridad de la aplicación';

CREATE TABLE USUARIO (
                         ID_USUARIO          NUMBER(10)     NOT NULL,
                         ID_EMPLEADO         NUMBER(10)     NOT NULL,
                         ID_ROL              NUMBER(10)     NOT NULL,
                         USERNAME            VARCHAR2(30)   NOT NULL,
                         PASSWORD_HASH       VARCHAR2(100)  NOT NULL,
                         INTENTOS_FALLIDOS   NUMBER(2)      DEFAULT 0 NOT NULL,
                         ULTIMO_ACCESO       TIMESTAMP,
                         ID_ESTADO           NUMBER(10)     NOT NULL,
                         FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                         CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                         FECHA_MODIFICACION  DATE,
                         MODIFICADO_POR      VARCHAR2(30),
                         CONSTRAINT PK_USUARIO PRIMARY KEY (ID_USUARIO),
                         CONSTRAINT UK_USU_01 UNIQUE (ID_EMPLEADO),
                         CONSTRAINT UK_USU_02 UNIQUE (USERNAME),
                         CONSTRAINT CK_USU_01 CHECK (INTENTOS_FALLIDOS >= 0),
                         CONSTRAINT CK_USU_02 CHECK (LENGTH(USERNAME) >= 4),
                         CONSTRAINT FK_USU_EMPLEADO FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADO (ID_EMPLEADO),
                         CONSTRAINT FK_USU_ROL FOREIGN KEY (ID_ROL) REFERENCES ROL (ID_ROL),
                         CONSTRAINT FK_USU_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE USUARIO IS 'Usuarios del sistema (uno por empleado) con clave encriptada';
CREATE INDEX IX_USU_ROL ON USUARIO (ID_ROL);

CREATE TABLE OPCION_MENU (
                             ID_OPCION           NUMBER(10)     NOT NULL,
                             ID_OPCION_PADRE     NUMBER(10),
                             NOMBRE              VARCHAR2(60)   NOT NULL,
                             RUTA                VARCHAR2(100),
                             ICONO               VARCHAR2(50),
                             ORDEN               NUMBER(3)      NOT NULL,
                             ID_ESTADO           NUMBER(10)     NOT NULL,
                             FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                             CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                             FECHA_MODIFICACION  DATE,
                             MODIFICADO_POR      VARCHAR2(30),
                             CONSTRAINT PK_OPCION_MENU PRIMARY KEY (ID_OPCION),
                             CONSTRAINT CK_OPM_01 CHECK (ORDEN >= 0),
                             CONSTRAINT CK_OPM_02 CHECK (ID_OPCION_PADRE IS NULL OR ID_OPCION_PADRE <> ID_OPCION),
                             CONSTRAINT FK_OPM_OPCION_PADRE FOREIGN KEY (ID_OPCION_PADRE) REFERENCES OPCION_MENU (ID_OPCION),
                             CONSTRAINT FK_OPM_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE OPCION_MENU IS 'Opciones de menú de la aplicación (jerárquico: módulo > opción)';
CREATE INDEX IX_OPM_OPCION_PADRE ON OPCION_MENU (ID_OPCION_PADRE);

CREATE TABLE ROL_OPCION (
                            ID_ROL_OPCION       NUMBER(10)     NOT NULL,
                            ID_ROL              NUMBER(10)     NOT NULL,
                            ID_OPCION           NUMBER(10)     NOT NULL,
                            PUEDE_CONSULTAR     CHAR(1)        DEFAULT 'S' NOT NULL,
                            PUEDE_CREAR         CHAR(1)        DEFAULT 'N' NOT NULL,
                            PUEDE_EDITAR        CHAR(1)        DEFAULT 'N' NOT NULL,
                            PUEDE_ELIMINAR      CHAR(1)        DEFAULT 'N' NOT NULL,
                            FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                            CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                            FECHA_MODIFICACION  DATE,
                            MODIFICADO_POR      VARCHAR2(30),
                            CONSTRAINT PK_ROL_OPCION PRIMARY KEY (ID_ROL_OPCION),
                            CONSTRAINT UK_ROP_01 UNIQUE (ID_ROL, ID_OPCION),
                            CONSTRAINT CK_ROP_01 CHECK (PUEDE_CONSULTAR IN ('S','N')),
                            CONSTRAINT CK_ROP_02 CHECK (PUEDE_CREAR IN ('S','N')),
                            CONSTRAINT CK_ROP_03 CHECK (PUEDE_EDITAR IN ('S','N')),
                            CONSTRAINT CK_ROP_04 CHECK (PUEDE_ELIMINAR IN ('S','N')),
                            CONSTRAINT FK_ROP_ROL FOREIGN KEY (ID_ROL) REFERENCES ROL (ID_ROL),
                            CONSTRAINT FK_ROP_OPCION FOREIGN KEY (ID_OPCION) REFERENCES OPCION_MENU (ID_OPCION)
);

COMMENT ON TABLE ROL_OPCION IS 'Permisos de cada rol sobre cada opción de menú';
CREATE INDEX IX_ROP_OPCION ON ROL_OPCION (ID_OPCION);

CREATE TABLE BITACORA_GENERAL (
                                  ID_BITACORA         NUMBER(12)     NOT NULL,
                                  TABLA               VARCHAR2(40)   NOT NULL,
                                  OPERACION           VARCHAR2(10)   NOT NULL,
                                  ID_REGISTRO         NUMBER(10)     NOT NULL,
                                  VALORES_ANTERIORES  CLOB,
                                  VALORES_NUEVOS      CLOB,
                                  USUARIO_BD          VARCHAR2(30)   DEFAULT USER NOT NULL,
                                  USUARIO_APP         VARCHAR2(30),
                                  FECHA               TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
                                  CONSTRAINT PK_BITACORA_GENERAL PRIMARY KEY (ID_BITACORA),
                                  CONSTRAINT CK_BIT_01 CHECK (OPERACION IN ('INSERT','UPDATE','DELETE'))
);

COMMENT ON TABLE BITACORA_GENERAL IS 'Bitácora general de operaciones INSERT/UPDATE/DELETE';

CREATE TABLE CATEGORIA (
                           ID_CATEGORIA        NUMBER(10)     NOT NULL,
                           NOMBRE              VARCHAR2(60)   NOT NULL,
                           DESCRIPCION         VARCHAR2(200),
                           ID_ESTADO           NUMBER(10)     NOT NULL,
                           FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                           CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                           FECHA_MODIFICACION  DATE,
                           MODIFICADO_POR      VARCHAR2(30),
                           CONSTRAINT PK_CATEGORIA PRIMARY KEY (ID_CATEGORIA),
                           CONSTRAINT UK_CAT_01 UNIQUE (NOMBRE),
                           CONSTRAINT FK_CAT_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE CATEGORIA IS 'Catálogo de categorías de producto';

CREATE TABLE MARCA (
                       ID_MARCA            NUMBER(10)     NOT NULL,
                       NOMBRE              VARCHAR2(60)   NOT NULL,
                       ID_ESTADO           NUMBER(10)     NOT NULL,
                       FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                       CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                       FECHA_MODIFICACION  DATE,
                       MODIFICADO_POR      VARCHAR2(30),
                       CONSTRAINT PK_MARCA PRIMARY KEY (ID_MARCA),
                       CONSTRAINT UK_MAR_01 UNIQUE (NOMBRE),
                       CONSTRAINT FK_MAR_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE MARCA IS 'Catálogo de marcas';

CREATE TABLE PRODUCTO (
                          ID_PRODUCTO         NUMBER(10)     NOT NULL,
                          ID_CATEGORIA        NUMBER(10)     NOT NULL,
                          ID_MARCA            NUMBER(10)     NOT NULL,
                          CODIGO              VARCHAR2(20)   NOT NULL,
                          NOMBRE              VARCHAR2(120)  NOT NULL,
                          DESCRIPCION         VARCHAR2(300),
                          PRECIO_COSTO        NUMBER(12,2)   NOT NULL,
                          PRECIO_VENTA        NUMBER(12,2)   NOT NULL,
                          MESES_GARANTIA      NUMBER(3)      NOT NULL,
                          ID_ESTADO           NUMBER(10)     NOT NULL,
                          FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                          CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                          FECHA_MODIFICACION  DATE,
                          MODIFICADO_POR      VARCHAR2(30),
                          CONSTRAINT PK_PRODUCTO PRIMARY KEY (ID_PRODUCTO),
                          CONSTRAINT UK_PRO_01 UNIQUE (CODIGO),
                          CONSTRAINT CK_PRO_01 CHECK (PRECIO_COSTO >= 0),
                          CONSTRAINT CK_PRO_02 CHECK (PRECIO_VENTA >= PRECIO_COSTO),
                          CONSTRAINT CK_PRO_03 CHECK (MESES_GARANTIA BETWEEN 0 AND 120),
                          CONSTRAINT FK_PRO_CATEGORIA FOREIGN KEY (ID_CATEGORIA) REFERENCES CATEGORIA (ID_CATEGORIA),
                          CONSTRAINT FK_PRO_MARCA FOREIGN KEY (ID_MARCA) REFERENCES MARCA (ID_MARCA),
                          CONSTRAINT FK_PRO_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE PRODUCTO IS 'Catálogo de productos con precios y meses de garantía';
CREATE INDEX IX_PRO_CATEGORIA ON PRODUCTO (ID_CATEGORIA);
CREATE INDEX IX_PRO_MARCA ON PRODUCTO (ID_MARCA);

CREATE TABLE INVENTARIO (
                            ID_INVENTARIO        NUMBER(10)     NOT NULL,
                            ID_SUCURSAL          NUMBER(10)     NOT NULL,
                            ID_PRODUCTO          NUMBER(10)     NOT NULL,
                            EXISTENCIA           NUMBER(8)      DEFAULT 0 NOT NULL,
                            STOCK_MINIMO         NUMBER(8)      DEFAULT 0 NOT NULL,
                            FECHA_ACTUALIZACION  TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
                            FECHA_CREACION       DATE           DEFAULT SYSDATE NOT NULL,
                            CREADO_POR           VARCHAR2(30)   DEFAULT USER NOT NULL,
                            FECHA_MODIFICACION   DATE,
                            MODIFICADO_POR       VARCHAR2(30),
                            CONSTRAINT PK_INVENTARIO PRIMARY KEY (ID_INVENTARIO),
                            CONSTRAINT UK_INV_01 UNIQUE (ID_SUCURSAL, ID_PRODUCTO),
                            CONSTRAINT CK_INV_01 CHECK (EXISTENCIA >= 0),
                            CONSTRAINT CK_INV_02 CHECK (STOCK_MINIMO >= 0),
                            CONSTRAINT FK_INV_SUCURSAL FOREIGN KEY (ID_SUCURSAL) REFERENCES SUCURSAL (ID_SUCURSAL),
                            CONSTRAINT FK_INV_PRODUCTO FOREIGN KEY (ID_PRODUCTO) REFERENCES PRODUCTO (ID_PRODUCTO)
);

COMMENT ON TABLE INVENTARIO IS 'Existencias de cada producto por sucursal';
CREATE INDEX IX_INV_PRODUCTO ON INVENTARIO (ID_PRODUCTO);

CREATE TABLE KARDEX (
                        ID_KARDEX            NUMBER(12)     NOT NULL,
                        ID_SUCURSAL          NUMBER(10)     NOT NULL,
                        ID_PRODUCTO          NUMBER(10)     NOT NULL,
                        TIPO_MOVIMIENTO      VARCHAR2(20)   NOT NULL,
                        CANTIDAD             NUMBER(8)      NOT NULL,
                        EXISTENCIA_ANTERIOR  NUMBER(8)      NOT NULL,
                        EXISTENCIA_NUEVA     NUMBER(8)      NOT NULL,
                        DOCUMENTO_ORIGEN     VARCHAR2(20)   NOT NULL,
                        ID_DOCUMENTO         NUMBER(10)     NOT NULL,
                        FECHA                TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
                        FECHA_CREACION       DATE           DEFAULT SYSDATE NOT NULL,
                        CREADO_POR           VARCHAR2(30)   DEFAULT USER NOT NULL,
                        FECHA_MODIFICACION   DATE,
                        MODIFICADO_POR       VARCHAR2(30),
                        CONSTRAINT PK_KARDEX PRIMARY KEY (ID_KARDEX),
                        CONSTRAINT CK_KAR_01 CHECK (TIPO_MOVIMIENTO IN ('COMPRA','VENTA','NOTA_CREDITO','TRASLADO_SALIDA','TRASLADO_ENTRADA','GARANTIA_CAMBIO','AJUSTE_ENTRADA','AJUSTE_SALIDA')),
                        CONSTRAINT CK_KAR_02 CHECK (CANTIDAD > 0),
                        CONSTRAINT CK_KAR_03 CHECK (EXISTENCIA_ANTERIOR >= 0),
                        CONSTRAINT CK_KAR_04 CHECK (EXISTENCIA_NUEVA >= 0),
                        CONSTRAINT FK_KAR_SUCURSAL FOREIGN KEY (ID_SUCURSAL) REFERENCES SUCURSAL (ID_SUCURSAL),
                        CONSTRAINT FK_KAR_PRODUCTO FOREIGN KEY (ID_PRODUCTO) REFERENCES PRODUCTO (ID_PRODUCTO)
);

COMMENT ON TABLE KARDEX IS 'Historial de movimientos de inventario';
CREATE INDEX IX_KAR_SUCURSAL ON KARDEX (ID_SUCURSAL);
CREATE INDEX IX_KAR_PRODUCTO ON KARDEX (ID_PRODUCTO);

CREATE TABLE AJUSTE_INVENTARIO (
                                   ID_AJUSTE           NUMBER(10)     NOT NULL,
                                   ID_SUCURSAL         NUMBER(10)     NOT NULL,
                                   ID_PRODUCTO         NUMBER(10)     NOT NULL,
                                   ID_EMPLEADO         NUMBER(10)     NOT NULL,
                                   TIPO_AJUSTE         VARCHAR2(10)   NOT NULL,
                                   CANTIDAD            NUMBER(8)      NOT NULL,
                                   MOTIVO              VARCHAR2(200)  NOT NULL,
                                   FECHA               DATE           DEFAULT SYSDATE NOT NULL,
                                   ID_ESTADO           NUMBER(10)     NOT NULL,
                                   FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                                   CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                                   FECHA_MODIFICACION  DATE,
                                   MODIFICADO_POR      VARCHAR2(30),
                                   CONSTRAINT PK_AJUSTE_INVENTARIO PRIMARY KEY (ID_AJUSTE),
                                   CONSTRAINT CK_AJU_01 CHECK (TIPO_AJUSTE IN ('ENTRADA','SALIDA')),
                                   CONSTRAINT CK_AJU_02 CHECK (CANTIDAD > 0),
                                   CONSTRAINT FK_AJU_SUCURSAL FOREIGN KEY (ID_SUCURSAL) REFERENCES SUCURSAL (ID_SUCURSAL),
                                   CONSTRAINT FK_AJU_PRODUCTO FOREIGN KEY (ID_PRODUCTO) REFERENCES PRODUCTO (ID_PRODUCTO),
                                   CONSTRAINT FK_AJU_EMPLEADO FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADO (ID_EMPLEADO),
                                   CONSTRAINT FK_AJU_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE AJUSTE_INVENTARIO IS 'Ajustes de inventario (entrada o salida) con su motivo';
CREATE INDEX IX_AJU_SUCURSAL ON AJUSTE_INVENTARIO (ID_SUCURSAL);
CREATE INDEX IX_AJU_PRODUCTO ON AJUSTE_INVENTARIO (ID_PRODUCTO);
CREATE INDEX IX_AJU_EMPLEADO ON AJUSTE_INVENTARIO (ID_EMPLEADO);

CREATE TABLE PROVEEDOR (
                           ID_PROVEEDOR        NUMBER(10)     NOT NULL,
                           NIT                 VARCHAR2(15)   NOT NULL,
                           NOMBRE              VARCHAR2(120)  NOT NULL,
                           CONTACTO            VARCHAR2(100),
                           TELEFONO            VARCHAR2(15),
                           CORREO              VARCHAR2(100),
                           DIRECCION           VARCHAR2(200),
                           ID_ESTADO           NUMBER(10)     NOT NULL,
                           FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                           CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                           FECHA_MODIFICACION  DATE,
                           MODIFICADO_POR      VARCHAR2(30),
                           CONSTRAINT PK_PROVEEDOR PRIMARY KEY (ID_PROVEEDOR),
                           CONSTRAINT UK_PRV_01 UNIQUE (NIT),
                           CONSTRAINT CK_PRV_01 CHECK (CORREO IS NULL OR CORREO LIKE '%_@_%._%'),
                           CONSTRAINT FK_PRV_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE PROVEEDOR IS 'Catálogo de proveedores';

CREATE TABLE COMPRA (
                        ID_COMPRA           NUMBER(10)     NOT NULL,
                        ID_PROVEEDOR        NUMBER(10)     NOT NULL,
                        ID_SUCURSAL         NUMBER(10)     NOT NULL,
                        ID_EMPLEADO         NUMBER(10)     NOT NULL,
                        NO_DOCUMENTO        VARCHAR2(30)   NOT NULL,
                        FECHA               DATE           DEFAULT SYSDATE NOT NULL,
                        TOTAL               NUMBER(14,2)   NOT NULL,
                        ID_ESTADO           NUMBER(10)     NOT NULL,
                        FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                        CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                        FECHA_MODIFICACION  DATE,
                        MODIFICADO_POR      VARCHAR2(30),
                        CONSTRAINT PK_COMPRA PRIMARY KEY (ID_COMPRA),
                        CONSTRAINT UK_COM_01 UNIQUE (ID_PROVEEDOR, NO_DOCUMENTO),
                        CONSTRAINT CK_COM_01 CHECK (TOTAL >= 0),
                        CONSTRAINT FK_COM_PROVEEDOR FOREIGN KEY (ID_PROVEEDOR) REFERENCES PROVEEDOR (ID_PROVEEDOR),
                        CONSTRAINT FK_COM_SUCURSAL FOREIGN KEY (ID_SUCURSAL) REFERENCES SUCURSAL (ID_SUCURSAL),
                        CONSTRAINT FK_COM_EMPLEADO FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADO (ID_EMPLEADO),
                        CONSTRAINT FK_COM_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE COMPRA IS 'Encabezado de compras a proveedores';
CREATE INDEX IX_COM_SUCURSAL ON COMPRA (ID_SUCURSAL);
CREATE INDEX IX_COM_EMPLEADO ON COMPRA (ID_EMPLEADO);

CREATE TABLE DETALLE_COMPRA (
                                ID_DETALLE_COMPRA   NUMBER(10)     NOT NULL,
                                ID_COMPRA           NUMBER(10)     NOT NULL,
                                ID_PRODUCTO         NUMBER(10)     NOT NULL,
                                CANTIDAD            NUMBER(8)      NOT NULL,
                                COSTO_UNITARIO      NUMBER(12,2)   NOT NULL,
                                SUBTOTAL            NUMBER(14,2)   NOT NULL,
                                FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                                CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                                FECHA_MODIFICACION  DATE,
                                MODIFICADO_POR      VARCHAR2(30),
                                CONSTRAINT PK_DETALLE_COMPRA PRIMARY KEY (ID_DETALLE_COMPRA),
                                CONSTRAINT UK_DCO_01 UNIQUE (ID_COMPRA, ID_PRODUCTO),
                                CONSTRAINT CK_DCO_01 CHECK (CANTIDAD > 0),
                                CONSTRAINT CK_DCO_02 CHECK (COSTO_UNITARIO >= 0),
                                CONSTRAINT CK_DCO_03 CHECK (SUBTOTAL >= 0),
                                CONSTRAINT FK_DCO_COMPRA FOREIGN KEY (ID_COMPRA) REFERENCES COMPRA (ID_COMPRA),
                                CONSTRAINT FK_DCO_PRODUCTO FOREIGN KEY (ID_PRODUCTO) REFERENCES PRODUCTO (ID_PRODUCTO)
);

COMMENT ON TABLE DETALLE_COMPRA IS 'Detalle de productos comprados';
CREATE INDEX IX_DCO_PRODUCTO ON DETALLE_COMPRA (ID_PRODUCTO);

CREATE TABLE TRASLADO (
                          ID_TRASLADO          NUMBER(10)     NOT NULL,
                          ID_SUCURSAL_ORIGEN   NUMBER(10)     NOT NULL,
                          ID_SUCURSAL_DESTINO  NUMBER(10)     NOT NULL,
                          ID_EMPLEADO          NUMBER(10)     NOT NULL,
                          FECHA                DATE           DEFAULT SYSDATE NOT NULL,
                          OBSERVACION          VARCHAR2(200),
                          ID_ESTADO            NUMBER(10)     NOT NULL,
                          FECHA_CREACION       DATE           DEFAULT SYSDATE NOT NULL,
                          CREADO_POR           VARCHAR2(30)   DEFAULT USER NOT NULL,
                          FECHA_MODIFICACION   DATE,
                          MODIFICADO_POR       VARCHAR2(30),
                          CONSTRAINT PK_TRASLADO PRIMARY KEY (ID_TRASLADO),
                          CONSTRAINT CK_TRA_01 CHECK (ID_SUCURSAL_ORIGEN <> ID_SUCURSAL_DESTINO),
                          CONSTRAINT FK_TRA_SUCURSAL_ORIGEN FOREIGN KEY (ID_SUCURSAL_ORIGEN) REFERENCES SUCURSAL (ID_SUCURSAL),
                          CONSTRAINT FK_TRA_SUCURSAL_DESTINO FOREIGN KEY (ID_SUCURSAL_DESTINO) REFERENCES SUCURSAL (ID_SUCURSAL),
                          CONSTRAINT FK_TRA_EMPLEADO FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADO (ID_EMPLEADO),
                          CONSTRAINT FK_TRA_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE TRASLADO IS 'Encabezado de traslados de producto entre sucursales';
CREATE INDEX IX_TRA_SUCURSAL_ORIGEN ON TRASLADO (ID_SUCURSAL_ORIGEN);
CREATE INDEX IX_TRA_SUCURSAL_DESTINO ON TRASLADO (ID_SUCURSAL_DESTINO);
CREATE INDEX IX_TRA_EMPLEADO ON TRASLADO (ID_EMPLEADO);

CREATE TABLE DETALLE_TRASLADO (
                                  ID_DETALLE_TRASLADO  NUMBER(10)     NOT NULL,
                                  ID_TRASLADO          NUMBER(10)     NOT NULL,
                                  ID_PRODUCTO          NUMBER(10)     NOT NULL,
                                  CANTIDAD             NUMBER(8)      NOT NULL,
                                  FECHA_CREACION       DATE           DEFAULT SYSDATE NOT NULL,
                                  CREADO_POR           VARCHAR2(30)   DEFAULT USER NOT NULL,
                                  FECHA_MODIFICACION   DATE,
                                  MODIFICADO_POR       VARCHAR2(30),
                                  CONSTRAINT PK_DETALLE_TRASLADO PRIMARY KEY (ID_DETALLE_TRASLADO),
                                  CONSTRAINT UK_DTR_01 UNIQUE (ID_TRASLADO, ID_PRODUCTO),
                                  CONSTRAINT CK_DTR_01 CHECK (CANTIDAD > 0),
                                  CONSTRAINT FK_DTR_TRASLADO FOREIGN KEY (ID_TRASLADO) REFERENCES TRASLADO (ID_TRASLADO),
                                  CONSTRAINT FK_DTR_PRODUCTO FOREIGN KEY (ID_PRODUCTO) REFERENCES PRODUCTO (ID_PRODUCTO)
);

COMMENT ON TABLE DETALLE_TRASLADO IS 'Detalle de productos trasladados';
CREATE INDEX IX_DTR_PRODUCTO ON DETALLE_TRASLADO (ID_PRODUCTO);

CREATE TABLE CLIENTE (
                         ID_CLIENTE          NUMBER(10)     NOT NULL,
                         NIT                 VARCHAR2(15)   NOT NULL,
                         NOMBRES             VARCHAR2(80)   NOT NULL,
                         APELLIDOS           VARCHAR2(80),
                         TELEFONO            VARCHAR2(15),
                         CORREO              VARCHAR2(100),
                         DIRECCION           VARCHAR2(200),
                         ID_ESTADO           NUMBER(10)     NOT NULL,
                         FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                         CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                         FECHA_MODIFICACION  DATE,
                         MODIFICADO_POR      VARCHAR2(30),
                         CONSTRAINT PK_CLIENTE PRIMARY KEY (ID_CLIENTE),
                         CONSTRAINT CK_CLI_01 CHECK (NIT = 'CF' OR LENGTH(NIT) BETWEEN 2 AND 13),
                         CONSTRAINT CK_CLI_02 CHECK (CORREO IS NULL OR CORREO LIKE '%_@_%._%'),
                         CONSTRAINT FK_CLI_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE CLIENTE IS 'Catálogo de clientes';

CREATE TABLE FORMA_PAGO (
                            ID_FORMA_PAGO        NUMBER(10)     NOT NULL,
                            NOMBRE               VARCHAR2(30)   NOT NULL,
                            REQUIERE_REFERENCIA  CHAR(1)        DEFAULT 'N' NOT NULL,
                            ID_ESTADO            NUMBER(10)     NOT NULL,
                            FECHA_CREACION       DATE           DEFAULT SYSDATE NOT NULL,
                            CREADO_POR           VARCHAR2(30)   DEFAULT USER NOT NULL,
                            FECHA_MODIFICACION   DATE,
                            MODIFICADO_POR       VARCHAR2(30),
                            CONSTRAINT PK_FORMA_PAGO PRIMARY KEY (ID_FORMA_PAGO),
                            CONSTRAINT UK_FPA_01 UNIQUE (NOMBRE),
                            CONSTRAINT CK_FPA_01 CHECK (REQUIERE_REFERENCIA IN ('S','N')),
                            CONSTRAINT FK_FPA_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE FORMA_PAGO IS 'Catálogo de formas de pago (efectivo, transferencia, tarjeta)';

CREATE TABLE BANCO (
                       ID_BANCO            NUMBER(10)     NOT NULL,
                       NOMBRE              VARCHAR2(80)   NOT NULL,
                       ID_ESTADO           NUMBER(10)     NOT NULL,
                       FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                       CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                       FECHA_MODIFICACION  DATE,
                       MODIFICADO_POR      VARCHAR2(30),
                       CONSTRAINT PK_BANCO PRIMARY KEY (ID_BANCO),
                       CONSTRAINT UK_BAN_01 UNIQUE (NOMBRE),
                       CONSTRAINT FK_BAN_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE BANCO IS 'Catálogo de bancos/emisores para transferencias y tarjetas';

CREATE TABLE FACTURA (
                         ID_FACTURA          NUMBER(10)     NOT NULL,
                         ID_SUCURSAL         NUMBER(10)     NOT NULL,
                         ID_CLIENTE          NUMBER(10)     NOT NULL,
                         ID_EMPLEADO         NUMBER(10)     NOT NULL,
                         SERIE               VARCHAR2(10)   NOT NULL,
                         NUMERO              NUMBER(10)     NOT NULL,
                         FECHA               DATE           DEFAULT SYSDATE NOT NULL,
                         SUBTOTAL            NUMBER(14,2)   NOT NULL,
                         IVA                 NUMBER(14,2)   NOT NULL,
                         TOTAL               NUMBER(14,2)   NOT NULL,
                         ID_ESTADO           NUMBER(10)     NOT NULL,
                         FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                         CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                         FECHA_MODIFICACION  DATE,
                         MODIFICADO_POR      VARCHAR2(30),
                         CONSTRAINT PK_FACTURA PRIMARY KEY (ID_FACTURA),
                         CONSTRAINT UK_FAC_01 UNIQUE (SERIE, NUMERO),
                         CONSTRAINT CK_FAC_01 CHECK (SUBTOTAL >= 0),
                         CONSTRAINT CK_FAC_02 CHECK (IVA >= 0),
                         CONSTRAINT CK_FAC_03 CHECK (TOTAL = SUBTOTAL + IVA),
                         CONSTRAINT FK_FAC_SUCURSAL FOREIGN KEY (ID_SUCURSAL) REFERENCES SUCURSAL (ID_SUCURSAL),
                         CONSTRAINT FK_FAC_CLIENTE FOREIGN KEY (ID_CLIENTE) REFERENCES CLIENTE (ID_CLIENTE),
                         CONSTRAINT FK_FAC_EMPLEADO FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADO (ID_EMPLEADO),
                         CONSTRAINT FK_FAC_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE FACTURA IS 'Encabezado de facturas. No se anulan: se corrigen con notas de crédito';
CREATE INDEX IX_FAC_SUCURSAL ON FACTURA (ID_SUCURSAL);
CREATE INDEX IX_FAC_CLIENTE ON FACTURA (ID_CLIENTE);
CREATE INDEX IX_FAC_EMPLEADO ON FACTURA (ID_EMPLEADO);

CREATE TABLE DETALLE_FACTURA (
                                 ID_DETALLE_FACTURA     NUMBER(10)     NOT NULL,
                                 ID_FACTURA             NUMBER(10)     NOT NULL,
                                 ID_PRODUCTO            NUMBER(10)     NOT NULL,
                                 CANTIDAD               NUMBER(8)      NOT NULL,
                                 PRECIO_UNITARIO        NUMBER(12,2)   NOT NULL,
                                 DESCUENTO              NUMBER(12,2)   DEFAULT 0 NOT NULL,
                                 SUBTOTAL               NUMBER(14,2)   NOT NULL,
                                 FECHA_INICIO_GARANTIA  DATE           NOT NULL,
                                 FECHA_FIN_GARANTIA     DATE           NOT NULL,
                                 FECHA_CREACION         DATE           DEFAULT SYSDATE NOT NULL,
                                 CREADO_POR             VARCHAR2(30)   DEFAULT USER NOT NULL,
                                 FECHA_MODIFICACION     DATE,
                                 MODIFICADO_POR         VARCHAR2(30),
                                 CONSTRAINT PK_DETALLE_FACTURA PRIMARY KEY (ID_DETALLE_FACTURA),
                                 CONSTRAINT UK_DFA_01 UNIQUE (ID_FACTURA, ID_PRODUCTO),
                                 CONSTRAINT CK_DFA_01 CHECK (CANTIDAD > 0),
                                 CONSTRAINT CK_DFA_02 CHECK (PRECIO_UNITARIO >= 0),
                                 CONSTRAINT CK_DFA_03 CHECK (DESCUENTO >= 0),
                                 CONSTRAINT CK_DFA_04 CHECK (SUBTOTAL >= 0),
                                 CONSTRAINT CK_DFA_05 CHECK (FECHA_FIN_GARANTIA >= FECHA_INICIO_GARANTIA),
                                 CONSTRAINT FK_DFA_FACTURA FOREIGN KEY (ID_FACTURA) REFERENCES FACTURA (ID_FACTURA),
                                 CONSTRAINT FK_DFA_PRODUCTO FOREIGN KEY (ID_PRODUCTO) REFERENCES PRODUCTO (ID_PRODUCTO)
);

COMMENT ON TABLE DETALLE_FACTURA IS 'Líneas de factura con fechas de cobertura de garantía';
CREATE INDEX IX_DFA_PRODUCTO ON DETALLE_FACTURA (ID_PRODUCTO);

CREATE TABLE PAGO (
                      ID_PAGO             NUMBER(10)     NOT NULL,
                      ID_FACTURA          NUMBER(10)     NOT NULL,
                      ID_FORMA_PAGO       NUMBER(10)     NOT NULL,
                      ID_BANCO            NUMBER(10),
                      MONTO               NUMBER(14,2)   NOT NULL,
                      NO_REFERENCIA       VARCHAR2(40),
                      NO_AUTORIZACION     VARCHAR2(40),
                      FECHA               TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
                      FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                      CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                      FECHA_MODIFICACION  DATE,
                      MODIFICADO_POR      VARCHAR2(30),
                      CONSTRAINT PK_PAGO PRIMARY KEY (ID_PAGO),
                      CONSTRAINT CK_PAG_01 CHECK (MONTO > 0),
                      CONSTRAINT FK_PAG_FACTURA FOREIGN KEY (ID_FACTURA) REFERENCES FACTURA (ID_FACTURA),
                      CONSTRAINT FK_PAG_FORMA_PAGO FOREIGN KEY (ID_FORMA_PAGO) REFERENCES FORMA_PAGO (ID_FORMA_PAGO),
                      CONSTRAINT FK_PAG_BANCO FOREIGN KEY (ID_BANCO) REFERENCES BANCO (ID_BANCO)
);

COMMENT ON TABLE PAGO IS 'Pagos aplicados a una factura';
CREATE INDEX IX_PAG_FACTURA ON PAGO (ID_FACTURA);
CREATE INDEX IX_PAG_FORMA_PAGO ON PAGO (ID_FORMA_PAGO);
CREATE INDEX IX_PAG_BANCO ON PAGO (ID_BANCO);

CREATE TABLE NOTA_CREDITO (
                              ID_NOTA_CREDITO     NUMBER(10)     NOT NULL,
                              ID_FACTURA          NUMBER(10)     NOT NULL,
                              ID_EMPLEADO         NUMBER(10)     NOT NULL,
                              SERIE               VARCHAR2(10)   NOT NULL,
                              NUMERO              NUMBER(10)     NOT NULL,
                              FECHA               DATE           DEFAULT SYSDATE NOT NULL,
                              MOTIVO              VARCHAR2(200)  NOT NULL,
                              TOTAL               NUMBER(14,2)   NOT NULL,
                              ID_ESTADO           NUMBER(10)     NOT NULL,
                              FECHA_CREACION      DATE           DEFAULT SYSDATE NOT NULL,
                              CREADO_POR          VARCHAR2(30)   DEFAULT USER NOT NULL,
                              FECHA_MODIFICACION  DATE,
                              MODIFICADO_POR      VARCHAR2(30),
                              CONSTRAINT PK_NOTA_CREDITO PRIMARY KEY (ID_NOTA_CREDITO),
                              CONSTRAINT UK_NCR_01 UNIQUE (SERIE, NUMERO),
                              CONSTRAINT CK_NCR_01 CHECK (TOTAL >= 0),
                              CONSTRAINT FK_NCR_FACTURA FOREIGN KEY (ID_FACTURA) REFERENCES FACTURA (ID_FACTURA),
                              CONSTRAINT FK_NCR_EMPLEADO FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADO (ID_EMPLEADO),
                              CONSTRAINT FK_NCR_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE NOTA_CREDITO IS 'Notas de crédito emitidas sobre una factura';
CREATE INDEX IX_NCR_FACTURA ON NOTA_CREDITO (ID_FACTURA);
CREATE INDEX IX_NCR_EMPLEADO ON NOTA_CREDITO (ID_EMPLEADO);

CREATE TABLE DETALLE_NOTA_CREDITO (
                                      ID_DETALLE_NC         NUMBER(10)     NOT NULL,
                                      ID_NOTA_CREDITO       NUMBER(10)     NOT NULL,
                                      ID_DETALLE_FACTURA    NUMBER(10)     NOT NULL,
                                      CANTIDAD              NUMBER(8)      NOT NULL,
                                      MONTO                 NUMBER(14,2)   NOT NULL,
                                      REINGRESA_INVENTARIO  CHAR(1)        DEFAULT 'S' NOT NULL,
                                      FECHA_CREACION        DATE           DEFAULT SYSDATE NOT NULL,
                                      CREADO_POR            VARCHAR2(30)   DEFAULT USER NOT NULL,
                                      FECHA_MODIFICACION    DATE,
                                      MODIFICADO_POR        VARCHAR2(30),
                                      CONSTRAINT PK_DETALLE_NOTA_CREDITO PRIMARY KEY (ID_DETALLE_NC),
                                      CONSTRAINT UK_DNC_01 UNIQUE (ID_NOTA_CREDITO, ID_DETALLE_FACTURA),
                                      CONSTRAINT CK_DNC_01 CHECK (CANTIDAD > 0),
                                      CONSTRAINT CK_DNC_02 CHECK (MONTO >= 0),
                                      CONSTRAINT CK_DNC_03 CHECK (REINGRESA_INVENTARIO IN ('S','N')),
                                      CONSTRAINT FK_DNC_NOTA_CREDITO FOREIGN KEY (ID_NOTA_CREDITO) REFERENCES NOTA_CREDITO (ID_NOTA_CREDITO),
                                      CONSTRAINT FK_DNC_DETALLE_FACTURA FOREIGN KEY (ID_DETALLE_FACTURA) REFERENCES DETALLE_FACTURA (ID_DETALLE_FACTURA)
);

COMMENT ON TABLE DETALLE_NOTA_CREDITO IS 'Líneas de factura afectadas por la nota de crédito';
CREATE INDEX IX_DNC_DETALLE_FACTURA ON DETALLE_NOTA_CREDITO (ID_DETALLE_FACTURA);

CREATE TABLE GARANTIA (
                          ID_GARANTIA            NUMBER(10)     NOT NULL,
                          ID_DETALLE_FACTURA     NUMBER(10)     NOT NULL,
                          ID_EMPLEADO            NUMBER(10)     NOT NULL,
                          ID_PRODUCTO_REEMPLAZO  NUMBER(10),
                          FECHA_RECLAMO          DATE           DEFAULT SYSDATE NOT NULL,
                          DESCRIPCION_FALLA      VARCHAR2(300)  NOT NULL,
                          TIPO_RESOLUCION        VARCHAR2(12),
                          FECHA_RESOLUCION       DATE,
                          OBSERVACIONES          VARCHAR2(300),
                          ID_ESTADO              NUMBER(10)     NOT NULL,
                          FECHA_CREACION         DATE           DEFAULT SYSDATE NOT NULL,
                          CREADO_POR             VARCHAR2(30)   DEFAULT USER NOT NULL,
                          FECHA_MODIFICACION     DATE,
                          MODIFICADO_POR         VARCHAR2(30),
                          CONSTRAINT PK_GARANTIA PRIMARY KEY (ID_GARANTIA),
                          CONSTRAINT CK_GAR_01 CHECK (TIPO_RESOLUCION IS NULL OR TIPO_RESOLUCION IN ('REPARACION','CAMBIO')),
                          CONSTRAINT CK_GAR_02 CHECK (FECHA_RESOLUCION IS NULL OR FECHA_RESOLUCION >= FECHA_RECLAMO),
                          CONSTRAINT FK_GAR_DETALLE_FACTURA FOREIGN KEY (ID_DETALLE_FACTURA) REFERENCES DETALLE_FACTURA (ID_DETALLE_FACTURA),
                          CONSTRAINT FK_GAR_EMPLEADO FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADO (ID_EMPLEADO),
                          CONSTRAINT FK_GAR_PRODUCTO_REEMPLAZO FOREIGN KEY (ID_PRODUCTO_REEMPLAZO) REFERENCES PRODUCTO (ID_PRODUCTO),
                          CONSTRAINT FK_GAR_ESTADO FOREIGN KEY (ID_ESTADO) REFERENCES ESTADO (ID_ESTADO)
);

COMMENT ON TABLE GARANTIA IS 'Reclamos de garantía por línea de factura (reparación o cambio)';
CREATE INDEX IX_GAR_DETALLE_FACTURA ON GARANTIA (ID_DETALLE_FACTURA);
CREATE INDEX IX_GAR_EMPLEADO ON GARANTIA (ID_EMPLEADO);
CREATE INDEX IX_GAR_PRODUCTO_REEMPLAZO ON GARANTIA (ID_PRODUCTO_REEMPLAZO);

SELECT table_name FROM user_tables ORDER BY table_name;