local  redis = require "resty.redis"


local red = redis:new()

red:set_timeout(1000)  -- 1 second

local ok,err = red:connect("127.0.0.1" , 6379)
if not ok then 
	ngx.say("failed to connect: ", err)
	return
end

ok,err = red:set("upstream", "10.100.112.162")
if not ok then 
	ngx.say("failed to set upstream:" , err)
	return
end

ngx.say("set result: ", ok)	

local res,err =  red:get("upstream")
if not res then 
	ngx.say("failed to get upstream: ", err)
	return
end

if res == ngx.null then 
	ngx.say("dog not found.")
	return
end

ngx.say("dog: ", res)


