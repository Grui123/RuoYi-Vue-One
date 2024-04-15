package com.ruoyi;

import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.ip.IpUtils;
import com.ruoyi.framework.init.MariaDB4jInit;
import com.ruoyi.framework.init.RedisInit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.context.ConfigurableApplicationContext;

/**
 * 启动程序
 *
 * @author ruoyi
 */
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
public class RuoYiApplication {

    @Autowired
    private MariaDB4jInit mariaDB4jInit;
    @Autowired
    private RedisInit redisInit;

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext context = SpringApplication.run(RuoYiApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  启动成功   ლ(´ڡ`ლ)ﾞ  \n");
        String ip = IpUtils.getHostCardIp();
        String port = context.getEnvironment().getProperty("server.port");
        String Network;
        if (StringUtils.isNull(ip)) {
            Network = "unavailable";
        } else {
            Network = "http://" + ip + ":" + port;
        }

        System.out.println("Server running at:\n" +
                "- Local:   http://localhost:" + port + "\n" +
                "- Network: " + Network
        );
    }

    /**
     * 设置MariaDB和Redis优先启动
     */
    public CommandLineRunner init() {
        return args -> {
            mariaDB4jInit.init();
            redisInit.init();
        };
    }
}
