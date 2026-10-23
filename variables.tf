variable "aws_region" {
  description = "AWS region where the spoke and security VPCs are deployed. Example: us-east-1"
  type        = string
  default     = "us-east-1"
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
}

variable "region_suffix" {
  description = "Region suffix for the VPC names (1 for us-east-1, 2 for us-east-2). This is auto-derived when possible."
  type        = string
  default     = "1"
}
