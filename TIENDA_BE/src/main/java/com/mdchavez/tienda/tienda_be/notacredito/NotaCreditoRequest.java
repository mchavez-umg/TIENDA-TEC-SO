package com.mdchavez.tienda.tienda_be.notacredito;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.util.List;

public record NotaCreditoRequest(
        @NotNull @Positive Long idFactura,
        @NotBlank @Size(max = 200) String motivo,
        @NotEmpty List<@Valid Linea> lineas) {

    public record Linea(
            @NotNull @Positive Long idDetalleFactura,
            @NotNull @Positive Integer cantidad,
            @Pattern(regexp = "[SN]", message = "debe ser S o N") String reingresaInventario) {
    }
}
