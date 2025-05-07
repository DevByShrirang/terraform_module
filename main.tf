

terraform {
  required_version = "~> 1.9.8"

  required_providers {
    aws = {
      version = "~> 5.52.0"

    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"

    }
  }
}
provider "aws" {
  region = var.region_name
}

resource "aws_vpc" "Prod" {
    cidr_block =  var.vpc_cidr_block                  
    enable_dns_support = "true"
    enable_dns_hostnames = "true"

    tags = {
        name = "production-vpc"
        Service = "terraform"
    }
    
}

resource "aws_subnet"  "Public" {
    vpc_id = aws_vpc.Prod.id
    cidr_block =  var.subnet_cidr_block
    map_public_ip_on_launch = "true"
    availability_zone = var.az_zone
    
    tags = {
        Name = "public-subnet-Terra"
        service = "Terraform"
      
    }

  
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Prod.id

  tags = {

    Name = "IGW-Terra"
    Service = "Terraform"
    

  }
}

resource "aws_route_table" "Public" {
  vpc_id = aws_vpc.Prod.id

  route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "Public-Routetable-Terra"
    Service = "Terraform"
  }
}

resource "aws_route_table_association" "Public" {
  subnet_id      = aws_subnet.Public.id
  route_table_id = aws_route_table.Public.id
}


resource "aws_security_group" "Prod-SG" {
  name        = "allow_Terra"
  description = "Allow inbound traffic on ports 22 (SSH) and 80 (HTTP)"
  vpc_id      = aws_vpc.Prod.id



  ingress {
    description = "allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "Allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
     Name  = "SG-Terra"
     Service = "terraform"

    }
  }

resource "aws_instance" "production-ec2" {
count = 2
  ami           = var.ami_id   
  instance_type = var.instance_type
  key_name      = var.key_name             

  tags = {
    Name = "prod-server"
  }
  depends_on = [ aws_security_group.Prod-SG  ]
  }













