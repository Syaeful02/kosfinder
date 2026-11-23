import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kostfinder/repositories/auth_repository.dart';

/// Mengelola state sesi dan operasi autentikasi pemilik.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository() {
    _currentUser = _repository.currentUser;
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signUp({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.signUp(email: email, password: password);
      _currentUser = _repository.currentUser;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _repository.signInWithPassword(
        email: email,
        password: password,
      );
      _currentUser = _repository.currentUser ?? response.user;
      if (_currentUser == null) {
        _errorMessage = 'Sesi pengguna tidak ditemukan setelah login.';
        return false;
      }
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.signOut();
      _currentUser = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
