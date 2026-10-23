locals {
  region_suffix = var.region_suffix != "" ? var.region_suffix : (var.aws_region == "us-east-1" ? "1" : "2")

  region_cidrs = {
    us-east-1 = {
      prod     = "10.1.0.0/16"
      dev      = "10.2.0.0/16"
      security = "10.99.0.0/16"
    }
    us-east-2 = {
      prod     = "10.3.0.0/16"
      dev      = "10.4.0.0/16"
      security = "10.98.0.0/16"
    }
  }

  vpc_specs = {
    prod = {
      role       = "prod"
      region     = var.aws_region
      short_name = "prod${local.region_suffix}"
      vpc_name   = "${var.naming_prefix}Prod-VPC-${local.region_suffix}"
      cidr       = local.region_cidrs[var.aws_region].prod
    }
    dev = {
      role       = "dev"
      region     = var.aws_region
      short_name = "dev${local.region_suffix}"
      vpc_name   = "${var.naming_prefix}Dev-VPC-${local.region_suffix}"
      cidr       = local.region_cidrs[var.aws_region].dev
    }
    security = {
      role       = "security"
      region     = var.aws_region
      short_name = "sec${local.region_suffix}"
      vpc_name   = "${var.naming_prefix}Security-VPC-${local.region_suffix}"
      cidr       = local.region_cidrs[var.aws_region].security
    }
  }

  subnet_specs = {
    "${var.aws_region}-prod-attach-aza" = {
      vpc_key = "prod"
      az      = "${var.aws_region}a"
      cidr    = var.aws_region == "us-east-1" ? "10.1.0.0/28" : "10.3.0.0/28"
      name    = "${var.naming_prefix}prod${local.region_suffix}-attach-aza"
      purpose = "Cloud WAN Attachment"
    }
    "${var.aws_region}-prod-attach-azb" = {
      vpc_key = "prod"
      az      = "${var.aws_region}b"
      cidr    = var.aws_region == "us-east-1" ? "10.1.0.16/28" : "10.3.0.16/28"
      name    = "${var.naming_prefix}prod${local.region_suffix}-attach-azb"
      purpose = "Cloud WAN Attachment"
    }
    "${var.aws_region}-prod-workload-aza" = {
      vpc_key = "prod"
      az      = "${var.aws_region}a"
      cidr    = var.aws_region == "us-east-1" ? "10.1.1.0/24" : "10.3.1.0/24"
      name    = "${var.naming_prefix}prod${local.region_suffix}-workload-aza"
      purpose = "Application Workloads"
    }
    "${var.aws_region}-prod-workload-azb" = {
      vpc_key = "prod"
      az      = "${var.aws_region}b"
      cidr    = var.aws_region == "us-east-1" ? "10.1.2.0/24" : "10.3.2.0/24"
      name    = "${var.naming_prefix}prod${local.region_suffix}-workload-azb"
      purpose = "Application Workloads"
    }

    "${var.aws_region}-dev-attach-aza" = {
      vpc_key = "dev"
      az      = "${var.aws_region}a"
      cidr    = var.aws_region == "us-east-1" ? "10.2.0.0/28" : "10.4.0.0/28"
      name    = "${var.naming_prefix}dev${local.region_suffix}-attach-aza"
      purpose = "Cloud WAN Attachment"
    }
    "${var.aws_region}-dev-attach-azb" = {
      vpc_key = "dev"
      az      = "${var.aws_region}b"
      cidr    = var.aws_region == "us-east-1" ? "10.2.0.16/28" : "10.4.0.16/28"
      name    = "${var.naming_prefix}dev${local.region_suffix}-attach-azb"
      purpose = "Cloud WAN Attachment"
    }
    "${var.aws_region}-dev-workload-aza" = {
      vpc_key = "dev"
      az      = "${var.aws_region}a"
      cidr    = var.aws_region == "us-east-1" ? "10.2.1.0/24" : "10.4.1.0/24"
      name    = "${var.naming_prefix}dev${local.region_suffix}-workload-aza"
      purpose = "Application Workloads"
    }
    "${var.aws_region}-dev-workload-azb" = {
      vpc_key = "dev"
      az      = "${var.aws_region}b"
      cidr    = var.aws_region == "us-east-1" ? "10.2.2.0/24" : "10.4.2.0/24"
      name    = "${var.naming_prefix}dev${local.region_suffix}-workload-azb"
      purpose = "Application Workloads"
    }

    "${var.aws_region}-sec-attach-aza" = {
      vpc_key = "security"
      az      = "${var.aws_region}a"
      cidr    = var.aws_region == "us-east-1" ? "10.99.0.0/28" : "10.98.0.0/28"
      name    = "${var.naming_prefix}sec${local.region_suffix}-attach-aza"
      purpose = "Cloud WAN Attachment"
    }
    "${var.aws_region}-sec-attach-azb" = {
      vpc_key = "security"
      az      = "${var.aws_region}b"
      cidr    = var.aws_region == "us-east-1" ? "10.99.0.16/28" : "10.98.0.16/28"
      name    = "${var.naming_prefix}sec${local.region_suffix}-attach-azb"
      purpose = "Cloud WAN Attachment"
    }
    "${var.aws_region}-sec-inspection-aza" = {
      vpc_key = "security"
      az      = "${var.aws_region}a"
      cidr    = var.aws_region == "us-east-1" ? "10.99.1.0/24" : "10.98.1.0/24"
      name    = "${var.naming_prefix}sec${local.region_suffix}-inspection-aza"
      purpose = "Inspection / GWLBe"
    }
    "${var.aws_region}-sec-inspection-azb" = {
      vpc_key = "security"
      az      = "${var.aws_region}b"
      cidr    = var.aws_region == "us-east-1" ? "10.99.2.0/24" : "10.98.2.0/24"
      name    = "${var.naming_prefix}sec${local.region_suffix}-inspection-azb"
      purpose = "Inspection / GWLBe"
    }
  }

  workload_sg_map = {
    for vpc_key, vpc in local.vpc_specs : "${vpc_key}-workload" => {
      vpc_key = vpc_key
      name    = "${var.naming_prefix}${vpc.short_name}-workload-sg"
    }
    if vpc.role != "security"
  }

  vpc_endpoint_specs = [
    for vpc_key, vpc in local.vpc_specs : [
      for service_name in ["ssm", "ssmmessages", "ec2messages"] : {
        key           = "${vpc_key}-${service_name}"
        vpc_key       = vpc_key
        region        = vpc.region
        service_name  = service_name
        subnet_keys   = [for az in ["aza", "azb"] : "${var.aws_region}-${vpc_key}-workload-${az}"]
        sg_key        = "${vpc_key}-workload"
        endpoint_name = "${var.naming_prefix}${vpc.short_name}-vpce-${service_name}"
      }
    ]
    if vpc.role != "security"
  ]

  vpc_endpoint_map = {
    for item in flatten(local.vpc_endpoint_specs) : item.key => item
  }
}
