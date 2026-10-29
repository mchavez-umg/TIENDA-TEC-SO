import { Injectable } from '@angular/core';
import { API_URL } from '../../core/api';
import { AsignacionHorario, Empleado, Horario, Puesto } from '../models/personal';
import { CrudService } from './crud.service';

@Injectable({ providedIn: 'root' })
export class PuestoService extends CrudService<Puesto> {
  protected readonly url = `${API_URL}/puestos`;
}

@Injectable({ providedIn: 'root' })
export class EmpleadoService extends CrudService<Empleado> {
  protected readonly url = `${API_URL}/empleados`;
}

@Injectable({ providedIn: 'root' })
export class HorarioService extends CrudService<Horario> {
  protected readonly url = `${API_URL}/horarios`;
}

@Injectable({ providedIn: 'root' })
export class AsignacionHorarioService extends CrudService<AsignacionHorario> {
  protected readonly url = `${API_URL}/asignaciones-horario`;
}
