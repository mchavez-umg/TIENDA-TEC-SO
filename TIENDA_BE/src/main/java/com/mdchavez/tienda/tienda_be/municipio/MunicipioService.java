package com.mdchavez.tienda.tienda_be.municipio;

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

@Service
@CacheConfig(cacheNames = ConfiguracionCache.MUNICIPIOS)
public class MunicipioService {

    private static final String SELECT = """
            SELECT M.ID_MUNICIPIO, M.ID_DEPARTAMENTO, D.NOMBRE AS DEPARTAMENTO, M.NOMBRE, M.ES_CABECERA,
                   E.NOMBRE AS ESTADO
            FROM MUNICIPIO M
            JOIN DEPARTAMENTO D ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
            JOIN ESTADO E ON E.ID_ESTADO = M.ID_ESTADO
            """;

    private static final RowMapper<MunicipioResponse> MAPPER = (rs, n) -> new MunicipioResponse(
            rs.getLong("ID_MUNICIPIO"), rs.getLong("ID_DEPARTAMENTO"), rs.getString("DEPARTAMENTO"),
            rs.getString("NOMBRE"), rs.getString("ES_CABECERA"), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public MunicipioService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Cacheable(cacheNames = ConfiguracionCache.MUNICIPIOS, key = "#idDepartamento ?: 'todos'")
    public List<MunicipioResponse> listar(Long idDepartamento) {
        if (idDepartamento != null) {
            return jdbc.query(SELECT + " WHERE M.ID_DEPARTAMENTO = ? ORDER BY M.NOMBRE", MAPPER, idDepartamento);
        }
        return jdbc.query(SELECT + " ORDER BY D.NOMBRE, M.NOMBRE", MAPPER);
    }

    public MunicipioResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE M.ID_MUNICIPIO = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Municipio no encontrado");
        }
    }

    @InvalidarCache
    public MunicipioResponse crear(MunicipioRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_MUNICIPIO.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("""
                INSERT INTO MUNICIPIO (ID_MUNICIPIO, ID_DEPARTAMENTO, NOMBRE, ES_CABECERA, ID_ESTADO)
                VALUES (?, ?, ?, ?, FN_ID_ESTADO('MUNICIPIO', 'A'))
                """, id, req.idDepartamento(), req.nombre(), cabecera(req));
        return obtener(id);
    }

    @InvalidarCache
    public MunicipioResponse actualizar(long id, MunicipioRequest req) {
        int filas = jdbc.update("""
                UPDATE MUNICIPIO SET ID_DEPARTAMENTO = ?, NOMBRE = ?, ES_CABECERA = ? WHERE ID_MUNICIPIO = ?
                """, req.idDepartamento(), req.nombre(), cabecera(req), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Municipio no encontrado");
        }
        return obtener(id);
    }

    @InvalidarCache
    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE MUNICIPIO SET ID_ESTADO = FN_ID_ESTADO('MUNICIPIO', 'I') WHERE ID_MUNICIPIO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Municipio no encontrado");
        }
    }

    @InvalidarCache
    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE MUNICIPIO SET ID_ESTADO = FN_ID_ESTADO('MUNICIPIO', 'A') WHERE ID_MUNICIPIO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Municipio no encontrado");
        }
    }

    private static String cabecera(MunicipioRequest req) {
        return req.esCabecera() != null ? req.esCabecera() : "N";
    }

    public record MunicipioResponse(long idMunicipio, long idDepartamento, String departamento, String nombre,
                                    String esCabecera, String estado) implements Serializable {
    }
}
