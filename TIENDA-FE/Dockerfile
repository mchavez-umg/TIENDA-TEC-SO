# ============================================================
# TIENDA-FE - Imagen Docker del frontend (Angular 22 con servidor Node)
# Construccion multi-etapa: compila con Angular CLI y ejecuta solo el
# servidor Node generado (dist/), sin codigo fuente ni dependencias de desarrollo.
# Imagen base multi-arquitectura (amd64 local / arm64 en OCI Ampere).
# ============================================================

# ---------- Etapa 1: compilacion ----------
FROM node:24-alpine AS build
WORKDIR /app

# Copiar primero los manifiestos para cachear node_modules en una capa propia
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund

# Copiar el codigo fuente y compilar en modo produccion
COPY . .
RUN npx ng build --configuration production

# ---------- Etapa 2: ejecucion ----------
FROM node:24-alpine
WORKDIR /app

# NG_ALLOWED_HOSTS: dominios aceptados en el encabezado Host (proteccion SSRF de Angular).
# En Docker Compose se sobrescribe agregando el dominio publico.
ENV NODE_ENV=production \
    PORT=4000 \
    NG_ALLOWED_HOSTS=localhost,127.0.0.1 \
    TZ=America/Guatemala

# El servidor generado por Angular ya incluye sus dependencias (express),
# por lo que solo se copia la carpeta dist. Se ejecuta con el usuario "node" (sin root).
COPY --from=build --chown=node:node /app/dist/TIENDA-FE ./dist/TIENDA-FE
USER node

EXPOSE 4000

CMD ["node", "dist/TIENDA-FE/server/server.mjs"]
