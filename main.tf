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
  username = var.snowflake_tenant_info.user_name
  password = var.snowflake_tenant_info.user_password
  account  = var.snowflake_tenant_info.account_name
  region   = var.snowflake_tenant_info.region
  alias    = "sys_admin"
  role     = "SYSADMIN"
}
provider "snowflake" {
  username = var.snowflake_tenant_info.user_name
  password = var.snowflake_tenant_info.user_password
  account  = var.snowflake_tenant_info.account_name
  region   = var.snowflake_tenant_info.region
  alias    = "security_admin"
  role     = "SECURITYADMIN"
}

# Create dbt technical user
resource "snowflake_user" "user" {
  provider     = snowflake.security_admin
  name         = "dbt technical user"
  login_name   = var.snowflake_dbt_user_info.user_name
  comment      = "dbt project technical user"
  password     = var.snowflake_dbt_user_info.user_password
  disabled     = false
  display_name = "dbt technical user"
}

# Create roles
resource "snowflake_role" "roles" {
  for_each = var.roles
  provider = snowflake.security_admin
  name     = upper(each.value["name"])
  comment  = each.value["comment"]
}

# Create warehouses
resource "snowflake_warehouse" "warehouses" {
  for_each            = var.warehouses
  provider            = snowflake.sys_admin
  name                = upper(each.value.name)
  warehouse_size      = each.value.size
  auto_suspend        = 60
  initially_suspended = true
}

# Grant roles to dbt technical user
resource "snowflake_role_grants" "roles" {
  provider   = snowflake.security_admin
  for_each   = var.roles
  role_name  = upper(each.value.name)
  users      = [snowflake_user.user.name]
  depends_on = [snowflake_role.roles]
}

# Create databases
resource "snowflake_database" "db" {
  for_each = toset(var.databases)
  provider = snowflake.sys_admin
  name     = upper(each.key)
}

# Grant roles to databases
resource "snowflake_database_grant" "grant" {
  for_each      = toset(var.databases)
  provider      = snowflake.sys_admin
  database_name = upper(each.key)
  roles         = [for k, v in var.roles : upper(v.name)]
  depends_on    = [snowflake_database.db]
}

# Grant roles to warehouses
resource "snowflake_warehouse_grant" "grant" {
  provider          = snowflake.sys_admin
  for_each          = var.warehouses
  warehouse_name    = upper(each.value.name)
  privilege         = "MODIFY"
  roles             = [upper(each.value.role)]
  with_grant_option = false
  depends_on        = [snowflake_warehouse.warehouses]
}

# Create schemas
locals {
  databases_schemas_list = flatten([
    for database in var.databases : [
      for key, value in var.schemas : {
        "database"    = upper(database)
        "schema_name" = upper(value.name)
        "comment"     = value.comment
      }
    ]
  ])
}

# Grant roles to future schemas
resource "snowflake_schema_grant" "grant" {
  provider      = snowflake.security_admin
  for_each      = toset(var.databases)
  database_name = upper(each.key)
  privilege     = "USAGE"
  roles         = [for k, v in var.roles : upper(v.name)]
  on_future     = true
  depends_on    = [snowflake_database.db]
}
# Create schemas
resource "snowflake_schema" "schema" {
  provider            = snowflake.sys_admin
  for_each            = { for key, value in local.databases_schemas_list : key => value }
  database            = upper(each.value.database)
  name                = upper(each.value.schema_name)
  comment             = each.value.comment
  is_transient        = false
  is_managed          = false
  data_retention_days = 1
  depends_on          = [snowflake_database.db]
}