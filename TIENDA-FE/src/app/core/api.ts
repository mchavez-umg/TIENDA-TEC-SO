// Ruta relativa: en produccion Nginx envia /api al backend (mismo dominio, sin CORS);
// en desarrollo ng serve la redirige a localhost:8080 mediante proxy.conf.json.
export const API_URL = '/api';
