#!/bin/bash
# Example test script assuming Kong listening at :8000 and Admin API at :8001
echo "Enabling plugin on service 'myservice' (assumes service exists)"
curl -s -i -X POST http://localhost:8001/services/myservice/plugins \\
  --data "name=kong-opafy" \\
  --data "config.opa_host=127.0.0.1" \\
  --data "config.opa_port=8181" | cat

echo
echo "Testing allowed path /hello"
curl -s -i http://localhost:8000/hello | sed -n '1,20p'

echo
echo "Testing forbidden path /forbidden"
curl -s -i http://localhost:8000/forbidden | sed -n '1,20p'
