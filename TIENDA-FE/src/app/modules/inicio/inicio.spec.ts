import { resumirSucursales } from './inicio';

describe('Inicio', () => {
  it('ordena las sucursales y calcula participación y barra', () => {
    const filas = resumirSucursales({
      totalVendidoMes: 1000,
      facturasMes: 10,
      productosBajoMinimo: 0,
      garantiasAbiertas: 0,
      ventasPorSucursalMes: [
        { idSucursal: 1, sucursal: 'Xela', numeroFacturas: 3, totalVendido: 250 },
        { idSucursal: 2, sucursal: 'Zona 10', numeroFacturas: 7, totalVendido: 750 },
      ],
    });
    expect(filas.map((f) => f.sucursal)).toEqual(['Zona 10', 'Xela']);
    expect(filas.map((f) => f.participacion)).toEqual([75, 25]);
    expect(filas.map((f) => Math.round(f.barra))).toEqual([100, 33]);
  });

  it('no divide entre cero sin ventas', () => {
    const [fila] = resumirSucursales({
      totalVendidoMes: 0,
      facturasMes: 0,
      productosBajoMinimo: 0,
      garantiasAbiertas: 0,
      ventasPorSucursalMes: [{ idSucursal: 1, sucursal: 'Xela', numeroFacturas: 0, totalVendido: 0 }],
    });
    expect(fila.participacion).toBe(0);
    expect(fila.barra).toBe(0);
  });
});
