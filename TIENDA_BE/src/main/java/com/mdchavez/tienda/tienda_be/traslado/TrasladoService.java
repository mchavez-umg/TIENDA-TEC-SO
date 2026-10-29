package com.mdchavez.tienda.tienda_be.traslado;

import com.mdchavez.tienda.tienda_be.seguridad.UsuarioActual;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.sql.CallableStatement;
import java.sql.Types;
import java.time.LocalDate;
import java.util.List;

@Service
public class TrasladoService {

    private static final String SELECT_CABECERA = """
            SELECT T.ID_TRASLADO, T.ID_SUCURSAL_ORIGEN, O.NOMBRE AS ORIGEN,
                   T.ID_SUCURSAL_DESTINO, D.NOMBRE AS DESTINO, T.FECHA, T.OBSERVACION, E.NOMBRE AS ESTADO
            FROM TRASLADO T
            JOIN SUCURSAL O ON O.ID_SUCURSAL = T.ID_SUCURSAL_ORIGEN
            JOIN SUCURSAL D ON D.ID_SUCURSAL = T.ID_SUCURSAL_DESTINO
            JOIN ESTADO E ON E.ID_ESTADO = T.ID_ESTADO
            """;

    private static final RowMapper<TrasladoResumen> RESUMEN = (rs, n) -> new TrasladoResumen(
            rs.getLong("ID_TRASLADO"), rs.getLong("ID_SUCURSAL_ORIGEN"), rs.getString("ORIGEN"),
            rs.getLong("ID_SUCURSAL_DESTINO"), rs.getString("DESTINO"),
            rs.getObject("FECHA", LocalDate.class), rs.getString("OBSERVACION"), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;
    private final UsuarioActual usuarioActual;

    public TrasladoService(JdbcTemplate jdbc, UsuarioActual usuarioActual) {
        this.jdbc = jdbc;
        this.usuarioActual = usuarioActual;
    }

    public List<TrasladoResumen> listar() {
        return jdbc.query(SELECT_CABECERA + " ORDER BY T.FECHA DESC, T.ID_TRASLADO DESC", RESUMEN);
    }

    public TrasladoDetalle obtener(long id) {
        TrasladoResumen cabecera;
        try {
            cabecera = jdbc.queryForObject(SELECT_CABECERA + " WHERE T.ID_TRASLADO = ?", RESUMEN, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Traslado no encontrado");
        }
        List<Linea> lineas = jdbc.query("""
                SELECT D.ID_PRODUCTO, PR.NOMBRE AS PRODUCTO, D.CANTIDAD
                FROM DETALLE_TRASLADO D
                JOIN PRODUCTO PR ON PR.ID_PRODUCTO = D.ID_PRODUCTO
                WHERE D.ID_TRASLADO = ?
                ORDER BY D.ID_DETALLE_TRASLADO
                """, (rs, n) -> new Linea(rs.getLong("ID_PRODUCTO"), rs.getString("PRODUCTO"),
                rs.getInt("CANTIDAD")), id);
        return new TrasladoDetalle(cabecera, lineas);
    }

    @Transactional
    public TrasladoDetalle registrar(TrasladoRequest req) {
        long idEmpleado = usuarioActual.idEmpleado();

        long idTraslado = jdbc.execute(
                (java.sql.Connection con) -> {
                    CallableStatement cs = con.prepareCall("{call PR_CREAR_TRASLADO(?, ?, ?, ?, ?)}");
                    cs.setLong(1, req.idSucursalOrigen());
                    cs.setLong(2, req.idSucursalDestino());
                    cs.setLong(3, idEmpleado);
                    cs.setString(4, req.observacion());
                    cs.registerOutParameter(5, Types.NUMERIC);
                    return cs;
                },
                (CallableStatement cs) -> {
                    cs.execute();
                    return cs.getLong(5);
                });

        for (TrasladoRequest.Linea l : req.lineas()) {
            jdbc.update("{call PR_AGREGAR_DETALLE_TRASLADO(?, ?, ?)}", idTraslado, l.idProducto(), l.cantidad());
        }
        return obtener(idTraslado);
    }

    public void recibir(long id) {
        jdbc.update("{call PR_RECIBIR_TRASLADO(?)}", id);
    }

    public void cancelar(long id) {
        jdbc.update("{call PR_CANCELAR_TRASLADO(?)}", id);
    }

    public record TrasladoResumen(long idTraslado, long idSucursalOrigen, String origen, long idSucursalDestino,
                                  String destino, LocalDate fecha, String observacion, String estado) {
    }

    public record Linea(long idProducto, String producto, int cantidad) {
    }

    public record TrasladoDetalle(TrasladoResumen traslado, List<Linea> lineas) {
    }
}
