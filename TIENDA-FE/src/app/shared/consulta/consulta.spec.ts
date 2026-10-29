import { aCsv, parametros, PERIODO, valoresIniciales } from './consulta';

describe('consulta', () => {
  it('arranca el periodo en el mes en curso', () => {
    expect(valoresIniciales(PERIODO, new Date(2026, 9, 23))).toEqual({
      desde: '2026-10-01',
      hasta: '2026-10-23',
    });
  });

  it('solo envía los filtros con valor', () => {
    expect(
      parametros({ desde: '2026-10-01', idSucursal: null, tabla: '  CLIENTE ', soloBajoMinimo: false, b: true }),
    ).toEqual({ desde: '2026-10-01', tabla: 'CLIENTE', b: 'true' });
  });

  it('genera CSV con comillas cuando hace falta', () => {
    const csv = aCsv(
      [
        { campo: 'nombre', titulo: 'Nombre' },
        { campo: 'total', titulo: 'Total' },
      ],
      [{ nombre: 'Laptop, 14"', total: 10.5 }],
    );
    expect(csv).toBe('﻿Nombre,Total\r\n"Laptop, 14""",10.5');
  });
});
