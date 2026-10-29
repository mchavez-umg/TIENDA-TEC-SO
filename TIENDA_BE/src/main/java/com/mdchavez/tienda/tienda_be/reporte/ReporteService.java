package com.mdchavez.tienda.tienda_be.reporte;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
public class ReporteService {

    private final JdbcTemplate jdbc;

    public ReporteService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Dashboard dashboard() {
        BigDecimal totalMes = jdbc.queryForObject(
                "SELECT NVL(SUM(TOTAL_VENDIDO), 0) FROM V_VENTAS_MENSUALES WHERE MES = TRUNC(SYSDATE, 'MM')",
                BigDecimal.class);
        long facturasMes = jdbc.queryForObject(
                "SELECT NVL(SUM(NUMERO_FACTURAS), 0) FROM V_VENTAS_MENSUALES WHERE MES = TRUNC(SYSDATE, 'MM')",
                Long.class);
        long bajoMinimo = jdbc.queryForObject(
                "SELECT COUNT(*) FROM V_EXISTENCIAS WHERE BAJO_MINIMO = 'S'", Long.class);
        long garantiasAbiertas = jdbc.queryForObject(
                "SELECT COUNT(*) FROM V_GARANTIA_DETALLE WHERE ESTADO NOT IN ('ENTREGADA', 'RECHAZADA')", Long.class);
        List<VentaPorSucursal> ventasMes = jdbc.query("""
                SELECT ID_SUCURSAL, SUCURSAL, NUMERO_FACTURAS, TOTAL_VENDIDO
                FROM V_VENTAS_MENSUALES
                WHERE MES = TRUNC(SYSDATE, 'MM')
                ORDER BY TOTAL_VENDIDO DESC
                """, (rs, n) -> new VentaPorSucursal(rs.getLong("ID_SUCURSAL"), rs.getString("SUCURSAL"),
                rs.getLong("NUMERO_FACTURAS"), rs.getBigDecimal("TOTAL_VENDIDO")));
        return new Dashboard(totalMes, facturasMes, bajoMinimo, garantiasAbiertas, ventasMes);
    }

    public List<VentaPorSucursal> ventasPorSucursal(LocalDate desde, LocalDate hasta) {
        List<Object> p = new ArrayList<>();
        String sql = "SELECT ID_SUCURSAL, SUCURSAL, SUM(NUMERO_FACTURAS) AS NUMERO_FACTURAS, "
                + "SUM(TOTAL_VENDIDO) AS TOTAL_VENDIDO FROM V_VENTAS_MENSUALES"
                + filtroFecha("MES", desde, hasta, p)
                + " GROUP BY ID_SUCURSAL, SUCURSAL ORDER BY TOTAL_VENDIDO DESC";
        return jdbc.query(sql, (rs, n) -> new VentaPorSucursal(rs.getLong("ID_SUCURSAL"), rs.getString("SUCURSAL"),
                rs.getLong("NUMERO_FACTURAS"), rs.getBigDecimal("TOTAL_VENDIDO")), p.toArray());
    }

    public List<VentaPorProducto> ventasPorProducto(LocalDate desde, LocalDate hasta) {
        List<Object> p = new ArrayList<>();
        String sql = "SELECT ID_PRODUCTO, CODIGO_PRODUCTO, PRODUCTO, SUM(CANTIDAD) AS CANTIDAD, "
                + "SUM(TOTAL_LINEA) AS TOTAL FROM V_VENTA_DETALLE"
                + filtroFecha("FECHA", desde, hasta, p)
                + " GROUP BY ID_PRODUCTO, CODIGO_PRODUCTO, PRODUCTO ORDER BY TOTAL DESC";
        return jdbc.query(sql, (rs, n) -> new VentaPorProducto(rs.getLong("ID_PRODUCTO"),
                rs.getString("CODIGO_PRODUCTO"), rs.getString("PRODUCTO"), rs.getLong("CANTIDAD"),
                rs.getBigDecimal("TOTAL")), p.toArray());
    }

    public List<VentaPorCategoria> ventasPorCategoria(LocalDate desde, LocalDate hasta) {
        List<Object> p = new ArrayList<>();
        String sql = "SELECT ID_CATEGORIA, CATEGORIA, SUM(CANTIDAD) AS CANTIDAD, SUM(TOTAL_LINEA) AS TOTAL "
                + "FROM V_VENTA_DETALLE"
                + filtroFecha("FECHA", desde, hasta, p)
                + " GROUP BY ID_CATEGORIA, CATEGORIA ORDER BY TOTAL DESC";
        return jdbc.query(sql, (rs, n) -> new VentaPorCategoria(rs.getLong("ID_CATEGORIA"), rs.getString("CATEGORIA"),
                rs.getLong("CANTIDAD"), rs.getBigDecimal("TOTAL")), p.toArray());
    }

    public List<VentaPorEmpleado> ventasPorEmpleado(LocalDate desde, LocalDate hasta) {
        List<Object> p = new ArrayList<>();
        String sql = "SELECT ID_EMPLEADO, EMPLEADO, COUNT(*) AS NUMERO_FACTURAS, SUM(TOTAL) AS TOTAL_VENDIDO "
                + "FROM V_FACTURA_RESUMEN WHERE ESTADO <> 'NC_TOTAL'"
                + filtroFecha("FECHA", desde, hasta, p).replaceFirst(" WHERE ", " AND ")
                + " GROUP BY ID_EMPLEADO, EMPLEADO ORDER BY TOTAL_VENDIDO DESC";
        return jdbc.query(sql, (rs, n) -> new VentaPorEmpleado(rs.getLong("ID_EMPLEADO"), rs.getString("EMPLEADO"),
                rs.getLong("NUMERO_FACTURAS"), rs.getBigDecimal("TOTAL_VENDIDO")), p.toArray());
    }

