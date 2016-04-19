--lua_code_test.lua

local uri = ngx.var.request_uri

ngx.print(uri'\n')