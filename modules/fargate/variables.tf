variable "fargate_service_name" {
  description = "name of farget service"
}
variable "image" {
  type = string
}

variable "vpc_id" {
  description = "vpc id containing farget"
}

variable "subnet_ids" {
  description = "subnet id's"
}


variable "ecs_cluster_name" {
  description = "name of ecs cluster"
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
  }
}
variable "retention_in_days" {
  type        = number
  description = "Log retention days"
  default     = 7
}

variable "container_port" {
  type        = number
  description = "(optional) describe your variable"
}

variable "source_cidr_blocks" {
  type        = list(string)
  description = "List of CIDRs"

}
variable "cpu" {
  type    = number
  default = 1024

}
variable "memory" {
  type    = number
  default = 2048
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "alb_target_group_arn" {
  type = string
}
variable "alb_listener_arn" {
  type = string
}
variable "desired_count" {
  type    = number
  default = 1
}

variable "keycloak_secret_name" {
  description = "AWS Secret manager ARN to retrive DB username and password"
  type        = string
}

variable "db_endpoint" {
  type = string

}

variable "project_domain_name" {
  type        = string
  description = "Domain name for the Keycloak service"
}