resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for the App Server"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      var.my_ip
    ]
  }

  ingress {
    description = "Flask app"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from App Server only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [
      aws_security_group.ec2_sg.id
    ]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}