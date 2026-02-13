# Build stage
FROM --platform=linux/amd64 golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o server .

# Run stage
FROM --platform=linux/amd64 alpine:3.19

WORKDIR /app

RUN adduser -D -g '' appuser
# Install grpc-health-probe for Kubernetes health checks
RUN apk add --no-cache wget && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v0.4.25/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe && \
    apk del wget

COPY --from=builder /app/server .

USER appuser

EXPOSE 50051

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["/bin/grpc_health_probe", "-addr=:50051"]

CMD ["./server"]
