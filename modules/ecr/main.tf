data "aws_caller_identity" "current" {}
resource "aws_ecr_repository" "repo" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"
  tags                 = var.tags

  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/push.sh"
    environment = {
      AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
      PROFILE        = "adex_sandbox_1"
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
