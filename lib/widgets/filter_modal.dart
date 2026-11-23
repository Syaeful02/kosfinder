import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kostfinder/providers/listing_provider.dart';

/// Modal bottom sheet untuk mengatur filter rentang harga kos.
///
/// Menampilkan dua field input (harga minimum dan maksimum dalam Rupiah).
/// Tombol "Terapkan" menyimpan filter, tombol "Reset" menghapus semua filter.
class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Isi field dengan nilai filter aktif saat ini (jika ada)
    final provider = context.read<ListingProvider>();
    if (provider.minPrice != null) {
      _minPriceController.text = provider.minPrice.toString();
    }
    if (provider.maxPrice != null) {
      _maxPriceController.text = provider.maxPrice.toString();
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  /// Parse teks input menjadi int, kembalikan null jika kosong atau bukan angka.
  int? _parsePrice(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  void _applyFilter() {
    if (!_formKey.currentState!.validate()) return;

    final min = _parsePrice(_minPriceController.text);
    final max = _parsePrice(_maxPriceController.text);

    context.read<ListingProvider>().setPriceRangeFilter(
          minPrice: min,
          maxPrice: max,
        );
    Navigator.pop(context);
  }

  void _resetFilter() {
    context.read<ListingProvider>().clearFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Pastikan modal naik saat keyboard muncul
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Judul
            Text(
              'Filter Harga',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Masukkan rentang harga sewa per bulan (Rupiah)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 20),

            // Field Harga Minimum
            TextFormField(
              controller: _minPriceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Harga Minimum',
                hintText: 'Contoh: 500000',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                final min = _parsePrice(value ?? '');
                final max = _parsePrice(_maxPriceController.text);
                if (min != null && max != null && min > max) {
                  return 'Harga minimum tidak boleh lebih dari maksimum';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Field Harga Maksimum
            TextFormField(
              controller: _maxPriceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Harga Maksimum',
                hintText: 'Contoh: 1500000',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                final min = _parsePrice(_minPriceController.text);
                final max = _parsePrice(value ?? '');
                if (min != null && max != null && min > max) {
                  return 'Harga maksimum tidak boleh kurang dari minimum';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Tombol aksi
            Row(
              children: [
                // Tombol Reset
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilter,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Terapkan
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _applyFilter,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Terapkan Filter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
