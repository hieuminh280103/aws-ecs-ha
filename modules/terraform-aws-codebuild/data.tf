data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_role" "codebuild" {
  name = var.create_codebuild_role ? aws_iam_role.codebuild[0].name : var.codebuild_role_name
}

# codebuild policy create ec2 network interface and write bucket
data "aws_iam_policy_document" "codebuild_vpc_policy" {
  count = var.create_codebuild_role && var.in_vpc ? 1 : 0

  statement {
    sid = "1"
    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeVpcs",
      "ec2:CreateNetworkInterface"
    ]
    resources = ["*"]
  }
  statement {
    sid = "2"
    actions = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"
      values = [
        for p_sub_id in var.private_subnet_ids: 
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:subnet/${p_sub_id}"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values = ["codebuild.amazonaws.com"]
    }
  }
}