# Product Requirements Document (PRD) - KosFinder

## 1. Ringkasan Produk
* **Nama Produk:** KosFinder
* **Visi Produk:** Platform pencarian kos yang transparan, ringan, dan bebas iklan untuk mahasiswa serta pekerja di Singaraja, sekaligus sarana promosi online yang mudah dan mandiri bagi pemilik kos.
* **Target Rilis:** Versi 1 (MVP) dengan batas pengerjaan **2 minggu kalender**.
* **Tech Stack:**
  * **Frontend / Mobile:** Flutter (Dart)
  * **Backend / Database:** Supabase (Auth & PostgreSQL Database dengan Row Level Security)
  * **Infrastruktur:** Serverless, tanpa server tambahan (*zero additional backend server*).

---

## 2. Peran & Akses Pengguna (User Roles)

### 2.1 Pencari Kos (Mode Guest / Publik)
* **Akses:** Bebas tanpa registrasi dan tanpa login (*guest mode*).
* **Hak Akses:**
  * Melihat daftar semua kos yang tersedia secara publik.
  * Mencari kos berdasarkan teks (nama kos atau area/alamat di Singaraja).
  * Memfilter daftar kos berdasarkan rentang harga sewa bulanan.
  * Melihat halaman detail informasi kos.
  * Menghubungi pemilik kos secara langsung melalui tombol WhatsApp (`https://wa.me/<nomor>`) atau panggilan telepon seluler.

### 2.2 Pemilik Kos (Authenticated User)
* **Akses:** Wajib mendaftar (*register*) dan masuk (*login*) menggunakan email dan kata sandi.
* **Hak Akses:**
  * Mengakses dashboard/menu manajemen kos miliknya sendiri.
  * Menambahkan kos baru (informasi langsung tayang secara publik tanpa moderasi/verifikasi admin).
  * Mengubah data kos yang dimilikinya.
  * Menghapus kos yang dimilikinya.
  * Mengubah status ketersediaan kamar (*Tersedia* / *Penuh*) untuk kos miliknya (fitur Slice 5).

---

## 3. Masalah & Solusi

### 3.1 Masalah Utama
1. **Pencari Kos:**
   * Informasi kos di Singaraja masih terpencar di grup WhatsApp atau brosur fisik di jalanan.
   * Sulit mengetahui kepastian harga bulanan dan fasilitas secara jelas dan transparan.
   * Aplikasi serupa yang ada saat ini (misal: Mamikos, Rukita) memiliki terlalu banyak iklan, fitur rumit, atau tidak fokus pada wilayah Singaraja.
2. **Pemilik Kos:**
   * Sulit mempromosikan kamar kos secara online tanpa ribet atau terbebani biaya perantara/iklan.

### 3.2 Solusi KosFinder
* Aplikasi ringkas dengan kartu informasi yang rapi, transparan, dan bebas iklan.
* Menampilkan informasi inti: nama kos, harga per bulan (Rupiah), tipe penghuni, alamat/lokasi, fasilitas ringkas, dan kontak WhatsApp.
* Memberikan akses langsung tanpa registrasi bagi pencari kos dan alur komunikasi instan langsung ke WhatsApp pemilik kos.

---

## 4. Batasan Ruang Lingkup (Scope Boundaries)

### 4.1 In-Scope (Fitur Versi 1 - MVP)
* **Autentikasi Pemilik:** Registrasi, Login, dan Logout berbasis Supabase Auth.
* **Manajemen Kos Pemilik (CRUD):** Tambah, lihat daftar, perbarui, dan hapus kos milik sendiri.
* **Keamanan Backend (RLS):** Kebijakan otorisasi ditegakkan langsung di level database Supabase (Row Level Security), bukan sekadar menyembunyikan tombol UI.
* **Penjelajahan Kos (Guest Mode):** Kartu daftar kos rapi dengan informasi ringkas (nama, harga bulanan, tipe penghuni, lokasi singkat, dan label status).
* **Urutan Default Daftar Kos:** Diurutkan secara default berdasarkan `created_at DESC` (listing terbaru di posisi paling atas). Tanpa opsi sorting di V1.
* **Pencarian Teks:** Pencarian berbasis string teks pada nama kos dan alamat/lokasi di Singaraja.
* **Filter Harga:** Filter berbasis rentang angka harga per bulan (minimum dan maksimum dalam Rupiah).
* **Halaman Detail Kos:** Menampilkan informasi lengkap dalam bentuk teks (nama, harga bulanan, tipe penghuni, alamat lengkap, fasilitas lengkap, kontak WhatsApp).
* **Tautan Kontak:** Tombol aksi langsung membuka aplikasi WhatsApp via URL scheme (`https://wa.me/62...`) atau dialer panggilan telepon.
* **Status Ketersediaan (Slice 5 / Bonus):** Kolom status ketersediaan disiapkan di database sejak awal; pemilik dapat mengubah status menjadi "Tersedia" atau "Penuh"; kos penuh tetap tampil pada urutan normal (`created_at DESC`) dengan badge/label penanda jelas "Penuh".

