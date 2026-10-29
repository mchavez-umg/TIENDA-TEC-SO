export interface NotaResumen {
  idNotaCredito: number;
  idFactura: number;
  serie: string;
  numero: number;
  fecha: string;
  motivo: string;
  total: number;
  estado: string;
  factura: string;
  cliente: string;
}

export interface NotaDetalle {
  notaCredito: NotaResumen;
  lineas: { idDetalleFactura: number; producto: string; cantidad: number; monto: number; reingresaInventario: string }[];
}

export interface NotaRequest {
  idFactura: number;
  motivo: string;
  lineas: { idDetalleFactura: number; cantidad: number; reingresaInventario: string }[];
}

export interface Garantia {
  idGarantia: number;
  idDetalleFactura: number;
  producto: string;
  descripcionFalla: string;
  tipoResolucion: string | null;
  idProductoReemplazo: number | null;
  productoReemplazo: string | null;
  fechaReclamo: string;
  fechaResolucion: string | null;
  observaciones: string | null;
  estado: string;
  factura: string;
  cliente: string;
}
