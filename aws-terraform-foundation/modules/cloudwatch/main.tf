variable "account_id" {
  type        = string
  description = "AWS Account ID for CloudWatch alarm ARNs"
}

variable "region" {
  type        = string
  description = "AWS region for CloudWatch resources"
}

resource "aws_cloudwatch_dashboard" "fintech_ops" {
  dashboard_name = "FinTech-Operations"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6
        properties = {
          title  = "Transaction Processing Rate"
          region = var.region
          annotations = {
            horizontal = []
          }
          metrics = [
            ["FinTech", "TransactionsProcessed", { stat = "Sum", period = 60 }],
            [".", "TransactionsFailed", { stat = "Sum", period = 60 }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 0
        width  = 8
        height = 6
        properties = {
          title = "API Latency (p99)"
          region = var.region
          annotations = {
            horizontal = []
          }
          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              "app/fintech-alb",
              { stat = "p99" }
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 0
        width  = 8
        height = 6
        properties = {
          title = "Database Performance"
          region = var.region
          annotations = {
            horizontal = []
          }
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBClusterIdentifier", "fintech-cluster"],
            [".", "DatabaseConnections", ".", "."],
            [".", "AuroraReplicaLag", ".", "."]
          ]
        }
      },
      {
        type   = "alarm"
        x      = 0
        y      = 6
        width  = 24
        height = 4
        properties = {
          title = "Active Alarms"
          alarms = [
            "arn:aws:cloudwatch:${var.region}:${var.account_id}:alarm:high-error-rate",
            "arn:aws:cloudwatch:${var.region}:${var.account_id}:alarm:high-latency",
            "arn:aws:cloudwatch:${var.region}:${var.account_id}:alarm:db-connections",
            "arn:aws:cloudwatch:${var.region}:${var.account_id}:alarm:fraud-detection"
          ]
        }
      }
    ]
  })
}
