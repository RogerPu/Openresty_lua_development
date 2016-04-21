-- Copyright (C) RogerPu (espwj@126.com), Plateno Groups Inc.

local headers = ngx.req.get_headers()
local apikey = headers["apikey"]
local redis_host = '127.0.0.1'
local redis_port = 6379
local resty_lock = require "resty.lock"
local cache  = ngx.shared.share_dict_cache
local redis = require "resty.redis"

local function fetch_redis(redis_host,redis_port,key)

	local red = redis:new()
	red:set_timeout(1000)  -- 1 second

	local ok,err = red:connect(redis_host , redis_port)
	if not ok then 
		return fail("failed to connect upstream configure Redis: ", err)
	end

	local value,err = red:get(key)
	if not value then 
		return fail("failed to get upstream: ",err)
	elseif value = ngx.null then
		return fail("key not found,",err)
	end
	return value

end






--Check if request has apikey in the headers
if not apikey then
	ngx.say("Please Offer apikey in the headers")
end	

		






			
	










