import { Component } from '@angular/core';
import { ConsultaConfig, PERIODO } from '../../shared/consulta/consulta';
import { ConsultaPagina } from '../../shared/consulta/consulta-pagina';

interface Registro {
  idBitacora: number;
  tabla: string;
  operacion: string;
  idRegistro: number;
  valoresAnteriores: string | null;
  valoresNuevos: string | null;
  usuarioBd: string;
  usuarioApp: string | null;
  fecha: string;
}

@Component({
  selector: 'app-bitacora',
  imports: [ConsultaPagina],
  template: '<app-consulta-pagina [config]="config" />',
})
export class Bitacora {
  protected readonly config: ConsultaConfig<Registro> = {
    titulo: 'Bitácora general',
    descripcion: 'Cambios registrados en la base de datos (hasta 200 más recientes)',
    endpoint: 'bitacora',
    filtros: [
      { nombre: 'tabla', etiqueta: 'Tabla', tipo: 'texto' },
      {
        nombre: 'operacion',
        etiqueta: 'Operación',
        tipo: 'opciones',
        opciones: [
          { valor: 'INSERT', texto: 'Inserción' },
          { valor: 'UPDATE', texto: 'Modificación' },
          { valor: 'DELETE', texto: 'Eliminación' },
        ],
      },
      { nombre: 'usuario', etiqueta: 'Usuario de la aplicación', tipo: 'texto' },
      ...PERIODO,
    ],
    resumen: (filas) => `${filas.length} registros`,
    columnas: [
      { campo: 'fecha', titulo: 'Fecha', tipo: 'fechaHora' },
      { campo: 'tabla', titulo: 'Tabla' },
      { campo: 'operacion', titulo: 'Operación' },
      { campo: 'idRegistro', titulo: 'Registro', tipo: 'numero' },
      { campo: 'usuarioApp', titulo: 'Usuario' },
      { campo: 'usuarioBd', titulo: 'Usuario BD' },
    ],
    detalle: (r) => ({
      titulo: `Bitácora ${r.idBitacora}`,
      cabecera: [
        { etiqueta: 'Tabla', valor: r.tabla },
        { etiqueta: 'Operación', valor: r.operacion },
        { etiqueta: 'Registro', valor: String(r.idRegistro) },
        { etiqueta: 'Usuario', valor: r.usuarioApp ?? r.usuarioBd },
        { etiqueta: 'Valores anteriores', valor: r.valoresAnteriores ?? '', completo: true },
        { etiqueta: 'Valores nuevos', valor: r.valoresNuevos ?? '', completo: true },
      ],
      columnas: [],
      lineas: [],
    }),
  };
}
