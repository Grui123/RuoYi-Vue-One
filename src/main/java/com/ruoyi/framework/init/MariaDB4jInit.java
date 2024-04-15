package com.ruoyi.framework.init;

import ch.vorburger.exec.ManagedProcessException;
import ch.vorburger.mariadb4j.springframework.MariaDB4jSpringService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

@Component
public class MariaDB4jInit {
    private static Logger logger = LoggerFactory.getLogger(MariaDB4jInit.class);

    private static MariaDB4jSpringService DB;

    @Value("${mariadb4j.port}")
    private Integer port;

    @Value("${mariadb4j.encoding}")
    private String encoding;

    @Value("${mariadb4j.database}")
    private String database;

    @Value("${mariadb4j.data}")
    private String[] data;


    @PostConstruct
    public void init() throws ManagedProcessException {
        DB = new MariaDB4jSpringService();
        DB.setDefaultCharacterSet(encoding);
        DB.setDefaultPort(port);
        DB.start();
        DB.getDB().createDB(database);
        for (String sql : data) {
            DB.getDB().source(sql, database);
        }
        logger.info("====启动MariaDB4j====");
    }

    @PreDestroy
    public void stop() {
        if (DB != null) DB.stop();
        logger.info("====关闭MariaDB4j====");
    }

}