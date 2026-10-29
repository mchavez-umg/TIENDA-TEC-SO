package com.mdchavez.tienda.tienda_be.empleado;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.util.List;

@Service
public class EmpleadoService {

    private static final String SELECT = """
            SELECT E.ID_EMPLEADO, E.ID_SUCURSAL, S.NOMBRE AS SUCURSAL, E.ID_PUESTO, P.NOMBRE AS PUESTO,
                   E.DPI, E.NOMBRES, E.APELLIDOS, E.TELEFONO, E.CORREO, E.DIRECCION, E.FECHA_INGRESO,
                   ES.NOMBRE AS ESTADO
            FROM EMPLEADO E
            JOIN SUCURSAL S ON S.ID_SUCURSAL = E.ID_SUCURSAL
            JOIN PUESTO P ON P.ID_PUESTO = E.ID_PUESTO
            JOIN ESTADO ES ON ES.ID_ESTADO = E.ID_ESTADO
            """;

    private static final RowMapper<EmpleadoResponse> MAPPER = (rs, n) -> new EmpleadoResponse(
            rs.getLong("ID_EMPLEADO"), rs.getLong("ID_SUCURSAL"), rs.getString("SUCURSAL"), rs.getLong("ID_PUESTO"),
            rs.getString("PUESTO"), rs.getString("DPI"), rs.getString("NOMBRES"), rs.getString("APELLIDOS"),
            rs.getString("TELEFONO"), rs.getString("CORREO"), rs.getString("DIRECCION"),
            rs.getObject("FECHA_INGRESO", LocalDate.class), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public EmpleadoService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<EmpleadoResponse> listar(Long idSucursal) {
        if (idSucursal != null) {
            return jdbc.query(SELECT + " WHERE E.ID_SUCURSAL = ? ORDER BY E.NOMBRES, E.APELLIDOS", MAPPER, idSucursal);
        }
        return jdbc.query(SELECT + " ORDER BY E.NOMBRES, E.APELLIDOS", MAPPER);
    }

    public EmpleadoResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE E.ID_EMPLEADO = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Empleado no encontrado");
        }
    }

    public EmpleadoResponse crear(EmpleadoRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_EMPLEADO.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("""
                INSERT INTO EMPLEADO (ID_EMPLEADO, ID_SUCURSAL, ID_PUESTO, DPI, NOMBRES, APELLIDOS, TELEFONO,
                                      CORREO, DIRECCION, FECHA_INGRESO, ID_ESTADO)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, FN_ID_ESTADO('EMPLEADO', 'A'))
                """, id, req.idSucursal(), req.idPuesto(), req.dpi(), req.nombres(), req.apellidos(),
                req.telefono(), req.correo(), req.direccion(), req.fechaIngreso());
        return obtener(id);
    }

    public EmpleadoResponse actualizar(long id, EmpleadoRequest req) {
        int filas = jdbc.update("""
                UPDATE EMPLEADO
                SET ID_SUCURSAL = ?, ID_PUESTO = ?, DPI = ?, NOMBRES = ?, APELLIDOS = ?, TELEFONO = ?,
                    CORREO = ?, DIRECCION = ?, FECHA_INGRESO = ?
                WHERE ID_EMPLEADO = ?
                """, req.idSucursal(), req.idPuesto(), req.dpi(), req.nombres(), req.apellidos(), req.telefono(),
                req.correo(), req.direccion(), req.fechaIngreso(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Empleado no encontrado");
        }
        return obtener(id);
    }

    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE EMPLEADO SET ID_ESTADO = FN_ID_ESTADO('EMPLEADO', 'I') WHERE ID_EMPLEADO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Empleado no encontrado");
        }
    }

    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE EMPLEADO SET ID_ESTADO = FN_ID_ESTADO('EMPLEADO', 'A') WHERE ID_EMPLEADO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Empleado no encontrado");
        }
    }

    public record EmpleadoResponse(long idEmpleado, long idSucursal, String sucursal, long idPuesto, String puesto,
                                   String dpi, String nombres, String apellidos, String telefono, String correo,
                                   String direccion, LocalDate fechaIngreso, String estado) {
    }
}
