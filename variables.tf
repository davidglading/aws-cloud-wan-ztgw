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
