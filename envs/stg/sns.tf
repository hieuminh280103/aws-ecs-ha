resource "aws_sns_topic" "alarm_sns" {
  name = "${local.name_prefix}-cloudwatch-alarm-sns"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic" "guarduty_sns" {
  name = "${local.name_prefix}-guardduty-sns"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.guarduty_sns.arn
  protocol = "email"
  endpoint = var.email_sub
}

# Create SNS topic policy to allow Eventbridge to publish to the SNS topic
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.guarduty_sns.arn
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "events.amazonaws.com"
        },
        "Action": "sns:Publish",
        "Resource": [
          "${aws_sns_topic.guarduty_sns.arn}",
        ],
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": "${aws_cloudwatch_event_rule.guardduty_finding_rule.arn}"
          }
        }
      }
    ]
  })
}
