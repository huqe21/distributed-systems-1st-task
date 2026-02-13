# Temperature Converter (gRPC) - Full Stack GKE Application

Same functionality as the REST version, but using **gRPC + Protobuf** instead of REST/JSON.

## Architecture

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│  Flutter Web    │──────│   Envoy Proxy   │──────│   Go Backend    │
│  (Frontend)     │gRPC- │  (gRPC-Web      │ gRPC │   (gRPC Server) │
│  Port: 80       │ Web  │   Bridge)       │      │   Port: 50051   │
│                 │      │  Port: 8080     │      │                 │
└─────────────────┘      └─────────────────┘      └─────────────────┘
```

**Why Envoy?** Flutter Web runs in the browser which only supports HTTP/1.1. gRPC requires HTTP/2. Envoy acts as a bridge: it accepts gRPC-Web (HTTP/1.1) from the browser and translates it to native gRPC (HTTP/2) for the backend.

## Project Structure

```
temp-converter-grpc/
├── proto/                 # Protobuf service definition
│   └── temperature.proto
├── backend/               # Go gRPC server
│   ├── main.go
│   ├── main_test.go
│   ├── proto/             # Generated Go code
│   └── Dockerfile
├── envoy/                 # Envoy gRPC-Web proxy
│   ├── envoy.yaml         # Config for docker-compose
│   ├── envoy-k8s.yaml     # Config for Kubernetes
│   └── Dockerfile
├── frontend/              # Flutter web app (gRPC-Web client)
│   ├── lib/
│   │   ├── main.dart
│   │   └── generated/     # Generated Dart gRPC code
│   └── Dockerfile
├── k8s/                   # Kubernetes manifests (incl. Ingress)
├── loadtest/              # ghz + k6 load testing scripts
└── docker-compose.yaml
```

## Prerequisites

- Docker Desktop
- Google Cloud SDK (`gcloud`)
- kubectl
- ghz (for gRPC load testing): `brew install ghz`
- k6 (for gRPC load testing with scenarios): `brew install k6`

---

## Part 1: Local Development

### Run Backend Tests

```bash
cd backend
go test -v
```

### Run with Docker Compose

```bash
# Build and start all 3 services (backend + envoy + frontend)
docker-compose up --build

# Frontend:       http://localhost:80
# Envoy (gRPC-Web): localhost:8080
# Backend (gRPC):   localhost:50051
# Envoy Admin:      http://localhost:9901
```

### Test gRPC API with grpcurl

```bash
# Install grpcurl
brew install grpcurl

# List services
grpcurl -plaintext localhost:50051 list

# Fahrenheit to Celsius
grpcurl -plaintext -d '{"fahrenheit": 100}' \
  localhost:50051 temperature.TemperatureConverter/FahrenheitToCelsius

# Celsius to Fahrenheit
grpcurl -plaintext -d '{"celsius": 37.78}' \
  localhost:50051 temperature.TemperatureConverter/CelsiusToFahrenheit

# Health check
grpcurl -plaintext localhost:50051 grpc.health.v1.Health/Check
```

---

## Part 2: Deploy to GKE

### Step 1: Set Up GCP Project

```bash
export PROJECT_ID=verteilte-systeme-487315
export REGION=us-central1
export ZONE=us-central1-a

gcloud auth login
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable artifactregistry.googleapis.com
```

### Step 2: Create Artifact Registry Repository

```bash
gcloud artifacts repositories create temp-converter-grpc \
  --repository-format=docker \
  --location=$REGION \
  --description="Temperature Converter gRPC Docker images"

gcloud auth configure-docker $REGION-docker.pkg.dev
```

### Step 3: Create GKE Cluster

```bash
gcloud container clusters create temp-converter-grpc-cluster-1 \
  --zone $ZONE \
  --num-nodes 3 \
  --machine-type e2-micro \
  --enable-autoscaling \
  --min-nodes 2 \
  --max-nodes 5

gcloud container clusters get-credentials temp-converter-grpc-cluster-1 --zone $ZONE
```

### Step 4: Build and Push Docker Images (amd64)

```bash
# Backend
docker build --platform linux/amd64 \
  -t $REGION-docker.pkg.dev/$PROJECT_ID/temp-converter-grpc/backend:latest \
  ./backend
docker push $REGION-docker.pkg.dev/$PROJECT_ID/temp-converter-grpc/backend:latest

# Envoy
docker build --platform linux/amd64 \
  -t $REGION-docker.pkg.dev/$PROJECT_ID/temp-converter-grpc/envoy:latest \
  ./envoy
docker push $REGION-docker.pkg.dev/$PROJECT_ID/temp-converter-grpc/envoy:latest

# Frontend
docker build --platform linux/amd64 \
  -t $REGION-docker.pkg.dev/$PROJECT_ID/temp-converter-grpc/frontend:latest \
  ./frontend
docker push $REGION-docker.pkg.dev/$PROJECT_ID/temp-converter-grpc/frontend:latest
```

### Step 5: Deploy to Kubernetes

```bash
# Apply all manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/envoy-configmap.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/backend-hpa.yaml
kubectl apply -f k8s/envoy-deployment.yaml
kubectl apply -f k8s/envoy-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml

# Deploy Ingress (routes traffic through a single IP)
kubectl apply -f k8s/ingress.yaml
```

### Step 6: Verify Deployment

```bash
# Check all pods
kubectl get pods -n temp-converter-grpc

