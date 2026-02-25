# output "instance_id" {
#   value = aws_instance.application[*].id
# }
output "instance_id" {
  value = {
    for idx, instance in aws_instance.application :
    idx => instance.id
  }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}