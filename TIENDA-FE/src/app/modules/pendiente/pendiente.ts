import { Component } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-pendiente',
  imports: [MatCardModule, MatIconModule],
  template: `
    <mat-card appearance="outlined" class="aviso">
      <mat-icon>construction</mat-icon>
      <h1>Módulo en construcción</h1>
      <p>Esta pantalla estará disponible próximamente.</p>
    </mat-card>
  `,
  styles: `
    .aviso {
      align-items: center;
      padding: 48px 24px;
      background: #fff;
      color: var(--app-texto-sec);
      text-align: center;
    }
    mat-icon {
      font-size: 40px;
      width: 40px;
      height: 40px;
    }
    h1 {
      margin: 12px 0 4px;
      color: var(--app-texto);
      font-size: 18px;
      font-weight: 500;
    }
    p {
      margin: 0;
    }
  `,
})
export class Pendiente {}
