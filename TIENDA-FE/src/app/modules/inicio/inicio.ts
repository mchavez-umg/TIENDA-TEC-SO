import { CurrencyPipe, DecimalPipe } from '@angular/common';
import { Component, computed, effect, inject, signal, untracked } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { AuthService } from '../../core/auth.service';
import { MenuService } from '../../core/menu.service';
import { Dashboard } from '../../data/models/reportes';
import { ReporteService } from '../../data/services/reportes.service';

export function resumirSucursales(datos: Dashboard) {
  const total = datos.totalVendidoMes;
  const maximo = Math.max(0, ...datos.ventasPorSucursalMes.map((s) => s.totalVendido));
  return [...datos.ventasPorSucursalMes]
    .sort((a, b) => b.totalVendido - a.totalVendido)
    .map((s) => ({
      ...s,
      participacion: total > 0 ? (s.totalVendido / total) * 100 : 0,
      barra: maximo > 0 ? (s.totalVendido / maximo) * 100 : 0,
    }));
}

@Component({
  selector: 'app-inicio',
  imports: [
    CurrencyPipe,
    DecimalPipe,
    RouterLink,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatProgressBarModule,
  ],
  templateUrl: './inicio.html',
  styleUrl: './inicio.scss',
})
export class Inicio {
  protected readonly auth = inject(AuthService);
  protected readonly menu = inject(MenuService);
  private readonly reportes = inject(ReporteService);

  protected readonly mes = new Intl.DateTimeFormat('es-GT', { month: 'long', year: 'numeric' }).format(
    new Date(),
  );
  protected readonly permitido = computed(() => !!this.menu.opcion('/reportes/dashboard'));
  protected readonly datos = signal<Dashboard | null>(null);
  protected readonly cargando = signal(false);
  protected readonly fallo = signal(false);

  protected readonly sucursales = computed(() => {
    const datos = this.datos();
    return datos ? resumirSucursales(datos) : [];
  });
  protected readonly ticketPromedio = computed(() => {
    const datos = this.datos();
    return datos && datos.facturasMes > 0 ? datos.totalVendidoMes / datos.facturasMes : null;
  });
  protected readonly hallazgo = computed(() => {
    const lider = this.sucursales()[0];
    if (!lider || lider.totalVendido === 0) {
      return `Aún no hay ventas registradas en ${this.mes}.`;
    }
    const porcentaje = lider.participacion.toFixed(0);
    return `${lider.sucursal} lleva el ${porcentaje} % de lo vendido en ${this.mes}.`;
  });

  constructor() {
    effect(() => {
      if (this.permitido()) {
        untracked(() => this.cargar());
      }
    });
  }

  protected cargar() {
    this.cargando.set(true);
    this.fallo.set(false);
    this.reportes
      .dashboard()
      .pipe(finalize(() => this.cargando.set(false)))
      .subscribe({
        next: (datos) => this.datos.set(datos),
        error: () => this.fallo.set(true),
      });
  }
}
