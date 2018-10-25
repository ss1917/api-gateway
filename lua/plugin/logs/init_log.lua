local user_info = ngx.shared.user_info
local my_cache = require ("redis")

local _M = {}

function _M.send()
    -- 记录日志操作
    local method = ngx.req.get_method()
    local postargs = ngx.req.get_body_data()    --str
    -- local postargs = ngx.req.get_post_args() --table
    local data = {
        username = user_info.username,
        nickname = user_info.nickname,
        login_ip = ngx.var.remote_addr,
        method = method,
        uri = ngx.var.request_uri,
        data = postargs
    }
    local time = os.date('%Y-%m-%d %H:%M:%S')
    data['time'] = time
    local new_data = json.encode(data)

    if method == "GET" then
        file = io.open(logs_file, "a+")
        file:write(new_data..'\n')
        file:close()
    else
        my_cache.publish(redis_config.channel,new_data)
    end
end

return _M