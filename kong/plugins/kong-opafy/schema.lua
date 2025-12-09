local PLUGIN_NAME = "kong-opafy"

return {
  name = PLUGIN_NAME,
  fields = {
    { config = {
        type = "record",
        fields = {
          { opa_host = { type = "string", required = true }, },
          { opa_port = { type = "number", default = 8181 }, },
          { include_consumer = { type = "boolean", default = false }, },
          { timeout = { type = "number", default = 5000 }, },
        },
      },
    },
  },
}
