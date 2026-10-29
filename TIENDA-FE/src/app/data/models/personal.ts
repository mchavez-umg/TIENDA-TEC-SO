export interface Puesto {
  idPuesto: number;
  nombre: string;
  descripcion: string | null;
  salarioBase: number;
  estado: string;
}

export interface Empleado {
  idEmpleado: number;
  idSucursal: number;
  sucursal: string;
  idPuesto: number;
  puesto: string;
  dpi: string;
  nombres: string;
  apellidos: string;
  telefono: string | null;
  correo: string | null;
  direccion: string | null;
  fechaIngreso: string;
  estado: string;
}

export interface Horario {
  idHorario: number;
  nombre: string;
  horaEntrada: string;
  horaSalida: string;
  diasSemana: string;
  estado: string;
}

export interface AsignacionHorario {
  idEmpleadoHorario: number;
  idEmpleado: number;
  empleado: string;
  idHorario: number;
  horario: string;
  fechaInicio: string;
  fechaFin: string | null;
  estado: string;
}
