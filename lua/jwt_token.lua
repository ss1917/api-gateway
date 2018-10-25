module("jwt_token", package.seeall)
local jwt = require "resty.jwt"

function encode_auth_token(uid)
    local jwt_token = jwt:sign(
        token_secret,
        {
            header={typ="JWT", alg="HS256"},
            payload={
                foo="bar",
                data={
                    user_id=uid,
                }
            }
        }
    )
    return jwt_token
end


function decode_auth_token(auth_token)
    local load_token = jwt:load_jwt(
        auth_token,
        token_secret
    )
    return load_token
end

--local jwt_token = encode_auth_token(token_secret,1)
--local load_token = decode_auth_token('eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MzUxOTMwMzksIm5iZiI6MTUzNTEwNjYxOSwiaWF0IjoxNTM1MTA2NjI5LCJpc3MiOiJhdXRoOiBzcyIsInN1YiI6Im15IHRva2VuIiwiaWQiOiIxNTYxODcxODA2MCIsImRhdGEiOnsidXNlcl9pZCI6IjE0IiwidXNlcm5hbWUiOiJ5YW5nbWluZ3dlaSIsIm5pY2tuYW1lIjoiXHU2NzY4XHU5NGVkXHU1YTAxIn19.GucrQnWIVsWL-0nTqef5eLFAVzBRjsuUp_L9oasRGRQ')
--ngx.say(json.encode(load_token))