# Backlog Task KosFinder

Dokumen ini memuat daftar task pengembangan aplikasi **KosFinder** yang disusun berdasarkan pendekatan *Vertical Slice Architecture*. Setiap slice merepresentasikan potongan fitur fungsional menyeluruh (*end-to-end* dari UI, State, Repository hingga Supabase) dan menghasilkan aplikasi yang dapat langsung dijalankan (*runnable*).

Acuan teknis dan fungsional:
* **Spesifikasi Produk:** `docs/PRD.md`
* **Arsitektur Sistem:** `docs/ARCHITECTURE.md`
* **Aturan Kerja & DoD:** `AGENTS.md`

Status task yang digunakan: `TODO`, `IN_PROGRESS`, `DONE`. Seluruh task berstatus awal `TODO`.

---

## Slice 1: Daftar dan Detail Kos

Aplikasi dapat dijalankan oleh pencari kos (*guest mode*) untuk menjelajahi daftar kos publik (`created_at DESC`), melihat detail lengkap kos, mengakses tombol kontak WhatsApp (`https://wa.me/62...`) / telepon, serta membuka informasi pengembang di halaman About.

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| T01 | Konfigurasi dependensi esensial, environment compile-time (`AppConfig`), dan inisialisasi Supabase client | PRD 1, 4.1; ARCHITECTURE 4, 6. AC: `AppConfig` membaca kredensial via `--dart-define` tanpa hardcoded keys, Supabase client terinisialisasi di Flutter | `pubspec.yaml`, `lib/core/config/app_config.dart`, `lib/main.dart` | Jalankan `flutter pub get`, verifikasi `flutter analyze` bersih dan aplikasi berjalan tanpa crash koneksi | TODO |
| T02 | Buat model data `Listing` dengan mapping JSON, format mata uang Rupiah, dan helper URL kontak WhatsApp | PRD 5, 8.1; ARCHITECTURE 3. AC: Mendukung seluruh field tabel `listings`, format harga via `intl` (`Rp xxx.xxx`), dan URL WhatsApp format `https://wa.me/62...` | `lib/models/listing_model.dart`, `test/models/listing_model_test.dart` | Jalankan `flutter test test/models/listing_model_test.dart` dan verifikasi parsing JSON serta formatting kontak | TODO |
| T03 | Buat `ListingRepository` untuk fetch daftar kos publik (`created_at DESC`) dan detail kos berdasarkan ID | PRD 4.1, 8.2; ARCHITECTURE 1, 3. AC: Query Supabase membaca data publik tabel `listings` berurutan `created_at DESC` dan fetch single listing berdasarkan ID | `lib/repositories/listing_repository.dart`, `test/repositories/listing_repository_test.dart` | Jalankan unit test `ListingRepository` dengan mock client untuk verifikasi query fetching dan sorting | TODO |
| T04 | Buat `ListingProvider` untuk mengelola state daftar kos publik (loading, data, dan error) | ARCHITECTURE 1 (State Management Provider). AC: Menyediakan state reaktif `listings`, `isLoading`, `errorMessage`, dan method `fetchListings()` | `lib/providers/listing_provider.dart`, `test/providers/listing_provider_test.dart` | Jalankan unit test `ListingProvider` untuk menguji skenario sukses dan error fetch data | TODO |
| T05 | Buat widget `ListingCard` dan `HomeScreen` untuk menampilkan daftar kartu kos dengan pembatasan teks fasilitas | PRD 2.1, 4.1, 8.2, 8.3; ARCHITECTURE 1, 2. AC: Menampilkan kartu kos rapi, harga Rupiah, tipe penghuni, alamat, fasilitas terpotong elipsis maks 2 baris | `lib/widgets/listing_card.dart`, `lib/screens/home_screen.dart`, `test/screens/home_screen_test.dart` | Jalankan widget test untuk verifikasi rendering kartu, urutan default, dan pemotongan teks fasilitas | TODO |
| T06 | Buat `ListingDetailScreen` menampilkan informasi lengkap kos dan aksi hubungi WhatsApp serta panggilan telepon | PRD 2.1, 4.1, 8.1, 8.3; ARCHITECTURE 1, 2. AC: Menampilkan semua detail kos; tombol WA membuka `https://wa.me/62...`, tombol telepon membuka dialer | `lib/screens/listing_detail_screen.dart`, `test/screens/listing_detail_screen_test.dart` | Jalankan widget test `ListingDetailScreen` dan verifikasi pemicuan URL launcher WhatsApp dan nomor telepon | TODO |
| T07 | Buat `AboutScreen` memuat identitas pengembang dan integrasikan navigasinya pada AppBar `HomeScreen` | AGENTS.md 7; ARCHITECTURE 1, 2. AC: Layar About memuat identitas persis `2415051059 - Syaeful Darmawan` dan dapat diakses dari HomeScreen | `lib/screens/about_screen.dart`, `lib/screens/home_screen.dart`, `test/screens/about_screen_test.dart` | Jalankan widget test untuk memastikan string identitas tampil persis dan navigasi dari HomeScreen berfungsi | TODO |
| T08 | Integrasi akhir Slice 1 pada `main.dart` dan pengujian aplikasi end-to-end | ARCHITECTURE 1, 2. AC: Aplikasi berjalan lancar, menampilkan HomeScreen publik dengan data kos, navigasi ke Detail dan About berfungsi tanpa error | `lib/main.dart`, `test/widget_test.dart` | Jalankan `flutter analyze`, `flutter test`, dan jalankan aplikasi untuk verifikasi aliran Slice 1 berjalan utuh | TODO |

