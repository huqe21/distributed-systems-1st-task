import grpc from 'k6/net/grpc';
import { check, sleep } from 'k6';

const client = new grpc.Client();
client.load(['../proto'], 'temperature.proto');

const GRPC_ADDR = __ENV.GRPC_ADDR || 'localhost:50051';

export const options = {
  vus: 10,
  duration: '30s',
  thresholds: {
    'grpc_req_duration': ['p(95)<200'],
    'checks': ['rate>0.99'],
  },
};

export default function () {
  client.connect(GRPC_ADDR, { plaintext: true });

  // Fahrenheit to Celsius
  const f2c = client.invoke(
    'temperature.TemperatureConverter/FahrenheitToCelsius',
    { fahrenheit: 100 }
  );
  check(f2c, {
    'F2C status OK': (r) => r && r.status === grpc.StatusOK,
    'F2C correct': (r) => r && r.message && Math.abs(r.message.celsius - 37.78) < 0.01,
  });

  // Celsius to Fahrenheit
  const c2f = client.invoke(
    'temperature.TemperatureConverter/CelsiusToFahrenheit',
    { celsius: 0 }
  );
  check(c2f, {
    'C2F status OK': (r) => r && r.status === grpc.StatusOK,
    'C2F correct': (r) => r && r.message && r.message.fahrenheit === 32,
  });

  client.close();
  sleep(0.1);
}
