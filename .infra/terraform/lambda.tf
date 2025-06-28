data "aws_lb" "nginx_lb" {
  name = "ingress-nginx-controller" # reemplazar si el nombre es distinto
}

resource "aws_lambda_function" "healthcheck" {
  function_name = "healthcheck"
  role          = data.aws_iam_role.lab_role.arn
  handler       = "main.handler"
  runtime       = "python3.11"
  filename      = "${path.module}/healthcheck-lambda.zip"
  timeout       = 30
  source_code_hash = filebase64sha256("${path.module}/healthcheck-lambda.zip")

  environment {
    variables = {
      ALB_HOSTNAME = data.aws_lb.nginx_lb.dns_name
    }
  }

  depends_on = [
    helm_release.nginx_ingress
  ]
}
