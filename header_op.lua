local headers = ngx.req.get_headers()
--ngx.say(headers["Host"])
--ngx.say(headers["User-agent"])
--ngx.say(headers["Dad"])
if headers["Dad"] == "diao" then
	--ngx.say(headers["Dad"])
	return
elseif headers["Dad"] == "cat" then
	ngx.say(ngx.unescape_uri("b%20r56+7"))
else
	ngx.exit(502)
end