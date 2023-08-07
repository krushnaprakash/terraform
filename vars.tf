variable "aws_region" {
  default = "us-east-1" 
}
variable "vpc_cidr" {
    default = "10.0.0.0/16"
}
variable "ec2_ami" {
    default = "ami-09538990a0c4fe9be"
}     #amzon linux-2
variable "instance_key" {
    default = "3tierkey"
}
variable "ec2_instance_type" {
    default = "t2.micro"
}
variable "load_balancer" {
    default = "application"
}
variable "target_type" {
    default = "instance"
}
variable "pub_cidr" {
    default = "10.0.1.0/24"
}
variable "pub_cidr_2" {
    default = "10.0.2.0/24"
}
variable "pvt_cidr" {
    default = "10.0.3.0/24"
}
