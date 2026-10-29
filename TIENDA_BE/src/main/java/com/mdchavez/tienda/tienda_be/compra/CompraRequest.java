package com.mdchavez.tienda.tienda_be.compra;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.util.List;

public record CompraRequest(
        @NotNull @Positive Long idProveedor,
        @NotNull @Positive Long idSucursal,
        @NotBlank @Size(max = 30) String noDocumento,
        @NotEmpty List<@Valid Linea> lineas) {

    public record Linea(
            @NotNull @Positive Long idProducto,
            @NotNull @Positive Integer cantidad,
            @NotNull @PositiveOrZero BigDecimal costoUnitario) {
    }
}
