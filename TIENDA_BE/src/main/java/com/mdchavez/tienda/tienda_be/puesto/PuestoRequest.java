package com.mdchavez.tienda.tienda_be.puesto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record PuestoRequest(
        @NotBlank @Size(max = 60) String nombre,
        @Size(max = 200) String descripcion,
        @NotNull @PositiveOrZero BigDecimal salarioBase) {
}
