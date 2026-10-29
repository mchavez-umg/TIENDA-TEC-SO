import { Injectable } from '@angular/core';
import { API_URL } from '../../core/api';
import { OpcionCatalogo, OpcionMenuAdmin, PermisoRol, Rol, Usuario } from '../models/seguridad';
import { CrudService, Valores } from './crud.service';

@Injectable({ providedIn: 'root' })
export class RolService extends CrudService<Rol> {
  protected readonly url = `${API_URL}/roles`;

  catalogoOpciones() {
    return this.http.get<OpcionCatalogo[]>(`${API_URL}/opciones-menu`);
  }

  permisos(idRol: number) {
    return this.http.get<PermisoRol[]>(`${this.url}/${idRol}/opciones`);
  }

  asignarPermiso(idRol: number, idOpcion: number, permisos: Valores) {
    return this.http.put<PermisoRol[]>(`${this.url}/${idRol}/opciones/${idOpcion}`, permisos);
  }

  quitarPermiso(idRol: number, idOpcion: number) {
    return this.http.delete<void>(`${this.url}/${idRol}/opciones/${idOpcion}`);
  }
}

@Injectable({ providedIn: 'root' })
export class UsuarioService extends CrudService<Usuario> {
  protected readonly url = `${API_URL}/usuarios`;

  restablecerPassword(id: number, request: Valores) {
    return this.http.post<void>(`${this.url}/${id}/restablecer-password`, request);
  }
}

@Injectable({ providedIn: 'root' })
export class OpcionMenuService extends CrudService<OpcionMenuAdmin> {
  protected readonly url = `${API_URL}/opciones-menu-admin`;
}
