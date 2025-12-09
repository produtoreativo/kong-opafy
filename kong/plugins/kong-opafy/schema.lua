local typedefs = require "kong.db.schema.typedefs"

return {
  name = "kong-opafy",
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    {
      config = {
        type = "record",
        fields = {
          { opa_url = { type = "string", required = true } },
        },
      },
    },
  },
}