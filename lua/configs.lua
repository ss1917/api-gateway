json = require("cjson")

--mysql_config = {
--    host = "127.0.0.1",
--    port = 3306,
--    database = "lua",
--    user = "root",
--    password = "",
--    max_packet_size = 1024 * 1024
--}

redis_config = {
    host = '172.16.0.223',
    --host = '172.16.0.121',
    port = 6379,
    auth_pwd = '123456',
    db = 7,
    alive_time = 3600 * 24 * 7,
    channel = 'gw'
}

--mq_conf = {
--	host = '172.16.0.121',
--	port = 5672,
--	username = 'sz',
--	password = '123456',
--	vhost = '/'
--}

token_secret = "pXFb4i%*834gfdh96(3df&%18iodGq4ODQyMzc4lz7yI6ImF1dG"
logs_file = '/var/log/gw.log'

--刷新权限到redis接口
rewrite_cache_url = 'http://aaaa.shinezone.net.cn:8888/v1/accounts/verify/'
rewrite_cache_token = '8b888a62-3edb-4920-b446-697a472b4001'

--Login URL
login_uri = '172.16.80.138:8080/#/login/'

--并发限流配置
limit_conf = {
    rate = 5, --限制ip每分钟只能调用n*60次接口
    burst = 10, --桶容量,用于平滑处理,最大接收请求次数
}

--upstream匹配规则
rewrite_conf = {
    ['gw.shinezone.net.cn'] = {
        rewrite_urls = {
            {
                uri = "/devops",
                rewrite_upstream = "devops.shinezone.net.cn"
            },
            {
                uri = "/cmdb",
                rewrite_upstream = "aaaa.shinezone.net.cn:8888"
            },
            {
                uri = "/mg",
                rewrite_upstream = "172.16.0.223:9800"
            },
        }
    }
}
