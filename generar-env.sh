#!/bin/sh
# Crea el archivo .env con contrasenas aleatorias seguras.
# Uso: ./generar-env.sh midominio.com
set -e

if [ -f .env ]; then
    echo "Ya existe .env; no se sobrescribe (borrarlo manualmente si se quiere regenerar)." >&2
    exit 1
fi
if [ -z "$1" ]; then
    echo "Uso: $0 <dominio>   (ejemplo: $0 midominio.com)" >&2
    exit 1
fi

# Genera una cadena aleatoria de N caracteres alfanumericos que empieza con letra
# (Oracle no acepta contrasenas que inicien con numero sin comillas).
aleatorio() {
    printf 'T%s' "$(openssl rand -base64 64 | tr -dc 'A-Za-z0-9' | cut -c1-$(($1 - 1)))"
}

umask 077   # .env solo legible por el propietario
cat > .env <<FIN
DOMINIO=$1
ORACLE_PASSWORD=$(aleatorio 24)
TIENDA_TEC_PASSWORD=$(aleatorio 24)
TIENDA_APP_PASSWORD=$(aleatorio 24)
TIENDA_ADMIN_PASSWORD=$(aleatorio 24)
TIENDA_CONSULTA_PASSWORD=$(aleatorio 24)
REDIS_PASSWORD=$(aleatorio 32)
JWT_SECRET=$(aleatorio 64)
FIN

echo ".env creado (permisos 600). Guardar una copia de las contrasenas en un lugar seguro."
