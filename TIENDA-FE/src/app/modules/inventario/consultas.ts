import { Component } from '@angular/core';
import { ConsultaConfig, PERIODO } from '../../shared/consulta/consulta';
import { ConsultaPagina } from '../../shared/consulta/consulta-pagina';

@Component({
  selector: 'app-existencias',
  imports: [ConsultaPagina],
  template: '<app-consulta-pagina [config]="config" />',
})
export class Existencias {
  protected readonly config: ConsultaConfig<{ bajoMinimo: string }> = {
    titulo: 'Existencias',
    descripcion: 'Inventario disponible por sucursal',
    endpoint: 'inventario/existencias',
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

@Component({
  selector: 'app-kardex',
  imports: [ConsultaPagina],
  template: '<app-consulta-pagina [config]="config" />',
})
export class Kardex {
  protected readonly config: ConsultaConfig<unknown> = {
    titulo: 'Kardex',
    descripcion: 'Movimientos de inventario por producto',
    endpoint: 'inventario/kardex',
    filtros: [
      { nombre: 'idSucursal', etiqueta: 'Sucursal', tipo: 'sucursal' },
      { nombre: 'idProducto', etiqueta: 'Producto', tipo: 'producto' },
      ...PERIODO,
    ],
    resumen: (filas) => `${filas.length} movimientos`,
    columnas: [
      { campo: 'fecha', titulo: 'Fecha', tipo: 'fechaHora' },
      { campo: 'sucursal', titulo: 'Sucursal' },
      { campo: 'codigoProducto', titulo: 'Código' },
      { campo: 'producto', titulo: 'Producto' },
      { campo: 'tipoMovimiento', titulo: 'Movimiento' },
      { campo: 'cantidad', titulo: 'Cantidad', tipo: 'numero' },
      { campo: 'existenciaAnterior', titulo: 'Antes', tipo: 'numero' },
      { campo: 'existenciaNueva', titulo: 'Después', tipo: 'numero' },
      { campo: 'documentoOrigen', titulo: 'Documento' },
      { campo: 'creadoPor', titulo: 'Usuario' },
    ],
  };
}
