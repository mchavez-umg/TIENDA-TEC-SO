import { Campo } from '../crud/crud';
import { valoresAEnviar, valorInicial } from './formulario-dialogo';

describe('FormularioDialogo', () => {
  const campos: Campo[] = [
    { nombre: 'nombre', etiqueta: 'Nombre' },
    { nombre: 'correo', etiqueta: 'Correo', tipo: 'correo' },
    { nombre: 'activo', etiqueta: 'Activo', tipo: 'sino' },
    { nombre: 'precio', etiqueta: 'Precio', tipo: 'moneda' },
  ];

  it('convierte los valores iniciales del backend', () => {
    expect(valorInicial(campos[2], 'S')).toBe(true);
    expect(valorInicial(campos[2], 'N')).toBe(false);
    expect(valorInicial(campos[3], undefined)).toBeNull();
    expect(valorInicial(campos[0], undefined)).toBe('');
  });

  it('prepara los valores para el backend', () => {
    expect(
      valoresAEnviar(campos, { nombre: '  Samsung ', correo: '   ', activo: false, precio: 0 }),
    ).toEqual({ nombre: 'Samsung', correo: null, activo: 'N', precio: 0 });
  });
});
