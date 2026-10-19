import 'package:flutter_test/flutter_test.dart';
import 'package:alang_motor/calculations.dart';

void main() {
  group('CR/DCR workbook reference values', () {
    test('matches stored Excel example for default inputs', () {
      const input = CrDcrInput();
      expect(input.strokeMm, closeTo(66.8, 1e-9));
      expect(input.engineCc, closeTo(221.65638625, 1e-7));
      expect(input.compressionRatio, closeTo(16.286647327586206, 1e-9));
      expect(input.dynamicCompressionRatio, closeTo(10.766469125957853, 1e-9));
      expect(input.extraGasketVolumeCc, closeTo(0, 1e-12));
    });

    test('keeps workbook gasket and deck intermediate formulas', () {
      const input = CrDcrInput(
        boreMm: 65,
        strokeOriginalMm: 57.8,
        strokeJackMm: 4.5,
        gasketThicknessMm: 0.5,
        deckClearanceMm: 0.2,
        headVolumeCc: 14.5,
        ivcDegrees: 65,
      );
      expect(input.gasketVolumeCc, closeTo(1.6591046875, 1e-9));
      expect(input.deckVolumeCc, closeTo(0.663641875, 1e-9));
      expect(input.compressionRatio,
          closeTo((221.65638625 + 1.6591046875 + 0.663641875 + 14.5) / 14.5, 1e-9));
    });
  });

  group('Cam Balancing workbook reference values', () {
    test('matches Actual Data and Balancing IVC/LSA examples', () {
      final r = calculateCamBalancing();
      expect(r.actualIntake.duration, closeTo(257, 1e-9));
      expect(r.actualExhaust.duration, closeTo(270, 1e-9));
      expect(r.actualIntake.lsa, closeTo(108.5, 1e-9));
      expect(r.actualExhaust.lsa, closeTo(101, 1e-9));
      expect(r.actualLsa, closeTo(104.75, 1e-9));
      expect(r.ivcIntake.open, closeTo(20.5, 1e-9));
      expect(r.ivcIntake.close, closeTo(56.5, 1e-9));
      expect(r.ivcExhaust.close, closeTo(33.5, 1e-9));
      expect(r.ivcLsa, closeTo(104.75, 1e-9));
      expect(r.lsaIntake.open, closeTo(23.75, 1e-9));
      expect(r.lsaIntake.close, closeTo(53.25, 1e-9));
      expect(r.lsaExhaust.open, closeTo(59.75, 1e-9));
      expect(r.lsaExhaust.close, closeTo(30.25, 1e-9));
      expect(r.balancedLsa, closeTo(104.75, 1e-9));
    });

    test('Cam Pairing starts with workbook values', () {
      final rows = camPairingRows();
      expect(rows.first['open'], 0);
      expect(rows.first['close'], 30);
      expect(rows.first['duration'], 30);
      expect(rows.first['degree'], 210);
      expect(rows[1]['open'], 5);
      expect(rows.last['open'], 45);
      expect(rows.last['close'], 75);
      expect(rows.last['degree'], 300);
    });
  });
}
