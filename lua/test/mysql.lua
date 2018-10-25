module("mysql", package.seeall)
local mysql = require "resty.mysql"

-- connect to mysql;
function connect()
    local db, err = mysql:new()
    if not db then
        return false
    end
    db:set_timeout(1000)

    local ok, err, errno, sqlstate = db:connect{
        host = "127.0.0.1",
        port = 3306,
        database = "lua",
        user = "root",
        password = "",
        max_packet_size = 1024 * 1024 }

    if not ok then
        return false
    end
    return db
end


