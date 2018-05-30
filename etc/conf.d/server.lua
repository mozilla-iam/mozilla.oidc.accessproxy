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

-- See also https://github.com/zmartzone/lua-resty-openidc#sample-configuration-for-google-signin for more options
opts = {
  redirect_uri_path = "/redirect_uri",
  discovery = cs_get(app_name..".discovery_url"),
  client_id = cs_get(app_name..".client_id"),
  client_secret = cs_get(app_name..".client_secret"),
  scope = "openid email profile",
  iat_slack = 600,
  redirect_uri_scheme = "https",
  logout_path = "/logout",
  redirect_after_logout_uri = "https://sso.mozilla.com/forbidden",
  -- The following options are used to verify a user session should be kept running and that the user is still valid
  -- refresh_session_interval will 302 the user's browser every X amount of seconds (here, 900) transparently
  -- renew_access_token_on_expiry will use an access or refresh token with a server-side request. If you use the later
  -- make sure you enable all 3 options: renew_access_token_on_expiry,access_token_expires_in,access_token_expires_leeway
  -- or understand the consequences of not doing so.
  --
  --renew_access_token_on_expiry = true
  --access_token_expires_in = 900
  --access_token_expires_leeway = 60
  refresh_session_interval = 900
  --proxy_opts = {
  -- http_proxy  = "http://insert_proxy_hostname:3128",
  -- https_proxy = "http://insert_proxy_hostname:3128"
  --}
}
