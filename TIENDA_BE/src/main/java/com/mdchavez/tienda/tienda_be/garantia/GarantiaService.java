package com.mdchavez.tienda.tienda_be.garantia;

import com.mdchavez.tienda.tienda_be.seguridad.UsuarioActual;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.sql.CallableStatement;
import java.sql.Types;
import java.time.LocalDate;
import java.util.List;

@Service
public class GarantiaService {

    private static final String SELECT = """
            SELECT G.ID_GARANTIA, G.ID_DETALLE_FACTURA, PR.NOMBRE AS PRODUCTO, G.DESCRIPCION_FALLA,
                   G.TIPO_RESOLUCION, G.ID_PRODUCTO_REEMPLAZO, PRE.NOMBRE AS PRODUCTO_REEMPLAZO,
                   G.FECHA_RECLAMO, G.FECHA_RESOLUCION, G.OBSERVACIONES, E.NOMBRE AS ESTADO,
                   F.SERIE || '-' || F.NUMERO AS FACTURA,
                   C.NOMBRES || NVL2(C.APELLIDOS, ' ' || C.APELLIDOS, '') AS CLIENTE
            FROM GARANTIA G
            JOIN DETALLE_FACTURA DF ON DF.ID_DETALLE_FACTURA = G.ID_DETALLE_FACTURA
            JOIN FACTURA F ON F.ID_FACTURA = DF.ID_FACTURA
            JOIN CLIENTE C ON C.ID_CLIENTE = F.ID_CLIENTE
            JOIN PRODUCTO PR ON PR.ID_PRODUCTO = DF.ID_PRODUCTO
            LEFT JOIN PRODUCTO PRE ON PRE.ID_PRODUCTO = G.ID_PRODUCTO_REEMPLAZO
            JOIN ESTADO E ON E.ID_ESTADO = G.ID_ESTADO
            """;

    private static final RowMapper<GarantiaResponse> MAPPER = (rs, n) -> new GarantiaResponse(
            rs.getLong("ID_GARANTIA"), rs.getLong("ID_DETALLE_FACTURA"), rs.getString("PRODUCTO"),
            rs.getString("DESCRIPCION_FALLA"), rs.getString("TIPO_RESOLUCION"),
            rs.getObject("ID_PRODUCTO_REEMPLAZO", Long.class), rs.getString("PRODUCTO_REEMPLAZO"),
            rs.getObject("FECHA_RECLAMO", LocalDate.class), rs.getObject("FECHA_RESOLUCION", LocalDate.class),
            rs.getString("OBSERVACIONES"), rs.getString("ESTADO"), rs.getString("FACTURA"),
            rs.getString("CLIENTE"));

    private final JdbcTemplate jdbc;
    private final UsuarioActual usuarioActual;

    public GarantiaService(JdbcTemplate jdbc, UsuarioActual usuarioActual) {
        this.jdbc = jdbc;
        this.usuarioActual = usuarioActual;
    }

    public List<GarantiaResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY G.FECHA_RECLAMO DESC, G.ID_GARANTIA DESC", MAPPER);
    }

    public GarantiaResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE G.ID_GARANTIA = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Garantía no encontrada");
        }
    }

    public GarantiaResponse registrarReclamo(GarantiaRequests.Reclamo req) {
        long idEmpleado = usuarioActual.idEmpleado();
        long id = jdbc.execute(
                (java.sql.Connection con) -> {
                    CallableStatement cs = con.prepareCall("{call PKG_GARANTIAS.PR_REGISTRAR_RECLAMO(?, ?, ?, ?)}");
                    cs.setLong(1, req.idDetalleFactura());
                    cs.setLong(2, idEmpleado);
                    cs.setString(3, req.descripcionFalla());
                    cs.registerOutParameter(4, Types.NUMERIC);
                    return cs;
                },
                (CallableStatement cs) -> {
                    cs.execute();
                    return cs.getLong(4);
                });
        return obtener(id);
    }

    public GarantiaResponse pasarARevision(long id) {
        jdbc.update("{call PKG_GARANTIAS.PR_PASAR_A_REVISION(?)}", id);
        return obtener(id);
    }

    public GarantiaResponse reparar(long id, String observaciones) {
        jdbc.update("{call PKG_GARANTIAS.PR_RESOLVER_REPARACION(?, ?)}", id, observaciones);
        return obtener(id);
    }

    public GarantiaResponse cambiar(long id, long idProductoReemplazo, String observaciones) {
        jdbc.update("{call PKG_GARANTIAS.PR_RESOLVER_CAMBIO(?, ?, ?)}", id, idProductoReemplazo, observaciones);
        return obtener(id);
    }

    public GarantiaResponse rechazar(long id, String observaciones) {
        jdbc.update("{call PKG_GARANTIAS.PR_RECHAZAR(?, ?)}", id, observaciones);
        return obtener(id);
    }

    public GarantiaResponse entregar(long id) {
        jdbc.update("{call PKG_GARANTIAS.PR_ENTREGAR(?)}", id);
        return obtener(id);
    }

    public record GarantiaResponse(long idGarantia, long idDetalleFactura, String producto, String descripcionFalla,
                                   String tipoResolucion, Long idProductoReemplazo, String productoReemplazo,
                                   LocalDate fechaReclamo, LocalDate fechaResolucion, String observaciones,
                                   String estado, String factura, String cliente) {
    }
}
