mock_provider "aws" {
  mock_data "aws_partition" { defaults = { partition = "aws" } }
  mock_data "aws_availability_zones" { defaults = { names = ["us-east-1a", "us-east-1b"] } }
  mock_data "aws_ami" { defaults = { id = "ami-0123456789abcdef0" } }
  mock_resource "aws_vpc" { defaults = { id = "vpc-0123456789abcdef0", arn = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-0123456789abcdef0" } }
  mock_resource "aws_subnet" { defaults = { id = "subnet-0123456789abcdef0", arn = "arn:aws:ec2:us-east-1:123456789012:subnet/subnet-0123456789abcdef0" } }
  mock_resource "aws_route_table" { defaults = { id = "rtb-0123456789abcdef0" } }
  mock_resource "aws_security_group" { defaults = { id = "sg-0123456789abcdef0" } }
  mock_resource "aws_vpc_endpoint" { defaults = { id = "vpce-0123456789abcdef0" } }
  mock_resource "aws_route53_resolver_endpoint" { defaults = { id = "rslvr-out-0123456789abcdef0" } }
  mock_resource "aws_route53_resolver_rule" { defaults = { id = "rslvr-rr-0123456789abcdef0" } }
  mock_resource "aws_networkmanager_global_network" { defaults = { id = "global-network-0123456789abcdef0" } }
  mock_resource "aws_networkmanager_core_network" { defaults = { id = "core-network-0123456789abcdef0", arn = "arn:aws:networkmanager::123456789012:core-network/core-network-0123456789abcdef0" } }
}
mock_provider "aws" {
  alias = "use1"
  mock_data "aws_partition" { defaults = { partition = "aws" } }
  mock_data "aws_availability_zones" { defaults = { names = ["us-east-1a", "us-east-1b"] } }
  mock_data "aws_ami" { defaults = { id = "ami-0123456789abcdef0" } }
  mock_resource "aws_vpc" { defaults = { id = "vpc-0123456789abcdef0", arn = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-0123456789abcdef0" } }
  mock_resource "aws_subnet" { defaults = { id = "subnet-0123456789abcdef0", arn = "arn:aws:ec2:us-east-1:123456789012:subnet/subnet-0123456789abcdef0" } }
  mock_resource "aws_route_table" { defaults = { id = "rtb-0123456789abcdef0" } }
  mock_resource "aws_security_group" { defaults = { id = "sg-0123456789abcdef0" } }
  mock_resource "aws_vpc_endpoint" { defaults = { id = "vpce-0123456789abcdef0" } }
  mock_resource "aws_route53_resolver_endpoint" { defaults = { id = "rslvr-out-0123456789abcdef0" } }
  mock_resource "aws_route53_resolver_rule" { defaults = { id = "rslvr-rr-0123456789abcdef0" } }
  mock_resource "aws_networkmanager_global_network" { defaults = { id = "global-network-0123456789abcdef0" } }
  mock_resource "aws_networkmanager_core_network" { defaults = { id = "core-network-0123456789abcdef0", arn = "arn:aws:networkmanager::123456789012:core-network/core-network-0123456789abcdef0" } }
}
mock_provider "aws" {
  alias = "use2"
  mock_data "aws_partition" { defaults = { partition = "aws" } }
  mock_data "aws_availability_zones" { defaults = { names = ["us-east-1a", "us-east-1b"] } }
  mock_data "aws_ami" { defaults = { id = "ami-0123456789abcdef0" } }
  mock_resource "aws_vpc" { defaults = { id = "vpc-0123456789abcdef0", arn = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-0123456789abcdef0" } }
  mock_resource "aws_subnet" { defaults = { id = "subnet-0123456789abcdef0", arn = "arn:aws:ec2:us-east-1:123456789012:subnet/subnet-0123456789abcdef0" } }
  mock_resource "aws_route_table" { defaults = { id = "rtb-0123456789abcdef0" } }
  mock_resource "aws_security_group" { defaults = { id = "sg-0123456789abcdef0" } }
  mock_resource "aws_vpc_endpoint" { defaults = { id = "vpce-0123456789abcdef0" } }
  mock_resource "aws_route53_resolver_endpoint" { defaults = { id = "rslvr-out-0123456789abcdef0" } }
  mock_resource "aws_route53_resolver_rule" { defaults = { id = "rslvr-rr-0123456789abcdef0" } }
  mock_resource "aws_networkmanager_global_network" { defaults = { id = "global-network-0123456789abcdef0" } }
  mock_resource "aws_networkmanager_core_network" { defaults = { id = "core-network-0123456789abcdef0", arn = "arn:aws:networkmanager::123456789012:core-network/core-network-0123456789abcdef0" } }
}
mock_provider "aws" {
  alias = "networkmanager"
  mock_data "aws_partition" { defaults = { partition = "aws" } }
  mock_data "aws_availability_zones" { defaults = { names = ["us-east-1a", "us-east-1b"] } }
  mock_data "aws_ami" { defaults = { id = "ami-0123456789abcdef0" } }
  mock_resource "aws_vpc" { defaults = { id = "vpc-0123456789abcdef0", arn = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-0123456789abcdef0" } }
  mock_resource "aws_subnet" { defaults = { id = "subnet-0123456789abcdef0", arn = "arn:aws:ec2:us-east-1:123456789012:subnet/subnet-0123456789abcdef0" } }
  mock_resource "aws_route_table" { defaults = { id = "rtb-0123456789abcdef0" } }
  mock_resource "aws_security_group" { defaults = { id = "sg-0123456789abcdef0" } }
  mock_resource "aws_vpc_endpoint" { defaults = { id = "vpce-0123456789abcdef0" } }
  mock_resource "aws_route53_resolver_endpoint" { defaults = { id = "rslvr-out-0123456789abcdef0" } }
  mock_resource "aws_route53_resolver_rule" { defaults = { id = "rslvr-rr-0123456789abcdef0" } }
  mock_resource "aws_networkmanager_global_network" { defaults = { id = "global-network-0123456789abcdef0" } }
  mock_resource "aws_networkmanager_core_network" { defaults = { id = "core-network-0123456789abcdef0", arn = "arn:aws:networkmanager::123456789012:core-network/core-network-0123456789abcdef0" } }
}


run "dns_disabled_by_default" {
  command = plan
  assert {
    condition     = length(aws_route53_resolver_endpoint.zpa_use1) == 0 && length(aws_route53_resolver_endpoint.zpa_use2) == 0 && length(aws_route53_resolver_rule.zpa_forward_use1) == 0 && length(aws_route53_resolver_rule.zpa_system_use1) == 0
    error_message = "Existing deployments must not gain DNS resources unless configured."
  }
}

run "primary_vpc_application_forwarding" {
  command = apply
  variables {
    zpa_dns = {
      "us-east-1-prod" = {
        application_domain_names = ["Apps.Example.Internal.", "apps.example.internal", "private.example.com"]
      }
    }
  }
  override_resource {
    target = aws_subnet.use1["us-east-1-prod-workload-aza"]
    values = { id = "subnet-00000000000000000" }
  }
  override_resource {
    target = aws_subnet.use1["us-east-1-prod-workload-azb"]
    values = { id = "subnet-00000000000000001" }
  }
  assert {
    condition     = length(output.zpa_dns_resolvers) == 1 && aws_route53_resolver_endpoint.zpa_use1["us-east-1-prod"].direction == "OUTBOUND" && length(aws_route53_resolver_endpoint.zpa_use1["us-east-1-prod"].ip_address) == 2
    error_message = "A configured VPC needs one outbound endpoint with two subnet addresses."
  }
  assert {
    condition     = toset([for address in aws_route53_resolver_endpoint.zpa_use1["us-east-1-prod"].ip_address : address.subnet_id]) == toset([aws_subnet.use1["us-east-1-prod-workload-aza"].id, aws_subnet.use1["us-east-1-prod-workload-azb"].id])
    error_message = "Resolver ENIs must use the selected VPC's workload subnets, not attachment subnets."
  }
  assert {
    condition     = length(aws_route53_resolver_rule.zpa_forward_use1) == 2 && aws_route53_resolver_rule.zpa_forward_use1["us-east-1-prod:apps.example.internal"].rule_type == "FORWARD" && length(aws_route53_resolver_rule_association.zpa_forward_use1) == 2
    error_message = "Normalize/deduplicate domains and associate each forwarding rule with its VPC."
  }
  assert {
    condition     = toset([for target in aws_route53_resolver_rule.zpa_forward_use1["us-east-1-prod:apps.example.internal"].target_ip : target.ip]) == toset(["185.46.212.88", "185.46.212.89"]) && alltrue([for target in aws_route53_resolver_rule.zpa_forward_use1["us-east-1-prod:apps.example.internal"].target_ip : target.port == 53])
    error_message = "Default DNS targets and ports must match the reference template."
  }
  assert {
    condition     = toset(keys(output.zpa_dns_resolvers["us-east-1-prod"].system_rule_ids)) == toset(["zscaler.net", "prod.zpath.net", "zscaler.com", "freebsd.org", "ntp.org", "amazonaws.com"]) && alltrue([for rule in aws_route53_resolver_rule.zpa_system_use1 : rule.rule_type == "SYSTEM"]) && length(aws_route53_resolver_rule_association.zpa_system_use1) == 6
    error_message = "All six template SYSTEM exceptions must remain AWS-resolved and associated."
  }
  assert {
    condition     = length(aws_security_group.zpa_dns_use1["us-east-1-prod"].ingress) == 0 && toset([for rule in aws_security_group.zpa_dns_use1["us-east-1-prod"].egress : rule.protocol]) == toset(["tcp", "udp"]) && alltrue([for rule in aws_security_group.zpa_dns_use1["us-east-1-prod"].egress : rule.from_port == 53 && rule.to_port == 53 && toset(rule.cidr_blocks) == toset(["185.46.212.88/32", "185.46.212.89/32"])])
    error_message = "Endpoint security groups must allow only TCP/UDP DNS to configured target IPs."
  }
}

run "root_forwarding_and_beta_exceptions" {
  command = apply
  variables {
    zpa_dns = {
      "us-east-1-prod" = {
        application_domain_names  = ["."]
        target_ips                = ["10.200.0.53"]
        target_port               = 5353
        zscaler_cloud_name        = "zscalertwo.net"
        zpa_cloud_name            = "ZPA-Beta"
        additional_system_domains = ["amazonaws.com", "control.example.net"]
      }
    }
  }
  override_resource {
    target = aws_subnet.use1["us-east-1-prod-workload-aza"]
    values = { id = "subnet-00000000000000000" }
  }
  override_resource {
    target = aws_subnet.use1["us-east-1-prod-workload-azb"]
    values = { id = "subnet-00000000000000001" }
  }
  assert {
    condition     = aws_route53_resolver_rule.zpa_forward_use1["us-east-1-prod:."].domain_name == "." && alltrue([for target in aws_route53_resolver_rule.zpa_forward_use1["us-east-1-prod:."].target_ip : target.ip == "10.200.0.53" && target.port == 5353])
    error_message = "Root forwarding must use configurable DNS servers and port."
  }
  assert {
    condition     = contains(keys(output.zpa_dns_resolvers["us-east-1-prod"].system_rule_ids), "zpabeta.net") && contains(keys(output.zpa_dns_resolvers["us-east-1-prod"].system_rule_ids), "zscalertwo.net") && contains(keys(output.zpa_dns_resolvers["us-east-1-prod"].system_rule_ids), "control.example.net") && !contains(keys(output.zpa_dns_resolvers["us-east-1-prod"].system_rule_ids), "prod.zpath.net")
    error_message = "Cloud parameters must select the correct SYSTEM exceptions."
  }
}

run "custom_regions_and_independent_vpcs" {
  command = apply
  variables {
    aws_region             = "us-west-1"
    multiregion_deployment = true
    secondary_aws_region   = "eu-west-1"
    zpa_dns = {
      "us-west-1-dev" = {
        application_domain_names = ["west.example.internal"]
        target_ips               = ["192.0.2.53"]
      }
      "eu-west-1-prod" = {
        application_domain_names = ["europe.example.internal"]
        target_ips               = ["192.0.2.54"]
        zscaler_cloud_name       = ""
      }
    }
  }
  override_data {
    target = data.aws_availability_zones.primary
    values = { names = ["us-west-1a", "us-west-1c"] }
  }
  override_data {
    target = data.aws_availability_zones.secondary[0]
    values = { names = ["eu-west-1a", "eu-west-1b"] }
  }
  override_resource {
    target = aws_subnet.use1["us-west-1-dev-workload-aza"]
    values = { id = "subnet-00000000000000000" }
  }
  override_resource {
    target = aws_subnet.use1["us-west-1-dev-workload-azb"]
    values = { id = "subnet-00000000000000001" }
  }
  override_resource {
    target = aws_subnet.use2["eu-west-1-prod-workload-aza"]
    values = { id = "subnet-00000000000000002" }
  }
  override_resource {
    target = aws_subnet.use2["eu-west-1-prod-workload-azb"]
    values = { id = "subnet-00000000000000003" }
  }
  assert {
    condition     = length(aws_route53_resolver_endpoint.zpa_use1) == 1 && length(aws_route53_resolver_endpoint.zpa_use2) == 1 && length(output.zpa_dns_resolvers) == 2
    error_message = "Both configured regions must receive their own resolver endpoint."
  }
  assert {
    condition     = aws_route53_resolver_rule.zpa_forward_use2["eu-west-1-prod:europe.example.internal"].resolver_endpoint_id == aws_route53_resolver_endpoint.zpa_use2["eu-west-1-prod"].id && length(aws_route53_resolver_rule.zpa_system_use2) == 5
    error_message = "Rules must select their regional endpoint and support an omitted cloud-domain exception."
  }
}

run "reject_unknown_vpc" {
  command = plan
  variables {
    zpa_dns = { "eu-west-1-prod" = { application_domain_names = ["apps.example.internal"] } }
  }
  expect_failures = [terraform_data.zpa_dns_configuration]
}
run "reject_invalid_targets" {
  command = plan
  variables {
    zpa_dns = { "us-east-1-prod" = { application_domain_names = ["apps.example.internal"], target_ips = ["999.1.2.3"] } }
  }
  expect_failures = [var.zpa_dns]
}
run "reject_wildcard_domain" {
  command = plan
  variables {
    zpa_dns = { "us-east-1-prod" = { application_domain_names = ["*.example.internal"] } }
  }
  expect_failures = [var.zpa_dns]
}
run "reject_system_forward_collision" {
  command = plan
  variables {
    zpa_dns = { "us-east-1-prod" = { application_domain_names = ["zscaler.net"] } }
  }
  expect_failures = [terraform_data.zpa_dns_configuration]
}
