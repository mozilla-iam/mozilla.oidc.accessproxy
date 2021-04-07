# Nginx Lua OpenID Connect Access Proxy
Wow that's a lot of words. What this is a reverse proxy that stands in front of your application. It proxies ALL calls,
no exception.
While doing so it can either pass ("whitelist") or require authentication, from an OIDC (OpenID Connect) provider.

This proxy uses the OpenResty version of Nginx, that has Lua support, and uses the [`lua-resty-openidc`](https://github.com/zmartzone/lua-resty-openidc) library for
authentication, as well as [`credstash`](https://github.com/fugue/credstash) to fetch credentials as needed.

## Setup
- Edit `etc/conf.d/server.lua` to your liking (in particular `app_name` and maybe `opts`)
- Ensure you have the same secrets configured in credstash on your AWS instance, if you plan to use that

For testing, or if credstash isn't being used, you can also pass secrets through environment variables:

- `discovery_url`: This is the well-known URL for your OIDC provider, such as
  `https://auth.mozilla.auth0.com/.well-known/openid-configuration`
- `client_id`: This is your OIDC identifier.
- `client_secret`: This is your shared OIDC secret.
- `backend`: This is the service to proxy.
- `allowed_group`: If set, only allow users in this group to log in.
- `httpsredir`: If set to `yes` then http will redirect automatically to https, otherwise it won't. (default: `yes`).
- `cookiename`: Sets the cookie/session name. Useful if you run multiple proxies with the same domain but different
  ports
- `sessionsecret`: Sets a session secret.

The Callback URL that the Mozilla OIDC Access Proxy uses is [`/redirect_uri`](https://github.com/mozilla-iam/mozilla.oidc.accessproxy/blob/76c7ef9b40a2f983b902977bafebc9e688e1ab61/etc/conf.d/server.lua#L35). You can provide this to the identity provider to add into the list of allowed callback URLs.

You can manually start this as such, if you like:

```
$ make build
$ make run
```

### AWS Deployment

- Read `cloudformation/README.md` and follow it's instructions
- Create a repository in ECR for the Docker image by following instructions at
  `https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/repositories/create/new` (or another region)
- Replace HUB_URL in the `Makefile` **and** in `compose/docker-compose.norebuild.yml`
- `make awslogin` (and wait a while until your image has been uploaded)


## Note
By default the Access Proxy does NOT configure TLS (HTTPS). This is up to you to either front it with an AWS ELB that
supports TLS, or to configure TLS. It is **very, very strongly** discouraged to run this access proxy without TLS. In
other words, do not do that, it's a terrible idea and will lead to compromise of your service.
If you need a certificate get it from LetsEncrypt for free.

## Config Structure

* `nginx.conf`
  * `conf.d/nginx_lua.conf`
  * `conf.d/headers.conf`
  * `conf.d/server.conf`
    * `conf.d/proxy_auth_bypass.conf` : optional
    * `conf.d/server.lua` : set the `opts` settings
    * `conf.d/openidc_layer.lua` : use `resty.openidc` to do OIDC auth
