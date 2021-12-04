## Thrive Terraform poc
- [reference](https://quickstarts.snowflake.com/guide/terraforming_snowflake/index.html?index=..%2F..index#0) <br>
- [documentation](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/warehouse)

### Dependencies
"sf_tf_user_name" user need sys_admin, security_admin roles on the target Snowflake instance

<img src="./misc/SF_TF.svg">


### Steps
- create warehouse(LOADING, TRANSFORMING)
- create databases(ANALYTICS, ANALYTICS_STAGE)
- create roles(LOADER, TRANSFORMER, REPORTER)
- create dbt user
- grant roles
