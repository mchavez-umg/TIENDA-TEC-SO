package com.mdchavez.tienda.tienda_be.municipio;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record MunicipioRequest(
        @NotNull @Positive Long idDepartamento,
        @NotBlank @Size(max = 80) String nombre,
        @Pattern(regexp = "[SN]", message = "debe ser S o N") String esCabecera) {
}
