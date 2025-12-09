local http = require "resty.http"
local cjson = require "cjson"
local BasePlugin = require "kong.plugins.base_plugin"

local KongOPAfy = BasePlugin:extend()
KongOPAfy.VERSION = "0.1.0"
KongOPAfy.PRIORITY = 900

function KongOPAfy:new()
  KongOPAfy.super.new(self, "kong-opafy")
end

function KongOPAfy:access(conf)
  KongOPAfy.super.access(self)

  local request = kong.request
  local input = {
    request = {
      method = request.get_method(),
      path = request.get_path(),
      query = request.get_query(),
      headers = request.get_headers(),
      body = request.get_raw_body(),
    }
  }

  if conf.include_consumer and kong.client.get_consumer then
    local consumer = kong.client.get_consumer()
    if consumer then
      input.consumer = { id = consumer.id, username = consumer.username }
    end
  end

  local opa_url = string.format("http://%s:%s/v1/data/http/authz/allow", conf.opa_host, conf.opa_port)
  local httpc = http.new()
  httpc:set_timeout(conf.timeout)

  local res, err = httpc:request_uri(opa_url, {
    method = "POST",
    body = cjson.encode({ input = input }),
    headers = { ["Content-Type"] = "application/json" }
  })

  if not res then
    kong.log.err("OPA request failed: ", err)
    return kong.response.exit(500, { message = "Internal Policy Error" })
  end

  if res.status ~= 200 then
    kong.log.err("OPA returned non-200: ", res.status, res.body)
    return kong.response.exit(500, { message = "Policy check failed" })
  end

  local body = cjson.decode(res.body)
  if body.result ~= true then
    return kong.response.exit(403, { message = "Forbidden" })
  end
end

return KongOPAfy
