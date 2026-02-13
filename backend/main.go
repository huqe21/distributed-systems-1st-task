package main

import (
	"context"
	"log"
	"net"
	"os"

	pb "temp-converter-grpc/proto"

	"google.golang.org/grpc"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/reflection"
)

// server implements the TemperatureConverterServer interface
type server struct {
	pb.UnimplementedTemperatureConverterServer
}

// FahrenheitToCelsius converts Fahrenheit to Celsius
func (s *server) FahrenheitToCelsius(ctx context.Context, req *pb.FahrenheitRequest) (*pb.CelsiusResponse, error) {
	celsius := (req.Fahrenheit - 32) * 5 / 9
	log.Printf("FahrenheitToCelsius: %.2f°F -> %.2f°C", req.Fahrenheit, celsius)
	return &pb.CelsiusResponse{Celsius: celsius}, nil
}

// CelsiusToFahrenheit converts Celsius to Fahrenheit
func (s *server) CelsiusToFahrenheit(ctx context.Context, req *pb.CelsiusRequest) (*pb.FahrenheitResponse, error) {
	fahrenheit := req.Celsius*9/5 + 32
	log.Printf("CelsiusToFahrenheit: %.2f°C -> %.2f°F", req.Celsius, fahrenheit)
	return &pb.FahrenheitResponse{Fahrenheit: fahrenheit}, nil
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "50051"
	}

	lis, err := net.Listen("tcp", ":"+port)
	if err != nil {
		log.Fatalf("Failed to listen: %v", err)
	}

	grpcServer := grpc.NewServer()

	// Register temperature converter service
	pb.RegisterTemperatureConverterServer(grpcServer, &server{})

	// Register health check service (for Kubernetes probes)
	healthServer := health.NewServer()
	healthpb.RegisterHealthServer(grpcServer, healthServer)
	healthServer.SetServingStatus("", healthpb.HealthCheckResponse_SERVING)

	// Register reflection service (for debugging with grpcurl)
	reflection.Register(grpcServer)

	log.Printf("gRPC server starting on port %s", port)
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("Failed to serve: %v", err)
	}
}
