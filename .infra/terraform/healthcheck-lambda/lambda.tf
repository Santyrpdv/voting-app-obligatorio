variable "url_list" {
  description = "Lista de endpoints a monitorear"
  type        = list(string)
  default     = []
}

resource "aws_sns_topic" "health_alerts" {
  name = "health-mail-alerts"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.health_alerts.arn
  protocol  = "email"
  endpoint  = "santyrpdv@gmail.com" 
}


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/main.py"
  output_path = "${path.module}/healthcheck-lambda.zip"
}

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# Crear función Lambda
resource "aws_lambda_function" "health_mail_alert" {
  function_name = "health-mail-alert"
  role          = data.aws_iam_role.lab_role.arn
  runtime       = "python3.11"
  handler       = "main.handler"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout       = 10

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.health_alerts.arn
      URL_LIST      = join(",", var.url_list)
    }
  }
}

# Ejecutar Lambda cada 5 minutos
resource "aws_cloudwatch_event_rule" "five_minutes" {
  name                = "health-mail-alert-5min"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.five_minutes.name
  target_id = "HealthMailAlert"
  arn       = aws_lambda_function.health_mail_alert.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health_mail_alert.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.five_minutes.arn
}
