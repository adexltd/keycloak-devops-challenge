locals {
  secrets = {
        db_username               = "keycloak"
        db_password               = "secrectpassword"
        keycloak_admin_username   = "admin"
        keycloak_admin_password   = "secrectpassword"
        certificate_arn_us-east-1 = "arn:aws:acm:us-east-1:426857564226:certificate/3fc0c3bc-90f6-4600-bcd5-6ffeb59db6db"
        certificate_arn_us-east-2 = "arn:aws:acm:us-east-2:426857564226:certificate/f53ef742-9dae-4c8e-b76d-1b0ba1cda8c5"
  }
}