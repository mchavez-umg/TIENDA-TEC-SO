package com.mdchavez.tienda.tienda_be.seguridad;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;

@Component("permisos")
public class Permisos {

    private final JdbcTemplate jdbc;

    public Permisos(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public boolean puede(String ruta, String accion) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof Jwt jwt)) {
            return false;
        }
        Object idUsuario = jwt.getClaim("idUsuario");
        if (!(idUsuario instanceof Number id)) {
            return false;
        }
        String permitido = jdbc.queryForObject(
                "SELECT PKG_SEGURIDAD.FN_TIENE_PERMISO(?, ?, ?) FROM DUAL",
                String.class, id.longValue(), ruta, accion);
        return "S".equals(permitido);
    }
}
