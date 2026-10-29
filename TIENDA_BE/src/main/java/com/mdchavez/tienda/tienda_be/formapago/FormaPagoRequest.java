package com.mdchavez.tienda.tienda_be.formapago;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record FormaPagoRequest(
        @NotBlank @Size(max = 30) String nombre,
        @NotBlank @Pattern(regexp = "[SN]", message = "debe ser S o N") String requiereReferencia) {
}