---

## Slice 2: Pencarian dan Filter

Aplikasi dapat dijalankan oleh pencari kos untuk mencari kos berdasarkan kata kunci teks (nama kos atau alamat/lokasi Singaraja) serta memfilter berdasarkan rentang harga sewa bulanan (minimum dan maksimum dalam Rupiah).

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| T09 | Perbarui `ListingRepository` untuk query pencarian teks (nama kos/alamat) dan filter rentang harga | PRD 2.1, 4.1, 6.2; ARCHITECTURE 1, 3. AC: Query Supabase mendukung pencarian `ilike` pada kolom `name`/`address` dan perbandingan `>= minPrice` serta `<= maxPrice` | `lib/repositories/listing_repository.dart`, `test/repositories/listing_repository_test.dart` | Jalankan unit test `ListingRepository` dengan parameter pencarian teks dan rentang harga | TODO |
| T10 | Perbarui `ListingProvider` untuk mengelola state filter pencarian teks, rentang harga, dan reset filter | ARCHITECTURE 1. AC: Menyimpan parameter `searchQuery`, `minPrice`, `maxPrice`, serta method `setSearchQuery()`, `setPriceFilter()`, dan `clearFilters()` | `lib/providers/listing_provider.dart`, `test/providers/listing_provider_test.dart` | Jalankan unit test `ListingProvider` untuk verifikasi perubahan state filter dan pemanggilan query baru | TODO |
| T11 | Implementasikan komponen Search Bar pada `HomeScreen` untuk pencarian berbasis nama kos dan alamat | PRD 2.1, 4.1; ARCHITECTURE 1, 2. AC: Pengguna dapat mengetik kata kunci pencarian pada AppBar/Header HomeScreen dan daftar kartu kos tersaring secara responsif | `lib/screens/home_screen.dart`, `test/screens/home_screen_test.dart` | Jalankan widget test dengan menginput teks pencarian dan memverifikasi daftar kos yang ditampilkan sesuai | TODO |
| T12 | Buat widget `FilterModal` (bottom sheet) untuk input rentang harga bulanan dan hubungkan ke `HomeScreen` | PRD 2.1, 4.1; ARCHITECTURE 1, 2. AC: Menyediakan input harga minimum dan maksimum dalam Rupiah, tombol "Terapkan", dan "Reset" yang memfilter daftar kos | `lib/widgets/filter_modal.dart`, `lib/screens/home_screen.dart`, `test/widgets/filter_modal_test.dart` | Jalankan widget test membuka modal filter, memasukkan rentang harga, klik terapkan, dan cek pembaruan list | TODO |
| T13 | Integrasi dan pengujian Slice 2 untuk pencarian teks dan filter harga yang bekerja secara simultan | PRD 4.1; ARCHITECTURE 1, 2. AC: Pencarian dan filter harga dapat dikombinasikan secara simultan, dan reset mengembalikan daftar ke kondisi default | `lib/screens/home_screen.dart`, `test/integration/search_filter_test.dart` | Jalankan `flutter analyze`, `flutter test`, dan uji coba manual interaksi search bar dan filter modal di aplikasi | TODO |

---

## Slice 3: Login Pemilik

