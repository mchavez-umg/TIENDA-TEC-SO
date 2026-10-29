import { Columna } from '../crud/crud';
import { DatosDocumento } from '../documento-detalle/documento-detalle';

export type TipoFiltro = 'desde' | 'hasta' | 'sucursal' | 'producto' | 'texto' | 'opciones' | 'casilla';

export interface Filtro {
  nombre: string;
  etiqueta: string;
  tipo: TipoFiltro;
  opciones?: { valor: string; texto: string }[];
}

export interface ConsultaConfig<T> {
  titulo: string;
  descripcion: string;
  endpoint: string;
  filtros: Filtro[];
  columnas: Columna[];
  resumen?: (filas: T[]) => string;
  detalle?: (fila: T) => DatosDocumento;
}

export const fechaLocal = (fecha: Date) => fecha.toLocaleDateString('en-CA');

export const PERIODO: Filtro[] = [
  { nombre: 'desde', etiqueta: 'Desde', tipo: 'desde' },
  { nombre: 'hasta', etiqueta: 'Hasta', tipo: 'hasta' },
];

export function valoresIniciales(filtros: Filtro[], hoy = new Date()) {
  const valores: Record<string, unknown> = {};
  for (const filtro of filtros) {
    if (filtro.tipo === 'desde') valores[filtro.nombre] = fechaLocal(new Date(hoy.getFullYear(), hoy.getMonth(), 1));
    else if (filtro.tipo === 'hasta') valores[filtro.nombre] = fechaLocal(hoy);
    else if (filtro.tipo === 'casilla') valores[filtro.nombre] = false;
    else valores[filtro.nombre] = null;
  }
  return valores;
}

export function parametros(valores: Record<string, unknown>) {
  const resultado: Record<string, string> = {};
  for (const [clave, valor] of Object.entries(valores)) {
    if (valor === null || valor === undefined || valor === '' || valor === false) continue;
    resultado[clave] = String(valor).trim();
  }
  return resultado;
}

export function aCsv(columnas: Columna[], filas: Record<string, unknown>[]) {
  const celda = (valor: unknown) => {
    const texto = valor === null || valor === undefined ? '' : String(valor);
    return /[",\n;]/.test(texto) ? `"${texto.replace(/"/g, '""')}"` : texto;
  };
  const lineas = [
    columnas.map((c) => celda(c.titulo)).join(','),
    ...filas.map((fila) => columnas.map((c) => celda(fila[c.campo])).join(',')),
  ];
  return '﻿' + lineas.join('\r\n');
}
