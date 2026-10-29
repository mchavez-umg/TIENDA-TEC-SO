import { Component, inject } from '@angular/core';
import { Banco, FormaPago } from '../../data/models/comercial';
import { BancoService, FormaPagoService } from '../../data/services/comercial.service';
import { CrudConfig } from '../../shared/crud/crud';
import { CrudPagina } from '../../shared/crud/crud-pagina';

@Component({
  selector: 'app-bancos',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Bancos {
  protected readonly config: CrudConfig<Banco> = {
    titulo: 'Bancos',
    descripcion: 'Bancos para pagos con tarjeta o transferencia',
    singular: 'banco',
    ruta: '/ventas/bancos',
    servicio: inject(BancoService),
    id: 'idBanco',
    columnas: [
      { campo: 'idBanco', titulo: 'Código', clase: 'col-codigo' },
      { campo: 'nombre', titulo: 'Nombre' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [{ nombre: 'nombre', etiqueta: 'Nombre', requerido: true, largoMax: 80 }],
  };
}

@Component({
  selector: 'app-formas-pago',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class FormasPago {
  protected readonly config: CrudConfig<FormaPago> = {
    titulo: 'Formas de pago',
    descripcion: 'Medios de pago aceptados en caja',
    singular: 'forma de pago',
    femenino: true,
    ruta: '/ventas/formas-pago',
    servicio: inject(FormaPagoService),
    id: 'idFormaPago',
    columnas: [
      { campo: 'idFormaPago', titulo: 'Código', clase: 'col-codigo' },
      { campo: 'nombre', titulo: 'Nombre' },
      { campo: 'requiereReferencia', titulo: 'Requiere referencia', tipo: 'sino' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [
      { nombre: 'nombre', etiqueta: 'Nombre', requerido: true, largoMax: 30 },
      { nombre: 'requiereReferencia', etiqueta: 'Requiere número de referencia', tipo: 'sino' },
    ],
  };
}
