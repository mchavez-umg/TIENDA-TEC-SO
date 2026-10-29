import { CurrencyPipe, DecimalPipe } from '@angular/common';
import { Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { Columna } from '../crud/crud';

export interface DatosDocumento {
  titulo: string;
  cabecera: { etiqueta: string; valor: string; completo?: boolean }[];
  columnas: Columna[];
  lineas: Record<string, unknown>[];
  total?: number;
}

@Component({
  selector: 'app-documento-detalle',
  imports: [CurrencyPipe, DecimalPipe, MatDialogModule, MatButtonModule],
  template: `
    <h2 mat-dialog-title>{{ datos.titulo }}</h2>
    <mat-dialog-content>
      <dl class="cabecera">
        @for (dato of datos.cabecera; track dato.etiqueta) {
          <div [class.completo]="dato.completo">
            <dt>{{ dato.etiqueta }}</dt>
            <dd>{{ dato.valor || '—' }}</dd>
          </div>
        }
      </dl>
      @if (datos.columnas.length) {
      <table class="detalle">
        <thead>
          <tr>
            @for (columna of datos.columnas; track columna.campo) {
              <th scope="col" [class.num]="columna.tipo === 'moneda' || columna.tipo === 'numero'">
                {{ columna.titulo }}
              </th>
            }
          </tr>
        </thead>
        <tbody>
          @for (linea of datos.lineas; track $index) {
            <tr>
              @for (columna of datos.columnas; track columna.campo) {
                @switch (columna.tipo) {
                  @case ('moneda') {
                    <td class="num">{{ $any(linea[columna.campo]) | currency: 'GTQ' : 'symbol-narrow' }}</td>
                  }
                  @case ('numero') {
                    <td class="num">{{ $any(linea[columna.campo]) | number }}</td>
                  }
                  @default {
                    <td>{{ linea[columna.campo] }}</td>
                  }
                }
              }
            </tr>
          }
        </tbody>
      </table>
      }
      @if (datos.total != null) {
        <p class="total">
          <span>Total</span>
          <strong>{{ datos.total | currency: 'GTQ' : 'symbol-narrow' }}</strong>
        </p>
      }
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-flat-button mat-dialog-close>Cerrar</button>
    </mat-dialog-actions>
  `,
  styles: `
    .cabecera {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 12px 24px;
      margin: 0 0 20px;
    }
    .cabecera .completo {
      grid-column: 1 / -1;
    }
    dt {
      color: var(--app-texto-sec);
      font-size: 13px;
    }
    dd {
      margin: 2px 0 0;
      color: var(--app-texto);
    }
    .detalle {
      width: 100%;
      border-collapse: collapse;
    }
    th,
    td {
      padding: 8px;
      border-bottom: 1px solid var(--app-regla);
      text-align: left;
    }
    th {
      border-bottom-color: var(--app-borde);
      color: var(--app-texto-sec);
      font-size: 13px;
      font-weight: 500;
    }
    .num {
      text-align: right;
      white-space: nowrap;
      font-variant-numeric: tabular-nums;
    }
    .total {
      display: flex;
      justify-content: flex-end;
      gap: 24px;
      margin: 12px 8px 0;
      font-size: 18px;
      font-weight: 600;
      font-variant-numeric: tabular-nums;
    }
    @media (max-width: 600px) {
      .cabecera {
        grid-template-columns: minmax(0, 1fr);
      }
    }
  `,
})
export class DocumentoDetalle {
  protected readonly datos = inject<DatosDocumento>(MAT_DIALOG_DATA);
}
