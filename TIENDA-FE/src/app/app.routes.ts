import { Routes } from '@angular/router';
import { authGuard, invitadoGuard } from './core/auth.guard';

export const routes: Routes = [
  {
    path: 'login',
    canActivate: [invitadoGuard],
    loadComponent: () => import('./modules/auth/login/login').then((m) => m.Login),
  },
  {
    path: '',
    loadComponent: () => import('./layout/shell/shell').then((m) => m.Shell),
    canActivate: [authGuard],
    children: [
      { path: '', loadComponent: () => import('./modules/inicio/inicio').then((m) => m.Inicio) },
      {
        path: 'productos',
        loadChildren: () =>
          import('./modules/productos/productos.routes').then((m) => m.PRODUCTOS_ROUTES),
      },
      {
        path: 'geografia',
        loadChildren: () =>
          import('./modules/geografia/geografia.routes').then((m) => m.GEOGRAFIA_ROUTES),
      },
      {
        path: 'personal',
        loadChildren: () =>
          import('./modules/personal/personal.routes').then((m) => m.PERSONAL_ROUTES),
      },
      {
        path: 'ventas',
        loadChildren: () => import('./modules/ventas/ventas.routes').then((m) => m.VENTAS_ROUTES),
      },
      {
        path: 'compras',
        loadChildren: () => import('./modules/compras/compras.routes').then((m) => m.COMPRAS_ROUTES),
      },
      {
        path: 'reportes',
        loadChildren: () => import('./modules/reportes/reportes.routes').then((m) => m.REPORTES_ROUTES),
      },
      {
        path: 'bitacora',
        loadComponent: () => import('./modules/bitacora/bitacora').then((m) => m.Bitacora),
      },
      {
        path: 'garantias',
        loadComponent: () => import('./modules/garantias/garantias').then((m) => m.Garantias),
      },
      {
        path: 'inventario',
        loadChildren: () =>
          import('./modules/inventario/inventario.routes').then((m) => m.INVENTARIO_ROUTES),
      },
      {
        path: 'clientes',
        loadComponent: () => import('./modules/clientes/clientes').then((m) => m.Clientes),
      },
      {
        path: 'seguridad',
        loadChildren: () =>
          import('./modules/seguridad/seguridad.routes').then((m) => m.SEGURIDAD_ROUTES),
      },
      {
        path: '**',
        loadComponent: () => import('./modules/pendiente/pendiente').then((m) => m.Pendiente),
      },
    ],
  },
];
