variable "repository_name" {
  type        = string
  description = "repsitory name"
}

# variable "builder_repository_name" {
#   type        = string
#   description = "builder repsitory name"
# }

variable "tags" {
  description = "Tag to use for deployed Docker image"
  type        = map(any)
}

variable "profile" {
  description = "value of AWS_PROFILE"
  type = string
}