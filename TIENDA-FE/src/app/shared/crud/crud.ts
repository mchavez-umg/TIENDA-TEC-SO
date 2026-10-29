import { map, Observable } from 'rxjs';
import { CrudService } from '../../data/services/crud.service';

export type TipoColumna = 'texto' | 'numero' | 'moneda' | 'fecha' | 'fechaHora' | 'sino' | 'estado';

export interface Columna {
  campo: string;
  titulo: string;
  tipo?: TipoColumna;
  clase?: string;
  total?: boolean;
  barra?: boolean;
}

export type TipoCampo =
  | 'texto'
  | 'area'
  | 'numero'
  | 'moneda'
  | 'fecha'
  | 'hora'
  | 'correo'
  | 'password'
  | 'select'
  | 'sino';

export interface Opcion {
  valor: unknown;
  texto: string;
  activo: boolean;
}

export interface Campo {
  nombre: string;
  etiqueta: string;
  tipo?: TipoCampo;
  requerido?: boolean;
  min?: number;
  max?: number;
  largoMin?: number;
  largoMax?: number;
  patron?: string;
  mensajePatron?: string;
  pista?: string;
  opciones?: Observable<Opcion[]>;
  soloCrear?: boolean;
  completo?: boolean;
}

export type Permiso = 'consultar' | 'puedeCrear' | 'puedeEditar' | 'puedeEliminar';

export type TonoEstado = 'exito' | 'aviso' | 'inactivo';

export interface AccionExtra<T> {
  icono: string;
  texto: string;
  permiso: Permiso;
  visible?: (fila: T) => boolean;
  ejecutar: (fila: T, recargar: () => void) => void;
}

export interface CrudConfig<T> {
  titulo: string;
  descripcion: string;
  singular: string;
  femenino?: boolean;
  ruta: string;
  servicio: CrudService<T>;
  id: keyof T & string;
  etiqueta?: (fila: T) => string;
  columnas: Columna[];
  campos: Campo[];
  acciones?: AccionExtra<T>[];
  nuevoRuta?: string;
  alCrear?: (recargar: () => void) => void;
  editable?: boolean;
  desactivable?: boolean;
  tonoEstado?: (estado: string) => TonoEstado;
  resumen?: (filas: T[]) => string;
}

export const activos = <T extends { estado: string }>(filas: T[]) =>
  filas.filter((fila) => fila.estado === 'Activo');

export function opcionesDe<T extends { estado: string }>(
  servicio: CrudService<T>,
  valor: keyof T,
  texto: (fila: T) => string,
): Observable<Opcion[]> {
  return servicio
    .listar()
    .pipe(
      map((filas) =>
        filas.map((fila) => ({ valor: fila[valor], texto: texto(fila), activo: fila.estado === 'Activo' })),
      ),
    );
}
