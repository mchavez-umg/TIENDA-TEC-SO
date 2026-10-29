package com.mdchavez.tienda.tienda_be.horario;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record HorarioRequest(
        @NotBlank @Size(max = 50) String nombre,
        @NotBlank @Pattern(regexp = "([01]\\d|2[0-3]):[0-5]\\d", message = "formato HH:MM") String horaEntrada,
        @NotBlank @Pattern(regexp = "([01]\\d|2[0-3]):[0-5]\\d", message = "formato HH:MM") String horaSalida,
        @NotBlank @Size(max = 30) String diasSemana) {
}
