# Route 53 equivalent of Zscaler's zs_cc_cf_template_zpa_r53.yaml and its
# per-application macro expansion. No Lambda/CloudFormation macro is required.
locals {
  zpa_cloud_domains = { ZPA = "prod.zpath.net", ZPA-Beta = "zpabeta.net" }
  zpa_dns_app_domains = {
    for key, config in var.zpa_dns : key => toset([
      for domain in config.application_domain_names : trimspace(domain) == "." ? "." : lower(trimsuffix(trimspace(domain), "."))
    ])
  }
  zpa_dns_system_domains = {
    for key, config in var.zpa_dns : key => toset([
      for domain in setunion(
        toset(["zscaler.com", "freebsd.org", "ntp.org", "amazonaws.com", lookup(local.zpa_cloud_domains, config.zpa_cloud_name, "prod.zpath.net")]),
        config.zscaler_cloud_name == "" ? toset([]) : toset([config.zscaler_cloud_name]),
        config.additional_system_domains
      ) : lower(trimsuffix(trimspace(domain), "."))
    ])
  }
  zpa_dns_names = {
    for key in keys(var.zpa_dns) : key => "${substr(replace(var.naming_prefix, "/[^a-zA-Z0-9_-]/", "-"), 0, 20)}zpa-${substr(key, 0, 24)}-${substr(sha1(key), 0, 8)}"
  }
  zpa_dns_use1 = { for key, config in var.zpa_dns : key => config if contains(keys(local.workload_vpcs_use1), key) }
  zpa_dns_use2 = { for key, config in var.zpa_dns : key => config if contains(keys(local.workload_vpcs_use2), key) }
  zpa_dns_forward_rules = merge({}, [
    for key, domains in local.zpa_dns_app_domains : {
      for domain in domains : "${key}:${domain}" => { vpc_key = key, domain = domain }
    }
  ]...)
  zpa_dns_system_rules = merge({}, [
    for key, domains in local.zpa_dns_system_domains : {
      for domain in domains : "${key}:${domain}" => { vpc_key = key, domain = domain }
    }
  ]...)
  zpa_dns_forward_use1 = { for key, rule in local.zpa_dns_forward_rules : key => rule if contains(keys(local.zpa_dns_use1), rule.vpc_key) }
  zpa_dns_forward_use2 = { for key, rule in local.zpa_dns_forward_rules : key => rule if contains(keys(local.zpa_dns_use2), rule.vpc_key) }
  zpa_dns_system_use1  = { for key, rule in local.zpa_dns_system_rules : key => rule if contains(keys(local.zpa_dns_use1), rule.vpc_key) }
  zpa_dns_system_use2  = { for key, rule in local.zpa_dns_system_rules : key => rule if contains(keys(local.zpa_dns_use2), rule.vpc_key) }
}

# Variable validation cannot reference deployment locals in Terraform 1.5.
# Fail explicitly instead of silently skipping a misspelled/inactive VPC key.
resource "terraform_data" "zpa_dns_configuration" {
  count = length(var.zpa_dns) > 0 ? 1 : 0
  input = sort(keys(var.zpa_dns))
  lifecycle {
    precondition {
      condition = alltrue([
        for key in keys(var.zpa_dns) : contains(keys(local.workload_sg_map), "${key}-workload")
      ])
      error_message = "Every zpa_dns key must select a Prod or Dev VPC in an active deployment region."
    }
    precondition {
      condition = alltrue([
        for key in keys(var.zpa_dns) : length(setintersection(local.zpa_dns_app_domains[key], local.zpa_dns_system_domains[key])) == 0
      ])
      error_message = "An application domain cannot also be a SYSTEM exception in the same VPC."
    }
  }
}

# Stateful outbound DNS only: reply traffic is allowed without inbound rules.
resource "aws_security_group" "zpa_dns_use1" {
  for_each    = local.zpa_dns_use1
  provider    = aws.use1
  name_prefix = "${local.zpa_dns_names[each.key]}-"
  description = "ZPA Route 53 outbound DNS resolver"
  vpc_id      = aws_vpc.use1[each.key].id

  dynamic "egress" {
    for_each = toset(["tcp", "udp"])
    content {
      description = "DNS to configured ZPA resolver targets"
      protocol    = egress.value
      from_port   = each.value.target_port
      to_port     = each.value.target_port
      cidr_blocks = [for ip in sort(tolist(each.value.target_ips)) : "${ip}/32"]
    }
  }
  tags = {
    Name      = "${local.zpa_dns_names[each.key]}-sg"
    Terraform = "true"
  }
}

resource "aws_route53_resolver_endpoint" "zpa_use1" {
  for_each               = local.zpa_dns_use1
  provider               = aws.use1
  name                   = local.zpa_dns_names[each.key]
  direction              = "OUTBOUND"
  resolver_endpoint_type = "IPV4"
  protocols              = ["Do53"]
  security_group_ids     = [aws_security_group.zpa_dns_use1[each.key].id]

  dynamic "ip_address" {
    for_each = toset(["aza", "azb"])
    content {
      subnet_id = aws_subnet.use1["${each.key}-workload-${ip_address.value}"].id
    }
  }
  tags = {
    Function  = "ZSCCAppSegmentResolver"
    Terraform = "true"
  }
  depends_on = [terraform_data.zpa_dns_configuration, aws_route.workload_default_use1]
}

