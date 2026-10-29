package com.mdchavez.tienda.tienda_be.menu;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MenuService {

    private static final String SQL = """
            SELECT O.ID_OPCION, O.ID_OPCION_PADRE, O.NOMBRE, O.RUTA, O.ICONO, O.ORDEN,
                   RO.PUEDE_CONSULTAR, RO.PUEDE_CREAR, RO.PUEDE_EDITAR, RO.PUEDE_ELIMINAR
            FROM OPCION_MENU O
            JOIN USUARIO U ON U.USERNAME = ?
            LEFT JOIN ROL_OPCION RO ON RO.ID_OPCION = O.ID_OPCION AND RO.ID_ROL = U.ID_ROL
            WHERE O.ID_ESTADO = FN_ID_ESTADO('OPCION_MENU', 'A')
              AND ( RO.PUEDE_CONSULTAR = 'S'
                    OR O.ID_OPCION IN (SELECT C.ID_OPCION_PADRE
                                       FROM OPCION_MENU C
                                       JOIN ROL_OPCION RO2 ON RO2.ID_OPCION = C.ID_OPCION AND RO2.ID_ROL = U.ID_ROL
                                       WHERE RO2.PUEDE_CONSULTAR = 'S') )
            ORDER BY O.ID_OPCION_PADRE NULLS FIRST, O.ORDEN
            """;

    private final JdbcTemplate jdbc;

    public MenuService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<MenuOpcion> menuDelUsuario() {
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        return jdbc.query(SQL, (rs, n) -> new MenuOpcion(
                rs.getLong("ID_OPCION"),
                rs.getObject("ID_OPCION_PADRE", Long.class),
                rs.getString("NOMBRE"),
                rs.getString("RUTA"),
                rs.getString("ICONO"),
                rs.getInt("ORDEN"),
                "S".equals(rs.getString("PUEDE_CREAR")),
                "S".equals(rs.getString("PUEDE_EDITAR")),
                "S".equals(rs.getString("PUEDE_ELIMINAR"))), username);
    }

    public record MenuOpcion(long idOpcion, Long idOpcionPadre, String nombre, String ruta, String icono,
                             int orden, boolean puedeCrear, boolean puedeEditar, boolean puedeEliminar) {
    }
}
