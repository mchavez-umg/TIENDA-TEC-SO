import { HttpClient } from '@angular/common/http';
import { computed, inject, Injectable, signal } from '@angular/core';
import { Router } from '@angular/router';
import { tap } from 'rxjs';
import { LoginRequest, Sesion } from '../data/models/auth';
import { API_URL } from './api';

const CLAVE_SESION = 'tienda.sesion';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  private readonly sesionActual = signal<Sesion | null>(leerSesion());

  readonly sesion = this.sesionActual.asReadonly();
  readonly autenticado = computed(() => this.sesionActual() !== null);

  login(request: LoginRequest) {
    return this.http.post<Sesion>(`${API_URL}/auth/login`, request).pipe(
      tap((sesion) => {
        localStorage.setItem(CLAVE_SESION, JSON.stringify(sesion));
        this.sesionActual.set(sesion);
      }),
    );
  }

  logout() {
    localStorage.removeItem(CLAVE_SESION);
    this.sesionActual.set(null);
    this.router.navigateByUrl('/login');
  }
}

function leerSesion(): Sesion | null {
  try {
    const sesion: Sesion | null = JSON.parse(localStorage.getItem(CLAVE_SESION) ?? 'null');
    return sesion && !expirado(sesion.token) ? sesion : null;
  } catch {
    return null;
  }
}

function expirado(token: string) {
  const payload = JSON.parse(atob(token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')));
  return payload.exp * 1000 <= Date.now();
}
