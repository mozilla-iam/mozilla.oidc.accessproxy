-- lua-resty-openidc options

-- Gets values from credstash
local function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

local function cs_get(key)
  local fe = os.getenv(split(key, ".")[2])
  if (fe) then
      return fe
  end

  local f = io.popen("/usr/bin/credstash -r "..aws_region.." get "..key.." app="..app_name)
  local r = f:read()
  f:close()
  return r
end

-- you probably want to change the app_name to something that is yours
-- and maybe opts as well. if not, make sure you have these values as env vars or in credstash (context is 'app')
app_name = 'proxied_app'
aws_region = 'us-west-2'
opts = {
  redirect_uri_path = "/redirect_uri",
  discovery = cs_get(app_name..".discovery_url"),
  client_id = cs_get(app_name..".client_id"),
  client_secret = cs_get(app_name..".client_secret"),
  scope = "openid email profile",
  iat_slack = 600,
  redirect_uri_scheme = "https",
  logout_path = "/logout",
  redirect_after_logout_uri = "https://sso.mozilla.com/logout",
  refresh_session_interval = 900
}
