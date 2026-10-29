package com.mdchavez.tienda.tienda_be.usuario;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public final class UsuarioRequests {

    private UsuarioRequests() {
    }

    public record Crear(
            @NotNull @Positive Long idEmpleado,
            @NotNull @Positive Long idRol,
            @NotBlank @Size(min = 4, max = 30) String username,
            @NotBlank @Size(min = 6, max = 72) String password) {
    }

    public record Actualizar(
            @NotNull @Positive Long idRol,
            @NotBlank @Size(min = 4, max = 30) String username) {
    }

    public record Clave(
            @NotBlank @Size(min = 6, max = 72) String password) {
    }
}
