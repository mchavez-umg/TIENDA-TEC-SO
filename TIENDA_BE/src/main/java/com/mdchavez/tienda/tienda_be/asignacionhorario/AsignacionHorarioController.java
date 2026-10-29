package com.mdchavez.tienda.tienda_be.asignacionhorario;

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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/asignaciones-horario")
public class AsignacionHorarioController {

    private static final String RUTA = "/personal/asignacion-horarios";

    private final AsignacionHorarioService asignacionService;

    public AsignacionHorarioController(AsignacionHorarioService asignacionService) {
        this.asignacionService = asignacionService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<AsignacionHorarioService.AsignacionResponse> listar(@RequestParam(required = false) Long idEmpleado) {
        return asignacionService.listar(idEmpleado);
    }

    @GetMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public AsignacionHorarioService.AsignacionResponse obtener(@PathVariable long id) {
        return asignacionService.obtener(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'A')")
    public AsignacionHorarioService.AsignacionResponse crear(@Valid @RequestBody AsignacionHorarioRequest request) {
        return asignacionService.crear(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public AsignacionHorarioService.AsignacionResponse actualizar(@PathVariable long id, @Valid @RequestBody AsignacionHorarioRequest request) {
        return asignacionService.actualizar(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> desactivar(@PathVariable long id) {
        asignacionService.desactivar(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/activar")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> activar(@PathVariable long id) {
        asignacionService.activar(id);
        return ResponseEntity.noContent().build();
    }
}
