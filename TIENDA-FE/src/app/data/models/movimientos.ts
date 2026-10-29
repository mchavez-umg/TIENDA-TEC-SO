export interface CompraResumen {
  idCompra: number;
  idProveedor: number;
  proveedor: string;
  idSucursal: number;
  sucursal: string;
  noDocumento: string;
  fecha: string;
  total: number;
  estado: string;
}

export interface CompraDetalle {
  compra: CompraResumen;
  lineas: { idProducto: number; producto: string; cantidad: number; costoUnitario: number; subtotal: number }[];
}

export interface CompraRequest {
  idProveedor: number;
  idSucursal: number;
  noDocumento: string;
  lineas: { idProducto: number; cantidad: number; costoUnitario: number }[];
}

export interface TrasladoResumen {
  idTraslado: number;
  idSucursalOrigen: number;
  origen: string;
  idSucursalDestino: number;
  destino: string;
  fecha: string;
  observacion: string | null;
  estado: string;
}

export interface TrasladoDetalle {
  traslado: TrasladoResumen;
  lineas: { idProducto: number; producto: string; cantidad: number }[];
}

export interface TrasladoRequest {
  idSucursalOrigen: number;
  idSucursalDestino: number;
  observacion: string | null;
  lineas: { idProducto: number; cantidad: number }[];
}
