import { Component, inject } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { map } from 'rxjs';
import { MenuService } from '../../core/menu.service';
import { OpcionMenuAdmin, Rol, Usuario } from '../../data/models/seguridad';
import { EmpleadoService } from '../../data/services/personal.service';
import {
  OpcionMenuService,
  RolService,
  UsuarioService,
} from '../../data/services/seguridad.service';
import { CrudConfig, opcionesDe } from '../../shared/crud/crud';
import { CrudPagina } from '../../shared/crud/crud-pagina';
import { anchoFormulario, FormularioDialogo } from '../../shared/formulario/formulario-dialogo';
import { PermisosDialogo } from './permisos-dialogo';

@Component({
  selector: 'app-usuarios',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Usuarios {
  private readonly dialog = inject(MatDialog);
  private readonly servicio = inject(UsuarioService);

  protected readonly config: CrudConfig<Usuario> = {
    titulo: 'Usuarios',
    descripcion: 'Cuentas de acceso al sistema',
    singular: 'usuario',
    ruta: '/seguridad/usuarios',
    servicio: this.servicio,
    id: 'idUsuario',
    etiqueta: (u) => u.username,
    tonoEstado: (estado) => (estado === 'Activo' ? 'exito' : estado === 'Bloqueado' ? 'aviso' : 'inactivo'),
    columnas: [
      { campo: 'username', titulo: 'Usuario' },
      { campo: 'empleado', titulo: 'Empleado' },
      { campo: 'rol', titulo: 'Rol' },
      { campo: 'ultimoAcceso', titulo: 'Último acceso', tipo: 'fechaHora' },
      { campo: 'intentosFallidos', titulo: 'Intentos fallidos', tipo: 'numero' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [
      {
        nombre: 'idEmpleado',
        etiqueta: 'Empleado',
        tipo: 'select',
        requerido: true,
        soloCrear: true,
        completo: true,
        opciones: opcionesDe(inject(EmpleadoService), 'idEmpleado', (e) => `${e.nombres} ${e.apellidos}`),
      },
      { nombre: 'username', etiqueta: 'Usuario', requerido: true, largoMin: 4, largoMax: 30 },
      {
        nombre: 'idRol',
        etiqueta: 'Rol',
        tipo: 'select',
        requerido: true,
        opciones: opcionesDe(inject(RolService), 'idRol', (r) => r.nombre),
      },
      {
        nombre: 'password',
        etiqueta: 'Contraseña',
        tipo: 'password',
        requerido: true,
        soloCrear: true,
        largoMin: 6,
        largoMax: 72,
        completo: true,
      },
    ],
    acciones: [
      {
        icono: 'lock_reset',
        texto: 'Restablecer contraseña',
        permiso: 'puedeEditar',
        ejecutar: (usuario, recargar) => this.restablecer(usuario, recargar),
      },
    ],
  };

  private restablecer(usuario: Usuario, recargar: () => void) {
    const campos = [
      {
        nombre: 'password',
        etiqueta: 'Nueva contraseña',
        tipo: 'password' as const,
        requerido: true,
        largoMin: 6,
        largoMax: 72,
      },
    ];
    this.dialog
      .open(FormularioDialogo, {
        width: anchoFormulario(campos),
        data: {
          titulo: `Restablecer contraseña de ${usuario.username}`,
          campos,
          guardar: (valores: Record<string, unknown>) =>
            this.servicio.restablecerPassword(usuario.idUsuario, valores),
          mensajeExito: 'Contraseña restablecida',
        },
      })
      .afterClosed()
      .subscribe((guardado) => guardado && recargar());
  }
}

@Component({
  selector: 'app-roles',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class Roles {
  private readonly dialog = inject(MatDialog);
  private readonly menu = inject(MenuService);

  protected readonly config: CrudConfig<Rol> = {
    titulo: 'Roles',
    descripcion: 'Perfiles de acceso y sus permisos',
    singular: 'rol',
    ruta: '/seguridad/roles',
    servicio: inject(RolService),
    id: 'idRol',
    columnas: [
      { campo: 'idRol', titulo: 'Código', clase: 'col-codigo' },
      { campo: 'nombre', titulo: 'Nombre' },
      { campo: 'descripcion', titulo: 'Descripción' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [
      { nombre: 'nombre', etiqueta: 'Nombre', requerido: true, largoMax: 50 },
      { nombre: 'descripcion', etiqueta: 'Descripción', tipo: 'area', largoMax: 200 },
    ],
    acciones: [
      {
        icono: 'admin_panel_settings',
        texto: 'Permisos',
        permiso: 'puedeEditar',
        ejecutar: (rol) =>
          this.dialog
            .open(PermisosDialogo, { data: rol, width: '760px' })
            .afterClosed()
            .subscribe(() => this.menu.cargar()),
      },
    ],
  };
}

@Component({
  selector: 'app-opciones-menu',
  imports: [CrudPagina],
  template: '<app-crud-pagina [config]="config" />',
})
export class OpcionesMenu {
  private readonly servicio = inject(OpcionMenuService);

  protected readonly config: CrudConfig<OpcionMenuAdmin> = {
    titulo: 'Opciones de menú',
    descripcion: 'Estructura del menú lateral del sistema',
    singular: 'opción de menú',
    femenino: true,
    ruta: '/seguridad/menu',
    servicio: this.servicio,
    id: 'idOpcion',
    columnas: [
      { campo: 'nombre', titulo: 'Nombre' },
      { campo: 'padre', titulo: 'Grupo' },
      { campo: 'ruta', titulo: 'Ruta' },
      { campo: 'icono', titulo: 'Ícono' },
      { campo: 'orden', titulo: 'Orden', tipo: 'numero' },
      { campo: 'estado', titulo: 'Estado', tipo: 'estado' },
    ],
    campos: [
      { nombre: 'nombre', etiqueta: 'Nombre', requerido: true, largoMax: 60 },
      {
        nombre: 'idOpcionPadre',
        etiqueta: 'Grupo',
        tipo: 'select',
        opciones: this.servicio.listar().pipe(
          map((opciones) =>
            opciones
              .filter((o) => !o.ruta)
              .map((o) => ({ valor: o.idOpcion, texto: o.nombre, activo: o.estado === 'Activo' })),
          ),
        ),
      },
      { nombre: 'ruta', etiqueta: 'Ruta', largoMax: 100, pista: 'Vacío si es un grupo' },
      { nombre: 'icono', etiqueta: 'Ícono', largoMax: 50, pista: 'Nombre de Material Icons' },
      { nombre: 'orden', etiqueta: 'Orden', tipo: 'numero', requerido: true, min: 0 },
    ],
  };
}
