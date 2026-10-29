package com.mdchavez.tienda.tienda_be.rol;

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
@RequestMapping("/api/roles")
public class RolController {

    private static final String RUTA = "/seguridad/roles";

    private final RolService rolService;

    public RolController(RolService rolService) {
        this.rolService = rolService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<RolService.RolResponse> listar() {
        return rolService.listar();
    }

    @GetMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public RolService.RolResponse obtener(@PathVariable long id) {
        return rolService.obtener(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'A')")
    public RolService.RolResponse crear(@Valid @RequestBody RolRequest request) {
        return rolService.crear(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public RolService.RolResponse actualizar(@PathVariable long id, @Valid @RequestBody RolRequest request) {
        return rolService.actualizar(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> desactivar(@PathVariable long id) {
        rolService.desactivar(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/activar")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> activar(@PathVariable long id) {
        rolService.activar(id);
        return ResponseEntity.noContent().build();
    }
}
