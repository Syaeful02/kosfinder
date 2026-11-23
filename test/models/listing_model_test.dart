import 'package:flutter_test/flutter_test.dart';
import 'package:kostfinder/models/listing_model.dart';

void main() {
  group('Listing Model Tests', () {
    final now = DateTime.parse('2026-11-23T10:00:00Z');
    final sampleJson = {
      'id': '11111111-2222-3333-4444-555555555555',
      'owner_id': '99999999-8888-7777-6666-555555555555',
      'name': 'Kos Singaraja Asri',
      'price_per_month': 850000,
      'type': 'Putra',
      'address': 'Jl. Udayana No. 10, Singaraja',
      'facilities': 'WiFi, Kasur, Lemari, Kamar Mandi Dalam',
      'whatsapp_number': '081234567890',
      'is_available': true,
      'created_at': '2026-11-23T10:00:00.000Z',
      'updated_at': '2026-11-23T10:00:00.000Z',
    };

    test('should correctly parse from JSON', () {
      final listing = Listing.fromJson(sampleJson);

      expect(listing.id, '11111111-2222-3333-4444-555555555555');
      expect(listing.ownerId, '99999999-8888-7777-6666-555555555555');
      expect(listing.name, 'Kos Singaraja Asri');
      expect(listing.pricePerMonth, 850000);
      expect(listing.type, 'Putra');
      expect(listing.address, 'Jl. Udayana No. 10, Singaraja');
      expect(listing.facilities, 'WiFi, Kasur, Lemari, Kamar Mandi Dalam');
      expect(listing.whatsappNumber, '081234567890');
      expect(listing.isAvailable, true);
      expect(listing.createdAt, DateTime.parse('2026-11-23T10:00:00.000Z'));
      expect(listing.updatedAt, DateTime.parse('2026-11-23T10:00:00.000Z'));
    });

    test('should correctly serialize to JSON', () {
      final listing = Listing(
        id: '11111111-2222-3333-4444-555555555555',
        ownerId: '99999999-8888-7777-6666-555555555555',
        name: 'Kos Singaraja Asri',
        pricePerMonth: 850000,
        type: 'Putra',
        address: 'Jl. Udayana No. 10, Singaraja',
        facilities: 'WiFi, Kasur, Lemari',
        whatsappNumber: '081234567890',
        isAvailable: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = listing.toJson();

      expect(json['id'], '11111111-2222-3333-4444-555555555555');
      expect(json['owner_id'], '99999999-8888-7777-6666-555555555555');
      expect(json['name'], 'Kos Singaraja Asri');
      expect(json['price_per_month'], 850000);
      expect(json['type'], 'Putra');
      expect(json['address'], 'Jl. Udayana No. 10, Singaraja');
      expect(json['facilities'], 'WiFi, Kasur, Lemari');
      expect(json['whatsapp_number'], '081234567890');
      expect(json['is_available'], true);
      expect(json['created_at'], now.toIso8601String());
      expect(json['updated_at'], now.toIso8601String());
    });

    test('should format price to Indonesian Rupiah via intl', () {
      final listing = Listing(
        id: '1',
        ownerId: 'owner-1',
        name: 'Kos Murah',
        pricePerMonth: 750000,
        type: 'Campur',
        address: 'Singaraja',
        facilities: 'Kasur',
        whatsappNumber: '081234567890',
        createdAt: now,
        updatedAt: now,
      );

      expect(listing.formattedPrice, contains('750.000'));
      expect(listing.formattedPrice, startsWith('Rp'));

      final expensiveListing = listing.copyWith(pricePerMonth: 1250000);
      expect(expensiveListing.formattedPrice, contains('1.250.000'));
      expect(expensiveListing.formattedPrice, startsWith('Rp'));
    });

    test('should generate correct WhatsApp URL format https://wa.me/62...', () {
      // Skenario 1: Nomor diawali 0
      final listingWith0 = Listing(
        id: '1',
        ownerId: 'owner-1',
        name: 'Kos 1',
        pricePerMonth: 500000,
        type: 'Putri',
        address: 'Alamat',
        facilities: 'Fasilitas',
        whatsappNumber: '081234567890',
        createdAt: now,
        updatedAt: now,
      );
      expect(listingWith0.whatsAppUrl, 'https://wa.me/6281234567890');

      // Skenario 2: Nomor sudah diawali 62
      final listingWith62 = listingWith0.copyWith(whatsappNumber: '6281234567890');
      expect(listingWith62.whatsAppUrl, 'https://wa.me/6281234567890');

      // Skenario 3: Nomor dengan format mengandung simbol dan spasi
      final listingWithSymbols = listingWith0.copyWith(whatsappNumber: '+62 812-3456-7890');
      expect(listingWithSymbols.whatsAppUrl, 'https://wa.me/6281234567890');

      // Skenario 4: Nomor tanpa awalan 0 atau 62 (misal 812...)
      final listingWithoutPrefix = listingWith0.copyWith(whatsappNumber: '81234567890');
      expect(listingWithoutPrefix.whatsAppUrl, 'https://wa.me/6281234567890');
    });

    test('should sanitize phone number to local 08... format for database storage', () {
      expect(Listing.sanitizeToLocalWhatsAppNumber('6281234567890'), '081234567890');
      expect(Listing.sanitizeToLocalWhatsAppNumber('+62 812-3456-7890'), '081234567890');
      expect(Listing.sanitizeToLocalWhatsAppNumber('081234567890'), '081234567890');
    });

    test('should support copyWith and value comparison', () {
      final listing1 = Listing.fromJson(sampleJson);
      final listing2 = listing1.copyWith(name: 'Nama Baru', isAvailable: false);

      expect(listing2.id, listing1.id);
      expect(listing2.name, 'Nama Baru');
      expect(listing2.isAvailable, false);
      expect(listing1 == listing2, true); // Identical by ID
    });
  });
}
