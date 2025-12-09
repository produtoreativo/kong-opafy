# KongOPAfy

`KongOPAfy` is a lightweight Kong OSS plugin (plugin id: `kong-opafy`) that integrates Kong Gateway with Open Policy Agent (OPA) for authorization.

Key points:
- Plugin id: kong-opafy (use this name in Admin API)
- Human name: KongOPAfy

Quick start:
1. Install dependencies:
   luarocks install lua-resty-http
   luarocks install lua-cjson
2. Install the plugin:
   luarocks make kong-opafy-0.1.0-1.rockspec
3. Configure Kong to load it and enable for a service or route.

Example OPA policy available in kong/plugins/kong-opafy/README_PLUGIN.md