Aplikasi dapat dijalankan oleh pemilik kos untuk mendaftar akun baru (*register*), masuk (*login*), keluar (*logout*), dan mempertahankan sesi autentikasi berbasis Supabase Auth.

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| T14 | Buat `AuthRepository` untuk integrasi Supabase Auth (`signUp`, `signInWithPassword`, `signOut`, status sesi) | PRD 2.2, 4.1; ARCHITECTURE 1, 3. AC: Menangani registrasi, login email/password, logout, serta pengecekan user/sesi aktif via Supabase Auth | `lib/repositories/auth_repository.dart`, `test/repositories/auth_repository_test.dart` | Jalankan unit test `AuthRepository` dengan mock client untuk skenario login sukses, gagal, dan logout | TODO |
| T15 | Buat `AuthProvider` untuk mengelola state autentikasi (user saat ini, status login, error, dan loading) | ARCHITECTURE 1. AC: Menyimpan state `currentUser`, `isAuthenticated`, `isLoading`, `errorMessage`, serta mengekspos method login, register, dan logout | `lib/providers/auth_provider.dart`, `test/providers/auth_provider_test.dart` | Jalankan unit test `AuthProvider` untuk transisi state login berhasil, gagal, registrasi, dan logout | TODO |
| T16 | Buat `LoginScreen` dan `RegisterScreen` dengan form validasi email dan password | PRD 2.2, 4.1; ARCHITECTURE 1, 2. AC: Form memvalidasi format email dan password min 6 karakter, menampilkan error banner jika auth gagal, dan navigasi antar halaman | `lib/screens/auth/login_screen.dart`, `lib/screens/auth/register_screen.dart`, `test/screens/auth_screen_test.dart` | Jalankan widget test form login dan register dengan input valid/invalid dan verifikasi pesan kesalahan | TODO |
| T17 | Hubungkan navigasi autentikasi dari `HomeScreen`, pengalihan ke dashboard setelah login, dan fungsi logout | ARCHITECTURE 1, 2. AC: Tombol akun di HomeScreen mengarahkan ke LoginScreen; login sukses mengarahkan ke Dashboard pemilik; logout mengembalikan ke HomeScreen | `lib/screens/home_screen.dart`, `lib/screens/owner/owner_dashboard_screen.dart`, `lib/main.dart`, `test/screens/auth_navigation_test.dart` | Jalankan widget test navigasi auth dari HomeScreen -> Login -> Dashboard -> Logout -> HomeScreen | TODO |
| T18 | Integrasi dan pengujian Slice 3 untuk memverifikasi alur otentikasi pemilik kos secara menyeluruh | PRD 4.1; ARCHITECTURE 1, 2. AC: Aplikasi berjalan dengan autentikasi stabil, sesi tersimpan, dan menu pemilik hanya terbuka jika terautentikasi | `lib/main.dart`, `test/widget_test.dart` | Jalankan `flutter analyze`, `flutter test`, dan lakukan uji coba registrasi, login, dan logout pada device/emulator | TODO |

---

## Slice 4: Tambah, Ubah, Hapus Kos Milik Sendiri

