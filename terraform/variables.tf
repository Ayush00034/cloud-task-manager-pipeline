variable "aws_region" {
description = "AWS region"
type = string
default = "ap-south-1"
}
variable "project_name" {
description = "Project name prefix for all resources"
type = string
default = "cloud-task-manager"
}
variable "instance_type" {
description = "App Server EC2 instance type"
type = string
default = "t2.micro"
}
variable "db_username" {
description = "RDS master username"
type = string
default = "admin"
}
variable "db_password" {
description = "RDS master password"
type = string
sensitive = true
}
variable "db_name" {
description = "Database name"
type = string
default = "taskdb"
}
variable "key_name" {
description = "EC2 Key Pair name (must exist in AWS)"
type = string
}
variable "my_ip" {
description = "Your local IP for SSH access to the App Server"
type = string
}