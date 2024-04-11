package com.ruoyi.framework.redis;


import org.springframework.stereotype.Component;
import redis.embedded.RedisServer;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

/**
 * 在本机启动一个Redis
 */
@Component("MemRedis")
public class MemRedis {

    private static RedisServer redisServer;


    @PostConstruct
    public static void startRedis() {
        redisServer = RedisServer.builder()
                .port(6379)
                .setting("maxmemory 128M")
                .build();
        redisServer.start();
    }

    @PreDestroy
    public void stopRedis() {
        redisServer.stop();
    }

}