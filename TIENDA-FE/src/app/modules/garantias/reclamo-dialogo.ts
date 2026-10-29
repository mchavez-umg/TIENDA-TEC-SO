import { DatePipe } from '@angular/common';
import { Component, computed, inject, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatRadioModule } from '@angular/material/radio';
import { finalize } from 'rxjs';
import { FacturaDetalle, LineaFactura } from '../../data/models/ventas';
import { GarantiaService } from '../../data/services/postventa.service';
import { Notificacion } from '../../shared/notificacion.service';
import { SelectorFactura } from '../../shared/selector-factura/selector-factura';

export function motivoNoReclamable(linea: LineaFactura) {
  if (linea.pendienteNc === 0) return 'Devuelto con nota de crédito';
  if (!linea.garantiaVigente) return 'Garantía vencida';
  return null;
}

@Component({
  selector: 'app-reclamo-dialogo',
  imports: [
    DatePipe,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatRadioModule,
    MatButtonModule,
    SelectorFactura,
  ],
  template: `
    <h2 mat-dialog-title>Nuevo reclamo de garantía</h2>
    <mat-dialog-content>
      <app-selector-factura (elegida)="factura.set($event); idDetalle.set(null)" />

      @if (factura(); as f) {
        <p class="instruccion" id="producto-reclamo">Producto con falla</p>
        <mat-radio-group
          class="productos"
          aria-labelledby="producto-reclamo"
          [value]="idDetalle()"
          (change)="idDetalle.set($event.value)"
        >
          @for (linea of f.lineas; track linea.idDetalleFactura) {
            <mat-radio-button [value]="linea.idDetalleFactura" [disabled]="!!noReclamable(linea)">
              <span class="producto">{{ linea.producto }}</span>
              <small [class.no-disponible]="noReclamable(linea)">
                @if (noReclamable(linea); as razon) {
                  {{ razon }} ·
                }
                Garantía hasta {{ linea.finGarantia | date: 'dd/MM/yyyy' }}
              </small>
            </mat-radio-button>
          }
        </mat-radio-group>

        <mat-form-field class="campo-completo">
          <mat-label>Descripción de la falla</mat-label>
          <textarea
            #falla
            matInput
            rows="3"
            maxlength="300"
            required
            [value]="descripcion()"
            (input)="descripcion.set(falla.value)"
          ></textarea>
        </mat-form-field>
      }
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close [disabled]="guardando()">Cancelar</button>
      <button mat-flat-button [disabled]="!valido() || guardando()" (click)="registrar()">
        {{ guardando() ? 'Registrando…' : 'Registrar reclamo' }}
      </button>
    </mat-dialog-actions>
  `,
  styles: `
    .instruccion {
      margin: 16px 0 8px;
      font-weight: 500;
    }
    .productos {
      display: flex;
      flex-direction: column;
      gap: 4px;
      margin-bottom: 16px;
    }
    .producto {
      display: block;
    }
    small {
      color: var(--app-texto-sec);
      font-size: 12px;
    }
    .no-disponible {
      color: var(--app-error);
    }
  `,
})
export class ReclamoDialogo {
  private readonly servicio = inject(GarantiaService);
  private readonly ref = inject(MatDialogRef<ReclamoDialogo>);
  private readonly notificacion = inject(Notificacion);

  protected readonly factura = signal<FacturaDetalle | null>(null);
  protected readonly idDetalle = signal<number | null>(null);
  protected readonly descripcion = signal('');
  protected readonly guardando = signal(false);
  protected readonly noReclamable = motivoNoReclamable;
  protected readonly valido = computed(() => !!this.idDetalle() && !!this.descripcion().trim());

  protected registrar() {
    const idDetalle = this.idDetalle();
    if (!this.valido() || !idDetalle) return;
    this.guardando.set(true);
    this.servicio
      .registrar(idDetalle, this.descripcion().trim())
      .pipe(finalize(() => this.guardando.set(false)))
      .subscribe({
        next: () => {
          this.notificacion.exito('Reclamo registrado');
          this.ref.close(true);
        },
        error: (error) => this.notificacion.error(error),
      });
  }
}
