package com.mdchavez.tienda.tienda_be.opcionmenu;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

public record OpcionMenuRequest(
        @Positive Long idOpcionPadre,
        @NotBlank @Size(max = 60) String nombre,
        @Size(max = 100) String ruta,
        @Size(max = 50) String icono,
        @NotNull @PositiveOrZero Integer orden) {
}
