package com.mdchavez.tienda.tienda_be.rol;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class RolService {

    private static final String SELECT = """
            SELECT R.ID_ROL, R.NOMBRE, R.DESCRIPCION, E.NOMBRE AS ESTADO
            FROM ROL R
            JOIN ESTADO E ON E.ID_ESTADO = R.ID_ESTADO
            """;

    private static final RowMapper<RolResponse> MAPPER = (rs, n) -> new RolResponse(
            rs.getLong("ID_ROL"), rs.getString("NOMBRE"), rs.getString("DESCRIPCION"), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public RolService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<RolResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY R.NOMBRE", MAPPER);
    }

    public RolResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE R.ID_ROL = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Rol no encontrado");
        }
    }

    public RolResponse crear(RolRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_ROL.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("INSERT INTO ROL (ID_ROL, NOMBRE, DESCRIPCION, ID_ESTADO) "
                + "VALUES (?, ?, ?, FN_ID_ESTADO('ROL', 'A'))", id, req.nombre(), req.descripcion());
        return obtener(id);
    }

    public RolResponse actualizar(long id, RolRequest req) {
        int filas = jdbc.update("UPDATE ROL SET NOMBRE = ?, DESCRIPCION = ? WHERE ID_ROL = ?",
                req.nombre(), req.descripcion(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Rol no encontrado");
        }
        return obtener(id);
    }

    public void desactivar(long id) {
        int filas = jdbc.update("UPDATE ROL SET ID_ESTADO = FN_ID_ESTADO('ROL', 'I') WHERE ID_ROL = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Rol no encontrado");
        }
    }

    public void activar(long id) {
        int filas = jdbc.update("UPDATE ROL SET ID_ESTADO = FN_ID_ESTADO('ROL', 'A') WHERE ID_ROL = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Rol no encontrado");
        }
    }

    public record RolResponse(long idRol, String nombre, String descripcion, String estado) {
    }
}
