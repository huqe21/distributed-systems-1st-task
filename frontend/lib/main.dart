import 'package:flutter/material.dart';
import 'package:grpc/grpc_web.dart';
import 'generated/temperature.pbgrpc.dart';

void main() {
  runApp(const TemperatureConverterApp());
}

class TemperatureConverterApp extends StatelessWidget {
  const TemperatureConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter (gRPC)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ConverterPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  bool _isLoading = false;
  bool _isFahrenheitToCelsius = true;
  String? _error;

  late final GrpcWebClientChannel _channel;
  late final TemperatureConverterClient _client;

  @override
  void initState() {
    super.initState();
    // Envoy proxy endpoint
    // Locally: http://localhost:8080 (Envoy directly)
    // In K8s with Ingress: same origin (Ingress routes gRPC-Web paths to Envoy)
    // In K8s without Ingress: same origin via nginx proxy
    final uri = Uri.base;
    final envoyUrl = (uri.host == 'localhost' || uri.host == '127.0.0.1')
        ? Uri.parse('http://localhost:8080')
        : Uri.parse('${uri.scheme}://${uri.host}');

    _channel = GrpcWebClientChannel.xhr(envoyUrl);
    _client = TemperatureConverterClient(_channel);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _channel.shutdown();
    super.dispose();
  }

  Future<void> _convert() async {
    final input = double.tryParse(_inputController.text);
    if (input == null) {
      setState(() {
        _error = 'Please enter a valid number';
        _result = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isFahrenheitToCelsius) {
        final response = await _client.fahrenheitToCelsius(
          FahrenheitRequest()..fahrenheit = input,
        );
        setState(() {
          _result = '${response.celsius.toStringAsFixed(2)} °C';
        });
      } else {
        final response = await _client.celsiusToFahrenheit(
          CelsiusRequest()..celsius = input,
        );
        setState(() {
          _result = '${response.fahrenheit.toStringAsFixed(2)} °F';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'gRPC error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _swapConversion() {
    setState(() {
      _isFahrenheitToCelsius = !_isFahrenheitToCelsius;
      _result = '';
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fromUnit = _isFahrenheitToCelsius ? 'Fahrenheit' : 'Celsius';
    final toUnit = _isFahrenheitToCelsius ? 'Celsius' : 'Fahrenheit';
    final fromSymbol = _isFahrenheitToCelsius ? '°F' : '°C';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Converter (gRPC)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Protocol badge
              Center(
                child: Chip(
                  label: const Text('gRPC-Web + Protobuf'),
                  avatar: const Icon(Icons.bolt, size: 18),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                ),
              ),
              const SizedBox(height: 16),

              // Conversion direction
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(fromUnit, style: Theme.of(context).textTheme.titleMedium),
                      IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: _swapConversion,
                        tooltip: 'Swap conversion direction',
                      ),
                      Text(toUnit, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Input field
              TextField(
                controller: _inputController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(
                  labelText: 'Enter temperature in $fromUnit',
                  suffixText: fromSymbol,
                  border: const OutlineInputBorder(),
                  errorText: _error,
                ),
                onSubmitted: (_) => _convert(),
              ),
              const SizedBox(height: 16),

              // Convert button
              ElevatedButton(
                onPressed: _isLoading ? null : _convert,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Convert'),
              ),
              const SizedBox(height: 24),

              // Result display
              if (_result.isNotEmpty)
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text('Result', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Text(
                          _result,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
