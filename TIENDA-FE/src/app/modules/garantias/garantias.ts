import { Component, inject } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { filter } from 'rxjs';
import { Garantia } from '../../data/models/postventa';
import { GarantiaService } from '../../data/services/postventa.service';
import { ProductoService } from '../../data/services/productos.service';
import { Confirmacion } from '../../shared/confirmacion/confirmacion';
import { Campo, CrudConfig, opcionesDe } from '../../shared/crud/crud';
import { CrudPagina } from '../../shared/crud/crud-pagina';
import { DocumentoDetalle } from '../../shared/documento-detalle/documento-detalle';
import { anchoFormulario, FormularioDialogo } from '../../shared/formulario/formulario-dialogo';
import { fechaCorta } from '../compras/compras';
import { ReclamoDialogo } from './reclamo-dialogo';

const RESUELTAS = ['Reparada', 'Cambiada', 'Rechazada'];

@Component({
  selector: 'app-garantias',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Garantias {
  private readonly servicio = inject(GarantiaService);
  private readonly productos = inject(ProductoService);
  private readonly dialog = inject(MatDialog);
  private readonly confirmacion = inject(Confirmacion);

  protected readonly config: CrudConfig<Garantia> = {
    titulo: 'Reclamos de garantía',
    descripcion: 'Productos en revisión, reparación o cambio',
    singular: 'reclamo',
    ruta: '/garantias',
    servicio: this.servicio,
    id: 'idGarantia',
    editable: false,
    desactivable: false,
    alCrear: (recargar) =>
      this.dialog
        .open(ReclamoDialogo, { width: '600px' })
        .afterClosed()
        .pipe(filter(Boolean))
        .subscribe(() => recargar()),
    etiqueta: (g) => `reclamo ${g.idGarantia}`,
    tonoEstado: (estado) =>
      ['Recibida', 'En revisión'].includes(estado)
        ? 'aviso'
        : ['Reparada', 'Cambiada'].includes(estado)
          ? 'exito'
          : 'inactivo',
    resumen: (filas) =>
      `${filas.length} reclamos · ${filas.filter((g) => g.estado !== 'Entregada').length} sin entregar`,
    columnas: [
      { campo: 'idGarantia', titulo: 'No.', clase: 'col-codigo' },
      { campo: 'fechaReclamo', titulo: 'Fecha', tipo: 'fecha' },
      { campo: 'factura', titulo: 'Factura', clase: 'col-codigo' },
      { campo: 'cliente', titulo: 'Cliente' },
      { campo: 'producto', titulo: 'Producto' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [],
    acciones: [
      { icono: 'visibility', texto: 'Ver reclamo', permiso: 'consultar', ejecutar: (g) => this.ver(g) },
      {
        icono: 'manage_search',
        texto: 'Pasar a revisión',
        permiso: 'puedeEditar',
        visible: (g) => g.estado === 'Recibida',
        ejecutar: (g, recargar) =>
          this.confirmacion.ejecutar(
            {
              titulo: 'Pasar a revisión',
              mensaje: `¿El técnico comienza a revisar ${g.producto} (reclamo ${g.idGarantia})?`,
              accion: 'Pasar a revisión',
            },
            () => this.servicio.revision(g.idGarantia),
            'Reclamo en revisión',
            recargar,
          ),
      },
      {
        icono: 'build',
        texto: 'Resolver con reparación',
        permiso: 'puedeEditar',
        visible: (g) => g.estado === 'En revisión',
        ejecutar: (g, recargar) =>
          this.resolver(
            g,
            'Reparación',
            [{ nombre: 'observaciones', etiqueta: 'Trabajo realizado', tipo: 'area', largoMax: 300 }],
            (v) => this.servicio.reparar(g.idGarantia, v),
            'Reclamo resuelto con reparación',
            recargar,
          ),
      },
      {
        icono: 'swap_horiz',
        texto: 'Resolver con cambio de producto',
        permiso: 'puedeEditar',
        visible: (g) => g.estado === 'En revisión',
        ejecutar: (g, recargar) =>
          this.resolver(
            g,
            'Cambio de producto',
            [
              {
                nombre: 'idProductoReemplazo',
                etiqueta: 'Producto de reemplazo',
                tipo: 'select',
                requerido: true,
                opciones: opcionesDe(this.productos, 'idProducto', (p) => `${p.codigo} · ${p.nombre}`),
              },
              { nombre: 'observaciones', etiqueta: 'Observaciones', tipo: 'area', largoMax: 300 },
            ],
            (v) => this.servicio.cambiar(g.idGarantia, v),
            'Reclamo resuelto con cambio de producto',
            recargar,
          ),
      },
      {
        icono: 'block',
        texto: 'Rechazar reclamo',
        permiso: 'puedeEditar',
        visible: (g) => g.estado === 'En revisión',
        ejecutar: (g, recargar) =>
          this.resolver(
            g,
            'Rechazo',
            [{ nombre: 'observaciones', etiqueta: 'Motivo del rechazo', tipo: 'area', requerido: true, largoMax: 300 }],
            (v) => this.servicio.rechazar(g.idGarantia, v),
            'Reclamo rechazado',
            recargar,
          ),
      },
      {
        icono: 'assignment_turned_in',
        texto: 'Entregar al cliente',
        permiso: 'puedeEditar',
        visible: (g) => RESUELTAS.includes(g.estado),
        ejecutar: (g, recargar) =>
          this.confirmacion.ejecutar(
            {
              titulo: 'Entregar al cliente',
              mensaje: `¿Se entregó al cliente ${g.cliente} el resultado del reclamo ${g.idGarantia} (${g.estado.toLowerCase()})?`,
              accion: 'Entregar',
            },
            () => this.servicio.entregar(g.idGarantia),
            'Reclamo entregado',
            recargar,
          ),
      },
    ],
  };

  private resolver(
    garantia: Garantia,
    tipo: string,
    campos: Campo[],
    guardar: (valores: Record<string, unknown>) => ReturnType<GarantiaService['reparar']>,
    mensajeExito: string,
    recargar: () => void,
  ) {
    this.dialog
      .open(FormularioDialogo, {
        width: anchoFormulario(campos),
        data: { titulo: `${tipo}: ${garantia.producto}`, campos, guardar, mensajeExito },
      })
      .afterClosed()
      .pipe(filter(Boolean))
      .subscribe(() => recargar());
  }

  private ver(g: Garantia) {
    this.dialog.open(DocumentoDetalle, {
      width: '640px',
      data: {
        titulo: `Reclamo de garantía ${g.idGarantia}`,
        cabecera: [
          { etiqueta: 'Factura', valor: g.factura },
          { etiqueta: 'Cliente', valor: g.cliente },
          { etiqueta: 'Producto', valor: g.producto },
          { etiqueta: 'Estado', valor: g.estado },
          { etiqueta: 'Fecha de reclamo', valor: fechaCorta(g.fechaReclamo) },
          { etiqueta: 'Fecha de resolución', valor: g.fechaResolucion ? fechaCorta(g.fechaResolucion) : '' },
          { etiqueta: 'Falla reportada', valor: g.descripcionFalla, completo: true },
          { etiqueta: 'Producto de reemplazo', valor: g.productoReemplazo ?? '' },
          { etiqueta: 'Observaciones', valor: g.observaciones ?? '', completo: true },
        ],
        columnas: [],
        lineas: [],
      },
    });
  }
}
