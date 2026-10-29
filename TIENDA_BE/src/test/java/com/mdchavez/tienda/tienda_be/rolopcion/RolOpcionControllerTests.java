package com.mdchavez.tienda.tienda_be.rolopcion;

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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class RolOpcionControllerTests {

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
        mvc.perform(get("/api/opciones-menu")).andExpect(status().isUnauthorized());
    }

    @Test
    void catalogoSinPermisoDevuelve403() throws Exception {
        mvc.perform(get("/api/opciones-menu").header("Authorization", "Bearer " + token()))
                .andExpect(status().isForbidden());
    }

    @Test
    void asignarConFlagInvalidoDevuelve400() throws Exception {
        mvc.perform(put("/api/roles/1/opciones/1").header("Authorization", "Bearer " + token())
                        .contentType(MediaType.APPLICATION_JSON).content("{\"puedeConsultar\":\"X\"}"))
                .andExpect(status().isBadRequest());
    }
}
