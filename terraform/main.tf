terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
terraform {
  backend "s3" {
    bucket       = "ayush-vvce-tfstate-2026" # The exact name of the bucket you just created
    key          = "vpc-infrastructure/terraform.tfstate"
    region       = "ap-south-1"              # The exact region where you created the bucket
    use_lockfile = true                      # Enables native S3 locking (No DynamoDB needed!)
    encrypt      = true
  }
}
provider "aws" {
  region = var.aws_region
}

# -- Networking -----------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-private-subnet-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.project_name}-private-subnet-b"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# -- Security Groups via Module --------------------------------------------
module "security_groups" {
  source       = "./modules/security_group"
  project_name = var.project_name
  vpc_id       = aws_vpc.main.id
  my_ip        = "${var.my_ip}/32"
}

# -- IAM Role for App Server to access S3 -----------------------------------
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-app-profile"
  role = aws_iam_role.ec2_role.name
}

# -- S3 Bucket --------------------------------------------------------------
resource "aws_s3_bucket" "uploads" {
  bucket = "${var.project_name}-uploads-${random_string.suffix.result}"

  tags = {
    Name = "${var.project_name}-uploads"
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# -- RDS MySQL ---------------------------------------------------------------
resource "aws_db_subnet_group" "rds_subnets" {
  name = "${var.project_name}-rds-subnet-group"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "${var.project_name}-rds-subnets"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "${var.project_name}-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids = [
    module.security_groups.rds_sg_id
  ]

  skip_final_snapshot      = true
  publicly_accessible      = false
  backup_retention_period  = 0

  tags = {
    Name = "${var.project_name}-rds"
  }
}

# -- App Server via Module ----------------------------------------------------
module "ec2" {
  source = "./modules/ec2"

  project_name    = var.project_name
  instance_type   = var.instance_type
  key_name        = var.key_name
  ec2_sg_id       = module.security_groups.ec2_sg_id
  public_subnet_id = aws_subnet.public.id
  iam_profile_name = aws_iam_instance_profile.ec2_profile.name
}