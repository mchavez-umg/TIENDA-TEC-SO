package com.mdchavez.tienda.tienda_be.seguridad;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.TestingAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

@SpringBootTest
class ClientIdentifierDataSourceTests {

    private static final String CONSULTA = "SELECT SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER') FROM DUAL";

    @Autowired
    JdbcTemplate jdbc;

    @AfterEach
    void limpiar() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void usaElUsuarioAutenticadoYSeLimpiaAlReutilizarLaConexion() {
        SecurityContextHolder.getContext().setAuthentication(new TestingAuthenticationToken("admin", null, "X"));
        assertEquals("admin", jdbc.queryForObject(CONSULTA, String.class));

        SecurityContextHolder.clearContext();
        assertNull(jdbc.queryForObject(CONSULTA, String.class));
    }
}
