import { LineaFactura } from '../../data/models/ventas';
import { montoEstimado } from '../ventas/notas-credito/nueva-nota';
import { motivoNoReclamable } from './reclamo-dialogo';

const linea = (parcial: Partial<LineaFactura>): LineaFactura => ({
  idDetalleFactura: 1,
  idProducto: 1,
  codigo: 'P-1',
  producto: 'Laptop',
  cantidad: 3,
  precioUnitario: 100,
  descuento: 0,
  subtotal: 300,
  inicioGarantia: '2026-01-01',
  finGarantia: '2027-01-01',
  pendienteNc: 3,
  garantiaVigente: true,
  ...parcial,
});

describe('postventa', () => {
  it('solo permite reclamar productos con garantía vigente y no devueltos', () => {
    expect(motivoNoReclamable(linea({}))).toBeNull();
    expect(motivoNoReclamable(linea({ garantiaVigente: false }))).toBe('Garantía vencida');
    expect(motivoNoReclamable(linea({ pendienteNc: 0 }))).toBe('Devuelto con nota de crédito');
  });

  it('estima el monto de la devolución proporcional al subtotal', () => {
    expect(montoEstimado(linea({ subtotal: 100, cantidad: 3 }), 1)).toBe(33.33);
    expect(montoEstimado(linea({ subtotal: 299.99, cantidad: 3 }), 3)).toBe(299.99);
    expect(montoEstimado(linea({}), 0)).toBe(0);
  });
});
