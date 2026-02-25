# Application Instance
resource "aws_instance" "application" {
  count = 2
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.private_subnet_id[count.index]
  key_name = var.devkey
  vpc_security_group_ids = [var.app_sg_group_id] # Firewalls for App serer who can reach it
  associate_public_ip_address = false

  tags = {
    "Name" = "App-Instance-${count.index}" 
  }
}

# Jenkins Instance
resource "aws_instance" "jenkins" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.public_subnet_id[0]
  key_name = var.devkey
  vpc_security_group_ids = [var.jenkins_sg_group_id]# Firewalls for Jenkins serer who can reach it 
  associate_public_ip_address = true

  tags = {
    "Name" = "Jenkins-Instance" 
  }
}