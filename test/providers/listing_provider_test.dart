import 'package:flutter_test/flutter_test.dart';
import 'package:kostfinder/models/listing_model.dart';
import 'package:kostfinder/providers/listing_provider.dart';
import 'package:kostfinder/repositories/listing_repository.dart';

class FakeListingRepository extends ListingRepository {
  List<Listing> fakeListings;
  Exception? errorToThrow;
  Listing? fakeListingById;
  String? lastSearchQuery;

  FakeListingRepository({
    this.fakeListings = const [],
    this.errorToThrow,
    this.fakeListingById,
  });

  @override
  Future<List<Listing>> fetchAll({String searchQuery = ''}) async {
    lastSearchQuery = searchQuery;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    if (searchQuery.trim().isEmpty) return fakeListings;
    // Simulasi filter case-insensitive pada nama / alamat
    final q = searchQuery.trim().toLowerCase();
    return fakeListings
        .where((l) =>
            l.name.toLowerCase().contains(q) ||
            l.address.toLowerCase().contains(q))
        .toList();
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
    final listing1 = Listing(
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

    final listing2 = Listing(
      id: 'kos-uuid-2',
      ownerId: 'owner-uuid-2',
      name: 'Kos Harmony',
      pricePerMonth: 700000,
      type: 'Putri',
      address: 'Jl. Ahmad Yani No. 5, Buleleng',
      facilities: 'AC, Kasur',
      whatsappNumber: '089876543210',
      isAvailable: true,
      createdAt: DateTime.parse('2026-11-22T08:00:00Z'),
      updatedAt: DateTime.parse('2026-11-22T08:00:00Z'),
    );

    test('initial state should be idle and empty', () {
      final repository = FakeListingRepository();
      final provider = ListingProvider(repository: repository);

      expect(provider.listings, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.hasError, isFalse);
      expect(provider.isEmpty, isTrue);
      expect(provider.searchQuery, '');
    });

    test('fetchListings() success should update listings and notify listeners', () async {
      final repository = FakeListingRepository(fakeListings: [listing1]);
      final provider = ListingProvider(repository: repository);

      final states = <bool>[];
      provider.addListener(() {
        states.add(provider.isLoading);
      });

      await provider.fetchListings();

      expect(states, [true, false]);
      expect(provider.listings.length, 1);
      expect(provider.listings.first.id, 'kos-uuid-1');
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.isEmpty, isFalse);
    });

    test('fetchListings() empty result should set isEmpty to true without error', () async {
      final repository = FakeListingRepository(fakeListings: []);
      final provider = ListingProvider(repository: repository);

      await provider.fetchListings();

      expect(provider.listings, isEmpty);
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
      expect(provider.errorMessage, contains('Gagal menghubungi server database'));
      expect(provider.hasError, isTrue);
      expect(provider.isEmpty, isFalse);
    });

    test('fetchListings() retry after error should clear errorMessage on success', () async {
      final repository = FakeListingRepository(
        errorToThrow: Exception('Koneksi terputus'),
      );
      final provider = ListingProvider(repository: repository);

      await provider.fetchListings();
      expect(provider.hasError, isTrue);

      repository.errorToThrow = null;
      repository.fakeListings = [listing1];

      await provider.fetchListings();

      expect(provider.hasError, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.listings.length, 1);
    });

    test('setSearchQuery() should update searchQuery and trigger fetchAll with query', () async {
      final repository = FakeListingRepository(fakeListings: [listing1, listing2]);
      final provider = ListingProvider(repository: repository);

      // Cari berdasarkan nama
      await provider.setSearchQuery('Asri');

      expect(provider.searchQuery, 'Asri');
      expect(repository.lastSearchQuery, 'Asri');
      expect(provider.listings.length, 1);
      expect(provider.listings.first.id, 'kos-uuid-1');
    });

    test('setSearchQuery() should return matching results case-insensitively', () async {
      final repository = FakeListingRepository(fakeListings: [listing1, listing2]);
      final provider = ListingProvider(repository: repository);

      // Cari dengan huruf kecil — harus tetap menemukan (case-insensitive)
      await provider.setSearchQuery('harmony');

      expect(provider.listings.length, 1);
      expect(provider.listings.first.id, 'kos-uuid-2');
    });

    test('setSearchQuery() should match results by address', () async {
      final repository = FakeListingRepository(fakeListings: [listing1, listing2]);
      final provider = ListingProvider(repository: repository);

      // Cari berdasarkan alamat
      await provider.setSearchQuery('Buleleng');

      expect(provider.listings.length, 1);
      expect(provider.listings.first.id, 'kos-uuid-2');
    });

    test('clearSearch() should reset searchQuery and reload all listings', () async {
      final repository = FakeListingRepository(fakeListings: [listing1, listing2]);
      final provider = ListingProvider(repository: repository);

      await provider.setSearchQuery('Harmony');
      expect(provider.listings.length, 1);
      expect(provider.searchQuery, 'Harmony');

      await provider.clearSearch();

      expect(provider.searchQuery, '');
      expect(repository.lastSearchQuery, '');
      expect(provider.listings.length, 2);
    });

    test('setSearchQuery() with no matching results should set isEmpty', () async {
      final repository = FakeListingRepository(fakeListings: [listing1, listing2]);
      final provider = ListingProvider(repository: repository);

      await provider.setSearchQuery('xyznotfound');

      expect(provider.listings, isEmpty);
      expect(provider.hasError, isFalse);
      expect(provider.isEmpty, isTrue);
    });

    test('getListingById() should delegate to repository.fetchById()', () async {
      final repository = FakeListingRepository(fakeListingById: listing1);
      final provider = ListingProvider(repository: repository);

      final result = await provider.getListingById('kos-uuid-1');

      expect(result, isNotNull);
      expect(result!.id, 'kos-uuid-1');
    });
  });
}
