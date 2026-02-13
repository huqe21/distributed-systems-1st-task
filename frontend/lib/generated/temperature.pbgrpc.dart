// This is a generated file - do not edit.
//
// Generated from temperature.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'temperature.pb.dart' as $0;

export 'temperature.pb.dart';

/// Temperature conversion service
@$pb.GrpcServiceName('temperature.TemperatureConverter')
class TemperatureConverterClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TemperatureConverterClient(super.channel,
      {super.options, super.interceptors});

  /// Convert Fahrenheit to Celsius
  $grpc.ResponseFuture<$0.CelsiusResponse> fahrenheitToCelsius(
    $0.FahrenheitRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$fahrenheitToCelsius, request, options: options);
  }

  /// Convert Celsius to Fahrenheit
  $grpc.ResponseFuture<$0.FahrenheitResponse> celsiusToFahrenheit(
    $0.CelsiusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$celsiusToFahrenheit, request, options: options);
  }

  // method descriptors

  static final _$fahrenheitToCelsius =
      $grpc.ClientMethod<$0.FahrenheitRequest, $0.CelsiusResponse>(
          '/temperature.TemperatureConverter/FahrenheitToCelsius',
          ($0.FahrenheitRequest value) => value.writeToBuffer(),
          $0.CelsiusResponse.fromBuffer);
  static final _$celsiusToFahrenheit =
      $grpc.ClientMethod<$0.CelsiusRequest, $0.FahrenheitResponse>(
          '/temperature.TemperatureConverter/CelsiusToFahrenheit',
          ($0.CelsiusRequest value) => value.writeToBuffer(),
          $0.FahrenheitResponse.fromBuffer);
}

@$pb.GrpcServiceName('temperature.TemperatureConverter')
abstract class TemperatureConverterServiceBase extends $grpc.Service {
  $core.String get $name => 'temperature.TemperatureConverter';

  TemperatureConverterServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.FahrenheitRequest, $0.CelsiusResponse>(
        'FahrenheitToCelsius',
        fahrenheitToCelsius_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FahrenheitRequest.fromBuffer(value),
        ($0.CelsiusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CelsiusRequest, $0.FahrenheitResponse>(
        'CelsiusToFahrenheit',
        celsiusToFahrenheit_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CelsiusRequest.fromBuffer(value),
        ($0.FahrenheitResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.CelsiusResponse> fahrenheitToCelsius_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.FahrenheitRequest> $request) async {
    return fahrenheitToCelsius($call, await $request);
  }

  $async.Future<$0.CelsiusResponse> fahrenheitToCelsius(
      $grpc.ServiceCall call, $0.FahrenheitRequest request);

  $async.Future<$0.FahrenheitResponse> celsiusToFahrenheit_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CelsiusRequest> $request) async {
    return celsiusToFahrenheit($call, await $request);
  }

  $async.Future<$0.FahrenheitResponse> celsiusToFahrenheit(
      $grpc.ServiceCall call, $0.CelsiusRequest request);
}
