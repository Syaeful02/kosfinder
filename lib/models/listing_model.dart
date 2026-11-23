import 'package:intl/intl.dart';

class Listing {
  final String id;
  final String ownerId;
  final String name;
  final int pricePerMonth;
  final String type;
  final String address;
  final String facilities;
  final String whatsappNumber;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Listing({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.pricePerMonth,
    required this.type,
    required this.address,
    required this.facilities,
    required this.whatsappNumber,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      pricePerMonth: (json['price_per_month'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      address: json['address'] as String? ?? '',
      facilities: json['facilities'] as String? ?? '',
      whatsappNumber: json['whatsapp_number'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? (json['created_at'] is DateTime
              ? json['created_at'] as DateTime
              : DateTime.parse(json['created_at'].toString()))
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] is DateTime
              ? json['updated_at'] as DateTime
              : DateTime.parse(json['updated_at'].toString()))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'price_per_month': pricePerMonth,
      'type': type,
      'address': address,
      'facilities': facilities,
      'whatsapp_number': whatsappNumber,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Format harga bulanan ke mata uang Rupiah via intl (contoh: Rp 850.000).
  String get formattedPrice {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(pricePerMonth).trim();
  }

  /// Helper URL WhatsApp berformat https://wa.me/62...
  /// Mengubah nomor awalan 0 menjadi 62, mempertahankan awalan 62,
  /// dan membersihkan karakter non-digit.
  String get whatsAppUrl {
    final cleanDigits = whatsappNumber.replaceAll(RegExp(r'\D'), '');
    String internationalNumber = cleanDigits;
    if (cleanDigits.startsWith('0')) {
      internationalNumber = '62${cleanDigits.substring(1)}';
    } else if (!cleanDigits.startsWith('62')) {
      internationalNumber = '62$cleanDigits';
    }
    return 'https://wa.me/$internationalNumber';
  }

  /// Sanitasi nomor kontak ke format lokal (08...) untuk kebutuhan penyimpanan database.
  static String sanitizeToLocalWhatsAppNumber(String raw) {
    final cleanDigits = raw.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.startsWith('62')) {
      return '0${cleanDigits.substring(2)}';
    }
    return cleanDigits;
  }

  Listing copyWith({
    String? id,
    String? ownerId,
    String? name,
    int? pricePerMonth,
    String? type,
    String? address,
    String? facilities,
    String? whatsappNumber,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Listing(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      type: type ?? this.type,
      address: address ?? this.address,
      facilities: facilities ?? this.facilities,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Listing && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
