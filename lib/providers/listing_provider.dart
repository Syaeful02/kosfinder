import 'package:flutter/foundation.dart';
import 'package:kostfinder/models/listing_model.dart';
import 'package:kostfinder/repositories/listing_repository.dart';

/// Provider untuk mengelola reactive state daftar kos publik.
class ListingProvider extends ChangeNotifier {
  final ListingRepository _repository;

  List<Listing> _listings = [];
  bool _isLoading = false;
  String? _errorMessage;

  ListingProvider({ListingRepository? repository})
      : _repository = repository ?? ListingRepository();

  /// Daftar kos yang tersedia saat ini.
  List<Listing> get listings => _listings;

  /// Status loading saat proses fetch berlangsung.
  bool get isLoading => _isLoading;

  /// Pesan kesalahan jika terjadi kegagalan fetch data.
  String? get errorMessage => _errorMessage;

  /// Menunjukkan apakah terjadi error pada state saat ini.
  bool get hasError => _errorMessage != null;

  /// Menunjukkan apakah data kos kosong dan tidak dalam kondisi loading atau error.
  bool get isEmpty => !_isLoading && _errorMessage == null && _listings.isEmpty;

  /// Mengambil daftar kos publik dari repositori (`created_at DESC`).
  Future<void> fetchListings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _listings = await _repository.fetchAll();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper untuk mengambil satu data kos berdasarkan [id].
  Future<Listing?> getListingById(String id) async {
    return _repository.fetchById(id);
  }
}
