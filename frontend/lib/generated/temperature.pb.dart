// This is a generated file - do not edit.
//
// Generated from temperature.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class FahrenheitRequest extends $pb.GeneratedMessage {
  factory FahrenheitRequest({
    $core.double? fahrenheit,
  }) {
    final result = create();
    if (fahrenheit != null) result.fahrenheit = fahrenheit;
    return result;
  }

  FahrenheitRequest._();

  factory FahrenheitRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FahrenheitRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FahrenheitRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'temperature'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'fahrenheit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FahrenheitRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FahrenheitRequest copyWith(void Function(FahrenheitRequest) updates) =>
      super.copyWith((message) => updates(message as FahrenheitRequest))
          as FahrenheitRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FahrenheitRequest create() => FahrenheitRequest._();
  @$core.override
  FahrenheitRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FahrenheitRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FahrenheitRequest>(create);
  static FahrenheitRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get fahrenheit => $_getN(0);
  @$pb.TagNumber(1)
  set fahrenheit($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFahrenheit() => $_has(0);
  @$pb.TagNumber(1)
  void clearFahrenheit() => $_clearField(1);
}

class CelsiusResponse extends $pb.GeneratedMessage {
  factory CelsiusResponse({
    $core.double? celsius,
  }) {
    final result = create();
    if (celsius != null) result.celsius = celsius;
    return result;
  }

  CelsiusResponse._();

  factory CelsiusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CelsiusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CelsiusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'temperature'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'celsius')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CelsiusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CelsiusResponse copyWith(void Function(CelsiusResponse) updates) =>
      super.copyWith((message) => updates(message as CelsiusResponse))
          as CelsiusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CelsiusResponse create() => CelsiusResponse._();
  @$core.override
  CelsiusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CelsiusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CelsiusResponse>(create);
  static CelsiusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get celsius => $_getN(0);
  @$pb.TagNumber(1)
  set celsius($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCelsius() => $_has(0);
  @$pb.TagNumber(1)
  void clearCelsius() => $_clearField(1);
}

class CelsiusRequest extends $pb.GeneratedMessage {
  factory CelsiusRequest({
    $core.double? celsius,
  }) {
    final result = create();
    if (celsius != null) result.celsius = celsius;
    return result;
  }

  CelsiusRequest._();

  factory CelsiusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CelsiusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CelsiusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'temperature'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'celsius')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CelsiusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CelsiusRequest copyWith(void Function(CelsiusRequest) updates) =>
      super.copyWith((message) => updates(message as CelsiusRequest))
          as CelsiusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CelsiusRequest create() => CelsiusRequest._();
  @$core.override
  CelsiusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CelsiusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CelsiusRequest>(create);
  static CelsiusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get celsius => $_getN(0);
  @$pb.TagNumber(1)
  set celsius($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCelsius() => $_has(0);
  @$pb.TagNumber(1)
  void clearCelsius() => $_clearField(1);
}

class FahrenheitResponse extends $pb.GeneratedMessage {
  factory FahrenheitResponse({
    $core.double? fahrenheit,
  }) {
    final result = create();
    if (fahrenheit != null) result.fahrenheit = fahrenheit;
    return result;
  }

  FahrenheitResponse._();

  factory FahrenheitResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FahrenheitResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FahrenheitResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'temperature'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'fahrenheit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FahrenheitResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FahrenheitResponse copyWith(void Function(FahrenheitResponse) updates) =>
      super.copyWith((message) => updates(message as FahrenheitResponse))
          as FahrenheitResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FahrenheitResponse create() => FahrenheitResponse._();
  @$core.override
  FahrenheitResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FahrenheitResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FahrenheitResponse>(create);
  static FahrenheitResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get fahrenheit => $_getN(0);
  @$pb.TagNumber(1)
  set fahrenheit($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFahrenheit() => $_has(0);
  @$pb.TagNumber(1)
  void clearFahrenheit() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
