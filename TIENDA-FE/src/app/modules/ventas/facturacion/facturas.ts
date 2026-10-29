import { CurrencyPipe, DatePipe } from '@angular/common';
import { AfterViewInit, Component, computed, inject, signal, viewChild } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
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
import { RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { MenuService } from '../../../core/menu.service';
import { FacturaResumen } from '../../../data/models/ventas';
import { SucursalService } from '../../../data/services/geografia.service';
import { FacturaService } from '../../../data/services/ventas.service';
import { Notificacion } from '../../../shared/notificacion.service';
import { centavos } from './calculos';
import { FacturaDetalle } from './factura-detalle';

export const fechaLocal = (fecha: Date) => fecha.toLocaleDateString('en-CA');

@Component({
  selector: 'app-facturas',
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
    MatSelectModule,
    MatButtonModule,
    MatIconModule,
    MatTooltipModule,
    MatProgressBarModule,
  ],
  templateUrl: './facturas.html',
})
export class Facturas implements AfterViewInit {
  private readonly servicio = inject(FacturaService);
  private readonly dialog = inject(MatDialog);
  private readonly notificacion = inject(Notificacion);
  private readonly menu = inject(MenuService);
  private readonly sort = viewChild.required(MatSort);
  private readonly paginador = viewChild.required(MatPaginator);

  protected readonly puedeCrear = computed(() => !!this.menu.opcion('/ventas/facturas')?.puedeCrear);
  protected readonly sucursales = toSignal(inject(SucursalService).listar(), { initialValue: [] });
  protected readonly columnas = ['documento', 'fecha', 'sucursal', 'cliente', 'total', 'estado', 'acciones'];

  protected readonly desde = signal(fechaLocal(new Date(new Date().getFullYear(), new Date().getMonth(), 1)));
  protected readonly hasta = signal(fechaLocal(new Date()));
  protected readonly idSucursal = signal<number | null>(null);

  protected readonly datos = new MatTableDataSource<FacturaResumen>([]);
  protected readonly facturas = signal<FacturaResumen[]>([]);
  protected readonly cargando = signal(false);
  protected readonly fallo = signal(false);
  protected readonly vendido = computed(
    () => this.facturas().reduce((suma, f) => suma + centavos(f.total), 0) / 100,
  );

  constructor() {
    this.datos.sortingDataAccessor = (fila, columna) =>
      columna === 'documento' ? fila.idFactura : (fila as never)[columna];
    this.cargar();
  }

  ngAfterViewInit() {
    this.datos.sort = this.sort();
    this.datos.paginator = this.paginador();
  }

  protected cambiar(filtro: 'desde' | 'hasta', valor: string) {
    this[filtro].set(valor);
    this.cargar();
  }

  protected cambiarSucursal(valor: number | null) {
    this.idSucursal.set(valor);
    this.cargar();
  }

  protected ver(factura: FacturaResumen) {
    this.dialog.open(FacturaDetalle, { data: { idFactura: factura.idFactura }, width: '760px' });
  }

  protected cargar() {
    this.cargando.set(true);
    this.fallo.set(false);
    this.servicio
      .listar({ desde: this.desde(), hasta: this.hasta(), idSucursal: this.idSucursal() })
      .pipe(finalize(() => this.cargando.set(false)))
      .subscribe({
        next: (facturas) => {
          this.facturas.set(facturas);
          this.datos.data = facturas;
        },
        error: (error) => {
          this.fallo.set(true);
          this.notificacion.error(error);
        },
      });
  }
}
