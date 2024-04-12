本项目将RuoYi前后端整合到一起，最终打包成一个jar方便部署

后端使用的RuoYi-Vue的单应用版本

前端使用的RuoYi-Vue的ruoyi-ui

> 基于RuoYi v3.8.7版本 <br>
> 数据库将MySQL改为H2<br>
> 集成Redis<br>
> 不需要搭建单独的MySQL和Redis

### 后端改造

1. `pom.xml`文件MySQL替换为H2，添加Redis和thymeleaf

   ~~~xml
   <!-- H2数据库 -->
   <dependency>
       <groupId>com.h2database</groupId>
       <artifactId>h2</artifactId>
       <version>1.4.199</version>
       <scope>runtime</scope>
   </dependency>
   
   <!-- redis -->
   <dependency>
       <groupId>it.ozimov</groupId>
       <artifactId>embedded-redis</artifactId>
       <version>0.7.3</version>
       <exclusions>
           <exclusion>
               <groupId>org.slf4j</groupId>
               <artifactId>slf4j-simple</artifactId>
           </exclusion>
       </exclusions>
   </dependency>
   
   <!-- thymeleaf -->
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-thymeleaf</artifactId>
   </dependency>
   ~~~

2. 新建Redis服务启动类`src/main/java/com/ruoyi/framework/redis/RedisStart.java`

   ~~~java
   /**
    * 在本机启动一个Redis
    */
   @Component("RedisStart")
   public class RedisStart {
       private static Logger logger = LoggerFactory.getLogger(RedisStart.class);
   
       private static RedisServer redisServer;
       
       @PostConstruct
       public static void startRedis() {
           redisServer = RedisServer.builder()
                   .port(6379)
                   .setting("maxmemory 128M")
                   .build();
           redisServer.start();
           logger.info("====启动Redis====");
       }
   
       @PreDestroy
       public void stopRedis() {
           redisServer.stop();
           logger.info("====关闭Redis====");
       }
   }
   ~~~

3. 在`src/main/java/com/ruoyi/framework/config/RedisConfig.java`上添加`@DependsOn("RedisStart")`保证在Redis启动后再连接

   ~~~java
   /**
    * redis配置
    *
    * @author ruoyi
    */
   @Configuration
   @EnableCaching
   @DependsOn("RedisStart")
   public class RedisConfig extends CachingConfigurerSupport {...}
   ~~~

4. `application.yml`配置修改

   ~~~yaml
   # PageHelper分页插件
   pagehelper:
     helperDialect: h2
     supportMethodsArguments: true
     params: count=countSql
   # Spring配置
   spring:
     thymeleaf:
       prefix: classpath:/dist/
       mode: HTML
       encoding: utf-8
       cache: false
   ~~~

5. `application-druid.yml`修改如下

   ~~~yaml
   # 数据源配置
   spring:
     h2:
       console:
         enabled: true
         path: /h2
     sql:
       init:
         schema-locations: classpath:sql/schema-h2.sql
         data-locations: classpath:sql/data-h2.sql
     datasource:
       type: com.alibaba.druid.pool.DruidDataSource
       driverClassName: org.h2.Driver
       druid:
         # 主库数据源
         master:
           url: jdbc:h2:mem:ry
           username: root
           password: root
   ~~~

6. `src/main/java/com/ruoyi/framework/config/SecurityConfig.java` configure方法添加允许匿名访问的资源

   ~~~java
   @Override
   protected void configure(HttpSecurity httpSecurity) throws Exception {
       // 注解标记允许匿名访问的url
       ExpressionUrlAuthorizationConfigurer<HttpSecurity>.ExpressionInterceptUrlRegistry registry = httpSecurity.authorizeRequests();
       permitAllUrl.getUrls().forEach(url -> registry.antMatchers(url).permitAll());
   
       httpSecurity
               // CSRF禁用，因为不使用session
               .csrf().disable()
               // 禁用HTTP响应标头
               .headers().cacheControl().disable().and()
               // 认证失败处理类
               .exceptionHandling().authenticationEntryPoint(unauthorizedHandler).and()
               // 基于token，所以不需要session
               .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS).and()
               // 过滤请求
               .authorizeRequests()
               // 对于登录login 注册register 验证码captchaImage 允许匿名访问
               .antMatchers("/login", "/register", "/captchaImage").permitAll()
               // 静态资源，可匿名访问
               .antMatchers(HttpMethod.GET, "/", "/*.html", "/**/*.html", "/**/*.css", "/**/*.js", "/profile/**").permitAll()
               .antMatchers("/swagger-ui.html", "/swagger-resources/**", "/webjars/**", "/*/api-docs", "/druid/**").permitAll()
               .antMatchers("/h2/**", "/static/**", "/", "/index").permitAll()
               // 除上面外的所有请求全部需要鉴权认证
               .anyRequest().authenticated()
               .and()
               .headers().frameOptions().disable();
       // 添加Logout filter
       httpSecurity.logout().logoutUrl("/logout").logoutSuccessHandler(logoutSuccessHandler);
       // 添加JWT filter
       httpSecurity.addFilterBefore(authenticationTokenFilter, UsernamePasswordAuthenticationFilter.class);
       // 添加CORS filter
       httpSecurity.addFilterBefore(corsFilter, JwtAuthenticationTokenFilter.class);
       httpSecurity.addFilterBefore(corsFilter, LogoutFilter.class);
   }
   ~~~

