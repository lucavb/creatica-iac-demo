resource "aws_ecr_repository" "demo-repository" {
  name                 = "beckerl-demo-repo"
  image_tag_mutability = "MUTABLE"
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
  family = "app-first-task" # Name your task

  runtime_platform {
    cpu_architecture = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name         = "app-first-task"
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
          "awslogs-region"        = "eu-central-1"
          "awslogs-stream-prefix" = "awslogs-example"
          "mode"                  = "non-blocking"
          "max-buffer-size"       = "25m"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory = 512         # Specify the memory the container requires
  cpu = 256         # Specify the CPU the container requires
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
}

# main.tf
# Provide a reference to your default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Provide references to your default subnets
resource "aws_default_subnet" "default_subnet_a" {
  # Use your own region here but reference to subnet 1a
  availability_zone = "eu-central-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  # Use your own region here but reference to subnet 1b
  availability_zone = "eu-central-1b"
}

# main.tf
# Create a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# main.tf
resource "aws_alb" "application_load_balancer" {
  name = "load-balancer-dev" #load balancer name
  load_balancer_type = "application"
  subnets = [
    # Referencing the default subnets
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_b.id
  ]
  # security group
  security_groups = [aws_security_group.load_balancer_security_group.id]
}

# main.tf
resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id # default VPC
  health_check {
    enabled = true
    path    = "/weatherforecast"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn #  load balancer
  port     = "80"
  protocol = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn # target group
  }
}

# main.tf
resource "aws_security_group" "service_security_group" {
  ingress {
    from_port       = 0
    to_port         = 0
    protocol = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# main.tf
resource "aws_ecs_service" "app_service" {
  name = "app-first-service"     # Name the service
  cluster = aws_ecs_cluster.ecs-cluster.id   # Reference the created Cluster
  task_definition = aws_ecs_task_definition.beckerl-dotnet-task.arn # Reference the task that the service will spin up
  launch_type   = "FARGATE"
  desired_count = 1  # Set up the number of containers to 3

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn # Reference the target group
    container_name = aws_ecs_task_definition.beckerl-dotnet-task.family
    container_port = 3000 # Specify the container port
  }

  network_configuration {
    subnets         = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id]
    assign_public_ip = true     # Provide the containers with public IPs
    security_groups = [aws_security_group.service_security_group.id] # Set up the security group
  }
}


# main.tf
#Log the load balancer app URL
output "app_url" {
  value = aws_alb.application_load_balancer.dns_name
}