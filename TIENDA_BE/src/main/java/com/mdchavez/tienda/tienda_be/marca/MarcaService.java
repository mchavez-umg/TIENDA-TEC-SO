package com.mdchavez.tienda.tienda_be.marca;

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
@CacheConfig(cacheNames = ConfiguracionCache.MARCAS)
public class MarcaService {

    private static final String SELECT = """
            SELECT M.ID_MARCA, M.NOMBRE, E.NOMBRE AS ESTADO
            FROM MARCA M
            JOIN ESTADO E ON E.ID_ESTADO = M.ID_ESTADO
            """;

    private static final RowMapper<MarcaResponse> MAPPER = (rs, n) -> new MarcaResponse(
            rs.getLong("ID_MARCA"), rs.getString("NOMBRE"), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public MarcaService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Cacheable(ConfiguracionCache.MARCAS)
    public List<MarcaResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY M.NOMBRE", MAPPER);
    }

    public MarcaResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE M.ID_MARCA = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Marca no encontrada");
        }
    }

    @InvalidarCache
    public MarcaResponse crear(MarcaRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_MARCA.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("INSERT INTO MARCA (ID_MARCA, NOMBRE, ID_ESTADO) VALUES (?, ?, FN_ID_ESTADO('MARCA', 'A'))",
                id, req.nombre());
        return obtener(id);
    }

    @InvalidarCache
    public MarcaResponse actualizar(long id, MarcaRequest req) {
        int filas = jdbc.update("UPDATE MARCA SET NOMBRE = ? WHERE ID_MARCA = ?", req.nombre(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Marca no encontrada");
        }
        return obtener(id);
    }

    @InvalidarCache
    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE MARCA SET ID_ESTADO = FN_ID_ESTADO('MARCA', 'I') WHERE ID_MARCA = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Marca no encontrada");
        }
    }

    @InvalidarCache
    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE MARCA SET ID_ESTADO = FN_ID_ESTADO('MARCA', 'A') WHERE ID_MARCA = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Marca no encontrada");
        }
    }

    public record MarcaResponse(long idMarca, String nombre, String estado) implements Serializable {
    }
}
