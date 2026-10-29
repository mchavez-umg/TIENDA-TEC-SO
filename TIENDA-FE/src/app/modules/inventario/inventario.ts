import { Component, inject } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { TrasladoResumen } from '../../data/models/movimientos';
import { TrasladoService } from '../../data/services/movimientos.service';
import { Confirmacion } from '../../shared/confirmacion/confirmacion';
import { CrudConfig } from '../../shared/crud/crud';
import { CrudPagina } from '../../shared/crud/crud-pagina';
import { DocumentoDetalle } from '../../shared/documento-detalle/documento-detalle';
import { Notificacion } from '../../shared/notificacion.service';
import { fechaCorta } from '../compras/compras';

@Component({
  selector: 'app-traslados',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Traslados {
  private readonly servicio = inject(TrasladoService);
  private readonly dialog = inject(MatDialog);
  private readonly confirmacion = inject(Confirmacion);
  private readonly notificacion = inject(Notificacion);

  protected readonly config: CrudConfig<TrasladoResumen> = {
    titulo: 'Traslados',
    descripcion: 'Envío de mercadería entre sucursales',
    singular: 'traslado',
    ruta: '/inventario/traslados',
    servicio: this.servicio,
    id: 'idTraslado',
    nuevoRuta: 'nuevo',
    editable: false,
    desactivable: false,
    etiqueta: (t) => `traslado ${t.idTraslado}`,
    tonoEstado: (estado) => (estado === 'Enviado' ? 'aviso' : estado === 'Recibido' ? 'exito' : 'inactivo'),
    resumen: (filas) =>
      `${filas.length} traslados · ${filas.filter((t) => t.estado === 'Enviado').length} en tránsito`,
    columnas: [
      { campo: 'idTraslado', titulo: 'No.', clase: 'col-codigo' },
      { campo: 'fecha', titulo: 'Fecha', tipo: 'fecha' },
      { campo: 'origen', titulo: 'Origen' },
      { campo: 'destino', titulo: 'Destino' },
      { campo: 'observacion', titulo: 'Observación' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [],
    acciones: [
      { icono: 'visibility', texto: 'Ver traslado', permiso: 'consultar', ejecutar: (t) => this.ver(t) },
      {
        icono: 'inventory',
        texto: 'Recibir traslado',
        permiso: 'puedeEditar',
        visible: (t) => t.estado === 'Enviado',
        ejecutar: (t, recargar) =>
          this.confirmacion.ejecutar(
            {
              titulo: 'Recibir traslado',
              mensaje: `¿Llegó a ${t.destino} la mercadería enviada desde ${t.origen}? Se sumará a su inventario.`,
              accion: 'Recibir',
            },
            () => this.servicio.recibir(t.idTraslado),
            'Traslado recibido. El inventario se actualizó.',
            recargar,
          ),
      },
      {
        icono: 'cancel',
        texto: 'Cancelar traslado',
        permiso: 'puedeEditar',
        visible: (t) => t.estado === 'Enviado',
        ejecutar: (t, recargar) =>
          this.confirmacion.ejecutar(
            {
              titulo: 'Cancelar traslado',
              mensaje: `¿Desea cancelar el traslado ${t.idTraslado}? La mercadería regresará al inventario de ${t.origen}.`,
              accion: 'Cancelar traslado',
              peligro: true,
            },
            () => this.servicio.cancelar(t.idTraslado),
            'Traslado cancelado',
            recargar,
          ),
      },
    ],
  };

  private ver(traslado: TrasladoResumen) {
    this.servicio.detalle(traslado.idTraslado).subscribe({
      next: ({ traslado: t, lineas }) =>
        this.dialog.open(DocumentoDetalle, {
          width: '640px',
          data: {
            titulo: `Traslado ${t.idTraslado}`,
            cabecera: [
              { etiqueta: 'Origen', valor: t.origen },
              { etiqueta: 'Destino', valor: t.destino },
              { etiqueta: 'Fecha', valor: fechaCorta(t.fecha) },
              { etiqueta: 'Estado', valor: t.estado },
              { etiqueta: 'Observación', valor: t.observacion ?? '' },
            ],
            columnas: [
              { campo: 'producto', titulo: 'Producto' },
              { campo: 'cantidad', titulo: 'Cantidad', tipo: 'numero' },
            ],
            lineas,
          },
        }),
      error: (error) => this.notificacion.error(error),
    });
  }
}
