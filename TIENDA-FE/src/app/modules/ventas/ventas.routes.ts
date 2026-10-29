import { Routes } from '@angular/router';
import { Facturas } from './facturacion/facturas';
import { NuevaFactura } from './facturacion/nueva-factura';
import { NotasCredito } from './notas-credito/notas-credito';
import { NuevaNota } from './notas-credito/nueva-nota';
import { Bancos, FormasPago } from './ventas';

export const VENTAS_ROUTES: Routes = [
  { path: 'facturas', component: Facturas },
  { path: 'facturas/nueva', component: NuevaFactura },
  { path: 'notas-credito', component: NotasCredito },
  { path: 'notas-credito/nueva', component: NuevaNota },
  { path: 'bancos', component: Bancos },
  { path: 'formas-pago', component: FormasPago },
];
