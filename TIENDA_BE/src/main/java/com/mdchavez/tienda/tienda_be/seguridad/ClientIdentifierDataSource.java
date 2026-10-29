package com.mdchavez.tienda.tienda_be.seguridad;

import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.jdbc.datasource.DelegatingDataSource;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

public class ClientIdentifierDataSource extends DelegatingDataSource {

    public ClientIdentifierDataSource(DataSource destino) {
        super(destino);
    }

    @Override
    public Connection getConnection() throws SQLException {
        Connection conexion = super.getConnection();
        conexion.setClientInfo("OCSID.CLIENTID", usuarioActual());
        return conexion;
    }

    private static String usuarioActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || auth instanceof AnonymousAuthenticationToken) {
            return "";
        }
        return auth.getName();
    }

    @Component
    static class Envoltorio implements BeanPostProcessor {
        @Override
        public Object postProcessAfterInitialization(Object bean, String beanName) {
            if (bean instanceof DataSource ds && !(bean instanceof ClientIdentifierDataSource)) {
                return new ClientIdentifierDataSource(ds);
            }
            return bean;
        }
    }
}
