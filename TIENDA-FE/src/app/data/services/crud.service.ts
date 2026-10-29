import { HttpClient } from '@angular/common/http';
import { inject } from '@angular/core';

export type Valores = Record<string, unknown>;

export abstract class CrudService<T> {
  protected readonly http = inject(HttpClient);
  protected abstract readonly url: string;

  listar() {
    return this.http.get<T[]>(this.url);
  }

  obtener(id: number) {
    return this.http.get<T>(`${this.url}/${id}`);
  }

  crear(request: Valores) {
    return this.http.post<T>(this.url, request);
  }

  actualizar(id: number, request: Valores) {
    return this.http.put<T>(`${this.url}/${id}`, request);
  }

  desactivar(id: number) {
    return this.http.delete<void>(`${this.url}/${id}`);
  }

  activar(id: number) {
    return this.http.put<void>(`${this.url}/${id}/activar`, null);
  }
}
