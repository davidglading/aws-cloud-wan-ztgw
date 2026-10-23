resource "aws_vpc" "use1" {
  for_each = local.vpc_specs_use1

  provider = aws.use1

  cidr_block           = each.value.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = each.value.vpc_name
    Role      = each.value.role
    Region    = each.value.region
    Terraform = "true"
  }
}

resource "aws_vpc" "use2" {
  for_each = local.vpc_specs_use2

  provider = aws.use2

  cidr_block           = each.value.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = each.value.vpc_name
    Role      = each.value.role
    Region    = each.value.region
    Terraform = "true"
  }
}

resource "aws_subnet" "use1" {
  for_each = local.subnet_specs_use1

  provider = aws.use1

  vpc_id                  = aws_vpc.use1[each.value.vpc_key].id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name      = each.value.name
    Purpose   = each.value.purpose
    Region    = "us-east-1"
    VPC       = aws_vpc.use1[each.value.vpc_key].tags["Name"]
    Terraform = "true"
  }
}

resource "aws_subnet" "use2" {
  for_each = local.subnet_specs_use2

  provider = aws.use2

  vpc_id                  = aws_vpc.use2[each.value.vpc_key].id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name      = each.value.name
    Purpose   = each.value.purpose
    Region    = "us-east-2"
    VPC       = aws_vpc.use2[each.value.vpc_key].tags["Name"]
    Terraform = "true"
  }
}

resource "aws_security_group" "use1" {
  for_each = local.workload_sg_map_use1

  provider = aws.use1

  name        = each.value.name
  description = "Workload security group for Cloud WAN deployment"
  vpc_id      = aws_vpc.use1[each.value.vpc_key].id

  ingress {
    description = "HTTP from private AWS ranges"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "HTTPS from private AWS ranges"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.4.0.0/16"]
  }

  ingress {
    description = "ICMP from private AWS ranges"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = each.value.name
    Terraform = "true"
  }
}

resource "aws_security_group" "use2" {
  for_each = local.workload_sg_map_use2

  provider = aws.use2

  name        = each.value.name
  description = "Workload security group for Cloud WAN deployment"
  vpc_id      = aws_vpc.use2[each.value.vpc_key].id

  ingress {
    description = "HTTP from private AWS ranges"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "HTTPS from private AWS ranges"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.4.0.0/16"]
  }

  ingress {
    description = "ICMP from private AWS ranges"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = each.value.name
    Terraform = "true"
  }
}

resource "aws_vpc_endpoint" "use1" {
  for_each = local.vpc_endpoint_map_use1

  provider = aws.use1

  vpc_id              = aws_vpc.use1[each.value.vpc_key].id
  service_name        = format("%s.%s.%s", var.vpc_endpoint_service_name, each.value.region, each.value.service_name)
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet_key in each.value.subnet_keys : aws_subnet.use1[subnet_key].id]
  security_group_ids  = [aws_security_group.use1[each.value.sg_key].id]
  private_dns_enabled = true

  tags = {
    Name      = each.value.endpoint_name
    Region    = each.value.region
    Service   = each.value.service_name
    Terraform = "true"
  }
}

resource "aws_vpc_endpoint" "use2" {
  for_each = local.vpc_endpoint_map_use2

  provider = aws.use2

  vpc_id              = aws_vpc.use2[each.value.vpc_key].id
  service_name        = format("%s.%s.%s", var.vpc_endpoint_service_name, each.value.region, each.value.service_name)
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet_key in each.value.subnet_keys : aws_subnet.use2[subnet_key].id]
  security_group_ids  = [aws_security_group.use2[each.value.sg_key].id]
  private_dns_enabled = true

  tags = {
    Name      = each.value.endpoint_name
    Region    = each.value.region
    Service   = each.value.service_name
    Terraform = "true"
  }
}

data "aws_ami" "amazon_linux_2_use1" {
  provider = aws.use1

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "amazon_linux_2_use2" {
  provider = aws.use2

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "use1" {
  for_each = local.ec2_map_use1

  provider = aws.use1

  ami                    = data.aws_ami.amazon_linux_2_use1.id
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.use1[each.value.subnet_key].id
  vpc_security_group_ids = [aws_security_group.use1["${each.value.vpc_key}-workload"].id]
  user_data              = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd
  EOF

  associate_public_ip_address = false

  tags = {
    Name      = each.value.name
    Role      = each.value.role
    Region    = each.value.region
    VPC       = aws_vpc.use1[each.value.vpc_key].tags["Name"]
    Terraform = "true"
  }
}

resource "aws_instance" "use2" {
  for_each = local.ec2_map_use2

  provider = aws.use2

  ami                    = data.aws_ami.amazon_linux_2_use2.id
  instance_type          = each.value.instance_type
  subnet_id              = aws_subnet.use2[each.value.subnet_key].id
  vpc_security_group_ids = [aws_security_group.use2["${each.value.vpc_key}-workload"].id]
  user_data              = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd
  EOF

  associate_public_ip_address = false

  tags = {
    Name      = each.value.name
    Role      = each.value.role
    Region    = each.value.region
    VPC       = aws_vpc.use2[each.value.vpc_key].tags["Name"]
    Terraform = "true"
  }
}
