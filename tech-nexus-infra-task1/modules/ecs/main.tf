resource "aws_ecs_cluster" "cluster" {
  name = "leidos-${var.env}-ecs-cluster"
}

resource "aws_ecs_task_definition" "wordpress" {
  family                   = "wordpress"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions    = jsonencode([
    {
      name      = "wordpress",
      image     = "wordpress",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ],
      environment = [
        {
          name  = "WORDPRESS_DB_HOST"
          value = "your-db-host"
        },
        {
          name  = "WORDPRESS_DB_USER"
          value = "wordpress_user"
        },
        {
          name  = "WORDPRESS_DB_PASSWORD"
          value = "wordpress_password"
        },
        {
          name  = "WORDPRESS_DB_NAME"
          value = "wordpress"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "leidos-${var.env}-wordpress-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.wordpress.arn
  desired_count   = 1
  launch_type     = "EC2"
  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.wordpress.arn
    container_name   = "wordpress"
    container_port   = 80
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "leidos-${var.env}-ecs-sg"
  description = "Security group for ECS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "leidos-${var.env}-ecs-sg"
  }
}

resource "aws_lb_target_group" "wordpress" {
  name        = "leidos-${var.env}-wordpress-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
