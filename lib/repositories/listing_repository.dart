import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kostfinder/models/listing_model.dart';

/// Repository untuk mengelola akses data tabel `listings` di Supabase.
class ListingRepository {
  final SupabaseClient? client;

  ListingRepository({this.client});

  SupabaseClient get _supabaseClient {
    if (client != null) return client!;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw Exception(
        'Supabase belum terkonfigurasi atau gagal diinisialisasi. '
        'Pastikan parameter --dart-define="SUPABASE_URL=..." dan '
        '--dart-define="SUPABASE_ANON_KEY=..." disertakan dengan benar saat menjalankan aplikasi.',
      );
    }
  }

  /// Mengambil seluruh data kos publik, diurutkan secara default berdasarkan `created_at DESC`.
  ///
  /// Jika [searchQuery] diberikan (tidak kosong), query akan menyaring kos
  /// berdasarkan nama atau alamat yang cocok (pencarian `ilike` case-insensitive).
  Future<List<Listing>> fetchAll({String searchQuery = ''}) async {
    var query = _supabaseClient
        .from('listings')
        .select();

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim();
      query = query.or('name.ilike.%$q%,address.ilike.%$q%');
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map((item) => Listing.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Mengambil satu data kos berdasarkan [id].
  /// Mengembalikan `null` jika tidak ditemukan data yang cocok.
  Future<Listing?> fetchById(String id) async {
    final response = await _supabaseClient
        .from('listings')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Listing.fromJson(response);
  }

  /// Mengambil kos milik pengguna yang sedang login.
  Future<List<Listing>> fetchOwnerListings() async {
    final ownerId = _currentOwnerId;
    final response = await _supabaseClient
        .from('listings')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Listing.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Membuat kos baru untuk pengguna yang sedang login.
  Future<Listing> createListing({
    required String name,
    required int pricePerMonth,
    required String type,
    required String address,
    required String facilities,
    required String whatsappNumber,
  }) async {
    final response = await _supabaseClient
        .from('listings')
        .insert({
          'owner_id': _currentOwnerId,
          'name': name,
          'price_per_month': pricePerMonth,
          'type': type,
          'address': address,
          'facilities': facilities,
          'whatsapp_number': Listing.sanitizeToLocalWhatsAppNumber(
            whatsappNumber,
          ),
        })
        .select()
        .single();

    return Listing.fromJson(response);
  }

  /// Memperbarui data kos berdasarkan ID; otorisasi tetap ditegakkan oleh RLS.
  Future<Listing> updateListing(Listing listing) async {
    final response = await _supabaseClient
        .from('listings')
        .update({
          'name': listing.name,
          'price_per_month': listing.pricePerMonth,
          'type': listing.type,
          'address': listing.address,
          'facilities': listing.facilities,
          'whatsapp_number': Listing.sanitizeToLocalWhatsAppNumber(
            listing.whatsappNumber,
          ),
        })
        .eq('id', listing.id)
        .select()
        .single();

    return Listing.fromJson(response);
  }

  /// Menghapus data kos berdasarkan ID; otorisasi tetap ditegakkan oleh RLS.
  Future<void> deleteListing(Listing listing) async {
    await _supabaseClient.from('listings').delete().eq('id', listing.id);
  }

  String get _currentOwnerId {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw StateError('Login diperlukan untuk mengelola kos.');
    }
    return user.id;
  }
}
