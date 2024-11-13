resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Project VPC"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  count  = length(var.public_subnet_cidrs)


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Public Route Table ${count.index + 1}"
  }
}
resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt[count.index].id

}

resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.AZs, count.index)

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }

}

resource "aws_eip" "elastic_IP" {
  # this just needs to be created no need for an argument the VPC argument
  #   vpc = true
  #   associate_with_private_ip = var.private_subnet_cidrs
  count = length(var.private_subnet_cidrs)
}

resource "aws_nat_gateway" "demo-nat-gateway" {

  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.elastic_IP[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id


  tags = {
    Name = "Demo NAT Gateway ${count.index + 1}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.IGW]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  count  = length(var.public_subnet_cidrs)

  route {
    cidr_block = "0.0.0.0/0" # Allow outbound access to all IPs
    gateway_id = aws_nat_gateway.demo-nat-gateway[count.index].id
  }

  tags = {
    Name = "Private Route Table ${count.index + 1}"
  }
}
resource "aws_route_table_association" "private_subnet_asso" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id

}
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.AZs, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }

}

# Public instance Security Group (traffic HTTP -> EC2, ssh -> EC2)
resource "aws_security_group" "ec2_Public_SG" {
  name        = "ec2_Public_SG"
  description = "Allows inbound access traffic on port HTTP and ssh"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
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
    Name = "Public Security Group"
  }
}

# Private instance Security Group (traffic ssh -> EC2)
resource "aws_security_group" "ec2_Private_SG" {
  name        = "ec2_Private_SG"
  description = "Allows inbound access ssh traffic only from within the VPC only"
  vpc_id      = aws_vpc.main.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.public_subnet_cidrs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private Security Group"
  }
}

# Create an Public EC2 instance
resource "aws_instance" "public_instance" {
  ami           = var.AMI
  instance_type = "t2.micro" # make this a variable
  key_name      = "network"  # make this a variable 
  count         = length(var.public_subnet_cidrs)

  subnet_id                   = aws_subnet.public_subnet[count.index].id
  vpc_security_group_ids      = [aws_security_group.ec2_Public_SG.id]
  associate_public_ip_address = true

  #   specify the root volume
  root_block_device {
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }

  tags = {
    Name = "Public Instance ${count.index + 1}"
  }

}

# Create an Private EC2 instance
resource "aws_instance" "private_instance" {
  ami           = var.AMI
  instance_type = "t2.micro"
  key_name      = "network"
  count         = length(var.private_subnet_cidrs)

  subnet_id                   = aws_subnet.private_subnet[count.index].id
  vpc_security_group_ids      = [aws_security_group.ec2_Private_SG.id]
  associate_public_ip_address = false

  #   specify the root volume
  root_block_device {
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }

  tags = {
    Name = "Private Instance ${count.index + 1}"
  }

}

# Additional EBS Volumes
# The code below could be further refactored but would be left for simplicity sake.
# the created ebs volumes will persist upon termination of the instance. It needs to be deleted manually.
resource "aws_ebs_volume" "public_instance_ebs" {
  count             = length(var.public_subnet_cidrs)
  availability_zone = aws_instance.public_instance[count.index].availability_zone
  size              = var.myEbs_Volume
  tags = {
    Name = "Public Instance EBS ${count.index + 1}"
  }
}
resource "aws_volume_attachment" "attach_public_ebs" {
  count       = length(var.public_subnet_cidrs)
  instance_id = aws_instance.public_instance[count.index].id
  volume_id   = aws_ebs_volume.public_instance_ebs[count.index].id
  device_name = "/dev/sdh"
}
# Private Instance EBS
resource "aws_ebs_volume" "private_instance_ebs" {
  count             = length(var.private_subnet_cidrs)
  availability_zone = aws_instance.private_instance[count.index].availability_zone
  size              = var.myEbs_Volume
  tags = {
    Name = "Private Instance EBS ${count.index + 1}"
  }
}
resource "aws_volume_attachment" "attach_private_ebs" {
  count       = length(var.private_subnet_cidrs)
  instance_id = aws_instance.private_instance[count.index].id
  volume_id   = aws_ebs_volume.private_instance_ebs[count.index].id
  device_name = "/dev/sdh"

}