# Check services
kubectl get services -n temp-converter-grpc

# Get Ingress external IP (may take 5-10 minutes)
kubectl get ingress -n temp-converter-grpc

# Test backend via port-forward
kubectl port-forward svc/backend 50051:50051 -n temp-converter-grpc &
grpcurl -plaintext -d '{"fahrenheit": 100}' \
  localhost:50051 temperature.TemperatureConverter/FahrenheitToCelsius
```

### Step 7: Access the Application

```bash
# Via Ingress (single IP for everything)
EXTERNAL_IP=$(kubectl get ingress temp-converter-grpc-ingress -n temp-converter-grpc -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Application URL: http://$EXTERNAL_IP"
```

The Ingress routes:
- `/*` -> Frontend (Flutter web app)
- `/temperature.TemperatureConverter/*` -> Envoy (gRPC-Web proxy)

---

## Part 3: Load Testing

Two load testing tools are available:
- **ghz** - Pure gRPC load testing, fast and simple
- **k6** - Scenario-based testing with ramping, stages, and detailed metrics

### Install Tools

```bash
brew install ghz k6
```

### Option A: ghz (Simple, Fast)

```bash
cd loadtest

# Quick test
./quick-test.sh localhost:50051

# Full load test
./run-load-test.sh localhost:50051

# Against GKE (port-forward backend first)
kubectl port-forward svc/backend 50051:50051 -n temp-converter-grpc &
./run-load-test.sh localhost:50051
```

### Option B: k6 (Scenario-Based, Ramping)

```bash
cd loadtest

# Quick test (10 VUs, 30s)
k6 run k6-quick-test.js

# Full load test (smoke -> load -> stress -> spike)
k6 run k6-load-test.js

# Against GKE
kubectl port-forward svc/backend 50051:50051 -n temp-converter-grpc &
k6 run -e GRPC_ADDR=localhost:50051 k6-load-test.js
```

### Load Test Scenarios

**ghz scenarios:**

| Scenario | Concurrent | Duration | Description |
|----------|-----------|----------|-------------|
| Smoke | 1 | 10 requests | Verify connectivity |
| Load | 50 | 30s | Normal expected load |
| Stress | 200 | 60s | Push the system |
| Spike | 500 | 30s | Sudden burst of users |

**k6 scenarios** (ramping, all in one run):

| Scenario | VUs | Duration | Description |
|----------|-----|----------|-------------|
| Smoke | 1 | 30s | Verify system works |
| Load | 0 -> 50 | 5min | Ramp to normal load |
| Stress | 100 -> 200 | 7min | Push beyond capacity |
| Spike | 0 -> 500 | 1.5min | Sudden burst |

### Monitor During Load Test

```bash
# Watch pod scaling (HPA)
kubectl get hpa -n temp-converter-grpc -w

# Watch pod status
kubectl get pods -n temp-converter-grpc -w

# Check resource usage
kubectl top pods -n temp-converter-grpc
```

---

## Part 4: Monitoring & Scaling

### View Logs

```bash
kubectl logs -l app=backend -n temp-converter-grpc --tail=100 -f
kubectl logs -l app=envoy -n temp-converter-grpc --tail=100 -f
kubectl logs -l app=frontend -n temp-converter-grpc --tail=100 -f
```

### Envoy Admin Dashboard

```bash
kubectl port-forward svc/envoy 9901:9901 -n temp-converter-grpc
# Open http://localhost:9901 for Envoy stats and config
```

---

## Part 5: Cleanup

```bash
# Delete all Kubernetes resources
kubectl delete namespace temp-converter-grpc

# Delete the cluster
gcloud container clusters delete temp-converter-grpc-cluster-1 --zone $ZONE

# Delete container images
gcloud artifacts docker images delete $REGION-docker.pkg.dev/$PROJECT_ID/temp-converter-grpc/backend:latest --delete-tags
gcloud artifacts docker images delete $REGION-docker.pkg.dev/$PROJECT_ID/temp-converter-grpc/envoy:latest --delete-tags
gcloud artifacts docker images delete $REGION-docker.pkg.dev/$PROJECT_ID/temp-converter-grpc/frontend:latest --delete-tags

# Delete repository
gcloud artifacts repositories delete temp-converter-grpc --location=$REGION
```

---

## gRPC API Reference

### Service: temperature.TemperatureConverter

#### RPC: FahrenheitToCelsius

```protobuf
rpc FahrenheitToCelsius(FahrenheitRequest) returns (CelsiusResponse);

message FahrenheitRequest { double fahrenheit = 1; }
message CelsiusResponse  { double celsius = 1; }
```

#### RPC: CelsiusToFahrenheit

```protobuf
rpc CelsiusToFahrenheit(CelsiusRequest) returns (FahrenheitResponse);

message CelsiusRequest    { double celsius = 1; }
message FahrenheitResponse { double fahrenheit = 1; }
```

---

## Key Differences from REST Version

| Aspect | REST | gRPC |
|--------|------|------|
| Protocol | HTTP/1.1 + JSON | HTTP/2 + Protobuf |
| Schema | OpenAPI (optional) | .proto file (required) |
| Code generation | Manual | Auto-generated |
| Browser support | Native | Needs Envoy proxy |
| Payload size | Larger (JSON text) | Smaller (binary Protobuf) |
| Services | 3 (frontend + backend) | 3 (frontend + envoy + backend) |
| Type safety | Runtime validation | Compile-time validation |
# distributed-systems-1st-task
