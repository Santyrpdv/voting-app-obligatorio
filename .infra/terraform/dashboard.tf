resource "aws_cloudwatch_dashboard" "monitor_dashboard" {
  dashboard_name = "observabilidad-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width = 12,
        height = 6,
        properties = {
          title = "Uso de CPU (ECS/EKS/EC2)"
          view = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.cluster_name, "ServiceName", var.service_name]
          ]
          period = 300
          stat = "Average"
        }
      }
    ]
  })
}
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "HighCPUAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "La CPU está por encima del 70%"
  alarm_actions       = [aws_sns_topic.alert_topic.arn]

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }
}
resource "aws_sns_topic" "alert_topic" {
  name = "alertas-monitoring"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alert_topic.arn
  protocol  = "email"
  endpoint  = "santyrpdv@gmail.com"
}

# ================================================================
#  CloudWatch Dashboard – EKS (dev | test | prod)
# ================================================================
resource "aws_cloudwatch_dashboard" "eks_multi_env" {
  dashboard_name = "eks-observabilidad-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # ────────────────────────────────────────────────────────────
      #  1) CPU Utilization (millicores) ─ tres clústeres
      # ────────────────────────────────────────────────────────────
      {
        "type" : "metric",
        "x"    : 0,
        "y"    : 0,
        "width": 12,
        "height": 6,
        "properties": {
          "title" : "CPU (millicores) – dev / test / prod",
          "stat"  : "Average",
          "view"  : "timeSeries",
          "region": var.aws_region,
          "period": 300,
          "metrics": [
            [ "AWS/ContainerInsights", "cpu_usage_total", "ClusterName", "dev-eks",  { "label": "dev"  } ],
            [ "...",                   "cpu_usage_total", "ClusterName", "test-eks", { "label": "test" } ],
            [ "...",                   "cpu_usage_total", "ClusterName", "prod-eks", { "label": "prod" } ]
          ]
        }
      },

      # ────────────────────────────────────────────────────────────
      #  2) Memory Utilization (MiB) ─ tres clústeres
      # ────────────────────────────────────────────────────────────
      {
        "type" : "metric",
        "x"    : 12,
        "y"    : 0,
        "width": 12,
        "height": 6,
        "properties": {
          "title" : "Memoria (MiB) – dev / test / prod",
          "stat"  : "Average",
          "view"  : "timeSeries",
          "region": var.aws_region,
          "period": 300,
          "metrics": [
            [ "AWS/ContainerInsights", "memory_usage_total", "ClusterName", "dev-eks",  { "label": "dev"  } ],
            [ "...",                   "memory_usage_total", "ClusterName", "test-eks", { "label": "test" } ],
            [ "...",                   "memory_usage_total", "ClusterName", "prod-eks", { "label": "prod" } ]
          ]
        }
      },

      # ────────────────────────────────────────────────────────────
      #  3) Running Pods por clúster
      # ────────────────────────────────────────────────────────────
      {
        "type" : "metric",
        "x"    : 0,
        "y"    : 6,
        "width": 12,
        "height": 6,
        "properties": {
          "title" : "Pods ejecutándose – dev / test / prod",
          "stat"  : "Maximum",
          "view"  : "timeSeries",
          "region": var.aws_region,
          "period": 300,
          "metrics": [
            [ "AWS/ContainerInsights", "pod_number_of_running", "ClusterName", "dev-eks",  { "label": "dev"  } ],
            [ "...",                   "pod_number_of_running", "ClusterName", "test-eks", { "label": "test" } ],
            [ "...",                   "pod_number_of_running", "ClusterName", "prod-eks", { "label": "prod" } ]
          ]
        }
      }
    ]
  })
}
