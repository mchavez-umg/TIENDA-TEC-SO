package com.mdchavez.tienda.tienda_be.opcionmenu;

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
@RequestMapping("/api/opciones-menu-admin")
public class OpcionMenuController {

    private static final String RUTA = "/seguridad/menu";

    private final OpcionMenuService opcionMenuService;

    public OpcionMenuController(OpcionMenuService opcionMenuService) {
        this.opcionMenuService = opcionMenuService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<OpcionMenuService.OpcionMenuResponse> listar() {
        return opcionMenuService.listar();
    }

    @GetMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public OpcionMenuService.OpcionMenuResponse obtener(@PathVariable long id) {
        return opcionMenuService.obtener(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'A')")
    public OpcionMenuService.OpcionMenuResponse crear(@Valid @RequestBody OpcionMenuRequest request) {
        return opcionMenuService.crear(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public OpcionMenuService.OpcionMenuResponse actualizar(@PathVariable long id, @Valid @RequestBody OpcionMenuRequest request) {
        return opcionMenuService.actualizar(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> desactivar(@PathVariable long id) {
        opcionMenuService.desactivar(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/activar")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> activar(@PathVariable long id) {
        opcionMenuService.activar(id);
        return ResponseEntity.noContent().build();
    }
}
