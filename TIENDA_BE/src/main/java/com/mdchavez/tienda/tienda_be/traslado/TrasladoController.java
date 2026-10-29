package com.mdchavez.tienda.tienda_be.traslado;

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
@RequestMapping("/api/traslados")
public class TrasladoController {

    private static final String RUTA = "/inventario/traslados";

    private final TrasladoService trasladoService;

    public TrasladoController(TrasladoService trasladoService) {
        this.trasladoService = trasladoService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<TrasladoService.TrasladoResumen> listar() {
        return trasladoService.listar();
    }

    @GetMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public TrasladoService.TrasladoDetalle obtener(@PathVariable long id) {
        return trasladoService.obtener(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'A')")
    public TrasladoService.TrasladoDetalle crear(@Valid @RequestBody TrasladoRequest request) {
        return trasladoService.registrar(request);
    }

    @PostMapping("/{id}/recibir")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public TrasladoService.TrasladoDetalle recibir(@PathVariable long id) {
        trasladoService.recibir(id);
        return trasladoService.obtener(id);
    }

    @PostMapping("/{id}/cancelar")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public ResponseEntity<Void> cancelar(@PathVariable long id) {
        trasladoService.cancelar(id);
        return ResponseEntity.noContent().build();
    }
}
