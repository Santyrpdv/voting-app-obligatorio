
provider "kubernetes" {
  host                   = aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
}


data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [helm_release.nginx_ingress]
}

locals {
  lb_hostname = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
  vote_url    = "http://${local.lb_hostname}/vote"
  result_url  = "http://${local.lb_hostname}/result"
}


resource "aws_lambda_function" "healthcheck" {
  function_name = "url-healthcheck"
  role          = var.existing_role_arn               
  handler       = "main.handler"
  runtime       = "python3.11"
  filename      = "healthcheck-lambda.zip"
  timeout       = 10
  source_code_hash = filebase64sha256("healthcheck-lambda.zip")

  environment {
    variables = {
      URLS = "${local.vote_url},${local.result_url}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "every_5_minutes" {
  name                = "run-healthcheck-every-5-mins"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_5_minutes.name
  target_id = "lambda-healthcheck"
  arn       = aws_lambda_function.healthcheck.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.healthcheck.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_5_minutes.arn
}


output "ingress_lb_hostname" {
  value = local.lb_hostname
}
