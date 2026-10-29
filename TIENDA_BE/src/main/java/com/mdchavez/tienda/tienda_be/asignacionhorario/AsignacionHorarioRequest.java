package com.mdchavez.tienda.tienda_be.asignacionhorario;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.time.LocalDate;

public record AsignacionHorarioRequest(
        @NotNull @Positive Long idEmpleado,
        @NotNull @Positive Long idHorario,
        @NotNull LocalDate fechaInicio,
        LocalDate fechaFin) {
}
