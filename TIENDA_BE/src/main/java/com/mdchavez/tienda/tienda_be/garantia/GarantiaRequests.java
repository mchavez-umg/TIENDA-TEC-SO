package com.mdchavez.tienda.tienda_be.garantia;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public final class GarantiaRequests {

    private GarantiaRequests() {
    }

    public record Reclamo(
            @NotNull @Positive Long idDetalleFactura,
            @NotBlank @Size(max = 300) String descripcionFalla) {
    }

    public record Resolucion(
            @Size(max = 300) String observaciones) {
    }

    public record Cambio(
            @NotNull @Positive Long idProductoReemplazo,
            @Size(max = 300) String observaciones) {
    }
}
