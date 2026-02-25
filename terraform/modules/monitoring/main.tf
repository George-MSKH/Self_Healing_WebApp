resource "aws_sns_topic" "alerts" {
  name = "infra-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
# Applcation Metric
resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
  for_each = var.app_instance_id
  alarm_name = "cpu-high-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 60
  statistic = "Average"
  threshold = 80
  alarm_description = "Alarm when App EC2 CPU exceeds 80%"

  dimensions = {
    InstanceId = each.value
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ALB Metric
resource "aws_cloudwatch_metric_alarm" "hosts" {
  alarm_name = "alb_unhealthy_hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  metric_name = "UnHealthyHostCount"
  namespace = "AWS/ApplicationELB"
  period = 60
  statistic = "Average"
  threshold = 0

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup = var.tg_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
