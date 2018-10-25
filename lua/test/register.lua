local mysql = require('mysql')
local json = require("cjson")

function register1(pargs)
    -- 字段不能为空
    ngx.log(ngx.ERR,'username---->',pargs.username)
    if pargs.username == nil or pargs.email == nil or pargs.password == nil then
        ngx.say('[Error] 字段[username][email][password]不能为空!')
        return
    end

    local db = mysql.connect()
    if db == false then
        ngx.say('[Error] Mysql连接失败!')
        return
    end

    local res, err, errno, sqlstate = db:query("insert into account(username, password, email) "
                             .. "values (\'".. pargs.username .."\',\'".. pargs.password .."\',\'".. pargs.email .."\')")
    if not res then
	ngx.say('[Error] 用户注册失败!')
        return
    end
end

-- post args
local postargs = json.decode(ngx.req.get_body_data())
register1(postargs)


--[[
http://172.16.0.121/api/register
{
	"username":"yangmv",
	"email":"yangmv@qq.com",
	"password":"123456"
}
--]]