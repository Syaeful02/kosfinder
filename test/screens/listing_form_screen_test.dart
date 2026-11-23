import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kostfinder/models/listing_model.dart';
import 'package:kostfinder/providers/owner_listing_provider.dart';
import 'package:kostfinder/repositories/listing_repository.dart';
import 'package:kostfinder/screens/owner/listing_form_screen.dart';

class FakeCreateListingRepository extends ListingRepository {
  int createCallCount = 0;
  Map<String, Object>? lastCreatedValues;

  @override
  Future<List<Listing>> fetchOwnerListings() async => [];

  @override
  Future<Listing> createListing({
    required String name,
    required int pricePerMonth,
    required String type,
    required String address,
    required String facilities,
    required String whatsappNumber,
  }) async {
    createCallCount++;
    lastCreatedValues = {
      'name': name,
      'pricePerMonth': pricePerMonth,
      'type': type,
      'address': address,
      'facilities': facilities,
      'whatsappNumber': whatsappNumber,
    };
    return Listing(
      id: 'listing-id',
      ownerId: 'owner-id',
      name: name,
      pricePerMonth: pricePerMonth,
      type: type,
      address: address,
      facilities: facilities,
      whatsappNumber: whatsappNumber,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }
}

Widget createTestApp(FakeCreateListingRepository repository) {
  return ChangeNotifierProvider(
    create: (_) => OwnerListingProvider(repository: repository),
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ListingFormScreen(),
                  ),
                );
              },
              child: const Text('Buka Form'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> openForm(WidgetTester tester) async {
  await tester.tap(find.text('Buka Form'));
  await tester.pumpAndSettle();
}

Future<void> chooseTenantType(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('listing-type')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Putra').last);
  await tester.pumpAndSettle();
}

void main() {
  group('ListingFormScreen', () {
    testWidgets('rejects invalid price and WhatsApp number', (tester) async {
      final repository = FakeCreateListingRepository();
      await tester.pumpWidget(createTestApp(repository));
      await openForm(tester);

      await tester.enterText(find.byKey(const Key('listing-name')), 'Kos Asri');
      await tester.enterText(find.byKey(const Key('listing-price')), 'abc');
      await chooseTenantType(tester);
      await tester.enterText(
        find.byKey(const Key('listing-address')),
        'Jl. Udayana, Singaraja',
      );
      await tester.enterText(
        find.byKey(const Key('listing-facilities')),
        'WiFi dan kasur',
      );
      await tester.enterText(
        find.byKey(const Key('listing-whatsapp')),
        '081234567',
      );
      await tester.ensureVisible(find.text('Simpan Kos'));
      await tester.tap(find.text('Simpan Kos'));
      await tester.pumpAndSettle();

      expect(
        find.text('Masukkan harga berupa angka lebih dari 0'),
        findsOneWidget,
      );
      expect(find.text('Nomor WA harus 10–15 digit angka'), findsOneWidget);
      expect(repository.createCallCount, 0);
    });

    testWidgets('limits facilities to 200 characters and creates listing', (
      tester,
    ) async {
      final repository = FakeCreateListingRepository();
      await tester.pumpWidget(createTestApp(repository));
      await openForm(tester);

      await tester.enterText(find.byKey(const Key('listing-name')), 'Kos Asri');
      await tester.enterText(find.byKey(const Key('listing-price')), '850000');
      await chooseTenantType(tester);
      await tester.enterText(
        find.byKey(const Key('listing-address')),
        'Jl. Udayana, Singaraja',
      );
      await tester.enterText(
        find.byKey(const Key('listing-facilities')),
        'f' * 205,
      );
      await tester.enterText(
        find.byKey(const Key('listing-whatsapp')),
        '081234567890',
      );
      await tester.ensureVisible(find.text('Simpan Kos'));
      await tester.tap(find.text('Simpan Kos'));
      await tester.pumpAndSettle();

      expect(repository.createCallCount, 1);
      expect(repository.lastCreatedValues!['pricePerMonth'], 850000);
      expect(
        (repository.lastCreatedValues!['facilities']! as String).length,
        200,
      );
      expect(repository.lastCreatedValues!['whatsappNumber'], '081234567890');
      expect(find.text('Buka Form'), findsOneWidget);
    });
  });
}
