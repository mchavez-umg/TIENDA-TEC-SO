import { Component, inject } from '@angular/core';
import { AsignacionHorario, Empleado, Horario, Puesto } from '../../data/models/personal';
import { SucursalService } from '../../data/services/geografia.service';
import {
  AsignacionHorarioService,
  EmpleadoService,
  HorarioService,
  PuestoService,
} from '../../data/services/personal.service';
import { CrudConfig, opcionesDe } from '../../shared/crud/crud';
import { CrudPagina } from '../../shared/crud/crud-pagina';

@Component({
  selector: 'app-puestos',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Puestos {
  protected readonly config: CrudConfig<Puesto> = {
    titulo: 'Puestos',
    descripcion: 'Puestos de trabajo y salario base',
    singular: 'puesto',
    ruta: '/personal/puestos',
    servicio: inject(PuestoService),
    id: 'idPuesto',
    columnas: [
      { campo: 'idPuesto', titulo: 'Código', clase: 'col-codigo' },
      { campo: 'nombre', titulo: 'Nombre' },
      { campo: 'descripcion', titulo: 'Descripción' },
      { campo: 'salarioBase', titulo: 'Salario base', tipo: 'moneda' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [
      { nombre: 'nombre', etiqueta: 'Nombre', requerido: true, largoMax: 60 },
      { nombre: 'salarioBase', etiqueta: 'Salario base', tipo: 'moneda', requerido: true, min: 0 },
      { nombre: 'descripcion', etiqueta: 'Descripción', tipo: 'area', largoMax: 200 },
    ],
  };
}

@Component({
  selector: 'app-empleados',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Empleados {
  protected readonly config: CrudConfig<Empleado> = {
    titulo: 'Empleados',
    descripcion: 'Personal de las sucursales',
    singular: 'empleado',
    ruta: '/personal/empleados',
    servicio: inject(EmpleadoService),
    id: 'idEmpleado',
    etiqueta: (e) => `${e.nombres} ${e.apellidos}`,
    columnas: [
      { campo: 'dpi', titulo: 'DPI', clase: 'col-fecha' },
      { campo: 'nombres', titulo: 'Nombres' },
      { campo: 'apellidos', titulo: 'Apellidos' },
      { campo: 'puesto', titulo: 'Puesto' },
      { campo: 'sucursal', titulo: 'Sucursal' },
      { campo: 'fechaIngreso', titulo: 'Ingreso', tipo: 'fecha' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [
      {
        nombre: 'dpi',
        etiqueta: 'DPI',
        requerido: true,
        largoMax: 13,
        patron: '\\d{13}',
        mensajePatron: 'El DPI debe tener 13 dígitos',
      },
      { nombre: 'fechaIngreso', etiqueta: 'Fecha de ingreso', tipo: 'fecha', requerido: true },
      { nombre: 'nombres', etiqueta: 'Nombres', requerido: true, largoMax: 80 },
      { nombre: 'apellidos', etiqueta: 'Apellidos', requerido: true, largoMax: 80 },
      {
        nombre: 'idSucursal',
        etiqueta: 'Sucursal',
        tipo: 'select',
        requerido: true,
        opciones: opcionesDe(inject(SucursalService), 'idSucursal', (s) => s.nombre),
      },
      {
        nombre: 'idPuesto',
        etiqueta: 'Puesto',
        tipo: 'select',
        requerido: true,
        opciones: opcionesDe(inject(PuestoService), 'idPuesto', (p) => p.nombre),
      },
      { nombre: 'telefono', etiqueta: 'Teléfono', largoMax: 15 },
      { nombre: 'correo', etiqueta: 'Correo', tipo: 'correo', largoMax: 100 },
      { nombre: 'direccion', etiqueta: 'Dirección', largoMax: 200, completo: true },
    ],
  };
}

@Component({
  selector: 'app-horarios',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Horarios {
  protected readonly config: CrudConfig<Horario> = {
    titulo: 'Horarios',
    descripcion: 'Jornadas de trabajo',
    singular: 'horario',
    ruta: '/personal/horarios',
    servicio: inject(HorarioService),
    id: 'idHorario',
    columnas: [
      { campo: 'idHorario', titulo: 'Código', clase: 'col-codigo' },
      { campo: 'nombre', titulo: 'Nombre' },
      { campo: 'horaEntrada', titulo: 'Entrada', clase: 'col-fecha' },
      { campo: 'horaSalida', titulo: 'Salida', clase: 'col-fecha' },
      { campo: 'diasSemana', titulo: 'Días' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [
      { nombre: 'nombre', etiqueta: 'Nombre', requerido: true, largoMax: 50, completo: true },
      { nombre: 'horaEntrada', etiqueta: 'Hora de entrada', tipo: 'hora', requerido: true },
      { nombre: 'horaSalida', etiqueta: 'Hora de salida', tipo: 'hora', requerido: true },
      {
        nombre: 'diasSemana',
        etiqueta: 'Días',
        requerido: true,
        largoMax: 30,
        pista: 'Ej.: Lunes a Viernes',
        completo: true,
      },
    ],
  };
}

@Component({
  selector: 'app-asignacion-horarios',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class AsignacionHorarios {
  protected readonly config: CrudConfig<AsignacionHorario> = {
    titulo: 'Asignaciones de horario',
    descripcion: 'Horario vigente de cada empleado',
    singular: 'asignación',
    femenino: true,
    ruta: '/personal/asignacion-horarios',
    servicio: inject(AsignacionHorarioService),
    id: 'idEmpleadoHorario',
    etiqueta: (a) => `${a.empleado} – ${a.horario}`,
    columnas: [
      { campo: 'empleado', titulo: 'Empleado' },
      { campo: 'horario', titulo: 'Horario' },
      { campo: 'fechaInicio', titulo: 'Desde', tipo: 'fecha' },
      { campo: 'fechaFin', titulo: 'Hasta', tipo: 'fecha' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [
      {
        nombre: 'idEmpleado',
        etiqueta: 'Empleado',
        tipo: 'select',
        requerido: true,
        completo: true,
        opciones: opcionesDe(inject(EmpleadoService), 'idEmpleado', (e) => `${e.nombres} ${e.apellidos}`),
      },
      {
        nombre: 'idHorario',
        etiqueta: 'Horario',
        tipo: 'select',
        requerido: true,
        completo: true,
        opciones: opcionesDe(
          inject(HorarioService),
          'idHorario',
          (h) => `${h.nombre} (${h.horaEntrada} – ${h.horaSalida})`,
        ),
      },
      { nombre: 'fechaInicio', etiqueta: 'Fecha de inicio', tipo: 'fecha', requerido: true },
      { nombre: 'fechaFin', etiqueta: 'Fecha de fin', tipo: 'fecha' },
    ],
  };
}
