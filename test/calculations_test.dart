import 'package:flutter_test/flutter_test.dart';
import 'package:alang_motor/calculations.dart';
import 'package:alang_motor/other_calculations.dart';

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
        boreMm: 65, strokeOriginalMm: 57.8, strokeJackMm: 4.5,
        gasketThicknessMm: 0.5, deckClearanceMm: 0.2,
        headVolumeCc: 14.5, ivcDegrees: 65,
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

  group('speed-2-1.xlsx worksheet formulas', () {
    test('Speed sheet matches workbook reference example', () {
      final result = calculateSpeedSheet({
        'rpm': 9000, 'primary': 24, 'clutchGear': 22,
        'clutchSprocket': 23, 'frontSprocket': 15,
        'rearSprocket': 29, 'gearBox': 69, 'rimInches': 17,
        'tireHeightInches': 2.5,
      });
      expect(result['finalRpm'], closeTo(1548.7908219803144, 1e-8));
      expect(result['rimDiameterMm'], closeTo(431.8, 1e-9));
      expect(result['tireDiameterMm'], closeTo(558.8, 1e-9));
      expect(result['tireCircumferenceMm'], closeTo(1755.520492, 1e-6));
      expect(result['speedKmh'], closeTo(163.13604154847795, 1e-8));
    });

    test('Power and torque sheet matches workbook formulas', () {
      final result = calculatePowerTorqueSheet({
        'hp': 29.27, 'torqueNm': 21.46, 'torqueForHp': 21.46, 'rpmHp': 7000,
        'torqueKg': 22, 'rpmTorque': 8000, 'rod': 55,
        'weight': 118, 'piston': 280,
      });
      expect(result['torqueFtLb'], closeTo(15.828896, 1e-9));
      expect(result['torqueRatio'], closeTo(0.5407890673044073, 1e-9));
      expect(result['calculatedHp'], closeTo(28.602437166793603, 1e-9));
      expect(result['calculatedTorque'], closeTo(28.776, 1e-9));
      expect(result['balanceFactorPercent'], closeTo(51.64179104477612, 1e-9));
    });

    test('RPM by intake valve sheet matches workbook example', () {
      final result = calculateRpmSheet({
        'valveDiameter': 22, 'valveCount': 2, 'bore': 65,
        'strokeJack': 4, 'standardStroke': 58.7,
      });
      expect(result['equivalentValveDiameter'], closeTo(31.11269837220809, 1e-8));
      expect(result['singleValveLift'], closeTo(8.555992052357226, 1e-8));
      expect(result['strokeTotal'], closeTo(66.7, 1e-9));
      expect(result['rpm'], closeTo(7852.338919297746, 1e-8));
    });

    test('carburetor and throttle body sheet matches workbook example', () {
      final result = calculateCarbThrottleSheet({'valveDiameter': 33, 'valveCount': 2});
      expect(result['equivalentValveDiameter'], closeTo(46.66904755831214, 1e-8));
      expect(result['carburetorSize'], closeTo(43.40221422923029, 1e-8));
      expect(result['throttleBodySize'], closeTo(49.00249993622774, 1e-8));
      expect(lc135GearRatios.length, 6);
      expect(lc135GearRatios.last['ratio'], closeTo(21 / 22, 1e-9));
    });

    test('porting sheet matches workbook example', () {
      final result = calculatePortSheet({'engineCc': 180, 'targetRpm': 12000});
      expect(result['portDiameter'], closeTo(37.1806401235912, 1e-8));
      expect(result['portArea'], closeTo(1085.7344210806325, 1e-8));
      expect(result['ovalHeight'], closeTo(23.667614480703485, 1e-8));
      expect(result['ovalWidth'], closeTo(46.38852438217883, 1e-8));
    });

    test('blank input remains blank rather than becoming zero', () {
      expect(calculatePortSheet({'engineCc': null, 'targetRpm': 12000})['portDiameter'], isNull);
      expect(calculateCarbThrottleSheet({'valveDiameter': 33, 'valveCount': null})['carburetorSize'], isNull);
      expect(calculateSpeedSheet({'rpm': null})['speedKmh'], isNull);
    });
  });
}
