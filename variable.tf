variable snowflake_account {
    type = string
    sensitive = true
}
variable snowflake_region {
    type = string
    sensitive = true
}
# This user is used to create the snowflake object, sys_admin/account_admin roles are required
variable sf_tf_user_name {
    type = string
    sensitive = true
}
variable sf_tf_user_password {
    type = string
    sensitive = true
}
variable "warehouses" {
    type = map(object({
        name = string,
        size = string
    }))
    default ={
        "loading" = {
            name = "loading",
            size = "xsmall"
        }
        "transforming" = {
            name = "transforming",
            size = "xsmall"
        }
        "reporting" = {
            name = "reporting",
            size = "xsmall"
        }
    } 
}

variable "roles" {
    type = map(object({
        name = string,
        comment = string
    }))
    default ={
        "loader" = {
            name = "loader2",
            comment = "Loader is responsible for loading raw data to Snowflake."
        }
        "transformer" = {
            name = "transformer",
            comment = "Transformer is responsible for transforming raw data into ready-for-analysis datasets."
        }
        "reporter" = {
            name = "reporter",
            comment = "Reporter is responsible for reading data by end-users as well as business intelligence service users."
        }
    } 
}
