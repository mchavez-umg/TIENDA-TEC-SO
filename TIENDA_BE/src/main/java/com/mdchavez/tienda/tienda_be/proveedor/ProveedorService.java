package com.mdchavez.tienda.tienda_be.proveedor;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class ProveedorService {

    private static final String SELECT = """
            SELECT P.ID_PROVEEDOR, P.NIT, P.NOMBRE, P.CONTACTO, P.TELEFONO, P.CORREO, P.DIRECCION,
                   E.NOMBRE AS ESTADO
            FROM PROVEEDOR P
            JOIN ESTADO E ON E.ID_ESTADO = P.ID_ESTADO
            """;

    private static final RowMapper<ProveedorResponse> MAPPER = (rs, n) -> new ProveedorResponse(
            rs.getLong("ID_PROVEEDOR"), rs.getString("NIT"), rs.getString("NOMBRE"), rs.getString("CONTACTO"),
            rs.getString("TELEFONO"), rs.getString("CORREO"), rs.getString("DIRECCION"), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public ProveedorService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<ProveedorResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY P.NOMBRE", MAPPER);
    }

    public ProveedorResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE P.ID_PROVEEDOR = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Proveedor no encontrado");
        }
    }

    public ProveedorResponse crear(ProveedorRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_PROVEEDOR.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("""
                INSERT INTO PROVEEDOR (ID_PROVEEDOR, NIT, NOMBRE, CONTACTO, TELEFONO, CORREO, DIRECCION, ID_ESTADO)
                VALUES (?, ?, ?, ?, ?, ?, ?, FN_ID_ESTADO('PROVEEDOR', 'A'))
                """, id, req.nit(), req.nombre(), req.contacto(), req.telefono(), req.correo(), req.direccion());
        return obtener(id);
    }

    public ProveedorResponse actualizar(long id, ProveedorRequest req) {
        int filas = jdbc.update("""
                UPDATE PROVEEDOR
                SET NIT = ?, NOMBRE = ?, CONTACTO = ?, TELEFONO = ?, CORREO = ?, DIRECCION = ?
                WHERE ID_PROVEEDOR = ?
                """, req.nit(), req.nombre(), req.contacto(), req.telefono(), req.correo(), req.direccion(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Proveedor no encontrado");
        }
        return obtener(id);
    }

    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE PROVEEDOR SET ID_ESTADO = FN_ID_ESTADO('PROVEEDOR', 'I') WHERE ID_PROVEEDOR = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Proveedor no encontrado");
        }
    }

    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE PROVEEDOR SET ID_ESTADO = FN_ID_ESTADO('PROVEEDOR', 'A') WHERE ID_PROVEEDOR = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Proveedor no encontrado");
        }
    }

    public record ProveedorResponse(long idProveedor, String nit, String nombre, String contacto, String telefono,
                                    String correo, String direccion, String estado) {
    }
}
