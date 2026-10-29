package com.mdchavez.tienda.tienda_be.sucursal;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record SucursalRequest(
        @NotNull @Positive Long idMunicipio,
        @NotBlank @Size(max = 10) String codigo,
        @NotBlank @Size(max = 100) String nombre,
        @NotBlank @Size(max = 200) String direccion,
        @Size(max = 15) String telefono,
        @Email @Size(max = 100) String correo,
        @NotNull LocalDate fechaApertura) {
}
