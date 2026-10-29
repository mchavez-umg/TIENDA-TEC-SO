import { CurrencyPipe } from '@angular/common';
import { Component, computed, input, output, signal } from '@angular/core';
import { MatAutocompleteModule } from '@angular/material/autocomplete';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { Producto } from '../../data/models/productos';

@Component({
  selector: 'app-buscador-producto',
  imports: [CurrencyPipe, MatFormFieldModule, MatInputModule, MatAutocompleteModule, MatIconModule],
  template: `
    <mat-form-field class="campo-completo">
      <mat-label>Agregar producto por código o nombre</mat-label>
      <mat-icon matPrefix>search</mat-icon>
      <input
        #entrada
        matInput
        [matAutocomplete]="auto"
        [disabled]="!!pista()"
        (input)="busqueda.set(entrada.value)"
      />
      @if (pista()) {
        <mat-hint>{{ pista() }}</mat-hint>
      }
      <mat-autocomplete #auto="matAutocomplete" (optionSelected)="elegir($event.option.value, entrada)">
        @for (p of filtrados(); track p.idProducto) {
          <mat-option [value]="p">
            <span class="opcion">
              <span>{{ p.codigo }} · {{ p.nombre }}</span>
              <span class="meta">
                {{ (mostrarCosto() ? p.precioCosto : p.precioVenta) | currency: 'GTQ' : 'symbol-narrow' }}
                @if (existencias(); as mapa) {
                  ·
                  <span [class.sin-stock]="!mapa.get(p.idProducto)">
                    {{ mapa.get(p.idProducto) ?? 0 }} disponibles
                  </span>
                }
              </span>
            </span>
          </mat-option>
        } @empty {
          @if (busqueda().trim()) {
            <mat-option disabled>Ningún producto coincide</mat-option>
          }
        }
      </mat-autocomplete>
    </mat-form-field>
  `,
  styles: `
    .opcion {
      display: flex;
      flex-direction: column;
      line-height: 1.3;
    }
    .meta {
      color: var(--app-texto-sec);
      font-size: 12px;
    }
    .sin-stock {
      color: var(--app-error);
    }
  `,
})
export class BuscadorProducto {
  readonly productos = input.required<Producto[]>();
  readonly existencias = input<Map<number, number> | null>(null);
  readonly mostrarCosto = input(false);
  readonly pista = input<string | null>(null);
  readonly elegido = output<Producto>();

  protected readonly busqueda = signal('');
  protected readonly filtrados = computed(() => {
    const texto = this.busqueda().trim().toLowerCase();
    if (!texto) return [];
    return this.productos()
      .filter((p) => `${p.codigo} ${p.nombre}`.toLowerCase().includes(texto))
      .slice(0, 8);
  });

  protected elegir(producto: Producto, entrada: HTMLInputElement) {
    this.elegido.emit(producto);
    entrada.value = '';
    this.busqueda.set('');
  }
}
