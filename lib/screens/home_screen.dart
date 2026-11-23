import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kostfinder/providers/auth_provider.dart';
import 'package:kostfinder/providers/listing_provider.dart';
import 'package:kostfinder/screens/about_screen.dart';
import 'package:kostfinder/screens/auth/login_screen.dart';
import 'package:kostfinder/screens/listing_detail_screen.dart';
import 'package:kostfinder/screens/owner/owner_dashboard_screen.dart';
import 'package:kostfinder/widgets/listing_card.dart';

/// Halaman utama (Beranda) publik untuk menampilkan daftar kos.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ListingProvider>().fetchListings();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KosFinder Singaraja'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<AuthProvider?>(
            builder: (context, authProvider, _) {
              final isAuthenticated = authProvider?.isAuthenticated ?? false;
              return IconButton(
                icon: Icon(
                  isAuthenticated ? Icons.account_circle : Icons.login,
                ),
                tooltip: isAuthenticated ? 'Dashboard Pemilik' : 'Login Pemilik',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => isAuthenticated
                          ? const OwnerDashboardScreen()
                          : const LoginScreen(),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang Aplikasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari nama kos atau lokasi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Consumer<ListingProvider>(
                  builder: (context, provider, _) {
                    if (provider.searchQuery.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Hapus pencarian',
                      onPressed: () {
                        _searchController.clear();
                        context.read<ListingProvider>().clearSearch();
                      },
                    );
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onSubmitted: (value) {
                context.read<ListingProvider>().setSearchQuery(value);
              },
              onChanged: (value) {
                if (value.isEmpty) {
                  context.read<ListingProvider>().clearSearch();
                }
              },
            ),
          ),

          // Daftar Kos
          Expanded(
            child: Consumer<ListingProvider>(
              builder: (context, provider, child) {
                // 1. Kondisi Loading
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Kondisi Error
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

                // 3. Kondisi Empty
                if (provider.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchListings(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text(
                            provider.searchQuery.isNotEmpty
                                ? 'Kos "${provider.searchQuery}" tidak ditemukan'
                                : 'Tidak ada kos',
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // 4. Kondisi Sukses
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
          ),
        ],
      ),
    );
  }
}
