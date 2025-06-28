locals {
  alb_hostname = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
}

resource "aws_lambda_function" "healthcheck" {
  function_name = "healthcheck"
  role          = data.aws_iam_role.lab_role.arn
  handler       = "main.handler"
  runtime       = "python3.11"
  filename      = "healthcheck-lambda.zip"
  timeout       = 30
  source_code_hash = filebase64sha256("healthcheck-lambda.zip")

  environment {
    variables = {
      ALB_HOSTNAME = local.alb_hostname
    }
  }

  depends_on = [helm_release.nginx_ingress]
}
