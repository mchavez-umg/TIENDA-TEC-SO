package com.mdchavez.tienda.tienda_be.cliente;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class ClienteService {

    private static final String SELECT = """
            SELECT C.ID_CLIENTE, C.NIT, C.NOMBRES, C.APELLIDOS, C.TELEFONO, C.CORREO, C.DIRECCION,
                   E.NOMBRE AS ESTADO
            FROM CLIENTE C
            JOIN ESTADO E ON E.ID_ESTADO = C.ID_ESTADO
            """;

    private static final RowMapper<ClienteResponse> MAPPER = (rs, n) -> new ClienteResponse(
            rs.getLong("ID_CLIENTE"), rs.getString("NIT"), rs.getString("NOMBRES"), rs.getString("APELLIDOS"),
            rs.getString("TELEFONO"), rs.getString("CORREO"), rs.getString("DIRECCION"), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public ClienteService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<ClienteResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY C.NOMBRES, C.APELLIDOS", MAPPER);
    }

    public ClienteResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE C.ID_CLIENTE = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Cliente no encontrado");
        }
    }

    public ClienteResponse crear(ClienteRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_CLIENTE.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("""
                INSERT INTO CLIENTE (ID_CLIENTE, NIT, NOMBRES, APELLIDOS, TELEFONO, CORREO, DIRECCION, ID_ESTADO)
                VALUES (?, ?, ?, ?, ?, ?, ?, FN_ID_ESTADO('CLIENTE', 'A'))
                """, id, req.nit(), req.nombres(), req.apellidos(), req.telefono(), req.correo(), req.direccion());
        return obtener(id);
    }

    public ClienteResponse actualizar(long id, ClienteRequest req) {
        int filas = jdbc.update("""
                UPDATE CLIENTE
                SET NIT = ?, NOMBRES = ?, APELLIDOS = ?, TELEFONO = ?, CORREO = ?, DIRECCION = ?
                WHERE ID_CLIENTE = ?
                """, req.nit(), req.nombres(), req.apellidos(), req.telefono(), req.correo(), req.direccion(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Cliente no encontrado");
        }
        return obtener(id);
    }

    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE CLIENTE SET ID_ESTADO = FN_ID_ESTADO('CLIENTE', 'I') WHERE ID_CLIENTE = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Cliente no encontrado");
        }
    }

    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE CLIENTE SET ID_ESTADO = FN_ID_ESTADO('CLIENTE', 'A') WHERE ID_CLIENTE = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Cliente no encontrado");
        }
    }

    public record ClienteResponse(long idCliente, String nit, String nombres, String apellidos, String telefono,
                                  String correo, String direccion, String estado) {
    }
}
