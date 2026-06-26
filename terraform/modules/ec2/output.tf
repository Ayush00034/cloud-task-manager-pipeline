output "public_ip" {
description = "Public IP address of the App Server"
value = aws_instance.app_server.public_ip
}

output "instance_id" {
description = "Instance ID of the App Server"
value = aws_instance.app_server.id
}