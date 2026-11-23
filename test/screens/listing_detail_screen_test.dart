import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kostfinder/models/listing_model.dart';
import 'package:kostfinder/screens/listing_detail_screen.dart';

void main() {
  group('ListingDetailScreen Tests', () {
    final sampleListing = Listing(
      id: 'kos-uuid-detail',
      ownerId: 'owner-uuid-1',
      name: 'Kos Bintang Singaraja',
      pricePerMonth: 950000,
      type: 'Campur',
      address: 'Jl. Dewi Sartika No. 12, Singaraja',
      facilities: 'Kamar mandi dalam, AC 1/2 PK, Lemari pakaian 2 pintu, WiFi super kencang, Dapur bersama, Parkir motor luas',
      whatsappNumber: '081999888777',
      isAvailable: true,
      createdAt: DateTime.parse('2026-11-23T10:00:00Z'),
      updatedAt: DateTime.parse('2026-11-23T10:00:00Z'),
    );

    testWidgets('should display complete details of the listing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ListingDetailScreen(listing: sampleListing),
        ),
      );

      // Verifikasi judul dan nama kos
      expect(find.text('Detail Kos'), findsOneWidget);
      expect(find.text('Kos Bintang Singaraja'), findsOneWidget);

      // Verifikasi tipe dan ketersediaan
      expect(find.text('Campur'), findsOneWidget);
      expect(find.text('Tersedia'), findsOneWidget);

      // Verifikasi harga
      expect(find.textContaining('950.000 / bulan'), findsOneWidget);

      // Verifikasi alamat
      expect(find.text('Jl. Dewi Sartika No. 12, Singaraja'), findsOneWidget);

      // Verifikasi fasilitas lengkap (tidak terpotong)
      expect(find.text(sampleListing.facilities), findsOneWidget);

      // Verifikasi nomor kontak
      expect(find.text('081999888777'), findsOneWidget);

      // Verifikasi tombol aksi
      expect(find.text('Hubungi WhatsApp'), findsOneWidget);
      expect(find.text('Telepon'), findsOneWidget);
    });

    testWidgets('should display "Penuh" badge when isAvailable is false', (tester) async {
      final fullListing = sampleListing.copyWith(isAvailable: false);
      await tester.pumpWidget(
        MaterialApp(
          home: ListingDetailScreen(listing: fullListing),
        ),
      );

      expect(find.text('Penuh'), findsOneWidget);
      expect(find.text('Tersedia'), findsNothing);
    });

    testWidgets('tapping WhatsApp button should trigger URL launcher with correct wa.me link', (tester) async {
      Uri? launchedUri;

      await tester.pumpWidget(
        MaterialApp(
          home: ListingDetailScreen(
            listing: sampleListing,
            urlLauncher: (uri) async {
              launchedUri = uri;
              return true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Hubungi WhatsApp'));
      await tester.pumpAndSettle();

      expect(launchedUri, isNotNull);
      expect(launchedUri.toString(), 'https://wa.me/6281999888777');
    });

    testWidgets('tapping Telepon button should trigger URL launcher with tel scheme', (tester) async {
      Uri? launchedUri;

      await tester.pumpWidget(
        MaterialApp(
          home: ListingDetailScreen(
            listing: sampleListing,
            urlLauncher: (uri) async {
              launchedUri = uri;
              return true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Telepon'));
      await tester.pumpAndSettle();

      expect(launchedUri, isNotNull);
      expect(launchedUri.toString(), 'tel:081999888777');
    });

    testWidgets('should show SnackBar when launcher returns false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ListingDetailScreen(
            listing: sampleListing,
            urlLauncher: (uri) async => false,
          ),
        ),
      );

      await tester.tap(find.text('Hubungi WhatsApp'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Tidak dapat membuka'), findsOneWidget);
    });
  });
}
