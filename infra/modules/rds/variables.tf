variable "db_name" {
  type = string
}


variable "db_instance_class" {
  type = string
}

variable "db_engine" {
  type = string
}

variable "db_engine_version" {
  type = string
}
variable "db_allocated_storage" {
  type = number
}

variable "db_subnet_group_name" {
  type = string
}
variable "db_subnet_ids" {
  type = list(string)
}

variable "db_parameter_group_name" {
  type = string
}

variable "db_multi_az" {
  type = bool
}

variable "db_backup_retention_period" {
  type = number
}

variable "db_port" {
  type    = number
  default = 5432
}


variable "vpc_id" {
  type        = string
  description = "VPC ID for postgress to launch on"
}
variable "db_tags" {
  type        = map(string)
  description = "Tags"
}

variable "cidr_blocks_to_allow_access_to_db" {
  type        = list(string)
  description = "List of CIDR Ranage to allow traffic to DataBase"

}
variable "keycloak_secret_name" {
  description = "AWS Secret manager ARN to retrive DB username and password"
  type        = string
}
