package com.mdchavez.tienda.tienda_be.seguridad;

import jakarta.validation.constraints.NotBlank;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Map;

@Service
public class AuthService {

    static final String CREDENCIALES_INVALIDAS = "Usuario o contraseña incorrectos";

    private final JdbcTemplate jdbc;
    private final PasswordEncoder passwordEncoder;
    private final JwtEncoder jwtEncoder;
    private final long expiracionHoras;

    public AuthService(JdbcTemplate jdbc, PasswordEncoder passwordEncoder, JwtEncoder jwtEncoder,
                       @Value("${app.jwt.expiracion-horas}") long expiracionHoras) {
        this.jdbc = jdbc;
        this.passwordEncoder = passwordEncoder;
        this.jwtEncoder = jwtEncoder;
        this.expiracionHoras = expiracionHoras;
    }

    public LoginResponse login(LoginRequest request) {
        String username = request.username();
        String hash = obtenerHash(username);

        if (!passwordEncoder.matches(request.password(), hash)) {
            jdbc.update("BEGIN PKG_SEGURIDAD.PR_LOGIN_FALLIDO(?); END;", username);
            throw new BadCredentialsException(CREDENCIALES_INVALIDAS);
        }
        jdbc.update("BEGIN PKG_SEGURIDAD.PR_LOGIN_EXITOSO(?); END;", username);

        Map<String, Object> usuario = jdbc.queryForMap(
                "SELECT U.ID_USUARIO, R.NOMBRE AS ROL FROM USUARIO U JOIN ROL R ON R.ID_ROL = U.ID_ROL WHERE U.USERNAME = ?",
                username);
        long idUsuario = ((Number) usuario.get("ID_USUARIO")).longValue();
        String rol = (String) usuario.get("ROL");

        Instant ahora = Instant.now();
        JwtClaimsSet claims = JwtClaimsSet.builder()
                .issuer("TIENDA_BE")
                .subject(username)
                .issuedAt(ahora)
                .expiresAt(ahora.plus(expiracionHoras, ChronoUnit.HOURS))
                .claim("idUsuario", idUsuario)
                .claim("rol", rol)
                .build();
        String token = jwtEncoder.encode(JwtEncoderParameters.from(JwsHeader.with(MacAlgorithm.HS256).build(), claims))
                .getTokenValue();

        return new LoginResponse(token, idUsuario, username, rol);
    }

    private String obtenerHash(String username) {
        try {
            return jdbc.queryForObject("SELECT PKG_SEGURIDAD.FN_OBTENER_HASH(?) FROM DUAL", String.class, username);
        } catch (DataAccessException e) {
            if (e.getCause() instanceof SQLException sql
                    && (sql.getErrorCode() == 20050 || sql.getErrorCode() == 20051)) {
                throw new BadCredentialsException(CREDENCIALES_INVALIDAS);
            }
            throw e;
        }
    }

    public record LoginRequest(@NotBlank String username, @NotBlank String password) {
    }

    public record LoginResponse(String token, long idUsuario, String username, String rol) {
    }
}
