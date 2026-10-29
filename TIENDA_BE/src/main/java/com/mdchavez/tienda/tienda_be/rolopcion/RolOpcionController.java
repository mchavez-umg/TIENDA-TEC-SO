package com.mdchavez.tienda.tienda_be.rolopcion;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
public class RolOpcionController {

    private static final String RUTA = "/seguridad/roles";

    private final RolOpcionService rolOpcionService;

    public RolOpcionController(RolOpcionService rolOpcionService) {
        this.rolOpcionService = rolOpcionService;
    }

    @GetMapping("/opciones-menu")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<RolOpcionService.OpcionMenu> catalogoOpciones() {
        return rolOpcionService.catalogoOpciones();
    }

    @GetMapping("/roles/{idRol}/opciones")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<RolOpcionService.RolOpcionResponse> permisosDelRol(@PathVariable long idRol) {
        return rolOpcionService.permisosDelRol(idRol);
    }

    @PutMapping("/roles/{idRol}/opciones/{idOpcion}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public List<RolOpcionService.RolOpcionResponse> asignar(@PathVariable long idRol, @PathVariable long idOpcion,
                                                            @Valid @RequestBody RolOpcionRequest request) {
        rolOpcionService.asignar(idRol, idOpcion, request);
        return rolOpcionService.permisosDelRol(idRol);
    }

    @DeleteMapping("/roles/{idRol}/opciones/{idOpcion}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public ResponseEntity<Void> quitar(@PathVariable long idRol, @PathVariable long idOpcion) {
        rolOpcionService.quitar(idRol, idOpcion);
        return ResponseEntity.noContent().build();
    }
}
