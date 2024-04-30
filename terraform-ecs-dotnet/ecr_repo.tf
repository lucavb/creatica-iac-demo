resource "aws_ecr_repository" "demo-repository" {
  name                 = "beckerl-weather-demo-app"
  image_tag_mutability = "MUTABLE"
}
