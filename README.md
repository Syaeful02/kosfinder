# KosFinder

KosFinder membantu mahasiswa dan pekerja mencari kos di Singaraja. Pencari dapat melihat daftar kos sebagai Guest, mencari dan memfilter harga, membuka detail, serta menghubungi pemilik. Pemilik dapat mengelola listing setelah login.

## Prasyarat

- Flutter SDK dan Android SDK terpasang.
- URL project Supabase dan **anon/public key** tersedia.

Jangan gunakan `service_role` key di aplikasi klien. Nilai `--dart-define` akan disertakan di binary; ganti placeholder sebelum menjalankan atau membangun aplikasi, dan jangan commit nilai kredensial.

## Menjalankan aplikasi

Dari root project, unduh dependensi lalu jalankan:

```powershell
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

Ganti kedua placeholder dengan URL project dan anon/public key Supabase Anda.

## Build APK rilis

Jalankan perintah berikut setelah mengganti placeholder dengan nilai milik Anda:

```powershell
flutter build apk --release --build-name=0.1.0 --build-number=1 --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

APK yang dihasilkan berada di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Pastikan APK dibangun ulang dengan konfigurasi Supabase yang benar sebelum dibagikan. Jangan unggah APK yang dibangun memakai placeholder.

## GitHub Release

Setelah build berhasil dan working tree siap dirilis, buat serta dorong tag:

```powershell
git status --short
git tag -a v0.1.0 -m "KosFinder v0.1.0"
git push origin v0.1.0
```

Dengan GitHub CLI (`gh auth login` sudah dilakukan), unggah APK sebagai GitHub Release:

```powershell
gh release create v0.1.0 build/app/outputs/flutter-apk/app-release.apk --title "KosFinder v0.1.0" --notes "Rilis awal KosFinder."
```

Alternatifnya, buka halaman **Releases** repositori di GitHub, pilih **Draft a new release**, pilih tag `v0.1.0`, lalu unggah `app-release.apk` sebagai binary asset dan publikasikan.
