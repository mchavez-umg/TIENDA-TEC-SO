package com.mdchavez.tienda.tienda_be.proveedor;

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
@RequestMapping("/api/proveedores")
public class ProveedorController {

    private static final String RUTA = "/compras/proveedores";

    private final ProveedorService proveedorService;

    public ProveedorController(ProveedorService proveedorService) {
        this.proveedorService = proveedorService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<ProveedorService.ProveedorResponse> listar() {
        return proveedorService.listar();
    }

    @GetMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public ProveedorService.ProveedorResponse obtener(@PathVariable long id) {
        return proveedorService.obtener(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'A')")
    public ProveedorService.ProveedorResponse crear(@Valid @RequestBody ProveedorRequest request) {
        return proveedorService.crear(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public ProveedorService.ProveedorResponse actualizar(@PathVariable long id, @Valid @RequestBody ProveedorRequest request) {
        return proveedorService.actualizar(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> desactivar(@PathVariable long id) {
        proveedorService.desactivar(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/activar")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> activar(@PathVariable long id) {
        proveedorService.activar(id);
        return ResponseEntity.noContent().build();
    }
}
