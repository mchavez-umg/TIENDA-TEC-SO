package com.mdchavez.tienda.tienda_be.cliente;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ClienteRequest(
        @NotBlank @Size(max = 15) String nit,
        @NotBlank @Size(max = 80) String nombres,
        @Size(max = 80) String apellidos,
        @Size(max = 15) String telefono,
        @Email @Size(max = 100) String correo,
        @Size(max = 200) String direccion) {
}
