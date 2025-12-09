local http = require "resty.http"

local KongOPAfy = {
  PRIORITY = 1200,
  VERSION = "0.1.0",
}

function KongOPAfy:access(conf)
  local req = kong.request.get_raw_body()
  local httpc = http.new()

  local res, err = httpc:request_uri(conf.opa_url, {
    method = "POST",
    body = req or "{}",
    headers = {
      ["Content-Type"] = "application/json"
    }
  })

  if not res then
    return kong.response.exit(500, { message = "OPA connection error", error = err })
  end

  local decoded = kong.json.decode(res.body or "{}")

  if not decoded.allow then
    return kong.response.exit(403, { message = "OPA denied the request" })
  end
end

return KongOPAfy