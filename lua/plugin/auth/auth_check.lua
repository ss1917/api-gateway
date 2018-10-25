local jwt = require('jwt_token')
local my_verify = require('my_verify')
local user_info = ngx.shared.user_info

local _M = {}

function _M.check()
    -- 获取cook
    local auth_key = ngx.var.cookie_auth_key

    if auth_key == nil then
        ngx.var.login_uri = login_uri
        ngx.exec("/login")
        -- ngx.redirect('http://aaaa.shinezone.net.cn:8888/login/')
        return
    end

    -- 解密auth_key
    local load_token = jwt.decode_auth_token(auth_key)
    -- ngx.log(ngx.ERR,'load_token--->',json.encode(load_token))

    -- 获得用户id
    local user_id = load_token.payload.data.user_id
    ngx.log(ngx.ERR,'user_id--->',user_id)
    user_info['username'] = load_token.payload.data.username
    user_info['nickname'] = load_token.payload.data.nickname

    -- 获取当前uri
    local uri = ngx.var.request_uri
    -- ngx.say('uri---> ',uri)

    -- 获取请求方法
    local method = ngx.req.get_method()

    -- 根据用户id获取权限列表(从权限系统redis获取)
    local is_permission =  my_verify.get_verify(user_id,uri,method)
    if is_permission ~= true then
        -- 第一次没有就先刷新下redis
        my_verify.write_verify(user_id)
        local is_permission =  my_verify.get_verify(user_id,uri,method)
        if is_permission ~= true then
            my_verify.write_permission(user_id)
            -- ngx.say('403')
            -- ngx.exit(403)
            ngx.exit(ngx.HTTP_FORBIDDEN)
            return
        end
    end

    ---- 根据用户id获取权限列表(本地测试redis)
    --local is_permission =  my_verify.get_permission(user_id,uri)
    ---- ngx.say('is_permission---> ',is_permission)
    --if is_permission ~= true then
    --    -- 第一次没有就先刷新下redis
    --    my_verify.write_permission(user_id)
    --    local is_permission =  my_verify.get_permission(user_id,uri)
    --    if is_permission ~= true then
    --        my_verify.write_permission(user_id)
    --        ngx.say('没有权限访问该URI')
    --        return
    --    end
    --end
end

return _M