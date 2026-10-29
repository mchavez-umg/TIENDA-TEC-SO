package com.mdchavez.tienda.tienda_be.compra;

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
public class CompraService {

    private static final String SELECT_CABECERA = """
            SELECT C.ID_COMPRA, C.ID_PROVEEDOR, P.NOMBRE AS PROVEEDOR, C.ID_SUCURSAL, S.NOMBRE AS SUCURSAL,
                   C.NO_DOCUMENTO, C.FECHA, C.TOTAL, E.NOMBRE AS ESTADO
            FROM COMPRA C
            JOIN PROVEEDOR P ON P.ID_PROVEEDOR = C.ID_PROVEEDOR
            JOIN SUCURSAL S ON S.ID_SUCURSAL = C.ID_SUCURSAL
            JOIN ESTADO E ON E.ID_ESTADO = C.ID_ESTADO
            """;

    private static final RowMapper<CompraResumen> RESUMEN = (rs, n) -> new CompraResumen(
            rs.getLong("ID_COMPRA"), rs.getLong("ID_PROVEEDOR"), rs.getString("PROVEEDOR"),
            rs.getLong("ID_SUCURSAL"), rs.getString("SUCURSAL"), rs.getString("NO_DOCUMENTO"),
            rs.getObject("FECHA", LocalDate.class), rs.getBigDecimal("TOTAL"), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;
    private final UsuarioActual usuarioActual;

    public CompraService(JdbcTemplate jdbc, UsuarioActual usuarioActual) {
        this.jdbc = jdbc;
        this.usuarioActual = usuarioActual;
    }

    public List<CompraResumen> listar() {
        return jdbc.query(SELECT_CABECERA + " ORDER BY C.FECHA DESC, C.ID_COMPRA DESC", RESUMEN);
    }

    public CompraDetalle obtener(long id) {
        CompraResumen cabecera;
        try {
            cabecera = jdbc.queryForObject(SELECT_CABECERA + " WHERE C.ID_COMPRA = ?", RESUMEN, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Compra no encontrada");
        }
        List<Linea> lineas = jdbc.query("""
                SELECT D.ID_PRODUCTO, PR.NOMBRE AS PRODUCTO, D.CANTIDAD, D.COSTO_UNITARIO, D.SUBTOTAL
                FROM DETALLE_COMPRA D
                JOIN PRODUCTO PR ON PR.ID_PRODUCTO = D.ID_PRODUCTO
                WHERE D.ID_COMPRA = ?
                ORDER BY D.ID_DETALLE_COMPRA
                """, (rs, n) -> new Linea(rs.getLong("ID_PRODUCTO"), rs.getString("PRODUCTO"),
                rs.getInt("CANTIDAD"), rs.getBigDecimal("COSTO_UNITARIO"), rs.getBigDecimal("SUBTOTAL")), id);
        return new CompraDetalle(cabecera, lineas);
    }

    @Transactional
    public CompraDetalle registrar(CompraRequest req) {
        long idEmpleado = usuarioActual.idEmpleado();

        long idCompra = jdbc.execute(
                (java.sql.Connection con) -> {
                    CallableStatement cs = con.prepareCall("{call PR_CREAR_COMPRA(?, ?, ?, ?, ?)}");
                    cs.setLong(1, req.idProveedor());
                    cs.setLong(2, req.idSucursal());
                    cs.setLong(3, idEmpleado);
                    cs.setString(4, req.noDocumento());
                    cs.registerOutParameter(5, Types.NUMERIC);
                    return cs;
                },
                (CallableStatement cs) -> {
                    cs.execute();
                    return cs.getLong(5);
                });

        for (CompraRequest.Linea l : req.lineas()) {
            jdbc.update("{call PR_AGREGAR_DETALLE_COMPRA(?, ?, ?, ?)}",
                    idCompra, l.idProducto(), l.cantidad(), l.costoUnitario());
        }
        return obtener(idCompra);
    }

    public void recibir(long id) {
        jdbc.update("{call PR_RECIBIR_COMPRA(?)}", id);
    }

    public void anular(long id) {
        jdbc.update("{call PR_ANULAR_COMPRA(?)}", id);
    }

    public record CompraResumen(long idCompra, long idProveedor, String proveedor, long idSucursal, String sucursal,
                                String noDocumento, LocalDate fecha, BigDecimal total, String estado) {
    }

    public record Linea(long idProducto, String producto, int cantidad, BigDecimal costoUnitario, BigDecimal subtotal) {
    }

    public record CompraDetalle(CompraResumen compra, List<Linea> lineas) {
    }
}
