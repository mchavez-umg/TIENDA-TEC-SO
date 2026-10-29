package com.mdchavez.tienda.tienda_be.puesto;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;

@Service
public class PuestoService {

    private static final String SELECT = """
            SELECT P.ID_PUESTO, P.NOMBRE, P.DESCRIPCION, P.SALARIO_BASE, E.NOMBRE AS ESTADO
            FROM PUESTO P
            JOIN ESTADO E ON E.ID_ESTADO = P.ID_ESTADO
            """;

    private static final RowMapper<PuestoResponse> MAPPER = (rs, n) -> new PuestoResponse(
            rs.getLong("ID_PUESTO"), rs.getString("NOMBRE"), rs.getString("DESCRIPCION"),
            rs.getBigDecimal("SALARIO_BASE"), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public PuestoService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<PuestoResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY P.NOMBRE", MAPPER);
    }

    public PuestoResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE P.ID_PUESTO = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Puesto no encontrado");
        }
    }

    public PuestoResponse crear(PuestoRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_PUESTO.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("""
                INSERT INTO PUESTO (ID_PUESTO, NOMBRE, DESCRIPCION, SALARIO_BASE, ID_ESTADO)
                VALUES (?, ?, ?, ?, FN_ID_ESTADO('PUESTO', 'A'))
                """, id, req.nombre(), req.descripcion(), req.salarioBase());
        return obtener(id);
    }

    public PuestoResponse actualizar(long id, PuestoRequest req) {
        int filas = jdbc.update("UPDATE PUESTO SET NOMBRE = ?, DESCRIPCION = ?, SALARIO_BASE = ? WHERE ID_PUESTO = ?",
                req.nombre(), req.descripcion(), req.salarioBase(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Puesto no encontrado");
        }
        return obtener(id);
    }

    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE PUESTO SET ID_ESTADO = FN_ID_ESTADO('PUESTO', 'I') WHERE ID_PUESTO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Puesto no encontrado");
        }
    }

    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE PUESTO SET ID_ESTADO = FN_ID_ESTADO('PUESTO', 'A') WHERE ID_PUESTO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Puesto no encontrado");
        }
    }

    public record PuestoResponse(long idPuesto, String nombre, String descripcion, BigDecimal salarioBase,
                                 String estado) {
    }
}
