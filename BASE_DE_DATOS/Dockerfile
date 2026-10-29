# ============================================================
# TIENDA-TEC - Imagen de la base de datos (Oracle Database 23ai Free)
# Basada en gvenzl/oracle-free: crea la BD al primer arranque y ejecuta
# los scripts de /container-entrypoint-initdb.d para cargar el esquema.
# Imagen base multi-arquitectura (amd64 local / arm64 en OCI Ampere).
# ============================================================
FROM gvenzl/oracle-free:23-slim

# Scripts del esquema (en el orden de ORDE_EJECUCION_SCRIPTS_SQL.txt)
COPY --chown=oracle:oinstall \
     CREATE_CONNECTION.sql QUERY_TABLAS.sql SECUENCIAS.sql TRIGGERS.sql \
     FUNCIONES.sql TRIGGERS_NEGOCIO.sql DATOS_INICIALES.sql PROCEDIMIENTOS.sql \
     PAQUETES.sql VISTAS.sql ROLES_BD.sql DATOS_MOVIMIENTOS.sql \
     /opt/tienda/sql/

# Script que los ejecuta la primera vez que se crea la base de datos
COPY --chown=oracle:oinstall --chmod=755 docker/01_init_tienda_tec.sh /container-entrypoint-initdb.d/

ENV TZ=America/Guatemala

EXPOSE 1521
