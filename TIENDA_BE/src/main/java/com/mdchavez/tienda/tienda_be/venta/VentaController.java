package com.mdchavez.tienda.tienda_be.venta;

import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/ventas")
public class VentaController {

    private static final String RUTA = "/ventas/facturas";

    private final VentaService ventaService;

    public VentaController(VentaService ventaService) {
        this.ventaService = ventaService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<VentaService.FacturaResumen> listar(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta,
            @RequestParam(required = false) Long idSucursal) {
        return ventaService.listar(desde, hasta, idSucursal);
    }

    @GetMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public VentaService.FacturaDetalle obtener(@PathVariable long id) {
        return ventaService.obtener(id);
    }

    @PostMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'A')")
    public ResponseEntity<VentaService.VentaResponse> registrar(@Valid @RequestBody VentaRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ventaService.registrar(request));
    }
}
