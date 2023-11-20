
###########provider##############

provider "aws" {
    region = var.region #region variable
    
    default_tags { #apply default tags for any resource
      tags = merge(var.common_tags, #merge common tags with Environmet tag based on env variable
      {
        Environment = var.env 
      }, )  
    }
}

###########data##############

data "aws_availability_zones" "working" {} #list of zones in AWS region

data "aws_ami" "latest_amazon_linux" { #filter names to get latest Amazon Linux Image 2023 AMI
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"] 
  }
}

###########resource##############

resource "aws_default_vpc" "default" {} # reqiured to get default VPC id

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.working.names[0] #return name of 1st AZ in current region
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.working.names[1] #return name of 2nd AZ in current region
}

resource "aws_security_group" "web" {    #defines SG in default VPC
  name   = "Web-Server Security Group"
  vpc_id = aws_default_vpc.default.id 
  dynamic "ingress" {
    for_each = var.allow_ports #define port range from variable
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "Web-Server Security Group"  #extra tag 
    }
}

resource "aws_launch_template" "web" {
  name                   = "WebServer-Highly-Available-LT"
  image_id               = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.env == "prod" ? "t2.large" : "t2.micro" #defines instance type based on condition 
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = filebase64("web-server.sh")
  
  monitoring {
    enabled = var.enable_monitoring
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "Web-Server-ASG-Ver-${aws_launch_template.web.latest_version}" #dynamic name based on LT version
  min_size            = var.env == "prod" ? 2 : 1  #ASG sizing bazed on condition if env variable is prod or other 
  max_size            = var.env == "prod" ? 2 : 1  # -//-
  min_elb_capacity    = var.env == "prod" ? 2 : 1  # -//-
  health_check_type   = "ELB"
  vpc_zone_identifier = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  target_group_arns = [aws_lb_target_group.web.arn]
  
  launch_template {
    id = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  dynamic "tag" { #dynamic tagging based on launch template version
    for_each = {
      Name   = "Web-Server in ASG-v${aws_launch_template.web.latest_version}" 
      Owner  = "Max"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "web" {
  name               = "Web-Server-HighlyAvailable-ALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  
  tags =  {
    Name = "Web-Server-HighlyAvailable-ALB" #extra tag
    }
}

resource "aws_lb_target_group" "web" {
  name                 = "Web-Server-TG"
  vpc_id               = aws_default_vpc.default.id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 10 #The amount of time for Elastic Load Balancing to wait before deregistering a target. The range is 0–3600 seconds. The default value is 300 seconds.
  
  stickiness {
    type = "lb_cookie"
  }

 tags =  {
    Name = "Web-Server-TG" #extra tag
    }
}
  
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  tags =  {
    Name = "aws_lb_listener" #extra tag
    }
}

resource "aws_iam_user" "iam_users" {
    count = length(var.iam_users)
    name = element(var.iam_users, count.index)
}