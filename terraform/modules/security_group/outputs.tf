output "ec2_sg_id" {
description = "Security group ID for the App Server"
value = aws_security_group.ec2_sg.id
}

output "rds_sg_id" {
description = "Security group ID for RDS"
value = aws_security_group.rds_sg.id
}