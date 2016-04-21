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
	elseif value == ngx.null then
		return fail("key not found,",err)
	end
	return value

end



local function get_upstream(key,redis_host,redis_port)

	if not key then
		return 
	end
	--SHM cache process
	--step 1:
	local upstream_name,err = cache:get(key)
	if upstream_name then 
		return upstream_name
	end

	if err then 
		return fail("failed to get key from shm:",err)
	end

	--//ngx.print(upstream_name)
	--cache miss!
	--step 2, lock the key:	
	local lock = resty_lock:new("my_locks")
	local elapsed,err = lock:lock(key)
	if not elapsed then
		return fail("failed to acquire the lock: ",err)
	end
	--lock successfully acquired!

	--step3:
	--someone might have already put the upstream_nameue into the cache
	--so check it here again:
	upstream_name,err = cache:get(key)
	if upstream_name then
		local ok,err = lock:unlock()
		if not ok then
			return fail("failed to unlock: ",err)
		end
		return upstream_name
	end
	--step4:

	local upstream_name = fetch_redis(redis_host,redis_port,key)
	if not upstream_name then
		local ok,err = lock:unlock()
		if not ok then
			return fail("failed to unlock: ",err)
		end
		ngx.say("no value found in redis")
		return 
	end

	--update the shm cache with the newly fetched value
	local ok,err = cache:set(key,upstream_name,1)
	if not ok then 
		local ok,err = lock:unlock()
		if not ok then
			return fail("failed to unlock: ",err)
		end
		return fail("failed to update shm cache: ",err)
	end

	local ok,err = lock:unlock()
	if not ok then 
		return fail("failed to unlock",err)
	end
	return upstream_name
end


--Check if request has apikey in the headers
if not apikey then
	ngx.say("Please Offer apikey in the headers")
end	


local upstream = get_upstream(apikey,redis_host,redis_port)
ngx.var.target = upstream
--//ngx.print(upstream)       
