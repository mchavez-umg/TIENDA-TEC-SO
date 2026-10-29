import { Component, computed, inject, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { finalize, forkJoin, Observable } from 'rxjs';
import { OpcionCatalogo, Rol } from '../../data/models/seguridad';
import { RolService } from '../../data/services/seguridad.service';
import { Notificacion } from '../../shared/notificacion.service';

const CLAVES = ['puedeConsultar', 'puedeCrear', 'puedeEditar', 'puedeEliminar'] as const;
type Clave = (typeof CLAVES)[number];
type Permisos = Record<Clave, boolean>;

const SIN_PERMISOS: Permisos = {
  puedeConsultar: false,
  puedeCrear: false,
  puedeEditar: false,
  puedeEliminar: false,
};

@Component({
  selector: 'app-permisos-dialogo',
  imports: [MatDialogModule, MatCheckboxModule, MatButtonModule, MatProgressBarModule],
  templateUrl: './permisos-dialogo.html',
  styleUrl: './permisos-dialogo.scss',
})
export class PermisosDialogo {
  protected readonly rol = inject<Rol>(MAT_DIALOG_DATA);
  private readonly servicio = inject(RolService);
  private readonly notificacion = inject(Notificacion);

  protected readonly claves = CLAVES;
  protected readonly titulos: Record<Clave, string> = {
    puedeConsultar: 'Consultar',
    puedeCrear: 'Crear',
    puedeEditar: 'Editar',
    puedeEliminar: 'Desactivar',
  };
  protected readonly cargando = signal(true);
  protected readonly pendientes = signal(0);
  protected readonly guardadoAlguna = signal(false);
  private readonly catalogo = signal<OpcionCatalogo[]>([]);
  private readonly permisos = signal(new Map<number, Permisos>());

  protected readonly grupos = computed(() => {
    const opciones = [...this.catalogo()].sort((a, b) => a.orden - b.orden);
    return opciones
      .filter((o) => o.idOpcionPadre === null)
      .map((raiz) => ({
        raiz,
        hojas: raiz.ruta ? [raiz] : opciones.filter((o) => o.idOpcionPadre === raiz.idOpcion && o.ruta),
      }));
  });

  constructor() {
    forkJoin([this.servicio.catalogoOpciones(), this.servicio.permisos(this.rol.idRol)])
      .pipe(finalize(() => this.cargando.set(false)))
      .subscribe({
        next: ([catalogo, permisos]) => {
          this.catalogo.set(catalogo);
          this.permisos.set(
            new Map(
              permisos.map((p) => [
                p.idOpcion,
                Object.fromEntries(CLAVES.map((c) => [c, p[c] === 'S'])) as Permisos,
              ]),
            ),
          );
        },
        error: (error) => this.notificacion.error(error),
      });
  }

  protected permiso(idOpcion: number) {
    return this.permisos().get(idOpcion) ?? SIN_PERMISOS;
  }

  protected cambiar(opcion: OpcionCatalogo, clave: Clave, valor: boolean) {
    const previo = this.permiso(opcion.idOpcion);
    let nuevo: Permisos = { ...previo, [clave]: valor };
    if (clave === 'puedeConsultar' && !valor) {
      nuevo = SIN_PERMISOS;
    } else if (valor) {
      nuevo.puedeConsultar = true;
    }
    this.guardarLocal(opcion.idOpcion, nuevo);

    const peticion: Observable<unknown> = Object.values(nuevo).some(Boolean)
      ? this.servicio.asignarPermiso(
          this.rol.idRol,
          opcion.idOpcion,
          Object.fromEntries(CLAVES.map((c) => [c, nuevo[c] ? 'S' : 'N'])),
        )
      : this.servicio.quitarPermiso(this.rol.idRol, opcion.idOpcion);
    this.pendientes.update((n) => n + 1);
    peticion.pipe(finalize(() => this.pendientes.update((n) => n - 1))).subscribe({
      next: () => this.guardadoAlguna.set(true),
      error: (error) => {
        this.guardarLocal(opcion.idOpcion, previo);
        this.notificacion.error(error);
      },
    });
  }

  private guardarLocal(idOpcion: number, permisos: Permisos) {
    this.permisos.update((mapa) => new Map(mapa).set(idOpcion, permisos));
  }
}
