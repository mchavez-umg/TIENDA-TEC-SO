import { Injectable } from '@angular/core';
import { API_URL } from '../../core/api';
import { Departamento, Municipio, Sucursal } from '../models/geografia';
import { CrudService } from './crud.service';

@Injectable({ providedIn: 'root' })
export class DepartamentoService extends CrudService<Departamento> {
  protected readonly url = `${API_URL}/departamentos`;
}

@Injectable({ providedIn: 'root' })
export class MunicipioService extends CrudService<Municipio> {
  protected readonly url = `${API_URL}/municipios`;
}

@Injectable({ providedIn: 'root' })
export class SucursalService extends CrudService<Sucursal> {
  protected readonly url = `${API_URL}/sucursales`;
}
