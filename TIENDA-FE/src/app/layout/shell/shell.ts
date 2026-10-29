import { BreakpointObserver } from '@angular/cdk/layout';
import { Component, computed, effect, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatTooltipModule } from '@angular/material/tooltip';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { filter, map } from 'rxjs';
import { AuthService } from '../../core/auth.service';
import { MenuService } from '../../core/menu.service';
import { MenuNodo } from '../../data/models/menu';

@Component({
  selector: 'app-shell',
  imports: [
    RouterOutlet,
    RouterLink,
    RouterLinkActive,
    MatSidenavModule,
    MatToolbarModule,
    MatIconModule,
    MatButtonModule,
    MatTooltipModule,
  ],
  templateUrl: './shell.html',
  styleUrl: './shell.scss',
})
export class Shell {
  protected readonly auth = inject(AuthService);
  protected readonly menu = inject(MenuService);
  private readonly router = inject(Router);

  private readonly url = toSignal(
    this.router.events.pipe(
      filter((e) => e instanceof NavigationEnd),
      map((e) => e.urlAfterRedirects.split('?')[0]),
    ),
    { initialValue: this.router.url.split('?')[0] },
  );
  private readonly actual = computed(() => {
    const url = this.url();
    return this.menu.opciones().find((o) => o.ruta && (url === o.ruta || url.startsWith(o.ruta + '/')));
  });
  private readonly abiertos = signal(new Set<number>());

  protected readonly movil = toSignal(
    inject(BreakpointObserver)
      .observe('(max-width: 899px)')
      .pipe(map((estado) => estado.matches)),
    { initialValue: false },
  );
  protected readonly menuAbierto = signal(false);

  protected readonly migas = computed(() => {
    const actual = this.actual();
    if (!actual) {
      return [];
    }
    const padre = this.menu.opciones().find((o) => o.idOpcion === actual.idOpcionPadre);
    return padre ? [padre.nombre, actual.nombre] : [actual.nombre];
  });

  constructor() {
    this.menu.cargar();
    effect(() => {
      this.url();
      this.menuAbierto.set(false);
    });
    effect(() => {
      const padre = this.actual()?.idOpcionPadre;
      if (padre != null) {
        this.abiertos.update((abiertos) => new Set(abiertos).add(padre));
      }
    });
  }

  protected contieneActual(nodo: MenuNodo) {
    return nodo.hijos.some((h) => h.idOpcion === this.actual()?.idOpcion);
  }

  protected expandido(nodo: MenuNodo) {
    return this.abiertos().has(nodo.idOpcion);
  }

  protected alternar(nodo: MenuNodo) {
    this.abiertos.update((abiertos) => {
      const copia = new Set(abiertos);
      if (!copia.delete(nodo.idOpcion)) {
        copia.add(nodo.idOpcion);
      }
      return copia;
    });
  }
}
