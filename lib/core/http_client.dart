
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gestor_cafeteria/core/failure.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;
  final Uri baseUrl;
  final Duration timeout;

  ApiClient({
    http.Client? client,
    String? baseUrl,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client(),
       baseUrl = Uri.parse(
         baseUrl ??
             (const String.fromEnvironment('API_URL').isNotEmpty
                 ? const String.fromEnvironment('API_URL')
                 : (kIsWeb
                     ? 'http://localhost:8000'
                     : 'http://10.0.2.2:8000')),
       );

  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, Object body) => _send('POST', path, body);
  Future<dynamic> patch(String path, Object body) => _send('PATCH', path, body);
  Future<void> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(String method, String path, [Object? body]) async {
    final request = http.Request(method, baseUrl.resolve(path))
      ..headers['Accept'] = 'application/json';

    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;

    try {
      response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(timeout);
    } on http.ClientException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    }

    final json = _tryDecode(response);
    final code = response.statusCode;

    if (code >= 200 && code < 300) return json;

    final detail = _extractDetail(json) ?? 'Error HTTP $code';

    switch (code) {
      case 404:
        throw NotFoundFailure(detail);
      case 409:
        throw ConflictFailure(detail);
      case 422:
        throw ValidationFailure(_extractValidationFields(json));
      default:
        if (code >= 500 && code <= 599) {
          throw ServerFailure(code);
        }
        throw UnexpectedFailure(code, detail);
    }
  }

  dynamic _tryDecode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return null;
    }
  }

  String? _extractDetail(dynamic decoded) {
    if (decoded is! Map || !decoded.containsKey('detail')) return null;

    final detail = decoded['detail'];

    if (detail is String && detail.isNotEmpty) return detail;

    if (detail is List) {
      final messages = <String>[];

      for (final item in detail) {
        if (item is Map && item['msg'] is String) {
          messages.add(item['msg'] as String);
        } else if (item is String) {
          messages.add(item);
        }
      }

      if (messages.isNotEmpty) return messages.join('; ');
      return detail.isEmpty ? null : detail.join('; ');
    }

    return null;
  }

  Map<String, String> _extractValidationFields(dynamic decoded) {
    if (decoded is! Map || decoded['detail'] is! List) return {};

    final fields = <String, String>{};

    for (final item in decoded['detail'] as List) {
      if (item is! Map) continue;

      final location = item['loc'];
      final message = item['msg'];

      if (location is List &&
          location.length > 1 &&
          location[1] != null &&
          message is String) {
        fields[location[1].toString()] = message;
      }
    }

    return fields;
  }
}
