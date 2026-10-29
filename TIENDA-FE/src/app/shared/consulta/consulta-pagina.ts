import { CurrencyPipe, DatePipe, DecimalPipe } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { AfterViewInit, Component, computed, inject, input, OnInit, signal, viewChild } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatDialog } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatPaginator, MatPaginatorModule } from '@angular/material/paginator';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatSelectModule } from '@angular/material/select';
import { MatSort, MatSortModule } from '@angular/material/sort';
import { MatTableDataSource, MatTableModule } from '@angular/material/table';
import { MatTooltipModule } from '@angular/material/tooltip';
import { finalize, map } from 'rxjs';
import { API_URL } from '../../core/api';
import { Sucursal } from '../../data/models/geografia';
import { Producto } from '../../data/models/productos';
import { SucursalService } from '../../data/services/geografia.service';
import { ProductoService } from '../../data/services/productos.service';
import { activos, Columna } from '../crud/crud';
import { DocumentoDetalle } from '../documento-detalle/documento-detalle';
import { Notificacion } from '../notificacion.service';
import { aCsv, ConsultaConfig, parametros, valoresIniciales } from './consulta';

type Fila = Record<string, any>;

@Component({
  selector: 'app-consulta-pagina',
  imports: [
    CurrencyPipe,
    DatePipe,
    DecimalPipe,
    MatCardModule,
    MatTableModule,
    MatSortModule,
    MatPaginatorModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatCheckboxModule,
    MatButtonModule,
    MatIconModule,
    MatTooltipModule,
    MatProgressBarModule,
  ],
  templateUrl: './consulta-pagina.html',
})
export class ConsultaPagina implements OnInit, AfterViewInit {
  readonly config = input.required<ConsultaConfig<any>>();

  private readonly http = inject(HttpClient);
  private readonly dialog = inject(MatDialog);
  private readonly notificacion = inject(Notificacion);
  private readonly sort = viewChild.required(MatSort);
  private readonly paginador = viewChild.required(MatPaginator);
  private readonly sucursalServicio = inject(SucursalService);
  private readonly productoServicio = inject(ProductoService);

  protected readonly valores = signal<Record<string, unknown>>({});
  protected readonly busqueda = signal('');
  protected readonly filas = signal<Fila[]>([]);
  protected readonly cargando = signal(false);
  protected readonly fallo = signal(false);
  protected readonly datos = new MatTableDataSource<Fila>([]);

  protected readonly sucursales = signal<Sucursal[]>([]);
  protected readonly productos = signal<Producto[]>([]);

  protected readonly columnas = computed(() => [
    ...this.config().columnas.map((c) => c.campo),
    ...(this.config().detalle ? ['acciones'] : []),
  ]);
  protected readonly conTotales = computed(() => this.config().columnas.some((c) => c.total));
  protected readonly resumen = computed(() => {
    const propio = this.config().resumen;
    return propio ? propio(this.filas()) : `${this.filas().length} registros`;
  });
  private readonly maximos = computed(() => {
    const maximos: Record<string, number> = {};
    for (const columna of this.config().columnas.filter((c) => c.barra)) {
      maximos[columna.campo] = Math.max(0, ...this.filas().map((f) => Number(f[columna.campo]) || 0));
    }
    return maximos;
  });

  ngOnInit() {
    this.valores.set(valoresIniciales(this.config().filtros));
    if (this.usa('sucursal')) {
      this.sucursalServicio.listar().pipe(map(activos)).subscribe((s) => this.sucursales.set(s));
    }
    if (this.usa('producto')) {
      this.productoServicio.listar().pipe(map(activos)).subscribe((p) => this.productos.set(p));
    }
    this.cargar();
  }

  ngAfterViewInit() {
    this.datos.sort = this.sort();
    this.datos.paginator = this.paginador();
  }

  protected cambiar(nombre: string, valor: unknown) {
    this.valores.update((v) => ({ ...v, [nombre]: valor }));
    this.cargar();
  }

  protected filtrar(valor: string) {
    this.busqueda.set(valor);
    this.datos.filter = valor.trim().toLowerCase();
    this.datos.paginator?.firstPage();
  }

  protected total(columna: Columna) {
    const filas = this.busqueda() ? this.datos.filteredData : this.filas();
    return filas.reduce((suma, f) => suma + Math.round((Number(f[columna.campo]) || 0) * 100), 0) / 100;
  }

  protected barra(columna: Columna, fila: Fila) {
    const maximo = this.maximos()[columna.campo];
    return maximo > 0 ? ((Number(fila[columna.campo]) || 0) / maximo) * 100 : 0;
  }

  protected esNumero(columna: Columna) {
    return columna.tipo === 'moneda' || columna.tipo === 'numero';
  }

  protected ver(fila: Fila) {
    const detalle = this.config().detalle;
    if (detalle) {
      this.dialog.open(DocumentoDetalle, { width: '720px', data: detalle(fila) });
    }
  }

  protected exportar() {
    const filas = this.busqueda() ? this.datos.filteredData : this.filas();
    const archivo = new Blob([aCsv(this.config().columnas, filas)], { type: 'text/csv;charset=utf-8' });
    const enlace = document.createElement('a');
    enlace.href = URL.createObjectURL(archivo);
    enlace.download = `${this.config().titulo.toLowerCase().replace(/\s+/g, '-')}.csv`;
    enlace.click();
    URL.revokeObjectURL(enlace.href);
  }

  protected cargar() {
    this.cargando.set(true);
    this.fallo.set(false);
    this.http
      .get<Fila[]>(`${API_URL}/${this.config().endpoint}`, { params: parametros(this.valores()) })
      .pipe(finalize(() => this.cargando.set(false)))
      .subscribe({
        next: (filas) => {
          this.filas.set(filas);
          this.datos.data = filas;
        },
        error: (error) => {
          this.fallo.set(true);
          this.notificacion.error(error);
        },
      });
  }

  private usa(tipo: string) {
    return this.config().filtros.some((f) => f.tipo === tipo);
  }
}
