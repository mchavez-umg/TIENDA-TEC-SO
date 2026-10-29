import { CurrencyPipe } from '@angular/common';
import { Component, computed, effect, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { MatAutocompleteModule } from '@angular/material/autocomplete';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDialog } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTooltipModule } from '@angular/material/tooltip';
import { Router, RouterLink } from '@angular/router';
import { finalize, map } from 'rxjs';
import { Cliente } from '../../../data/models/comercial';
import { Producto } from '../../../data/models/productos';
import { BancoService, ClienteService, FormaPagoService } from '../../../data/services/comercial.service';
import { SucursalService } from '../../../data/services/geografia.service';
import { InventarioService } from '../../../data/services/inventario.service';
import { ProductoService } from '../../../data/services/productos.service';
import { FacturaService } from '../../../data/services/ventas.service';
import { BuscadorProducto } from '../../../shared/buscador-producto/buscador-producto';
import { activos } from '../../../shared/crud/crud';
import { anchoFormulario, FormularioDialogo } from '../../../shared/formulario/formulario-dialogo';
import { Notificacion } from '../../../shared/notificacion.service';
import { CAMPOS_CLIENTE } from '../../clientes/clientes';
import {
  centavos,
  errorLinea,
  LineaVenta,
  PagoVenta,
  pendiente,
  subtotalLinea,
  totales,
  totalPagado,
} from './calculos';
import { FacturaDetalle } from './factura-detalle';

const CLAVE_SUCURSAL = 'tienda.factura.sucursal';

@Component({
  selector: 'app-nueva-factura',
  imports: [
    CurrencyPipe,
    RouterLink,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatAutocompleteModule,
    MatButtonModule,
    MatIconModule,
    MatTooltipModule,
    BuscadorProducto,
  ],
  templateUrl: './nueva-factura.html',
  styleUrl: './nueva-factura.scss',
})
export class NuevaFactura {
  private readonly facturas = inject(FacturaService);
  private readonly inventario = inject(InventarioService);
  private readonly clientesServicio = inject(ClienteService);
  private readonly dialog = inject(MatDialog);
  private readonly router = inject(Router);
  private readonly notificacion = inject(Notificacion);

  protected readonly sucursales = toSignal(inject(SucursalService).listar().pipe(map(activos)), {
    initialValue: [],
  });
  protected readonly productos = toSignal(inject(ProductoService).listar().pipe(map(activos)), {
    initialValue: [],
  });
  protected readonly formas = toSignal(inject(FormaPagoService).listar().pipe(map(activos)), {
    initialValue: [],
  });
  protected readonly bancos = toSignal(inject(BancoService).listar().pipe(map(activos)), {
    initialValue: [],
  });
  protected readonly clientes = signal<Cliente[]>([]);

  protected readonly idSucursal = signal<number | null>(leerSucursal());
  protected readonly cliente = signal<Cliente | null>(null);
  protected readonly existencias = signal(new Map<number, number>());
  protected readonly lineas = signal<LineaVenta[]>([]);
  protected readonly pagos = signal<PagoVenta[]>([]);

  protected readonly busquedaCliente = signal('');
  protected readonly idFormaPago = signal<number | null>(null);
  protected readonly monto = signal<number | null>(null);
  protected readonly idBanco = signal<number | null>(null);
  protected readonly referencia = signal('');
  protected readonly autorizacion = signal('');
  protected readonly errorPago = signal<string | null>(null);
  protected readonly emitiendo = signal(false);

  protected readonly resumen = computed(() => totales(this.lineas()));
  protected readonly pagado = computed(() => totalPagado(this.pagos()));
  protected readonly porPagar = computed(() => pendiente(this.lineas(), this.pagos()));
  protected readonly formaElegida = computed(() =>
    this.formas().find((f) => f.idFormaPago === this.idFormaPago()),
  );
  protected readonly requiereReferencia = computed(() => this.formaElegida()?.requiereReferencia === 'S');

  protected readonly clientesFiltrados = computed(() => {
    const texto = this.busquedaCliente().trim().toLowerCase();
    return this.clientes()
      .filter((c) => !texto || this.textoCliente(c).toLowerCase().includes(texto))
      .slice(0, 8);
  });

  protected readonly motivo = computed(() => {
    if (!this.idSucursal()) return 'Seleccione la sucursal.';
    if (!this.cliente()) return 'Seleccione el cliente.';
    if (!this.lineas().length) return 'Agregue al menos un producto.';
    if (this.lineas().some((l) => errorLinea(l))) return 'Corrija las líneas marcadas.';
    if (this.porPagar() > 0) return `Falta registrar ${formatoQ(this.porPagar())} en pagos.`;
    if (this.porPagar() < 0) return 'Los pagos superan el total. Quite o ajuste un pago.';
    return null;
  });

  protected readonly subtotalLinea = subtotalLinea;
  protected readonly errorLinea = errorLinea;

  constructor() {
    this.clientesServicio
      .listar()
      .pipe(map(activos))
      .subscribe((clientes) => {
        this.clientes.set(clientes);
        this.cliente.set(clientes.find((c) => c.nit.toUpperCase() === 'CF') ?? null);
      });

    effect(() => {
      const idSucursal = this.idSucursal();
      if (!idSucursal) return;
      this.inventario.existencias(idSucursal).subscribe({
        next: (filas) => this.existencias.set(new Map(filas.map((f) => [f.idProducto, f.existencia]))),
        error: (error) => this.notificacion.error(error),
      });
    });

    effect(() => {
      const existencias = this.existencias();
      this.lineas.update((lineas) =>
        lineas.map((l) => ({ ...l, existencia: existencias.get(l.idProducto) ?? 0 })),
      );
    });
  }

