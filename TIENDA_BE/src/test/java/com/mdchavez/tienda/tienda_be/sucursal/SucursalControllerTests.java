package com.mdchavez.tienda.tienda_be.sucursal;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class SucursalControllerTests {

    @Autowired
    MockMvc mvc;

    @Autowired
    JwtEncoder jwtEncoder;

    private String token() {
        JwtClaimsSet claims = JwtClaimsSet.builder().subject("admin")
                .issuedAt(Instant.now()).expiresAt(Instant.now().plusSeconds(60)).build();
        return jwtEncoder.encode(JwtEncoderParameters.from(JwsHeader.with(MacAlgorithm.HS256).build(), claims))
                .getTokenValue();
    }

    @Test
    void sinTokenDevuelve401() throws Exception {
        mvc.perform(get("/api/sucursales")).andExpect(status().isUnauthorized());
    }

    @Test
    void listarAutenticadoSinPermisoDevuelve200() throws Exception {
        mvc.perform(get("/api/sucursales").header("Authorization", "Bearer " + token()))
                .andExpect(status().isOk());
    }

    @Test
    void obtenerSinPermisoDevuelve403() throws Exception {
        mvc.perform(get("/api/sucursales/1").header("Authorization", "Bearer " + token()))
                .andExpect(status().isForbidden());
    }

    @Test
    void crearSinCodigoYCorreoInvalidoDevuelve400() throws Exception {
        mvc.perform(post("/api/sucursales").header("Authorization", "Bearer " + token())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"idMunicipio\":1,\"codigo\":\"\",\"nombre\":\"Suc\",\"direccion\":\"x\"," +
                                "\"correo\":\"malcorreo\",\"fechaApertura\":\"2024-01-01\"}"))
                .andExpect(status().isBadRequest());
    }
}
