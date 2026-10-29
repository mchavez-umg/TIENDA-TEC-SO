package com.mdchavez.tienda.tienda_be.reporte;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class ReporteControllerTests {

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
    void dashboardSinTokenDevuelve401() throws Exception {
        mvc.perform(get("/api/reportes/dashboard")).andExpect(status().isUnauthorized());
    }

    @Test
    void dashboardSinPermisoDevuelve403() throws Exception {
        mvc.perform(get("/api/reportes/dashboard").header("Authorization", "Bearer " + token()))
                .andExpect(status().isForbidden());
    }

    @Test
    void existenciasSinPermisoDevuelve403() throws Exception {
        mvc.perform(get("/api/reportes/existencias").header("Authorization", "Bearer " + token()))
                .andExpect(status().isForbidden());
    }
}
