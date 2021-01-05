module "my_vpc"{
    source = "../../Modules/app_infrastructure"
    credentials = var.credentials
    gcp_project = var.gcp_project
    region = var.region
    subnet_1_CIDR = var.subnet_1_CIDR
    subnet_2_CIDR = var.subnet_2_CIDR
    subnet_3_CIDR = var.subnet_3_CIDR
    cloud_sql_password= var.cloud_sql_password
    cloud_sql_user= var.cloud_sql_user
    cloud_sql_db_names=var.cloud_sql_db_names
}