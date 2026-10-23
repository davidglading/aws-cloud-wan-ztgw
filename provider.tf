provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "use1"
  region = var.aws_region
}

provider "aws" {
  alias  = "use2"
  region = var.multiregion_deployment ? var.secondary_aws_region : var.aws_region
}

# Network Manager's global API endpoint is hosted in us-west-2.
provider "aws" {
  alias  = "networkmanager"
  region = "us-west-2"
}
