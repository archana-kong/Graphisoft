# Create a consumer and a basic auth credential for that consumer
resource "konnect_gateway_consumer" "joe" {
  username         = "joe"
  custom_id        = "joe"
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
}

# Then a consumer group, and add the consumer to a group
/*resource "konnect_gateway_consumer_group" "graphisoft" {
  name             = "graphisoft"
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
}

resource "konnect_gateway_consumer_group_member" "client1" {
  consumer_id       = konnect_gateway_consumer.joe.id
  consumer_group_id = konnect_gateway_consumer_group.graphisoft.id
  control_plane_id  = konnect_gateway_control_plane.kongair_internal_cp.id
}*/

#Add an authentication mechanism for a joe Konnect Gateway Consumer
resource "konnect_gateway_basic_auth" "my_basicauth" {
  username = "joe"
  password = "demo"
  consumer_id      = konnect_gateway_consumer.joe.id
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
}


#Add keyauth mechanism for joe Konnect Gateway Consumer
resource "konnect_gateway_key_auth" "my_keyauth" {
  consumer_id      = konnect_gateway_consumer.joe.id
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
  key              = "joe"
}


#Create an external consumer alex
resource "konnect_gateway_consumer" "alex" {
  custom_id = "alex"
  username = "alex"
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
}

#Adding ACL credentials for alex
resource "konnect_gateway_plugin_acls" "my_acls_alex" {
  group = "External"
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
  consumer = {
    id = konnect_gateway_consumer.joe.id
  }
}
#Adding keyauth credentials for alex
resource "konnect_gateway_plugin_keyauth_credentials" "my_keyauth_credentials_alex" {
  key = "alex"
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
  consumer = {
    id = konnect_gateway_consumer.alex.id
  }
}

#Create an external consumer roy
resource "konnect_gateway_consumer" "roy" {
  custom_id = "roy"
  username = "roy"
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
}

#Adding ACL credentials for roy
resource "konnect_gateway_plugin_acls" "my_acls_roy" {
  group = "External"
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
  consumer = {
    id = konnect_gateway_consumer.roy.id
  }
}

#Adding keyauth credentials for roy
resource "konnect_gateway_plugin_keyauth_credentials" "my_keyauth_credentials_roy" {
  key = "roy"
  control_plane_id = konnect_gateway_control_plane.kongair_internal_cp.id
  consumer = {
    id = konnect_gateway_consumer.roy.id
  }
}
