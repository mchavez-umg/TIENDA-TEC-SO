package com.mdchavez.tienda.tienda_be.producto;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;

@Service
public class ProductoService {

    private static final String SELECT = """
            SELECT P.ID_PRODUCTO, P.ID_CATEGORIA, C.NOMBRE AS CATEGORIA, P.ID_MARCA, M.NOMBRE AS MARCA,
                   P.CODIGO, P.NOMBRE, P.DESCRIPCION, P.PRECIO_COSTO, P.PRECIO_VENTA, P.MESES_GARANTIA,
                   E.NOMBRE AS ESTADO
            FROM PRODUCTO P
            JOIN CATEGORIA C ON C.ID_CATEGORIA = P.ID_CATEGORIA
            JOIN MARCA M ON M.ID_MARCA = P.ID_MARCA
            JOIN ESTADO E ON E.ID_ESTADO = P.ID_ESTADO
            """;

    private static final RowMapper<ProductoResponse> MAPPER = (rs, n) -> new ProductoResponse(
            rs.getLong("ID_PRODUCTO"), rs.getLong("ID_CATEGORIA"), rs.getString("CATEGORIA"),
            rs.getLong("ID_MARCA"), rs.getString("MARCA"), rs.getString("CODIGO"), rs.getString("NOMBRE"),
            rs.getString("DESCRIPCION"), rs.getBigDecimal("PRECIO_COSTO"), rs.getBigDecimal("PRECIO_VENTA"),
            rs.getInt("MESES_GARANTIA"), rs.getString("ESTADO"));

    private final JdbcTemplate jdbc;

    public ProductoService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<ProductoResponse> listar() {
        return jdbc.query(SELECT + " ORDER BY P.CODIGO", MAPPER);
    }

    public ProductoResponse obtener(long id) {
        try {
            return jdbc.queryForObject(SELECT + " WHERE P.ID_PRODUCTO = ?", MAPPER, id);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Producto no encontrado");
        }
    }

    public ProductoResponse crear(ProductoRequest req) {
        long id = jdbc.queryForObject("SELECT SEQ_PRODUCTO.NEXTVAL FROM DUAL", Long.class);
        jdbc.update("""
                INSERT INTO PRODUCTO (ID_PRODUCTO, ID_CATEGORIA, ID_MARCA, CODIGO, NOMBRE, DESCRIPCION,
                                      PRECIO_COSTO, PRECIO_VENTA, MESES_GARANTIA, ID_ESTADO)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, FN_ID_ESTADO('PRODUCTO', 'A'))
                """, id, req.idCategoria(), req.idMarca(), req.codigo(), req.nombre(), req.descripcion(),
                req.precioCosto(), req.precioVenta(), req.mesesGarantia());
        return obtener(id);
    }

    public ProductoResponse actualizar(long id, ProductoRequest req) {
        int filas = jdbc.update("""
                UPDATE PRODUCTO
                SET ID_CATEGORIA = ?, ID_MARCA = ?, CODIGO = ?, NOMBRE = ?, DESCRIPCION = ?,
                    PRECIO_COSTO = ?, PRECIO_VENTA = ?, MESES_GARANTIA = ?
                WHERE ID_PRODUCTO = ?
                """, req.idCategoria(), req.idMarca(), req.codigo(), req.nombre(), req.descripcion(),
                req.precioCosto(), req.precioVenta(), req.mesesGarantia(), id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Producto no encontrado");
        }
        return obtener(id);
    }

    public void desactivar(long id) {
        int filas = jdbc.update(
                "UPDATE PRODUCTO SET ID_ESTADO = FN_ID_ESTADO('PRODUCTO', 'I') WHERE ID_PRODUCTO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Producto no encontrado");
        }
    }

    public void activar(long id) {
        int filas = jdbc.update(
                "UPDATE PRODUCTO SET ID_ESTADO = FN_ID_ESTADO('PRODUCTO', 'A') WHERE ID_PRODUCTO = ?", id);
        if (filas == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Producto no encontrado");
        }
    }

    public record ProductoResponse(long idProducto, long idCategoria, String categoria, long idMarca, String marca,
                                   String codigo, String nombre, String descripcion, BigDecimal precioCosto,
                                   BigDecimal precioVenta, int mesesGarantia, String estado) {
    }
}
