-- @Author: RogerPu
-- @Date:   2016-08-09 11:44:57
-- @Last Modified by:   RogerPu
-- @Last Modified time: 2016-08-11 15:02:02

uri_black = {'/icac','/plateno'}
CCDeny=true
CCrate="10/10" -- 100 counts, per 60 sec.


function get_client_ip()
	ip = ngx.var.remote_addr
	if ip == nil then
		ip = "unknown"
	end
	return ip
end

function ccdeny(uri)
	CCcount = tonumber(string.match(CCrate,'(.*)/'))
	CCseconds = tonumber(string.match(CCrate,'/(.*)'))
	local limit = ngx.shared.limit
	local token = get_client_ip()..uri
	local req,_ = limit:get(token)
	if req then
		if req > CCcount then
			ngx.exit(503)
			return true
		else
			limit:incr(token,1)
		end 
	else 
		limit:set(token,2,CCseconds)
	end
	return false
end

function main()
	local uri = ngx.var.uri
	if CCDeny then 
		for _,rules in pairs(uri_black) do
			if rules ~= nil then
				if ngx.re.match(uri,rules,"isjo") then
					-- ngx.log(ngx.ERR,"start ccdeny: ",uri)
					ccdeny(uri)					
				end
			end
		end
	end
end
 
main()

