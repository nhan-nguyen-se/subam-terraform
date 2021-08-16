resource "auth0_role" "bank_seller" {
  name = "seller"
  description = "Seller"
}

resource "auth0_role" "bank_seller_supervisor" {
  name = "seller_supervisor"
  description = "Seller Supervisor"
}

resource "auth0_role" "bank_user_management" {
  name = "user_management"
  description = "User Management"

  permissions {
    name = "read:users"
    resource_server_identifier = auth0_resource_server.bank-be.identifier
  }

  permissions {
    name = "create:users"
    resource_server_identifier = auth0_resource_server.bank-be.identifier
  }

  permissions {
    name = "update:users"
    resource_server_identifier = auth0_resource_server.bank-be.identifier
  }

  permissions {
    name = "read:roles"
    resource_server_identifier = auth0_resource_server.bank-be.identifier
  }

  permissions {
    name = "create:roles"
    resource_server_identifier = auth0_resource_server.bank-be.identifier
  }

  permissions {
    name = "update:roles"
    resource_server_identifier = auth0_resource_server.bank-be.identifier
  }

  permissions {
    name = "read:role-assignments"
    resource_server_identifier = auth0_resource_server.bank-be.identifier
  }

  permissions {
    name = "create:role-assignments"
    resource_server_identifier = auth0_resource_server.bank-be.identifier
  }

  permissions {
    name = "delete:role-assignments"
    resource_server_identifier = auth0_resource_server.bank-be.identifier
  }

  permissions {
    name = "read:permissions"
    resource_server_identifier = auth0_resource_server.bank-be.identifier
  }

  permissions {
    name = "read:permission-assignments"
    resource_server_identifier = auth0_resource_server.bank-be.identifier
  }

  permissions {
    name = "create:permission-assignments"
    resource_server_identifier = auth0_resource_server.bank-be.identifier
  }

  permissions {
    name = "delete:permission-assignments"
    resource_server_identifier = auth0_resource_server.bank-be.identifier
  }
}
