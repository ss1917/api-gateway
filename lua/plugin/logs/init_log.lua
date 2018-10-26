local user_info = ngx.shared.user_info
local my_cache = require("redis")

local _M = {}

function _M.send()
    -- 记录日志操作
    local method = ngx.req.get_method()
    local postargs = ngx.req.get_body_data() --str
    -- local postargs = ngx.req.get_post_args() --table
    local data = {
        username = user_info.username,
        nickname = user_info.nickname,
        login_ip = ngx.var.remote_addr,
        method = method,
        uri = ngx.var.request_uri,
        data = postargs,
        time = os.date('%Y-%m-%d %H:%M:%S')
    }

    --  data['time'] = os.date('%Y-%m-%d %H:%M:%S')
    local new_data = json.encode(data)

    local this_file = io.open(logs_file, "a+")
    this_file:write(new_data .. '\n')
    this_file:close()

    if method ~= "GET" then
        my_cache.publish(redis_config.channel, new_data)
    end
end

return _M