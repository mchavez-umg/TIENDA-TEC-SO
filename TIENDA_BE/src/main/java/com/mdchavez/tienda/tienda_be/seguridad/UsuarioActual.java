package com.mdchavez.tienda.tienda_be.seguridad;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class UsuarioActual {

    private final JdbcTemplate jdbc;

    public UsuarioActual(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public long idEmpleado() {
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        return jdbc.queryForObject("SELECT ID_EMPLEADO FROM USUARIO WHERE USERNAME = ?", Long.class, username);
    }
}
