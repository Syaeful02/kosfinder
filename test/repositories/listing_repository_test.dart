import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kostfinder/repositories/listing_repository.dart';

void main() {
  group('ListingRepository Tests', () {
    const supabaseUrl = 'https://example.supabase.co';
    const supabaseKey = 'dummy-anon-key';

    final sampleListingJson1 = {
      'id': 'kos-uuid-1',
      'owner_id': 'owner-uuid-1',
      'name': 'Kos Singaraja Asri',
      'price_per_month': 850000,
      'type': 'Putra',
      'address': 'Jl. Udayana No. 10, Singaraja',
      'facilities': 'WiFi, Kasur, Lemari',
      'whatsapp_number': '081234567890',
      'is_available': true,
      'created_at': '2026-11-23T10:00:00.000Z',
      'updated_at': '2026-11-23T10:00:00.000Z',
    };

    final sampleListingJson2 = {
      'id': 'kos-uuid-2',
      'owner_id': 'owner-uuid-2',
      'name': 'Kos Harmony Singaraja',
      'price_per_month': 700000,
      'type': 'Putri',
      'address': 'Jl. Ahmad Yani No. 5, Singaraja',
      'facilities': 'WiFi, Kamar Mandi Luar',
      'whatsapp_number': '089876543210',
      'is_available': true,
      'created_at': '2026-11-22T08:00:00.000Z',
      'updated_at': '2026-11-22T08:00:00.000Z',
    };

    test('fetchAll() should return list of listings ordered by created_at DESC', () async {
      Uri? capturedUri;

      final mockHttpClient = MockClient((request) async {
        capturedUri = request.url;
        if (request.url.path.contains('listings')) {
          return http.Response(
            jsonEncode([sampleListingJson1, sampleListingJson2]),
            200,
            request: request,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('[]', 200, request: request);
      });

      final client = SupabaseClient(supabaseUrl, supabaseKey, httpClient: mockHttpClient);
      final repository = ListingRepository(client: client);

      final result = await repository.fetchAll();

      expect(result.length, 2);
      expect(result[0].id, 'kos-uuid-1');
      expect(result[0].name, 'Kos Singaraja Asri');
      expect(result[1].id, 'kos-uuid-2');
      expect(result[1].name, 'Kos Harmony Singaraja');

      // Verifikasi bahwa Postgrest mengirimkan query parameter order created_at DESC
      expect(capturedUri, isNotNull);
      expect(capturedUri!.queryParameters['order'], contains('created_at.desc'));
    });

    test('fetchAll() should return empty list when no data exists', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
          request: request,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = SupabaseClient(supabaseUrl, supabaseKey, httpClient: mockHttpClient);
      final repository = ListingRepository(client: client);

      final result = await repository.fetchAll();

      expect(result, isEmpty);
    });

    test('fetchAll() should throw PostgrestException when database error occurs', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Internal Server Error', 'code': '500'}),
          500,
          request: request,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = SupabaseClient(supabaseUrl, supabaseKey, httpClient: mockHttpClient);
      final repository = ListingRepository(client: client);

      expect(() => repository.fetchAll(), throwsA(isA<PostgrestException>()));
    });

    test('fetchById() should return listing matching the requested id', () async {
      Uri? capturedUri;

      final mockHttpClient = MockClient((request) async {
        capturedUri = request.url;
        if (request.url.queryParameters['id'] == 'eq.kos-uuid-1') {
          return http.Response(
            jsonEncode(sampleListingJson1),
            200,
            request: request,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('', 200, request: request);
      });

      final client = SupabaseClient(supabaseUrl, supabaseKey, httpClient: mockHttpClient);
      final repository = ListingRepository(client: client);

      final result = await repository.fetchById('kos-uuid-1');

      expect(result, isNotNull);
      expect(result!.id, 'kos-uuid-1');
      expect(result.name, 'Kos Singaraja Asri');
      expect(result.pricePerMonth, 850000);

      // Verifikasi query parameter id filter
      expect(capturedUri, isNotNull);
      expect(capturedUri!.queryParameters['id'], 'eq.kos-uuid-1');
    });

    test('fetchById() should return null when listing is not found', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          '',
          200,
          request: request,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = SupabaseClient(supabaseUrl, supabaseKey, httpClient: mockHttpClient);
      final repository = ListingRepository(client: client);

      final result = await repository.fetchById('non-existent-id');

      expect(result, isNull);
    });

    test('fetchById() should throw PostgrestException when database error occurs', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Database connection failed', 'code': 'PGRST'}),
          500,
          request: request,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = SupabaseClient(supabaseUrl, supabaseKey, httpClient: mockHttpClient);
      final repository = ListingRepository(client: client);

      expect(() => repository.fetchById('kos-uuid-1'), throwsA(isA<PostgrestException>()));
    });

    test('fetchAll() should throw informative exception when client is not initialized', () async {
      final repository = ListingRepository();
      expect(
        () => repository.fetchAll(),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Supabase belum terkonfigurasi atau gagal diinisialisasi'),
          ),
        ),
      );
    });

    test('fetchAll() with searchQuery should include or filter in the request URL', () async {
      Uri? capturedUri;

      final mockHttpClient = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          jsonEncode([sampleListingJson1]),
          200,
          request: request,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = SupabaseClient(supabaseUrl, supabaseKey, httpClient: mockHttpClient);
      final repository = ListingRepository(client: client);

      final result = await repository.fetchAll(searchQuery: 'Singaraja');

      expect(result.length, 1);
      expect(capturedUri, isNotNull);
      // Verifikasi bahwa filter OR ilike dikirim sebagai parameter `or`
      final orParam = capturedUri!.queryParameters['or'];
      expect(orParam, isNotNull);
      expect(orParam, contains('ilike'));
      expect(orParam, contains('Singaraja'));
    });

    test('fetchAll() with empty searchQuery should not include or filter', () async {
      Uri? capturedUri;

      final mockHttpClient = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          jsonEncode([sampleListingJson1, sampleListingJson2]),
          200,
          request: request,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = SupabaseClient(supabaseUrl, supabaseKey, httpClient: mockHttpClient);
      final repository = ListingRepository(client: client);

      final result = await repository.fetchAll();

      expect(result.length, 2);
      expect(capturedUri, isNotNull);
      // Tanpa searchQuery tidak ada parameter `or`
      expect(capturedUri!.queryParameters.containsKey('or'), isFalse);
    });

    test(
      'fetchOwnerListings() filters by the authenticated owner id',
      () async {
        Uri? capturedUri;
        final mockHttpClient = MockClient((request) async {
          capturedUri = request.url;
          return http.Response(
            jsonEncode([sampleListingJson1]),
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
        await client.auth.recoverSession(
          jsonEncode({
            'access_token': 'eyJhbGciOiJub25lIn0.eyJleHAiOjE5OTk5OTk5OTl9.x',
            'refresh_token': 'refresh-token',
            'token_type': 'bearer',
            'user': {
              'id': 'owner-uuid-1',
              'aud': 'authenticated',
              'role': 'authenticated',
              'email': 'owner@example.com',
              'created_at': '2026-11-23T10:00:00.000Z',
            },
          }),
        );
        final repository = ListingRepository(client: client);

        final result = await repository.fetchOwnerListings();

        expect(result.single.id, 'kos-uuid-1');
        expect(capturedUri!.queryParameters['owner_id'], 'eq.owner-uuid-1');
        await client.dispose();
      },
    );

    test('createListing() inserts new listing for current owner', () async {
      http.Request? capturedRequest;
      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode(sampleListingJson1),
          201,
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
      await client.auth.recoverSession(
        jsonEncode({
          'access_token': 'eyJhbGciOiJub25lIn0.eyJleHAiOjE5OTk5OTk5OTl9.x',
          'refresh_token': 'refresh-token',
          'token_type': 'bearer',
          'user': {
            'id': 'owner-uuid-1',
            'aud': 'authenticated',
            'role': 'authenticated',
            'email': 'owner@example.com',
            'created_at': '2026-11-23T10:00:00.000Z',
          },
        }),
      );
      final repository = ListingRepository(client: client);

      final result = await repository.createListing(
        name: 'Kos Singaraja Asri',
        pricePerMonth: 850000,
        type: 'Putra',
        address: 'Jl. Udayana No. 10, Singaraja',
        facilities: 'WiFi, Kasur, Lemari',
        whatsappNumber: '6281234567890',
      );

      final payload = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(result.id, 'kos-uuid-1');
      expect(capturedRequest!.url.path, '/rest/v1/listings');
      expect(payload['owner_id'], 'owner-uuid-1');
      expect(payload['price_per_month'], 850000);
      expect(payload['whatsapp_number'], '081234567890');
      await client.dispose();
    });

    test('updateListing() updates only the row matching listing id', () async {
      http.Request? capturedRequest;
      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode(sampleListingJson1),
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
      final repository = ListingRepository(client: client);

      final result = await repository.updateListing(
        Listing.fromJson(sampleListingJson1).copyWith(name: 'Kos Baru'),
      );

      final payload = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(result.id, 'kos-uuid-1');
      expect(capturedRequest!.method, 'PATCH');
      expect(capturedRequest!.url.queryParameters['id'], 'eq.kos-uuid-1');
      expect(
        capturedRequest!.url.queryParameters.containsKey('owner_id'),
        isFalse,
      );
      expect(payload['name'], 'Kos Baru');
      expect(payload.containsKey('owner_id'), isFalse);
      await client.dispose();
    });

    test('deleteListing() deletes only the row matching listing id', () async {
      http.Request? capturedRequest;
      final mockHttpClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 204, request: request);
      });
      final client = SupabaseClient(
        supabaseUrl,
        supabaseKey,
        httpClient: mockHttpClient,
      );
      final repository = ListingRepository(client: client);

      await repository.deleteListing(Listing.fromJson(sampleListingJson1));

      expect(capturedRequest!.method, 'DELETE');
      expect(capturedRequest!.url.queryParameters['id'], 'eq.kos-uuid-1');
      expect(
        capturedRequest!.url.queryParameters.containsKey('owner_id'),
        isFalse,
      );
      await client.dispose();
    });
  });
}
