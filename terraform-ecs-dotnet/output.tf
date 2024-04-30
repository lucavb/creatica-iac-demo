output "app_url" {
  value = aws_alb.application_load_balancer.dns_name
}

output "dotnet_app_ecr_repo_url" {
  value = aws_ecr_repository.demo-repository.repository_url
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}