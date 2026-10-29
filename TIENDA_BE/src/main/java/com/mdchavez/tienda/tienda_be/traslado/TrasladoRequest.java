package com.mdchavez.tienda.tienda_be.traslado;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.util.List;

public record TrasladoRequest(
        @NotNull @Positive Long idSucursalOrigen,
        @NotNull @Positive Long idSucursalDestino,
        @Size(max = 200) String observacion,
        @NotEmpty List<@Valid Linea> lineas) {

    public record Linea(
            @NotNull @Positive Long idProducto,
            @NotNull @Positive Integer cantidad) {
    }
}
