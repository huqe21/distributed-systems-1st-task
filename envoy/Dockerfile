FROM --platform=linux/amd64 envoyproxy/envoy:v1.29-latest

COPY envoy.yaml /etc/envoy/envoy.yaml

EXPOSE 8080 9901

CMD ["/usr/local/bin/envoy", "-c", "/etc/envoy/envoy.yaml"]
