# 1. Esperar a que el Load Balancer de NGINX tenga hostname
resource "null_resource" "wait_for_ingress" {
  provisioner "local-exec" {
    command = <<EOT
    for i in {1..30}; do
      HOST=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
      if [ ! -z "$HOST" ]; then
        echo "Ingress hostname is $HOST"
        echo "$HOST" > alb_hostname.txt
        break
      fi
      echo "Waiting for ingress load balancer..."
      sleep 10
    done
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

# 2. Leer el archivo con el hostname
data "local_file" "alb_hostname" {
  depends_on = [null_resource.wait_for_ingress]
  filename   = "${path.module}/alb_hostname.txt"
}

# 3. Crear la función Lambda de healthcheck
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
      ALB_HOSTNAME = data.local_file.alb_hostname.content
    }
  }

  depends_on = [data.local_file.alb_hostname]
}
