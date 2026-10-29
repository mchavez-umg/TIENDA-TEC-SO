import { Component, inject } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Proveedor } from '../../data/models/comercial';
import { CompraResumen } from '../../data/models/movimientos';
import { ProveedorService } from '../../data/services/comercial.service';
import { CompraService } from '../../data/services/movimientos.service';
import { Confirmacion } from '../../shared/confirmacion/confirmacion';
import { CrudConfig } from '../../shared/crud/crud';
import { CrudPagina } from '../../shared/crud/crud-pagina';
import { DocumentoDetalle } from '../../shared/documento-detalle/documento-detalle';
import { Notificacion } from '../../shared/notificacion.service';

export const fechaCorta = (fecha: string) => fecha.slice(0, 10).split('-').reverse().join('/');

@Component({
  selector: 'app-proveedores',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Proveedores {
  protected readonly config: CrudConfig<Proveedor> = {
    titulo: 'Proveedores',
    descripcion: 'Empresas que abastecen a la tienda',
    singular: 'proveedor',
    ruta: '/compras/proveedores',
    servicio: inject(ProveedorService),
    id: 'idProveedor',
    columnas: [
      { campo: 'nit', titulo: 'NIT', clase: 'col-fecha' },
      { campo: 'nombre', titulo: 'Nombre' },
      { campo: 'contacto', titulo: 'Contacto' },
      { campo: 'telefono', titulo: 'Teléfono' },
      { campo: 'correo', titulo: 'Correo' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [
      { nombre: 'nit', etiqueta: 'NIT', requerido: true, largoMax: 15 },
      { nombre: 'nombre', etiqueta: 'Nombre', requerido: true, largoMax: 120 },
      { nombre: 'contacto', etiqueta: 'Contacto', largoMax: 100 },
      { nombre: 'telefono', etiqueta: 'Teléfono', largoMax: 15 },
      { nombre: 'correo', etiqueta: 'Correo', tipo: 'correo', largoMax: 100, completo: true },
      { nombre: 'direccion', etiqueta: 'Dirección', largoMax: 200, completo: true },
    ],
  };
}

@Component({
  selector: 'app-compras',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Compras {
  private readonly servicio = inject(CompraService);
  private readonly dialog = inject(MatDialog);
  private readonly confirmacion = inject(Confirmacion);
  private readonly notificacion = inject(Notificacion);

  protected readonly config: CrudConfig<CompraResumen> = {
    titulo: 'Compras',
    descripcion: 'Compras a proveedores',
    singular: 'compra',
    femenino: true,
    ruta: '/compras/compras',
    servicio: this.servicio,
    id: 'idCompra',
    nuevoRuta: 'nueva',
    editable: false,
    desactivable: false,
    etiqueta: (c) => `documento ${c.noDocumento}`,
    tonoEstado: (estado) => (estado === 'Pendiente' ? 'aviso' : estado === 'Recibida' ? 'exito' : 'inactivo'),
    resumen: (filas) =>
      `${filas.length} compras · ${filas.filter((c) => c.estado === 'Pendiente').length} pendientes de recibir`,
    columnas: [
      { campo: 'idCompra', titulo: 'No.', clase: 'col-codigo' },
      { campo: 'fecha', titulo: 'Fecha', tipo: 'fecha' },
      { campo: 'proveedor', titulo: 'Proveedor' },
      { campo: 'sucursal', titulo: 'Sucursal' },
      { campo: 'noDocumento', titulo: 'Documento', clase: 'col-codigo' },
      { campo: 'total', titulo: 'Total', tipo: 'moneda' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [],
    acciones: [
      { icono: 'visibility', texto: 'Ver compra', permiso: 'consultar', ejecutar: (c) => this.ver(c) },
      {
        icono: 'inventory',
        texto: 'Recibir mercadería',
        permiso: 'puedeEditar',
        visible: (c) => c.estado === 'Pendiente',
        ejecutar: (c, recargar) =>
          this.confirmacion.ejecutar(
            {
              titulo: 'Recibir compra',
              mensaje: `¿Llegó la mercadería del documento ${c.noDocumento}? Se sumará al inventario de ${c.sucursal}.`,
              accion: 'Recibir',
            },
            () => this.servicio.recibir(c.idCompra),
            'Compra recibida. El inventario se actualizó.',
            recargar,
          ),
      },
      {
        icono: 'cancel',
        texto: 'Anular compra',
        permiso: 'puedeEditar',
        visible: (c) => c.estado === 'Pendiente',
        ejecutar: (c, recargar) =>
          this.confirmacion.ejecutar(
            {
              titulo: 'Anular compra',
              mensaje: `¿Desea anular la compra del documento ${c.noDocumento}? No podrá recibirse después.`,
              accion: 'Anular',
              peligro: true,
            },
            () => this.servicio.anular(c.idCompra),
            'Compra anulada',
            recargar,
          ),
      },
    ],
  };

  private ver(compra: CompraResumen) {
    this.servicio.detalle(compra.idCompra).subscribe({
      next: ({ compra: c, lineas }) =>
        this.dialog.open(DocumentoDetalle, {
          width: '720px',
          data: {
            titulo: `Compra ${c.noDocumento}`,
            cabecera: [
              { etiqueta: 'Proveedor', valor: c.proveedor },
              { etiqueta: 'Sucursal', valor: c.sucursal },
              { etiqueta: 'Fecha', valor: fechaCorta(c.fecha) },
              { etiqueta: 'Estado', valor: c.estado },
            ],
            columnas: [
              { campo: 'producto', titulo: 'Producto' },
              { campo: 'cantidad', titulo: 'Cantidad', tipo: 'numero' },
              { campo: 'costoUnitario', titulo: 'Costo unitario', tipo: 'moneda' },
              { campo: 'subtotal', titulo: 'Subtotal', tipo: 'moneda' },
            ],
            lineas,
            total: c.total,
          },
        }),
      error: (error) => this.notificacion.error(error),
    });
  }
}
