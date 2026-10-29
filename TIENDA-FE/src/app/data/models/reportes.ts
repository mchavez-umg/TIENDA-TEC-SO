export interface VentaSucursal {
  idSucursal: number;
  sucursal: string;
  numeroFacturas: number;
  totalVendido: number;
}

export interface Dashboard {
  totalVendidoMes: number;
  facturasMes: number;
  productosBajoMinimo: number;
  garantiasAbiertas: number;
  ventasPorSucursalMes: VentaSucursal[];
}
