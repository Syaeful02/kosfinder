# Rencana Uji Penerimaan KosFinder

Gunakan environment Supabase khusus pengujian dengan akun Guest, Pemilik A, Pemilik B, serta data kos yang mencakup beberapa harga dan status ketersediaan. Jangan gunakan kredensial produksi.

| Skenario Uji | Langkah | Hasil yang Diharapkan |
|---|---|---|
| Inisialisasi aplikasi | Jalankan aplikasi dengan konfigurasi Supabase yang valid; ulangi tanpa salah satu parameter konfigurasi. | Aplikasi berjalan dengan konfigurasi valid dan menampilkan pesan konfigurasi yang jelas jika URL atau anon key tidak tersedia. |
| Daftar kos publik | Buka HomeScreen sebagai Guest. | Guest dapat melihat semua kos publik tanpa harus login. |
| Urutan daftar default | Siapkan beberapa kos dengan waktu pembuatan berbeda, lalu buka HomeScreen. | Kos ditampilkan dengan urutan `created_at DESC`; tidak ada pengurutan tambahan yang mengubah urutan default. |
| Informasi kartu kos | Periksa kartu pada HomeScreen. | Kartu menampilkan nama, harga Rupiah per bulan, tipe, alamat ringkas, fasilitas, dan status; fasilitas panjang dibatasi dua baris dengan elipsis. |
| Status penuh pada daftar Guest | Siapkan kos `is_available = false`, lalu buka HomeScreen sebagai Guest. | Kos tetap tampil di urutan normal dan memiliki badge “Penuh”. |
| Detail kos | Buka kartu kos dari HomeScreen. | Halaman detail menampilkan seluruh informasi kos, termasuk fasilitas lengkap dan kontak; kos penuh tetap diberi label “Penuh”. |
| Tautan WhatsApp | Dari detail kos, tekan tombol WhatsApp untuk nomor lokal `08...` dan nomor berawalan `62`. | Tautan memakai format `https://wa.me/62...`; kedua bentuk nomor diarahkan ke nomor yang benar. |
| Tautan telepon | Dari detail kos, tekan tombol Telepon. | Dialer perangkat dibuka dengan nomor kontak kos. |
| Pencarian nama kos | Cari kos menggunakan sebagian nama, termasuk variasi huruf besar/kecil. | Daftar hanya menampilkan nama yang cocok tanpa membedakan kapitalisasi. |
| Pencarian alamat | Cari menggunakan kata atau area dari alamat kos. | Daftar menampilkan kos dengan alamat yang cocok. |
| Filter harga batas bawah dan atas | Terapkan rentang harga bulanan dengan kos di bawah, tepat pada, dan di atas batas. | Hanya kos di dalam rentang yang tampil; nilai pada batas minimum dan maksimum termasuk hasil. |
| Pencarian dan filter bersamaan | Isi pencarian teks dan terapkan rentang harga. | Hasil memenuhi pencarian teks dan rentang harga secara bersamaan. |
| Reset filter | Terapkan pencarian dan rentang harga, lalu tekan Reset. | Pencarian dan filter harga kembali ke kondisi awal dan daftar publik dimuat ulang. |
| Register pemilik | Daftarkan akun dengan email dan password yang valid, lalu coba input tidak valid. | Akun valid berhasil dibuat; email tidak valid atau password di bawah batas form ditolak dengan pesan validasi. |
| Login dan sesi pemilik | Login dengan kredensial valid, muat ulang aplikasi, lalu logout. | Login membuka akses pemilik dan sesi dipulihkan; logout mengakhiri sesi dan kembali ke HomeScreen. |
| Isolasi daftar pemilik | Login sebagai Pemilik A lalu Pemilik B, masing-masing membuka dashboard. | Setiap pemilik hanya melihat kos miliknya sendiri. |
| Tambah kos | Sebagai pemilik, masukkan data kos valid dan simpan. | Kos tersimpan dengan `owner_id` akun aktif, tampil di dashboard dan langsung dapat dibaca secara publik; ketersediaan awal bernilai tersedia. |
| Default dan timestamp data | Buat kos tanpa mengirim `id`, `created_at`, `updated_at`, atau `is_available`; lalu ubah salah satu field. | Database mengisi ID dan timestamp, `is_available` bernilai `true`, dan `updated_at` berubah saat data diperbarui. |
| Validasi data kos | Coba nama kosong atau lebih dari 150 karakter, harga bukan angka atau tidak positif, tipe di luar pilihan, alamat kosong, serta fasilitas kosong atau lebih dari 200 karakter. | Input tidak valid ditolak dan pesan validasi ditampilkan sebelum data disimpan. |
| Validasi dan sanitasi WhatsApp | Coba nomor nonangka atau panjang di luar 10–15 digit; simpan nomor valid berawalan `62`. | Nomor tidak valid ditolak; nomor valid disimpan dalam format lokal `08...` dan tautan kontak tetap memakai awalan `62`. |
| Ubah kos | Sebagai pemilik kos, ubah data kos lalu simpan; coba ubah kos milik akun lain. | Pemilik dapat mengubah datanya; perubahan milik akun lain ditolak oleh RLS. |
| Hapus kos | Hapus kos milik sendiri dengan konfirmasi; coba hapus kos pemilik lain. | Kos sendiri terhapus; penghapusan kos pemilik lain ditolak oleh RLS. |
| Hak baca Guest | Lakukan pembacaan tabel `listings` sebagai role `anon`, termasuk kos penuh. | Guest dapat membaca semua kos publik tanpa menyaring status ketersediaan. |
| Penegakan RLS perubahan data | Sebagai `anon`, coba insert/update/delete; sebagai Pemilik B, coba mengubah atau menghapus data Pemilik A. | Operasi tanpa hak ditolak; pemilik terautentikasi hanya dapat mengubah dan menghapus datanya sendiri. |
| Ubah ketersediaan | Pada dashboard, ubah switch kos sendiri dari Tersedia ke Penuh dan kembali. | Status tersimpan ke `is_available`, dashboard merefleksikan perubahan, dan pemilik lain tidak dapat mengubahnya. |
| Urutan kos penuh | Ubah salah satu kos menjadi Penuh dan muat ulang HomeScreen. | Kos tetap berada pada posisi yang ditentukan `created_at DESC`, dengan badge “Penuh”. |
| Indeks dan performa query | Periksa indeks database untuk sorting tanggal, filter harga, dan pencarian teks; uji query pada jumlah data representatif. | Indeks yang diperlukan tersedia dan pencarian/filter tetap responsif pada skala data uji. |
| Responsivitas dan ruang lingkup | Jalankan alur utama pada ukuran layar mobile dan web; periksa tidak ada iklan atau fitur di luar ruang lingkup. | UI tetap dapat digunakan pada kedua target; tidak ada upload foto, chat, booking/pembayaran, rating, peta, iklan, atau fitur admin. |
