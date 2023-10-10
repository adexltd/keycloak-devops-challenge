variable "keycloak_secret_name" {
  description = "The name of the secret to create"
}

variable "db_username" {
  description = "username for the Postgres database"
}

variable "db_password" {
  description = "password for the Postgres database"
}

variable "keycloak_admin_username" {
  description = "username for the Keycloak admin"  
}

variable "keycloak_admin_password" {
  description = "password for the Keycloak admin"  
}

variable "certificate_arn_us-east-1" {
  description = "certificate arn for us-east-1"
}

variable "certificate_arn_us-east-2" {
  description = "certificate arn for us-east-2"
}

variable "recovery_window_in_days" {
  description = "recovery window after a secret is deleted"
  type = number
  default = 7
}
variable "tags" {
  type        = map(string)
  description = "Tags"
}
