#!/bin/bash

SERVICE_NAME="vote-service"
NAMESPACE="default"
MAX_RETRIES=20
SLEEP_SECONDS=10

echo "Esperando hostname del Load Balancer para el servicio $SERVICE_NAME..."

for i in $(seq 1 $MAX_RETRIES); do
  HOSTNAME=$(kubectl get svc $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  if [ -n "$HOSTNAME" ]; then
    echo "Load Balancer listo: $HOSTNAME"
    echo "::set-output name=lb_hostname::$HOSTNAME"
    exit 0
  fi
  echo "Intento $i: esperando $SLEEP_SECONDS segundos..."
  sleep $SLEEP_SECONDS
done

echo "ERROR: No se pudo obtener el hostname del LoadBalancer."
exit 1