Aplikasi dapat dijalankan oleh pemilik kos yang sudah login untuk melihat daftar kos miliknya sendiri di dashboard, menambahkan kos baru, mengubah data kos miliknya, dan menghapus kos dengan penegakan RLS di level database.

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| T19 | Perbarui `ListingRepository` untuk operasi CRUD pemilik dan sanitasi penyimpanan nomor WhatsApp | PRD 2.2, 4.1, 5, 8.1; ARCHITECTURE 1, 3. AC: Operasi CRUD menyertakan `owner_id = auth.uid()`, nomor kontak disanitasi ke format lokal `08...` sebelum disimpan | `lib/repositories/listing_repository.dart`, `test/repositories/listing_repository_test.dart` | Jalankan unit test `ListingRepository` untuk insert, update, delete, fetch by owner, dan sanitasi nomor kontak | TODO |
| T20 | Buat `OwnerListingProvider` untuk mengelola state reaktif data kos milik pemilik terautentikasi | ARCHITECTURE 1. AC: Menyediakan state `ownerListings`, `isLoading`, `errorMessage`, dan method `fetchOwnerListings()`, `createListing()`, `updateListing()`, `deleteListing()` | `lib/providers/owner_listing_provider.dart`, `test/providers/owner_listing_provider_test.dart` | Jalankan unit test `OwnerListingProvider` untuk operasi CRUD dan pemicuan perubahan state | TODO |
| T21 | Buat `ListingFormScreen` untuk tambah dan ubah kos dengan validasi aturan bisnis lengkap | PRD 5, 8.1, 8.3; ARCHITECTURE 1, 2. AC: Form memvalidasi nama kos (1–150 char), harga (> 0), tipe ('Putra'/'Putri'/'Campur'), alamat, fasilitas (1–200 char), dan WA (10–15 digit numerik) | `lib/screens/owner/listing_form_screen.dart`, `test/screens/listing_form_screen_test.dart` | Jalankan widget test form untuk kasus input valid dan invalid (misal: fasilitas > 200 karakter atau WA salah) | TODO |
| T22 | Buat `OwnerDashboardScreen` menampilkan daftar kos pemilik dengan tombol Tambah, Ubah, dan Hapus | PRD 2.2, 4.1; ARCHITECTURE 1, 2. AC: Menampilkan daftar kos milik pemilik, FAB Tambah Kos, tombol Edit membuka form terisi, dan tombol Hapus memicu dialog konfirmasi | `lib/screens/owner/owner_dashboard_screen.dart`, `test/screens/owner_dashboard_screen_test.dart` | Jalankan widget test interaksi dashboard: klik tambah, edit, dan konfirmasi hapus data kos | TODO |
| T23 | Integrasi dan pengujian Slice 4 untuk sinkronisasi CRUD kos pemilik dengan tampilan publik | PRD 4.1; ARCHITECTURE 1, 2. AC: Penambahan/perubahan/penghapusan kos pada dashboard pemilik langsung tercermin pada daftar publik HomeScreen | `lib/screens/owner/owner_dashboard_screen.dart`, `lib/screens/home_screen.dart`, `test/integration/owner_crud_test.dart` | Jalankan `flutter analyze`, `flutter test`, dan uji coba pembuatan kos di dashboard lalu verifikasi di HomeScreen | TODO |

---

## Slice 5 (bonus): Ketersediaan Kamar

Aplikasi dapat dijalankan dengan fitur status ketersediaan kamar ("Tersedia" atau "Penuh"). Pemilik kos dapat mengubah status ketersediaan dari dashboard, dan kartu publik menampilkan badge visual "Penuh" tanpa mengubah urutan default `created_at DESC`.

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| T24 | Perbarui `ListingRepository` dan `OwnerListingProvider` dengan fungsi update status ketersediaan | PRD 4.1, 5, 8.4; ARCHITECTURE 1, 3. AC: Menjalankan update kolom `is_available` di Supabase untuk listing dengan `owner_id == auth.uid()` dan merefleksikan perubahan di state | `lib/repositories/listing_repository.dart`, `lib/providers/owner_listing_provider.dart`, `test/repositories/listing_repository_test.dart` | Jalankan unit test repository dan provider untuk pembaruan status `is_available` | TODO |
| T25 | Tambahkan kontrol toggle ketersediaan ("Tersedia" / "Penuh") pada antarmuka pemilik di `OwnerDashboardScreen` | PRD 2.2, 4.1, 8.4; ARCHITECTURE 1, 2. AC: Terdapat switch/toggle interaktif pada setiap kartu kos milik pemilik untuk mengubah status kamar secara instan | `lib/screens/owner/owner_dashboard_screen.dart`, `test/screens/owner_dashboard_screen_test.dart` | Jalankan widget test menekan toggle ketersediaan dan memastikan pemicuan update status ke provider | TODO |
| T26 | Implementasikan badge visual "Penuh" pada `ListingCard` di `HomeScreen` dan `ListingDetailScreen` | PRD 4.1, 8.4; ARCHITECTURE 1, 2. AC: Kos dengan `is_available == false` menampilkan badge visual "Penuh" yang kontras; urutan kos tetap normal mengikuti `created_at DESC` | `lib/widgets/listing_card.dart`, `lib/screens/listing_detail_screen.dart`, `test/widgets/listing_card_test.dart` | Jalankan widget test memverifikasi munculnya badge "Penuh" pada kartu dan detail serta urutan tidak berubah | TODO |
| T27 | Pengujian regresi menyeluruh Slice 1–5, verifikasi DoD, dan audit kepatuhan spesifikasi | AGENTS.md 6; PRD 4.1; ARCHITECTURE 1. AC: Seluruh unit & widget test lulus, `flutter analyze` 0 warning, halaman About memuat identitas sesuai, dan seluruh fitur berjalan stabil | `test/widget_test.dart`, `lib/main.dart`, `docs/TASKS.md` | Jalankan `flutter analyze` dan `flutter test` untuk memastikan semua pengujian lulus dan kriteria DoD terpenuhi | TODO |
