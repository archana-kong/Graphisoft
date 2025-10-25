terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "3.3.0"
    }
  }
}

provider "konnect" {
  # Configuration options
    server_url = var.server_url
    system_account_access_token = var.system_account_access_token
}

resource "konnect_gateway_control_plane" "kongair_internal_cp" {
  auth_type     = "pki_client_certs"
  cloud_gateway = false
  cluster_type  = "CLUSTER_TYPE_CONTROL_PLANE"
  description   = "CP for KongAir Internal API Configurations"
  labels = {
    env = var.environment
    team = "kong-air-internal"
    generated_by =  "terraform"
  }
  name = "KongAir_Internal"
}

# Internal Developer Team
# The internal developers team is responsible for managing the internal control plane configuration

resource "konnect_team" "kong_air_internal_devs" {
  description = "Allow managing the internal control plane configuration."
  name        = "Kong Air Internal Developers"
}
resource "konnect_team_role" "kong_air_internal_cp_admin" {
  entity_id        = konnect_gateway_control_plane.kongair_internal_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  team_id          = konnect_team.kong_air_internal_devs.id
}
# Internal Viewers Team
# The internal viewers team is responsible for monitoring the internal control plane configuration and will have read only access to the Internal Control Plane.

resource "konnect_team" "kong_air_internal_viewers" {
  description = "Allow read-only access to all entities in the internal control plane"
  name        = "Kong Air Internal Viewers"
}

resource "konnect_team_role" "kong_air_internal_cp_viewer" {
  entity_id        = konnect_gateway_control_plane.kongair_internal_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Viewer"
  team_id          = konnect_team.kong_air_internal_viewers.id
}
# Platform Admins Team
# The platform admins team is responsible for managing all entities in the
# internal control planes.

resource "konnect_team" "platform_admins" {
  description = "Allow managing entities in the  internal control planes"
  name        = "Platform Admins"
}


resource "konnect_team_role" "platform_admins_internal_cp_admin" {
  entity_id        = konnect_gateway_control_plane.kongair_internal_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Admin"
  team_id          = konnect_team.platform_admins.id
}

# Platform Viewers Team
# The platform viewers team is responsible for monitoring all entities in the 
# internal control planes.

resource "konnect_team" "platform_viewers" {
  description = "Allow read-only access to all entities in the internal control planes"
  name        = "Platform Viewers"
}


resource "konnect_team_role" "platform_viewers_internal_cp_viewer" {
  entity_id        = konnect_gateway_control_plane.kongair_internal_cp.id
  entity_region    = "us"
  entity_type_name = "Control Planes"
  role_name        = "Viewer"
  team_id          = konnect_team.platform_viewers.id
}
