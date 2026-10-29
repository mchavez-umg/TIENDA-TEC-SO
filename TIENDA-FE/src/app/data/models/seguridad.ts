export interface Rol {
  idRol: number;
  nombre: string;
  descripcion: string | null;
  estado: string;
}

export interface Usuario {
  idUsuario: number;
  idEmpleado: number;
  empleado: string;
  idRol: number;
  rol: string;
  username: string;
  intentosFallidos: number;
  ultimoAcceso: string | null;
  estado: string;
}

export interface OpcionMenuAdmin {
  idOpcion: number;
  idOpcionPadre: number | null;
  padre: string | null;
  nombre: string;
  ruta: string | null;
  icono: string | null;
  orden: number;
  estado: string;
}

export interface OpcionCatalogo {
  idOpcion: number;
  idOpcionPadre: number | null;
  nombre: string;
  ruta: string | null;
  orden: number;
}

export interface PermisoRol {
  idOpcion: number;
  opcion: string;
  ruta: string | null;
  puedeConsultar: string;
  puedeCrear: string;
  puedeEditar: string;
  puedeEliminar: string;
}
