output "alb_security_group_id" {
  description = "SG ID for ALB"
  value = aws_security_group.alb_sg_group.id
}

output "app_security_group_id" {
  description = "SG ID for APP"
  value = aws_security_group.app_sg_group.id
}

output "jenkins_security_group_id" {
  description = "SG ID for Jenkins"
  value = aws_security_group.jenkins_sg_group.id
}