# Configure a service and a route that we can use to test
#Create a service for openid connect
resource "konnect_gateway_service" "httpbin" {
  name             = "HTTPBin"
  protocol         = "http"
  host             = "httpbin.konghq.com"
  port             = 443
  path             = "/"
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
}

#Create a service with key-auth plugin
resource "konnect_gateway_service" "httpbin-keyauth" {
  connect_timeout = 60000
  enabled = true
  host = "httpbin.konghq.com"
  name = "httpbin-keyauth"
  port = 80
  protocol = "http"
  read_timeout = 60000
  retries = 5
  write_timeout = 60000
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
}
#Attach the key auth plugin to service
resource "konnect_gateway_plugin_key_auth" "my_key_auth" {
  config = {
    key_in_body = false
    key_in_header = true
    key_in_query = true
    key_names = [
      "apikey"
    ]
  }
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
  service = {
    id = konnect_gateway_service.httpbin-keyauth.id
  }
}


#Create Routes
#create route for /response-headers
resource "konnect_gateway_route" "response-headers" {
  methods = ["GET"]
  name    = "response-headers"
  paths   = ["/response-headers"]

  strip_path = false

  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
  service = {
    id = konnect_gateway_service.httpbin-keyauth.id
  }
}

#Add ACL plugins to the response-headers route
resource "konnect_gateway_plugin_acl" "my_response-headers-acl" {
  config = {
    allow = []
    deny = [
      "External"
    ]
  }
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
  route = {
    id = konnect_gateway_route.response-headers.id
  }
}

#Add route for /anything
resource "konnect_gateway_route" "anything" {
  methods = ["GET"]
  name    = "Anything"
  paths   = ["/anything"]

  strip_path = false

  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
  service = {
    id = konnect_gateway_service.httpbin-keyauth.id
  }
}

#Add Mtls Plugin for /anything route
resource "konnect_gateway_plugin_mtls_auth" "my_mtls_auth" {
  config = {
    authenticated_group_by = "CN"
    ca_certificates = [
       konnect_gateway_ca_cert.my_ca_certificate.id
    ]
    consumer_by = []
    skip_consumer_lookup = true
  }
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
  route = {
    id = konnect_gateway_route.anything.id
  }
}

#Add Basic Auth Plugin for /anything route
resource "konnect_gateway_plugin_basic_auth" "my_basic_auth" {
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
  route = {
    id = konnect_gateway_route.anything.id
  }
}

#create route for /headers
resource "konnect_gateway_route" "headers" {
  methods = ["GET"]
  name    = "Headers"
  paths   = ["/headers"]

  strip_path = false

  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
  service = {
    id = konnect_gateway_service.httpbin.id
  }
}

#Add openid to the /header route
resource "konnect_gateway_plugin_openid_connect" "my_headers_openid_connect" {
  config = {
    auth_methods = [
      "authorization_code",
      "session"
    ]
    client_id = [
      "a5e8eaed-5db9-415b-90b6-99f55e9241cc"
    ]
    client_secret = [
      "n-08Q~h1ip0P4aqJNL2ffkX8D40YDW1VgaAlRaW9"
    ]
    issuer = "https://login.microsoftonline.com/f177c1d6-50cf-49e0-818a-a0585cbafd8d/v2.0"
    redirect_uri = [
      "https://48.194.96.60/headers"
    ]
    scopes = [
      "openid",
      "email",
      "profile",
      "a5e8eaed-5db9-415b-90b6-99f55e9241cc/.default"
    ]

    ssl_verify = false
  }
  control_plane_id = konnect_gateway_control_plane.my_konnect_cp.id
  route = {
    id = konnect_gateway_route.headers.id
  }
}



