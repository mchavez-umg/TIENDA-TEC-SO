export interface LineaVenta {
  idProducto: number;
  codigo: string;
  nombre: string;
  precio: number;
  cantidad: number;
  descuento: number;
  existencia: number;
}

export interface PagoVenta {
  idFormaPago: number;
  formaPago: string;
  monto: number;
  idBanco: number | null;
  banco: string | null;
  noReferencia: string | null;
  noAutorizacion: string | null;
}

export const centavos = (quetzales: number) => Math.round(quetzales * 100);

export function subtotalLinea(linea: LineaVenta) {
  return (centavos(linea.precio) * linea.cantidad - centavos(linea.descuento)) / 100;
}

export function errorLinea(linea: LineaVenta): string | null {
  if (!Number.isInteger(linea.cantidad) || linea.cantidad < 1) return 'Cantidad no válida';
  if (linea.cantidad > linea.existencia) return `Solo hay ${linea.existencia} disponibles`;
  if (linea.descuento < 0) return 'Descuento no válido';
  if (centavos(linea.descuento) > centavos(linea.precio) * linea.cantidad) {
    return 'El descuento supera el valor de la línea';
  }
  return null;
}

export function totales(lineas: LineaVenta[]) {
  const total = lineas.reduce((suma, l) => suma + centavos(subtotalLinea(l)), 0);
  const base = Math.round(total / 1.12);
  return { total: total / 100, base: base / 100, iva: (total - base) / 100 };
}

export function totalPagado(pagos: PagoVenta[]) {
  return pagos.reduce((suma, p) => suma + centavos(p.monto), 0) / 100;
}

export function pendiente(lineas: LineaVenta[], pagos: PagoVenta[]) {
  return (centavos(totales(lineas).total) - centavos(totalPagado(pagos))) / 100;
}
