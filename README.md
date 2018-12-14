# API网关项目介绍
API网关系统,是基于openresty + Lua开发的一套API网关系统,主要功能如下：

- API鉴权

- API 限速

- 日志记录



# 一、服务部署
#### openresty 编译安装
```
wget https://openresty.org/download/openresty-1.13.6.2.tar.gz
tar zxf openresty-1.13.6.2.tar.gz && cd openresty-1.13.6.2
./configure --prefix=/usr/local/openresty-1.13.6.2 \
--with-luajit --with-http_stub_status_module \
--with-pcre --with-pcre-jit
gmake && gmake install
ln -s /usr/local/openresty-1.13.6.2/ /usr/local/openresty
ln -s /usr/local/openresty/bin/resty /usr/bin/resty
```

####  yum安装
```bash
# yum部署
yum install yum-utils
yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo
yum install openresty
yum install openresty-resty
```
#####  代码部署
```bash
\cp -arp api-gateway/* /usr/local/openresty/nginx/
```

# 二、 修改配置 
   ##### 文件 /usr/local/openresty/nginx/conf/nginx.conf
   -  修改 resolver 172.16.0.21; 为resolver DNS服务器。
   -  修改 lua_code_cache on; 线上环境设置为on
   -  修改 server_name  为你的网关域名
   ##### 文件 /usr/local/openresty/nginx/lua/configs.lua
   - token_secret 为你的令牌的密钥 和登录JWT 服务的key一致
   - rewrite_cache_url 刷新权限到redis接口  
   - rewrite_cache_token  为获取权限的令牌
   - login_url 当token 无效或者过期 跳转的登录页面
   - limit_conf 并发 限制默认即可 如有需求下面有详细介绍
   - rewrite_conf 注册API 下面有详解
          


# 三、使用配置,注册API
> 要接入API网关系统，则要先进行注册，注册方式如下：

​	a、配置文件configs.lua中的rewrite_conf

​	b、POST注册接口(暂无)

注册示例如下：

```lua
gw_domain_name = 'gw.opendevops.cn'

rewrite_conf = {
    [gw_domain_name] = {
        rewrite_urls = {
            {
                uri = "/cmdb",
                rewrite_upstream = "172.16.80.12:8000"
            },
            {
                uri = "/task",
                rewrite_upstream = "172.16.0.223:8900"
            },
            {
                uri = "/cron",
                rewrite_upstream = "172.16.0.223:9900"
            },
            {
                uri = "/mg",
                rewrite_upstream = "172.16.0.223:9800"
            },
            {
                uri = "/accounts",
                rewrite_upstream = "172.16.0.223:9800"
            },
        }
    }
}
```



如上可以看到，注册了的服务【cron】【mg】【accounts】
accounts 做过处理 不用经过鉴权



# 四、API鉴权权限

在configs.lua文件中配置redis信息和刷新redis权限接口信息，此信息由【权限系统】提供

权限验证步骤如下：

- 获取cook信息，得到auth_key
- 根据私钥及加密算法解密auth_key
- 得到用户ID
- 获取当前uri及method
- redis中查询用户id的权限列表进行匹配
- 匹配不通过则rewrite login



在这里来测试 devops服务的job接口

​	原接口地址：http://devops.shinezone.net.cn/xxxx/

​	现接口地址：http://gw.shinezone.net.cn/devops/xxxx/

测试：

​        首次访问 http://gw.shinezone.net.cn/devops/xxxx/ 跳转到login页面登录

​        登录成功,再次访问进行uri鉴权,鉴权成功则如下

![img](images/01.png)



# 四、API限速

在configs.lua文件中配置limit,配置示例如下

```lua
limit_conf = {
    rate = 5,   --限制ip每分钟只能调用n*60次接口
    burst = 10, 	 --桶容量,用于平滑处理,最大接收请求次数
}
```

次配置为每秒5个并发请求，并临时允许超出10个请求并平滑处理掉：

测试：（最好先关闭权限验证，方便测试）

```shell
ab -c 100 -n 1000 http://gw.shinezone.net.cn/cron/v1/cron/log/
```
可以看到,差不多有21个请求是成功的
```bash
Document Path:          /cron/v1/cron/log/
Document Length:        11852 bytes

Concurrency Level:      100
Time taken for tests:   3.982 seconds
Complete requests:      1000
Failed requests:        979
```

再试试 并发5个请求 如下:
```shell
ab -c 5 -n 1000 http://gw.shinezone.net.cn/cron/v1/cron/log/ 
```
```bash
Document Path:          /cron/v1/cron/log/
Document Length:        11852 bytes

Concurrency Level:      5
Time taken for tests:   199.811 seconds
Complete requests:      1000
Failed requests:        0
Write errors:           0
```



# 五、日志记录

在configs.lua文件中配置log地址及redis channel

- get请求日志会访日本地log
- 非get请求会发送给redis channel 需要自己接受记录

```bash
[root@CentOS7-Shinezone /var/log]#tailf gw.log
{"time":"2018-09-19 10:44:48","uri":"\/devops\/api\/v1.0\/job\/","login_ip":"172.16.0.121","method":"GET"}
{"time":"2018-09-19 10:44:48","uri":"\/devops\/api\/v1.0\/job\/","login_ip":"172.16.0.121","method":"GET"}
```

```
[root@CentOS7-Shinezone /var/log]#redis-cli -h 127.0.0.1 -p 6379
127.0.0.1:6379> SUBSCRIBE gw
Reading messages... (press Ctrl-C to quit)
1) "subscribe"
2) "gw"
3) (integer) 1


1) "message"
2) "gw"
3) "{\"time\":\"2018-09-19 10:48:52\",\"uri\":\"\\/devops\\/api\\/v1.0\\/job\\/\",\"login_ip\":\"172.16.80.12\",\"method\":\"POST\"}"
```