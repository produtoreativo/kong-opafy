KongOPAfy (plugin id: kong-opafy)
=================================

This is the Kong plugin "KongOPAfy" (plugin id `kong-opafy`) — a rename of `pr-kong-opa`.
It integrates Kong OSS with an external Open Policy Agent (OPA) server for authorization checks.

Installation notes
------------------
1. Ensure Kong 3.8 (OSS) is installed.
2. Install dependencies on the Kong node(s):

   luarocks install lua-resty-http
   luarocks install lua-cjson

3. Copy plugin into Lua path or install via rockspec at repo root.

4. Configure Kong to load custom plugin:

   export KONG_CUSTOM_PLUGINS=kong-opafy
   # or add to kong.conf: plugins = bundled,kong-opafy

5. Install the rockspec and restart Kong:

   luarocks make kong-opafy-0.1.0-1.rockspec
   kong restart

Enable the plugin for a service/route via Admin API:

   curl -i -X POST http://localhost:8001/services/myservice/plugins \
     --data "name=kong-opafy" \
     --data "config.opa_host=127.0.0.1" \
     --data "config.opa_port=8181"

Example OPA policy (policy.rego)
--------------------------------
package http.authz

default allow = false

allow {
    input.request.path == "/hello"
}

Testing
-------
1. Run OPA: opa run --server --watch policy.rego
2. Call Kong proxy endpoints:

   curl http://localhost:8000/hello       # 200 OK allowed by policy
   curl http://localhost:8000/forbidden   # 403 Forbidden
