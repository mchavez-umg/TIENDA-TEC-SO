package com.mdchavez.tienda.tienda_be.inventario;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/inventario")
public class InventarioController {

    private final InventarioService inventarioService;

    public InventarioController(InventarioService inventarioService) {
        this.inventarioService = inventarioService;
    }

    @GetMapping("/existencias")
    @PreAuthorize("@permisos.puede('/inventario/existencias', 'C')")
    public List<InventarioService.Existencia> existencias(
            @RequestParam(required = false) Long idSucursal,
            @RequestParam(required = false, defaultValue = "false") boolean soloBajoMinimo) {
        return inventarioService.existencias(idSucursal, soloBajoMinimo);
    }

    @GetMapping("/kardex")
    @PreAuthorize("@permisos.puede('/inventario/kardex', 'C')")
    public List<InventarioService.KardexMovimiento> kardex(
            @RequestParam(required = false) Long idSucursal,
            @RequestParam(required = false) Long idProducto,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return inventarioService.kardex(idSucursal, idProducto, desde, hasta);
    }
}
