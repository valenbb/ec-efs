variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Desired instance type for EC2"
  default = "t2.medium"
}

variable "vpc_prod_id" {
  description = "Production VPC ID"
  default = "vpc-0e628976"
}

variable "subnet_id" {
  description = "Subnet ID to use"
  default = "subnet-a8181884"
}

variable "az_id" {
  description = "Availability Zone"
  default = "us-east-1d"
}

variable "cidr" {
  description = "CIDR for subnet"
  default = "10.0.4.0/24"
}

# Amazon AMI
variable "aws_ami" {
  default = "ami-8c1be5f6"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "esn-devops"
}

variable "ssh_key_filename" {
  description = "Enter the path to the SSH Private Key to run provisioner."
  default = "/var/lib/jenkins/.ssh/esn-devops.pem"
}
