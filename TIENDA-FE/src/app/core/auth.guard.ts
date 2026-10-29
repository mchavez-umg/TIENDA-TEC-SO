import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from './auth.service';

export const authGuard: CanActivateFn = () =>
  inject(AuthService).autenticado() || inject(Router).createUrlTree(['/login']);

export const invitadoGuard: CanActivateFn = () =>
  !inject(AuthService).autenticado() || inject(Router).createUrlTree(['/']);
