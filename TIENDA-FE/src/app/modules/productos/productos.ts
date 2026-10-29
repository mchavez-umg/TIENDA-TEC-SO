import { Component, inject } from '@angular/core';
import { Categoria, Marca, Producto } from '../../data/models/productos';
import { CategoriaService, MarcaService, ProductoService } from '../../data/services/productos.service';
import { CrudConfig, opcionesDe } from '../../shared/crud/crud';
import { CrudPagina } from '../../shared/crud/crud-pagina';

@Component({
  selector: 'app-marcas',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Marcas {
  protected readonly config: CrudConfig<Marca> = {
    titulo: 'Marcas',
    descripcion: 'Catálogo de marcas de productos',
    singular: 'marca',
    femenino: true,
    ruta: '/productos/marcas',
    servicio: inject(MarcaService),
    id: 'idMarca',
    columnas: [
      { campo: 'idMarca', titulo: 'Código', clase: 'col-codigo' },
      { campo: 'nombre', titulo: 'Nombre' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [{ nombre: 'nombre', etiqueta: 'Nombre', requerido: true, largoMax: 60 }],
  };
}

@Component({
  selector: 'app-categorias',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Categorias {
  protected readonly config: CrudConfig<Categoria> = {
    titulo: 'Categorías',
    descripcion: 'Clasificación de los productos',
    singular: 'categoría',
    femenino: true,
    ruta: '/productos/categorias',
    servicio: inject(CategoriaService),
    id: 'idCategoria',
    columnas: [
      { campo: 'idCategoria', titulo: 'Código', clase: 'col-codigo' },
      { campo: 'nombre', titulo: 'Nombre' },
      { campo: 'descripcion', titulo: 'Descripción' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [
      { nombre: 'nombre', etiqueta: 'Nombre', requerido: true, largoMax: 60 },
      { nombre: 'descripcion', etiqueta: 'Descripción', tipo: 'area', largoMax: 200 },
    ],
  };
}

@Component({
  selector: 'app-productos',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Productos {
  protected readonly config: CrudConfig<Producto> = {
    titulo: 'Productos',
    descripcion: 'Catálogo de productos, precios y garantía',
    singular: 'producto',
    ruta: '/productos/productos',
    servicio: inject(ProductoService),
    id: 'idProducto',
    columnas: [
      { campo: 'codigo', titulo: 'Código', clase: 'col-codigo' },
      { campo: 'nombre', titulo: 'Nombre' },
      { campo: 'categoria', titulo: 'Categoría' },
      { campo: 'marca', titulo: 'Marca' },
      { campo: 'precioVenta', titulo: 'Precio venta', tipo: 'moneda' },
      { campo: 'mesesGarantia', titulo: 'Garantía (meses)', tipo: 'numero' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [
      { nombre: 'codigo', etiqueta: 'Código', requerido: true, largoMax: 20 },
      { nombre: 'nombre', etiqueta: 'Nombre', requerido: true, largoMax: 120 },
      {
        nombre: 'idCategoria',
        etiqueta: 'Categoría',
        tipo: 'select',
        requerido: true,
        opciones: opcionesDe(inject(CategoriaService), 'idCategoria', (c) => c.nombre),
      },
      {
        nombre: 'idMarca',
        etiqueta: 'Marca',
        tipo: 'select',
        requerido: true,
        opciones: opcionesDe(inject(MarcaService), 'idMarca', (m) => m.nombre),
      },
      { nombre: 'precioCosto', etiqueta: 'Precio costo', tipo: 'moneda', requerido: true, min: 0 },
      { nombre: 'precioVenta', etiqueta: 'Precio venta', tipo: 'moneda', requerido: true, min: 0 },
      {
        nombre: 'mesesGarantia',
        etiqueta: 'Garantía (meses)',
        tipo: 'numero',
        requerido: true,
        min: 0,
        max: 120,
      },
      { nombre: 'descripcion', etiqueta: 'Descripción', tipo: 'area', largoMax: 300 },
    ],
  };
}
