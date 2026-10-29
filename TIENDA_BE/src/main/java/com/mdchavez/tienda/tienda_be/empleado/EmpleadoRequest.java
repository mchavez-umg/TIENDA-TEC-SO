package com.mdchavez.tienda.tienda_be.empleado;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record EmpleadoRequest(
        @NotNull @Positive Long idSucursal,
        @NotNull @Positive Long idPuesto,
        @NotBlank @Size(min = 13, max = 13) String dpi,
        @NotBlank @Size(max = 80) String nombres,
        @NotBlank @Size(max = 80) String apellidos,
        @Size(max = 15) String telefono,
        @Email @Size(max = 100) String correo,
        @Size(max = 200) String direccion,
        @NotNull LocalDate fechaIngreso) {
}
