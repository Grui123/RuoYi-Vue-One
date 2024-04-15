package com.ruoyi.framework.init;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import redis.embedded.RedisServer;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

/**
 * 在本机启动一个Redis
 */
@Component
public class RedisInit {
    private static Logger logger = LoggerFactory.getLogger(RedisInit.class);

    private static RedisServer redisServer;

    @PostConstruct
    public void init() {
        redisServer = RedisServer.builder()
                .port(6379)
                .setting("maxmemory 128M")
                .build();
        redisServer.start();
        logger.info("====启动Redis====");
    }

    @PreDestroy
    public void stop() {
        redisServer.stop();
        logger.info("====关闭Redis====");
    }

}