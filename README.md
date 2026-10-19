# Alang Motor

Aplikasi Android Flutter offline untuk kalkulasi CR/DCR mesin 4-tak dan camshaft balancing, berdasarkan formula pada workbook `CR DCR CAM BALANCING updated jan2024-1.xlsx`.

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

## Build APK
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