terraform {
  required_providers {
    auth0 = {
      source = "alexkappa/auth0"
      version = "0.21.0"
    }
  }
}

provider "auth0" {
  debug         = true
}

resource "auth0_client" "subam" {
  app_type                   = "non_interactive"
  name                       = "Subam"
  description                = "Client configuration app"
  token_endpoint_auth_method = "client_secret_post"
  grant_types                = ["client_credentials"]

  jwt_configuration {
    secret_encoded = false
    alg                 = "RS256"
    lifetime_in_seconds = 36000
  }

  refresh_token {
    expiration_type     = "non-expiring"
    rotation_type       = "non-rotating"
    token_lifetime      = 31557600
    idle_token_lifetime = 2592000
    infinite_idle_token_lifetime = true
    infinite_token_lifetime = true
  }
}

resource "auth0_resource_server" "management" {
  name = "Auth0 Management API"
  identifier = "https://${var.auth0-domain}/api/v2/"
  allow_offline_access = false
  enforce_policies = false
  signing_alg = "RS256"
  skip_consent_for_verifiable_first_party_clients = false
  token_lifetime = 86400
  token_lifetime_for_web = 7200
  lifecycle {
    ignore_changes = [scopes]
  }
}

resource "auth0_client_grant" "mgmt-subam" {
  client_id = auth0_client.subam.id
  audience  = auth0_resource_server.management.identifier
  scope     = [
    "read:client_grants", "create:client_grants", "delete:client_grants", "update:client_grants",
    "read:clients", "update:clients", "create:clients",
    "read:connections", "update:connections", "create:connections",
    "read:resource_servers", "update:resource_servers", "create:resource_servers",
    "read:tenant_settings", "update:tenant_settings",
    "read:roles", "create:roles", "delete:roles", "update:roles",
  ]
}

resource "auth0_client" "bank" {
  app_type                   = "non_interactive"
  name                       = "Bank"
  description                = "Bank"
  token_endpoint_auth_method = "client_secret_post"
  grant_types                = ["authorization_code", "implicit", "refresh_token", "client_credentials", "password", "http://auth0.com/oauth/grant-type/password-realm"]
  is_token_endpoint_ip_header_trusted = false
  oidc_conformant = true
  callbacks = []
  allowed_origins = []
  allowed_logout_urls = []
  web_origins = []
  client_metadata = {}
  jwt_configuration {
    secret_encoded = false
    alg                 = "RS256"
    lifetime_in_seconds = 36000
  }
  refresh_token {
    expiration_type     = "expiring"
    leeway              = 0
    rotation_type       = "rotating"
    token_lifetime      = 31557600
    idle_token_lifetime = 2592000
  }
}

resource "auth0_resource_server" "bank-be" {
  name        = "Bank Backend"
  identifier  = var.bank-be-identifier
  signing_alg = "RS256"
  allow_offline_access = true
  token_lifetime = 3600
  token_lifetime_for_web = 3600
  skip_consent_for_verifiable_first_party_clients = true
  enforce_policies = true
  token_dialect = "access_token_authz"

  scopes {
    value       = "read:users"
    description = "Read users"
  }

  scopes {
    value       = "create:users"
    description = "Create users"
  }

  scopes {
    value       = "update:users"
    description = "Update users"
  }

  scopes {
    value       = "read:roles"
    description = "Read roles"
  }

  scopes {
    value       = "create:roles"
    description = "Create roles"
  }

  scopes {
    value       = "update:roles"
    description = "Update roles"
  }

  scopes {
    value       = "delete:roles"
    description = "Delete roles"
  }

  scopes {
    value = "read:role-assignments"
    description = "Read user role assignment"
  }

  scopes {
    value = "create:role-assignments"
    description = "Create user role assignment"
  }

  scopes {
    value = "delete:role-assignments"
    description = "Delete user role assignment"
  }

  scopes {
    value = "read:permissions"
    description = "Read permissions"
  }

  scopes {
    value = "read:permission-assignments"
    description = "Read role permission assignment"
  }

  scopes {
    value = "create:permission-assignments"
    description = "Create role permission assignment"
  }

  scopes {
    value = "delete:permission-assignments"
    description = "Delete role permission assignment"
  }
}

resource "auth0_client_grant" "mgmt-bank" {
  client_id = auth0_client.bank.id
  audience  = auth0_resource_server.management.identifier
  scope     = [
    "read:resource_servers",
    "read:users", "update:users", "create:users",
    "read:users_app_metadata", "update:users_app_metadata", "delete:users_app_metadata", "create:users_app_metadata",
    "read:user_custom_blocks", "create:user_custom_blocks", "delete:user_custom_blocks",
    "read:roles", "create:roles", "delete:roles", "update:roles",
    "create:role_members", "read:role_members", "delete:role_members"
  ]
}

resource "auth0_client_grant" "bank-be-bank" {
  client_id = auth0_client.bank.id
  audience  = auth0_resource_server.bank-be.identifier
  scope = []
}

resource "auth0_connection" "username-password-connection" {
  name = "Username-Password-Authentication"
  strategy = "auth0"
  is_domain_connection = false
  enabled_clients = [auth0_client.bank.id]

  options {
    requires_username = true
    validation {
      username {
        min = 6
        max = 15
      }
    }
    password_complexity_options {
      min_length = 8
    }
    import_mode = false
    disable_signup = false

    password_policy = "good"
    password_history {
      enable = true
      size = 5
    }
    password_dictionary {
      enable = true
      dictionary = []
    }
    password_no_personal_info {
      enable = true
    }
    enabled_database_customization = false

    client_id = auth0_client.bank.id

    allowed_audiences = []
    configuration = {}
    custom_scripts = {}
    domain_aliases = []
    fields_map = {}
    ips = []
    scopes = []
    scripts = {}
  }
}

resource "auth0_tenant" "tenant" {
  default_audience  = auth0_resource_server.management.identifier
  default_directory = auth0_connection.username-password-connection.name
  friendly_name = var.subam-tenant-friendly-name
  enabled_locales = ["en"]
}
