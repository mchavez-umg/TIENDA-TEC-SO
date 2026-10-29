import { CurrencyPipe, DatePipe } from '@angular/common';
import { Component, computed, inject, output, signal } from '@angular/core';
import { MatAutocompleteModule } from '@angular/material/autocomplete';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { FacturaDetalle, FacturaResumen } from '../../data/models/ventas';
import { FacturaService } from '../../data/services/ventas.service';
import { Notificacion } from '../notificacion.service';

@Component({
  selector: 'app-selector-factura',
  imports: [CurrencyPipe, DatePipe, MatFormFieldModule, MatInputModule, MatAutocompleteModule, MatIconModule],
  template: `
    <mat-form-field class="campo-completo">
      <mat-label>Factura (número, NIT o cliente)</mat-label>
      <mat-icon matPrefix>receipt_long</mat-icon>
      <input #entrada matInput [matAutocomplete]="auto" (input)="busqueda.set(entrada.value)" />
      <mat-hint>Ej.: SUC-01-12</mat-hint>
      <mat-autocomplete #auto="matAutocomplete" [displayWith]="texto" (optionSelected)="elegir($event.option.value)">
        @for (f of filtradas(); track f.idFactura) {
          <mat-option [value]="f">
            <span class="opcion">
              <span>{{ f.serie }}-{{ f.numero }} · {{ f.cliente }}</span>
              <span class="meta">
                {{ f.fecha | date: 'dd/MM/yyyy' }} · NIT {{ f.nit }} ·
                {{ f.total | currency: 'GTQ' : 'symbol-narrow' }}
              </span>
            </span>
          </mat-option>
        } @empty {
          @if (busqueda().trim()) {
            <mat-option disabled>Ninguna factura coincide</mat-option>
          }
        }
      </mat-autocomplete>
    </mat-form-field>
  `,
  styles: `
    :host {
      display: block;
      padding-top: 8px;
    }
    .opcion {
      display: flex;
      flex-direction: column;
      line-height: 1.3;
    }
    .meta {
      color: var(--app-texto-sec);
      font-size: 12px;
    }
  `,
})
export class SelectorFactura {
  private readonly servicio = inject(FacturaService);
  private readonly notificacion = inject(Notificacion);

  readonly elegida = output<FacturaDetalle>();

  protected readonly facturas = signal<FacturaResumen[]>([]);
  protected readonly busqueda = signal('');
  protected readonly filtradas = computed(() => {
    const texto = this.busqueda().trim().toLowerCase();
    if (!texto) return this.facturas().slice(0, 8);
    return this.facturas()
      .filter((f) => `${f.serie}-${f.numero} ${f.nit} ${f.cliente}`.toLowerCase().includes(texto))
      .slice(0, 8);
  });

  constructor() {
    this.servicio.listar({}).subscribe({
      next: (facturas) => this.facturas.set(facturas),
      error: (error) => this.notificacion.error(error),
    });
  }

  protected texto(factura: FacturaResumen | null) {
    return factura ? `${factura.serie}-${factura.numero} · ${factura.cliente}` : '';
  }

  protected elegir(factura: FacturaResumen) {
    this.servicio.obtener(factura.idFactura).subscribe({
      next: (detalle) => this.elegida.emit(detalle),
      error: (error) => this.notificacion.error(error),
    });
  }
}
