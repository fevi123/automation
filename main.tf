# Provider configuration (replace with your preferred cloud provider)
provider "aws" {
  region = "ap-south-1"      #fevi7@gmail.com 
}

# Create a key pair
resource "aws_key_pair" "example" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Path to your public key file
}

# Create a security group allowing SSH access
resource "aws_security_group" "example" {
  name        = "example-security-group"
  description = "Allow SSH access"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  }

# Create a load balancer
resource "aws_lb" "example" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  
  subnets = ["subnet-12345678", "subnet-87654321"]  # Replace with your subnet IDs
  
  security_groups = [aws_security_group.example.id]
  
  tags = {
    Name = "example-lb"
  }
}

# Create an autoscaling group
resource "aws_autoscaling_group" "example" {
  name                 = "example-asg"
  min_size             = 2
  max_size             = 5
  desired_capacity     = 2
  health_check_type    = "EC2"
  health_check_grace_period = 300
  vpc_zone_identifier  = ["subnet-12345678", "subnet-87654321"]  # Replace with your subnet IDs
  
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }
}

# Create a launch template
resource "aws_launch_template" "example" {
  name_prefix   = "example-lt"
  image_id      = "ami-12345678"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  
  key_name               = aws_key_pair.example.key_name
  security_group_names   = [aws_security_group.example.name]
  vpc_security_group_ids = [aws_security_group.example.id]
  
  user_data = <<EOF
              #!/bin/bash
              echo "Hello, World!"
              EOF
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "example-instance"
    }
  }
}
