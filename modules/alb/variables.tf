variable "alb_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}


variable "target_group_name" {
  type = string
}

variable "target_group_port" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "listener_port" {
  type = number
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
  }
}



