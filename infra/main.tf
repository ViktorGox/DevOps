terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.44.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "subnet" {
  for_each = var.subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  map_public_ip_on_launch = true

  tags = {
    Name = each.key
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "example" {
  for_each = aws_subnet.subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_table.id

  depends_on = [aws_route_table.route_table]
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "my-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

#resource "aws_instance" "backend" {
#  ami           = "ami-08116b9957a259459"
#  instance_type = "t2.micro"
#  key_name      = aws_key_pair.ssh_key.key_name
#  subnet_id     = aws_subnet.subnet.id
#  vpc_security_group_ids = [aws_security_group.instance_sg.id]
#  user_data     = var.user_data_script
#
#  tags = {
#    Name = "BackendInstance"
#  }
#}

resource "aws_instance" "database" {
  ami           = "ami-08116b9957a259459"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key.key_name
  subnet_id     = aws_subnet.subnet["subnet1"].id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  user_data     = var.user_data_script

  tags = {
    Name = "DatabaseInstance"
  }
}

resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.subnet : subnet.id]
}

resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

resource "aws_launch_configuration" "my_lc" {
  name                 = "my-lc"
  image_id             = "ami-08116b9957a259459"
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.ssh_key.key_name
  security_groups      = [aws_security_group.instance_sg.id]
  user_data            = var.user_data_script
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "my_asg" {
  name                      = "my-asg"
  max_size                  = 5
  min_size                  = 2
  desired_capacity          = 2
  vpc_zone_identifier       = [for subnet in aws_subnet.subnet : subnet.id]
  launch_configuration      = aws_launch_configuration.my_lc.name
  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "FinalAssingment"
    value               = "autoscaling-group"
    propagate_at_launch = true
  }
}


### Created with the help of this website
### https://dev.to/aws-builders/how-to-create-a-simple-static-amazon-s3-website-using-terraform-43hc
#resource "aws_s3_bucket" "bucket" {
#  bucket = "devops-final-assignment-bobby-viktor"
#}
#
#resource "aws_s3_bucket_website_configuration" "bucket" {
#  bucket = aws_s3_bucket.bucket.id
#  index_document {
#    suffix = "index.html"
#  }
#}
#
#resource "aws_s3_bucket_public_access_block" "public_access_block" {
#  bucket = aws_s3_bucket.bucket.id
#  block_public_acls       = false
#  block_public_policy     = false
#  ignore_public_acls      = false
#  restrict_public_buckets = false
#}
#
#resource "aws_s3_object" "upload_objects" {
#  bucket = aws_s3_bucket.bucket.id
#  for_each = fileset("html/", "**/*")  # Recursive fileset
#
#  key    = each.value
#  source = "html/${each.value}"
#  etag   = filemd5("html/${each.value}")
#  content_type  = "text/html"
#}
#resource "aws_s3_bucket_policy" "bucket_policy" {
#  bucket = aws_s3_bucket.bucket.id
#
#  policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Effect    = "Allow"
#        Principal = "*"
#        Action = [
#          "s3:GetObject"
#        ]
#        Resource = [
#          "${aws_s3_bucket.bucket.arn}/*"
#        ]
#      }
#    ]
#  })
#}

#output "instance_ip" {
#  value = aws_instance.backend.public_ip
#}
#
output "database_ip" {
  value = aws_instance.database.public_ip
}

#output "bucket_website_endpoint" {
#  value = aws_s3_bucket_website_configuration.bucket.website_endpoint
#}

output "ssh_private_key" {
  value = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
