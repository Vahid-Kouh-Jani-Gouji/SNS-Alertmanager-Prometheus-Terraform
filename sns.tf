resource "aws_sns_topic" "alarms_topic" {
  name = "alarms-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarms_topic.arn
  protocol  = "email"
  endpoint  = "vahid.jani@docc.techstarter.de"
}