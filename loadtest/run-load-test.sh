#!/bin/bash
# gRPC Load Testing with ghz
# Install: brew install ghz (or go install github.com/bojand/ghz/cmd/ghz@latest)
#
# Usage:
#   ./run-load-test.sh [BACKEND_HOST:PORT]
#   Default: localhost:50051

set -e

BACKEND="${1:-localhost:50051}"
PROTO_PATH="../proto/temperature.proto"

echo "================================================"
echo "  gRPC Load Test - Temperature Converter"
echo "  Target: $BACKEND"
echo "================================================"
echo ""

# --- Smoke Test ---
echo "--- SMOKE TEST (1 concurrent, 10 requests) ---"
ghz --insecure \
  --proto "$PROTO_PATH" \
  --call temperature.TemperatureConverter.FahrenheitToCelsius \
  -d '{"fahrenheit": 100}' \
  -c 1 -n 10 \
  "$BACKEND"

echo ""

# --- Load Test: Fahrenheit to Celsius ---
echo "--- LOAD TEST: FahrenheitToCelsius (50 concurrent, 30s) ---"
ghz --insecure \
  --proto "$PROTO_PATH" \
  --call temperature.TemperatureConverter.FahrenheitToCelsius \
  -d '{"fahrenheit": 100}' \
  -c 50 -z 30s \
  --connections 10 \
  "$BACKEND"

echo ""

# --- Load Test: Celsius to Fahrenheit ---
echo "--- LOAD TEST: CelsiusToFahrenheit (50 concurrent, 30s) ---"
ghz --insecure \
  --proto "$PROTO_PATH" \
  --call temperature.TemperatureConverter.CelsiusToFahrenheit \
  -d '{"celsius": 37.78}' \
  -c 50 -z 30s \
  --connections 10 \
  "$BACKEND"

echo ""

# --- Stress Test ---
echo "--- STRESS TEST: FahrenheitToCelsius (200 concurrent, 60s) ---"
ghz --insecure \
  --proto "$PROTO_PATH" \
  --call temperature.TemperatureConverter.FahrenheitToCelsius \
  -d '{"fahrenheit": 212}' \
  -c 200 -z 60s \
  --connections 20 \
  "$BACKEND"

echo ""

# --- Spike Test ---
echo "--- SPIKE TEST: FahrenheitToCelsius (500 concurrent, 30s) ---"
ghz --insecure \
  --proto "$PROTO_PATH" \
  --call temperature.TemperatureConverter.FahrenheitToCelsius \
  -d '{"fahrenheit": 98.6}' \
  -c 500 -z 30s \
  --connections 50 \
  "$BACKEND"

echo ""
echo "================================================"
echo "  Load test completed!"
echo "================================================"
