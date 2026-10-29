package com.mdchavez.tienda.tienda_be.banco;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record BancoRequest(@NotBlank @Size(max = 80) String nombre) {
}
