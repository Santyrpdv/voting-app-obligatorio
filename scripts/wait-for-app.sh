#!/bin/bash

URL=$1
MAX_RETRIES=20
SLEEP_SECONDS=5

echo "Verificando disponibilidad de la app en $URL..."

for i in $(seq 1 $MAX_RETRIES); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
  if [ "$STATUS" -eq 200 ]; then
    echo "App disponible (HTTP 200)"
    exit 0
  fi
  echo "Intento $i: status HTTP $STATUS, esperando $SLEEP_SECONDS segundos..."
  sleep $SLEEP_SECONDS
done

echo "ERROR: La app no respondió con HTTP 200."
exit 1
