export interface FacturaResumen {
  idFactura: number;
  serie: string;
  numero: number;
  fecha: string;
  idSucursal: number;
  sucursal: string;
  idCliente: number;
  nit: string;
  cliente: string;
  empleado: string;
  subtotal: number;
  iva: number;
  total: number;
  estado: string;
}

export interface LineaFactura {
  idDetalleFactura: number;
  idProducto: number;
  codigo: string;
  producto: string;
  cantidad: number;
  precioUnitario: number;
  descuento: number;
  subtotal: number;
  inicioGarantia: string;
  finGarantia: string;
  pendienteNc: number;
  garantiaVigente: boolean;
}

export interface PagoFactura {
  idPago: number;
  formaPago: string;
  banco: string | null;
  monto: number;
  noReferencia: string | null;
  noAutorizacion: string | null;
}

export interface FacturaDetalle {
  factura: FacturaResumen;
  lineas: LineaFactura[];
  pagos: PagoFactura[];
}

export interface VentaRequest {
  idSucursal: number;
  idCliente: number;
  lineas: { idProducto: number; cantidad: number; descuento: number }[];
  pagos: {
    idFormaPago: number;
    monto: number;
    idBanco: number | null;
    noReferencia: string | null;
    noAutorizacion: string | null;
  }[];
}

export interface VentaRegistrada {
  idFactura: number;
  serie: string;
  numero: number;
  total: number;
}
