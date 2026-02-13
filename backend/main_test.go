package main

import (
	"context"
	"math"
	"net"
	"testing"

	pb "temp-converter-grpc/proto"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/test/bufconn"
)

const bufSize = 1024 * 1024

var lis *bufconn.Listener

func init() {
	lis = bufconn.Listen(bufSize)
	s := grpc.NewServer()
	pb.RegisterTemperatureConverterServer(s, &server{})
	go func() {
		if err := s.Serve(lis); err != nil {
			panic(err)
		}
	}()
}

func bufDialer(context.Context, string) (net.Conn, error) {
	return lis.Dial()
}

func getClient(t *testing.T) pb.TemperatureConverterClient {
	conn, err := grpc.NewClient("passthrough://bufnet",
		grpc.WithContextDialer(bufDialer),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		t.Fatalf("Failed to dial bufnet: %v", err)
	}
	t.Cleanup(func() { conn.Close() })
	return pb.NewTemperatureConverterClient(conn)
}

func floatEquals(a, b, tolerance float64) bool {
	return math.Abs(a-b) < tolerance
}

func TestFahrenheitToCelsius(t *testing.T) {
	client := getClient(t)
	ctx := context.Background()

	tests := []struct {
		name       string
		fahrenheit float64
		expected   float64
	}{
		{"Freezing point", 32, 0},
		{"Boiling point", 212, 100},
		{"Body temperature", 98.6, 37},
		{"Zero Fahrenheit", 0, -17.78},
		{"Negative same", -40, -40},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			resp, err := client.FahrenheitToCelsius(ctx, &pb.FahrenheitRequest{
				Fahrenheit: tt.fahrenheit,
			})
			if err != nil {
				t.Fatalf("FahrenheitToCelsius RPC failed: %v", err)
			}
			if !floatEquals(resp.Celsius, tt.expected, 0.01) {
				t.Errorf("FahrenheitToCelsius(%v) = %v; want %v",
					tt.fahrenheit, resp.Celsius, tt.expected)
			}
		})
	}
}

func TestCelsiusToFahrenheit(t *testing.T) {
	client := getClient(t)
	ctx := context.Background()

	tests := []struct {
		name     string
		celsius  float64
		expected float64
	}{
		{"Freezing point", 0, 32},
		{"Boiling point", 100, 212},
		{"Body temperature", 37, 98.6},
		{"Negative same", -40, -40},
		{"Room temperature", 20, 68},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			resp, err := client.CelsiusToFahrenheit(ctx, &pb.CelsiusRequest{
				Celsius: tt.celsius,
			})
			if err != nil {
				t.Fatalf("CelsiusToFahrenheit RPC failed: %v", err)
			}
			if !floatEquals(resp.Fahrenheit, tt.expected, 0.01) {
				t.Errorf("CelsiusToFahrenheit(%v) = %v; want %v",
					tt.celsius, resp.Fahrenheit, tt.expected)
			}
		})
	}
}
