#!/bin/sh
# Si no se monto el certificado de origen de Cloudflare en /etc/nginx/certs (Paso 9),
# genera uno autofirmado para que Nginx pueda arrancar en pruebas locales.
set -e

CERT=/etc/nginx/certs/origen.pem
LLAVE=/etc/nginx/certs/origen.key

if [ -f "$CERT" ] && [ -f "$LLAVE" ]; then
    echo "$0: usando el certificado montado en /etc/nginx/certs"
    exit 0
fi

echo "$0: no hay certificado en /etc/nginx/certs, se genera uno AUTOFIRMADO (solo pruebas)"
mkdir -p /etc/nginx/certs
openssl req -x509 -nodes -newkey rsa:2048 -days 30 -subj "/CN=localhost" \
    -keyout "$LLAVE" -out "$CERT" 2>/dev/null
chmod 600 "$LLAVE"
