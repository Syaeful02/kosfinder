import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kostfinder/providers/auth_provider.dart';
import 'package:kostfinder/providers/owner_listing_provider.dart';
import 'package:kostfinder/screens/owner/listing_form_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OwnerListingProvider>().fetchOwnerListings();
      }
    });
  }

  Future<void> _signOut(BuildContext context) async {
    final success = await context.read<AuthProvider>().signOut();
    if (!context.mounted || !success) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _openListingForm() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ListingFormScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Pemilik')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('add-listing-button'),
                onPressed: _openListingForm,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Kos Baru'),
              ),
            ),
          ),
          Expanded(
            child: Consumer<OwnerListingProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: provider.fetchOwnerListings,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (provider.ownerListings.isEmpty) {
                  return const Center(
                    child: Text('Belum ada kos yang ditambahkan'),
                  );
                }
                return ListView.builder(
                  itemCount: provider.ownerListings.length,
                  itemBuilder: (context, index) {
                    final listing = provider.ownerListings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(listing.name),
                        subtitle: Text(
                          '${listing.formattedPrice} / bulan | ${listing.type}\n'
                          '${listing.address}',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Consumer<AuthProvider>(
            builder: (context, provider, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () => _signOut(context),
                  child: provider.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Logout'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
