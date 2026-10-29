import { CurrencyPipe, DatePipe } from '@angular/common';
import { Component, computed, inject, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { Router, RouterLink } from '@angular/router';
import { finalize } from 'rxjs';
import { FacturaDetalle, LineaFactura } from '../../../data/models/ventas';
import { NotaCreditoService } from '../../../data/services/postventa.service';
import { Notificacion } from '../../../shared/notificacion.service';
import { SelectorFactura } from '../../../shared/selector-factura/selector-factura';
import { centavos } from '../facturacion/calculos';

interface Devolucion {
  linea: LineaFactura;
  cantidad: number;
  reingresa: boolean;
}

export function montoEstimado(linea: LineaFactura, cantidad: number) {
  return Math.round((centavos(linea.subtotal) * cantidad) / linea.cantidad) / 100;
}

@Component({
  selector: 'app-nueva-nota',
  imports: [
    CurrencyPipe,
    DatePipe,
    RouterLink,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatCheckboxModule,
    MatButtonModule,
    MatIconModule,
    SelectorFactura,
  ],
  templateUrl: './nueva-nota.html',
})
export class NuevaNota {
  private readonly servicio = inject(NotaCreditoService);
  private readonly router = inject(Router);
  private readonly notificacion = inject(Notificacion);

  protected readonly factura = signal<FacturaDetalle | null>(null);
  protected readonly devoluciones = signal<Devolucion[]>([]);
  protected readonly motivoTexto = signal('');
  protected readonly guardando = signal(false);

  protected readonly montoEstimado = montoEstimado;
  protected readonly sinPendientes = computed(
    () => !!this.factura() && this.devoluciones().every((d) => d.linea.pendienteNc === 0),
  );
  protected readonly total = computed(
    () =>
      this.devoluciones().reduce((suma, d) => suma + centavos(montoEstimado(d.linea, d.cantidad)), 0) / 100,
  );
  protected readonly motivo = computed(() => {
    if (!this.factura()) return 'Seleccione la factura.';
    if (this.sinPendientes()) return 'Esta factura ya fue devuelta por completo.';
    if (this.devoluciones().some((d) => this.error(d))) return 'Corrija las cantidades marcadas.';
    if (!this.devoluciones().some((d) => d.cantidad > 0)) return 'Indique al menos una unidad a devolver.';
    if (!this.motivoTexto().trim()) return 'Escriba el motivo de la devolución.';
    return null;
  });

  protected elegir(factura: FacturaDetalle) {
    this.factura.set(factura);
    this.devoluciones.set(factura.lineas.map((linea) => ({ linea, cantidad: 0, reingresa: true })));
  }

  protected error(devolucion: Devolucion) {
    const { cantidad, linea } = devolucion;
    if (!Number.isInteger(cantidad) || cantidad < 0) return 'Cantidad no válida';
    if (cantidad > linea.pendienteNc) return `Solo quedan ${linea.pendienteNc} por devolver`;
    return null;
  }

  protected actualizar(indice: number, cambios: Partial<Devolucion>) {
    this.devoluciones.update((lista) => lista.map((d, i) => (i === indice ? { ...d, ...cambios } : d)));
  }

  protected guardar() {
    const factura = this.factura();
    if (this.motivo() || !factura) return;
    this.guardando.set(true);
    this.servicio
      .registrar({
        idFactura: factura.factura.idFactura,
        motivo: this.motivoTexto().trim(),
        lineas: this.devoluciones()
          .filter((d) => d.cantidad > 0)
          .map((d) => ({
            idDetalleFactura: d.linea.idDetalleFactura,
            cantidad: d.cantidad,
            reingresaInventario: d.reingresa ? 'S' : 'N',
          })),
      })
      .pipe(finalize(() => this.guardando.set(false)))
      .subscribe({
        next: (nota) => {
          this.notificacion.exito(
            `Nota de crédito ${nota.notaCredito.serie}-${nota.notaCredito.numero} emitida`,
          );
          this.router.navigateByUrl('/ventas/notas-credito');
        },
        error: (error) => this.notificacion.error(error),
      });
  }
}
