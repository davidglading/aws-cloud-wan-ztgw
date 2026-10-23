output "vpcs" {
  description = "VPC IDs for the prod, dev, and security VPCs in the selected region(s)."
  value = merge(
    { for key, vpc in aws_vpc.use1 : key => { id = vpc.id, name = vpc.tags["Name"], cidr = vpc.cidr_block } },
    { for key, vpc in aws_vpc.use2 : key => { id = vpc.id, name = vpc.tags["Name"], cidr = vpc.cidr_block } }
  )
}

output "subnets" {
  description = "Subnet IDs for Cloud WAN attachment, workload, and inspection subnets."
  value = merge(
    { for key, subnet in aws_subnet.use1 : key => { id = subnet.id, az = subnet.availability_zone, cidr = subnet.cidr_block } },
    { for key, subnet in aws_subnet.use2 : key => { id = subnet.id, az = subnet.availability_zone, cidr = subnet.cidr_block } }
  )
}

output "workload_security_groups" {
  description = "Security groups associated with the workload subnets."
  value = merge(
    { for key, sg in aws_security_group.use1 : key => { id = sg.id, name = sg.name } },
    { for key, sg in aws_security_group.use2 : key => { id = sg.id, name = sg.name } }
  )
}

output "vpc_endpoints" {
  description = "Interface endpoints created for the configured SSM services."
  value = merge(
    { for key, endpoint in aws_vpc_endpoint.use1 : key => { id = endpoint.id, service_name = endpoint.service_name, dns_entries = endpoint.dns_entry } },
    { for key, endpoint in aws_vpc_endpoint.use2 : key => { id = endpoint.id, service_name = endpoint.service_name, dns_entries = endpoint.dns_entry } }
  )
}

output "ec2_instances" {
  description = "EC2 workload instances created in the prod and dev workload subnets."
  value = merge(
    { for key, instance in aws_instance.use1 : key => { id = instance.id, name = instance.tags["Name"], subnet = instance.subnet_id, az = instance.availability_zone } },
    { for key, instance in aws_instance.use2 : key => { id = instance.id, name = instance.tags["Name"], subnet = instance.subnet_id, az = instance.availability_zone } }
  )
}

output "cloud_wan" {
  description = "Global/core network identifiers and the configured segments/NFG."
  value = {
    global_network_id      = aws_networkmanager_global_network.this.id
    core_network_id        = aws_networkmanager_core_network.this.id
    core_network_arn       = aws_networkmanager_core_network.this.arn
    segments               = ["Prod", "NonProd"]
    network_function_group = "SecurityNFG"
  }
}

output "core_network_policy_json" {
  description = "Effective guide policy JSON with the configured regional edges."
  value       = jsonencode(local.core_network_policy)
}

output "cloud_wan_attachments" {
  description = "VPC attachment IDs keyed by region and role. Security attachments use appliance mode."
  value = merge(
    { for key, attachment in aws_networkmanager_vpc_attachment.use1 : key => attachment.id },
    { for key, attachment in aws_networkmanager_vpc_attachment.use2 : key => attachment.id }
  )
}

output "ztgw_gwlb_endpoints" {
  description = "Per-AZ Zscaler GWLB endpoint IDs."
  value = merge(
    { for key, endpoint in aws_vpc_endpoint.ztgw_use1 : key => endpoint.id },
    { for key, endpoint in aws_vpc_endpoint.ztgw_use2 : key => endpoint.id }
  )
}

output "inspection_pending_regions" {
  description = "Regions missing a Zscaler endpoint service name. Transit and Internet egress will not work there until inspection is configured and healthy."
  value       = [for region in local.deployment_regions : region if !contains(keys(var.ztgw_endpoint_service_names), region)]
}
