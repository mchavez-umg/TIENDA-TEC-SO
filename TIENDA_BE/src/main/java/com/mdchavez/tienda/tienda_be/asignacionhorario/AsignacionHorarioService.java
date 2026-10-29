package com.mdchavez.tienda.tienda_be.asignacionhorario;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.util.List;

@Service
public class AsignacionHorarioService {

    private static final String SELECT = """
            SELECT EH.ID_EMPLEADO_HORARIO, EH.ID_EMPLEADO, E.NOMBRES || ' ' || E.APELLIDOS AS EMPLEADO,
                   EH.ID_HORARIO, H.NOMBRE AS HORARIO, EH.FECHA_INICIO, EH.FECHA_FIN, ES.NOMBRE AS ESTADO
            FROM EMPLEADO_HORARIO EH
            JOIN EMPLEADO E ON E.ID_EMPLEADO = EH.ID_EMPLEADO
            JOIN HORARIO H ON H.ID_HORARIO = EH.ID_HORARIO
            JOIN ESTADO ES ON ES.ID_ESTADO = EH.ID_ESTADO
            """;

    private static final RowMapper<AsignacionResponse> MAPPER = (rs, n) -> new AsignacionResponse(
            rs.getLong("ID_EMPLEADO_HORARIO"), rs.getLong("ID_EMPLEADO"), rs.getString("EMPLEADO"),
            rs.getLong("ID_HORARIO"), rs.getString("HORARIO"), rs.getObject("FECHA_INICIO", LocalDate.class),
            rs.getObject("FECHA_FIN", LocalDate.class), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public AsignacionHorarioService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<AsignacionResponse> listar(Long idEmpleado) {
        if (idEmpleado != null) {
            return jdbc.query(SELECT + " WHERE EH.ID_EMPLEADO = ? ORDER BY EH.FECHA_INICIO DESC", MAPPER, idEmpleado);
        }
        return jdbc.query(SELECT + " ORDER BY EH.FECHA_INICIO DESC, EH.ID_EMPLEADO_HORARIO DESC", MAPPER);
    }

    public AsignacionResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE EH.ID_EMPLEADO_HORARIO = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Asignación no encontrada");
        }
    }

    public AsignacionResponse crear(AsignacionHorarioRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_EMPLEADO_HORARIO.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("""
                INSERT INTO EMPLEADO_HORARIO (ID_EMPLEADO_HORARIO, ID_EMPLEADO, ID_HORARIO, FECHA_INICIO, FECHA_FIN,
                                              ID_ESTADO)
                VALUES (?, ?, ?, ?, ?, FN_ID_ESTADO('EMPLEADO_HORARIO', 'A'))
                """, id, req.idEmpleado(), req.idHorario(), req.fechaInicio(), req.fechaFin());
        return obtener(id);
    }

    public AsignacionResponse actualizar(long id, AsignacionHorarioRequest req) {
        int filas = jdbc.update("""
                UPDATE EMPLEADO_HORARIO
                SET ID_EMPLEADO = ?, ID_HORARIO = ?, FECHA_INICIO = ?, FECHA_FIN = ?
                WHERE ID_EMPLEADO_HORARIO = ?
                """, req.idEmpleado(), req.idHorario(), req.fechaInicio(), req.fechaFin(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Asignación no encontrada");
        }
        return obtener(id);
    }

    public void desactivar(long id) {
        int filas = jdbc.update("UPDATE EMPLEADO_HORARIO SET ID_ESTADO = FN_ID_ESTADO('EMPLEADO_HORARIO', 'I') "
                + "WHERE ID_EMPLEADO_HORARIO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Asignación no encontrada");
        }
    }

    public void activar(long id) {
        int filas = jdbc.update("UPDATE EMPLEADO_HORARIO SET ID_ESTADO = FN_ID_ESTADO('EMPLEADO_HORARIO', 'A') "
                + "WHERE ID_EMPLEADO_HORARIO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Asignación no encontrada");
        }
    }

    public record AsignacionResponse(long idEmpleadoHorario, long idEmpleado, String empleado, long idHorario,
                                     String horario, LocalDate fechaInicio, LocalDate fechaFin, String estado) {
    }
}