### 4.2 Out-of-Scope (TIDAK ADA di Versi 1)
* **Tidak ada fitur upload atau penyimpanan foto** (semua listing kos berbasis teks untuk menjaga kuota storage dan mematuhi batas waktu 2 minggu).
* **Tidak ada chat in-app** (komunikasi dialihkan penuh ke WhatsApp / telepon).
* **Tidak ada sistem transaksi, booking, atau pembayaran digital**.
* **Tidak ada sistem rating dan ulasan (review)**.
* **Tidak ada integrasi peta (Google Maps / Mapbox)**.
* **Tidak ada banner iklan atau sistem monetisasi iklan**.
* **Tidak ada filter lanjutan di V1** (filter fasilitas dan filter tipe penghuni ditunda untuk versi berikutnya).
* **Tidak ada opsi sorting lanjutan** (hanya default `created_at DESC`).
* **Tidak ada periode sewa harian/tahunan** (seluruh harga seragam bulanan).
* **Tidak ada peran Admin atau antrean verifikasi manual** (listing langsung publik begitu dibuat).

---

## 5. Spesifikasi Entitas & Skema Data

Tabel utama di Supabase PostgreSQL: `listings` (atau `kos`).

| Kolom | Tipe Data | Keterangan & Aturan Validasi |
| :--- | :--- | :--- |
| `id` | `UUID` | Primary Key, default `gen_random_uuid()` |
| `owner_id` | `UUID` | Foreign Key ke `auth.users.id`, NOT NULL |
| `name` | `VARCHAR(150)` | Nama kos, NOT NULL |
| `price_per_month` | `BIGINT` / `INTEGER` | Harga sewa per bulan dalam Rupiah (angka murni, > 0), NOT NULL |
| `type` | `VARCHAR(20)` | Tipe penghuni: `'Putra'`, `'Putri'`, atau `'Campur'`, NOT NULL |
| `address` | `TEXT` | Alamat lengkap / area lokasi di Singaraja, NOT NULL |
| `facilities` | `VARCHAR(200)` | Rincian fasilitas kos (teks bebas, 1–200 karakter), NOT NULL |
| `whatsapp_number` | `VARCHAR(20)` | Nomor WhatsApp/telepon pemilik kos, format lokal `08...`, 10–15 digit numerik, NOT NULL |
| `is_available` | `BOOLEAN` | Status ketersediaan: `true` (Tersedia), `false` (Penuh). Default: `true` |
| `created_at` | `TIMESTAMPTZ` | Waktu pembuatan data, default `now()` |
| `updated_at` | `TIMESTAMPTZ` | Waktu pembaruan data, default `now()` |

### Kebijakan Row Level Security (RLS) Supabase
* **SELECT (Read):** Terbuka untuk semua (`anon` dan `authenticated`). Kos yang berstatus penuh tetap dapat dibaca oleh publik.
* **INSERT (Create):** Hanya untuk `authenticated user`, dengan syarat `owner_id == auth.uid()`.
* **UPDATE (Update):** Hanya untuk `authenticated user` yang merupakan pemilik data (`owner_id == auth.uid()`).
* **DELETE (Delete):** Hanya untuk `authenticated user` yang merupakan pemilik data (`owner_id == auth.uid()`).

---

## 6. Kebutuhan Non-Fungsional (NFR)
1. **Keamanan:**
   * Penegakan otorisasi mutlak di database Supabase melalui RLS. Pengguna yang tidak terautentikasi atau pemilik lain tidak dapat memodifikasi data orang lain melalui API.
2. **Kinerja & Responsivitas:**
   * Aplikasi Flutter responsif pada perangkat mobile (Android & iOS) serta dapat dijalankan dengan baik di Chrome (Web).
   * Query pencarian teks dan filter harga dijalankan secara efisien dengan indeks pada kolom harga dan teks pencarian.
