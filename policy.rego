package http.authz

default allow = false

allow {
  input.request.path == "/hello"
}
