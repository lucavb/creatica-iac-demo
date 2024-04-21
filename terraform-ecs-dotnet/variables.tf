variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "github_organization" {
  type        = string
  description = "GitHub Organization Name"
}

variable "github_repository" {
  type        = string
  description = "GitHub Repository Name"
}

variable "github_thumbprints" {
  type        = list(string)
  description = "List of GitHub OIDC thumbprints"
}

