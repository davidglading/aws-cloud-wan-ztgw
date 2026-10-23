locals {
  # The guide's policy is kept as JSON for review. Only the edge locations are
  # replaced so the same policy works with the configured deployment regions.
  guide_core_network_policy = jsondecode(file("${path.module}/policies/core-network-policy.json"))
  core_network_configuration = merge(local.guide_core_network_policy["core-network-configuration"], {
    "edge-locations" = [for region in local.deployment_regions : { location = region }]
  })
  core_network_policy = merge(local.guide_core_network_policy, {
    "core-network-configuration" = local.core_network_configuration
  })
  attachment_segments = { prod = "Prod", dev = "NonProd", security = "Security" }
}

resource "aws_networkmanager_global_network" "this" {
  provider    = aws.networkmanager
  description = "Global Network for Cloud WAN ZTGW deployment"
  tags = {
    Name      = "${var.naming_prefix}GlobalTransitNetwork"
    Terraform = "true"
  }
}

resource "aws_networkmanager_core_network" "this" {
  provider           = aws.networkmanager
  global_network_id  = aws_networkmanager_global_network.this.id
  description        = "Core Network spanning ${join(", ", local.deployment_regions)}"
  create_base_policy = true
  base_policy_document = jsonencode({
    version                      = "2021.12"
    "core-network-configuration" = local.core_network_configuration
    segments = [{
      name                            = "Prod"
      "require-attachment-acceptance" = false
      "isolate-attachments"           = true
    }]
  })
  tags = {
    Name      = "${var.naming_prefix}MultiRegionCoreNetwork"
    Terraform = "true"
  }
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "aws_networkmanager_core_network_policy_attachment" "this" {
  provider        = aws.networkmanager
  core_network_id = aws_networkmanager_core_network.this.id
  policy_document = jsonencode(local.core_network_policy)
  timeouts {
    update = "60m"
  }
}

# Network Manager is a global API. The subnets/VPC ARNs select each attachment's
# regional edge. Wait for the LIVE NFG policy before creating attachments.

resource "aws_networkmanager_vpc_attachment" "use1" {
  for_each = local.vpc_specs_use1
  provider = aws.networkmanager

  core_network_id = aws_networkmanager_core_network.this.id
  vpc_arn         = aws_vpc.use1[each.key].arn
  subnet_arns = [for az in ["aza", "azb"] : aws_subnet.use1[
    "${each.value.region}-${each.value.role == "security" ? "sec" : each.value.role}-attach-${az}"
  ].arn]
  options {
    appliance_mode_support = each.value.role == "security"
  }
  tags = {
    Name      = "${each.value.vpc_name}-attachment"
    segment   = local.attachment_segments[each.value.role]
    Terraform = "true"
  }
  depends_on = [aws_networkmanager_core_network_policy_attachment.this]
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

resource "aws_networkmanager_vpc_attachment" "use2" {
  for_each = local.vpc_specs_use2
  provider = aws.networkmanager

  core_network_id = aws_networkmanager_core_network.this.id
  vpc_arn         = aws_vpc.use2[each.key].arn
  subnet_arns = [for az in ["aza", "azb"] : aws_subnet.use2[
    "${each.value.region}-${each.value.role == "security" ? "sec" : each.value.role}-attach-${az}"
  ].arn]
  options {
    appliance_mode_support = each.value.role == "security"
  }
  tags = {
    Name      = "${each.value.vpc_name}-attachment"
    segment   = local.attachment_segments[each.value.role]
    Terraform = "true"
  }
  depends_on = [aws_networkmanager_core_network_policy_attachment.this]
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}