    public List<VentaPorFormaPago> ventasPorFormaPago(LocalDate desde, LocalDate hasta) {
        List<Object> p = new ArrayList<>();
        String sql = "SELECT ID_FORMA_PAGO, FORMA_PAGO, COUNT(*) AS NUMERO_PAGOS, SUM(MONTO) AS TOTAL "
                + "FROM V_VENTA_FORMA_PAGO"
                + filtroFecha("FECHA", desde, hasta, p)
                + " GROUP BY ID_FORMA_PAGO, FORMA_PAGO ORDER BY TOTAL DESC";
        return jdbc.query(sql, (rs, n) -> new VentaPorFormaPago(rs.getLong("ID_FORMA_PAGO"),
                rs.getString("FORMA_PAGO"), rs.getLong("NUMERO_PAGOS"), rs.getBigDecimal("TOTAL")), p.toArray());
    }

    public List<GarantiaPorEstado> garantiasPorEstado() {
        return jdbc.query("""
                SELECT ESTADO, NOMBRE_ESTADO, COUNT(*) AS CANTIDAD
                FROM V_GARANTIA_DETALLE
                GROUP BY ESTADO, NOMBRE_ESTADO
                ORDER BY CANTIDAD DESC
                """, (rs, n) -> new GarantiaPorEstado(rs.getString("ESTADO"), rs.getString("NOMBRE_ESTADO"),
                rs.getLong("CANTIDAD")));
    }

    public List<NotaCreditoEmitida> notasCreditoEmitidas(LocalDate desde, LocalDate hasta) {
        List<Object> p = new ArrayList<>();
        String sql = "SELECT ID_NOTA_CREDITO, SERIE, NUMERO, FECHA, SUCURSAL, EMPLEADO, MOTIVO, "
                + "SUM(MONTO) AS TOTAL FROM V_NOTA_CREDITO_DETALLE"
                + filtroFecha("FECHA", desde, hasta, p)
                + " GROUP BY ID_NOTA_CREDITO, SERIE, NUMERO, FECHA, SUCURSAL, EMPLEADO, MOTIVO "
                + "ORDER BY FECHA DESC, ID_NOTA_CREDITO DESC";
        return jdbc.query(sql, (rs, n) -> new NotaCreditoEmitida(rs.getLong("ID_NOTA_CREDITO"), rs.getString("SERIE"),
                rs.getLong("NUMERO"), rs.getObject("FECHA", LocalDate.class), rs.getString("SUCURSAL"),
                rs.getString("EMPLEADO"), rs.getString("MOTIVO"), rs.getBigDecimal("TOTAL")), p.toArray());
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
        String sql = "SELECT SUCURSAL, CATEGORIA, CODIGO_PRODUCTO, PRODUCTO, EXISTENCIA, STOCK_MINIMO, BAJO_MINIMO "
                + "FROM V_EXISTENCIAS" + where + " ORDER BY SUCURSAL, PRODUCTO";
        return jdbc.query(sql, (rs, n) -> new Existencia(rs.getString("SUCURSAL"), rs.getString("CATEGORIA"),
                rs.getString("CODIGO_PRODUCTO"), rs.getString("PRODUCTO"), rs.getInt("EXISTENCIA"),
                rs.getInt("STOCK_MINIMO"), rs.getString("BAJO_MINIMO")), p.toArray());
    }

    private static String filtroFecha(String col, LocalDate desde, LocalDate hasta, List<Object> params) {
        StringBuilder w = new StringBuilder();
        if (desde != null) {
            w.append(w.isEmpty() ? " WHERE " : " AND ").append(col).append(" >= ?");
            params.add(desde);
        }
        if (hasta != null) {
            w.append(w.isEmpty() ? " WHERE " : " AND ").append(col).append(" < ?");
            params.add(hasta.plusDays(1));
        }
        return w.toString();
    }

    public record Dashboard(BigDecimal totalVendidoMes, long facturasMes, long productosBajoMinimo,
                            long garantiasAbiertas, List<VentaPorSucursal> ventasPorSucursalMes) {
    }

    public record VentaPorSucursal(long idSucursal, String sucursal, long numeroFacturas, BigDecimal totalVendido) {
    }

    public record VentaPorProducto(long idProducto, String codigoProducto, String producto, long cantidad,
                                   BigDecimal total) {
    }

    public record VentaPorCategoria(long idCategoria, String categoria, long cantidad, BigDecimal total) {
    }

    public record VentaPorEmpleado(long idEmpleado, String empleado, long numeroFacturas, BigDecimal totalVendido) {
    }

    public record VentaPorFormaPago(long idFormaPago, String formaPago, long numeroPagos, BigDecimal total) {
    }

    public record GarantiaPorEstado(String estado, String nombreEstado, long cantidad) {
    }

    public record NotaCreditoEmitida(long idNotaCredito, String serie, long numero, LocalDate fecha, String sucursal,
                                     String empleado, String motivo, BigDecimal total) {
    }

    public record Existencia(String sucursal, String categoria, String codigoProducto, String producto,
                             int existencia, int stockMinimo, String bajoMinimo) {
    }
}
