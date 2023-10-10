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
  default = {
    project = "Keycloak"
  }
}

variable "owner" {
  description = "value of owner"
  type        = string
}

variable "zone_id" {
  description = "value of zone id"
  type        = string
}

variable "container_desired_count" {
  description = "value of container desired count"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "value of container port"
  type        = number
  default     = 8080
}

variable "db_instance_class" {
  description = "value of db instance class"
  type        = string
  default     = "db.t2.micro"
}

variable "db_port" {
  description = "value of db port"
  type        = number
  default     = 5432
}

variable "db_multi_az" {
  description = "value of db multi az"
  type        = bool
  default     = false
}

variable "db_storage_size" {
  description = "value of db storage size"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "value of db username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "value of db password"
  type        = string
  default     = "your_default_password"
}

variable "keycloak_admin_username" {
  description = "value of Keycloak admin username"
  type        = string
  default     = "admin"
}

variable "keycloak_admin_password" {
  description = "value of Keycloak admin password"
  type        = string
  default     = "your_default_password"
}

variable "certificate_arn_us-east-1" {
  description = "ARN of the certificate in us-east-1 region"
  type        = string
  default     = "arn:aws:acm:us-east-1:your-account-id:certificate/your-certificate-id"
}

variable "certificate_arn_us-east-2" {
  description = "ARN of the certificate in us-east-2 region"
  type        = string
  default     = "arn:aws:acm:us-east-2:your-account-id:certificate/your-certificate-id"
}
