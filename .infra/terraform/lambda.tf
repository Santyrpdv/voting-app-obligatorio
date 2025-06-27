resource "aws_lambda_function" "ecr_cleanup" {
  function_name = "ecr-cleanup"
  role          = var.existing_role_arn
  handler       = "main.handler"
  runtime       = "python3.11"
  filename      = "ecr-cleanup.zip"
  timeout       = 30
  source_code_hash = filebase64sha256("ecr-cleanup.zip")

  environment {
    variables = {
      REPOS   = "vote,result,worker"
      KEEP_N  = "10"
    }
  }
}
