package com.mdchavez.tienda.tienda_be.venta;

import com.mdchavez.tienda.tienda_be.seguridad.UsuarioActual;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class VentaService {

    private static final String SELECT_CABECERA = """
            SELECT F.ID_FACTURA, F.SERIE, F.NUMERO, F.FECHA, F.ID_SUCURSAL, S.NOMBRE AS SUCURSAL,
                   F.ID_CLIENTE, C.NIT, C.NOMBRES || NVL2(C.APELLIDOS, ' ' || C.APELLIDOS, '') AS CLIENTE,
                   E.NOMBRES || ' ' || E.APELLIDOS AS EMPLEADO, F.SUBTOTAL, F.IVA, F.TOTAL, ES.NOMBRE AS ESTADO
            FROM FACTURA F
            JOIN SUCURSAL S ON S.ID_SUCURSAL = F.ID_SUCURSAL
            JOIN CLIENTE C ON C.ID_CLIENTE = F.ID_CLIENTE
            JOIN EMPLEADO E ON E.ID_EMPLEADO = F.ID_EMPLEADO
            JOIN ESTADO ES ON ES.ID_ESTADO = F.ID_ESTADO
            """;

    private static final RowMapper<FacturaResumen> RESUMEN = (rs, n) -> new FacturaResumen(
            rs.getLong("ID_FACTURA"), rs.getString("SERIE"), rs.getLong("NUMERO"),
            rs.getObject("FECHA", LocalDateTime.class), rs.getLong("ID_SUCURSAL"), rs.getString("SUCURSAL"),
            rs.getLong("ID_CLIENTE"), rs.getString("NIT"), rs.getString("CLIENTE"), rs.getString("EMPLEADO"),
            rs.getBigDecimal("SUBTOTAL"), rs.getBigDecimal("IVA"), rs.getBigDecimal("TOTAL"),
            rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;
    private final UsuarioActual usuarioActual;

    public VentaService(JdbcTemplate jdbc, UsuarioActual usuarioActual) {
        this.jdbc = jdbc;
        this.usuarioActual = usuarioActual;
    }

    public List<FacturaResumen> listar(LocalDate desde, LocalDate hasta, Long idSucursal) {
        List<String> condiciones = new ArrayList<>();
        List<Object> parametros = new ArrayList<>();
        if (desde != null) {
            condiciones.add("F.FECHA >= ?");
            parametros.add(desde);
        }
        if (hasta != null) {
            condiciones.add("F.FECHA < ?");
            parametros.add(hasta.plusDays(1));
        }
        if (idSucursal != null) {
            condiciones.add("F.ID_SUCURSAL = ?");
            parametros.add(idSucursal);
        }
        String where = condiciones.isEmpty() ? "" : " WHERE " + String.join(" AND ", condiciones);
        return jdbc.query(SELECT_CABECERA + where + " ORDER BY F.FECHA DESC, F.ID_FACTURA DESC",
                RESUMEN, parametros.toArray());
    }

    public FacturaDetalle obtener(long id) {
        FacturaResumen cabecera;
        try {
            cabecera = jdbc.queryForObject(SELECT_CABECERA + " WHERE F.ID_FACTURA = ?", RESUMEN, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Factura no encontrada");
        }
        List<LineaFactura> lineas = jdbc.query("""
                SELECT D.ID_DETALLE_FACTURA, D.ID_PRODUCTO, P.CODIGO, P.NOMBRE, D.CANTIDAD, D.PRECIO_UNITARIO,
                       D.DESCUENTO, D.SUBTOTAL, D.FECHA_INICIO_GARANTIA, D.FECHA_FIN_GARANTIA,
                       FN_CANTIDAD_PENDIENTE_NC(D.ID_DETALLE_FACTURA) AS PENDIENTE_NC,
                       FN_GARANTIA_VIGENTE(D.ID_DETALLE_FACTURA) AS GARANTIA_VIGENTE
                FROM DETALLE_FACTURA D
                JOIN PRODUCTO P ON P.ID_PRODUCTO = D.ID_PRODUCTO
                WHERE D.ID_FACTURA = ?
                ORDER BY D.ID_DETALLE_FACTURA
                """, (rs, n) -> new LineaFactura(rs.getLong("ID_DETALLE_FACTURA"), rs.getLong("ID_PRODUCTO"),
                rs.getString("CODIGO"), rs.getString("NOMBRE"), rs.getInt("CANTIDAD"),
                rs.getBigDecimal("PRECIO_UNITARIO"), rs.getBigDecimal("DESCUENTO"), rs.getBigDecimal("SUBTOTAL"),
                rs.getObject("FECHA_INICIO_GARANTIA", LocalDate.class),
                rs.getObject("FECHA_FIN_GARANTIA", LocalDate.class), rs.getInt("PENDIENTE_NC"),
                "S".equals(rs.getString("GARANTIA_VIGENTE"))), id);
        List<PagoFactura> pagos = jdbc.query("""
                SELECT PG.ID_PAGO, FP.NOMBRE AS FORMA_PAGO, B.NOMBRE AS BANCO, PG.MONTO, PG.NO_REFERENCIA,
                       PG.NO_AUTORIZACION
                FROM PAGO PG
                JOIN FORMA_PAGO FP ON FP.ID_FORMA_PAGO = PG.ID_FORMA_PAGO
                LEFT JOIN BANCO B ON B.ID_BANCO = PG.ID_BANCO
                WHERE PG.ID_FACTURA = ?
                ORDER BY PG.ID_PAGO
                """, (rs, n) -> new PagoFactura(rs.getLong("ID_PAGO"), rs.getString("FORMA_PAGO"),
                rs.getString("BANCO"), rs.getBigDecimal("MONTO"), rs.getString("NO_REFERENCIA"),
                rs.getString("NO_AUTORIZACION")), id);
        return new FacturaDetalle(cabecera, lineas, pagos);
    }

    @Transactional
    public VentaResponse registrar(VentaRequest req) {
        long idEmpleado = usuarioActual.idEmpleado();

        long idFactura = jdbc.execute(
                (java.sql.Connection con) -> {
                    CallableStatement cs = con.prepareCall("{call PR_CREAR_FACTURA(?, ?, ?, ?)}");
                    cs.setLong(1, req.idSucursal());
                    cs.setLong(2, req.idCliente());
                    cs.setLong(3, idEmpleado);
                    cs.registerOutParameter(4, Types.NUMERIC);
                    return cs;
                },
                (CallableStatement cs) -> {
                    cs.execute();
                    return cs.getLong(4);
                });

        for (VentaRequest.Linea l : req.lineas()) {
            jdbc.update("{call PR_AGREGAR_DETALLE_FACTURA(?, ?, ?, ?)}",
                    idFactura, l.idProducto(), l.cantidad(),
                    l.descuento() != null ? l.descuento() : BigDecimal.ZERO);
        }

        for (VentaRequest.Pago p : req.pagos()) {
            jdbc.update("{call PR_REGISTRAR_PAGO(?, ?, ?, ?, ?, ?)}",
                    idFactura, p.idFormaPago(), p.monto(), p.idBanco(), p.noReferencia(), p.noAutorizacion());
        }

        jdbc.update("{call PR_FINALIZAR_FACTURA(?)}", idFactura);

        return jdbc.queryForObject(
                "SELECT ID_FACTURA, SERIE, NUMERO, TOTAL FROM FACTURA WHERE ID_FACTURA = ?",
                (rs, n) -> new VentaResponse(rs.getLong("ID_FACTURA"), rs.getString("SERIE"),
                        rs.getLong("NUMERO"), rs.getBigDecimal("TOTAL")),
                idFactura);
    }

    public record VentaResponse(long idFactura, String serie, long numero, BigDecimal total) {
    }

    public record FacturaResumen(long idFactura, String serie, long numero, LocalDateTime fecha, long idSucursal,
                                 String sucursal, long idCliente, String nit, String cliente, String empleado,
                                 BigDecimal subtotal, BigDecimal iva, BigDecimal total, String estado) {
    }

    public record LineaFactura(long idDetalleFactura, long idProducto, String codigo, String producto, int cantidad,
                               BigDecimal precioUnitario, BigDecimal descuento, BigDecimal subtotal,
                               LocalDate inicioGarantia, LocalDate finGarantia, int pendienteNc,
                               boolean garantiaVigente) {
    }

    public record PagoFactura(long idPago, String formaPago, String banco, BigDecimal monto, String noReferencia,
                              String noAutorizacion) {
    }

    public record FacturaDetalle(FacturaResumen factura, List<LineaFactura> lineas, List<PagoFactura> pagos) {
    }
}
