package com.mdchavez.tienda.tienda_be.proveedor;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ProveedorRequest(
        @NotBlank @Size(max = 15) String nit,
        @NotBlank @Size(max = 120) String nombre,
        @Size(max = 100) String contacto,
        @Size(max = 15) String telefono,
        @Email @Size(max = 100) String correo,
        @Size(max = 200) String direccion) {
}
