import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository untuk operasi autentikasi pemilik melalui Supabase Auth.
class AuthRepository {
  final SupabaseClient? client;

  AuthRepository({this.client});

  SupabaseClient get _supabaseClient {
    if (client != null) return client!;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw StateError(
        'Supabase belum terkonfigurasi. Pastikan SUPABASE_URL dan '
        'SUPABASE_ANON_KEY disertakan saat menjalankan aplikasi.',
      );
    }
  }

  /// Pengguna pada sesi Supabase aktif, atau `null` bila belum login.
  User? get currentUser {
    if (client != null) return client!.auth.currentUser;
    try {
      return Supabase.instance.client.auth.currentUser;
    } on AssertionError {
      return null;
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _supabaseClient.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return _supabaseClient.auth.signOut();
  }
}
