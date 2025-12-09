package = "kong-opafy"
version = "0.1.0-1"
source = { url = "file://." }
description = {
  summary = "Kong OSS plugin KongOPAfy for OPA authorization",
  detailed = "Sends request data to an external OPA server and enforces policies.",
  homepage = "https://github.com/your-repo/kong-opafy",
  license = "MIT",
}
dependencies = { "lua >= 5.1", "kong >= 3.8", "lua-resty-http" }
build = { type = "none" }
