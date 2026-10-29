package com.mdchavez.tienda.tienda_be.departamento;

import com.mdchavez.tienda.tienda_be.comun.ConfiguracionCache;
import com.mdchavez.tienda.tienda_be.comun.InvalidarCache;
import org.springframework.cache.annotation.CacheConfig;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.io.Serializable;
import java.util.List;

// El nombre del departamento tambien aparece en el listado de municipios
@Service
@CacheConfig(cacheNames = {ConfiguracionCache.DEPARTAMENTOS, ConfiguracionCache.MUNICIPIOS})
public class DepartamentoService {

    private static final String SELECT = """
            SELECT D.ID_DEPARTAMENTO, D.NOMBRE, E.NOMBRE AS ESTADO
            FROM DEPARTAMENTO D
            JOIN ESTADO E ON E.ID_ESTADO = D.ID_ESTADO
            """;

    private static final RowMapper<DepartamentoResponse> MAPPER = (rs, n) -> new DepartamentoResponse(
            rs.getLong("ID_DEPARTAMENTO"), rs.getString("NOMBRE"), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public DepartamentoService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Cacheable(ConfiguracionCache.DEPARTAMENTOS)
    public List<DepartamentoResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY D.NOMBRE", MAPPER);
    }

    public DepartamentoResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE D.ID_DEPARTAMENTO = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Departamento no encontrado");
        }
    }

    @InvalidarCache
    public DepartamentoResponse crear(DepartamentoRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_DEPARTAMENTO.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("INSERT INTO DEPARTAMENTO (ID_DEPARTAMENTO, NOMBRE, ID_ESTADO) "
                + "VALUES (?, ?, FN_ID_ESTADO('DEPARTAMENTO', 'A'))", id, req.nombre());
        return obtener(id);
    }

    @InvalidarCache
    public DepartamentoResponse actualizar(long id, DepartamentoRequest req) {
        int filas = jdbc.update("UPDATE DEPARTAMENTO SET NOMBRE = ? WHERE ID_DEPARTAMENTO = ?", req.nombre(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Departamento no encontrado");
        }
        return obtener(id);
    }

    @InvalidarCache
    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE DEPARTAMENTO SET ID_ESTADO = FN_ID_ESTADO('DEPARTAMENTO', 'I') WHERE ID_DEPARTAMENTO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Departamento no encontrado");
        }
    }

    @InvalidarCache
    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE DEPARTAMENTO SET ID_ESTADO = FN_ID_ESTADO('DEPARTAMENTO', 'A') WHERE ID_DEPARTAMENTO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Departamento no encontrado");
        }
    }

    public record DepartamentoResponse(long idDepartamento, String nombre, String estado) implements Serializable {
    }
}
