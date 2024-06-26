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

resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.vpc.id

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

resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Security group for the backend"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Security group for the database"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.instance_sg.id]
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

resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.subnet : subnet.id]
  security_groups = [aws_security_group.lb_sg.id]
}

resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/api/songs"
    protocol            = "HTTP"
    interval            = 61
    timeout             = 60
    healthy_threshold   = 2
    unhealthy_threshold = 3
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

data "template_file" "user_data_script" {
  template = file("user_data_script.sh")
}

resource "aws_launch_configuration" "my_lc" {
  name                 = "my-lc"
  image_id             = "ami-08116b9957a259459"
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.ssh_key.key_name
  security_groups      = [aws_security_group.instance_sg.id]
  user_data = data.template_file.user_data_script.rendered
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "cpu_scaling_policy" {
  name                   = "cpu-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 20
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

  target_group_arns = [aws_lb_target_group.my_target_group.arn]

  termination_policies = ["Default"]

  lifecycle {
    create_before_destroy = true
  }
}

### RDS
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [for subnet in aws_subnet.subnet : subnet.id]

  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_db_instance" "playlist" {
  allocated_storage    = 5
  db_name              = "playlist"
  engine               = "mariadb"
  engine_version       = "10.11.6"
  instance_class       = "db.t3.micro"
  username             = var.db_data["username"]
  password             = var.db_data["password"]
  parameter_group_name = "default.mariadb10.11"
  skip_final_snapshot  = true

  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}


### Created with the help of this website
### https://dev.to/aws-builders/how-to-create-a-simple-static-amazon-s3-website-using-terraform-43hc
resource "random_string" "bucket_name" {
  length  = 48
  special = false
}

resource "aws_s3_bucket" "bucket" {
  bucket =  lower(random_string.bucket_name.result)
}

resource "aws_s3_bucket_website_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      }
    ]
  })
}

### Outputs
output "database_ip" {
  value = aws_db_instance.playlist.address
}

output "bucket_name" {
  value = aws_s3_bucket_website_configuration.bucket.bucket
}

output "ssh_private_key" {
  value = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "load_balancer_dns" {
  value = aws_lb.my_alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.playlist.endpoint
}

output "db_username" {
  value = aws_db_instance.playlist.username
}

output "db_password" {
  value = aws_db_instance.playlist.password
  sensitive = true
}

output "bucket_website_endpoint" {
  value = aws_s3_bucket_website_configuration.bucket.website_endpoint
}
