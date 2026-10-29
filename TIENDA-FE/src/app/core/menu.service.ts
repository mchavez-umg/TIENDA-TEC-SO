import { HttpClient } from '@angular/common/http';
import { computed, inject, Injectable, signal } from '@angular/core';
import { MenuNodo, MenuOpcion } from '../data/models/menu';
import { Notificacion } from '../shared/notificacion.service';
import { API_URL } from './api';

@Injectable({ providedIn: 'root' })
export class MenuService {
  private readonly http = inject(HttpClient);
  private readonly notificacion = inject(Notificacion);

  readonly opciones = signal<MenuOpcion[]>([]);
  readonly arbol = computed<MenuNodo[]>(() => {
    const opciones = this.opciones();
    return opciones
      .filter((o) => o.idOpcionPadre === null)
      .map((raiz) => ({
        ...raiz,
        hijos: opciones.filter((o) => o.idOpcionPadre === raiz.idOpcion),
      }));
  });

  cargar() {
    this.opciones.set([]);
    this.http.get<MenuOpcion[]>(`${API_URL}/menu`).subscribe({
      next: (opciones) => this.opciones.set(opciones),
      error: (error) => this.notificacion.error(error),
    });
  }

  opcion(ruta: string) {
    return this.opciones().find((o) => o.ruta === ruta);
  }
}
