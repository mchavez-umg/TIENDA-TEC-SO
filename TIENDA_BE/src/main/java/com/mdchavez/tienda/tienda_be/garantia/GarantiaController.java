package com.mdchavez.tienda.tienda_be.garantia;

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
@RequestMapping("/api/garantias")
public class GarantiaController {

    private static final String RUTA = "/garantias";

    private final GarantiaService garantiaService;

    public GarantiaController(GarantiaService garantiaService) {
        this.garantiaService = garantiaService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<GarantiaService.GarantiaResponse> listar() {
        return garantiaService.listar();
    }

    @GetMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public GarantiaService.GarantiaResponse obtener(@PathVariable long id) {
        return garantiaService.obtener(id);
    }

    @PostMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'A')")
    public ResponseEntity<GarantiaService.GarantiaResponse> registrar(@Valid @RequestBody GarantiaRequests.Reclamo request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(garantiaService.registrarReclamo(request));
    }

    @PostMapping("/{id}/revision")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public GarantiaService.GarantiaResponse revision(@PathVariable long id) {
        return garantiaService.pasarARevision(id);
    }

    @PostMapping("/{id}/reparar")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public GarantiaService.GarantiaResponse reparar(@PathVariable long id, @Valid @RequestBody GarantiaRequests.Resolucion request) {
        return garantiaService.reparar(id, request.observaciones());
    }

    @PostMapping("/{id}/cambiar")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public GarantiaService.GarantiaResponse cambiar(@PathVariable long id, @Valid @RequestBody GarantiaRequests.Cambio request) {
        return garantiaService.cambiar(id, request.idProductoReemplazo(), request.observaciones());
    }

    @PostMapping("/{id}/rechazar")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public GarantiaService.GarantiaResponse rechazar(@PathVariable long id, @Valid @RequestBody GarantiaRequests.Resolucion request) {
        return garantiaService.rechazar(id, request.observaciones());
    }

    @PostMapping("/{id}/entregar")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public GarantiaService.GarantiaResponse entregar(@PathVariable long id) {
        return garantiaService.entregar(id);
    }
}
