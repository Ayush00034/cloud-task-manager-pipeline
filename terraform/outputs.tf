output "app_server_ip" {
description = "Public IP of the App Server"
value = module.ec2.public_ip
}



output "rds_endpoint" {
description = "RDS connection endpoint"
value = aws_db_instance.mysql.endpoint 
}

output "s3_bucket_name" {
description = "S3 bucket name for uploads"
value = aws_s3_bucket.uploads.bucket 
}

output "app_url" {
description = "Flask app URL"
value = "http://${module.ec2.public_ip}:5000"
}
