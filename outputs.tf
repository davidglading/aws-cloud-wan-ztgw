output "vpcs" {
  description = "VPC IDs for the prod, dev, and security VPCs in this region."
  value = {
    for key, vpc in aws_vpc.this : key => {
      id   = vpc.id
      name = vpc.tags["Name"]
      cidr = vpc.cidr_block
    }
  }
}

output "subnets" {
  description = "Subnet IDs for Cloud WAN attachment, workload, and inspection subnets."
  value = {
    for key, subnet in aws_subnet.this : key => {
      id   = subnet.id
      az   = subnet.availability_zone
      cidr = subnet.cidr_block
    }
  }
}

output "workload_security_groups" {
  description = "Security groups associated with the workload subnets."
  value = {
    for key, sg in aws_security_group.workload : key => {
      id   = sg.id
      name = sg.name
    }
  }
}

output "vpc_endpoints" {
  description = "Interface endpoints created for SSM, SSMMessages, and EC2Messages."
  value = {
    for key, endpoint in aws_vpc_endpoint.interface : key => {
      id           = endpoint.id
      service_name = endpoint.service_name
      dns_entries  = endpoint.dns_entry
    }
  }
}
