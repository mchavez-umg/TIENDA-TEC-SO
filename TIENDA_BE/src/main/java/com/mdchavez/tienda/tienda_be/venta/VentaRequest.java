package com.mdchavez.tienda.tienda_be.venta;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;

import java.math.BigDecimal;
import java.util.List;

public record VentaRequest(
        @NotNull @Positive Long idSucursal,
        @NotNull @Positive Long idCliente,
        @NotEmpty List<@Valid Linea> lineas,
        @NotEmpty List<@Valid Pago> pagos) {

    public record Linea(
            @NotNull @Positive Long idProducto,
            @NotNull @Positive Integer cantidad,
            @PositiveOrZero BigDecimal descuento) {
    }

    public record Pago(
            @NotNull @Positive Long idFormaPago,
            @NotNull @Positive BigDecimal monto,
            Long idBanco,
            String noReferencia,
            String noAutorizacion) {
    }
}
