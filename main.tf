resource "aws_vpc" "this" {
  for_each = local.vpc_specs

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

resource "aws_subnet" "this" {
  for_each = local.subnet_specs

  vpc_id                  = aws_vpc.this[each.value.vpc_key].id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name      = each.value.name
    Purpose   = each.value.purpose
    Region    = var.aws_region
    VPC       = aws_vpc.this[each.value.vpc_key].tags["Name"]
    Terraform = "true"
  }
}

resource "aws_security_group" "workload" {
  for_each = local.workload_sg_map

  name        = each.value.name
  description = "Workload security group for Cloud WAN deployment"
  vpc_id      = aws_vpc.this[each.value.vpc_key].id

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

resource "aws_vpc_endpoint" "interface" {
  for_each = local.vpc_endpoint_map

  vpc_id              = aws_vpc.this[each.value.vpc_key].id
  service_name        = format("%s.%s.%s", var.vpc_endpoint_service_name, each.value.region, each.value.service_name)
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet_key in each.value.subnet_keys : aws_subnet.this[subnet_key].id]
  security_group_ids  = [aws_security_group.workload[each.value.sg_key].id]
  private_dns_enabled = true

  tags = {
    Name      = each.value.endpoint_name
    Region    = each.value.region
    Service   = each.value.service_name
    Terraform = "true"
  }
}
