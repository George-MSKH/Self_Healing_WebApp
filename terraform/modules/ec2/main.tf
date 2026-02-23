resource "aws_instance" "application" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = var.private_subnet_id
    key_name = var.devkey
    vpc_security_group_ids = [aws_security_group.app_sg_group.id]

    tags = {
      "Name" = "App-Instance" 
    }
}

