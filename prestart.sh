#!/bin/bash
sleep 10

echo "备份/usr/local/openresty/nginx/lua/configs.lua完成"
mv /usr/local/openresty/nginx/lua/configs.lua /usr/local/openresty/nginx/lua/configs.lua.bak


echo "注意,下面将开始生成网关中lua的配置文件!!!!!!"

cat > /usr/local/openresty/nginx/lua/configs.lua << EOF
json = require("cjson")

--mysql_config = {
--    host = "${DEFAULT_DB_DBHOST}",
--    port = "${DEFAULT_DB_DBPORT}",
--    database = "lua",
--    user = "${DEFAULT_DB_DBUSER}",
--    password = "${DEFAULT_DB_DBPWD}",
--    max_packet_size = 1024 * 1024
--}

-- redis配置，一定要修改,并且和codo-admin保持一致
redis_config = {
    host = '${DEFAULT_REDIS_HOST}',
    port = '${DEFAULT_REDIS_PORT}',
    auth_pwd = '${DEFAULT_REDIS_PASSWORD}',
    db = 8,
    alive_time = 3600 * 24 * 7,
    channel = 'gw'
}


-- 注意：这里的token_secret必须要和codo-admin里面的token_secret保持一致
token_secret = '${token_secret}'
logs_file = '/usr/local/openresty/nginx/logs/gateway-lua.log'

--刷新权限到redis接口
rewrite_cache_url = 'http://${mg_domain}/v2/accounts/verify/'
-- 注意：rewrite_cache_token要和codo-admin里面的secret_key保持一致
rewrite_cache_token = '${secret_key}'


--并发限流配置
limit_conf = {
    rate = 10, --限制ip每分钟只能调用n*60次接口
    burst = 10, --桶容量,用于平滑处理,最大接收请求次数
}

--upstream匹配规则,API网关域名
gw_domain_name = '"${api_gw_url}"'

--下面的转发一定要修改，根据自己实际数据修改
rewrite_conf = {
    [gw_domain_name] = {
        rewrite_urls = {
            {
                uri = "/dns",
                rewrite_upstream = "${dns_domain}"
            },
            {
                uri = "/cmdb2",
                rewrite_upstream = "${cmdb_domain}"
            },
            {
                uri = "/tools",
                rewrite_upstream = "${tools_domain}"
            },
            {
                uri = "/kerrigan",
                rewrite_upstream = "${kerrigan_domain}"
            },
            {
                uri = "/cmdb",
                rewrite_upstream = "${cmdb_domain}"
            },
            {
                uri = "/k8s",
                rewrite_upstream = "${k8s_domain}"
            },
            {
                uri = "/task",
                rewrite_upstream = "${task_domain}"
            },
            {
                uri = "/cron",
                rewrite_upstream = "${cron_domain}"
            },
            {
                uri = "/mg",
                rewrite_upstream = "${mg_domain}"
            },
            {
                uri = "/accounts",
                rewrite_upstream = "${mg_domain}"
            },
        }
    }
}
EOF

echo "请取人lua配置文件是否正确"
cat /usr/local/openresty/nginx/lua/configs.lua

echo "为了避免lua配置的是不能热加载配置文件,这里手动停止nginx,后面nginx的启动将会由supervisor服务来负责启动"
/usr/local/openresty/nginx/sbin/nginx -s stop