local rabbitmq = require "resty.rabbitmqstomp"
local _M = {}


function _M.send()
    -- send log to mq
    local opts = { username = "guest",
               password = "guest",
               vhost = "/" }

    local mq, err = rabbitmq:new(opts)
    if not mq then
        ngx.log(ngx.ERR, "cannot new mq-------->")
        return
    end
    ngx.log(ngx.ERR, "send mq-22222------->")
    mq:set_timeout(10000)

    local ok, err = mq:connect('127.0.0.1',61613)

    if not ok then
        ngx.log(ngx.ERR, "cannot connect mq-------->"..err)
        return
    end
    ngx.log(ngx.ERR, "connect mq ok ------->")

    local msg = {key="value1", key2="value2"}

    local headers = {}
    -- 消息发送到哪里 /exchange/交换机名称/routing_key名称
    headers["destination"] = "/exchange/test/binding"
    headers["receipt"] = "msg#1"
    headers["app-id"] = "luaresty"
    -- 是否持久化
    headers["persistent"] = "true"
    -- 消息格式
    headers["content-type"] = "application/json"

    local ok, err = mq:send(json.encode(data), headers)
    if not ok then
        ngx.log(ngx.ERR, "cannot send mq ------->")
        return
    end
    ngx.log(ngx.INFO, "Published: " .. msg)

--    -- 消息保持长连接，第一个参数表示连接超时时间，第二个参数是表示连接池大小
--    -- 由于 rabbitmq 连接建立比较耗时，所以保持连接池是非常必要的
--    local ok, err = mq:set_keepalive(10000, 500)
--    if not ok then
--        ngx.log(ngx.ERR, err)
--        return
--    end


end


function _M.subscribe( self, channel )
    -- send log to redis
    local redis, err = redis_c:new()
    if not redis then
        return nil, err
    end

    local ok, err = self:connect_mod(redis)
    if not ok or err then
        return nil, err
    end

    local res, err = redis:subscribe(channel)
    if not res then
        return nil, err
    end

    local function do_read_func ( do_read )
        if do_read == nil or do_read == true then
            res, err = redis:read_reply()
            if not res then
                return nil, err
            end
            return res
        end

        redis:unsubscribe(channel)
        self.set_keepalive_mod(redis)
        return
    end

    return do_read_func
end


return _M