
data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.eks.name
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
