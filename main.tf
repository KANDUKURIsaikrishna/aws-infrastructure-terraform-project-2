
# creating the VPC

resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

# creating the public subnets

resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_1b" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true
}

# Create private subnets
resource "aws_subnet" "private_subnet_1a" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-north-1a"
}

resource "aws_subnet" "private_subnet_1b" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-north-1b"
}

# Create NAT Gateways
resource "aws_nat_gateway" "nat_gateway_1a" {
  allocation_id = aws_eip.nat_eip_1a.id
  subnet_id     = aws_subnet.public_subnet_1a.id
}

resource "aws_nat_gateway" "nat_gateway_1b" {
  allocation_id = aws_eip.nat_eip_1b.id
  subnet_id     = aws_subnet.public_subnet_1b.id
}

# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip_1a" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip_1b" {
  domain = "vpc"
}

# Create Load Balancer
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1b.id]
}

# Create Security Group for Load Balancer
resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.myvpc.id

  # Rules for load balancer traffic

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}


# Create Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  launch_configuration   = aws_launch_configuration.ec2_lc.name
  min_size               = 2
  max_size               = 3
  desired_capacity       = 2
  health_check_type     = "EC2"
  termination_policies  = ["OldestInstance"]
  vpc_zone_identifier    = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1b.id]
  launch_template {
    id      = aws_launch_configuration.ec2_lc.id
    version = "1"
  }

  # Add other auto scaling configurations
}






# Create Launch Configuration
resource "aws_launch_configuration" "ec2_lc" {
  image_id          = var.ami_id
  instance_type     = "t2.micro"  # Example instance type, change as needed
  security_groups   = [aws_security_group.instance_sg.id]

  # Add other launch configuration settings
}

# Create Security Group for Instances


  # Add rules for instance traffic

  # Create Security Group for Instances
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.myvpc.id

  # Allow traffic from ALB
  ingress {
    description        = "Allow traffic from ALB"
    from_port          = 80
    to_port            = 80
    protocol           = "tcp"
    security_groups    = [aws_security_group.lb_sg.id]
  }

  # Allow SSH access for management
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace "YOUR_IP" with your actual IP address
  }

  # Allow outgoing traffic to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create Gateway VPC Endpoint for Amazon S3
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.myvpc.id
  service_name      = "com.amazonaws.eu-north-1.s3"
  route_table_ids   = [aws_route_table.private_route_table_1a.id, aws_route_table.private_route_table_1b.id]
}

# Create Route Tables for private subnets
resource "aws_route_table" "private_route_table_1a" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "private_route_table_1b" {
  vpc_id = aws_vpc.myvpc.id
}

# Associate private subnets with route tables
resource "aws_route_table_association" "private_subnet_association_1a" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private_route_table_1a.id
}

resource "aws_route_table_association" "private_subnet_association_1b" {
  subnet_id      = aws_subnet.private_subnet_1b.id
  route_table_id = aws_route_table.private_route_table_1b.id
}

