import 'package:flutter_test/flutter_test.dart';
import 'package:kostfinder/models/listing_model.dart';
import 'package:kostfinder/providers/listing_provider.dart';
import 'package:kostfinder/repositories/listing_repository.dart';

class FakeListingRepository extends ListingRepository {
  List<Listing> fakeListings;
  Exception? errorToThrow;
  Listing? fakeListingById;

  FakeListingRepository({
    this.fakeListings = const [],
    this.errorToThrow,
    this.fakeListingById,
  });

  @override
  Future<List<Listing>> fetchAll() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return fakeListings;
  }

  @override
  Future<Listing?> fetchById(String id) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return fakeListingById;
  }
}

void main() {
  group('ListingProvider Tests', () {
    final sampleListing = Listing(
      id: 'kos-uuid-1',
      ownerId: 'owner-uuid-1',
      name: 'Kos Asri Singaraja',
      pricePerMonth: 850000,
      type: 'Putra',
      address: 'Jl. Udayana No. 10',
      facilities: 'WiFi, Kasur',
      whatsappNumber: '081234567890',
      isAvailable: true,
      createdAt: DateTime.parse('2026-11-23T10:00:00Z'),
      updatedAt: DateTime.parse('2026-11-23T10:00:00Z'),
    );

    test('initial state should be idle and empty', () {
      final repository = FakeListingRepository();
      final provider = ListingProvider(repository: repository);

      expect(provider.listings, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.hasError, isFalse);
      expect(provider.isEmpty, isTrue);
    });

    test('fetchListings() success should update listings and notify listeners', () async {
      final repository = FakeListingRepository(fakeListings: [sampleListing]);
      final provider = ListingProvider(repository: repository);

      final states = <bool>[];
      provider.addListener(() {
        states.add(provider.isLoading);
      });

      await provider.fetchListings();

      expect(states, [true, false]); // Transisi loading state
      expect(provider.listings.length, 1);
      expect(provider.listings.first.id, 'kos-uuid-1');
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.hasError, isFalse);
      expect(provider.isEmpty, isFalse);
    });

    test('fetchListings() empty result should set isEmpty to true without error', () async {
      final repository = FakeListingRepository(fakeListings: []);
      final provider = ListingProvider(repository: repository);

      await provider.fetchListings();

      expect(provider.listings, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.hasError, isFalse);
      expect(provider.isEmpty, isTrue);
    });

    test('fetchListings() failure should set errorMessage and hasError', () async {
      final repository = FakeListingRepository(
        errorToThrow: Exception('Gagal menghubungi server database'),
      );
      final provider = ListingProvider(repository: repository);

      await provider.fetchListings();

      expect(provider.listings, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Gagal menghubungi server database'));
      expect(provider.hasError, isTrue);
      expect(provider.isEmpty, isFalse); // Error state bukan kondisi empty biasa
    });

    test('fetchListings() retry after error should clear errorMessage on success', () async {
      final repository = FakeListingRepository(
        errorToThrow: Exception('Koneksi terputus'),
      );
      final provider = ListingProvider(repository: repository);

      await provider.fetchListings();
      expect(provider.hasError, isTrue);

      // Simulasi koneksi pulih
      repository.errorToThrow = null;
      repository.fakeListings = [sampleListing];

      await provider.fetchListings();

      expect(provider.hasError, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.listings.length, 1);
    });

    test('getListingById() should delegate to repository.fetchById()', () async {
      final repository = FakeListingRepository(fakeListingById: sampleListing);
      final provider = ListingProvider(repository: repository);

      final result = await provider.getListingById('kos-uuid-1');

      expect(result, isNotNull);
      expect(result!.id, 'kos-uuid-1');
      expect(result.name, 'Kos Asri Singaraja');
    });
  });
}