3. **Usability (Kemudahan Penggunaan):**
   * Antarmuka bersih, cepat dimuat, minim distraksi, tanpa iklan, dan navigasi intuitif.
   * Input nomor WhatsApp fleksibel dan ramah pengguna dengan sanitasi otomatis.
4. **Batas Waktu (Time-to-Market):**
   * Pengerjaan seluruh modul inti selesai dalam rentang waktu 2 minggu kalender.

---

## 7. Rencana Pemotongan Fitur (Slices / Tahapan Implementasi)

* **Slice 1 — Fondasi Proyek & Backend:**
  * Inisialisasi Supabase client di Flutter.
  * Pembuatan tabel data kos di Supabase PostgreSQL beserta RLS policies.
  * Konfigurasi environment aman (`.env` diabaikan oleh Git).
* **Slice 2 — Autentikasi & Manajemen Kos Pemilik (CRUD):**
  * Halaman Register, Login, dan Logout untuk pemilik kos.
  * Halaman Dashboard / Daftar Kos Saya.
  * Form Tambah Kos, Ubah Kos, dan Hapus Kos dengan konfirmasi & validasi input (termasuk validasi nomor WA dan batas teks fasilitas).
* **Slice 3 — Eksplorasi Publik & Kontak (Guest Mode):**
  * Halaman Beranda publik menampilkan daftar kartu kos rapi (urutan `created_at DESC`, fasilitas dipotong *ellipsis* maks 2 baris).
  * Halaman Detail Kos dengan seluruh informasi teks.
  * Tombol aksi WhatsApp (sanitasi ke format `https://wa.me/62...`) dan Panggilan Telepon.
* **Slice 4 — Pencarian & Filter Harga:**
  * Search bar teks untuk nama kos dan lokasi.
  * Filter modal / bottom sheet untuk rentang harga (minimum dan maksimum).
* **Slice 5 — Ketersediaan Kamar (Bonus / Penyempurnaan):**
  * Toggle status ketersediaan ("Tersedia" / "Penuh") pada halaman manajemen pemilik.
  * Badge visual "Penuh" pada kartu kos dan halaman detail untuk kos yang tidak lagi tersedia tanpa mengubah posisi urutan daftar.

---

## 8. Keputusan Teknis & Aturan Validasi Khusus (Final)

Empat keputusan teknis dan aturan bisnis spesifik yang telah ditetapkan:

1. **Format Input & Sanitasi Nomor WhatsApp:**
   * **Input Form:** Menerima format lokal (`08...`) maupun internasional (`628...`).
   * **Validasi Form:** Hanya karakter numerik, panjang antara 10 hingga 15 digit.
   * **Penyimpanan Database:** Disimpan dalam format lokal standar (`08...`). Jika pengguna memasukkan awalan `62`, aplikasi mengonversi awalannya menjadi `0` saat disimpan.
   * **Pembuatan Tautan URL:** Sanitasi otomatis saat membentuk tautan aksi: jika diawali `0`, diubah menjadi `62`; jika sudah `62`, dipertahankan. Hasil akhir URL selalu mengarah ke `https://wa.me/62...`.

2. **Urutan Tampilan Default Daftar Kos:**
   * Daftar kos di beranda publik diurutkan berdasarkan `created_at DESC` (listing paling baru berada di urutan teratas).
   * Tidak ada tombol/fitur pengurutan (*sorting*) tambahan di V1.

3. **Batas Karakter & Tampilan Deskripsi Fasilitas:**
   * **Panjang Karakter:** Minimal 1 karakter (wajib diisi), maksimal 200 karakter.
   * **Validasi:** Divalidasi langsung pada form penambahan dan pengubahan kos.
   * **Tampilan Kartu Beranda:** Jika teks fasilitas melebihi 2 baris pada kartu kos, teks dipotong rapi dengan elipsis (*text-overflow: ellipsis*, `maxLines: 2`). Teks fasilitas penuh tetap dapat dibaca di Halaman Detail Kos.

4. **Penanganan Kos "Penuh" pada Urutan Daftar:**
   * Kos dengan status kamar "Penuh" tetap berada pada posisi urutan normalnya (`created_at DESC`), tidak dipindahkan ke urutan paling bawah.
   * Kartu kos dan halaman detail kos "Penuh" wajib menampilkan badge/label visual yang jelas bertuliskan **"Penuh"**.
   * Status ketersediaan kamar masuk ke ruang lingkup **Slice 5 (bonus)**, dengan kolom database yang sudah disiapkan sejak awal.
