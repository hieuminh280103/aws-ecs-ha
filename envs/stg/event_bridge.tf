resource "aws_cloudwatch_event_rule" "guardduty_finding_rule" {
  name        = "${local.name_prefix}-guardduty-finding-rule"
  description = "Capture each GuardDuty Finding"

  event_pattern = <<EOF
{
        "source": ["aws.guardduty"],
        "detail-type": ["GuardDuty Finding"]
}
EOF
  tags = local.tags
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_finding_rule.name
  target_id = "SendToGuardDutySNS"
  arn       = aws_sns_topic.guarduty_sns.arn
}


