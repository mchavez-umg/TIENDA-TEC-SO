package com.mdchavez.tienda.tienda_be.opcionmenu;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class OpcionMenuService {

    private static final String SELECT = """
            SELECT O.ID_OPCION, O.ID_OPCION_PADRE, PA.NOMBRE AS PADRE, O.NOMBRE, O.RUTA, O.ICONO, O.ORDEN,
                   E.NOMBRE AS ESTADO
            FROM OPCION_MENU O
            LEFT JOIN OPCION_MENU PA ON PA.ID_OPCION = O.ID_OPCION_PADRE
            JOIN ESTADO E ON E.ID_ESTADO = O.ID_ESTADO
            """;

    private static final RowMapper<OpcionMenuResponse> MAPPER = (rs, n) -> new OpcionMenuResponse(
            rs.getLong("ID_OPCION"), rs.getObject("ID_OPCION_PADRE", Long.class), rs.getString("PADRE"),
            rs.getString("NOMBRE"), rs.getString("RUTA"), rs.getString("ICONO"), rs.getInt("ORDEN"),
            rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public OpcionMenuService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<OpcionMenuResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY O.ID_OPCION_PADRE NULLS FIRST, O.ORDEN", MAPPER);
    }

    public OpcionMenuResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE O.ID_OPCION = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Opción de menú no encontrada");
        }
    }

    public OpcionMenuResponse crear(OpcionMenuRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_OPCION_MENU.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("""
                INSERT INTO OPCION_MENU (ID_OPCION, ID_OPCION_PADRE, NOMBRE, RUTA, ICONO, ORDEN, ID_ESTADO)
                VALUES (?, ?, ?, ?, ?, ?, FN_ID_ESTADO('OPCION_MENU', 'A'))
                """, id, req.idOpcionPadre(), req.nombre(), req.ruta(), req.icono(), req.orden());
        return obtener(id);
    }

    public OpcionMenuResponse actualizar(long id, OpcionMenuRequest req) {
        int filas = jdbc.update("""
                UPDATE OPCION_MENU
                SET ID_OPCION_PADRE = ?, NOMBRE = ?, RUTA = ?, ICONO = ?, ORDEN = ?
                WHERE ID_OPCION = ?
                """, req.idOpcionPadre(), req.nombre(), req.ruta(), req.icono(), req.orden(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Opción de menú no encontrada");
        }
        return obtener(id);
    }

    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE OPCION_MENU SET ID_ESTADO = FN_ID_ESTADO('OPCION_MENU', 'I') WHERE ID_OPCION = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Opción de menú no encontrada");
        }
    }

    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE OPCION_MENU SET ID_ESTADO = FN_ID_ESTADO('OPCION_MENU', 'A') WHERE ID_OPCION = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Opción de menú no encontrada");
        }
    }

    public record OpcionMenuResponse(long idOpcion, Long idOpcionPadre, String padre, String nombre, String ruta,
                                     String icono, int orden, String estado) {
    }
}
