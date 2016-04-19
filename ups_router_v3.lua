--ups_router_v3.lua
local headers = ngx.req.get_headers()
local apikey = headers["apikey"]
local redis_host = '127.0.0.1'
local redis_port = 6379

local redis = require "resty.redis"
local red = redis:new()
redis.add_commands("keys")
red:set_timeout(1000)  -- 1 second

local ok,err = red:connect(redis_host , redis_port)
if not ok then 
	ngx.say("failed to connect: ", err)
	return
end


local function check_apikey_match (apikey)

	local all_redis_keys,err = red:keys("*")

	for i,v in pairs (all_redis_keys) do
		
		if v == apikey then
			local upstream_name,err =  red:get(v)

			if not upstream_name then 
				ngx.say("failed to get upstream",":",v, err)
				return

			elseif upstream_name == ngx.null then 
				ngx.say("upstream not found.")
				return			
			end
			ngx.var.target = upstream_name				
		end		
	end
end
check_apikey_match(apikey)









