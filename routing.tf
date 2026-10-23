locals {
  workload_vpcs_use1               = { for key, vpc in local.vpc_specs_use1 : key => vpc if vpc.role != "security" }
  workload_vpcs_use2               = { for key, vpc in local.vpc_specs_use2 : key => vpc if vpc.role != "security" }
  security_vpcs_use1               = { for key, vpc in local.vpc_specs_use1 : key => vpc if vpc.role == "security" }
  security_vpcs_use2               = { for key, vpc in local.vpc_specs_use2 : key => vpc if vpc.role == "security" }
  workload_subnets_use1            = { for key, subnet in local.subnet_specs_use1 : key => subnet if subnet.purpose == "Application Workloads" }
  workload_subnets_use2            = { for key, subnet in local.subnet_specs_use2 : key => subnet if subnet.purpose == "Application Workloads" }
  security_attachment_subnets_use1 = { for key, subnet in local.subnet_specs_use1 : key => subnet if subnet.vpc_key == "${var.aws_region}-security" && subnet.purpose == "Cloud WAN Attachment" }
  security_attachment_subnets_use2 = { for key, subnet in local.subnet_specs_use2 : key => subnet if subnet.vpc_key == "${var.secondary_aws_region}-security" && subnet.purpose == "Cloud WAN Attachment" }
  inspection_subnets_use1          = { for key, subnet in local.subnet_specs_use1 : key => subnet if subnet.purpose == "Inspection / GWLBe" }
  inspection_subnets_use2          = { for key, subnet in local.subnet_specs_use2 : key => subnet if subnet.purpose == "Inspection / GWLBe" }
  gwlb_subnets_use1                = { for key, subnet in local.inspection_subnets_use1 : key => subnet if contains(keys(var.ztgw_endpoint_service_names), var.aws_region) }
  gwlb_subnets_use2                = { for key, subnet in local.inspection_subnets_use2 : key => subnet if contains(keys(var.ztgw_endpoint_service_names), var.secondary_aws_region) }
  security_default_routes_use1     = { for key, subnet in local.security_attachment_subnets_use1 : key => subnet if contains(keys(var.ztgw_endpoint_service_names), var.aws_region) }
  security_default_routes_use2     = { for key, subnet in local.security_attachment_subnets_use2 : key => subnet if contains(keys(var.ztgw_endpoint_service_names), var.secondary_aws_region) }
}

# Dedicated workload tables leave spoke attachment subnets on their local-only
# main table. Never install the workload default route on an attachment subnet.

resource "aws_route_table" "workload_use1" {
  for_each = local.workload_vpcs_use1
  provider = aws.use1
  vpc_id   = aws_vpc.use1[each.key].id
  tags = {
    Name      = "${var.naming_prefix}${each.value.short_name}-workload-rtb"
    Terraform = "true"
  }
}

