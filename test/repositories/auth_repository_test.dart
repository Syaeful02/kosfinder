import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kostfinder/repositories/auth_repository.dart';

void main() {
  const supabaseUrl = 'https://example.supabase.co';
  const supabaseKey = 'dummy-anon-key';
  const userJson = {
    'id': 'user-uuid-1',
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': 'owner@example.com',
    'created_at': '2026-11-23T10:00:00.000Z',
    'app_metadata': <String, dynamic>{},
    'user_metadata': <String, dynamic>{},
  };

  group('AuthRepository', () {
    test('signUp sends email and password to Supabase Auth', () async {
      http.Request? capturedRequest;
      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode(userJson),
          200,
          request: request,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final client = SupabaseClient(
        supabaseUrl,
        supabaseKey,
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
        httpClient: mockHttpClient,
      );

      final response = await AuthRepository(client: client)
          .signUp(email: 'owner@example.com', password: 'secure1');

      expect(response.user?.id, 'user-uuid-1');
      expect(capturedRequest?.url.path, '/auth/v1/signup');
      expect(
        jsonDecode(capturedRequest!.body),
        containsPair('email', 'owner@example.com'),
      );
      expect(
        jsonDecode(capturedRequest!.body),
        containsPair('password', 'secure1'),
      );
      await client.dispose();
    });

    test('signInWithPassword sends credentials and returns the user', () async {
      http.Request? capturedRequest;
      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode(userJson),
          200,
          request: request,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final client = SupabaseClient(
        supabaseUrl,
        supabaseKey,
        httpClient: mockHttpClient,
      );

      final response = await AuthRepository(client: client)
          .signInWithPassword(email: 'owner@example.com', password: 'secure1');

      expect(response.user?.email, 'owner@example.com');
      expect(capturedRequest?.url.path, '/auth/v1/token');
      expect(capturedRequest?.url.queryParameters['grant_type'], 'password');
      await client.dispose();
    });

    test('signOut succeeds when there is no active session', () async {
      final client = SupabaseClient(
        supabaseUrl,
        supabaseKey,
        httpClient: MockClient((request) async => http.Response('', 204)),
      );

      await expectLater(AuthRepository(client: client).signOut(), completes);
      await client.dispose();
    });

    test('currentUser is null when no session exists', () async {
      final client = SupabaseClient(
        supabaseUrl,
        supabaseKey,
        httpClient: MockClient((request) async => http.Response('', 204)),
      );

      expect(AuthRepository(client: client).currentUser, isNull);
      await client.dispose();
    });
  });
}
