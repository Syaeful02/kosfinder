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
  Future<List<Listing>> fetchAll() async {
    final response = await _supabaseClient
        .from('listings')
        .select()
        .order('created_at', ascending: false);

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
}
