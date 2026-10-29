import { Injectable } from '@angular/core';
import { API_URL } from '../../core/api';
import {
  CompraDetalle,
  CompraRequest,
  CompraResumen,
  TrasladoDetalle,
  TrasladoRequest,
  TrasladoResumen,
} from '../models/movimientos';
import { CrudService } from './crud.service';

@Injectable({ providedIn: 'root' })
export class CompraService extends CrudService<CompraResumen> {
  protected readonly url = `${API_URL}/compras`;

  detalle(id: number) {
    return this.http.get<CompraDetalle>(`${this.url}/${id}`);
  }

  registrar(request: CompraRequest) {
    return this.http.post<CompraDetalle>(this.url, request);
  }

  recibir(id: number) {
    return this.http.post<CompraDetalle>(`${this.url}/${id}/recibir`, null);
  }

  anular(id: number) {
    return this.http.post<void>(`${this.url}/${id}/anular`, null);
  }
}

@Injectable({ providedIn: 'root' })
export class TrasladoService extends CrudService<TrasladoResumen> {
  protected readonly url = `${API_URL}/traslados`;

  detalle(id: number) {
    return this.http.get<TrasladoDetalle>(`${this.url}/${id}`);
  }

  registrar(request: TrasladoRequest) {
    return this.http.post<TrasladoDetalle>(this.url, request);
  }

  recibir(id: number) {
    return this.http.post<TrasladoDetalle>(`${this.url}/${id}/recibir`, null);
  }

  cancelar(id: number) {
    return this.http.post<void>(`${this.url}/${id}/cancelar`, null);
  }
}
