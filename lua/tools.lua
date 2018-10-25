module("tools", package.seeall)
function split(s, p)
    -- 字符串切割
    local rt = {}
    string.gsub(s, '[^' .. p .. ']+', function(w)
        rt[#rt + 1] = w
        --table.insert(rt, w)
    end )
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
