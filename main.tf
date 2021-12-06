terraform {
  required_providers {
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.25.28"
    }
  }
}

# Init sys_admin, security_admin object
provider "snowflake" {
  username = var.sf_tf_user_name
  password = var.sf_tf_user_password
  account  = var.snowflake_account
  region   = var.snowflake_region
  alias    = "sys_admin"
  role     = "SYSADMIN"
}
provider "snowflake" {
  username = var.sf_tf_user_name
  password = var.sf_tf_user_password
  account  = var.snowflake_account
  region   = var.snowflake_region
  alias    = "security_admin"
  role     = "SECURITYADMIN"
}

# Create dbt technical user
resource snowflake_user user {
  provider      = snowflake.security_admin
  name          = "dbt technical user"
  login_name    = var.sf_dbt_user_name
  comment       = "dbt project technical user"
  password      = var.sf_dbt_user_password
  disabled      = false
  display_name  = "dbt technical user"
}

# Create roles
resource snowflake_role roles {
  for_each  = var.roles
  provider  = snowflake.security_admin
  name      = each.value["name"]
  comment   = each.value["comment"]
}

# Create warehouses
resource snowflake_warehouse warehouses {
  
    for_each            = var.warehouses
    provider            = snowflake.sys_admin
    name                = upper(each.value.name)
    warehouse_size      = each.value.size
    auto_suspend        = 60
    initially_suspended = true
}

# Grant roles to dbt technical user
resource snowflake_role_grants roles {
  provider    = snowflake.security_admin
  for_each    = var.roles
  role_name   = each.value.name
  users       = [snowflake_user.user.name]
  depends_on  = [snowflake_role.roles]
}
# Create databases
resource "snowflake_database" "db" {
  for_each = toset(var.databases)
  provider = snowflake.sys_admin
  name     = upper(each.key)
}

# Grant roles to databases
resource snowflake_database_grant grant {
  for_each      = toset(var.databases)
  provider      = snowflake.sys_admin
  database_name = upper(each.key)
  roles         = [for k, v in var.roles : v.name]
  depends_on    = [snowflake_database.db]
}

# Grant roles to warehouses
resource snowflake_warehouse_grant grant {
  provider       = snowflake.sys_admin
  for_each       = var.warehouses
  warehouse_name = upper(each.value.name)
  privilege      = "MODIFY"
  roles = [each.value.role]
  with_grant_option = false
  depends_on     = [snowflake_warehouse.warehouses]
}