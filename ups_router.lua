
local headers = ngx.req.get_headers()

local apikey = headers["apikey"]
local uri = ngx.var.uri

args = ngx.req.get_uri_args()

for key,val in pairs(args) do
	if type(val) == "table" then
		ngx.say(key, ":", table.concat( val, ", "))
	else
		ngx.say(key,":", val)
	end
end
--uri_decode = ngx.escape_uri(uri)
---ngx.print(uri_decode)
if apikey == "plateno1" then
	res = ngx.location.capture('/plateno1')
	ngx.print(res.body)
elseif apikey == "plateno2" then
	--plateno2_uri = '/' .. apikey .. uri
	--ngx.print(plateno2_uri)
	--res = ngx.location.capture(plateno2_uri)
	res = ngx.location.capture('/lua_code_test')
	ngx.say("you are in plateno2  lua phase")
	ngx.say(uri)
	ngx.print(res.body)
	ngx.print(res.status)
	--ngx.print(res.header)
else
	ngx.say('please give right apikey')
end