import { Routes } from '@angular/router';
import { AsignacionHorarios, Empleados, Horarios, Puestos } from './personal';

export const PERSONAL_ROUTES: Routes = [
  { path: 'puestos', component: Puestos },
  { path: 'empleados', component: Empleados },
  { path: 'horarios', component: Horarios },
  { path: 'asignacion-horarios', component: AsignacionHorarios },
];
