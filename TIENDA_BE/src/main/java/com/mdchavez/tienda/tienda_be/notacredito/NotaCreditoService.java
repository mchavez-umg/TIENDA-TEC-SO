package com.mdchavez.tienda.tienda_be.notacredito;

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
import java.util.List;

@Service
public class NotaCreditoService {

    private static final String SELECT_CABECERA = """
            SELECT N.ID_NOTA_CREDITO, N.ID_FACTURA, N.SERIE, N.NUMERO, N.FECHA, N.MOTIVO, N.TOTAL,
                   E.NOMBRE AS ESTADO, F.SERIE || '-' || F.NUMERO AS FACTURA,
                   C.NOMBRES || NVL2(C.APELLIDOS, ' ' || C.APELLIDOS, '') AS CLIENTE
            FROM NOTA_CREDITO N
            JOIN ESTADO E ON E.ID_ESTADO = N.ID_ESTADO
            JOIN FACTURA F ON F.ID_FACTURA = N.ID_FACTURA
            JOIN CLIENTE C ON C.ID_CLIENTE = F.ID_CLIENTE
            """;

    private static final RowMapper<NotaResumen> RESUMEN = (rs, n) -> new NotaResumen(
            rs.getLong("ID_NOTA_CREDITO"), rs.getLong("ID_FACTURA"), rs.getString("SERIE"), rs.getLong("NUMERO"),
            rs.getObject("FECHA", LocalDate.class), rs.getString("MOTIVO"), rs.getBigDecimal("TOTAL"),
            rs.getString("ESTADO"), rs.getString("FACTURA"), rs.getString("CLIENTE"));

    private final JdbcTemplate jdbc;
    private final UsuarioActual usuarioActual;

    public NotaCreditoService(JdbcTemplate jdbc, UsuarioActual usuarioActual) {
        this.jdbc = jdbc;
        this.usuarioActual = usuarioActual;
    }

    public List<NotaResumen> listar() {
        return jdbc.query(SELECT_CABECERA + " ORDER BY N.FECHA DESC, N.ID_NOTA_CREDITO DESC", RESUMEN);
    }

    public NotaDetalle obtener(long id) {
        NotaResumen cabecera;
        try {
            cabecera = jdbc.queryForObject(SELECT_CABECERA + " WHERE N.ID_NOTA_CREDITO = ?", RESUMEN, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Nota de crédito no encontrada");
        }
        List<Linea> lineas = jdbc.query("""
                SELECT D.ID_DETALLE_FACTURA, PR.NOMBRE AS PRODUCTO, D.CANTIDAD, D.MONTO, D.REINGRESA_INVENTARIO
                FROM DETALLE_NOTA_CREDITO D
                JOIN DETALLE_FACTURA DF ON DF.ID_DETALLE_FACTURA = D.ID_DETALLE_FACTURA
                JOIN PRODUCTO PR ON PR.ID_PRODUCTO = DF.ID_PRODUCTO
                WHERE D.ID_NOTA_CREDITO = ?
                ORDER BY D.ID_DETALLE_NC
                """, (rs, n) -> new Linea(rs.getLong("ID_DETALLE_FACTURA"), rs.getString("PRODUCTO"),
                rs.getInt("CANTIDAD"), rs.getBigDecimal("MONTO"), rs.getString("REINGRESA_INVENTARIO")), id);
        return new NotaDetalle(cabecera, lineas);
    }

    @Transactional
    public NotaDetalle registrar(NotaCreditoRequest req) {
        long idEmpleado = usuarioActual.idEmpleado();

        long idNota = jdbc.execute(
                (java.sql.Connection con) -> {
                    CallableStatement cs = con.prepareCall("{call PR_CREAR_NOTA_CREDITO(?, ?, ?, ?)}");
                    cs.setLong(1, req.idFactura());
                    cs.setLong(2, idEmpleado);
                    cs.setString(3, req.motivo());
                    cs.registerOutParameter(4, Types.NUMERIC);
                    return cs;
                },
                (CallableStatement cs) -> {
                    cs.execute();
                    return cs.getLong(4);
                });

        for (NotaCreditoRequest.Linea l : req.lineas()) {
            String reingresa = l.reingresaInventario() != null ? l.reingresaInventario() : "S";
            jdbc.update("{call PR_AGREGAR_DETALLE_NC(?, ?, ?, ?)}",
                    idNota, l.idDetalleFactura(), l.cantidad(), reingresa);
        }

        jdbc.update("{call PR_FINALIZAR_NOTA_CREDITO(?)}", idNota);
        return obtener(idNota);
    }

    public record NotaResumen(long idNotaCredito, long idFactura, String serie, long numero, LocalDate fecha,
                              String motivo, BigDecimal total, String estado, String factura, String cliente) {
    }

    public record Linea(long idDetalleFactura, String producto, int cantidad, BigDecimal monto,
                        String reingresaInventario) {
    }

    public record NotaDetalle(NotaResumen notaCredito, List<Linea> lineas) {
    }
}
