import { errorLineaCompra } from './nueva-compra';

describe('NuevaCompra', () => {
  const linea = { idProducto: 1, codigo: 'P-1', nombre: 'Producto', cantidad: 2, costo: 10 };

  it('acepta una línea válida, incluido costo cero', () => {
    expect(errorLineaCompra(linea)).toBeNull();
    expect(errorLineaCompra({ ...linea, costo: 0 })).toBeNull();
  });

  it('rechaza cantidades no enteras o menores a uno y costos negativos', () => {
    expect(errorLineaCompra({ ...linea, cantidad: 0 })).toBe('Cantidad no válida');
    expect(errorLineaCompra({ ...linea, cantidad: 1.5 })).toBe('Cantidad no válida');
    expect(errorLineaCompra({ ...linea, costo: -1 })).toBe('Costo no válido');
  });
});
