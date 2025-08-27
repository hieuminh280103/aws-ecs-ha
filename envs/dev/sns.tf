resource "aws_sns_topic" "alarm_sns" {
  name = "${local.name_prefix}-cloudwatch-alarm-sns"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alarm_sns.arn
  protocol = "email"
  endpoint = "example@gmail.com" 
}

resource "aws_sns_topic_policy" "sns_policy" {
  arn = aws_sns_topic.alarm_sns.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    sid    = "AllowPublishThroughSSLOnly"
    effect = "Deny"
    actions = [
      "SNS:Publish"
    ]
    resources = [
      aws_sns_topic.alarm_sns.arn
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    sid    = "__owner_statement_ID"
    effect = "Allow"
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission"
    ]
    resources = [
      aws_sns_topic.alarm_sns.arn
    ]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}
