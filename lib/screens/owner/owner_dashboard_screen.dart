import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kostfinder/providers/auth_provider.dart';
import 'package:kostfinder/providers/owner_listing_provider.dart';
import 'package:kostfinder/models/listing_model.dart';
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

  void _openListingForm([Listing? listing]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ListingFormScreen(listing: listing),
      ),
    );
  }

  Future<void> _confirmDelete(Listing listing) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kos?'),
        content: Text('Kos "${listing.name}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    await context.read<OwnerListingProvider>().deleteListing(listing);
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
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(listing.name),
                            subtitle: Text(
                              '${listing.formattedPrice} / bulan | ${listing.type}\n'
                              '${listing.address}',
                            ),
                            isThreeLine: true,
                          ),
                          SwitchListTile(
                            key: Key('availability-switch-${listing.id}'),
                            title: Text(
                              listing.isAvailable ? 'Tersedia' : 'Penuh',
                            ),
                            value: listing.isAvailable,
                            onChanged: provider.isLoading
                                ? null
                                : (value) {
                                    provider.updateAvailability(
                                      listing.id,
                                      value,
                                    );
                                  },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 8,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  key: Key('edit-listing-${listing.id}'),
                                  onPressed: () => _openListingForm(listing),
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Edit'),
                                ),
                                TextButton.icon(
                                  key: Key('delete-listing-${listing.id}'),
                                  onPressed: () => _confirmDelete(listing),
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Hapus'),
                                ),
                              ],
                            ),
                          ),
                        ],
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
