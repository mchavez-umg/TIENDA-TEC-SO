import { CurrencyPipe, DatePipe } from '@angular/common';
import {
  AfterViewInit,
  Component,
  computed,
  inject,
  input,
  OnInit,
  signal,
  viewChild,
} from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDialog } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatPaginator, MatPaginatorModule } from '@angular/material/paginator';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatSort, MatSortModule } from '@angular/material/sort';
import { MatTableDataSource, MatTableModule } from '@angular/material/table';
import { MatTooltipModule } from '@angular/material/tooltip';
import { filter, finalize, switchMap } from 'rxjs';
import { MenuService } from '../../core/menu.service';
import { Confirmacion } from '../confirmacion/confirmacion';
import { anchoFormulario, FormularioDialogo } from '../formulario/formulario-dialogo';
import { Notificacion } from '../notificacion.service';
import { RouterLink } from '@angular/router';
import { Columna, CrudConfig, Permiso, TonoEstado } from './crud';

type Fila = Record<string, any>;

@Component({
  selector: 'app-crud-pagina',
  imports: [
    CurrencyPipe,
    DatePipe,
    RouterLink,
    MatCardModule,
    MatTableModule,
    MatSortModule,
    MatPaginatorModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatTooltipModule,
    MatProgressBarModule,
  ],
  templateUrl: './crud-pagina.html',
})
export class CrudPagina implements OnInit, AfterViewInit {
  readonly config = input.required<CrudConfig<any>>();

  private readonly menu = inject(MenuService);
  private readonly dialog = inject(MatDialog);
  private readonly notificacion = inject(Notificacion);
  private readonly confirmacion = inject(Confirmacion);
  private readonly sort = viewChild.required(MatSort);
  private readonly paginador = viewChild.required(MatPaginator);

  protected readonly permisos = computed(() => this.menu.opcion(this.config().ruta));
  protected readonly editable = computed(() => this.config().editable !== false);
  protected readonly desactivable = computed(() => this.config().desactivable !== false);
  protected readonly conAcciones = computed(
    () =>
      (this.editable() && this.puede('puedeEditar')) ||
      (this.desactivable() && this.puede('puedeEliminar')) ||
      (this.config().acciones ?? []).some((a) => this.puede(a.permiso)),
  );
  protected readonly columnas = computed(() => [
    ...this.config().columnas.map((c) => c.campo),
    ...(this.conAcciones() ? ['acciones'] : []),
  ]);
  protected readonly articulo = computed(() => (this.config().femenino ? 'a' : 'o'));
  private readonly nombre = computed(() => {
    const singular = this.config().singular;
    return singular[0].toUpperCase() + singular.slice(1);
  });
  protected readonly datos = new MatTableDataSource<Fila>([]);
  protected readonly cargando = signal(false);
  protected readonly fallo = signal(false);
  protected readonly busqueda = signal('');
  protected readonly filas = signal<Fila[]>([]);
  protected readonly resumen = computed(() => {
    const filas = this.filas();
    const propio = this.config().resumen;
    if (propio) {
      return propio(filas);
    }
    const activos = filas.filter((f) => f['estado'] === 'Activo').length;
    return `${filas.length} en total · ${activos} activ${this.articulo()}s`;
  });

  ngOnInit() {
    this.cargar();
  }

  ngAfterViewInit() {
    this.datos.sort = this.sort();
    this.datos.paginator = this.paginador();
  }

  protected puede(permiso: Permiso) {
    const permisos = this.permisos();
    return permiso === 'consultar' ? !!permisos : !!permisos?.[permiso];
  }

  protected tono(estado: string): TonoEstado {
    return this.config().tonoEstado?.(estado) ?? (estado === 'Activo' ? 'exito' : 'inactivo');
  }

  protected clase(columna: Columna) {
    const porTipo: Record<string, string> = {
      estado: 'col-estado',
      moneda: 'col-numero',
      numero: 'col-numero',
      fecha: 'col-fecha',
      fechaHora: 'col-fecha',
    };
    return [porTipo[columna.tipo ?? ''], columna.clase].filter(Boolean).join(' ');
  }

  protected etiqueta(fila: Fila): string {
    return this.config().etiqueta?.(fila) ?? fila['nombre'];
  }

  protected filtrar(valor: string) {
    this.busqueda.set(valor);
    this.datos.filter = valor.trim().toLowerCase();
    this.datos.paginator?.firstPage();
  }

  protected abrir(fila?: Fila) {
    const config = this.config();
    if (!fila && config.alCrear) {
      return config.alCrear(this.recargar);
    }
    const a = this.articulo();
    const nombre = this.nombre();
    this.dialog
      .open(FormularioDialogo, {
        width: anchoFormulario(config.campos),
        data: {
          titulo: fila ? `Editar ${config.singular}` : `Nuev${a} ${config.singular}`,
          campos: config.campos,
          valores: fila ?? null,
          guardar: (valores: Fila) =>
            fila ? config.servicio.actualizar(fila[config.id], valores) : config.servicio.crear(valores),
          mensajeExito: fila ? `${nombre} actualizad${a}` : `${nombre} cread${a}`,
        },
      })
      .afterClosed()
      .pipe(filter(Boolean))
      .subscribe(() => this.cargar());
  }

  protected desactivar(fila: Fila) {
    const config = this.config();
    this.confirmacion
      .preguntar({
        titulo: `Desactivar ${config.singular}`,
        mensaje: `¿Desea desactivar "${this.etiqueta(fila)}"? Dejará de aparecer en las listas de selección.`,
        accion: 'Desactivar',
        peligro: true,
      })
      .pipe(
        filter(Boolean),
        switchMap(() => config.servicio.desactivar(fila[config.id])),
      )
      .subscribe({
        next: () => {
          this.notificacion.exito(`${this.nombre()} desactivad${this.articulo()}`);
          this.cargar();
        },
        error: (error) => this.notificacion.error(error),
      });
  }

  protected activar(fila: Fila) {
    const config = this.config();
    this.confirmacion
      .preguntar({
        titulo: `Activar ${config.singular}`,
        mensaje: `¿Desea activar "${this.etiqueta(fila)}"? Volverá a aparecer en las listas de selección.`,
        accion: 'Activar',
      })
      .pipe(
        filter(Boolean),
        switchMap(() => config.servicio.activar(fila[config.id])),
      )
      .subscribe({
        next: () => {
          this.notificacion.exito(`${this.nombre()} activad${this.articulo()}`);
          this.cargar();
        },
        error: (error) => this.notificacion.error(error),
      });
  }

  protected readonly recargar = () => this.cargar();

  protected cargar() {
    this.cargando.set(true);
    this.fallo.set(false);
    this.config()
      .servicio.listar()
      .pipe(finalize(() => this.cargando.set(false)))
      .subscribe({
        next: (filas) => {
          this.filas.set(filas as Fila[]);
          this.datos.data = filas as Fila[];
        },
        error: (error) => {
          this.fallo.set(true);
          this.notificacion.error(error);
        },
      });
  }
}
