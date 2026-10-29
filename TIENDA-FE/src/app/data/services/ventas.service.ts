import { HttpClient, HttpParams } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { API_URL } from '../../core/api';
import { FacturaDetalle, FacturaResumen, VentaRegistrada, VentaRequest } from '../models/ventas';

export interface FiltrosFacturas {
  desde?: string | null;
  hasta?: string | null;
  idSucursal?: number | null;
}

@Injectable({ providedIn: 'root' })
export class FacturaService {
  private readonly http = inject(HttpClient);
  private readonly url = `${API_URL}/ventas`;

  listar(filtros: FiltrosFacturas) {
    let params = new HttpParams();
    for (const [clave, valor] of Object.entries(filtros)) {
      if (valor != null && valor !== '') {
        params = params.set(clave, valor);
      }
    }
    return this.http.get<FacturaResumen[]>(this.url, { params });
  }

  obtener(id: number) {
    return this.http.get<FacturaDetalle>(`${this.url}/${id}`);
  }

  registrar(request: VentaRequest) {
    return this.http.post<VentaRegistrada>(this.url, request);
  }
}
