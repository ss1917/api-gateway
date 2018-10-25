module("my_verify", package.seeall)
--local mysql = require('mysql')
local my_cache = require ("redis")
local http = require "resty.http"

function write_permission(user_id)
    local db = mysql.connect()
    if db == false then
        ngx.say('[Error] Mysql连接失败!')
        return
    end

    local select_sql = string.format("SELECT a.id,a.permission from permission a ,role_permission b,role c,user_role d,account e WHERE a.id=b.permission_id and c.id=b.role_id and d.role_id=c.id and d.user_id=e.uid and e.uid=%s;",user_id)
    local res, err, errno, sqlstate = db:query(select_sql)
    if not res then
        ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
        return close_db(db)
    end

    local permissions={}
    for i, row in ipairs(res) do
        for name, value in pairs(row) do
            if name == "permission" then
                table.insert(permissions, 1, value)
                my_cache.sadd(user_id, value)
            end
        end
    end
  return permissions
end

function get_permission(user_id,uri)
    my_verify = my_cache.smembers(user_id)
    for k,v in ipairs(my_verify) do
        -- ngx.log(ngx.ERR,'line----->',v)
        local is_exit = string.find(uri,"^"..v)
        if is_exit == 1 then
            return true
        end
    end
    return false
end


-- 对接权限系统的redis
function get_verify(user_id,uri,method)
    my_verify = my_cache.smembers(user_id..method)
    all_verify = my_cache.smembers(user_id..'ALL')

    for k,v in ipairs(my_verify) do
        --ngx.log(ngx.ERR,'line----->',v)
        local is_exit = string.find(uri,"^"..v)
        if is_exit == 1 then
            return true
        end
    end

    for k,v in ipairs(all_verify) do
        --ngx.log(ngx.ERR,'line----->',v)
        local is_exit = string.find(uri,"^"..v)
        if is_exit == 1 then
            return true
        end
    end
    return false
end

function write_verify(user_id)
    local httpc = http.new()
    local res, err = httpc:request_uri(
        rewrite_cache_url,
        {
            method = "POST",
            body = json.encode({
                user_id=user_id,
                secret_key=rewrite_cache_token
            }),
            headers = {
                ["Content-Type"] = "application/json"
            }
        }
    )
    if not res then
        ngx.say("failed to request: ", err)
        return
    end
    if 200 ~= res.status then
        ngx.exit(res.status)
    end
end

--local permissions = get_permission(28,'/home1')
--ngx.say(json.encode(permissions))





