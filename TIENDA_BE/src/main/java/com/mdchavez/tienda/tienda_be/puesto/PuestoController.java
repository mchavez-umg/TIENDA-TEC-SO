package com.mdchavez.tienda.tienda_be.puesto;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/puestos")
public class PuestoController {

    private static final String RUTA = "/personal/puestos";

    private final PuestoService puestoService;

    public PuestoController(PuestoService puestoService) {
        this.puestoService = puestoService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<PuestoService.PuestoResponse> listar() {
        return puestoService.listar();
    }

    @GetMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public PuestoService.PuestoResponse obtener(@PathVariable long id) {
        return puestoService.obtener(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'A')")
    public PuestoService.PuestoResponse crear(@Valid @RequestBody PuestoRequest request) {
        return puestoService.crear(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public PuestoService.PuestoResponse actualizar(@PathVariable long id, @Valid @RequestBody PuestoRequest request) {
        return puestoService.actualizar(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> desactivar(@PathVariable long id) {
        puestoService.desactivar(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/activar")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> activar(@PathVariable long id) {
        puestoService.activar(id);
        return ResponseEntity.noContent().build();
    }
}
