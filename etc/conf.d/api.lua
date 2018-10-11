if session ~= nil then
  ngx.log(ngx.ERR, "No session set, but we're supposed to be authenticated!")
  ngx.say("Please authenticate")
  ngx.status = 401
  ngx.exit(401)
end

local endpoint = "{
  \"user_id\": \""+session.data.user.sub+"\",
  \"primary_email\": \""+session.data.user.email+"\",
  \"first_name\": \""+session.data.user.given_name+"\",
  \"last_name\": \""++session.data.user.family_name+"\"
}"

ngx.header.content_type = "application/json; charset=utf-8"
ngx.status = ngx.HTTP_OK
ngx.say(endpoint)
ngx.exit(ngx.HTTP_OK)
