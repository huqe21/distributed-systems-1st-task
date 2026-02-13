#!/bin/bash
# Quick gRPC test - verify connectivity and basic performance
# Usage: ./quick-test.sh [BACKEND_HOST:PORT]

BACKEND="${1:-localhost:50051}"

echo "Quick gRPC test against $BACKEND"
echo ""

ghz --insecure \
  --proto "../proto/temperature.proto" \
  --call temperature.TemperatureConverter.FahrenheitToCelsius \
  -d '{"fahrenheit": 100}' \
  -c 10 -z 10s \
  "$BACKEND"
