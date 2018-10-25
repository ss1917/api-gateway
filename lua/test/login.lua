local mysql = require('mysql')
local jwt = require('jwt_token')
local my_verify = require('my_verify')

function login1(pargs)
    if pargs.username == nil or pargs.password == nil then
        ngx.say('[Error] 字段[username][password]不能为空!')
        return
    end

    local db = mysql.connect()
    if db == false then
        ngx.say('[Error] Mysql连接失败!')
        return
    end

    local res, err, errno, sqlstate = db:query("select uid from account where username=\'".. pargs.username .."\' and password=\'".. pargs.password .."\' limit 1", 1)
    if not res then
        ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
        return close_db(db)
    end

    if res[1] == nil then
        ngx.say('[Error] 用户名或密码错误!')
        ngx.exit(ngx.HTTP_FORBIDDEN)

    end

    local uid = res[1].uid

    -- 根据uid生成token
    --local token, rawtoken = tokentool.gen_token(uid)
    local token = jwt.encode_auth_token(uid)

    -- token写入cookie
    ngx.header['Set-Cookie'] = 'auth_key='.. token ..'; path=/; Expires=' .. ngx.cookie_time(ngx.time() + 60 * 90) -- 设置Cookie过期时间为90分钟

    -- 用户权限信息写入redis,key为用户id
    my_verify.write_permission(uid)

    ngx.say('[Success] 登录成功! [Token] '..token)
--    local ret = tokentool.add_token(token, rawtoken)
--    if ret == true then
--        ngx.say(token)
--    else
--        ngx.say('[Error] Token 写入redis失败!')
--        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
--    end
end


local postargs = json.decode(ngx.req.get_body_data())
login1(postargs)

--[[
http://172.16.0.121/api/login
{
	"username":"yangmv",
	"password":"123456"
}
--]]
