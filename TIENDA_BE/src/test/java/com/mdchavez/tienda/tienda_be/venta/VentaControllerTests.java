package com.mdchavez.tienda.tienda_be.venta;

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
class VentaControllerTests {

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
        mvc.perform(post("/api/ventas").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"idSucursal\":1,\"idCliente\":1,\"lineas\":[],\"pagos\":[]}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void ventaSinLineasNiPagosDevuelve400() throws Exception {
        mvc.perform(post("/api/ventas").header("Authorization", "Bearer " + token())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"idSucursal\":1,\"idCliente\":1,\"lineas\":[],\"pagos\":[]}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void ventaValidaSinPermisoDevuelve403() throws Exception {
        mvc.perform(post("/api/ventas").header("Authorization", "Bearer " + token())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"idSucursal\":1,\"idCliente\":1," +
                                "\"lineas\":[{\"idProducto\":1,\"cantidad\":1}]," +
                                "\"pagos\":[{\"idFormaPago\":1,\"monto\":10}]}"))
                .andExpect(status().isForbidden());
    }

    @Test
    void listarSinPermisoDevuelve403() throws Exception {
        mvc.perform(get("/api/ventas").header("Authorization", "Bearer " + token()))
                .andExpect(status().isForbidden());
    }

    @Test
    void detalleSinPermisoDevuelve403() throws Exception {
        mvc.perform(get("/api/ventas/1").header("Authorization", "Bearer " + token()))
                .andExpect(status().isForbidden());
    }

    @Test
    void listarSinTokenDevuelve401() throws Exception {
        mvc.perform(get("/api/ventas")).andExpect(status().isUnauthorized());
    }

    @Test
    void lineaConCantidadNegativaDevuelve400() throws Exception {
        mvc.perform(post("/api/ventas").header("Authorization", "Bearer " + token())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"idSucursal\":1,\"idCliente\":1," +
                                "\"lineas\":[{\"idProducto\":1,\"cantidad\":-2}]," +
                                "\"pagos\":[{\"idFormaPago\":1,\"monto\":10}]}"))
                .andExpect(status().isBadRequest());
    }
}
