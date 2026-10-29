import { Component } from '@angular/core';
import { ConsultaConfig, PERIODO } from '../../shared/consulta/consulta';
import { ConsultaPagina } from '../../shared/consulta/consulta-pagina';

const PLANTILLA = '<app-consulta-pagina [config]="config" />';

@Component({ selector: 'app-reporte-sucursal', imports: [ConsultaPagina], template: PLANTILLA })
export class VentasSucursal {
  protected readonly config: ConsultaConfig<unknown> = {
    titulo: 'Ventas por sucursal',
    descripcion: 'Facturación de cada tienda en el período',
    endpoint: 'reportes/ventas-sucursal',
    filtros: PERIODO,
    resumen: (filas) => `${filas.length} sucursales`,
    columnas: [
      { campo: 'sucursal', titulo: 'Sucursal' },
      { campo: 'numeroFacturas', titulo: 'Facturas', tipo: 'numero', total: true },
      { campo: 'totalVendido', titulo: 'Vendido', tipo: 'moneda', total: true, barra: true },
    ],
  };
}

@Component({ selector: 'app-reporte-producto', imports: [ConsultaPagina], template: PLANTILLA })
export class VentasProducto {
  protected readonly config: ConsultaConfig<unknown> = {
    titulo: 'Ventas por producto',
    descripcion: 'Unidades y monto vendido de cada producto',
    endpoint: 'reportes/ventas-producto',
    filtros: PERIODO,
    resumen: (filas) => `${filas.length} productos vendidos`,
    columnas: [
      { campo: 'codigoProducto', titulo: 'Código' },
      { campo: 'producto', titulo: 'Producto' },
      { campo: 'cantidad', titulo: 'Unidades', tipo: 'numero', total: true },
      { campo: 'total', titulo: 'Vendido', tipo: 'moneda', total: true, barra: true },
    ],
  };
}

@Component({ selector: 'app-reporte-categoria', imports: [ConsultaPagina], template: PLANTILLA })
export class VentasCategoria {
  protected readonly config: ConsultaConfig<unknown> = {
    titulo: 'Ventas por categoría',
    descripcion: 'Participación de cada categoría en las ventas',
    endpoint: 'reportes/ventas-categoria',
    filtros: PERIODO,
    resumen: (filas) => `${filas.length} categorías`,
    columnas: [
      { campo: 'categoria', titulo: 'Categoría' },
      { campo: 'cantidad', titulo: 'Unidades', tipo: 'numero', total: true },
      { campo: 'total', titulo: 'Vendido', tipo: 'moneda', total: true, barra: true },
    ],
  };
}

@Component({ selector: 'app-reporte-empleado', imports: [ConsultaPagina], template: PLANTILLA })
export class VentasEmpleado {
  protected readonly config: ConsultaConfig<unknown> = {
    titulo: 'Ventas por empleado',
    descripcion: 'Desempeño de cada vendedor en el período',
    endpoint: 'reportes/ventas-empleado',
    filtros: PERIODO,
    resumen: (filas) => `${filas.length} vendedores`,
    columnas: [
      { campo: 'empleado', titulo: 'Empleado' },
      { campo: 'numeroFacturas', titulo: 'Facturas', tipo: 'numero', total: true },
      { campo: 'totalVendido', titulo: 'Vendido', tipo: 'moneda', total: true, barra: true },
    ],
  };
}

@Component({ selector: 'app-reporte-forma-pago', imports: [ConsultaPagina], template: PLANTILLA })
export class VentasFormaPago {
  protected readonly config: ConsultaConfig<unknown> = {
    titulo: 'Ventas por forma de pago',
    descripcion: 'Cómo pagan los clientes',
    endpoint: 'reportes/forma-pago',
    filtros: PERIODO,
    resumen: (filas) => `${filas.length} formas de pago`,
    columnas: [
      { campo: 'formaPago', titulo: 'Forma de pago' },
      { campo: 'numeroPagos', titulo: 'Pagos', tipo: 'numero', total: true },
      { campo: 'total', titulo: 'Monto', tipo: 'moneda', total: true, barra: true },
    ],
  };
}

@Component({ selector: 'app-reporte-garantias', imports: [ConsultaPagina], template: PLANTILLA })
export class GarantiasEstado {
  protected readonly config: ConsultaConfig<unknown> = {
    titulo: 'Garantías por estado',
    descripcion: 'Reclamos de garantía agrupados por estado',
    endpoint: 'reportes/garantias',
    filtros: [],
    resumen: (filas) => `${filas.length} estados`,
    columnas: [
      { campo: 'nombreEstado', titulo: 'Estado' },
      { campo: 'cantidad', titulo: 'Reclamos', tipo: 'numero', total: true, barra: true },
    ],
  };
}

@Component({ selector: 'app-reporte-notas-credito', imports: [ConsultaPagina], template: PLANTILLA })
export class NotasCreditoEmitidas {
  protected readonly config: ConsultaConfig<unknown> = {
    titulo: 'Notas de crédito emitidas',
    descripcion: 'Devoluciones registradas en el período',
    endpoint: 'reportes/notas-credito',
    filtros: PERIODO,
    resumen: (filas) => `${filas.length} notas de crédito`,
    columnas: [
      { campo: 'serie', titulo: 'Serie' },
      { campo: 'numero', titulo: 'No.', tipo: 'numero' },
      { campo: 'fecha', titulo: 'Fecha', tipo: 'fecha' },
      { campo: 'sucursal', titulo: 'Sucursal' },
      { campo: 'empleado', titulo: 'Emitida por' },
      { campo: 'motivo', titulo: 'Motivo' },
      { campo: 'total', titulo: 'Total', tipo: 'moneda', total: true },
    ],
  };
}

@Component({ selector: 'app-reporte-existencias', imports: [ConsultaPagina], template: PLANTILLA })
export class ExistenciasReporte {
  protected readonly config: ConsultaConfig<{ bajoMinimo: string }> = {
    titulo: 'Existencias y stock mínimo',
    descripcion: 'Productos por sucursal frente a su stock mínimo',
    endpoint: 'reportes/existencias',
    filtros: [
      { nombre: 'idSucursal', etiqueta: 'Sucursal', tipo: 'sucursal' },
      { nombre: 'soloBajoMinimo', etiqueta: 'Solo bajo el stock mínimo', tipo: 'casilla' },
    ],
    resumen: (filas) =>
      `${filas.length} productos · ${filas.filter((f) => f.bajoMinimo === 'S').length} bajo el mínimo`,
    columnas: [
      { campo: 'sucursal', titulo: 'Sucursal' },
      { campo: 'categoria', titulo: 'Categoría' },
      { campo: 'codigoProducto', titulo: 'Código' },
      { campo: 'producto', titulo: 'Producto' },
      { campo: 'existencia', titulo: 'Existencia', tipo: 'numero', total: true },
      { campo: 'stockMinimo', titulo: 'Stock mínimo', tipo: 'numero' },
      { campo: 'bajoMinimo', titulo: 'Bajo mínimo', tipo: 'sino' },
    ],
  };
}
