package com.mdchavez.tienda.tienda_be.bitacora;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class BitacoraService {

    private final JdbcTemplate jdbc;

    public BitacoraService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<BitacoraRegistro> consultar(String tabla, String operacion, String usuario,
                                            LocalDate desde, LocalDate hasta, int limite) {
        List<Object> p = new ArrayList<>();
        StringBuilder where = new StringBuilder();
        agregar(where, "TABLA = ?", tabla, p);
        agregar(where, "OPERACION = ?", operacion, p);
        agregar(where, "USUARIO_APP = ?", usuario, p);
        if (desde != null) {
            where.append(where.isEmpty() ? " WHERE " : " AND ").append("FECHA >= ?");
            p.add(desde.atStartOfDay());
        }
        if (hasta != null) {
            where.append(where.isEmpty() ? " WHERE " : " AND ").append("FECHA < ?");
            p.add(hasta.plusDays(1).atStartOfDay());
        }
        p.add(limite);
        String sql = """
                SELECT ID_BITACORA, TABLA, OPERACION, ID_REGISTRO, VALORES_ANTERIORES, VALORES_NUEVOS,
                       USUARIO_BD, USUARIO_APP, FECHA
                FROM BITACORA_GENERAL""" + where + " ORDER BY FECHA DESC, ID_BITACORA DESC FETCH FIRST ? ROWS ONLY";
        return jdbc.query(sql, (rs, n) -> new BitacoraRegistro(rs.getLong("ID_BITACORA"), rs.getString("TABLA"),
                rs.getString("OPERACION"), rs.getLong("ID_REGISTRO"), rs.getString("VALORES_ANTERIORES"),
                rs.getString("VALORES_NUEVOS"), rs.getString("USUARIO_BD"), rs.getString("USUARIO_APP"),
                rs.getObject("FECHA", LocalDateTime.class)), p.toArray());
    }

    private static void agregar(StringBuilder where, String condicion, Object valor, List<Object> params) {
        if (valor != null) {
            where.append(where.isEmpty() ? " WHERE " : " AND ").append(condicion);
            params.add(valor);
        }
    }

    public record BitacoraRegistro(long idBitacora, String tabla, String operacion, long idRegistro,
                                   String valoresAnteriores, String valoresNuevos, String usuarioBd,
                                   String usuarioApp, LocalDateTime fecha) {
    }
}
