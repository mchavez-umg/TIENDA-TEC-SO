package com.mdchavez.tienda.tienda_be.comun;

import org.apache.commons.logging.LogFactory;
import org.springframework.cache.annotation.CachingConfigurer;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.interceptor.CacheErrorHandler;
import org.springframework.cache.interceptor.LoggingCacheErrorHandler;
import org.springframework.context.annotation.Configuration;

/**
 * Cache de catalogos en Redis, compartido por todas las replicas del backend.
 * Si Redis no responde, el error solo se registra y la consulta va directo a Oracle.
 */
@Configuration
@EnableCaching
public class ConfiguracionCache implements CachingConfigurer {

    public static final String CATEGORIAS = "categorias";
    public static final String MARCAS = "marcas";
    public static final String DEPARTAMENTOS = "departamentos";
    public static final String MUNICIPIOS = "municipios";

    @Override
    public CacheErrorHandler errorHandler() {
        return new LoggingCacheErrorHandler(LogFactory.getLog(ConfiguracionCache.class), false);
    }
}
