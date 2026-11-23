import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kostfinder/providers/listing_provider.dart';
import 'package:kostfinder/screens/listing_detail_screen.dart';
import 'package:kostfinder/widgets/listing_card.dart';

/// Halaman utama (Beranda) publik untuk menampilkan daftar kos.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Memanggil fetchListings() saat layar pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ListingProvider>().fetchListings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KosFinder Singaraja'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ListingProvider>(
        builder: (context, provider, child) {
          // 1. Kondisi Loading (Indikator Putar)
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 2. Kondisi Error (Pesan kesalahan + tombol Coba Lagi)
          if (provider.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      provider.errorMessage ?? 'Terjadi kesalahan saat memuat data.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchListings(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Kondisi Empty (Pesan "Tidak ada kos")
          if (provider.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchListings(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Tidak ada kos',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          // 4. Kondisi Sukses (Daftar Kartu Kos)
          return RefreshIndicator(
            onRefresh: () => provider.fetchListings(),
            child: ListView.builder(
              itemCount: provider.listings.length,
              itemBuilder: (context, index) {
                final listing = provider.listings[index];
                return ListingCard(
                  listing: listing,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListingDetailScreen(listing: listing),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
