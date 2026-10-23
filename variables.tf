variable "aws_region" {
  description = "Primary AWS region for the deployment. Example: us-east-1"
  type        = string
  default     = "us-east-1"
}

variable "multiregion_deployment" {
  description = "When true, deploys the guide's two-region pattern (us-east-1 and us-east-2) instead of a single region."
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
}

variable "region_suffix" {
  description = "Optional region suffix override for VPC naming. When left empty, it is automatically derived from the regional mapping."
  type        = string
  default     = ""
}
