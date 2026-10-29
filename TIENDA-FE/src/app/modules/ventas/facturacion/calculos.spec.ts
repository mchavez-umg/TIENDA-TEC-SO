import { errorLinea, LineaVenta, pendiente, PagoVenta, totales } from './calculos';

const linea = (parcial: Partial<LineaVenta>): LineaVenta => ({
  idProducto: 1,
  codigo: 'P-1',
  nombre: 'Producto',
  precio: 0,
  cantidad: 1,
  descuento: 0,
  existencia: 10,
  ...parcial,
});

const pago = (monto: number): PagoVenta => ({
  idFormaPago: 1,
  formaPago: 'Efectivo',
  monto,
  idBanco: null,
  banco: null,
  noReferencia: null,
  noAutorizacion: null,
});

describe('calculos de factura', () => {
  it('calcula total, base e IVA como Oracle', () => {
    const resultado = totales([
      linea({ precio: 0.1, cantidad: 3 }),
      linea({ idProducto: 2, precio: 1499.99, cantidad: 2, descuento: 100 }),
    ]);
    expect(resultado.total).toBe(2900.28);
    expect(resultado.base).toBe(2589.54);
    expect(resultado.iva).toBe(310.74);
  });

  it('calcula lo pendiente sin errores de coma flotante', () => {
    const lineas = [linea({ precio: 0.1, cantidad: 3 })];
    expect(pendiente(lineas, [pago(0.1), pago(0.2)])).toBe(0);
  });

  it('valida existencia, cantidad y descuento', () => {
    expect(errorLinea(linea({ precio: 10, cantidad: 11 }))).toBe('Solo hay 10 disponibles');
    expect(errorLinea(linea({ precio: 10, cantidad: 0 }))).toBe('Cantidad no válida');
    expect(errorLinea(linea({ precio: 10, cantidad: 2, descuento: 20.01 }))).toBe(
      'El descuento supera el valor de la línea',
    );
    expect(errorLinea(linea({ precio: 10, cantidad: 2, descuento: 20 }))).toBeNull();
  });
});
