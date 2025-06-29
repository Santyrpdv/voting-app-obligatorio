resource "aws_cloudwatch_dashboard" "eks_dashboard" {
  # 👉 quedará “dev-eks-dashboard”, “test-eks-dashboard”, etc.
  dashboard_name = "${var.cluster_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # ───────────────────────── CPU ─────────────────────────
      {
        "type" : "metric",
        "x"    : 0,
        "y"    : 0,
        "width": 12,
        "height": 6,
        "properties": {
          "title"  : "CPU (millicores)",
          "stat"   : "Average",
          "view"   : "timeSeries",
          "region" : var.aws_region,
          "period" : 30,                      # 30 s
          "metrics": [
            [ "AWS/ContainerInsights",
              "cpu_usage_total",
              "ClusterName", var.cluster_name,
              { "label": var.environment }    # etiqueta legible
            ]
          ]
        }
      },

      # ──────────────────────── Memoria ──────────────────────
      {
        "type" : "metric",
        "x"    : 12,
        "y"    : 0,
        "width": 12,
        "height": 6,
        "properties": {
          "title"  : "Memoria (MiB)",
          "stat"   : "Average",
          "view"   : "timeSeries",
          "region" : var.aws_region,
          "period" : 30,
          "metrics": [
            [ "AWS/ContainerInsights",
              "memory_usage_total",
              "ClusterName", var.cluster_name,
              { "label": var.environment }
            ]
          ]
        }
      },

      # ───────────── Pods en ejecución ─────────────
      {
        "type" : "metric",
        "x"    : 0,
        "y"    : 6,
        "width": 12,
        "height": 6,
        "properties": {
          "title"  : "Pods ejecutándose",
          "stat"   : "Maximum",
          "view"   : "timeSeries",
          "region" : var.aws_region,
          "period" : 30,
          "metrics": [
            [ "AWS/ContainerInsights",
              "pod_number_of_running",
              "ClusterName", var.cluster_name,
              { "label": var.environment }
            ]
          ]
        }
      }
    ]
  })
}