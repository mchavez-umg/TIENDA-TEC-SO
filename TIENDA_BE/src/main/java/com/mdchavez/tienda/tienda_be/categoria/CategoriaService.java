package com.mdchavez.tienda.tienda_be.categoria;

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
@CacheConfig(cacheNames = ConfiguracionCache.CATEGORIAS)
public class CategoriaService {

    private static final String SELECT = """
            SELECT C.ID_CATEGORIA, C.NOMBRE, C.DESCRIPCION, E.NOMBRE AS ESTADO
            FROM CATEGORIA C
            JOIN ESTADO E ON E.ID_ESTADO = C.ID_ESTADO
            """;

    private static final RowMapper<CategoriaResponse> MAPPER = (rs, n) -> new CategoriaResponse(
            rs.getLong("ID_CATEGORIA"), rs.getString("NOMBRE"), rs.getString("DESCRIPCION"), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public CategoriaService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Cacheable(ConfiguracionCache.CATEGORIAS)
    public List<CategoriaResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY C.NOMBRE", MAPPER);
    }

    public CategoriaResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE C.ID_CATEGORIA = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Categoría no encontrada");
        }
    }

    @InvalidarCache
    public CategoriaResponse crear(CategoriaRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_CATEGORIA.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("""
                INSERT INTO CATEGORIA (ID_CATEGORIA, NOMBRE, DESCRIPCION, ID_ESTADO)
                VALUES (?, ?, ?, FN_ID_ESTADO('CATEGORIA', 'A'))
                """, id, req.nombre(), req.descripcion());
        return obtener(id);
    }

    @InvalidarCache
    public CategoriaResponse actualizar(long id, CategoriaRequest req) {
        int filas = jdbc.update("UPDATE CATEGORIA SET NOMBRE = ?, DESCRIPCION = ? WHERE ID_CATEGORIA = ?",
                req.nombre(), req.descripcion(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Categoría no encontrada");
        }
        return obtener(id);
    }

    @InvalidarCache
    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE CATEGORIA SET ID_ESTADO = FN_ID_ESTADO('CATEGORIA', 'I') WHERE ID_CATEGORIA = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Categoría no encontrada");
        }
    }

    @InvalidarCache
    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE CATEGORIA SET ID_ESTADO = FN_ID_ESTADO('CATEGORIA', 'A') WHERE ID_CATEGORIA = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Categoría no encontrada");
        }
    }

    public record CategoriaResponse(long idCategoria, String nombre, String descripcion, String estado) implements Serializable {
    }
}
