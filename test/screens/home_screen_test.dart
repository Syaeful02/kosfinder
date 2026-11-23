import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kostfinder/models/listing_model.dart';
import 'package:kostfinder/providers/listing_provider.dart';
import 'package:kostfinder/repositories/listing_repository.dart';
import 'package:kostfinder/screens/home_screen.dart';
import 'package:kostfinder/widgets/listing_card.dart';

class MockListingRepository extends ListingRepository {
  final Future<List<Listing>> Function() onFetchAll;

  MockListingRepository({required this.onFetchAll});

  @override
  Future<List<Listing>> fetchAll({
    String searchQuery = '',
    int? minPrice,
    int? maxPrice,
  }) => onFetchAll();
}

void main() {
  group('HomeScreen & ListingCard Widget Tests', () {
    final sampleListing = Listing(
      id: 'kos-uuid-1',
      ownerId: 'owner-uuid-1',
      name: 'Kos Udayana Asri',
      pricePerMonth: 850000,
      type: 'Putra',
      address: 'Jl. Udayana No. 10, Singaraja',
      facilities: 'WiFi kencang, Kasur busa tebal, Lemari pakaian 2 pintu, Meja belajar, Kamar mandi dalam dengan shower',
      whatsappNumber: '081234567890',
      isAvailable: true,
      createdAt: DateTime.parse('2026-11-23T10:00:00Z'),
      updatedAt: DateTime.parse('2026-11-23T10:00:00Z'),
    );

    Widget createTestWidget(ListingProvider provider) {
      return MaterialApp(
        home: ChangeNotifierProvider<ListingProvider>.value(
          value: provider,
          child: const HomeScreen(),
        ),
      );
    }

    testWidgets('should display CircularProgressIndicator while loading', (tester) async {
      final completer = Completer<List<Listing>>();
      final repository = MockListingRepository(onFetchAll: () => completer.future);
      final provider = ListingProvider(repository: repository);

      await tester.pumpWidget(createTestWidget(provider));
      // Trigger frame awal setelah addPostFrameCallback
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([sampleListing]);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Kos Udayana Asri'), findsOneWidget);
    });

    testWidgets('should display error message and "Coba Lagi" button on error', (tester) async {
      int fetchCallCount = 0;
      final repository = MockListingRepository(
        onFetchAll: () async {
          fetchCallCount++;
          throw Exception('Koneksi internet terputus');
        },
      );
      final provider = ListingProvider(repository: repository);

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.textContaining('Koneksi internet terputus'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Tekan tombol Coba Lagi
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(fetchCallCount, 2);
    });

    testWidgets('should display "Tidak ada kos" when listing data is empty', (tester) async {
      final repository = MockListingRepository(onFetchAll: () async => []);
      final provider = ListingProvider(repository: repository);

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada kos'), findsOneWidget);
      expect(find.byType(ListingCard), findsNothing);
    });

    testWidgets('should display ListingCard with correct details and truncated facilities', (tester) async {
      final fullListing = sampleListing.copyWith(isAvailable: false);
      final repository = MockListingRepository(onFetchAll: () async => [fullListing]);
      final provider = ListingProvider(repository: repository);

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Cek nama kos
      expect(find.text('Kos Udayana Asri'), findsOneWidget);

      // Cek harga berformat Rupiah
      expect(find.textContaining('850.000 / bulan'), findsOneWidget);

      // Cek tipe kos
      expect(find.text('Putra'), findsOneWidget);

      // Cek badge Penuh
      expect(find.text('Penuh'), findsOneWidget);

      // Cek alamat
      expect(find.text('Jl. Udayana No. 10, Singaraja'), findsOneWidget);

      // Cek pemotongan teks fasilitas (maxLines: 2, overflow: ellipsis)
      final facilitiesTextFinder = find.text(fullListing.facilities);
      expect(facilitiesTextFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(facilitiesTextFinder);
      expect(textWidget.maxLines, 2);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('tapping ListingCard should navigate to ListingDetailScreen', (tester) async {
      final repository = MockListingRepository(onFetchAll: () async => [sampleListing]);
      final provider = ListingProvider(repository: repository);

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Tap kartu kos
      await tester.tap(find.byType(ListingCard));
      await tester.pumpAndSettle();

      // Memastikan navigasi berhasil ke ListingDetailScreen
      expect(find.text('Detail Kos'), findsOneWidget);
      expect(find.text('Hubungi WhatsApp'), findsOneWidget);
      expect(find.text('Telepon'), findsOneWidget);
    });
  });
}
