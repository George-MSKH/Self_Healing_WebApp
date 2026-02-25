variable "public_subnet_id" {
    type = list(string)
}
variable "private_subnet_id" {
    type = list(string)
}
variable "alb_security_group_id" {}
variable "vpc_id" {}
variable "app_instance_id" {
    type = map(string)
}
