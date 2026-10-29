package com.mdchavez.tienda.tienda_be.producto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record ProductoRequest(
        @NotNull @Positive Long idCategoria,
        @NotNull @Positive Long idMarca,
        @NotBlank @Size(max = 20) String codigo,
        @NotBlank @Size(max = 120) String nombre,
        @Size(max = 300) String descripcion,
        @NotNull @PositiveOrZero BigDecimal precioCosto,
        @NotNull @PositiveOrZero BigDecimal precioVenta,
        @NotNull @Min(0) @Max(120) Integer mesesGarantia) {
}
