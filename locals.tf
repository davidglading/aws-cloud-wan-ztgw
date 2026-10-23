locals {
  deployment_regions = var.multiregion_deployment ? ["us-east-1", "us-east-2"] : [var.aws_region]

  region_suffix_map = {
    "us-east-1" = "1"
    "us-east-2" = "2"
  }

  vpc_role_names = {
    prod     = "Prod"
    dev      = "Dev"
    security = "Security"
  }

  region_cidrs = {
    "us-east-1" = {
      prod     = "10.1.0.0/16"
      dev      = "10.2.0.0/16"
      security = "10.99.0.0/16"
    }
    "us-east-2" = {
      prod     = "10.3.0.0/16"
      dev      = "10.4.0.0/16"
      security = "10.98.0.0/16"
    }
  }

  vpc_specs = merge([
    for region in local.deployment_regions : {
      for role in ["prod", "dev", "security"] : "${region}-${role}" => {
        role       = role
        region     = region
        short_name = "${role}${local.region_suffix_map[region]}"
        vpc_name   = "${var.naming_prefix}${local.vpc_role_names[role]}-VPC-${local.region_suffix_map[region]}"
        cidr       = local.region_cidrs[region][role]
      }
    }
  ]...)

  vpc_specs_use1 = { for key, vpc in local.vpc_specs : key => vpc if vpc.region == "us-east-1" }
  vpc_specs_use2 = { for key, vpc in local.vpc_specs : key => vpc if vpc.region == "us-east-2" }

  subnet_specs = merge([
    for region in local.deployment_regions : {
      "${region}-prod-attach-aza" = {
        vpc_key = "${region}-prod"
        az      = "${region}a"
        cidr    = region == "us-east-1" ? "10.1.0.0/28" : "10.3.0.0/28"
        name    = "${var.naming_prefix}prod${local.region_suffix_map[region]}-attach-aza"
        purpose = "Cloud WAN Attachment"
      }
      "${region}-prod-attach-azb" = {
        vpc_key = "${region}-prod"
        az      = "${region}b"
        cidr    = region == "us-east-1" ? "10.1.0.16/28" : "10.3.0.16/28"
        name    = "${var.naming_prefix}prod${local.region_suffix_map[region]}-attach-azb"
        purpose = "Cloud WAN Attachment"
      }
      "${region}-prod-workload-aza" = {
        vpc_key = "${region}-prod"
        az      = "${region}a"
        cidr    = region == "us-east-1" ? "10.1.1.0/24" : "10.3.1.0/24"
        name    = "${var.naming_prefix}prod${local.region_suffix_map[region]}-workload-aza"
        purpose = "Application Workloads"
      }
      "${region}-prod-workload-azb" = {
        vpc_key = "${region}-prod"
        az      = "${region}b"
        cidr    = region == "us-east-1" ? "10.1.2.0/24" : "10.3.2.0/24"
        name    = "${var.naming_prefix}prod${local.region_suffix_map[region]}-workload-azb"
        purpose = "Application Workloads"
      }
      "${region}-dev-attach-aza" = {
        vpc_key = "${region}-dev"
        az      = "${region}a"
        cidr    = region == "us-east-1" ? "10.2.0.0/28" : "10.4.0.0/28"
        name    = "${var.naming_prefix}dev${local.region_suffix_map[region]}-attach-aza"
        purpose = "Cloud WAN Attachment"
      }
      "${region}-dev-attach-azb" = {
        vpc_key = "${region}-dev"
        az      = "${region}b"
        cidr    = region == "us-east-1" ? "10.2.0.16/28" : "10.4.0.16/28"
        name    = "${var.naming_prefix}dev${local.region_suffix_map[region]}-attach-azb"
        purpose = "Cloud WAN Attachment"
      }
      "${region}-dev-workload-aza" = {
        vpc_key = "${region}-dev"
        az      = "${region}a"
        cidr    = region == "us-east-1" ? "10.2.1.0/24" : "10.4.1.0/24"
        name    = "${var.naming_prefix}dev${local.region_suffix_map[region]}-workload-aza"
        purpose = "Application Workloads"
      }
      "${region}-dev-workload-azb" = {
        vpc_key = "${region}-dev"
        az      = "${region}b"
        cidr    = region == "us-east-1" ? "10.2.2.0/24" : "10.4.2.0/24"
        name    = "${var.naming_prefix}dev${local.region_suffix_map[region]}-workload-azb"
        purpose = "Application Workloads"
      }
      "${region}-sec-attach-aza" = {
        vpc_key = "${region}-security"
        az      = "${region}a"
        cidr    = region == "us-east-1" ? "10.99.0.0/28" : "10.98.0.0/28"
        name    = "${var.naming_prefix}sec${local.region_suffix_map[region]}-attach-aza"
        purpose = "Cloud WAN Attachment"
      }
      "${region}-sec-attach-azb" = {
        vpc_key = "${region}-security"
        az      = "${region}b"
        cidr    = region == "us-east-1" ? "10.99.0.16/28" : "10.98.0.16/28"
        name    = "${var.naming_prefix}sec${local.region_suffix_map[region]}-attach-azb"
        purpose = "Cloud WAN Attachment"
      }
      "${region}-sec-inspection-aza" = {
        vpc_key = "${region}-security"
        az      = "${region}a"
        cidr    = region == "us-east-1" ? "10.99.1.0/24" : "10.98.1.0/24"
        name    = "${var.naming_prefix}sec${local.region_suffix_map[region]}-inspection-aza"
        purpose = "Inspection / GWLBe"
      }
      "${region}-sec-inspection-azb" = {
        vpc_key = "${region}-security"
        az      = "${region}b"
        cidr    = region == "us-east-1" ? "10.99.2.0/24" : "10.98.2.0/24"
        name    = "${var.naming_prefix}sec${local.region_suffix_map[region]}-inspection-azb"
        purpose = "Inspection / GWLBe"
      }
    }
  ]...)

  subnet_specs_use1 = { for key, subnet in local.subnet_specs : key => subnet if startswith(key, "us-east-1") }
  subnet_specs_use2 = { for key, subnet in local.subnet_specs : key => subnet if startswith(key, "us-east-2") }

  workload_sg_map = {
    for vpc_key, vpc in local.vpc_specs : "${vpc_key}-workload" => {
      vpc_key = vpc_key
      region  = vpc.region
      name    = "${var.naming_prefix}${vpc.short_name}-workload-sg"
    }
    if vpc.role != "security"
  }

  workload_sg_map_use1 = { for key, sg in local.workload_sg_map : key => sg if startswith(key, "us-east-1-") }
  workload_sg_map_use2 = { for key, sg in local.workload_sg_map : key => sg if startswith(key, "us-east-2-") }

  vpc_endpoint_specs = flatten([
    for vpc_key, vpc in local.vpc_specs : [
      for service_name in ["ssm", "ssmmessages", "ec2messages"] : {
        key           = "${vpc_key}-${service_name}"
        vpc_key       = vpc_key
        region        = vpc.region
        service_name  = service_name
        subnet_keys   = [for az in ["aza", "azb"] : "${vpc.region}-${vpc.role}-workload-${az}"]
        sg_key        = "${vpc_key}-workload"
        endpoint_name = "${var.naming_prefix}${vpc.short_name}-vpce-${service_name}"
      }
    ]
    if vpc.role != "security"
  ])

  vpc_endpoint_map      = { for item in local.vpc_endpoint_specs : item.key => item }
  vpc_endpoint_map_use1 = { for key, item in local.vpc_endpoint_map : key => item if item.region == "us-east-1" }
  vpc_endpoint_map_use2 = { for key, item in local.vpc_endpoint_map : key => item if item.region == "us-east-2" }

  ec2_specs = flatten([
    for vpc_key, vpc in local.vpc_specs : [
      for az in ["aza", "azb"] : {
        key           = "${vpc_key}-${az}-ec2"
        vpc_key       = vpc_key
        region        = vpc.region
        role          = vpc.role
        short_name    = vpc.short_name
        subnet_key    = "${vpc.region}-${vpc.role}-workload-${az}"
        name          = "${var.naming_prefix}${vpc.short_name}-${az}-ec2"
        instance_type = "t3.micro"
      }
    ]
    if vpc.role != "security"
  ])

  ec2_map      = { for item in local.ec2_specs : item.key => item }
  ec2_map_use1 = { for key, item in local.ec2_map : key => item if item.region == "us-east-1" }
  ec2_map_use2 = { for key, item in local.ec2_map : key => item if item.region == "us-east-2" }
}