resource "aws_route53_resolver_rule" "zpa_forward_use1" {
  for_each             = local.zpa_dns_forward_use1
  provider             = aws.use1
  name                 = "${substr(local.zpa_dns_names[each.value.vpc_key], 0, 43)}-f-${substr(sha1(each.value.domain), 0, 12)}"
  domain_name          = each.value.domain
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.zpa_use1[each.value.vpc_key].id

  dynamic "target_ip" {
    for_each = var.zpa_dns[each.value.vpc_key].target_ips
    content {
      ip   = target_ip.value
      port = var.zpa_dns[each.value.vpc_key].target_port
    }
  }
  tags = {
    Function  = "ZSCCAppSegmentResolver"
    Terraform = "true"
  }
}

resource "aws_route53_resolver_rule_association" "zpa_forward_use1" {
  for_each         = local.zpa_dns_forward_use1
  provider         = aws.use1
  name             = aws_route53_resolver_rule.zpa_forward_use1[each.key].name
  resolver_rule_id = aws_route53_resolver_rule.zpa_forward_use1[each.key].id
  vpc_id           = aws_vpc.use1[each.value.vpc_key].id
}

resource "aws_route53_resolver_rule" "zpa_system_use1" {
  for_each    = local.zpa_dns_system_use1
  provider    = aws.use1
  name        = "${substr(local.zpa_dns_names[each.value.vpc_key], 0, 43)}-s-${substr(sha1(each.value.domain), 0, 12)}"
  domain_name = each.value.domain
  rule_type   = "SYSTEM"
  tags = {
    Function  = "ZPAResolverSystemException"
    Terraform = "true"
  }
  depends_on = [terraform_data.zpa_dns_configuration]
}

resource "aws_route53_resolver_rule_association" "zpa_system_use1" {
  for_each         = local.zpa_dns_system_use1
  provider         = aws.use1
  name             = aws_route53_resolver_rule.zpa_system_use1[each.key].name
  resolver_rule_id = aws_route53_resolver_rule.zpa_system_use1[each.key].id
  vpc_id           = aws_vpc.use1[each.value.vpc_key].id
}

# Stateful outbound DNS only: reply traffic is allowed without inbound rules.
resource "aws_security_group" "zpa_dns_use2" {
  for_each    = local.zpa_dns_use2
  provider    = aws.use2
  name_prefix = "${local.zpa_dns_names[each.key]}-"
  description = "ZPA Route 53 outbound DNS resolver"
  vpc_id      = aws_vpc.use2[each.key].id

  dynamic "egress" {
    for_each = toset(["tcp", "udp"])
    content {
      description = "DNS to configured ZPA resolver targets"
      protocol    = egress.value
      from_port   = each.value.target_port
      to_port     = each.value.target_port
      cidr_blocks = [for ip in sort(tolist(each.value.target_ips)) : "${ip}/32"]
    }
  }
  tags = {
    Name      = "${local.zpa_dns_names[each.key]}-sg"
    Terraform = "true"
  }
}

resource "aws_route53_resolver_endpoint" "zpa_use2" {
  for_each               = local.zpa_dns_use2
  provider               = aws.use2
  name                   = local.zpa_dns_names[each.key]
  direction              = "OUTBOUND"
  resolver_endpoint_type = "IPV4"
  protocols              = ["Do53"]
  security_group_ids     = [aws_security_group.zpa_dns_use2[each.key].id]

  dynamic "ip_address" {
    for_each = toset(["aza", "azb"])
    content {
      subnet_id = aws_subnet.use2["${each.key}-workload-${ip_address.value}"].id
    }
  }
  tags = {
    Function  = "ZSCCAppSegmentResolver"
    Terraform = "true"
  }
  depends_on = [terraform_data.zpa_dns_configuration, aws_route.workload_default_use2]
}

resource "aws_route53_resolver_rule" "zpa_forward_use2" {
  for_each             = local.zpa_dns_forward_use2
  provider             = aws.use2
  name                 = "${substr(local.zpa_dns_names[each.value.vpc_key], 0, 43)}-f-${substr(sha1(each.value.domain), 0, 12)}"
  domain_name          = each.value.domain
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.zpa_use2[each.value.vpc_key].id

  dynamic "target_ip" {
    for_each = var.zpa_dns[each.value.vpc_key].target_ips
    content {
      ip   = target_ip.value
      port = var.zpa_dns[each.value.vpc_key].target_port
    }
  }
  tags = {
    Function  = "ZSCCAppSegmentResolver"
    Terraform = "true"
  }
}

resource "aws_route53_resolver_rule_association" "zpa_forward_use2" {
  for_each         = local.zpa_dns_forward_use2
  provider         = aws.use2
  name             = aws_route53_resolver_rule.zpa_forward_use2[each.key].name
  resolver_rule_id = aws_route53_resolver_rule.zpa_forward_use2[each.key].id
  vpc_id           = aws_vpc.use2[each.value.vpc_key].id
}

resource "aws_route53_resolver_rule" "zpa_system_use2" {
  for_each    = local.zpa_dns_system_use2
  provider    = aws.use2
  name        = "${substr(local.zpa_dns_names[each.value.vpc_key], 0, 43)}-s-${substr(sha1(each.value.domain), 0, 12)}"
  domain_name = each.value.domain
  rule_type   = "SYSTEM"
  tags = {
    Function  = "ZPAResolverSystemException"
    Terraform = "true"
  }
  depends_on = [terraform_data.zpa_dns_configuration]
}

resource "aws_route53_resolver_rule_association" "zpa_system_use2" {
  for_each         = local.zpa_dns_system_use2
  provider         = aws.use2
  name             = aws_route53_resolver_rule.zpa_system_use2[each.key].name
  resolver_rule_id = aws_route53_resolver_rule.zpa_system_use2[each.key].id
  vpc_id           = aws_vpc.use2[each.value.vpc_key].id
}
