package com.mdchavez.tienda.tienda_be.banco;

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
@RequestMapping("/api/bancos")
public class BancoController {

    private static final String RUTA = "/ventas/bancos";

    private final BancoService bancoService;

    public BancoController(BancoService bancoService) {
        this.bancoService = bancoService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<BancoService.BancoResponse> listar() {
        return bancoService.listar();
    }

    @GetMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public BancoService.BancoResponse obtener(@PathVariable long id) {
        return bancoService.obtener(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'A')")
    public BancoService.BancoResponse crear(@Valid @RequestBody BancoRequest request) {
        return bancoService.crear(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public BancoService.BancoResponse actualizar(@PathVariable long id, @Valid @RequestBody BancoRequest request) {
        return bancoService.actualizar(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> desactivar(@PathVariable long id) {
        bancoService.desactivar(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/activar")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> activar(@PathVariable long id) {
        bancoService.activar(id);
        return ResponseEntity.noContent().build();
    }
}
