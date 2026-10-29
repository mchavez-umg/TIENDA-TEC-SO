# ============================================================
# TIENDA_BE - Imagen Docker del backend (Spring Boot 4 / Java 21)
# Construccion multi-etapa: compila con Maven y ejecuta solo con JRE.
# Imagenes base multi-arquitectura (amd64 local / arm64 en OCI Ampere).
# ============================================================

# ---------- Etapa 1: compilacion ----------
FROM maven:3.9.11-eclipse-temurin-21 AS build
WORKDIR /app

# Copiar primero el pom para cachear las dependencias en una capa propia
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

# Copiar el codigo fuente y empaquetar (las pruebas requieren BD, se omiten)
COPY src ./src
RUN mvn -B -q package -DskipTests \
    && cp target/*.jar app.jar

# ---------- Etapa 2: ejecucion ----------
FROM eclipse-temurin:21-jre
WORKDIR /app

# Usuario sin privilegios (seguridad: no ejecutar como root)
RUN groupadd --system tienda && useradd --system --gid tienda --no-create-home tienda

COPY --from=build /app/app.jar app.jar
RUN chown tienda:tienda app.jar
USER tienda

# Ajuste de memoria de la JVM al limite del contenedor
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0 -XX:+UseContainerSupport" \
    TZ=America/Guatemala

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.jar"]
