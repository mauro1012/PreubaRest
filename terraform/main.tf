provider "aws" {
  region = var.aws_region
}

# 1. Backend para el estado remoto
terraform {
  backend "s3" {
    bucket  = "examen-suple-rest-mauro28102023"
    key     = "notificaciones-rest/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

# 3. Red por defecto
data "aws_vpc" "default" { 
  default = true 
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id] 
  }
}

# 4. Security Groups
resource "aws_security_group" "sg_alb_rest" {
  name = "sg_alb_rest_notif"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_app_rest" {
  name = "sg_app_rest_notif"
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb_rest.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Balanceador de Carga (ALB)
resource "aws_lb" "rest_alb" {
  name               = "rest-api-notif-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb_rest.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "rest_tg" {
  name     = "rest-api-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "rest_listener" {
  load_balancer_arn = aws_lb.rest_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rest_tg.arn
  }
}

# 6. Launch Template para el ASG
resource "aws_launch_template" "rest_lt" {
  name_prefix   = "rest-notif-lt-"
  image_id      = "ami-0c7217cdde317cfec" 
  instance_type = "t2.micro"
  key_name      = var.ssh_key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.sg_app_rest.id]
  }

  # Indentación corregida en el docker-compose
  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y docker.io docker-compose
              sudo systemctl start docker

              mkdir -p /home/ubuntu/app && cd /home/ubuntu/app

              cat <<EOT > docker-compose.yml
              version: '3.8'
              services:
                cache-db:
                  image: redis:latest
                  container_name: redis-notif
                  ports:
                    - "6379:6379"
                  restart: always

                api-rest:
                  image: ${var.docker_user}/api-notificaciones:latest
                  container_name: rest-api-servidor
                  ports:
                    - "3000:3000"
                  environment:
                    - REDIS_HOST=cache-db
                    - BUCKET_NAME=${var.bucket_logs}
                    - AWS_ACCESS_KEY_ID=${var.aws_access_key}
                    - AWS_SECRET_ACCESS_KEY=${var.aws_secret_key}
                    - AWS_SESSION_TOKEN=${var.aws_session_token}
                  depends_on:
                    - cache-db
                  restart: always
              EOT
              sudo docker-compose up -d
              EOF
  )
}

# 7. Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "rest_asg" {
  name                = "rest-api-asg"
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.rest_tg.arn]
  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.rest_lt.id
    version = "$Latest"
  }
}

# 8. Bucket S3 para Auditoría
resource "aws_s3_bucket" "bucket_alertas" {
  bucket        = var.bucket_logs
  force_destroy = true
}

# 9. Salidas
output "dns_balanceador_rest" {
  value = aws_lb.rest_alb.dns_name
}