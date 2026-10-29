import { Routes } from '@angular/router';
import { Categorias, Marcas, Productos } from './productos';

export const PRODUCTOS_ROUTES: Routes = [
  { path: 'marcas', component: Marcas },
  { path: 'categorias', component: Categorias },
  { path: 'productos', component: Productos },
];
