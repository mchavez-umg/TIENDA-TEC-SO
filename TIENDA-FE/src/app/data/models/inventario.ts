export interface Existencia {
  idSucursal: number;
  sucursal: string;
  categoria: string;
  idProducto: number;
  codigoProducto: string;
  producto: string;
  existencia: number;
  stockMinimo: number;
  bajoMinimo: string;
  fechaActualizacion: string | null;
}
