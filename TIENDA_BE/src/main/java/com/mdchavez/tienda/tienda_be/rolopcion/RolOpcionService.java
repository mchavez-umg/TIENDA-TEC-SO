package com.mdchavez.tienda.tienda_be.rolopcion;

import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class RolOpcionService {

    private static final RowMapper<OpcionMenu> OPCION = (rs, n) -> new OpcionMenu(rs.getLong("ID_OPCION"),
            rs.getObject("ID_OPCION_PADRE", Long.class), rs.getString("NOMBRE"), rs.getString("RUTA"),
            rs.getInt("ORDEN"));

    private static final RowMapper<RolOpcionResponse> ROL_OPCION = (rs, n) -> new RolOpcionResponse(
            rs.getLong("ID_OPCION"), rs.getString("OPCION"), rs.getString("RUTA"), rs.getString("PUEDE_CONSULTAR"),
            rs.getString("PUEDE_CREAR"), rs.getString("PUEDE_EDITAR"), rs.getString("PUEDE_ELIMINAR"));

    private final JdbcTemplate jdbc;

    public RolOpcionService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<OpcionMenu> catalogoOpciones() {
        return jdbc.query("""
                SELECT ID_OPCION, ID_OPCION_PADRE, NOMBRE, RUTA, ORDEN
                FROM OPCION_MENU
                WHERE ID_ESTADO = FN_ID_ESTADO('OPCION_MENU', 'A')
                ORDER BY ID_OPCION_PADRE NULLS FIRST, ORDEN
                """, OPCION);
    }

    public List<RolOpcionResponse> permisosDelRol(long idRol) {
        exigirRol(idRol);
        return jdbc.query("""
                SELECT O.ID_OPCION, O.NOMBRE AS OPCION, O.RUTA, RO.PUEDE_CONSULTAR, RO.PUEDE_CREAR,
                       RO.PUEDE_EDITAR, RO.PUEDE_ELIMINAR
                FROM ROL_OPCION RO
                JOIN OPCION_MENU O ON O.ID_OPCION = RO.ID_OPCION
                WHERE RO.ID_ROL = ?
                ORDER BY O.ID_OPCION_PADRE NULLS FIRST, O.ORDEN
                """, ROL_OPCION, idRol);
    }

    public void asignar(long idRol, long idOpcion, RolOpcionRequest req) {
        exigirRol(idRol);
        String consultar = flag(req.puedeConsultar(), "S");
        String crear = flag(req.puedeCrear(), "N");
        String editar = flag(req.puedeEditar(), "N");
        String eliminar = flag(req.puedeEliminar(), "N");

        int filas = jdbc.update("""
                UPDATE ROL_OPCION
                SET PUEDE_CONSULTAR = ?, PUEDE_CREAR = ?, PUEDE_EDITAR = ?, PUEDE_ELIMINAR = ?
                WHERE ID_ROL = ? AND ID_OPCION = ?
                """, consultar, crear, editar, eliminar, idRol, idOpcion);

        if (filas == 0) {
            long id = jdbc.queryForObject("SELECT SEQ_ROL_OPCION.NEXTVAL FROM DUAL", Long.class);
            jdbc.update("""
                    INSERT INTO ROL_OPCION (ID_ROL_OPCION, ID_ROL, ID_OPCION, PUEDE_CONSULTAR, PUEDE_CREAR,
                                            PUEDE_EDITAR, PUEDE_ELIMINAR)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    """, id, idRol, idOpcion, consultar, crear, editar, eliminar);
        }
    }

    public void quitar(long idRol, long idOpcion) {
        int filas = jdbc.update("DELETE FROM ROL_OPCION WHERE ID_ROL = ? AND ID_OPCION = ?", idRol, idOpcion);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "El rol no tiene asignada esa opción");
        }
    }

    private void exigirRol(long idRol) {
        Integer existe = jdbc.queryForObject("SELECT COUNT(*) FROM ROL WHERE ID_ROL = ?", Integer.class, idRol);
        if (existe == null || existe == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Rol no encontrado");
        }
    }

    private static String flag(String valor, String porDefecto) {
        return valor != null ? valor : porDefecto;
    }

    public record OpcionMenu(long idOpcion, Long idOpcionPadre, String nombre, String ruta, int orden) {
    }

    public record RolOpcionResponse(long idOpcion, String opcion, String ruta, String puedeConsultar,
                                    String puedeCrear, String puedeEditar, String puedeEliminar) {
    }
}
