# Alang Motor

Aplikasi Android Flutter offline untuk kalkulasi mesin dan motor berdasarkan formula workbook `CR DCR CAM BALANCING updated jan2024-1.xlsx` dan `speed-2-1.xlsx`.

## Modul aplikasi

- **CR / DCR** — kapasitas mesin, compression ratio, dynamic compression ratio, volume gasket, dan deck clearance.
- **Cam Balancing** — Actual Data, Balancing IVC, Balancing LSA, dan tabel Cam Pairing.
- **Speed by RPM** — rasio primary, gear, sprocket, ukuran ban, RPM akhir, dan estimasi kecepatan.
- **Power & Torque** — konversi torsi, torque ratio, HP, torsi, dan balance factor.
- **RPM by Intake Valve** — luas valve, diameter ekuivalen, lift valve, stroke total, dan RPM.
- **Karburator & Throttle Body** — diameter ekuivalen, estimasi ukuran karburator/TB, dan tabel rasio gear LC135 5S–6S.
- **Porting** — diameter port, luas port, tinggi dan lebar port oval.

## Formula workbook

Pemetaan sel dan formula dari sheet `Speed`, `TvsHP`, `RPM`, `karbTB`, dan `Port` tersedia di [docs/speed-2-1-formula-map.md](docs/speed-2-1-formula-map.md). Konstanta workbook seperti `3.14159`, `3.14`, dan `PI()` dipertahankan sesuai formula sumber. Input yang dikosongkan tidak otomatis dianggap nol.

Formula CR/DCR dan Cam Balancing juga ditranskripsikan dari workbook CR/DCR/Cam Balancing. Hasil merupakan alat bantu kalkulasi; verifikasi terhadap pengukuran aktual dan spesifikasi mesin.

## Unduh versi rilis

Buka halaman [GitHub Releases](https://github.com/diycraftchannel83-create/Alang_Motor/releases) untuk mengunduh:
- **APK** — untuk instalasi langsung pada perangkat Android.
- **AAB** — Android App Bundle untuk proses distribusi melalui Google Play Console.
- **SHA256SUMS.txt** — checksum untuk memeriksa integritas unduhan.

Setiap rilis mencantumkan ringkasan fitur, petunjuk file unduhan, catatan penggunaan, serta catatan perubahan otomatis dari commit sejak rilis sebelumnya.

## Membuat rilis baru

Workflow [Build and Publish Android Release](https://github.com/diycraftchannel83-create/Alang_Motor/actions/workflows/release.yml) membangun dan menguji aplikasi, lalu menerbitkan APK, AAB, dan checksum ke GitHub Releases.

1. Buka tab **Actions** pada repository.
2. Pilih **Build and Publish Android Release**.
3. Klik **Run workflow**, lalu masukkan nomor versi tanpa awalan `v`, misalnya `1.0.0`.
4. Jalankan workflow. Jika analisis, pengujian, dan build berhasil, rilis bertag `v1.0.0` akan dibuat beserta APK, AAB, dan release notes.
5. Untuk versi berikutnya, gunakan nomor versi baru. Alternatifnya, push tag seperti `v1.0.1` untuk menjalankan workflow secara otomatis.

## Build dan pengujian lokal

Dengan Flutter SDK terpasang:
```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

Workbook sumber tidak didistribusikan ulang; aplikasi mengimplementasikan formula yang dianalisis dari workbook pengguna.
