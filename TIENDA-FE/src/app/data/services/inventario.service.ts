import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { API_URL } from '../../core/api';
import { Existencia } from '../models/inventario';

@Injectable({ providedIn: 'root' })
export class InventarioService {
  private readonly http = inject(HttpClient);

  existencias(idSucursal: number) {
    return this.http.get<Existencia[]>(`${API_URL}/inventario/existencias`, {
      params: { idSucursal },
    });
  }
}
