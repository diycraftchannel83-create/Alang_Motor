# Alang Motor

Aplikasi Android Flutter offline untuk kalkulasi mesin dan motor berdasarkan formula workbook `CR DCR CAM BALANCING updated jan2024-1.xlsx` serta `speed-2-1.xlsx`.

## Modul
- CR/DCR: bore, stroke asal, perubahan stroke, gasket, deck clearance, volume head, IVC, CC, CR, dan DCR.
- Cam Balancing: Actual Data, Balancing IVC, Balancing LSA, dan tabel Cam Pairing.
- Pengujian unit untuk hasil contoh dari workbook.

## Formula workbook yang dipertahankan
- Stroke: `(E8 * 2) + G8`
- CC: `(3.1415 * bore^2 * stroke) / 4000`
- CR: `(CC + volume_gasket + volume_deck + volume_head) / volume_head`, dengan volume gasket/deck mengikuti sel perantara workbook.
- DCR: `((180 - IVC) * (CC / 180) + volume_head) / volume_head`
- Cam durations, LSA, IVC balancing, LSA balancing mengikuti formula sheet `CAM BALANCING`.

Catatan: aplikasi meniru formula workbook, termasuk formula DCR yang digunakan workbook; hasilnya bukan validasi teknis atau rekomendasi tuning mesin.

## Formula map — workbook speed-2-1.xlsx\n\nPemetaan setiap formula dan sel Excel ke hasil di aplikasi tersedia di [docs/speed-2-1-formula-map.md](docs/speed-2-1-formula-map.md). Formula helper, konstanta seperti 3.14159/3.14/PI(), serta rasio gear referensi ikut direplikasi. Input yang dikosongkan tetap kosong dan tidak dianggap sebagai 0.\n\n## Build APK
GitHub Actions workflow `Build Android APK` akan membuat scaffold Android Flutter, menjalankan `flutter analyze`, `flutter test`, lalu membangun APK debug. Unduh APK dari artifact workflow setelah proses berhasil.

## Menjalankan lokal
Dengan Flutter SDK terpasang:
```bash
flutter create --platforms=android --project-name alang_motor .
flutter pub get
flutter analyze
flutter test
flutter run
```

Workbook sumber tidak didistribusikan ulang; implementasi mengacu pada formula yang dianalisis dari file pengguna.