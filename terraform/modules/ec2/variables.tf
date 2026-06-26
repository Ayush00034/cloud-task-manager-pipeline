variable "project_name" {
description = "Project name prefix"
type = string
}
variable "instance_type" {
description = "EC2 instance type for the App Server"
type = string
}
variable "key_name" {
description = "EC2 Key Pair name"
type = string
}
variable "ec2_sg_id" {
description = "Security group ID to attach to the App Server"
type = string
}
variable "public_subnet_id" {
description = "Public subnet ID to launch the App Server into"
type = string
}
variable "iam_profile_name" {
description = "IAM instance profile name for S3 access"
type = string
}