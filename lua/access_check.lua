local limit_req = require "plugin.limit.limit_req"
local auth_check = require "plugin.auth.auth_check"
local init_log = require "plugin.logs.init_log"
local upstream = require "upstream"

limit_req.incoming()     --限速,限制每秒请求数
auth_check.check()       --权限验证
init_log.send()          --记录日志
upstream.set()          --匹配upstream

