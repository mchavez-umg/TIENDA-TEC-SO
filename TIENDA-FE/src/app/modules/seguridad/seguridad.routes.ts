import { Routes } from '@angular/router';
import { OpcionesMenu, Roles, Usuarios } from './seguridad';

export const SEGURIDAD_ROUTES: Routes = [
  { path: 'usuarios', component: Usuarios },
  { path: 'roles', component: Roles },
  { path: 'menu', component: OpcionesMenu },
];
