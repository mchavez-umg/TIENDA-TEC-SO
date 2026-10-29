import { Injectable } from '@angular/core';
import { API_URL } from '../../core/api';
import { Garantia, NotaDetalle, NotaRequest, NotaResumen } from '../models/postventa';
import { CrudService, Valores } from './crud.service';

@Injectable({ providedIn: 'root' })
export class NotaCreditoService extends CrudService<NotaResumen> {
  protected readonly url = `${API_URL}/notas-credito`;

  detalle(id: number) {
    return this.http.get<NotaDetalle>(`${this.url}/${id}`);
  }

  registrar(request: NotaRequest) {
    return this.http.post<NotaDetalle>(this.url, request);
  }
}

@Injectable({ providedIn: 'root' })
export class GarantiaService extends CrudService<Garantia> {
  protected readonly url = `${API_URL}/garantias`;

  registrar(idDetalleFactura: number, descripcionFalla: string) {
    return this.http.post<Garantia>(this.url, { idDetalleFactura, descripcionFalla });
  }

  revision(id: number) {
    return this.http.post<Garantia>(`${this.url}/${id}/revision`, null);
  }

  reparar(id: number, valores: Valores) {
    return this.http.post<Garantia>(`${this.url}/${id}/reparar`, valores);
  }

  cambiar(id: number, valores: Valores) {
    return this.http.post<Garantia>(`${this.url}/${id}/cambiar`, valores);
  }

  rechazar(id: number, valores: Valores) {
    return this.http.post<Garantia>(`${this.url}/${id}/rechazar`, valores);
  }

  entregar(id: number) {
    return this.http.post<Garantia>(`${this.url}/${id}/entregar`, null);
  }
}
