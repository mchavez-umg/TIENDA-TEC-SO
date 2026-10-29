import { CurrencyPipe, DatePipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { FacturaDetalle as Detalle } from '../../../data/models/ventas';
import { FacturaService } from '../../../data/services/ventas.service';
import { mensajeError } from '../../../shared/notificacion.service';

export interface DatosFacturaDetalle {
  idFactura: number;
  recienEmitida?: boolean;
}

@Component({
  selector: 'app-factura-detalle',
  imports: [CurrencyPipe, DatePipe, MatDialogModule, MatButtonModule, MatProgressBarModule],
  templateUrl: './factura-detalle.html',
  styleUrl: './factura-detalle.scss',
})
export class FacturaDetalle {
  protected readonly datos = inject<DatosFacturaDetalle>(MAT_DIALOG_DATA);
  protected readonly detalle = signal<Detalle | null>(null);
  protected readonly error = signal<string | null>(null);

  constructor() {
    inject(FacturaService)
      .obtener(this.datos.idFactura)
      .subscribe({
        next: (detalle) => this.detalle.set(detalle),
        error: (error) => this.error.set(mensajeError(error)),
      });
  }
}
