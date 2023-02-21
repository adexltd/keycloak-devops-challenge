variable "secret_name" {
  description = "The name of the secret to create"
}

variable "db_username" {
  description = "username for the Postgres database"
}

variable "db_password" {
  description = "password for the Postgres database"
}

variable "tags" {
  type        = map(string)
  description = "Tags"
}
