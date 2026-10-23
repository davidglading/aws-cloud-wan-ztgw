data "aws_partition" "current" {}

resource "aws_iam_role" "workload_ssm" {
  # IAM names are account-wide. Reserve space for Terraform's unique suffix.
  name_prefix = "${substr(var.naming_prefix, 0, 30)}ec2-ssm-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "workload_ssm" {
  role       = aws_iam_role.workload_ssm.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "workload_ssm" {
  # IAM names are account-wide. Reserve space for Terraform's unique suffix.
  name_prefix = "${substr(var.naming_prefix, 0, 30)}ec2-ssm-"
  role        = aws_iam_role.workload_ssm.name
}
