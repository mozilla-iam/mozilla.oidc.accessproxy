- emulate a /authorize endpoint for API in the proxy
- remove /userinfo
- send back an id token jwt and access token from the OP via the proxy so that SPA think we're a real OP authorizer
- profit


Note: this means SPA cannot use the discovery urls, but would have to specify authorize endpoints separately from the
jwks url (used to fetch the pub keys to verify tokens), eg:
authorize: https://proxyhere.com/authorize
jwks: https://auth.mozilla.auth0.com/....
