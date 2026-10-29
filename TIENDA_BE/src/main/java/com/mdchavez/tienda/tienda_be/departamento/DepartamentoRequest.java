package com.mdchavez.tienda.tienda_be.departamento;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record DepartamentoRequest(@NotBlank @Size(max = 60) String nombre) {
}
