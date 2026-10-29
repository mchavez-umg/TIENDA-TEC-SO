import { Injectable } from '@angular/core';
import { API_URL } from '../../core/api';
import { Banco, Cliente, FormaPago, Proveedor } from '../models/comercial';
import { CrudService } from './crud.service';

@Injectable({ providedIn: 'root' })
export class BancoService extends CrudService<Banco> {
  protected readonly url = `${API_URL}/bancos`;
}

@Injectable({ providedIn: 'root' })
export class FormaPagoService extends CrudService<FormaPago> {
  protected readonly url = `${API_URL}/formas-pago`;
}

@Injectable({ providedIn: 'root' })
export class ClienteService extends CrudService<Cliente> {
  protected readonly url = `${API_URL}/clientes`;
}

@Injectable({ providedIn: 'root' })
export class ProveedorService extends CrudService<Proveedor> {
  protected readonly url = `${API_URL}/proveedores`;
}
