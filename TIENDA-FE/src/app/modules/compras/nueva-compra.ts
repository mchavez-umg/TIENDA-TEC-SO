import { CurrencyPipe } from '@angular/common';
import { Component, computed, inject, signal } from '@angular/core';
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
import { ProveedorService } from '../../data/services/comercial.service';
import { SucursalService } from '../../data/services/geografia.service';
import { CompraService } from '../../data/services/movimientos.service';
import { ProductoService } from '../../data/services/productos.service';
import { BuscadorProducto } from '../../shared/buscador-producto/buscador-producto';
import { activos } from '../../shared/crud/crud';
import { Notificacion } from '../../shared/notificacion.service';
import { centavos } from '../ventas/facturacion/calculos';

interface LineaCompra {
  idProducto: number;
  codigo: string;
  nombre: string;
  cantidad: number;
  costo: number;
}

export function errorLineaCompra(linea: LineaCompra) {
  if (!Number.isInteger(linea.cantidad) || linea.cantidad < 1) return 'Cantidad no válida';
  if (!(linea.costo >= 0)) return 'Costo no válido';
  return null;
}

@Component({
  selector: 'app-nueva-compra',
  imports: [
    CurrencyPipe,
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
  templateUrl: './nueva-compra.html',
})
export class NuevaCompra {
  private readonly servicio = inject(CompraService);
  private readonly router = inject(Router);
  private readonly notificacion = inject(Notificacion);

  protected readonly proveedores = toSignal(inject(ProveedorService).listar().pipe(map(activos)), {
    initialValue: [],
  });
  protected readonly sucursales = toSignal(inject(SucursalService).listar().pipe(map(activos)), {
    initialValue: [],
  });
  protected readonly productos = toSignal(inject(ProductoService).listar().pipe(map(activos)), {
    initialValue: [],
  });

  protected readonly idProveedor = signal<number | null>(null);
  protected readonly idSucursal = signal<number | null>(null);
  protected readonly noDocumento = signal('');
  protected readonly lineas = signal<LineaCompra[]>([]);
  protected readonly guardando = signal(false);

  protected readonly total = computed(
    () => this.lineas().reduce((suma, l) => suma + centavos(l.costo) * l.cantidad, 0) / 100,
  );
  protected readonly motivo = computed(() => {
    if (!this.idProveedor()) return 'Seleccione el proveedor.';
    if (!this.idSucursal()) return 'Seleccione la sucursal que recibe.';
    if (!this.noDocumento().trim()) return 'Ingrese el número de documento del proveedor.';
    if (!this.lineas().length) return 'Agregue al menos un producto.';
    if (this.lineas().some((l) => errorLineaCompra(l))) return 'Corrija las líneas marcadas.';
    return null;
  });

  protected readonly errorLinea = errorLineaCompra;
  protected readonly subtotal = (l: LineaCompra) => (centavos(l.costo) * l.cantidad) / 100;

  protected agregar(producto: Producto) {
    this.lineas.update((lineas) =>
      lineas.some((l) => l.idProducto === producto.idProducto)
        ? lineas.map((l) => (l.idProducto === producto.idProducto ? { ...l, cantidad: l.cantidad + 1 } : l))
        : [
            ...lineas,
            {
              idProducto: producto.idProducto,
              codigo: producto.codigo,
              nombre: producto.nombre,
              cantidad: 1,
              costo: producto.precioCosto,
            },
          ],
    );
  }

  protected actualizar(indice: number, campo: 'cantidad' | 'costo', valor: string) {
    const numero = valor === '' ? 0 : Number(valor);
    this.lineas.update((lineas) =>
      lineas.map((l, i) => (i === indice ? { ...l, [campo]: Number.isFinite(numero) ? numero : 0 } : l)),
    );
  }

  protected quitar(indice: number) {
    this.lineas.update((lineas) => lineas.filter((_, i) => i !== indice));
  }

  protected guardar() {
    const idProveedor = this.idProveedor();
    const idSucursal = this.idSucursal();
    if (this.motivo() || !idProveedor || !idSucursal) return;
    this.guardando.set(true);
    this.servicio
      .registrar({
        idProveedor,
        idSucursal,
        noDocumento: this.noDocumento().trim(),
        lineas: this.lineas().map((l) => ({
          idProducto: l.idProducto,
          cantidad: l.cantidad,
          costoUnitario: l.costo,
        })),
      })
      .pipe(finalize(() => this.guardando.set(false)))
      .subscribe({
        next: () => {
          this.notificacion.exito('Compra registrada como pendiente. Recíbala cuando llegue la mercadería.');
          this.router.navigateByUrl('/compras/compras');
        },
        error: (error) => this.notificacion.error(error),
      });
  }
}
