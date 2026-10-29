package com.mdchavez.tienda.tienda_be.banco;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class BancoService {

    private static final String SELECT = """
            SELECT B.ID_BANCO, B.NOMBRE, E.NOMBRE AS ESTADO
            FROM BANCO B
            JOIN ESTADO E ON E.ID_ESTADO = B.ID_ESTADO
            """;

    private static final RowMapper<BancoResponse> MAPPER = (rs, n) -> new BancoResponse(
            rs.getLong("ID_BANCO"), rs.getString("NOMBRE"), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public BancoService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<BancoResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY B.NOMBRE", MAPPER);
    }

    public BancoResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE B.ID_BANCO = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Banco no encontrado");
        }
    }

    public BancoResponse crear(BancoRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_BANCO.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("INSERT INTO BANCO (ID_BANCO, NOMBRE, ID_ESTADO) VALUES (?, ?, FN_ID_ESTADO('BANCO', 'A'))",
                id, req.nombre());
        return obtener(id);
    }

    public BancoResponse actualizar(long id, BancoRequest req) {
        int filas = jdbc.update("UPDATE BANCO SET NOMBRE = ? WHERE ID_BANCO = ?", req.nombre(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Banco no encontrado");
        }
        return obtener(id);
    }

    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE BANCO SET ID_ESTADO = FN_ID_ESTADO('BANCO', 'I') WHERE ID_BANCO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Banco no encontrado");
        }
    }

    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE BANCO SET ID_ESTADO = FN_ID_ESTADO('BANCO', 'A') WHERE ID_BANCO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Banco no encontrado");
        }
    }

    public record BancoResponse(long idBanco, String nombre, String estado) {
    }
}
