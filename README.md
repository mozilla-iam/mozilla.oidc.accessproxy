# Nginx Lua OpenID Connect Access Proxy
Wow that's a lot of words. What this is a reverse proxy that stands in front of your application. It proxies ALL calls,
no exception.
While doing so it can either pass ("whitelist") or require authentication, from an OIDC (OpenID Connect) provider.

This proxy use the OpenResty version of Nginx, that has Lua support, and uses the `lua-resty-openidc` library for
authentication, as well as `credstash` to fetch credentials as needed.

## Setup
- Edit etc/conf.d/server.lua to your liking (in particular `app_name` and maybe `opts`)
- Ensure you have the same secrets configured in credstash on your AWS instance, if you plan to use that

For testing, or if not using credstash you can also pass secret through environment variables:

- `discovery_url`: This is the well-known URL for your OIDC provider, such as
  `https://auth.mozilla.auth0.com/.well-known/openid-configuration`
- `client_id`: This is your OIDC identifier.
- `client_secret`: This is your shared OIDC secret.

You can manually start this as such, if you like:

```
$ docker run -p 8080:80 -e discovery_url=localhost -e client_id=1 -e client_secret=1 -ti openresty.mozilla.accessproxy:latest
```

## Note
By default the Access Proxy does NOT configure TLS (HTTPS). This is up to you to either front it with an AWS ELB that
supports TLS, or to configure TLS. It is **very, very strongly** discouraged to run this access proxy without TLS. In
other words, do not do that, it's a terrible idea and will lead to compromise of your service.
If you need a certificate get it from LetsEncrypt for free.
