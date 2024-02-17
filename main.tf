
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
  availability_zones     = ["eu-north-1a", "eu-north-1b"]
  launch_configuration   = aws_launch_configuration.example_lc.name
  min_size               = 1
  max_size               = 3
  desired_capacity       = 2
  vpc_zone_identifier    = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1b.id]

  # Add other auto scaling configurations
}

# Create Launch Configuration
resource "aws_instance" "webserver1" {
  ami = "ami-0014ce3e52359afbd"  # Specify an appropriate AMI ID
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data              = base64encode(file("userdata.sh"))
}

resource "aws_instance" "webserver2" {
  ami = "ami-0014ce3e52359afbd"  # Specify an appropriate AMI ID
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = base64encode(file("userdata1.sh"))
}


