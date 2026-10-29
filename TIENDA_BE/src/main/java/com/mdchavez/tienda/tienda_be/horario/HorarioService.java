package com.mdchavez.tienda.tienda_be.horario;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class HorarioService {

    private static final String SELECT = """
            SELECT H.ID_HORARIO, H.NOMBRE, H.HORA_ENTRADA, H.HORA_SALIDA, H.DIAS_SEMANA, E.NOMBRE AS ESTADO
            FROM HORARIO H
            JOIN ESTADO E ON E.ID_ESTADO = H.ID_ESTADO
            """;

    private static final RowMapper<HorarioResponse> MAPPER = (rs, n) -> new HorarioResponse(
            rs.getLong("ID_HORARIO"), rs.getString("NOMBRE"), rs.getString("HORA_ENTRADA"),
            rs.getString("HORA_SALIDA"), rs.getString("DIAS_SEMANA"), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public HorarioService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<HorarioResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY H.NOMBRE", MAPPER);
    }

    public HorarioResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE H.ID_HORARIO = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Horario no encontrado");
        }
    }

    public HorarioResponse crear(HorarioRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_HORARIO.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("""
                INSERT INTO HORARIO (ID_HORARIO, NOMBRE, HORA_ENTRADA, HORA_SALIDA, DIAS_SEMANA, ID_ESTADO)
                VALUES (?, ?, ?, ?, ?, FN_ID_ESTADO('HORARIO', 'A'))
                """, id, req.nombre(), req.horaEntrada(), req.horaSalida(), req.diasSemana());
        return obtener(id);
    }

    public HorarioResponse actualizar(long id, HorarioRequest req) {
        int filas = jdbc.update("""
                UPDATE HORARIO SET NOMBRE = ?, HORA_ENTRADA = ?, HORA_SALIDA = ?, DIAS_SEMANA = ? WHERE ID_HORARIO = ?
                """, req.nombre(), req.horaEntrada(), req.horaSalida(), req.diasSemana(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Horario no encontrado");
        }
        return obtener(id);
    }

    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE HORARIO SET ID_ESTADO = FN_ID_ESTADO('HORARIO', 'I') WHERE ID_HORARIO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Horario no encontrado");
        }
    }

    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE HORARIO SET ID_ESTADO = FN_ID_ESTADO('HORARIO', 'A') WHERE ID_HORARIO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Horario no encontrado");
        }
    }

    public record HorarioResponse(long idHorario, String nombre, String horaEntrada, String horaSalida,
                                  String diasSemana, String estado) {
    }
}
