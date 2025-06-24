provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "pub-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "pub-1"
  }
}

resource "aws_subnet" "pub-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "pub-2"
  }
}

resource "aws_subnet" "pvt-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "pvt-1"
  }
}
resource "aws_subnet" "pvt-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"  # Updated to avoid overlap
  availability_zone = "us-east-1b"
  tags = {
    Name = "pvt-2"
  }
}


resource "aws_internet_gateway" "ig-pub" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ig-pub"
  }
}

resource "aws_route_table" "rt-pub" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig-pub.id
  }

  tags = {
    Name = "rt-pub"
  }
}

resource "aws_route_table_association" "pub-1-assoc" {
  subnet_id      = aws_subnet.pub-1.id
  route_table_id = aws_route_table.rt-pub.id
}

resource "aws_route_table_association" "pub-2-assoc" {
  subnet_id      = aws_subnet.pub-2.id
  route_table_id = aws_route_table.rt-pub.id
}

resource "aws_instance" "frontend_pub" {
  ami                         = "ami-09e6f87a47903347c"  # Amazon Linux 2 AMI (us-east-1)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.pub-1.id
  associate_public_ip_address = true

  vpc_security_group_ids      = [aws_security_group.frontend-sg.id]

  tags = {
    Name = "frontend-pub"
  }
}



resource "aws_security_group" "frontend-sg" {
  name        = "frontend-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
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

  tags = {
    Name = "frontend-sg"
  }
}


