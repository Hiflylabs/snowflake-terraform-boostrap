variable "snowflake_tenant_info" {
  type = object({
    account_name = string,
    region       = string,
    # This user is used to create the snowflake object,
    # sys_admin/account_admin roles are required
    user_name     = string,
    user_password = string
  })
  sensitive = true
}

# DBT cloud user 
variable "snowflake_dbt_user_info" {
  type = object({
    user_name     = string,
    user_password = string
  })
  sensitive = true
}
variable "warehouses" {
  type = map(object({
    name = string,
    size = string,
    role = string,
  }))
  default = {
    "loading" = {
      name = "TF_LOADING",
      size = "xsmall",
      role = "tf_loader"
    }
    "transforming" = {
      name = "TF_TRANSFORMING",
      size = "xsmall",
      role = "tf_transformer"
    }
    "reporting" = {
      name = "TF_REPORTING",
      size = "xsmall",
      role = "tf_reporter"
    }
  }
}

variable "roles" {
  type = map(object({
    name    = string,
    comment = string
  }))
  default = {
    "loader" = {
      name    = "tf_loader",
      comment = "Loader is responsible for loading raw data to Snowflake."
    }
    "transformer" = {
      name    = "tf_transformer",
      comment = "Transformer is responsible for transforming raw data into ready-for-analysis datasets."
    }
    "reporter" = {
      name    = "tf_reporter",
      comment = "Reporter is responsible for reading data by end-users as well as business intelligence service users."
    }
  }
}

variable "databases" {
  type    = list(string)
  default = ["TF_ANALYTICS", "TF_ANALYTICS_STAGE", "TF_ANALYTICS_DEV"]
}

variable "schema" {
  type = object({
    name    = string,
    comment = string
  })
  default = {
    name    = "log",
    comment = "Log"
  }
}