  protected textoCliente(cliente: Cliente | null) {
    return cliente ? `${cliente.nit} · ${cliente.nombres} ${cliente.apellidos ?? ''}`.trim() : '';
  }

  protected disponible(idProducto: number) {
    return this.existencias().get(idProducto) ?? 0;
  }

  protected elegirSucursal(idSucursal: number) {
    this.idSucursal.set(idSucursal);
    try {
      localStorage.setItem(CLAVE_SUCURSAL, String(idSucursal));
    } catch {}
  }

  protected nuevoCliente() {
    this.dialog
      .open(FormularioDialogo, {
        width: anchoFormulario(CAMPOS_CLIENTE),
        data: {
          titulo: 'Nuevo cliente',
          campos: CAMPOS_CLIENTE,
          guardar: (valores: Record<string, unknown>) => this.clientesServicio.crear(valores),
          mensajeExito: 'Cliente creado',
        },
      })
      .afterClosed()
      .subscribe((creado) => {
        if (creado && typeof creado === 'object') {
          this.clientes.update((clientes) => [creado as Cliente, ...clientes]);
          this.cliente.set(creado as Cliente);
        }
      });
  }

  protected agregar(producto: Producto) {
    this.lineas.update((lineas) => {
      const existente = lineas.find((l) => l.idProducto === producto.idProducto);
      if (existente) {
        return lineas.map((l) => (l === existente ? { ...l, cantidad: l.cantidad + 1 } : l));
      }
      return [
        ...lineas,
        {
          idProducto: producto.idProducto,
          codigo: producto.codigo,
          nombre: producto.nombre,
          precio: producto.precioVenta,
          cantidad: 1,
          descuento: 0,
          existencia: this.disponible(producto.idProducto),
        },
      ];
    });
  }

  protected actualizar(indice: number, campo: 'cantidad' | 'descuento', valor: string) {
    const numero = valor === '' ? 0 : Number(valor);
    this.lineas.update((lineas) =>
      lineas.map((l, i) => (i === indice ? { ...l, [campo]: Number.isFinite(numero) ? numero : 0 } : l)),
    );
  }

  protected quitar(indice: number) {
    this.lineas.update((lineas) => lineas.filter((_, i) => i !== indice));
  }

  protected elegirForma(idFormaPago: number) {
    this.idFormaPago.set(idFormaPago);
    this.errorPago.set(null);
    if (this.porPagar() > 0) {
      this.monto.set(this.porPagar());
    }
    if (!this.requiereReferencia()) {
      this.idBanco.set(null);
      this.referencia.set('');
      this.autorizacion.set('');
    }
  }

  protected agregarPago() {
    const forma = this.formaElegida();
    const monto = this.monto() ?? 0;
    const referencia = this.referencia().trim() || null;
    const autorizacion = this.autorizacion().trim() || null;
    if (!forma) return this.errorPago.set('Seleccione la forma de pago.');
    if (centavos(monto) <= 0) return this.errorPago.set('Ingrese un monto mayor a cero.');
    if (centavos(monto) > centavos(this.porPagar())) {
      return this.errorPago.set(`El monto no puede superar lo pendiente (${formatoQ(this.porPagar())}).`);
    }
    if (this.requiereReferencia() && (!this.idBanco() || (!referencia && !autorizacion))) {
      return this.errorPago.set('Esta forma de pago requiere banco y número de referencia o autorización.');
    }
    this.pagos.update((pagos) => [
      ...pagos,
      {
        idFormaPago: forma.idFormaPago,
        formaPago: forma.nombre,
        monto,
        idBanco: this.idBanco(),
        banco: this.bancos().find((b) => b.idBanco === this.idBanco())?.nombre ?? null,
        noReferencia: referencia,
        noAutorizacion: autorizacion,
      },
    ]);
    this.idFormaPago.set(null);
    this.monto.set(null);
    this.idBanco.set(null);
    this.referencia.set('');
    this.autorizacion.set('');
    this.errorPago.set(null);
  }

  protected quitarPago(indice: number) {
    this.pagos.update((pagos) => pagos.filter((_, i) => i !== indice));
  }

  protected emitir() {
    const idSucursal = this.idSucursal();
    const cliente = this.cliente();
    if (this.motivo() || !idSucursal || !cliente) return;
    this.emitiendo.set(true);
    this.facturas
      .registrar({
        idSucursal,
        idCliente: cliente.idCliente,
        lineas: this.lineas().map((l) => ({
          idProducto: l.idProducto,
          cantidad: l.cantidad,
          descuento: l.descuento,
        })),
        pagos: this.pagos().map((p) => ({
          idFormaPago: p.idFormaPago,
          monto: p.monto,
          idBanco: p.idBanco,
          noReferencia: p.noReferencia,
          noAutorizacion: p.noAutorizacion,
        })),
      })
      .pipe(finalize(() => this.emitiendo.set(false)))
      .subscribe({
        next: (factura) =>
          this.dialog
            .open(FacturaDetalle, {
              data: { idFactura: factura.idFactura, recienEmitida: true },
              width: '760px',
            })
            .afterClosed()
            .subscribe(() => this.router.navigateByUrl('/ventas/facturas')),
        error: (error) => this.notificacion.error(error),
      });
  }
}

function leerSucursal() {
  try {
    const valor = Number(localStorage.getItem(CLAVE_SUCURSAL));
    return valor > 0 ? valor : null;
  } catch {
    return null;
  }
}

function formatoQ(valor: number) {
  return `Q${valor.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}
