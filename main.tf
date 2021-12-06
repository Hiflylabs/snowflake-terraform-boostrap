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