resource "aws_route" "workload_default_use1" {
  for_each               = local.workload_vpcs_use1
  provider               = aws.use1
  route_table_id         = aws_route_table.workload_use1[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = aws_networkmanager_core_network.this.arn
  depends_on             = [aws_networkmanager_vpc_attachment.use1]
}

resource "aws_route_table_association" "workload_use1" {
  for_each       = local.workload_subnets_use1
  provider       = aws.use1
  subnet_id      = aws_subnet.use1[each.key].id
  route_table_id = aws_route_table.workload_use1[each.value.vpc_key].id
}

resource "aws_vpc_endpoint" "ztgw_use1" {
  for_each          = local.gwlb_subnets_use1
  provider          = aws.use1
  vpc_id            = aws_vpc.use1[each.value.vpc_key].id
  service_name      = var.ztgw_endpoint_service_names[var.aws_region]
  vpc_endpoint_type = "GatewayLoadBalancer"
  subnet_ids        = [aws_subnet.use1[each.key].id]
  tags = {
    Name      = replace(each.value.name, "inspection", "ztgw-gwlbe")
    Terraform = "true"
  }
}

resource "aws_route_table" "security_attachment_use1" {
  for_each = local.security_attachment_subnets_use1
  provider = aws.use1
  vpc_id   = aws_vpc.use1[each.value.vpc_key].id
  tags = {
    Name      = replace(each.value.name, "-attach-", "-attach-rtb-")
    Terraform = "true"
  }
}

resource "aws_route_table_association" "security_attachment_use1" {
  for_each       = local.security_attachment_subnets_use1
  provider       = aws.use1
  subnet_id      = aws_subnet.use1[each.key].id
  route_table_id = aws_route_table.security_attachment_use1[each.key].id
}

# A distinct endpoint in each AZ keeps inspection on the incoming flow's AZ.
resource "aws_route" "security_to_ztgw_use1" {
  for_each               = local.security_default_routes_use1
  provider               = aws.use1
  route_table_id         = aws_route_table.security_attachment_use1[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.ztgw_use1[replace(each.key, "-attach-", "-inspection-")].id
}

resource "aws_route_table" "inspection_use1" {
  for_each = local.security_vpcs_use1
  provider = aws.use1
  vpc_id   = aws_vpc.use1[each.key].id
  tags = {
    Name      = "${var.naming_prefix}sec${local.region_suffix_map[each.value.region]}-inspection-rtb"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "inspection_use1" {
  for_each       = local.inspection_subnets_use1
  provider       = aws.use1
  subnet_id      = aws_subnet.use1[each.key].id
  route_table_id = aws_route_table.inspection_use1[each.value.vpc_key].id
}

# The guide uses 10.0.0.0/8 for private return traffic. Do not add a default
# route here: Internet egress is supplied by ZTGW/ZIA, not an AWS NAT gateway.
resource "aws_route" "inspection_return_use1" {
  for_each               = local.security_vpcs_use1
  provider               = aws.use1
  route_table_id         = aws_route_table.inspection_use1[each.key].id
  destination_cidr_block = "10.0.0.0/8"
  core_network_arn       = aws_networkmanager_core_network.this.arn
  depends_on             = [aws_networkmanager_vpc_attachment.use1]
}

resource "aws_route_table" "workload_use2" {
  for_each = local.workload_vpcs_use2
  provider = aws.use2
  vpc_id   = aws_vpc.use2[each.key].id
  tags = {
    Name      = "${var.naming_prefix}${each.value.short_name}-workload-rtb"
    Terraform = "true"
  }
}

resource "aws_route" "workload_default_use2" {
  for_each               = local.workload_vpcs_use2
  provider               = aws.use2
  route_table_id         = aws_route_table.workload_use2[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = aws_networkmanager_core_network.this.arn
  depends_on             = [aws_networkmanager_vpc_attachment.use2]
}

resource "aws_route_table_association" "workload_use2" {
  for_each       = local.workload_subnets_use2
  provider       = aws.use2
  subnet_id      = aws_subnet.use2[each.key].id
  route_table_id = aws_route_table.workload_use2[each.value.vpc_key].id
}

resource "aws_vpc_endpoint" "ztgw_use2" {
  for_each          = local.gwlb_subnets_use2
  provider          = aws.use2
  vpc_id            = aws_vpc.use2[each.value.vpc_key].id
  service_name      = var.ztgw_endpoint_service_names[var.secondary_aws_region]
  vpc_endpoint_type = "GatewayLoadBalancer"
  subnet_ids        = [aws_subnet.use2[each.key].id]
  tags = {
    Name      = replace(each.value.name, "inspection", "ztgw-gwlbe")
    Terraform = "true"
  }
}

resource "aws_route_table" "security_attachment_use2" {
  for_each = local.security_attachment_subnets_use2
  provider = aws.use2
  vpc_id   = aws_vpc.use2[each.value.vpc_key].id
  tags = {
    Name      = replace(each.value.name, "-attach-", "-attach-rtb-")
    Terraform = "true"
  }
}

resource "aws_route_table_association" "security_attachment_use2" {
  for_each       = local.security_attachment_subnets_use2
  provider       = aws.use2
  subnet_id      = aws_subnet.use2[each.key].id
  route_table_id = aws_route_table.security_attachment_use2[each.key].id
}

# A distinct endpoint in each AZ keeps inspection on the incoming flow's AZ.
resource "aws_route" "security_to_ztgw_use2" {
  for_each               = local.security_default_routes_use2
  provider               = aws.use2
  route_table_id         = aws_route_table.security_attachment_use2[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.ztgw_use2[replace(each.key, "-attach-", "-inspection-")].id
}

resource "aws_route_table" "inspection_use2" {
  for_each = local.security_vpcs_use2
  provider = aws.use2
  vpc_id   = aws_vpc.use2[each.key].id
  tags = {
    Name      = "${var.naming_prefix}sec${local.region_suffix_map[each.value.region]}-inspection-rtb"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "inspection_use2" {
  for_each       = local.inspection_subnets_use2
  provider       = aws.use2
  subnet_id      = aws_subnet.use2[each.key].id
  route_table_id = aws_route_table.inspection_use2[each.value.vpc_key].id
}

# The guide uses 10.0.0.0/8 for private return traffic. Do not add a default
# route here: Internet egress is supplied by ZTGW/ZIA, not an AWS NAT gateway.
resource "aws_route" "inspection_return_use2" {
  for_each               = local.security_vpcs_use2
  provider               = aws.use2
  route_table_id         = aws_route_table.inspection_use2[each.key].id
  destination_cidr_block = "10.0.0.0/8"
  core_network_arn       = aws_networkmanager_core_network.this.arn
  depends_on             = [aws_networkmanager_vpc_attachment.use2]
}
