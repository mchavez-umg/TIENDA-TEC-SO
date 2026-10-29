#!/bin/bash
# ============================================================
# Inicializacion de la BD TIENDA-TEC dentro del contenedor gvenzl/oracle-free.
# Se ejecuta UNA sola vez, cuando el contenedor crea la base de datos por primera vez.
# Respeta el orden de ORDE_EJECUCION_SCRIPTS_SQL.txt:
#   CREATE_CONNECTION como SYS y el resto como TIENDA_TEC.
# ============================================================

# El entrypoint de la imagen carga los .sh con "source"; se re-ejecuta en un proceso
# aparte para que "set -e" y "exit" no alteren el entrypoint.
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    bash "${BASH_SOURCE[0]}"
    return $?
fi

set -euo pipefail

SQL_DIR=/opt/tienda/sql
PDB=FREEPDB1                         # PDB por defecto de Oracle Free (en XE era XEPDB1)
TIENDA_TEC_PWD_INICIAL="Tienda2026"  # definida en CREATE_CONNECTION.sql
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8   # tildes y enes correctas

SCRIPTS_TIENDA_TEC=(
    QUERY_TABLAS SECUENCIAS TRIGGERS FUNCIONES TRIGGERS_NEGOCIO DATOS_INICIALES
    PROCEDIMIENTOS PAQUETES VISTAS ROLES_BD DATOS_MOVIMIENTOS
)

# Ejecuta un archivo .sql con SQL*Plus; se detiene ante el primer error.
# Los scripts tienen fin de linea Windows (CRLF), por eso se eliminan los \r.
ejecutar() {
    local conexion="$1" archivo="$2" contenido="$3"
    echo ">>> Ejecutando ${archivo}"
    {
        echo "SET DEFINE OFF"
        echo "SET SQLBLANKLINES ON"
        echo "SET FEEDBACK OFF"
        echo "WHENEVER SQLERROR EXIT FAILURE ROLLBACK"
        printf '%s\n' "$contenido"
        echo "EXIT"
    } | sqlplus -s -L "$conexion"
}

# 1. Usuario propietario del esquema (como SYS). Se ajusta el nombre del PDB.
ejecutar "/ as sysdba" CREATE_CONNECTION \
    "$(tr -d '\r' < "$SQL_DIR/CREATE_CONNECTION.sql" | sed "s/XEPDB1/${PDB}/")"

# 2. Objetos y datos del esquema (como TIENDA_TEC)
for nombre in "${SCRIPTS_TIENDA_TEC[@]}"; do
    ejecutar "TIENDA_TEC/\"${TIENDA_TEC_PWD_INICIAL}\"@//localhost:1521/${PDB}" "$nombre" \
        "$(tr -d '\r' < "$SQL_DIR/${nombre}.sql")"
done

# 3. Verificacion: no debe quedar ningun objeto invalido (paquetes, triggers, vistas...)
invalidos=$(sqlplus -s -L "TIENDA_TEC/\"${TIENDA_TEC_PWD_INICIAL}\"@//localhost:1521/${PDB}" <<'SQL'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT object_type || ' ' || object_name FROM user_objects WHERE status = 'INVALID';
EXIT
SQL
)
if [[ -n "${invalidos//[[:space:]]/}" ]]; then
    echo "ERROR: objetos invalidos en TIENDA_TEC:"; echo "$invalidos"; exit 1
fi

# 4. Contrasenas de produccion: si se definen las variables, reemplazan las de desarrollo
for usuario in TIENDA_TEC TIENDA_APP TIENDA_ADMIN TIENDA_CONSULTA; do
    variable="${usuario}_PASSWORD"
    if [[ -n "${!variable:-}" ]]; then
        echo ">>> Cambiando contrasena de ${usuario}"
        ejecutar "/ as sysdba" "ALTER USER ${usuario}" \
            "ALTER SESSION SET CONTAINER = ${PDB};
ALTER USER ${usuario} IDENTIFIED BY \"${!variable}\";"
    fi
done

echo ">>> Base de datos TIENDA-TEC inicializada correctamente"
