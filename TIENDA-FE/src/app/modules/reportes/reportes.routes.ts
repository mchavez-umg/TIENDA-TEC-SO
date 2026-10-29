import { Routes } from '@angular/router';
import {
  ExistenciasReporte,
  GarantiasEstado,
  NotasCreditoEmitidas,
  VentasCategoria,
  VentasEmpleado,
  VentasFormaPago,
  VentasProducto,
  VentasSucursal,
} from './reportes';

export const REPORTES_ROUTES: Routes = [
  { path: 'dashboard', loadComponent: () => import('../inicio/inicio').then((m) => m.Inicio) },
  { path: 'ventas-sucursal', component: VentasSucursal },
  { path: 'ventas-producto', component: VentasProducto },
  { path: 'ventas-categoria', component: VentasCategoria },
  { path: 'ventas-empleado', component: VentasEmpleado },
  { path: 'forma-pago', component: VentasFormaPago },
  { path: 'garantias', component: GarantiasEstado },
  { path: 'notas-credito', component: NotasCreditoEmitidas },
  { path: 'existencias', component: ExistenciasReporte },
];
