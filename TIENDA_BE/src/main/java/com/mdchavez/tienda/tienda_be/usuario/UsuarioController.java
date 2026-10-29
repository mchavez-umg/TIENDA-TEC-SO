package com.mdchavez.tienda.tienda_be.usuario;

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
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private static final String RUTA = "/seguridad/usuarios";

    private final UsuarioService usuarioService;

    public UsuarioController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<UsuarioService.UsuarioResponse> listar() {
        return usuarioService.listar();
    }

    @GetMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public UsuarioService.UsuarioResponse obtener(@PathVariable long id) {
        return usuarioService.obtener(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'A')")
    public UsuarioService.UsuarioResponse crear(@Valid @RequestBody UsuarioRequests.Crear request) {
        return usuarioService.crear(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public UsuarioService.UsuarioResponse actualizar(@PathVariable long id, @Valid @RequestBody UsuarioRequests.Actualizar request) {
        return usuarioService.actualizar(id, request);
    }

    @PostMapping("/{id}/cambiar-password")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public ResponseEntity<Void> cambiarPassword(@PathVariable long id, @Valid @RequestBody UsuarioRequests.Clave request) {
        usuarioService.cambiarPassword(id, request.password());
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/restablecer-password")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public ResponseEntity<Void> restablecerPassword(@PathVariable long id, @Valid @RequestBody UsuarioRequests.Clave request) {
        usuarioService.restablecerPassword(id, request.password());
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> desactivar(@PathVariable long id) {
        usuarioService.desactivar(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/activar")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> activar(@PathVariable long id) {
        usuarioService.activar(id);
        return ResponseEntity.noContent().build();
    }
}
