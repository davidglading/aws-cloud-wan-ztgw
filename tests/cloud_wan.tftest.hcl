mock_provider "aws" {
  mock_data "aws_partition" { defaults = { partition = "aws" } }
  mock_data "aws_availability_zones" { defaults = { names = ["us-east-1a", "us-east-1b"] } }
  mock_data "aws_ami" { defaults = { id = "ami-0123456789abcdef0" } }
  mock_resource "aws_vpc" { defaults = { id = "vpc-0123456789abcdef0", arn = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-0123456789abcdef0" } }
  mock_resource "aws_subnet" { defaults = { id = "subnet-0123456789abcdef0", arn = "arn:aws:ec2:us-east-1:123456789012:subnet/subnet-0123456789abcdef0" } }
  mock_resource "aws_route_table" { defaults = { id = "rtb-0123456789abcdef0" } }
  mock_resource "aws_security_group" { defaults = { id = "sg-0123456789abcdef0" } }
  mock_resource "aws_vpc_endpoint" { defaults = { id = "vpce-0123456789abcdef0" } }
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
  mock_resource "aws_networkmanager_global_network" { defaults = { id = "global-network-0123456789abcdef0" } }
  mock_resource "aws_networkmanager_core_network" { defaults = { id = "core-network-0123456789abcdef0", arn = "arn:aws:networkmanager::123456789012:core-network/core-network-0123456789abcdef0" } }
}

# All providers are mocked: apply below never calls AWS.
run "single_region_core_without_endpoint_service" {
  command = apply
  assert {
    condition     = length(aws_networkmanager_vpc_attachment.use1) == 3 && length(aws_networkmanager_vpc_attachment.use2) == 0
    error_message = "A single region needs exactly three VPC attachments."
  }
  assert {
    condition     = aws_networkmanager_vpc_attachment.use1["us-east-1-security"].options[0].appliance_mode_support && !aws_networkmanager_vpc_attachment.use1["us-east-1-prod"].options[0].appliance_mode_support
    error_message = "Only the Security VPC attachment should enable appliance mode."
  }
  assert {
    condition     = aws_networkmanager_vpc_attachment.use1["us-east-1-dev"].tags.segment == "NonProd" && aws_networkmanager_vpc_attachment.use1["us-east-1-security"].tags.segment == "Security"
    error_message = "Attachment tags must match the policy's segment/NFG rules."
  }
  assert {
    condition     = length(aws_route.workload_default_use1) == 2 && length(aws_route_table_association.workload_use1) == 4 && length(aws_route_table_association.security_attachment_use1) == 2 && length(aws_route_table_association.inspection_use1) == 2
    error_message = "Spoke workload, Security attachment, and inspection subnets need separate route tables."
  }
  assert {
    condition     = length(aws_vpc_endpoint.ztgw_use1) == 0 && length(aws_route.security_to_ztgw_use1) == 0 && output.inspection_pending_regions == ["us-east-1"]
    error_message = "Missing service names must leave inspection explicitly pending without fabricating endpoints."
  }
  assert {
    condition     = jsondecode(output.core_network_policy_json)["network-function-groups"][0].name == "SecurityNFG" && alltrue([for segment in jsondecode(output.core_network_policy_json).segments : segment["isolate-attachments"]])
    error_message = "The guide requires SecurityNFG and attachment isolation in both segments."
  }
}

run "two_regions_with_inspection" {
  command = apply
  variables {
    multiregion_deployment = true
    ztgw_endpoint_service_names = {
      "us-east-1" = "com.amazonaws.vpce.us-east-1.vpce-svc-0123456789abcdef0"
      "us-east-2" = "com.amazonaws.vpce.us-east-2.vpce-svc-0123456789abcdef1"
    }
  }
  override_data {
    target = data.aws_availability_zones.secondary[0]
    values = { names = ["us-east-2a", "us-east-2b"] }
  }
  assert {
    condition     = length(output.cloud_wan_attachments) == 6 && length(output.ztgw_gwlb_endpoints) == 4 && length(output.inspection_pending_regions) == 0
    error_message = "Two regions need six attachments and four per-AZ inspection endpoints."
  }
  assert {
    condition     = alltrue([for endpoint in aws_vpc_endpoint.ztgw_use1 : endpoint.vpc_endpoint_type == "GatewayLoadBalancer" && length(endpoint.subnet_ids) == 1]) && alltrue([for endpoint in aws_vpc_endpoint.ztgw_use2 : endpoint.vpc_endpoint_type == "GatewayLoadBalancer" && length(endpoint.subnet_ids) == 1])
    error_message = "Each GWLB endpoint must belong to a single AZ subnet."
  }
  assert {
    condition     = length(aws_route.security_to_ztgw_use1) == 2 && length(aws_route.security_to_ztgw_use2) == 2 && aws_route.inspection_return_use2["us-east-2-security"].destination_cidr_block == "10.0.0.0/8"
    error_message = "Inspection requires AZ-specific forward routes and private return routes to Cloud WAN."
  }
  assert {
    condition     = jsondecode(output.core_network_policy_json) == jsondecode(file("${path.module}/policies/core-network-policy.json"))
    error_message = "The default two-region policy must exactly match the PDF's JSON."
  }
  assert {
    condition     = aws_security_group.use1["us-east-1-prod-workload"].ingress != null && aws_instance.use1["us-east-1-prod-aza-ec2"].iam_instance_profile == aws_iam_instance_profile.workload_ssm.name
    error_message = "Workloads must have the SSM instance profile."
  }
}

run "custom_region_pair" {
  command = apply
  variables {
    aws_region             = "us-west-2"
    multiregion_deployment = true
    secondary_aws_region   = "eu-west-1"
    ztgw_endpoint_service_names = {
      "us-west-2" = "com.amazonaws.vpce.us-west-2.vpce-svc-0123456789abcdef0"
      "eu-west-1" = "com.amazonaws.vpce.eu-west-1.vpce-svc-0123456789abcdef1"
    }
  }
  override_data {
    target = data.aws_availability_zones.primary
    values = { names = ["us-west-2b", "us-west-2d"] }
  }
  override_data {
    target = data.aws_availability_zones.secondary[0]
    values = { names = ["eu-west-1a", "eu-west-1c"] }
  }
  assert {
    condition     = [for edge in jsondecode(output.core_network_policy_json)["core-network-configuration"]["edge-locations"] : edge.location] == ["us-west-2", "eu-west-1"]
    error_message = "Core network edges must follow the region variables."
  }
  assert {
    condition     = aws_subnet.use1["us-west-2-sec-attach-azb"].availability_zone == "us-west-2d" && aws_subnet.use2["eu-west-1-sec-inspection-azb"].availability_zone == "eu-west-1c"
    error_message = "Routing must use discovered zones, not assumed region suffixes."
  }
  assert {
    condition     = length(output.cloud_wan_attachments) == 6 && length(output.ztgw_gwlb_endpoints) == 4
    error_message = "Custom regions must receive the complete Cloud WAN attachment and endpoint topology."
  }
}

run "reject_mismatched_service_region" {
  command = plan
  variables {
    ztgw_endpoint_service_names = { "us-west-2" = "com.amazonaws.vpce.eu-west-1.vpce-svc-0123456789abcdef0" }
  }
  expect_failures = [var.ztgw_endpoint_service_names]
}

run "reject_duplicate_regions" {
  command = plan
  variables {
    multiregion_deployment = true
    secondary_aws_region   = "us-east-1"
  }
  expect_failures = [data.aws_availability_zones.secondary]
}

run "reject_insufficient_zones" {
  command = plan
  override_data {
    target = data.aws_availability_zones.primary
    values = { names = ["us-east-1a"] }
  }
  expect_failures = [data.aws_availability_zones.primary]
}

run "reject_gwlb_service_in_ssm_prefix" {
  command = plan
  variables {
    vpc_endpoint_service_name = "com.amazonaws.vpce.us-west-1.vpce-svc-0123456789abcdef0"
  }
  expect_failures = [var.vpc_endpoint_service_name]
}
