import grpc from 'k6/net/grpc';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const f2cTrend = new Trend('f2c_duration');
const c2fTrend = new Trend('c2f_duration');

// gRPC client
const client = new grpc.Client();
client.load(['../proto'], 'temperature.proto');

// Backend address (gRPC directly, NOT through Envoy)
const GRPC_ADDR = __ENV.GRPC_ADDR || 'localhost:50051';

export const options = {
  scenarios: {
    // Smoke test
    smoke: {
      executor: 'constant-vus',
      vus: 1,
      duration: '30s',
      startTime: '0s',
      tags: { test_type: 'smoke' },
    },
    // Load test - normal expected load
    load: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '1m', target: 50 },
        { duration: '3m', target: 50 },
        { duration: '1m', target: 0 },
      ],
      startTime: '30s',
      tags: { test_type: 'load' },
    },
    // Stress test
    stress: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '1m', target: 100 },
        { duration: '2m', target: 100 },
        { duration: '1m', target: 200 },
        { duration: '2m', target: 200 },
        { duration: '1m', target: 0 },
      ],
      startTime: '6m',
      tags: { test_type: 'stress' },
    },
    // Spike test
    spike: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '10s', target: 500 },
        { duration: '1m', target: 500 },
        { duration: '10s', target: 0 },
      ],
      startTime: '13m',
      tags: { test_type: 'spike' },
    },
  },
  thresholds: {
    'grpc_req_duration': ['p(95)<500'],
    'errors': ['rate<0.01'],
  },
};

export default function () {
  client.connect(GRPC_ADDR, { plaintext: true });

  const testF2C = Math.random() > 0.5;

  if (testF2C) {
    const fahrenheit = Math.random() * 200 - 40;
    const startTime = Date.now();

    const response = client.invoke(
      'temperature.TemperatureConverter/FahrenheitToCelsius',
      { fahrenheit: fahrenheit }
    );

    f2cTrend.add(Date.now() - startTime);

    const success = check(response, {
      'F2C: status is OK': (r) => r && r.status === grpc.StatusOK,
      'F2C: has celsius': (r) => r && r.message && r.message.celsius !== undefined,
      'F2C: correct value': (r) => {
        if (!r || !r.message) return false;
        const expected = (fahrenheit - 32) * 5 / 9;
        return Math.abs(r.message.celsius - expected) < 0.01;
      },
    });
    errorRate.add(!success);
  } else {
    const celsius = Math.random() * 100 - 40;
    const startTime = Date.now();

    const response = client.invoke(
      'temperature.TemperatureConverter/CelsiusToFahrenheit',
      { celsius: celsius }
    );

    c2fTrend.add(Date.now() - startTime);

    const success = check(response, {
      'C2F: status is OK': (r) => r && r.status === grpc.StatusOK,
      'C2F: has fahrenheit': (r) => r && r.message && r.message.fahrenheit !== undefined,
      'C2F: correct value': (r) => {
        if (!r || !r.message) return false;
        const expected = celsius * 9 / 5 + 32;
        return Math.abs(r.message.fahrenheit - expected) < 0.01;
      },
    });
    errorRate.add(!success);
  }

  client.close();
  sleep(0.1 + Math.random() * 0.2);
}

export function setup() {
  client.connect(GRPC_ADDR, { plaintext: true });
  const healthCheck = client.invoke('grpc.health.v1.Health/Check', {});
  check(healthCheck, {
    'Health check OK': (r) => r && r.status === grpc.StatusOK,
  });
  client.close();
  console.log(`gRPC backend is healthy at ${GRPC_ADDR}`);
}
