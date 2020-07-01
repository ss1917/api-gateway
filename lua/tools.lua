module("tools", package.seeall)
local ngx_re = require "ngx.re"

function split(s, p)
    -- 字符串切割
    local rt = {}

    -- 对问号分割做转义
    if p == "?" then
        p = "\\?"
    end
    
    local res = ngx_re.split(s, p)
    if res then
        if res[1] == "" then
            table.remove(res, 1)
        end
        rt = res
    else
        table.insert(rt, 1, s)
    end

    return rt
end

function list_to_str(list,x)
    local st = ''
    for i,v in ipairs(list) do
        st = st..x..v
    end
    st = st..x
    return st
end

function match(s,p)
    local s_end = string.sub(s,-1,-1)
    local p_end = string.sub(p,-1,-1)
    if s_end ~= '/' then
        s = s..'/'
    end
    if p_end ~= '/' then
        p = p..'/'
    end
    local ret = string.match(s,'^'..p)
    return ret
end
