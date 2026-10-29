package com.mdchavez.tienda.tienda_be.formapago;

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
@RequestMapping("/api/formas-pago")
public class FormaPagoController {

    private static final String RUTA = "/ventas/formas-pago";

    private final FormaPagoService formaPagoService;

    public FormaPagoController(FormaPagoService formaPagoService) {
        this.formaPagoService = formaPagoService;
    }

    @GetMapping
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public List<FormaPagoService.FormaPagoResponse> listar() {
        return formaPagoService.listar();
    }

    @GetMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'C')")
    public FormaPagoService.FormaPagoResponse obtener(@PathVariable long id) {
        return formaPagoService.obtener(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'A')")
    public FormaPagoService.FormaPagoResponse crear(@Valid @RequestBody FormaPagoRequest request) {
        return formaPagoService.crear(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'M')")
    public FormaPagoService.FormaPagoResponse actualizar(@PathVariable long id, @Valid @RequestBody FormaPagoRequest request) {
        return formaPagoService.actualizar(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> desactivar(@PathVariable long id) {
        formaPagoService.desactivar(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/activar")
    @PreAuthorize("@permisos.puede('" + RUTA + "', 'B')")
    public ResponseEntity<Void> activar(@PathVariable long id) {
        formaPagoService.activar(id);
        return ResponseEntity.noContent().build();
    }
}