7. `src/main/java/com/ruoyi/framework/config/ResourcesConfig.java`修改如下

   ~~~java
   @Configuration
   public class ResourcesConfig implements WebMvcConfigurer {
       @Autowired
       private RepeatSubmitInterceptor repeatSubmitInterceptor;
   
       @Override
       public void addResourceHandlers(ResourceHandlerRegistry registry) {
           /** 本地文件上传路径 */
           registry.addResourceHandler(Constants.RESOURCE_PREFIX + "/**")
                   .addResourceLocations("file:" + RuoYiConfig.getProfile() + "/");
   
           /** 页面静态化 */
           registry.addResourceHandler("/static/**").addResourceLocations("classpath:/dist/static/");
   
           /** swagger配置 */
           registry.addResourceHandler("/swagger-ui/**")
                   .addResourceLocations("classpath:/META-INF/resources/webjars/springfox-swagger-ui/")
                   .setCacheControl(CacheControl.maxAge(5, TimeUnit.HOURS).cachePublic());
           ;
       }
   
       @Override
       public void addViewControllers(ViewControllerRegistry registry) {
           registry.addViewController("/index").setViewName("index.html");
           registry.addViewController("/").setViewName("index.html");
           registry.setOrder(Ordered.HIGHEST_PRECEDENCE);
       }
   
       ......
   }
   ~~~

   

8. 在 `src/main/resources/sql`下创建h2 的sql文件（我通过IDEA的插件`Mysql To H2`转换的若依的sql）

### 前端改造

1. 修改 `ruoyi-ui/src/router/index.js`文件 ，将 mode: ‘history’ 改成 mode: ‘hash’

   ~~~javascript
   export default new Router({
     mode: 'hash', 
     scrollBehavior: () => ({ y: 0 }),
     routes: constantRoutes
   })
   ~~~

2. 修改`ruoyi-ui/.env.production`文件 将’/prod-api’ 改成’/’ 这个必须要改要不你直接访问localhost:8080打不开页面

   ~~~javascript
   # 若依管理系统/生产环境 VUE_APP_BASE_API = '/prod-api'
   VUE_APP_BASE_API = '/'
   ~~~

### 打包部署

前端打好包之后，手动将dist目录复制，放到后端的resources目录下面即可，然后直接打后端的jar包，此时前后端就在一个jar包里面了 ，然后运行后端 在浏览器输入 localhost:8080就行了

### 其他修改（可选）

1. 启动类添加地址

   ~~~java
   /**
    * 启动程序
    *
    * @author ruoyi
    */
   @SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
   public class RuoYiApplication {
   
       public static void main(String[] args) throws Exception {
           // System.setProperty("spring.devtools.restart.enabled", "false");
           ConfigurableApplicationContext context = SpringApplication.run(RuoYiApplication.class, args);
           System.out.println("(♥◠‿◠)ﾉﾞ  启动成功   ლ(´ڡ`ლ)ﾞ  \n");
           String ip = InetAddress.getLocalHost().getHostAddress();
           String port = context.getEnvironment().getProperty("server.port");
           System.out.println("Server running at:\n" +
                   "- Local:   http://localhost:" + port + "\n" +
                   "- Network: http://" + ip + ":" + port);
       }
   }
   ~~~

2. 修改日志存放路径`src/main/resources/logback.xml`

   ~~~xml
   <!-- 日志存放路径 -->
   <property name="log.path" value="./logs" />
   ~~~

   
