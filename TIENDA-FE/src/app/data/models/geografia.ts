export interface Departamento {
  idDepartamento: number;
  nombre: string;
  estado: string;
}

export interface Municipio {
  idMunicipio: number;
  idDepartamento: number;
  departamento: string;
  nombre: string;
  esCabecera: string;
  estado: string;
}

export interface Sucursal {
  idSucursal: number;
  idMunicipio: number;
  municipio: string;
  codigo: string;
  nombre: string;
  direccion: string;
  telefono: string | null;
  correo: string | null;
  fechaApertura: string;
  estado: string;
}
