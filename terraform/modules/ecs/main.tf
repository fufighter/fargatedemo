resource "aws_ecs_cluster" "ecs" {
  name = "${var.project}-${var.env_name}"
}

resource "aws_ecs_task_definition" "task" {
  execution_role_arn       = var.iam_ecs_arn
  family                   = "${var.project}"
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name      = var.project
      image     = var.image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = var.project
  cluster         = aws_ecs_cluster.ecs.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  network_configuration {
    subnets          = var.public_subnets
    assign_public_ip = true
    security_groups  = [module.sg_ecs.security_group_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = var.project
    container_port   = var.app_port
  }
}

module "sg_ecs" {
  source      = "code.logicworks.net/terraform-modules/terraform-aws-securitygroup/aws"
  version     = "1.3.2"
  vpc_id      = var.vpc_id
  name        = "${var.project}-ecs-${var.env_name}"
  description = "ECS Service SG"
  ingress_rules = {
    web = {
      from_port   = var.app_port
      cidr_blocks = ["10.0.0.0/8"]
    }
  }
}

module "sg_alb" {
  source      = "code.logicworks.net/terraform-modules/terraform-aws-securitygroup/aws"
  version     = "1.3.2"
  vpc_id      = var.vpc_id
  name        = "${var.project}-alb-${var.env_name}"
  description = "ALB SG"
  ingress_rules = {
    web = {
      from_port   = 80
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_lb" "alb" {
  name               = "${var.project}-alb"
  subnets            = var.public_subnets
  load_balancer_type = "application"
  security_groups    = [module.sg_alb.security_group_id]
}

resource "aws_lb_listener" "http_forward" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group" "tg" {
  name                 = "${var.project}-tg"
  deregistration_delay = 0
  port                 = var.app_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "90"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "20"
    path                = "/"
    port                = var.app_port
    unhealthy_threshold = "2"
  }
}
