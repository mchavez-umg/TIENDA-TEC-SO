import { Routes } from '@angular/router';
import { Existencias, Kardex } from './consultas';
import { Traslados } from './inventario';
import { NuevoTraslado } from './nuevo-traslado';

export const INVENTARIO_ROUTES: Routes = [
  { path: 'existencias', component: Existencias },
  { path: 'kardex', component: Kardex },
  { path: 'traslados', component: Traslados },
  { path: 'traslados/nuevo', component: NuevoTraslado },
];
