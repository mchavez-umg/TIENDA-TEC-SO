package com.mdchavez.tienda.tienda_be.usuario;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class UsuarioService {

    private static final String SELECT = """
            SELECT U.ID_USUARIO, U.ID_EMPLEADO, E.NOMBRES || ' ' || E.APELLIDOS AS EMPLEADO,
                   U.ID_ROL, R.NOMBRE AS ROL, U.USERNAME, U.INTENTOS_FALLIDOS, U.ULTIMO_ACCESO,
                   ES.NOMBRE AS ESTADO
            FROM USUARIO U
            JOIN EMPLEADO E ON E.ID_EMPLEADO = U.ID_EMPLEADO
            JOIN ROL R ON R.ID_ROL = U.ID_ROL
            JOIN ESTADO ES ON ES.ID_ESTADO = U.ID_ESTADO
            """;

    private static final RowMapper<UsuarioResponse> MAPPER = (rs, n) -> new UsuarioResponse(
            rs.getLong("ID_USUARIO"), rs.getLong("ID_EMPLEADO"), rs.getString("EMPLEADO"), rs.getLong("ID_ROL"),
            rs.getString("ROL"), rs.getString("USERNAME"), rs.getInt("INTENTOS_FALLIDOS"),
            rs.getObject("ULTIMO_ACCESO", LocalDateTime.class), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;
    private final PasswordEncoder passwordEncoder;

    public UsuarioService(JdbcTemplate jdbc, PasswordEncoder passwordEncoder) {
        this.jdbc = jdbc;
        this.passwordEncoder = passwordEncoder;
    }

    public List<UsuarioResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY U.USERNAME", MAPPER);
    }

    public UsuarioResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE U.ID_USUARIO = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
        }
    }

    public UsuarioResponse crear(UsuarioRequests.Crear req) {
        long id = jdbc.queryForObject("SELECT SEQ_USUARIO.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("""
                INSERT INTO USUARIO (ID_USUARIO, ID_EMPLEADO, ID_ROL, USERNAME, PASSWORD_HASH, ID_ESTADO)
                VALUES (?, ?, ?, ?, ?, FN_ID_ESTADO('USUARIO', 'A'))
                """, id, req.idEmpleado(), req.idRol(), req.username(), passwordEncoder.encode(req.password()));
        return obtener(id);
    }

    public UsuarioResponse actualizar(long id, UsuarioRequests.Actualizar req) {
        int filas = jdbc.update("UPDATE USUARIO SET ID_ROL = ?, USERNAME = ? WHERE ID_USUARIO = ?",
                req.idRol(), req.username(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
        }
        return obtener(id);
    }

    public void cambiarPassword(long id, String password) {
        jdbc.update("BEGIN PKG_SEGURIDAD.PR_CAMBIAR_PASSWORD(?, ?); END;", id, passwordEncoder.encode(password));
    }

    public void restablecerPassword(long id, String password) {
        jdbc.update("BEGIN PKG_SEGURIDAD.PR_RESTABLECER_PASSWORD(?, ?); END;", id, passwordEncoder.encode(password));
    }

    public void desactivar(long id) {
        int filas = jdbc.update("UPDATE USUARIO SET ID_ESTADO = FN_ID_ESTADO('USUARIO', 'I') WHERE ID_USUARIO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
        }
    }

    public void activar(long id) {
        int filas = jdbc.update("UPDATE USUARIO SET ID_ESTADO = FN_ID_ESTADO('USUARIO', 'A'), INTENTOS_FALLIDOS = 0 WHERE ID_USUARIO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
        }
    }

    public record UsuarioResponse(long idUsuario, long idEmpleado, String empleado, long idRol, String rol,
                                  String username, int intentosFallidos, LocalDateTime ultimoAcceso, String estado) {
    }
}
