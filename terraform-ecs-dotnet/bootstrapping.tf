# resource "aws_iam_role" "github_actions" {
#   name = "GitHubActionsRole"
#
#   assume_role_policy = jsonencode({
#     Version   = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
#         }
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Condition = {
#           StringEquals = {
#             "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
#           },
#           StringLike = {
#             "token.actions.githubusercontent.com:sub" : "repo:${var.github_organization}/${var.github_repository}:*"
#           },
#           "StringEquals" : {
#             "token.actions.githubusercontent.com:thumbprint" : var.github_thumbprints
#           }
#         }
#       },
#     ]
#   })
# }
# resource "aws_iam_role_policy_attachment" "admin_access" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }
#
# output "role_arn" {
#   value = aws_iam_role.github_actions.arn
# }