import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_cafeteria/core/failure.dart';
import 'package:gestor_cafeteria/core/http_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiClient', () {
    test('200: devuelve el contenido de una respuesta exitosa', () async {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response(
            '{"message":"OK"}',
            200,
            headers: {'content-type': 'application/json'},
          ),
        ),
        baseUrl: 'https://example.com',
      );

      final result = await client.get('/test');

      expect(result, {'message': 'OK'});
    });

    test('300: genera UnexpectedFailure', () async {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response('Redirection', 300),
        ),
        baseUrl: 'https://example.com',
      );

      expect(
        () => client.get('/test'),
        throwsA(isA<UnexpectedFailure>()),
      );
    });

    test('404: genera NotFoundFailure', () async {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response(
            '{"detail":"Order not found"}',
            404,
          ),
        ),
        baseUrl: 'https://example.com',
      );

      expect(
        () => client.get('/test'),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('409: genera ConflictFailure', () async {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response(
            '{"detail":"Conflict detected"}',
            409,
          ),
        ),
        baseUrl: 'https://example.com',
      );

      expect(
        () => client.get('/test'),
        throwsA(isA<ConflictFailure>()),
      );
    });

    test('422: genera ValidationFailure con los campos', () async {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response(
            '{"detail":[{"loc":["body","customer"],'
            '"msg":"Must be 1-50 characters"}]}',
            422,
          ),
        ),
        baseUrl: 'https://example.com',
      );

      try {
        await client.get('/test');
        fail('Se esperaba ValidationFailure');
      } on ValidationFailure catch (error) {
        expect(
          error.fields,
          {'customer': 'Must be 1-50 characters'},
        );
      }
    });

    test('503: genera ServerFailure', () async {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response('Service unavailable', 503),
        ),
        baseUrl: 'https://example.com',
      );

      expect(
        () => client.get('/test'),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('ClientException: genera NetworkFailure', () async {
      final client = ApiClient(
        client: MockClient(
          (_) async => throw http.ClientException('Connection failed'),
        ),
        baseUrl: 'https://example.com',
      );

      expect(
        () => client.get('/test'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('Timeout: genera NetworkFailure', () async {
      final client = ApiClient(
        client: MockClient(
          (_) async {
            await Future<void>.delayed(
              const Duration(milliseconds: 100),
            );
            return http.Response('{}', 200);
          },
        ),
        baseUrl: 'https://example.com',
        timeout: const Duration(milliseconds: 10),
      );

      expect(
        () => client.get('/test'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}