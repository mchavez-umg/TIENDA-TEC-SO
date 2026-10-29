package com.mdchavez.tienda.tienda_be.formapago;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class FormaPagoService {

    private static final String SELECT = """
            SELECT F.ID_FORMA_PAGO, F.NOMBRE, F.REQUIERE_REFERENCIA, E.NOMBRE AS ESTADO
            FROM FORMA_PAGO F
            JOIN ESTADO E ON E.ID_ESTADO = F.ID_ESTADO
            """;

    private static final RowMapper<FormaPagoResponse> MAPPER = (rs, n) -> new FormaPagoResponse(
            rs.getLong("ID_FORMA_PAGO"), rs.getString("NOMBRE"), rs.getString("REQUIERE_REFERENCIA"),
            rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public FormaPagoService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<FormaPagoResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY F.NOMBRE", MAPPER);
    }

    public FormaPagoResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE F.ID_FORMA_PAGO = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Forma de pago no encontrada");
        }
    }

    public FormaPagoResponse crear(FormaPagoRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_FORMA_PAGO.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("""
                INSERT INTO FORMA_PAGO (ID_FORMA_PAGO, NOMBRE, REQUIERE_REFERENCIA, ID_ESTADO)
                VALUES (?, ?, ?, FN_ID_ESTADO('FORMA_PAGO', 'A'))
                """, id, req.nombre(), req.requiereReferencia());
        return obtener(id);
    }

    public FormaPagoResponse actualizar(long id, FormaPagoRequest req) {
        int filas = jdbc.update("UPDATE FORMA_PAGO SET NOMBRE = ?, REQUIERE_REFERENCIA = ? WHERE ID_FORMA_PAGO = ?",
                req.nombre(), req.requiereReferencia(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Forma de pago no encontrada");
        }
        return obtener(id);
    }

    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE FORMA_PAGO SET ID_ESTADO = FN_ID_ESTADO('FORMA_PAGO', 'I') WHERE ID_FORMA_PAGO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Forma de pago no encontrada");
        }
    }

    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE FORMA_PAGO SET ID_ESTADO = FN_ID_ESTADO('FORMA_PAGO', 'A') WHERE ID_FORMA_PAGO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Forma de pago no encontrada");
        }
    }

    public record FormaPagoResponse(long idFormaPago, String nombre, String requiereReferencia, String estado) {
    }
}
