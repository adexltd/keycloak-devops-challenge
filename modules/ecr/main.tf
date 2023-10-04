data "aws_caller_identity" "current" {}

# resource "aws_ecr_repository" "builder_repo" {
#   name                 = var.builder_repository_name
#   image_tag_mutability = "MUTABLE"
#   tags                 = var.tags
#   force_delete         = true
# }

resource "aws_ecr_repository" "repo" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"
  tags                 = var.tags
  force_delete         = true

  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/../../scripts/push.sh"
    environment = {
      AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
      PROFILE        = "default" # has to be changed
      MODULE_PATH    = path.module
    }
  }
}

# resource "aws_ecr_lifecycle_policy" "repo-policy" {
#   repository = var.repository_name

#   policy = <<EOF
# {
#   "rules": [
#     {
#       "rulePriority": 1,
#       "description": "Keep image deployed with tags",
#       "selection": {
#         "tagStatus": "untagged",
#         "countType": "imageCountMoreThan",
#         "countNumber": 1
#       },
#       "action": {
#         "type": "expire"
#       }
#     },
#     {
#       "rulePriority": 2,
#       "description": "Keep last 2 any images",
#       "selection": {
#         "tagStatus": "any",
#         "countType": "imageCountMoreThan",
#         "countNumber": 2
#       },
#       "action": {
#         "type": "expire"
#       }
#     }
#   ]
# }
# EOF
# }
