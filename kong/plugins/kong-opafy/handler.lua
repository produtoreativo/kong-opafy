local cjson = require "cjson"
local http = require "resty.http"

local KongOPAfy = {
  PRIORITY = 900,
  VERSION = "0.1.0",
}

function KongOPAfy:access(config)
  -- monta o input para o OPA
  local input = {}

  if config.include_headers then
    input.headers = kong.request.get_headers()
  end

  if config.include_query then
    input.query = kong.request.get_query()
  end

  if config.include_body then
    local body_raw = kong.request.get_raw_body()

    if body_raw then
      -- tenta decodificar o JSON
      local ok, decoded = pcall(cjson.decode, body_raw)

      if ok then
        input.body = decoded
      else
        input.body = body_raw  -- fallback
      end
    end
  end

  -- prepara chamada HTTP
  local httpc = http.new()
  httpc:set_timeout(config.timeout or 2000)

  local url = config.opa_url .. "/v1/data/authz/allow"

  print("============================ OPA INPUT PAYLOAD 1 ==================================")

  kong.log.inspect(input, "OPA INPUT PAYLOAD 2")
  kong.log.inspect(cjson.encode({ input = input }), "OPA INPUT PAYLOAD 3")


  print("============================ OPA INPUT PAYLOAD 1 ==================================")

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