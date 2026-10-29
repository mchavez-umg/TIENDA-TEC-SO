# ============================================================
# TIENDA-TEC - Proxy inverso y balanceador de carga (Nginx)
# Termina HTTPS y reparte las peticiones entre las replicas:
#   /api/*  -> backend  (tienda-be-1, tienda-be-2)
#   resto   -> frontend (tienda-fe-1, tienda-fe-2)
# Imagen base multi-arquitectura (amd64 local / arm64 en OCI Ampere).
# ============================================================
FROM nginx:1.31-alpine

# openssl: solo para generar un certificado autofirmado si no se monta el de Cloudflare
RUN apk add --no-cache openssl \
    && rm /etc/nginx/conf.d/default.conf

COPY conf.d/tienda.conf /etc/nginx/conf.d/tienda.conf
COPY snippets/cloudflare-ips.conf /etc/nginx/snippets/cloudflare-ips.conf
COPY --chmod=755 40-certificado-autofirmado.sh /docker-entrypoint.d/

EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1/nginx-salud || exit 1
