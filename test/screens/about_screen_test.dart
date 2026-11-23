import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kostfinder/models/listing_model.dart';
import 'package:kostfinder/providers/listing_provider.dart';
import 'package:kostfinder/repositories/listing_repository.dart';
import 'package:kostfinder/screens/about_screen.dart';
import 'package:kostfinder/screens/home_screen.dart';

class MockListingRepo extends ListingRepository {
  @override
  @override
  Future<List<Listing>> fetchAll({String searchQuery = ''}) async => [];
}

void main() {
  group('AboutScreen Tests', () {
    testWidgets('should display exact developer identity 2415051059 - Syaeful Darmawan', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      // Verifikasi judul AppBar
      expect(find.text('Tentang Aplikasi'), findsOneWidget);

      // Verifikasi identitas pengembang secara persis sesuai ketentuan AGENTS.md 7
      expect(find.text('2415051059 - Syaeful Darmawan'), findsOneWidget);

      // Verifikasi nama aplikasi dan deskripsi
      expect(find.text('KosFinder'), findsOneWidget);
      expect(find.textContaining('platform pencarian kos'), findsOneWidget);
    });

    testWidgets('tapping info button on HomeScreen AppBar should navigate to AboutScreen', (tester) async {
      final provider = ListingProvider(repository: MockListingRepo());

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ListingProvider>.value(
            value: provider,
            child: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Cari tombol info pada AppBar
      final infoButtonFinder = find.byTooltip('Tentang Aplikasi');
      expect(infoButtonFinder, findsOneWidget);

      // Tap tombol info
      await tester.tap(infoButtonFinder);
      await tester.pumpAndSettle();

      // Memastikan navigasi ke AboutScreen berhasil
      expect(find.text('Tentang Aplikasi'), findsOneWidget);
      expect(find.text('2415051059 - Syaeful Darmawan'), findsOneWidget);
    });
  });
}
