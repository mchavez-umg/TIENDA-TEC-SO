package com.mdchavez.tienda.tienda_be.bitacora;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/bitacora")
public class BitacoraController {

    private final BitacoraService bitacoraService;

    public BitacoraController(BitacoraService bitacoraService) {
        this.bitacoraService = bitacoraService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('/bitacora', 'C')")
    public List<BitacoraService.BitacoraRegistro> consultar(
            @RequestParam(required = false) String tabla,
            @RequestParam(required = false) String operacion,
            @RequestParam(required = false) String usuario,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta,
            @RequestParam(required = false, defaultValue = "200") int limite) {
        int tope = Math.min(Math.max(limite, 1), 1000);
        return bitacoraService.consultar(tabla, operacion, usuario, desde, hasta, tope);
    }
}
