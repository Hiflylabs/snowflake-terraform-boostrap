variable "snowflake_account" {
  type      = string
  sensitive = true
}
variable "snowflake_region" {
  type      = string
  sensitive = true
}
# This user is used to create the snowflake object, sys_admin/account_admin roles are required
variable "sf_tf_user_name" {
  type      = string
  sensitive = true
}
variable "sf_tf_user_password" {
  type      = string
  sensitive = true
}
# DBT cloud user name
variable "sf_dbt_user_name" {
  type      = string
  sensitive = true
  default   = "dbt2"
}
# DBT cloud user password
variable "sf_dbt_user_password" {
  type      = string
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
  default = ["TF_ANALYTICS", "TF_ANALYTICS_STAGE"]
}