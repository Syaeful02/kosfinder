import 'package:flutter_test/flutter_test.dart';
import 'package:kostfinder/models/listing_model.dart';
import 'package:kostfinder/providers/owner_listing_provider.dart';
import 'package:kostfinder/repositories/listing_repository.dart';

class FakeOwnerListingRepository extends ListingRepository {
  final List<Listing> storedListings;
  int fetchCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;

  FakeOwnerListingRepository(this.storedListings);

  @override
  Future<List<Listing>> fetchOwnerListings() async {
    fetchCalls++;
    return List<Listing>.from(storedListings);
  }

  @override
  Future<Listing> updateListing(Listing listing) async {
    updateCalls++;
    final index = storedListings.indexWhere((item) => item.id == listing.id);
    if (index >= 0) storedListings[index] = listing;
    return listing;
  }

  @override
  Future<void> deleteListing(Listing listing) async {
    deleteCalls++;
    storedListings.removeWhere((item) => item.id == listing.id);
  }
}

void main() {
  final listing = Listing(
    id: 'listing-id',
    ownerId: 'owner-id',
    name: 'Kos Lama',
    pricePerMonth: 800000,
    type: 'Putra',
    address: 'Jl. Udayana',
    facilities: 'WiFi',
    whatsappNumber: '081234567890',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test(
    'updateListing refreshes owner listings after repository update',
    () async {
      final repository = FakeOwnerListingRepository([listing]);
      final provider = OwnerListingProvider(repository: repository);
      await provider.fetchOwnerListings();

      final success = await provider.updateListing(
        listing.copyWith(name: 'Kos Baru'),
      );

      expect(success, isTrue);
      expect(repository.updateCalls, 1);
      expect(repository.fetchCalls, 2);
      expect(provider.ownerListings.single.name, 'Kos Baru');
      expect(provider.errorMessage, isNull);
    },
  );

  test(
    'deleteListing refreshes owner listings after repository deletion',
    () async {
      final repository = FakeOwnerListingRepository([listing]);
      final provider = OwnerListingProvider(repository: repository);
      await provider.fetchOwnerListings();

      final success = await provider.deleteListing(listing);

      expect(success, isTrue);
      expect(repository.deleteCalls, 1);
      expect(repository.fetchCalls, 2);
      expect(provider.ownerListings, isEmpty);
      expect(provider.errorMessage, isNull);
    },
  );
}
