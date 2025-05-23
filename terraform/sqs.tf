
resource "aws_sqs_queue" "order_queue" {
  name       = "ce-grp-2-order-queqe.fifo"
  fifo_queue = true
  # Optional: Enable content-based deduplication (default false)
  content_based_deduplication = true

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "__default_policy_ID",
    "Statement" : [
      {
        "Sid" : "__owner_statement",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "SQS:*",
        "Resource" : "arn:aws:sqs:us-east-1:${data.aws_caller_identity.current.account_id}:ce9-grp-2-order-queqe.fifo"
      }
    ]
  })
}
