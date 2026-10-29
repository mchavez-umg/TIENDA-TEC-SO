import { Routes } from '@angular/router';
import { Departamentos, Municipios, Sucursales } from './geografia';

export const GEOGRAFIA_ROUTES: Routes = [
  { path: 'departamentos', component: Departamentos },
  { path: 'municipios', component: Municipios },
  { path: 'sucursales', component: Sucursales },
];
