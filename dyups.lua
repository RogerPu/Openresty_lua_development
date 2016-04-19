local redis_op = require "resty.redis"

local red = redis_op:new()

red:set_timeout(1000)  --1 second

local ok,err = red:connect("127.0.0.1", 6379)
if not ok then 
	ngx.say("failed to connect redis: ",err)
	return
end

local upstream_addr,err = red:get("upstream_addr")
if  not upstream_addr  then 
	ngx.say("failed to get upstream_addr: ",err)
	return
end

if upstream_addr == ngx.null then 
	ngx.say("upstream_addr not found", err)
	return
end

ngx.say("upstream_addr :", upstream_addr)


local  url = 'http://' .. upstream_addr .. '/2.html'

local res = ngx.location.capture('proxy',
	{ args = {url = url}}
	)
ngx.print(res.body)

