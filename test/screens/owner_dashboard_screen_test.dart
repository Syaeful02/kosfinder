import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kostfinder/models/listing_model.dart';
import 'package:kostfinder/providers/auth_provider.dart';
import 'package:kostfinder/providers/owner_listing_provider.dart';
import 'package:kostfinder/repositories/auth_repository.dart';
import 'package:kostfinder/repositories/listing_repository.dart';
import 'package:kostfinder/screens/owner/listing_form_screen.dart';
import 'package:kostfinder/screens/owner/owner_dashboard_screen.dart';

class FakeOwnerDashboardRepository extends ListingRepository {
  @override
  Future<List<Listing>> fetchOwnerListings() async => [
    Listing(
      id: 'listing-id',
      ownerId: 'owner-id',
      name: 'Kos Udayana',
      pricePerMonth: 850000,
      type: 'Putra',
      address: 'Jl. Udayana, Singaraja',
      facilities: 'WiFi',
      whatsappNumber: '081234567890',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  ];
}

class FakeDashboardAuthRepository extends AuthRepository {
  @override
  User? get currentUser => User(
    id: 'owner-id',
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: '2026-11-23T10:00:00.000Z',
  );
}

void main() {
  testWidgets('shows owner listings and opens the create form', (tester) async {
    final ownerListingProvider = OwnerListingProvider(
      repository: FakeOwnerDashboardRepository(),
    );
    final authProvider = AuthProvider(
      repository: FakeDashboardAuthRepository(),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<OwnerListingProvider>.value(
            value: ownerListingProvider,
          ),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: const MaterialApp(home: OwnerDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kos Udayana'), findsOneWidget);
    expect(find.text('Tambah Kos Baru'), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-listing-button')));
    await tester.pumpAndSettle();

    expect(find.byType(ListingFormScreen), findsOneWidget);
  });
}
