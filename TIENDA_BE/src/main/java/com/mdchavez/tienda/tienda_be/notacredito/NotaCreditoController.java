package com.mdchavez.tienda.tienda_be.notacredito;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/notas-credito")
public class NotaCreditoController {

    private static final String RUTA = "/ventas/notas-credito";

    private final NotaCreditoService notaCreditoService;

    public NotaCreditoController(NotaCreditoService notaCreditoService) {
        this.notaCreditoService = notaCreditoService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<NotaCreditoService.NotaResumen> listar() {
        return notaCreditoService.listar();
    }

    @GetMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public NotaCreditoService.NotaDetalle obtener(@PathVariable long id) {
        return notaCreditoService.obtener(id);
    }

    @PostMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'A')")
    public ResponseEntity<NotaCreditoService.NotaDetalle> crear(@Valid @RequestBody NotaCreditoRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(notaCreditoService.registrar(request));
    }
}
