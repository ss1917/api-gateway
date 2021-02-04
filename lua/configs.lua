json = require("cjson")

--mysql_config = {
--    host = "codo-mysql;",
--    port = 3306,
--    database = "lua",
--    user = "root",
--    password = "",
--    max_packet_size = 1024 * 1024
--}

-- redis配置，一定要修改,并且和codo-admin保持一致
redis_config = {
    host = 'codo-redis',
    port = 6379,
    auth_pwd = 'cWCVKJ7ZHUK12mVbivUf',
    db = 8,
    alive_time = 3600 * 24 * 7,
    channel = 'gw'
}

--mq_conf = {
--	host = 'codo-mq',
--	port = 5672,
--	username = 'sz',
--	password = '123456',
--	vhost = '/'
--}

-- 注意：这里的token_secret必须要和codo-admin里面的token_secret保持一致
token_secret = "pXFb4i%*834gfdh963df718iodGq4dsafsdadg7yI6ImF1999aaG7"
logs_file = '/usr/local/openresty/nginx/logs/gateway-lua.log'

--刷新权限到redis接口
rewrite_cache_url = 'http://codo-admin/v2/accounts/verify/'
-- 注意：rewrite_cache_token要和codo-admin里面的secret_key = '8b888a62-3edb-4920-b446-697a472b4001'保持一致
rewrite_cache_token = '8b888a62-3edb-4920-b446-697a472b4001'

--并发限流配置
limit_conf = {
    rate = 10, --限制ip每分钟只能调用n*60次接口
    burst = 10, --桶容量,用于平滑处理,最大接收请求次数
}

--upstream匹配规则,API网关域名
gw_domain_name = 'codo-gateway'

--下面的转发一定要修改，根据自己实际数据修改
rewrite_conf = {
    [gw_domain_name] = {
        rewrite_urls = {
            {
                uri = "/dns",
                rewrite_upstream = "codo-dns"
            },
            {
                uri = "/cmdb2",
                rewrite_upstream = "codo-cmdb"
            },
            {
                uri = "/tools",
                rewrite_upstream = "codo-tools"
            },
            {
                uri = "/kerrigan",
                rewrite_upstream = "codo-kerrigan"
            },
            {
                uri = "/cmdb",
                rewrite_upstream = "codo-cmdb"
            },
            {
                uri = "/k8s",
                rewrite_upstream = "codo-k8s"
            },
            {
                uri = "/task",
                rewrite_upstream = "codo-task"
            },
            {
                uri = "/cron",
                rewrite_upstream = "codo-cron"
            },
            {
                uri = "/mg",
                rewrite_upstream = "codo-admin"
            },
            {
                uri = "/accounts",
                rewrite_upstream = "codo-admin"
            },
        }
    }
}
