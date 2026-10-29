export interface MenuOpcion {
  idOpcion: number;
  idOpcionPadre: number | null;
  nombre: string;
  ruta: string | null;
  icono: string | null;
  orden: number;
  puedeCrear: boolean;
  puedeEditar: boolean;
  puedeEliminar: boolean;
}

export interface MenuNodo extends MenuOpcion {
  hijos: MenuOpcion[];
}
