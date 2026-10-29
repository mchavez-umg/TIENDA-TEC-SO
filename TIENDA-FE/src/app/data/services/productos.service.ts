import { Injectable } from '@angular/core';
import { API_URL } from '../../core/api';
import { Categoria, Marca, Producto } from '../models/productos';
import { CrudService } from './crud.service';

@Injectable({ providedIn: 'root' })
export class MarcaService extends CrudService<Marca> {
  protected readonly url = `${API_URL}/marcas`;
}

@Injectable({ providedIn: 'root' })
export class CategoriaService extends CrudService<Categoria> {
  protected readonly url = `${API_URL}/categorias`;
}

@Injectable({ providedIn: 'root' })
export class ProductoService extends CrudService<Producto> {
  protected readonly url = `${API_URL}/productos`;
}
