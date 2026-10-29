import { Component, computed, effect, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTooltipModule } from '@angular/material/tooltip';
import { Router, RouterLink } from '@angular/router';
import { finalize, map } from 'rxjs';
import { Producto } from '../../data/models/productos';
import { SucursalService } from '../../data/services/geografia.service';
import { InventarioService } from '../../data/services/inventario.service';
import { TrasladoService } from '../../data/services/movimientos.service';
import { ProductoService } from '../../data/services/productos.service';
import { BuscadorProducto } from '../../shared/buscador-producto/buscador-producto';
import { activos } from '../../shared/crud/crud';
import { Notificacion } from '../../shared/notificacion.service';

interface LineaTraslado {
  idProducto: number;
  codigo: string;
  nombre: string;
  cantidad: number;
}

@Component({
  selector: 'app-nuevo-traslado',
  imports: [
    RouterLink,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
    MatIconModule,
    MatTooltipModule,
    BuscadorProducto,
  ],
  templateUrl: './nuevo-traslado.html',
})
export class NuevoTraslado {
  private readonly servicio = inject(TrasladoService);
  private readonly inventario = inject(InventarioService);
  private readonly router = inject(Router);
  private readonly notificacion = inject(Notificacion);

  protected readonly sucursales = toSignal(inject(SucursalService).listar().pipe(map(activos)), {
    initialValue: [],
  });
  protected readonly productos = toSignal(inject(ProductoService).listar().pipe(map(activos)), {
    initialValue: [],
  });

  protected readonly idOrigen = signal<number | null>(null);
  protected readonly idDestino = signal<number | null>(null);
  protected readonly observacion = signal('');
  protected readonly existencias = signal<Map<number, number> | null>(null);
  protected readonly lineas = signal<LineaTraslado[]>([]);
  protected readonly guardando = signal(false);

  protected readonly unidades = computed(() => this.lineas().reduce((suma, l) => suma + l.cantidad, 0));
  protected readonly motivo = computed(() => {
    if (!this.idOrigen()) return 'Seleccione la sucursal de origen.';
    if (!this.idDestino()) return 'Seleccione la sucursal de destino.';
    if (this.idOrigen() === this.idDestino()) return 'El origen y el destino deben ser distintos.';
    if (!this.lineas().length) return 'Agregue al menos un producto.';
    if (this.lineas().some((l) => this.errorLinea(l))) return 'Corrija las líneas marcadas.';
    return null;
  });

  constructor() {
    effect(() => {
      const idOrigen = this.idOrigen();
      this.existencias.set(null);
      if (!idOrigen) return;
      this.inventario.existencias(idOrigen).subscribe({
        next: (filas) => this.existencias.set(new Map(filas.map((f) => [f.idProducto, f.existencia]))),
        error: (error) => this.notificacion.error(error),
      });
    });
  }

  protected disponible(idProducto: number) {
    return this.existencias()?.get(idProducto) ?? 0;
  }

  protected errorLinea(linea: LineaTraslado) {
    if (!Number.isInteger(linea.cantidad) || linea.cantidad < 1) return 'Cantidad no válida';
    const disponible = this.disponible(linea.idProducto);
    if (linea.cantidad > disponible) return `Solo hay ${disponible} disponibles en el origen`;
    return null;
  }

  protected agregar(producto: Producto) {
    this.lineas.update((lineas) =>
      lineas.some((l) => l.idProducto === producto.idProducto)
        ? lineas.map((l) => (l.idProducto === producto.idProducto ? { ...l, cantidad: l.cantidad + 1 } : l))
        : [...lineas, { idProducto: producto.idProducto, codigo: producto.codigo, nombre: producto.nombre, cantidad: 1 }],
    );
  }

  protected actualizar(indice: number, valor: string) {
    const numero = valor === '' ? 0 : Number(valor);
    this.lineas.update((lineas) =>
      lineas.map((l, i) => (i === indice ? { ...l, cantidad: Number.isFinite(numero) ? numero : 0 } : l)),
    );
  }

  protected quitar(indice: number) {
    this.lineas.update((lineas) => lineas.filter((_, i) => i !== indice));
  }

  protected guardar() {
    const idSucursalOrigen = this.idOrigen();
    const idSucursalDestino = this.idDestino();
    if (this.motivo() || !idSucursalOrigen || !idSucursalDestino) return;
    this.guardando.set(true);
    this.servicio
      .registrar({
        idSucursalOrigen,
        idSucursalDestino,
        observacion: this.observacion().trim() || null,
        lineas: this.lineas().map((l) => ({ idProducto: l.idProducto, cantidad: l.cantidad })),
      })
      .pipe(finalize(() => this.guardando.set(false)))
      .subscribe({
        next: () => {
          this.notificacion.exito('Traslado enviado. Quedará en tránsito hasta que el destino lo reciba.');
          this.router.navigateByUrl('/inventario/traslados');
        },
        error: (error) => this.notificacion.error(error),
      });
  }
}
