local cjson = require "cjson"
local http = require "resty.http"

local KongOPAfy = {
  PRIORITY = 900,
  VERSION = "0.1.0",
}

function KongOPAfy:access(config)
  -- monta o input para o OPA

  local input = {
    method = kong.request.get_method(),
    path   = kong.request.get_path(),
    raw_path = kong.request.get_raw_path(),
    headers = kong.request.get_headers(),
    host = kong.request.get_host(),
    scheme = kong.request.get_scheme(),
    port = kong.request.get_forwarded_port(),
    query = kong.request.get_query(),

    route = kong.router.get_route(),
    service = kong.router.get_service(),

    consumer = kong.client.get_consumer(),
    credential = kong.client.get_credential(),
    ip = kong.client.get_forwarded_ip()
  }

  if body_raw then
    -- tenta decodificar o JSON
    local ok, decoded = pcall(cjson.decode, body_raw)

    if ok then
      input.body = decoded
    else
      input.body = body_raw  -- fallback
    end
  end

  -- prepara chamada HTTP
  local httpc = http.new()
  httpc:set_timeout(config.timeout or 2000)

  local url = config.opa_url .. "/v1/data/authz/allow"

  kong.log.inspect(input, "OPA INPUT PAYLOAD 2")

  local res, err = httpc:request_uri(url, {
    method = "POST",
    body = cjson.encode({ input = input }),
    headers = {
      ["Content-Type"] = "application/json",
    },
    ssl_verify = false,
  })

  if not res then
    return kong.response.error(500, "OPA connection error: " .. tostring(err))
  end

  local ok, opa_result = pcall(cjson.decode, res.body or "")

  if not ok then
    return kong.response.error(500, "OPA invalid response")
  end

  if opa_result.result == true then
    return -- permitido
  end

  return kong.response.exit(403, { message = "Access denied by OPA" })
end

return KongOPAfy