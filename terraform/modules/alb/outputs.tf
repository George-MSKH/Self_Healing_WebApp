output "tg_arn_suffix" {
  value = aws_lb_target_group.alb_tg.arn_suffix
}
output "alb_arn_suffix" {
  value = aws_lb.app_alb.arn_suffix
}

output "alb_tg_arn" {
  value = aws_lb_target_group.alb_tg.arn
}

output "alb_tg_name" {
  value = aws_lb_target_group.alb_tg.name
}