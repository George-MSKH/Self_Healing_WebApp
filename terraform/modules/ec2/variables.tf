variable "ami_id" {}
variable "instance_type" {}
variable "public_subnet_id" {
    type = list(string)
}
variable "private_subnet_id" {
    type = list(string)
}
variable "devkey" {}
variable "alb_sg_group_id" {}
variable "app_sg_group_id" {}
variable "jenkins_sg_group_id" {}