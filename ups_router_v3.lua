-- Copyright (C) RogerPu (espwj@126.com), Plateno Groups Inc.

local headers = ngx.req.get_headers()
local apikey = headers["apikey"]
local redis_host = '127.0.0.1'
local redis_port = 6379

local redis = require "resty.redis"
local red = redis:new()
--redis.add_commands("keys")
red:set_timeout(1000)  -- 1 second

local ok,err = red:connect(redis_host , redis_port)
if not ok then 
	ngx.say("failed to connect upstream configure Redis: ", err)
	return
end

--Check if request has apikey in the headers
if apikey == nil then
	ngx.say("Please Offer apikey in the headers")
end

--Macth the header and get the right upstream and return to Nginx
local function check_apikey_match (apikey)

	local apikey_map_value,err = red:get(apikey)		
	
	if not apikey_map_value then 
		ngx.say("failed to get upstream",":",v, err)
		return

	elseif apikey_map_value == ngx.null then 
		ngx.say("upstream not found.")
		return			
	end
	ngx.var.target = apikey_map_value				
			
end
check_apikey_match(apikey)









