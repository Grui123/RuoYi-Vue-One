DROP TABLE IF EXISTS QRTZ_FIRED_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_PAUSED_TRIGGER_GRPS;
DROP TABLE IF EXISTS QRTZ_SCHEDULER_STATE;
DROP TABLE IF EXISTS QRTZ_LOCKS;
DROP TABLE IF EXISTS QRTZ_SIMPLE_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_SIMPROP_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_CRON_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_BLOB_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_JOB_DETAILS;
DROP TABLE IF EXISTS QRTZ_CALENDARS;
-- ----------------------------
-- 1、存储每一个已配置的 jobDetail 的详细信息
-- ----------------------------
CREATE TABLE QRTZ_JOB_DETAILS
(
    sched_name        varchar(120) NOT NULL COMMENT '调度名称',
    job_name          varchar(200) NOT NULL COMMENT '任务名称',
    job_group         varchar(200) NOT NULL COMMENT '任务组名',
    description       varchar(250) NULL COMMENT '相关介绍',
    job_class_name    varchar(250) NOT NULL COMMENT '执行任务类名称',
    is_durable        varchar(1)   NOT NULL COMMENT '是否持久化',
    is_nonconcurrent  varchar(1)   NOT NULL COMMENT '是否并发',
    is_update_data    varchar(1)   NOT NULL COMMENT '是否更新数据',
    requests_recovery varchar(1)   NOT NULL COMMENT '是否接受恢复执行',
    job_data          blob         NULL COMMENT '存放持久化job对象'
);
-- ----------------------------
-- 2、 存储已配置的 Trigger 的信息
-- ----------------------------
CREATE TABLE QRTZ_TRIGGERS
(
    sched_name     varchar(120) NOT NULL COMMENT '调度名称',
    trigger_name   varchar(200) NOT NULL COMMENT '触发器的名字',
    trigger_group  varchar(200) NOT NULL COMMENT '触发器所属组的名字',
    job_name       varchar(200) NOT NULL COMMENT 'qrtz_job_details表job_name的外键',
    job_group      varchar(200) NOT NULL COMMENT 'qrtz_job_details表job_group的外键',
    description    varchar(250) NULL COMMENT '相关介绍',
    next_fire_time bigint(13)   NULL COMMENT '上一次触发时间（毫秒）',
    prev_fire_time bigint(13)   NULL COMMENT '下一次触发时间（默认为-1表示不触发）',
    priority       integer      NULL COMMENT '优先级',
    trigger_state  varchar(16)  NOT NULL COMMENT '触发器状态',
    trigger_type   varchar(8)   NOT NULL COMMENT '触发器的类型',
    start_time     bigint(13)   NOT NULL COMMENT '开始时间',
    end_time       bigint(13)   NULL COMMENT '结束时间',
    calendar_name  varchar(200) NULL COMMENT '日程表名称',
    misfire_instr  smallint(2)  NULL COMMENT '补偿执行的策略',
    job_data       blob         NULL COMMENT '存放持久化job对象'
);
-- ----------------------------
-- 3、 存储简单的 Trigger，包括重复次数，间隔，以及已触发的次数
-- ----------------------------
CREATE TABLE QRTZ_SIMPLE_TRIGGERS
(
    sched_name      varchar(120) NOT NULL COMMENT '调度名称',
    trigger_name    varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
    trigger_group   varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
    repeat_count    bigint(7)    NOT NULL COMMENT '重复的次数统计',
    repeat_interval bigint(12)   NOT NULL COMMENT '重复的间隔时间',
    times_triggered bigint(10)   NOT NULL COMMENT '已经触发的次数'
);
-- ----------------------------
-- 4、 存储 Cron Trigger，包括 Cron 表达式和时区信息
-- ----------------------------
CREATE TABLE QRTZ_CRON_TRIGGERS
(
    sched_name      varchar(120) NOT NULL COMMENT '调度名称',
    trigger_name    varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
    trigger_group   varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
    cron_expression varchar(200) NOT NULL COMMENT 'cron表达式',
    time_zone_id    varchar(80) COMMENT '时区'
);
-- ----------------------------
-- 5、 Trigger 作为 Blob 类型存储(用于 Quartz 用户用 JDBC 创建他们自己定制的 Trigger 类型，JobStore 并不知道如何存储实例的时候)
-- ----------------------------
CREATE TABLE QRTZ_BLOB_TRIGGERS
(
    sched_name    varchar(120) NOT NULL COMMENT '调度名称',
    trigger_name  varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
    trigger_group varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
    blob_data     blob         NULL COMMENT '存放持久化Trigger对象'
);
-- ----------------------------
-- 6、 以 Blob 类型存储存放日历信息， quartz可配置一个日历来指定一个时间范围
-- ----------------------------
CREATE TABLE QRTZ_CALENDARS
(
    sched_name    varchar(120) NOT NULL COMMENT '调度名称',
    calendar_name varchar(200) NOT NULL COMMENT '日历名称',
    calendar      blob         NOT NULL COMMENT '存放持久化calendar对象'
);
-- ----------------------------
-- 7、 存储已暂停的 Trigger 组的信息
-- ----------------------------
CREATE TABLE QRTZ_PAUSED_TRIGGER_GRPS
(
    sched_name    varchar(120) NOT NULL COMMENT '调度名称',
    trigger_group varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键'
);
-- ----------------------------
-- 8、 存储与已触发的 Trigger 相关的状态信息，以及相联 Job 的执行信息
-- ----------------------------
CREATE TABLE QRTZ_FIRED_TRIGGERS
(
    sched_name        varchar(120) NOT NULL COMMENT '调度名称',
    entry_id          varchar(95)  NOT NULL COMMENT '调度器实例id',
    trigger_name      varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
    trigger_group     varchar(200) NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
    instance_name     varchar(200) NOT NULL COMMENT '调度器实例名',
    fired_time        bigint(13)   NOT NULL COMMENT '触发的时间',
    sched_time        bigint(13)   NOT NULL COMMENT '定时器制定的时间',
    priority          integer      NOT NULL COMMENT '优先级',
    state             varchar(16)  NOT NULL COMMENT '状态',
    job_name          varchar(200) NULL COMMENT '任务名称',
    job_group         varchar(200) NULL COMMENT '任务组名',
    is_nonconcurrent  varchar(1)   NULL COMMENT '是否并发',
    requests_recovery varchar(1)   NULL COMMENT '是否接受恢复执行'
);
-- ----------------------------
-- 9、 存储少量的有关 Scheduler 的状态信息，假如是用于集群中，可以看到其他的 Scheduler 实例
-- ----------------------------
CREATE TABLE QRTZ_SCHEDULER_STATE
(
    sched_name        varchar(120) NOT NULL COMMENT '调度名称',
    instance_name     varchar(200) NOT NULL COMMENT '实例名称',
    last_checkin_time bigint(13)   NOT NULL COMMENT '上次检查时间',
    checkin_interval  bigint(13)   NOT NULL COMMENT '检查间隔时间'
);
-- ----------------------------
-- 10、 存储程序的悲观锁的信息(假如使用了悲观锁)
-- ----------------------------
CREATE TABLE QRTZ_LOCKS
(
    sched_name varchar(120) NOT NULL COMMENT '调度名称',
    lock_name  varchar(40)  NOT NULL COMMENT '悲观锁名称'
);
-- ----------------------------
-- 11、 Quartz集群实现同步机制的行锁表
-- ----------------------------
CREATE TABLE QRTZ_SIMPROP_TRIGGERS
(
    sched_name    varchar(120)   NOT NULL COMMENT '调度名称',
    trigger_name  varchar(200)   NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
    trigger_group varchar(200)   NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
    str_prop_1    varchar(512)   NULL COMMENT 'String类型的trigger的第一个参数',
    str_prop_2    varchar(512)   NULL COMMENT 'String类型的trigger的第二个参数',
    str_prop_3    varchar(512)   NULL COMMENT 'String类型的trigger的第三个参数',
    int_prop_1    int            NULL COMMENT 'int类型的trigger的第一个参数',
    int_prop_2    int            NULL COMMENT 'int类型的trigger的第二个参数',
    long_prop_1   bigint         NULL COMMENT 'long类型的trigger的第一个参数',
    long_prop_2   bigint         NULL COMMENT 'long类型的trigger的第二个参数',
    dec_prop_1    numeric(13, 4) NULL COMMENT 'decimal类型的trigger的第一个参数',
    dec_prop_2    numeric(13, 4) NULL COMMENT 'decimal类型的trigger的第二个参数',
    bool_prop_1   varchar(1)     NULL COMMENT 'Boolean类型的trigger的第一个参数',
    bool_prop_2   varchar(1)     NULL COMMENT 'Boolean类型的trigger的第二个参数'
);
DROP TABLE IF EXISTS sys_dept;
CREATE TABLE sys_dept
(
    dept_id     bigint(20) NOT NULL AUTO_INCREMENT COMMENT '部门id',
    parent_id   bigint(20)  DEFAULT 0 COMMENT '父部门id',
    ancestors   varchar(50) DEFAULT '' COMMENT '祖级列表',
    dept_name   varchar(30) DEFAULT '' COMMENT '部门名称',
    order_num   int(4)      DEFAULT 0 COMMENT '显示顺序',
    leader      varchar(20) DEFAULT NULL COMMENT '负责人',
    phone       varchar(11) DEFAULT NULL COMMENT '联系电话',
    email       varchar(50) DEFAULT NULL COMMENT '邮箱',
    status      char(1)     DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
    del_flag    char(1)     DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
    create_by   varchar(64) DEFAULT '' COMMENT '创建者',
    create_time datetime COMMENT '创建时间',
    update_by   varchar(64) DEFAULT '' COMMENT '更新者',
    update_time datetime COMMENT '更新时间'
);
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user
(
    user_id     bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    dept_id     bigint(20)   DEFAULT NULL COMMENT '部门ID',
    user_name   varchar(30) NOT NULL COMMENT '用户账号',
    nick_name   varchar(30) NOT NULL COMMENT '用户昵称',
    user_type   varchar(2)   DEFAULT '00' COMMENT '用户类型（00系统用户）',
    email       varchar(50)  DEFAULT '' COMMENT '用户邮箱',
    phonenumber varchar(11)  DEFAULT '' COMMENT '手机号码',
    sex         char(1)      DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
    avatar      varchar(100) DEFAULT '' COMMENT '头像地址',
    password    varchar(100) DEFAULT '' COMMENT '密码',
    status      char(1)      DEFAULT '0' COMMENT '帐号状态（0正常 1停用）',
    del_flag    char(1)      DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
    login_ip    varchar(128) DEFAULT '' COMMENT '最后登录IP',
    login_date  datetime COMMENT '最后登录时间',
    create_by   varchar(64)  DEFAULT '' COMMENT '创建者',
    create_time datetime COMMENT '创建时间',
    update_by   varchar(64)  DEFAULT '' COMMENT '更新者',
    update_time datetime COMMENT '更新时间',
    remark      varchar(500) DEFAULT NULL COMMENT '备注'
);
DROP TABLE IF EXISTS sys_post;
CREATE TABLE sys_post
(
    post_id     bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
    post_code   varchar(64) NOT NULL COMMENT '岗位编码',
    post_name   varchar(50) NOT NULL COMMENT '岗位名称',
    post_sort   int(4)      NOT NULL COMMENT '显示顺序',
    status      char(1)     NOT NULL COMMENT '状态（0正常 1停用）',
    create_by   varchar(64)  DEFAULT '' COMMENT '创建者',
    create_time datetime COMMENT '创建时间',
    update_by   varchar(64)  DEFAULT '' COMMENT '更新者',
    update_time datetime COMMENT '更新时间',
    remark      varchar(500) DEFAULT NULL COMMENT '备注'
);
DROP TABLE IF EXISTS sys_role;
CREATE TABLE sys_role
(
    role_id             bigint(20)   NOT NULL AUTO_INCREMENT COMMENT '角色ID',
    role_name           varchar(30)  NOT NULL COMMENT '角色名称',
    role_key            varchar(100) NOT NULL COMMENT '角色权限字符串',
    role_sort           int(4)       NOT NULL COMMENT '显示顺序',
    data_scope          char(1)      DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
    menu_check_strictly tinyint(1)   DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
    dept_check_strictly tinyint(1)   DEFAULT 1 COMMENT '部门树选择项是否关联显示',
    status              char(1)      NOT NULL COMMENT '角色状态（0正常 1停用）',
    del_flag            char(1)      DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
    create_by           varchar(64)  DEFAULT '' COMMENT '创建者',
    create_time         datetime COMMENT '创建时间',
    update_by           varchar(64)  DEFAULT '' COMMENT '更新者',
    update_time         datetime COMMENT '更新时间',
    remark              varchar(500) DEFAULT NULL COMMENT '备注'
);
DROP TABLE IF EXISTS sys_menu;
CREATE TABLE sys_menu
(
    menu_id     bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
    menu_name   varchar(50) NOT NULL COMMENT '菜单名称',
    parent_id   bigint(20)   DEFAULT 0 COMMENT '父菜单ID',
    order_num   int(4)       DEFAULT 0 COMMENT '显示顺序',
    path        varchar(200) DEFAULT '' COMMENT '路由地址',
    component   varchar(255) DEFAULT NULL COMMENT '组件路径',
    query       varchar(255) DEFAULT NULL COMMENT '路由参数',
    is_frame    int(1)       DEFAULT 1 COMMENT '是否为外链（0是 1否）',
    is_cache    int(1)       DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
    menu_type   char(1)      DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
    visible     char(1)      DEFAULT 0 COMMENT '菜单状态（0显示 1隐藏）',
    status      char(1)      DEFAULT 0 COMMENT '菜单状态（0正常 1停用）',
    perms       varchar(100) DEFAULT NULL COMMENT '权限标识',
    icon        varchar(100) DEFAULT '#' COMMENT '菜单图标',
    create_by   varchar(64)  DEFAULT '' COMMENT '创建者',
    create_time datetime COMMENT '创建时间',
    update_by   varchar(64)  DEFAULT '' COMMENT '更新者',
    update_time datetime COMMENT '更新时间',
    remark      varchar(500) DEFAULT '' COMMENT '备注'
);
DROP TABLE IF EXISTS sys_user_role;
CREATE TABLE sys_user_role
(
    user_id bigint(20) NOT NULL COMMENT '用户ID',
    role_id bigint(20) NOT NULL COMMENT '角色ID'
);
DROP TABLE IF EXISTS sys_role_menu;
CREATE TABLE sys_role_menu
(
    role_id bigint(20) NOT NULL COMMENT '角色ID',
    menu_id bigint(20) NOT NULL COMMENT '菜单ID'
);
DROP TABLE IF EXISTS sys_role_dept;
CREATE TABLE sys_role_dept
(
    role_id bigint(20) NOT NULL COMMENT '角色ID',
    dept_id bigint(20) NOT NULL COMMENT '部门ID'
);
DROP TABLE IF EXISTS sys_user_post;
CREATE TABLE sys_user_post
(
    user_id bigint(20) NOT NULL COMMENT '用户ID',
    post_id bigint(20) NOT NULL COMMENT '岗位ID'
);
DROP TABLE IF EXISTS sys_oper_log;
CREATE TABLE sys_oper_log
(
    oper_id        bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志主键',
    title          varchar(50)   DEFAULT '' COMMENT '模块标题',
    business_type  int(2)        DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
    method         varchar(100)  DEFAULT '' COMMENT '方法名称',
    request_method varchar(10)   DEFAULT '' COMMENT '请求方式',
    operator_type  int(1)        DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
    oper_name      varchar(50)   DEFAULT '' COMMENT '操作人员',
    dept_name      varchar(50)   DEFAULT '' COMMENT '部门名称',
    oper_url       varchar(255)  DEFAULT '' COMMENT '请求URL',
    oper_ip        varchar(128)  DEFAULT '' COMMENT '主机地址',
    oper_location  varchar(255)  DEFAULT '' COMMENT '操作地点',
    oper_param     varchar(2000) DEFAULT '' COMMENT '请求参数',
    json_result    varchar(2000) DEFAULT '' COMMENT '返回参数',
    status         int(1)        DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
    error_msg      varchar(2000) DEFAULT '' COMMENT '错误消息',
    oper_time      datetime COMMENT '操作时间',
    cost_time      bigint(20)    DEFAULT 0 COMMENT '消耗时间'
);
DROP TABLE IF EXISTS sys_dict_type;
CREATE TABLE sys_dict_type
(
    dict_id     bigint(20) NOT NULL AUTO_INCREMENT COMMENT '字典主键',
    dict_name   varchar(100) DEFAULT '' COMMENT '字典名称',
    dict_type   varchar(100) DEFAULT '' COMMENT '字典类型',
    status      char(1)      DEFAULT '0' COMMENT '状态（0正常 1停用）',
    create_by   varchar(64)  DEFAULT '' COMMENT '创建者',
    create_time datetime COMMENT '创建时间',
    update_by   varchar(64)  DEFAULT '' COMMENT '更新者',
    update_time datetime COMMENT '更新时间',
    remark      varchar(500) DEFAULT NULL COMMENT '备注'
);
DROP TABLE IF EXISTS sys_dict_data;
CREATE TABLE sys_dict_data
(
    dict_code   bigint(20) NOT NULL AUTO_INCREMENT COMMENT '字典编码',
    dict_sort   int(4)       DEFAULT 0 COMMENT '字典排序',
    dict_label  varchar(100) DEFAULT '' COMMENT '字典标签',
    dict_value  varchar(100) DEFAULT '' COMMENT '字典键值',
    dict_type   varchar(100) DEFAULT '' COMMENT '字典类型',
    css_class   varchar(100) DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
    list_class  varchar(100) DEFAULT NULL COMMENT '表格回显样式',
    is_default  char(1)      DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
    status      char(1)      DEFAULT '0' COMMENT '状态（0正常 1停用）',
    create_by   varchar(64)  DEFAULT '' COMMENT '创建者',
    create_time datetime COMMENT '创建时间',
    update_by   varchar(64)  DEFAULT '' COMMENT '更新者',
    update_time datetime COMMENT '更新时间',
    remark      varchar(500) DEFAULT NULL COMMENT '备注'
);
DROP TABLE IF EXISTS sys_config;
CREATE TABLE sys_config
(
    config_id    int(5) NOT NULL AUTO_INCREMENT COMMENT '参数主键',
    config_name  varchar(100) DEFAULT '' COMMENT '参数名称',
    config_key   varchar(100) DEFAULT '' COMMENT '参数键名',
    config_value varchar(500) DEFAULT '' COMMENT '参数键值',
    config_type  char(1)      DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
    create_by    varchar(64)  DEFAULT '' COMMENT '创建者',
    create_time  datetime COMMENT '创建时间',
    update_by    varchar(64)  DEFAULT '' COMMENT '更新者',
    update_time  datetime COMMENT '更新时间',
    remark       varchar(500) DEFAULT NULL COMMENT '备注'
);
DROP TABLE IF EXISTS sys_logininfor;
CREATE TABLE sys_logininfor
(
    info_id        bigint(20) NOT NULL AUTO_INCREMENT COMMENT '访问ID',
    user_name      varchar(50)  DEFAULT '' COMMENT '用户账号',
    ipaddr         varchar(128) DEFAULT '' COMMENT '登录IP地址',
    login_location varchar(255) DEFAULT '' COMMENT '登录地点',
    browser        varchar(50)  DEFAULT '' COMMENT '浏览器类型',
    os             varchar(50)  DEFAULT '' COMMENT '操作系统',
    status         char(1)      DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
    msg            varchar(255) DEFAULT '' COMMENT '提示消息',
    login_time     datetime COMMENT '访问时间'
);
DROP TABLE IF EXISTS sys_job;
CREATE TABLE sys_job
(
    job_id          bigint(20)   NOT NULL AUTO_INCREMENT COMMENT '任务ID',
    job_name        varchar(64)  DEFAULT '' COMMENT '任务名称',
    job_group       varchar(64)  DEFAULT 'DEFAULT' COMMENT '任务组名',
    invoke_target   varchar(500) NOT NULL COMMENT '调用目标字符串',
    cron_expression varchar(255) DEFAULT '' COMMENT 'cron执行表达式',
    misfire_policy  varchar(20)  DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
    concurrent      char(1)      DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
    status          char(1)      DEFAULT '0' COMMENT '状态（0正常 1暂停）',
    create_by       varchar(64)  DEFAULT '' COMMENT '创建者',
    create_time     datetime COMMENT '创建时间',
    update_by       varchar(64)  DEFAULT '' COMMENT '更新者',
    update_time     datetime COMMENT '更新时间',
    remark          varchar(500) DEFAULT '' COMMENT '备注信息'
);
DROP TABLE IF EXISTS sys_job_log;
CREATE TABLE sys_job_log
(
    job_log_id     bigint(20)   NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
    job_name       varchar(64)  NOT NULL COMMENT '任务名称',
    job_group      varchar(64)  NOT NULL COMMENT '任务组名',
    invoke_target  varchar(500) NOT NULL COMMENT '调用目标字符串',
    job_message    varchar(500) COMMENT '日志信息',
    status         char(1)       DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
    exception_info varchar(2000) DEFAULT '' COMMENT '异常信息',
    create_time    datetime COMMENT '创建时间'
);
DROP TABLE IF EXISTS sys_notice;
CREATE TABLE sys_notice
(
    notice_id      int(4)      NOT NULL AUTO_INCREMENT COMMENT '公告ID',
    notice_title   varchar(50) NOT NULL COMMENT '公告标题',
    notice_type    char(1)     NOT NULL COMMENT '公告类型（1通知 2公告）',
    notice_content longblob     DEFAULT NULL COMMENT '公告内容',
    status         char(1)      DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
    create_by      varchar(64)  DEFAULT '' COMMENT '创建者',
    create_time    datetime COMMENT '创建时间',
    update_by      varchar(64)  DEFAULT '' COMMENT '更新者',
    update_time    datetime COMMENT '更新时间',
    remark         varchar(255) DEFAULT NULL COMMENT '备注'
);
DROP TABLE IF EXISTS gen_table;
CREATE TABLE gen_table
(
    table_id          bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
    table_name        varchar(200) DEFAULT '' COMMENT '表名称',
    table_comment     varchar(500) DEFAULT '' COMMENT '表描述',
    sub_table_name    varchar(64)  DEFAULT NULL COMMENT '关联子表的表名',
    sub_table_fk_name varchar(64)  DEFAULT NULL COMMENT '子表关联的外键名',
    class_name        varchar(100) DEFAULT '' COMMENT '实体类名称',
    tpl_category      varchar(200) DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
    tpl_web_type      varchar(30)  DEFAULT '' COMMENT '前端模板类型（element-ui模版 element-plus模版）',
    package_name      varchar(100) COMMENT '生成包路径',
    module_name       varchar(30) COMMENT '生成模块名',
    business_name     varchar(30) COMMENT '生成业务名',
    function_name     varchar(50) COMMENT '生成功能名',
    function_author   varchar(50) COMMENT '生成功能作者',
    gen_type          char(1)      DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
    gen_path          varchar(200) DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
    options           varchar(1000) COMMENT '其它生成选项',
    create_by         varchar(64)  DEFAULT '' COMMENT '创建者',
    create_time       datetime COMMENT '创建时间',
    update_by         varchar(64)  DEFAULT '' COMMENT '更新者',
    update_time       datetime COMMENT '更新时间',
    remark            varchar(500) DEFAULT NULL COMMENT '备注'
);
DROP TABLE IF EXISTS gen_table_column;
CREATE TABLE gen_table_column
(
    column_id      bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
    table_id       bigint(20) COMMENT '归属表编号',
    column_name    varchar(200) COMMENT '列名称',
    column_comment varchar(500) COMMENT '列描述',
    column_type    varchar(100) COMMENT '列类型',
    java_type      varchar(500) COMMENT 'JAVA类型',
    java_field     varchar(200) COMMENT 'JAVA字段名',
    is_pk          char(1) COMMENT '是否主键（1是）',
    is_increment   char(1) COMMENT '是否自增（1是）',
    is_required    char(1) COMMENT '是否必填（1是）',
    is_insert      char(1) COMMENT '是否为插入字段（1是）',
    is_edit        char(1) COMMENT '是否编辑字段（1是）',
    is_list        char(1) COMMENT '是否列表字段（1是）',
    is_query       char(1) COMMENT '是否查询字段（1是）',
    query_type     varchar(200) DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
    html_type      varchar(200) COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
    dict_type      varchar(200) DEFAULT '' COMMENT '字典类型',
    sort           int COMMENT '排序',
    create_by      varchar(64)  DEFAULT '' COMMENT '创建者',
    create_time    datetime COMMENT '创建时间',
    update_by      varchar(64)  DEFAULT '' COMMENT '更新者',
    update_time    datetime COMMENT '更新时间'
);
