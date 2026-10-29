import { Component, inject } from '@angular/core';
import { Departamento, Municipio, Sucursal } from '../../data/models/geografia';
import {
  DepartamentoService,
  MunicipioService,
  SucursalService,
} from '../../data/services/geografia.service';
import { CrudConfig, opcionesDe } from '../../shared/crud/crud';
import { CrudPagina } from '../../shared/crud/crud-pagina';

@Component({
  selector: 'app-departamentos',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Departamentos {
  protected readonly config: CrudConfig<Departamento> = {
    titulo: 'Departamentos',
    descripcion: 'Departamentos del país',
    singular: 'departamento',
    ruta: '/geografia/departamentos',
    servicio: inject(DepartamentoService),
    id: 'idDepartamento',
    columnas: [
      { campo: 'idDepartamento', titulo: 'Código', clase: 'col-codigo' },
      { campo: 'nombre', titulo: 'Nombre' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [{ nombre: 'nombre', etiqueta: 'Nombre', requerido: true, largoMax: 60 }],
  };
}

@Component({
  selector: 'app-municipios',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Municipios {
  protected readonly config: CrudConfig<Municipio> = {
    titulo: 'Municipios',
    descripcion: 'Municipios por departamento',
    singular: 'municipio',
    ruta: '/geografia/municipios',
    servicio: inject(MunicipioService),
    id: 'idMunicipio',
    columnas: [
      { campo: 'idMunicipio', titulo: 'Código', clase: 'col-codigo' },
      { campo: 'nombre', titulo: 'Nombre' },
      { campo: 'departamento', titulo: 'Departamento' },
      { campo: 'esCabecera', titulo: 'Cabecera', tipo: 'sino' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [
      {
        nombre: 'idDepartamento',
        etiqueta: 'Departamento',
        tipo: 'select',
        requerido: true,
        opciones: opcionesDe(inject(DepartamentoService), 'idDepartamento', (d) => d.nombre),
      },
      { nombre: 'nombre', etiqueta: 'Nombre', requerido: true, largoMax: 80 },
      { nombre: 'esCabecera', etiqueta: 'Es cabecera departamental', tipo: 'sino' },
    ],
  };
}

@Component({
  selector: 'app-sucursales',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Sucursales {
  protected readonly config: CrudConfig<Sucursal> = {
    titulo: 'Sucursales',
    descripcion: 'Tiendas de la cadena',
    singular: 'sucursal',
    femenino: true,
    ruta: '/geografia/sucursales',
    servicio: inject(SucursalService),
    id: 'idSucursal',
    columnas: [
      { campo: 'codigo', titulo: 'Código', clase: 'col-codigo' },
      { campo: 'nombre', titulo: 'Nombre' },
      { campo: 'municipio', titulo: 'Municipio' },
      { campo: 'telefono', titulo: 'Teléfono' },
      { campo: 'fechaApertura', titulo: 'Apertura', tipo: 'fecha' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [
      { nombre: 'codigo', etiqueta: 'Código', requerido: true, largoMax: 10 },
      { nombre: 'nombre', etiqueta: 'Nombre', requerido: true, largoMax: 100 },
      {
        nombre: 'idMunicipio',
        etiqueta: 'Municipio',
        tipo: 'select',
        requerido: true,
        opciones: opcionesDe(inject(MunicipioService), 'idMunicipio', (m) => `${m.nombre}, ${m.departamento}`),
      },
      { nombre: 'fechaApertura', etiqueta: 'Fecha de apertura', tipo: 'fecha', requerido: true },
      { nombre: 'telefono', etiqueta: 'Teléfono', largoMax: 15 },
      { nombre: 'correo', etiqueta: 'Correo', tipo: 'correo', largoMax: 100 },
      { nombre: 'direccion', etiqueta: 'Dirección', requerido: true, largoMax: 200, completo: true },
    ],
  };
}
