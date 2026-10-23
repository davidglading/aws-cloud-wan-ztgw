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
  description = "Interface endpoints created for SSM, SSMMessages, and EC2Messages."
  value = merge(
    { for key, endpoint in aws_vpc_endpoint.use1 : key => { id = endpoint.id, service_name = endpoint.service_name, dns_entries = endpoint.dns_entry } },
    { for key, endpoint in aws_vpc_endpoint.use2 : key => { id = endpoint.id, service_name = endpoint.service_name, dns_entries = endpoint.dns_entry } }
  )
}
