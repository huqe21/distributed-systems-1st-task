# Build stage - Flutter web build
FROM --platform=linux/amd64 ghcr.io/cirruslabs/flutter:3.38.9 AS builder

WORKDIR /app

COPY pubspec.yaml ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# Production stage - Nginx (serves static files + proxies gRPC-Web to Envoy)
FROM --platform=linux/amd64 nginx:alpine

COPY nginx.conf.template /etc/nginx/templates/default.conf.template

COPY --from=builder /app/build/web /usr/share/nginx/html

# Default Envoy URL for Kubernetes
ENV ENVOY_URL=http://envoy.temp-converter-grpc.svc.cluster.local:8080

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

CMD ["/bin/sh", "-c", "envsubst '${ENVOY_URL}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
