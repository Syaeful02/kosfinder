# AGENTS.md — Aturan Kerja Agen AI

Dokumen ini berisi panduan, konvensi, dan batasan kerja bagi agen AI yang berkontribusi pada pengembangan repositori **KosFinder / KostFinder**. Seluruh instruksi dalam dokumen ini bersifat mengikat dan wajib dipatuhi.

---

## 1. Konteks Proyek & Dokumen Acuan

**KosFinder** adalah platform pencarian kos yang transparan, ringan, dan bebas iklan untuk mahasiswa serta pekerja di Singaraja, sekaligus sarana promosi online yang mudah dan mandiri bagi pemilik kos.

Setiap agen AI wajib membaca, memahami, dan merujuk ke dokumen-dokumen utama proyek berikut:

* **`docs/PRD.md`**: Spesifikasi produk, peran pengguna (*guest* vs *authenticated owner*), batasan ruang lingkup (*in-scope* dan *out-of-scope*), skema data PostgreSQL, aturan validasi, dan alur aplikasi.
* **`docs/ARCHITECTURE.md`**: Arsitektur teknis, struktur folder/layering, manajemen state, pola repository/service, serta konvensi kode.
* **`docs/TASKS.md`**: Backlog task, pembagian *slice*, status pengerjaan, dan daftar ID task yang menjadi acuan setiap pengerjaan fitur/perbaikan.

---

## 2. Cara Kerja Agen AI

1. **Satu Task Per Permintaan:**
   * Kerjakan hanya **1 task** dalam setiap permintaan atau sesi interaksi. Selesaikan task tersebut secara tuntas sebelum berpindah ke task lain.
2. **Batasan File (Scope Isolation):**
   * **Jangan mengubah file di luar lingkup task** yang sedang dikerjakan.
   * Hindari refactoring liar, formatting ulang file lain yang tidak terkait, atau perubahan sampingan yang tidak diminta.
3. **Perencanaan untuk Perubahan Besar:**
   * Untuk perubahan arsitektural, modifikasi skema data, atau refactoring skala besar, susun dan sampaikan rencana kerja (*action plan*) terlebih dahulu kepada pengguna untuk disetujui sebelum menulis atau mengubah kode.
4. **Pilih Solusi Paling Sederhana (KISS & YAGNI):**
   * Prioritaskan solusi yang paling sederhana, langsung, mudah dibaca, dan mudah dipelihara. Hindari *over-engineering* atau abstraksi prematur.
5. **Manajemen Package / Dependency:**
   * **DILARANG menambah atau memperbarui package/dependency** di `pubspec.yaml` tanpa persetujuan eksplisit dari pengguna.

---

## 3. Teknologi & Stack

* **Frontend / Framework:** Flutter (Dart)
* **State Management:** Provider
* **Backend / Database:** Supabase (PostgreSQL Database, Supabase Auth, Row Level Security)

---

## 4. Keamanan (Security Rules)

1. **Tanpa Kredensial di Kode:**
   * **Tidak ada API key rahasia, token, atau password yang boleh ditulis langsung di dalam kode (*hardcoded*)**.
   * Gunakan konfigurasi lingkungan (*environment variables* atau file `.env` yang terdaftar di `.gitignore`).
2. **Larangan `service_role` Key:**
   * Kunci `service_role` Supabase **TIDAK PERNAH** boleh dipakai atau dimasukkan ke dalam aplikasi klien Flutter. Aplikasi klien hanya boleh menggunakan public `anon` key.
3. **Penegakan Hak Akses via Database (RLS):**
   * Hak akses dan otorisasi data (Read, Insert, Update, Delete) **wajib ditegakkan di level database melalui Row Level Security (RLS)** di Supabase, bukan hanya mengandalkan logika atau menyembunyikan tombol di antarmuka (UI).

---

## 5. Standar Git & Version Control

1. **Satu Task Satu Commit:**
   * Setiap penyelesaian satu task harus dibungkus dalam **satu commit** (*atomic commit*).
2. **Format Pesan Commit:**
   * Pesan commit **wajib menyebutkan ID task** yang relevan dari `docs/TASKS.md`.
   * Contoh format:
     * `feat: [TASK-01] inisialisasi integrasi supabase auth`
     * `fix: [TASK-04] validasi nomor whatsapp pemilik kos`
     * `test: [TASK-06] unit test model listing kos`

---

## 6. Definition of Done (DoD)

Sebuah task baru dinyatakan selesai (*Done*) jika seluruh kriteria berikut terpenuhi:

- [ ] **`flutter analyze` bersih**: Tidak ada error dan tidak menghasilkan linting warning baru.
- [ ] **`flutter test` lulus**: Seluruh unit test dan widget test berhasil dijalankan tanpa kegagalan.
- [ ] **Aplikasi dijalankan di device**: Fungsionalitas task telah diuji coba langsung pada device atau emulator.
- [ ] **Laporan pengujian transparan**: Agen AI wajib mendokumentasikan apa saja yang sudah diuji serta secara jujur **melaporkan apa saja skenario atau bagian yang belum diuji**.

---

## 7. Ketentuan Halaman About

Di halaman **About** (Tentang Aplikasi), wajib mencantumkan identitas pengembang/pemilik proyek dengan format:

```text
2415051059 - Syaeful Darmawan
```
