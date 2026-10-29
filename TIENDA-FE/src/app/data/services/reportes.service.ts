import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { API_URL } from '../../core/api';
import { Dashboard } from '../models/reportes';

@Injectable({ providedIn: 'root' })
export class ReporteService {
  private readonly http = inject(HttpClient);

  dashboard() {
    return this.http.get<Dashboard>(`${API_URL}/reportes/dashboard`);
  }
}
