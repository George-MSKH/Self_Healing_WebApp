##########################
# ALB Security Group
##########################
resource "aws_security_group" "alb_sg_group" {
  name   = "alb-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "ALB-SG"
  }
}

# ALB Ingress - HTTP
resource "aws_vpc_security_group_ingress_rule" "allow_http_alb" {
  security_group_id = aws_security_group.alb_sg_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# ALB Ingress - HTTPS
resource "aws_vpc_security_group_ingress_rule" "allow_https_alb" {
  security_group_id = aws_security_group.alb_sg_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# ALB Egress → App SG
resource "aws_vpc_security_group_egress_rule" "alb_to_app_http" {
  security_group_id          = aws_security_group.alb_sg_group.id
  referenced_security_group_id = aws_security_group.app_sg_group.id
  from_port                  = 80
  to_port                    = 80
  ip_protocol                = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app_https" {
  security_group_id          = aws_security_group.alb_sg_group.id
  referenced_security_group_id = aws_security_group.app_sg_group.id
  from_port                  = 443
  to_port                    = 443
  ip_protocol                = "tcp"
}

##########################
# App EC2 Security Group
##########################
resource "aws_security_group" "app_sg_group" {
  name   = "app-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "APP-SG"
  }
}

# App Ingress - from ALB
resource "aws_vpc_security_group_ingress_rule" "app_from_alb_http" {
  security_group_id         = aws_security_group.app_sg_group.id
  referenced_security_group_id = aws_security_group.alb_sg_group.id
  from_port                 = 80
  to_port                   = 80
  ip_protocol               = "tcp"
}

# App Ingress - from Jenkins (SSH)
resource "aws_vpc_security_group_ingress_rule" "app_from_jenkins_ssh" {
  security_group_id         = aws_security_group.app_sg_group.id
  referenced_security_group_id = aws_security_group.jenkins_sg_group.id
  from_port                 = 22
  to_port                   = 22
  ip_protocol               = "tcp"
}

# App Egress - Internet
resource "aws_vpc_security_group_egress_rule" "app_egress_internet" {
  security_group_id = aws_security_group.app_sg_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

##########################
# Jenkins Security Group
##########################
resource "aws_security_group" "jenkins_sg_group" {
  name   = "jenkins-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "JENKINS-SG"
  }
}

# Jenkins Ingress - SSH from YOUR_IP
resource "aws_vpc_security_group_ingress_rule" "jenkins_ssh" {
  security_group_id = aws_security_group.jenkins_sg_group.id
  cidr_ipv4         = "0.0.0.0/0" # replace with your IP
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# Jenkins Ingress - Web UI (8080) from YOUR_IP
resource "aws_vpc_security_group_ingress_rule" "jenkins_ui" {
  security_group_id = aws_security_group.jenkins_sg_group.id
  cidr_ipv4         = "0.0.0.0/0" # replace with your IP
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

# Jenkins Egress - Internet
resource "aws_vpc_security_group_egress_rule" "jenkins_egress_internet" {
  security_group_id = aws_security_group.jenkins_sg_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}