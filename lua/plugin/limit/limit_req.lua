local limit_req = require "resty.limit.req"

-- 限制 ip 每分钟只能调用 5*60 次 接口（平滑处理请求，即每秒放过5个请求）
-- 超过部分进入桶中等待，（桶容量为60），如果桶也满了，则进行限流
local lim, err = limit_req.new("my_limit_conn_store",limit_conf.rate,limit_conf.burst)

if not lim then  --没定义共享字典
    ngx.log(ngx.ERR, "failed to instantiate a resty.limit.conn object: ", err)
    return ngx.exit(500)
end

local _M = {}

function _M.incoming()
    -- 对于内部重定向或子请求，不进行限制。因为这些并不是真正对外的请求。
    if ngx.req.is_internal() then
        return
    end

    local key = ngx.var.binary_remote_addr
    local delay, err = lim:incoming(key, true)
    if not delay then
        if err == "rejected" then
            return ngx.exit(503)
        end
        ngx.log(ngx.ERR, "failed to limit req: ", err)
        return ngx.exit(500)
    end
    -- 此方法返回，当前请求需要delay秒后才会被处理，和他前面对请求数
    -- 所以此处对桶中请求进行延时处理，让其排队等待，就是应用了漏桶算法
    if delay >= 0.001 then
        ngx.sleep(delay)
    end
end

return _M




