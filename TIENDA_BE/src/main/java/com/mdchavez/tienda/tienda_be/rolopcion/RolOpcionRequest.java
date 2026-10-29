package com.mdchavez.tienda.tienda_be.rolopcion;

import jakarta.validation.constraints.Pattern;

public record RolOpcionRequest(
        @Pattern(regexp = "[SN]", message = "debe ser S o N") String puedeConsultar,
        @Pattern(regexp = "[SN]", message = "debe ser S o N") String puedeCrear,
        @Pattern(regexp = "[SN]", message = "debe ser S o N") String puedeEditar,
        @Pattern(regexp = "[SN]", message = "debe ser S o N") String puedeEliminar) {
}
