import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kostfinder/models/listing_model.dart';
import 'package:kostfinder/providers/listing_provider.dart';
import 'package:kostfinder/repositories/listing_repository.dart';
import 'package:kostfinder/screens/home_screen.dart';

class DelayedListingRepository extends ListingRepository {
  final Future<List<Listing>> future;

  DelayedListingRepository(this.future);

  @override
  Future<List<Listing>> fetchAll() => future;
}

void main() {
  testWidgets('HomeScreen displays loading indicator when state is loading', (WidgetTester tester) async {
    final completer = Completer<List<Listing>>();
    final provider = ListingProvider(repository: DelayedListingRepository(completer.future));

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ListingProvider>.value(
          value: provider,
          child: const HomeScreen(),
        ),
      ),
    );

    // Trigger frame setelah addPostFrameCallback
    await tester.pump();

    // Verifikasi bahwa CircularProgressIndicator muncul saat status loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete([]);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
