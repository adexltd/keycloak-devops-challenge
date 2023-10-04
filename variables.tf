variable "name" {
  description = "Name of the service"
  type        = string
  default     = "keycloak"
}

variable "region" {

}

variable "domain_name" {
  description = "value of domain name"
  type        = string
}

variable "environment" {
  description = "value of environment"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags"
  default    = {
    project = "Keycloak"
  }
}

variable "owner" {
  description = "value of owner"
  type        = string
}
