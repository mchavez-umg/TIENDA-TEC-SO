import { Component, ElementRef, inject, signal } from '@angular/core';
import {
  AbstractControl,
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  ValidationErrors,
  ValidatorFn,
  Validators,
} from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { finalize, Observable } from 'rxjs';
import { Valores } from '../../data/services/crud.service';
import { Campo, Opcion } from '../crud/crud';
import { Notificacion } from '../notificacion.service';

export interface DatosFormulario {
  titulo: string;
  campos: Campo[];
  valores?: object | null;
  guardar: (valores: Valores) => Observable<unknown>;
  mensajeExito: string;
}

export function anchoFormulario(campos: Campo[]) {
  return campos.length > 3 ? '680px' : '440px';
}

@Component({
  selector: 'app-formulario-dialogo',
  imports: [
    ReactiveFormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatCheckboxModule,
    MatButtonModule,
  ],
  templateUrl: './formulario-dialogo.html',
})
export class FormularioDialogo {
  protected readonly datos = inject<DatosFormulario>(MAT_DIALOG_DATA);
  private readonly ref = inject(MatDialogRef<FormularioDialogo>);
  private readonly notificacion = inject(Notificacion);
  private readonly elemento = inject<ElementRef<HTMLElement>>(ElementRef);
  private readonly valores = (this.datos.valores ?? {}) as Valores;

  protected readonly campos = this.datos.campos.filter((c) => !(c.soloCrear && this.datos.valores));
  protected readonly unaColumna = this.campos.length <= 3;
  protected readonly guardando = signal(false);
  protected readonly opciones = signal<Record<string, Opcion[]>>({});
  protected readonly form = new FormGroup<Record<string, FormControl>>(
    Object.fromEntries(
      this.campos.map((c) => [c.nombre, new FormControl(valorInicial(c, this.valores[c.nombre]), validadores(c))]),
    ),
  );

  constructor() {
    this.form.valueChanges.subscribe(() => (this.ref.disableClose = this.form.dirty));
    for (const campo of this.campos) {
      campo.opciones?.subscribe({
        next: (opciones) => {
          const actual = this.form.controls[campo.nombre].value;
          this.opciones.update((o) => ({
            ...o,
            [campo.nombre]: opciones.filter((x) => x.activo || x.valor === actual),
          }));
        },
        error: (error) => this.notificacion.error(error),
      });
    }
  }

  protected tipoInput(campo: Campo) {
    return { fecha: 'date', hora: 'time', correo: 'email', password: 'password' }[campo.tipo as string] ?? 'text';
  }

  protected error(campo: Campo) {
    const errores = this.form.controls[campo.nombre].errors ?? {};
    if (errores['required']) return 'Campo obligatorio';
    if (errores['email']) return 'Correo no válido';
    if (errores['min']) return `El mínimo es ${campo.min}`;
    if (errores['max']) return `El máximo es ${campo.max}`;
    if (errores['minlength']) return `Debe tener al menos ${campo.largoMin} caracteres`;
    if (errores['maxlength']) return `Máximo ${campo.largoMax} caracteres`;
    if (errores['pattern']) return campo.mensajePatron ?? 'Formato no válido';
    return '';
  }

  protected guardar() {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      this.elemento.nativeElement
        .querySelector<HTMLElement>('input.ng-invalid, textarea.ng-invalid, mat-select.ng-invalid')
        ?.focus();
      return;
    }
    this.guardando.set(true);
    this.datos
      .guardar(valoresAEnviar(this.campos, this.form.getRawValue()))
      .pipe(finalize(() => this.guardando.set(false)))
      .subscribe({
        next: (resultado) => {
          this.notificacion.exito(this.datos.mensajeExito);
          this.ref.close(resultado ?? true);
        },
        error: (error) => this.notificacion.error(error),
      });
  }
}

export function valorInicial(campo: Campo, valor: unknown) {
  if (campo.tipo === 'sino') return valor === 'S';
  return valor ?? (['select', 'numero', 'moneda'].includes(campo.tipo ?? '') ? null : '');
}

function requerido(control: AbstractControl): ValidationErrors | null {
  const valor = control.value;
  return valor == null || (typeof valor === 'string' && valor.trim() === '') ? { required: true } : null;
}

function validadores(campo: Campo) {
  const lista: ValidatorFn[] = [];
  if (campo.requerido) lista.push(Validators.required, requerido);
  if (campo.tipo === 'correo') lista.push(Validators.email);
  if (campo.min != null) lista.push(Validators.min(campo.min));
  if (campo.max != null) lista.push(Validators.max(campo.max));
  if (campo.largoMin) lista.push(Validators.minLength(campo.largoMin));
  if (campo.largoMax) lista.push(Validators.maxLength(campo.largoMax));
  if (campo.patron) lista.push(Validators.pattern(campo.patron));
  return lista;
}

export function valoresAEnviar(campos: Campo[], valores: Valores): Valores {
  return Object.fromEntries(
    campos.map((c) => {
      const valor = valores[c.nombre];
      if (c.tipo === 'sino') return [c.nombre, valor ? 'S' : 'N'];
      if (typeof valor === 'string') return [c.nombre, valor.trim() || null];
      return [c.nombre, valor];
    }),
  );
}
