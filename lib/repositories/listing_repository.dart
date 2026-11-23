import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kostfinder/models/listing_model.dart';

/// Repository untuk mengelola akses data tabel `listings` di Supabase.
class ListingRepository {
  final SupabaseClient? client;

  ListingRepository({this.client});

  SupabaseClient get _supabaseClient => client ?? Supabase.instance.client;

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
