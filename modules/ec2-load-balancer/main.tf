resource "aws_lb" "alb" {
  name               = "${ var.prefix }-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.network_interface_security_groups
  subnets            = data.aws_subnets.public.ids
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.prefix}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  deregistration_delay = 30
  slow_start           = 30
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.aws_instance_id
}