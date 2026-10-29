package com.mdchavez.tienda.tienda_be.categoria;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CategoriaRequest(
        @NotBlank @Size(max = 60) String nombre,
        @Size(max = 200) String descripcion) {
}
