export interface LoginRequest {
  username: string;
  password: string;
}

export interface Sesion {
  token: string;
  idUsuario: number;
  username: string;
  rol: string;
}
