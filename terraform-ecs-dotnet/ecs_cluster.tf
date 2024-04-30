module "workshop-vpc" {
  source             = "./vpc"
  name               = "creatica-workshop"
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "beckerl-ecs-cluster"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "beckerl-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "my-log-group" {
  name = "beckerl-loggroup"
}

resource "aws_ecs_task_definition" "beckerl-dotnet-task" {
  family = "dotnet-weather-app"

  runtime_platform {
    cpu_architecture = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name         = "dotnet-weather-app"
      image        = aws_ecr_repository.demo-repository.repository_url
      essential    = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      memory = 512
      cpu    = 256
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true"
          "awslogs-group"         = aws_cloudwatch_log_group.my-log-group.name
          "awslogs-region"        = "eu-west-1"
          "awslogs-stream-prefix" = "awslogs-example"
          "mode"                  = "non-blocking"
          "max-buffer-size"       = "25m"
        }
      }
    }
  ])
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}


# Create a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = module.workshop-vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_alb" "application_load_balancer" {
  name               = "load-balancer-dev"
  load_balancer_type = "application"
  subnets            = module.workshop-vpc.subnet_ids
  security_groups    = [aws_security_group.load_balancer_security_group.id]
}


resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.workshop-vpc.vpc_id
  health_check {
    enabled = true
    path    = "/weatherforecast"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.creatica_wildcard_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}


resource "aws_security_group" "service_security_group" {
  vpc_id = module.workshop-vpc.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "dotnet-weather-service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.beckerl-dotnet-task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    container_name   = aws_ecs_task_definition.beckerl-dotnet-task.family
    container_port   = 3000
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.service_security_group.id]
    subnets          = module.workshop-vpc.subnet_ids
  }
}
