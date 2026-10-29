package com.mdchavez.tienda.tienda_be.compra;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/compras")
public class CompraController {

    private static final String RUTA = "/compras/compras";

    private final CompraService compraService;

    public CompraController(CompraService compraService) {
        this.compraService = compraService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<CompraService.CompraResumen> listar() {
        return compraService.listar();
    }

    @GetMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public CompraService.CompraDetalle obtener(@PathVariable long id) {
        return compraService.obtener(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'A')")
    public CompraService.CompraDetalle crear(@Valid @RequestBody CompraRequest request) {
        return compraService.registrar(request);
    }

    @PostMapping("/{id}/recibir")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public CompraService.CompraDetalle recibir(@PathVariable long id) {
        compraService.recibir(id);
        return compraService.obtener(id);
    }

    @PostMapping("/{id}/anular")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public ResponseEntity<Void> anular(@PathVariable long id) {
        compraService.anular(id);
        return ResponseEntity.noContent().build();
    }
}
