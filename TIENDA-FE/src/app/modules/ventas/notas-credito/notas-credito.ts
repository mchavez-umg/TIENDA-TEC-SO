import { Component, inject } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { NotaResumen } from '../../../data/models/postventa';
import { NotaCreditoService } from '../../../data/services/postventa.service';
import { CrudConfig } from '../../../shared/crud/crud';
import { CrudPagina } from '../../../shared/crud/crud-pagina';
import { DocumentoDetalle } from '../../../shared/documento-detalle/documento-detalle';
import { Notificacion } from '../../../shared/notificacion.service';
import { fechaCorta } from '../../compras/compras';

@Component({
  selector: 'app-notas-credito',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class NotasCredito {
  private readonly servicio = inject(NotaCreditoService);
  private readonly dialog = inject(MatDialog);
  private readonly notificacion = inject(Notificacion);

  protected readonly config: CrudConfig<NotaResumen> = {
    titulo: 'Notas de crédito',
    descripcion: 'Devoluciones sobre facturas emitidas',
    singular: 'nota de crédito',
    femenino: true,
    ruta: '/ventas/notas-credito',
    servicio: this.servicio,
    id: 'idNotaCredito',
    nuevoRuta: 'nueva',
    editable: false,
    desactivable: false,
    tonoEstado: (estado) => (estado === 'Emitida' ? 'exito' : 'inactivo'),
    resumen: (filas) => `${filas.length} notas de crédito`,
    columnas: [
      { campo: 'numero', titulo: 'No.', clase: 'col-codigo' },
      { campo: 'fecha', titulo: 'Fecha', tipo: 'fecha' },
      { campo: 'factura', titulo: 'Factura', clase: 'col-codigo' },
      { campo: 'cliente', titulo: 'Cliente' },
      { campo: 'motivo', titulo: 'Motivo' },
      { campo: 'total', titulo: 'Total', tipo: 'moneda' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [],
    acciones: [{ icono: 'visibility', texto: 'Ver nota de crédito', permiso: 'consultar', ejecutar: (n) => this.ver(n) }],
  };

  private ver(nota: NotaResumen) {
    this.servicio.detalle(nota.idNotaCredito).subscribe({
      next: ({ notaCredito: n, lineas }) =>
        this.dialog.open(DocumentoDetalle, {
          width: '720px',
          data: {
            titulo: `Nota de crédito ${n.serie}-${n.numero}`,
            cabecera: [
              { etiqueta: 'Factura', valor: n.factura },
              { etiqueta: 'Cliente', valor: n.cliente },
              { etiqueta: 'Fecha', valor: fechaCorta(n.fecha) },
              { etiqueta: 'Estado', valor: n.estado },
              { etiqueta: 'Motivo', valor: n.motivo, completo: true },
            ],
            columnas: [
              { campo: 'producto', titulo: 'Producto' },
              { campo: 'cantidad', titulo: 'Cantidad', tipo: 'numero' },
              { campo: 'reingreso', titulo: 'Reingresa a inventario' },
              { campo: 'monto', titulo: 'Monto', tipo: 'moneda' },
            ],
            lineas: lineas.map((l) => ({ ...l, reingreso: l.reingresaInventario === 'S' ? 'Sí' : 'No' })),
            total: n.total,
          },
        }),
      error: (error) => this.notificacion.error(error),
    });
  }
}
