import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kostfinder/providers/owner_listing_provider.dart';

class ListingFormScreen extends StatefulWidget {
  const ListingFormScreen({super.key});

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _facilitiesController = TextEditingController();
  final _whatsappController = TextEditingController();
  String? _type;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _facilitiesController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  String? _requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  String? _validatePrice(String? value) {
    final price = int.tryParse(value ?? '');
    if (price == null || price <= 0) {
      return 'Masukkan harga berupa angka lebih dari 0';
    }
    return null;
  }

  String? _validateFacilities(String? value) {
    final facilities = value?.trim() ?? '';
    if (facilities.isEmpty) return 'Fasilitas wajib diisi';
    if (facilities.length > 200) return 'Fasilitas maksimal 200 karakter';
    return null;
  }

  String? _validateWhatsapp(String? value) {
    final number = value ?? '';
    if (!RegExp(r'^\d{10,15}$').hasMatch(number)) {
      return 'Nomor WA harus 10–15 digit angka';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<OwnerListingProvider>().createListing(
      name: _nameController.text.trim(),
      pricePerMonth: int.parse(_priceController.text),
      type: _type!,
      address: _addressController.text.trim(),
      facilities: _facilitiesController.text.trim(),
      whatsappNumber: _whatsappController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kos Baru')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('listing-name'),
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Kos'),
              validator: (value) => _requiredText(value, 'Nama kos'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('listing-price'),
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Harga per Bulan',
                prefixText: 'Rp ',
              ),
              validator: _validatePrice,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('listing-type'),
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipe Penghuni'),
              items: const [
                DropdownMenuItem(value: 'Putra', child: Text('Putra')),
                DropdownMenuItem(value: 'Putri', child: Text('Putri')),
                DropdownMenuItem(value: 'Campur', child: Text('Campur')),
              ],
              onChanged: (value) => setState(() => _type = value),
              validator: (value) =>
                  value == null ? 'Tipe penghuni wajib dipilih' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('listing-address'),
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Alamat'),
              validator: (value) => _requiredText(value, 'Alamat'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('listing-facilities'),
              controller: _facilitiesController,
              maxLength: 200,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Fasilitas'),
              validator: _validateFacilities,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('listing-whatsapp'),
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              decoration: const InputDecoration(labelText: 'Nomor WhatsApp'),
              validator: _validateWhatsapp,
            ),
            Consumer<OwnerListingProvider>(
              builder: (context, provider, _) {
                if (provider.errorMessage == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Consumer<OwnerListingProvider>(
              builder: (context, provider, _) => ElevatedButton(
                onPressed: provider.isLoading ? null : _submit,
                child: provider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Simpan Kos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
