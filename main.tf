resource "aws_vpc" "vpc1" {
  cidr_block       = "172.120.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Terraform-vpc"
    env  = "Dev"

  }

}

## public Subnet

resource "aws_subnet" "public_subnet1" {
  availability_zone       = "us-east-1a"
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "172.120.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-public-vpc"
    env  = "Dev"
  }
}

resource "aws_subnet" "public_subnet2" {
  availability_zone       = "us-east-1b"
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "172.120.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-public-vpc"
    env  = "Dev"
  }
}
## Private subnet

resource "aws_subnet" "private_subnet1" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "172.120.3.0/24"
  tags = {
    Name = "subnet-private-vpc"
    env  = "Dev"
  }

}
resource "aws_subnet" "private_subnet2" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "172.120.4.0/24"
  tags = {
    Name = "subnet-private-vpc"
    env  = "Dev"
  }

}
## route table
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gtw1.id
  }

}
## gateway

resource "aws_internet_gateway" "gtw1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    name = "IGW"
  }

}

## route table association

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.rt1.id
}

## security group

resource "aws_security_group" "sg-demo" {
  name        = "webserver-sg-dev"
  description = "Allow ssh and httpd"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow http"
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
    env = "Dev"
  }
}

## instance

resource "aws_instance" "ec2-demo" {
  ami                    = "ami-0bb4c991fa89d4b9b"
  vpc_security_group_ids = [aws_security_group.sg-demo.id]
  instance_type          = "t2.micro"
  key_name               = "ec2-demo"
  subnet_id              = aws_subnet.public_subnet1.id
  user_data              = file("install.sh")

}

output "public-ip" {
  value = aws_instance.ec2-demo.public_ip

}

