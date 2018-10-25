module("redis", package.seeall)
local redis = require "resty.redis"
local aes = require "resty.aes"
local str = require "resty.string"

local function connect()
    local red = redis:new()
    red:set_timeout(1000)
    local ok, err = red:connect(redis_config['host'], redis_config['port'])
    if not ok then
        return false
    end
    red:auth(redis_config['auth_pwd'])
    ok, err = red:select(redis_config['db'])
    if not ok then
        return false
    end
    return red
end

function add_token(token, raw_token)
    local red = connect()
    if red == false then
        return false
    end

    local ok, err = red:setex(token, redis_config['alive_time'], raw_token)
    if not ok then
        return false
    end
    return true
end

-- 用户权限信息写入redis
function sadd(k, v)
    local red = connect()
    if red == false then
        return false
    end

    local ok, err = red:sadd(k,v)
    if not ok then
        return false
    end
    return true
end

-- 读取用户权限信息
function smembers(k)
    local red = connect()
    if red == false then
        return false
    end
    local res, err = red:smembers(k)
    if not res then
        return false
    end
    return res
end

function del_token(token)
    local red = connect()
    if red == false then
        return
    end
    red:del(token)
end

function has_token(token)
    local red = connect()
    if red == false then
        return false
    end

    local res, err = red:get(token)
    if not res then
        return false
    end
    return res
end

-- 发布消息
function publish(channel,msg)
    local red = connect()
    if red == false then
        return false
    end

    local ok, err = red:publish(channel,msg)
    if not ok then
        return false
    end
    return true
end


-- 根据uid生成token,不用了
function gen_token(uid)
    local rawtoken = uid .. " " .. ngx.now()
    local aes_128_cbc_md5 = aes:new("friends_secret_key")
    local encrypted = aes_128_cbc_md5:encrypt(rawtoken)
    local token = str.to_hex(encrypted)
    return token, rawtoken
end

