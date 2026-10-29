variable "aws_region" {
  description = "Primary AWS region for the deployment."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}(-[a-z]+)+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be an AWS region name, such as us-west-2 or eu-west-1."
  }
}

variable "multiregion_deployment" {
  description = "When true, deploys in aws_region and secondary_aws_region."
  type        = bool
  default     = false
}

variable "naming_prefix" {
  description = "Naming prefix used throughout the AWS resources, as shown in the guide (for example dglading-cloud-wan-)."
  type        = string
  default     = "dglading-cloud-wan-"
}

variable "vpc_endpoint_service_name" {
  description = "Base AWS service-name prefix used for interface endpoints. Example: com.amazonaws"
  type        = string
  default     = "com.amazonaws"

  validation {
    condition     = !can(regex("vpce-svc-", var.vpc_endpoint_service_name))
    error_message = "vpc_endpoint_service_name is the SSM service prefix (normally com.amazonaws). Put full Zscaler GWLB service names in ztgw_endpoint_service_names instead."
  }
}

variable "region_suffix" {
  description = "Optional primary region naming suffix. Defaults to 1 for us-east-1, 2 for us-east-2, or the region name elsewhere."
  type        = string
  default     = ""
}

variable "secondary_aws_region" {
  description = "Second AWS region, used only when multiregion_deployment is true. Must differ from aws_region."
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^[a-z]{2}(-[a-z]+)+-[0-9]+$", var.secondary_aws_region))
    error_message = "secondary_aws_region must be an AWS region name, such as eu-west-1."
  }
}

variable "secondary_region_suffix" {
  description = "Optional secondary region naming suffix. Defaults to its region name, except 1 and 2 for us-east-1 and us-east-2."
  type        = string
  default     = ""
}

variable "ssm_endpoint_services" {
  description = "SSM interface endpoint services. Add ec2messages only in regions that support that legacy service."
  type        = set(string)
  default     = ["ssm", "ssmmessages"]

  validation {
    condition     = contains(var.ssm_endpoint_services, "ssm") && contains(var.ssm_endpoint_services, "ssmmessages") && alltrue([for service in var.ssm_endpoint_services : contains(["ssm", "ssmmessages", "ec2messages"], service)])
    error_message = "Include ssm and ssmmessages; ec2messages is the only optional service."
  }
}

variable "ztgw_endpoint_service_names" {
  description = "Zscaler GWLB endpoint service names keyed by deployment region. Omit a region to create Cloud WAN first; its inspection endpoints and attachment default routes remain pending."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for region, name in var.ztgw_endpoint_service_names :
      can(regex("^[a-z]{2}(-[a-z]+)+-[0-9]+$", region)) &&
      can(regex("^com\\.amazonaws(\\.cn)?\\.vpce\\.${region}\\.vpce-svc-[0-9a-f]+$", name))
    ])
    error_message = "Each entry must map an AWS region to its matching Zscaler GWLB service name: com.amazonaws.vpce.<region>.vpce-svc-<id>."
  }
}

variable "zpa_dns" {
  description = "Optional Route 53 Resolver configuration keyed by managed workload VPC key (<region>-prod or <region>-dev). An empty map creates no DNS resources. VPC IDs and two workload subnet IDs are derived from the selected VPC."
  type = map(object({
    application_domain_names  = set(string)
    target_ips                = optional(set(string), ["185.46.212.88", "185.46.212.89"])
    target_port               = optional(number, 53)
    zscaler_cloud_name        = optional(string, "zscaler.net")
    zpa_cloud_name            = optional(string, "ZPA")
    additional_system_domains = optional(set(string), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for key in keys(var.zpa_dns) : can(regex("^[a-z]{2}(-[a-z]+)+-[0-9]+-(prod|dev)$", key))
    ])
    error_message = "Each zpa_dns key must identify a managed workload VPC: <region>-prod or <region>-dev."
  }

  validation {
    condition = alltrue([
      for config in values(var.zpa_dns) :
      length(config.application_domain_names) > 0 && length(join(",", config.application_domain_names)) <= 4096 &&
      alltrue([for domain in config.application_domain_names :
        trimspace(domain) == "." || (
          length(trimspace(domain)) <= 254 &&
          can(regex("^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?(\\.[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*\\.?$", trimspace(domain)))
        )
      ])
    ])
    error_message = "Supply one or more application DNS suffixes (up to 4096 characters total). Use example.internal rather than *.example.internal, or . to forward all domains except SYSTEM exceptions."
  }

  validation {
    condition = alltrue([
      for config in values(var.zpa_dns) :
      length(config.target_ips) >= 1 && length(config.target_ips) <= 6 &&
      alltrue([for ip in config.target_ips : can(cidrnetmask("${ip}/32"))]) &&
      config.target_port >= 1 && config.target_port <= 65535 && floor(config.target_port) == config.target_port
    ])
    error_message = "Provide 1–6 IPv4 DNS target addresses and an integer target_port from 1 to 65535."
  }

  validation {
    condition = alltrue([
      for config in values(var.zpa_dns) : contains(["ZPA", "ZPA-Beta"], config.zpa_cloud_name)
    ])
    error_message = "zpa_cloud_name must be ZPA (prod.zpath.net) or ZPA-Beta (zpabeta.net)."
  }

  validation {
    condition = alltrue(flatten([
      for config in values(var.zpa_dns) : [
        for domain in setunion(config.additional_system_domains, config.zscaler_cloud_name == "" ? toset([]) : toset([config.zscaler_cloud_name])) :
        length(trimspace(domain)) <= 254 &&
        can(regex("^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?(\\.[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*\\.?$", trimspace(domain)))
      ]
    ]))
    error_message = "zscaler_cloud_name and additional_system_domains must be DNS domain names without wildcards. An empty zscaler_cloud_name omits that one exception."
  }
}
