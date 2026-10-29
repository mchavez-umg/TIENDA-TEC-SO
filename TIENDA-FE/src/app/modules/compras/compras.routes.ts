import { Routes } from '@angular/router';
import { Compras, Proveedores } from './compras';
import { NuevaCompra } from './nueva-compra';

export const COMPRAS_ROUTES: Routes = [
  { path: 'proveedores', component: Proveedores },
  { path: 'compras', component: Compras },
  { path: 'compras/nueva', component: NuevaCompra },
];
