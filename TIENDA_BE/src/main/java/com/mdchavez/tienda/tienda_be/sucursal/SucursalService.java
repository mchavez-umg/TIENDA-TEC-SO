package com.mdchavez.tienda.tienda_be.sucursal;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.util.List;

@Service
public class SucursalService {

    private static final String SELECT = """
            SELECT S.ID_SUCURSAL, S.ID_MUNICIPIO, M.NOMBRE AS MUNICIPIO, S.CODIGO, S.NOMBRE, S.DIRECCION,
                   S.TELEFONO, S.CORREO, S.FECHA_APERTURA, E.NOMBRE AS ESTADO
            FROM SUCURSAL S
            JOIN MUNICIPIO M ON M.ID_MUNICIPIO = S.ID_MUNICIPIO
            JOIN ESTADO E ON E.ID_ESTADO = S.ID_ESTADO
            """;

    private static final RowMapper<SucursalResponse> MAPPER = (rs, n) -> new SucursalResponse(
            rs.getLong("ID_SUCURSAL"), rs.getLong("ID_MUNICIPIO"), rs.getString("MUNICIPIO"), rs.getString("CODIGO"),
            rs.getString("NOMBRE"), rs.getString("DIRECCION"), rs.getString("TELEFONO"), rs.getString("CORREO"),
            rs.getObject("FECHA_APERTURA", LocalDate.class), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public SucursalService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<SucursalResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY S.CODIGO", MAPPER);
    }

    public SucursalResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE S.ID_SUCURSAL = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Sucursal no encontrada");
        }
    }

    public SucursalResponse crear(SucursalRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_SUCURSAL.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("""
                INSERT INTO SUCURSAL (ID_SUCURSAL, ID_MUNICIPIO, CODIGO, NOMBRE, DIRECCION, TELEFONO, CORREO,
                                      FECHA_APERTURA, ID_ESTADO)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, FN_ID_ESTADO('SUCURSAL', 'A'))
                """, id, req.idMunicipio(), req.codigo(), req.nombre(), req.direccion(), req.telefono(),
                req.correo(), req.fechaApertura());
        return obtener(id);
    }

    public SucursalResponse actualizar(long id, SucursalRequest req) {
        int filas = jdbc.update("""
                UPDATE SUCURSAL
                SET ID_MUNICIPIO = ?, CODIGO = ?, NOMBRE = ?, DIRECCION = ?, TELEFONO = ?, CORREO = ?,
                    FECHA_APERTURA = ?
                WHERE ID_SUCURSAL = ?
                """, req.idMunicipio(), req.codigo(), req.nombre(), req.direccion(), req.telefono(),
                req.correo(), req.fechaApertura(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Sucursal no encontrada");
        }
        return obtener(id);
    }

    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE SUCURSAL SET ID_ESTADO = FN_ID_ESTADO('SUCURSAL', 'I') WHERE ID_SUCURSAL = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Sucursal no encontrada");
        }
    }

    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE SUCURSAL SET ID_ESTADO = FN_ID_ESTADO('SUCURSAL', 'A') WHERE ID_SUCURSAL = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Sucursal no encontrada");
        }
    }

    public record SucursalResponse(long idSucursal, long idMunicipio, String municipio, String codigo, String nombre,
                                   String direccion, String telefono, String correo, LocalDate fechaApertura,
                                   String estado) {
    }
}
