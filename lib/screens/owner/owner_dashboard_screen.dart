import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kostfinder/providers/auth_provider.dart';

/// Placeholder dashboard autentikasi hingga fitur manajemen kos dikerjakan.
class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final success = await context.read<AuthProvider>().signOut();
    if (!context.mounted || !success) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Pemilik')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dashboard Pemilik'),
            const SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, provider, _) => ElevatedButton(
                onPressed: provider.isLoading ? null : () => _signOut(context),
                child: provider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Logout'),
              ),
            ),
            Consumer<AuthProvider>(
              builder: (context, provider, _) {
                if (provider.errorMessage == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
