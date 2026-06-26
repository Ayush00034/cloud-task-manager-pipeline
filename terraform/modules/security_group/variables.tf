variable "project_name" {
description = "Project name prefix for all resources"
type = string
}
variable "vpc_id" {
description = "VPC ID where security groups will be created"
type = string
}
variable "my_ip" {
description = "Your IP in CIDR form, e.g. 1.2.3.4/32"
type = string
}