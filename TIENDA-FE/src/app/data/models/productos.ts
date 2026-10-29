export interface Marca {
  idMarca: number;
  nombre: string;
  estado: string;
}

export interface Categoria {
  idCategoria: number;
  nombre: string;
  descripcion: string | null;
  estado: string;
}

export interface Producto {
  idProducto: number;
  idCategoria: number;
  categoria: string;
  idMarca: number;
  marca: string;
  codigo: string;
  nombre: string;
  descripcion: string | null;
  precioCosto: number;
  precioVenta: number;
  mesesGarantia: number;
  estado: string;
}
