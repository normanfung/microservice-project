# EventBridge Rule
resource "aws_cloudwatch_event_rule" "order_placed_rule" {
  name           = "ce-grp-2-order-placed"
  description    = "Listen to customer orders."
  event_bus_name = "default"
  event_pattern = jsonencode({
    "source" : ["checkoutservice"],
    "detail-type" : ["OrderPlaced"]
  })
  state = "ENABLED"
}

# IAM Role for EventBridge
resource "aws_iam_role" "eventbridge_target_role" {
  name = "ce-grp-2-eventbridge-order-target-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "aws:SourceArn"     = "arn:aws:events:us-east-1:${data.aws_caller_identity.current.account_id}:rule/ce-grp-2-order-placed",
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# IAM Policy for sending messages to SQS
resource "aws_iam_role_policy" "eventbridge_sqs_policy" {
  name = "ce-grp-2-eventbridge-sqs-policy"
  role = aws_iam_role.eventbridge_target_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage"
        ],
        Resource = "arn:aws:sqs:us-east-1:${data.aws_caller_identity.current.account_id}:ce-grp-2-order-queqe.fifo"
      }
    ]
  })
}



# EventBridge Target with Input Transformer and FIFO support
resource "aws_cloudwatch_event_target" "send_to_fifo_sqs" {
  rule      = aws_cloudwatch_event_rule.order_placed_rule.name
  target_id = "SendToFifoQueue"
  arn       = "arn:aws:sqs:us-east-1:${data.aws_caller_identity.current.account_id}:ce-grp-2-order-queqe.fifo"
  role_arn  = aws_iam_role.eventbridge_target_role.arn

  input_transformer {
    input_paths = {
      detail = "$.detail"
    }

    input_template = <<TEMPLATE
{
  "MessageGroupId": "default",
  "MessageBody": {
    "detail": <detail>
  }
}
TEMPLATE
  }

  sqs_target {
    message_group_id = "default"
  }

  retry_policy {
    maximum_retry_attempts       = 0
    maximum_event_age_in_seconds = 60 # must be at least 60 seconds
  }
}
