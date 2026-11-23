import 'package:flutter/material.dart';

/// Halaman Tentang Aplikasi (About) yang memuat informasi aplikasi dan identitas pengembang.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Logo / Ikon Aplikasi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_work_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Nama Aplikasi & Versi
            Text(
              'KosFinder',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Versi 1.0.0 (MVP)',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Kartu Identitas Pengembang (Sesuai AGENTS.md Bagian 7)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Pengembang / Pemilik Proyek',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '2415051059 - Syaeful Darmawan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Deskripsi Aplikasi
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tentang KosFinder',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KosFinder adalah platform pencarian kos yang transparan, ringan, dan bebas iklan untuk mahasiswa serta pekerja di Singaraja, sekaligus sarana promosi online yang mudah dan mandiri bagi pemilik kos.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Info Teknologi
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.bolt, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dibangun menggunakan Flutter & Supabase (PostgreSQL dengan Row Level Security).',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
