import { Component, inject } from '@angular/core';
import { Cliente } from '../../data/models/comercial';
import { ClienteService } from '../../data/services/comercial.service';
import { Campo, CrudConfig } from '../../shared/crud/crud';
import { CrudPagina } from '../../shared/crud/crud-pagina';

export const CAMPOS_CLIENTE: Campo[] = [
  { nombre: 'nit', etiqueta: 'NIT', requerido: true, largoMax: 15, completo: true, pista: 'CF si no tiene NIT' },
  { nombre: 'nombres', etiqueta: 'Nombres', requerido: true, largoMax: 80 },
  { nombre: 'apellidos', etiqueta: 'Apellidos', largoMax: 80 },
  { nombre: 'telefono', etiqueta: 'Teléfono', largoMax: 15 },
  { nombre: 'correo', etiqueta: 'Correo', tipo: 'correo', largoMax: 100 },
  { nombre: 'direccion', etiqueta: 'Dirección', largoMax: 200, completo: true },
];

@Component({
  selector: 'app-clientes',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Clientes {
  protected readonly config: CrudConfig<Cliente> = {
    titulo: 'Clientes',
    descripcion: 'Clientes registrados para facturación',
    singular: 'cliente',
    ruta: '/clientes',
    servicio: inject(ClienteService),
    id: 'idCliente',
    etiqueta: (c) => `${c.nombres} ${c.apellidos ?? ''}`.trim(),
    columnas: [
      { campo: 'nit', titulo: 'NIT', clase: 'col-fecha' },
      { campo: 'nombres', titulo: 'Nombres' },
      { campo: 'apellidos', titulo: 'Apellidos' },
      { campo: 'telefono', titulo: 'Teléfono' },
      { campo: 'correo', titulo: 'Correo' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: CAMPOS_CLIENTE,
  };
}
