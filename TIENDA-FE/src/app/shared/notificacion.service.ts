import { HttpErrorResponse } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';

const MENSAJES_POR_ESTADO: Record<number, string> = {
  400: 'Los datos enviados no son válidos',
  403: 'No tiene permiso para realizar esta acción',
  404: 'El registro no existe',
  500: 'El servidor no pudo completar la operación. Intente de nuevo en unos minutos.',
  503: 'El servidor no está disponible. Intente de nuevo en unos minutos.',
};

export function mensajeError(error: unknown): string {
  if (error instanceof HttpErrorResponse) {
    if (error.status === 0) {
      return 'No se pudo conectar con el servidor';
    }
    return error.error?.mensaje ?? MENSAJES_POR_ESTADO[error.status] ?? `No se pudo completar la operación (código ${error.status}).`;
  }
  return 'Ocurrió un error inesperado';
}

@Injectable({ providedIn: 'root' })
export class Notificacion {
  private readonly snackBar = inject(MatSnackBar);

  exito(mensaje: string) {
    this.snackBar.open(mensaje, 'Cerrar', { duration: 3000 });
  }

  error(error: unknown) {
    this.snackBar.open(mensajeError(error), 'Cerrar', {
      duration: 6000,
      panelClass: 'snack-error',
    });
  }
}
