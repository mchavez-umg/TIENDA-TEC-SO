export interface Banco {
  idBanco: number;
  nombre: string;
  estado: string;
}

export interface FormaPago {
  idFormaPago: number;
  nombre: string;
  requiereReferencia: string;
  estado: string;
}

export interface Cliente {
  idCliente: number;
  nit: string;
  nombres: string;
  apellidos: string | null;
  telefono: string | null;
  correo: string | null;
  direccion: string | null;
  estado: string;
}

export interface Proveedor {
  idProveedor: number;
  nit: string;
  nombre: string;
  contacto: string | null;
  telefono: string | null;
  correo: string | null;
  direccion: string | null;
  estado: string;
}
