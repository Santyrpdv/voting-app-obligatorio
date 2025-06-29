
data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.eks.name
}

resource "helm_release" "cloudwatch_agent" {
  name       = "cloudwatch-agent"
  namespace  = "amazon-cloudwatch"
  create_namespace = true

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-cloudwatch-metrics"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "cloudwatch-agent"
  }
}

resource "helm_release" "fluent_bit" {
  name             = "fluent-bit"
  namespace        = "amazon-cloudwatch"
  create_namespace = false  # Ya creada por cloudwatch-agent

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"

  set {
    name  = "cloudWatch.enabled"
    value = "true"
  }

  set {
    name  = "cloudWatch.region"
    value = var.aws_region
  }

  set {
    name  = "cloudWatch.logGroupName"
    value = "/aws/eks/${var.cluster_name}/application"
  }

  set {
    name  = "cloudWatch.logStreamPrefix"
    value = "fluentbit-"
  }

  set {
    name  = "cloudWatch.logRetentionDays"
    value = "7"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "fluent-bit"
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "firehose.enabled"
    value = "false"
  }

  set {
    name  = "elasticsearch.enabled"
    value = "false"
  }

  set {
    name  = "kinesis.enabled"
    value = "false"
  }
}


resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.12.1"
  values           = [file("./nginx.yaml")]

  set {
    name  = "controller.service.internal.enabled"
    value = "true"
  }

  depends_on = [
    aws_eks_cluster.eks,
    aws_eks_node_group.node_group
  ]
}
