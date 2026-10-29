package com.mdchavez.tienda.tienda_be.comun;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Caching;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Vacia los caches declarados en el @CacheConfig de la clase cuando el metodo modifica datos.
 * Antes de ejecutarlo se invalida de inmediato (la siguiente lectura ya no ve el dato viejo) y al
 * terminar se limpia otra vez, por si otra peticion guardo una copia vieja mientras se escribia.
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Caching(evict = {
        @CacheEvict(allEntries = true, beforeInvocation = true),
        @CacheEvict(allEntries = true)
})
public @interface InvalidarCache {
}
