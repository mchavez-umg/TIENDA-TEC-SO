package com.mdchavez.tienda.tienda_be.inventario;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
public class InventarioService {

    private final JdbcTemplate jdbc;

    public InventarioService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<Existencia> existencias(Long idSucursal, boolean soloBajoMinimo) {
        List<Object> p = new ArrayList<>();
        StringBuilder where = new StringBuilder();
        if (idSucursal != null) {
            where.append(where.isEmpty() ? " WHERE " : " AND ").append("ID_SUCURSAL = ?");
            p.add(idSucursal);
        }
        if (soloBajoMinimo) {
            where.append(where.isEmpty() ? " WHERE " : " AND ").append("BAJO_MINIMO = 'S'");
        }
        String sql = """
                SELECT ID_SUCURSAL, SUCURSAL, CATEGORIA, ID_PRODUCTO, CODIGO_PRODUCTO, PRODUCTO,
                       EXISTENCIA, STOCK_MINIMO, BAJO_MINIMO, FECHA_ACTUALIZACION
                FROM V_EXISTENCIAS""" + where + " ORDER BY SUCURSAL, PRODUCTO";
        return jdbc.query(sql, (rs, n) -> new Existencia(rs.getLong("ID_SUCURSAL"), rs.getString("SUCURSAL"),
                rs.getString("CATEGORIA"), rs.getLong("ID_PRODUCTO"), rs.getString("CODIGO_PRODUCTO"),
                rs.getString("PRODUCTO"), rs.getInt("EXISTENCIA"), rs.getInt("STOCK_MINIMO"),
                rs.getString("BAJO_MINIMO"), rs.getObject("FECHA_ACTUALIZACION", java.time.LocalDateTime.class)),
                p.toArray());
    }

    public List<KardexMovimiento> kardex(Long idSucursal, Long idProducto, LocalDate desde, LocalDate hasta) {
        List<Object> p = new ArrayList<>();
        StringBuilder where = new StringBuilder();
        agregar(where, "ID_SUCURSAL = ?", idSucursal, p);
        agregar(where, "ID_PRODUCTO = ?", idProducto, p);
        if (desde != null) {
            where.append(where.isEmpty() ? " WHERE " : " AND ").append("FECHA >= ?");
            p.add(desde);
        }
        if (hasta != null) {
            where.append(where.isEmpty() ? " WHERE " : " AND ").append("FECHA < ?");
            p.add(hasta.plusDays(1));
        }
        String sql = """
                SELECT ID_KARDEX, FECHA, SUCURSAL, CODIGO_PRODUCTO, PRODUCTO, TIPO_MOVIMIENTO, CANTIDAD,
                       EXISTENCIA_ANTERIOR, EXISTENCIA_NUEVA, DOCUMENTO_ORIGEN, ID_DOCUMENTO, CREADO_POR
                FROM V_KARDEX""" + where + " ORDER BY FECHA DESC, ID_KARDEX DESC";
        return jdbc.query(sql, (rs, n) -> new KardexMovimiento(rs.getLong("ID_KARDEX"),
                rs.getObject("FECHA", java.time.LocalDateTime.class), rs.getString("SUCURSAL"),
                rs.getString("CODIGO_PRODUCTO"), rs.getString("PRODUCTO"), rs.getString("TIPO_MOVIMIENTO"),
                rs.getInt("CANTIDAD"), rs.getInt("EXISTENCIA_ANTERIOR"), rs.getInt("EXISTENCIA_NUEVA"),
                rs.getString("DOCUMENTO_ORIGEN"), rs.getObject("ID_DOCUMENTO", Long.class),
                rs.getString("CREADO_POR")), p.toArray());
    }

    private static void agregar(StringBuilder where, String condicion, Object valor, List<Object> params) {
        if (valor != null) {
            where.append(where.isEmpty() ? " WHERE " : " AND ").append(condicion);
            params.add(valor);
        }
    }

    public record Existencia(long idSucursal, String sucursal, String categoria, long idProducto,
                             String codigoProducto, String producto, int existencia, int stockMinimo,
                             String bajoMinimo, java.time.LocalDateTime fechaActualizacion) {
    }

    public record KardexMovimiento(long idKardex, java.time.LocalDateTime fecha, String sucursal,
                                   String codigoProducto, String producto, String tipoMovimiento, int cantidad,
                                   int existenciaAnterior, int existenciaNueva, String documentoOrigen,
                                   Long idDocumento, String creadoPor) {
    }
}
