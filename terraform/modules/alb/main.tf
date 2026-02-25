# AWS Load Balancer
resource "aws_lb" "app_alb" {
  name = "app-alb"
  internal = false
  load_balancer_type = "application"
  subnets = var.public_subnet_id
  security_groups = [var.alb_security_group_id]
  enable_deletion_protection = false
}

# Target Group
resource "aws_lb_target_group" "alb_tg" {
  name = "Alb-Tg"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  target_type = "instance"
}

# APP Attachment
resource "aws_lb_target_group_attachment" "app_attachment" {
  for_each = var.app_instance_id
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = each.value
  port             = 80
  depends_on = [aws_lb_target_group.alb_tg]
}

# Listener
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}