import 'package:flutter/material.dart';
import 'package:kostfinder/models/listing_model.dart';

/// Kartu tampilan ringkas untuk kos pada daftar beranda publik.
class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nama Kos + Badge Tipe Penghuni & Badge Status Ketersediaan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      listing.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(listing.type),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      listing.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!listing.isAvailable) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Penuh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Harga Bulanan (Format Rupiah via intl)
              Text(
                '${listing.formattedPrice} / bulan',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // Alamat Kos
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      listing.address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Fasilitas (maksimal 2 baris terpotong elipsis)
              Text(
                listing.facilities,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'putra':
        return Colors.blue.shade700;
      case 'putri':
        return Colors.pink.shade600;
      case 'campur':
        return Colors.purple.shade600;
      default:
        return Colors.teal.shade700;
    }
  }
}
