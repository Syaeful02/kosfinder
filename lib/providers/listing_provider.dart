import 'package:flutter/foundation.dart';
import 'package:kostfinder/models/listing_model.dart';
import 'package:kostfinder/repositories/listing_repository.dart';

/// Provider untuk mengelola reactive state daftar kos publik,
/// termasuk state pencarian teks (searchQuery) dan filter harga (minPrice, maxPrice).
class ListingProvider extends ChangeNotifier {
  final ListingRepository _repository;

  List<Listing> _listings = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  int? _minPrice;
  int? _maxPrice;

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

  /// Query pencarian teks saat ini.
  String get searchQuery => _searchQuery;

  /// Filter harga minimum (dalam Rupiah). `null` berarti tidak ada batas bawah.
  int? get minPrice => _minPrice;

  /// Filter harga maksimum (dalam Rupiah). `null` berarti tidak ada batas atas.
  int? get maxPrice => _maxPrice;

  /// Menunjukkan apakah ada filter harga yang sedang aktif.
  bool get hasPriceFilter => _minPrice != null || _maxPrice != null;

  /// Mengambil daftar kos publik dari repositori (`created_at DESC`).
  /// Menyertakan [searchQuery], [minPrice], dan [maxPrice] jika tersedia.
  Future<void> fetchListings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _listings = await _repository.fetchAll(
        searchQuery: _searchQuery,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengubah query pencarian dan langsung memanggil ulang fetch data.
  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    await fetchListings();
  }

  /// Mereset query pencarian ke kondisi awal dan memuat ulang semua data.
  Future<void> clearSearch() async {
    _searchQuery = '';
    await fetchListings();
  }

  /// Mengatur batas harga maksimum dan memicu ulang fetch data.
  Future<void> setPriceFilter(int? maxPrice) async {
    _maxPrice = maxPrice;
    await fetchListings();
  }

  /// Mengatur filter rentang harga yang digunakan oleh input filter UI.
  Future<void> setPriceRangeFilter({
    int? minPrice,
    int? maxPrice,
  }) async {
    _minPrice = minPrice;
    await setPriceFilter(maxPrice);
  }

  /// Mereset semua filter (harga dan pencarian) dan memuat ulang semua data.
  Future<void> clearFilters() async {
    _searchQuery = '';
    _minPrice = null;
    _maxPrice = null;
    await fetchListings();
  }

  /// Helper untuk mengambil satu data kos berdasarkan [id].
  Future<Listing?> getListingById(String id) async {
    return _repository.fetchById(id);
  }
}
