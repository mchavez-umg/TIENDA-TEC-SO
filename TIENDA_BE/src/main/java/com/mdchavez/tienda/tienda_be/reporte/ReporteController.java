package com.mdchavez.tienda.tienda_be.reporte;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/reportes")
public class ReporteController {

    private final ReporteService reporteService;

    public ReporteController(ReporteService reporteService) {
        this.reporteService = reporteService;
    }

    @GetMapping("/dashboard")
    @PreAuthorize("@permisos.puede('/reportes/dashboard', 'C')")
    public ReporteService.Dashboard dashboard() {
        return reporteService.dashboard();
    }

    @GetMapping("/ventas-sucursal")
    @PreAuthorize("@permisos.puede('/reportes/ventas-sucursal', 'C')")
    public List<ReporteService.VentaPorSucursal> ventasPorSucursal(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return reporteService.ventasPorSucursal(desde, hasta);
    }

    @GetMapping("/ventas-producto")
    @PreAuthorize("@permisos.puede('/reportes/ventas-producto', 'C')")
    public List<ReporteService.VentaPorProducto> ventasPorProducto(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return reporteService.ventasPorProducto(desde, hasta);
    }

    @GetMapping("/ventas-categoria")
    @PreAuthorize("@permisos.puede('/reportes/ventas-categoria', 'C')")
    public List<ReporteService.VentaPorCategoria> ventasPorCategoria(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return reporteService.ventasPorCategoria(desde, hasta);
    }

    @GetMapping("/ventas-empleado")
    @PreAuthorize("@permisos.puede('/reportes/ventas-empleado', 'C')")
    public List<ReporteService.VentaPorEmpleado> ventasPorEmpleado(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return reporteService.ventasPorEmpleado(desde, hasta);
    }

    @GetMapping("/forma-pago")
    @PreAuthorize("@permisos.puede('/reportes/forma-pago', 'C')")
    public List<ReporteService.VentaPorFormaPago> ventasPorFormaPago(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return reporteService.ventasPorFormaPago(desde, hasta);
    }

    @GetMapping("/garantias")
    @PreAuthorize("@permisos.puede('/reportes/garantias', 'C')")
    public List<ReporteService.GarantiaPorEstado> garantiasPorEstado() {
        return reporteService.garantiasPorEstado();
    }

    @GetMapping("/notas-credito")
    @PreAuthorize("@permisos.puede('/reportes/notas-credito', 'C')")
    public List<ReporteService.NotaCreditoEmitida> notasCreditoEmitidas(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        return reporteService.notasCreditoEmitidas(desde, hasta);
    }

    @GetMapping("/existencias")
    @PreAuthorize("@permisos.puede('/reportes/existencias', 'C')")
    public List<ReporteService.Existencia> existencias(
            @RequestParam(required = false) Long idSucursal,
            @RequestParam(required = false, defaultValue = "false") boolean soloBajoMinimo) {
        return reporteService.existencias(idSucursal, soloBajoMinimo);
    }
}
