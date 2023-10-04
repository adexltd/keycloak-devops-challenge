locals {
  secrets = {
    db_username               = env.db_username 
    db_password               = env.db_password
    keycloak_admin_username   = env.keycloak_admin_username
    keycloak_admin_password   = env.keycloak_admin_password
    certificate_arn_us-east-1 = env.certificate_arn_us-east-1
    certificate_arn_us-east-2 = env.certificate_arn_us-east-2
  }
}