variable "repository_name" {
  type        = string
  description = "repsitory name"
}

variable "tags" {
  description = "Tag to use for deployed Docker image"
  type        = map(any)
}

