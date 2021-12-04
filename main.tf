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
  alias = "sys_admin"
  role  = "SYSADMIN"
}
provider "snowflake" {
  username = var.sf_tf_user_name
  password = var.sf_tf_user_password
  account  = var.snowflake_account
  region   = var.snowflake_region
  alias = "security_admin"
  role  = "SECURITYADMIN"
}

# Create dbt technical user
resource snowflake_user user {
  provider      = snowflake.security_admin
  name         = "dbt technical user"
  login_name   = var.sf_dbt_user_name
  comment      = "dbt project technical user"
  password     = var.sf_dbt_user_password
  disabled     = false
  display_name = "dbt technical user"
  # depends_on   = [snowflake.security_admin]
}

# Create roles
resource snowflake_role roles {
  for_each  = var.roles
  provider  = snowflake.security_admin
  name      = each.value["name"]
  comment   = each.value["comment"]
}

# Create warehouses
resource "snowflake_warehouse" "warehouses" {
  
    for_each       = var.warehouses
    provider       = snowflake.sys_admin
    name           = upper(each.value.name)
    warehouse_size = each.value.size
    auto_suspend = 60
    initially_suspended = true
}

# Grant roles to dbt technical user
resource snowflake_role_grants grant_loader {
  provider  = snowflake.security_admin
  for_each = var.roles
  role_name = each.value.name
  users = [
    snowflake_user.user.name
  ]
  depends_on = [snowflake_role.roles]
}