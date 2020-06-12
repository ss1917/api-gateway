local limit_req = require "plugin.limit.limit_req"
local auth_check = require "plugin.auth.auth_check"
local init_log = require "plugin.logs.init_log"
local upstream = require "upstream"
local tools = require "tools"

limit_req.incoming() --限速,限制每秒请求数

-- 获取访问URI
local url_path_list = tools.split(ngx.var.request_uri, '/')
local svc_code = url_path_list[2] -- 取第二位
--
table.remove(url_path_list,1)
real_new_uri = tools.list_to_str(url_path_list,'/')
--
-- 不用鉴权的URI
if svc_code == 'accounts' or svc_code == 'favicon.ico' then
    ngx.log(ngx.ERR, 'acc-->>>', svc_code)
else
    -- 获取真实的URI
    auth_check.check(real_new_uri) --权限验证
    init_log.send(real_new_uri) --记录日志
end
upstream.set(real_new_uri) --匹配upstream