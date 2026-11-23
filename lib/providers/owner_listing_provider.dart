import 'package:flutter/foundation.dart';
import 'package:kostfinder/models/listing_model.dart';
import 'package:kostfinder/repositories/listing_repository.dart';

/// Mengelola daftar kos dan pembuatan kos milik pemilik yang sedang login.
class OwnerListingProvider extends ChangeNotifier {
  final ListingRepository _repository;

  List<Listing> _ownerListings = [];
  bool _isLoading = false;
  String? _errorMessage;

  OwnerListingProvider({ListingRepository? repository})
    : _repository = repository ?? ListingRepository();

  List<Listing> get ownerListings => _ownerListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOwnerListings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _ownerListings = await _repository.fetchOwnerListings();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createListing({
    required String name,
    required int pricePerMonth,
    required String type,
    required String address,
    required String facilities,
    required String whatsappNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final listing = await _repository.createListing(
        name: name,
        pricePerMonth: pricePerMonth,
        type: type,
        address: address,
        facilities: facilities,
        whatsappNumber: whatsappNumber,
      );
      _ownerListings = [listing, ..._ownerListings];
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateListing(Listing listing) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.updateListing(listing);
      _ownerListings = await _repository.fetchOwnerListings();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteListing(Listing listing) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteListing(listing);
      _ownerListings = await _repository.fetchOwnerListings();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAvailability(String id, bool isAvailable) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.updateAvailability(id, isAvailable);
      final index = _ownerListings.indexWhere((listing) => listing.id == id);
      if (index >= 0) {
        _ownerListings[index] = _ownerListings[index].copyWith(
          isAvailable: isAvailable,
        );
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
}
