--ups_router_v2.lua
local header = ngx.req.get_headers()
local res = ngx.location.capture("/redis",{args = { key = header }})

print("key:", key)

if res.status ~= 200 then
	ngx.log(ngx.ERR,"redis returned bad status",res.status)
	ngx.exit(res.status)
end

if not  res.body then
	ngx.log(ngx.ERR,"redis returned empty body")
	ngx.exit(500)
end

local parser = require "redis.parser"
local server,typ = parser.parse_reply(res.body)
if typ ~= parser.BULK_REPLY or not server then
	ngx.log(ngx.ERR,"bad redis response:",res.body)
	ngx.exit(500)
end

print("server:",server)

ngx.var.target = server




