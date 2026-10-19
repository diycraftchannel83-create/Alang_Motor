import 'dart:math' as math;

/// Formula-compatible calculations transcribed from the workbook.
class CrDcrInput {
  const CrDcrInput({
    this.cylinders = 1,
    this.boreMm = 65,
    this.strokeOriginalMm = 57.8,
    this.strokeJackMm = 4.5,
    this.gasketThicknessMm = 0,
    this.deckClearanceMm = 0,
    this.headVolumeCc = 14.5,
    this.extraGasketThicknessMm = 0,
    this.ivcDegrees = 65,
  });

  final double cylinders;
  final double boreMm;
  final double strokeOriginalMm;
  final double strokeJackMm;
  final double gasketThicknessMm;
  final double deckClearanceMm;
  final double headVolumeCc;
  final double extraGasketThicknessMm;
  final double ivcDegrees;

  double get strokeMm => (strokeJackMm * 2) + strokeOriginalMm;

  // Excel: HQ3=B6^2; HR3=3.1415/4; HT3=HS3*HR3*HQ3; HS5=HT3/1000
  double get sweptVolumeCc =>
      (3.1415 / 4) * math.pow(boreMm, 2) * strokeMm / 1000;

  // Excel gasket/deck intermediate cells use bore^2 * (pi/4) * thickness / 1000.
  double get gasketVolumeCc =>
      gasketThicknessMm * (3.1415 / 4) * math.pow(boreMm, 2) / 1000;

  double get deckVolumeCc =>
      deckClearanceMm * (3.1415 / 4) * math.pow(boreMm, 2) / 1000;

  // Workbook B24 = (3.1415 * (bore/2)^2 * extra gasket thickness) * 0.001.
  // This is displayed as a separate result and is not added to the workbook CR cell.
  double get extraGasketVolumeCc =>
      3.1415 * math.pow(boreMm / 2, 2) * extraGasketThicknessMm * 0.001;

  // Excel HS26=(HS5+HS15+HT20+B15)/B15
  double get compressionRatio =>
      (sweptVolumeCc + gasketVolumeCc + deckVolumeCc + headVolumeCc) /
      headVolumeCc;

  // Excel HS51=(3.1415 * bore^2 * stroke)/4000
  double get engineCc =>
      (3.1415 * math.pow(boreMm, 2) * strokeMm) / 4000;

  // Excel HR57=HS51/180; HS57=180-IVC; HT57=HS57*HR57
  double get dynamicSweptVolumeCc => (180 - ivcDegrees) * (engineCc / 180);

  // Excel HT61=(HT57+B15)/B15
  double get dynamicCompressionRatio =>
      (dynamicSweptVolumeCc + headVolumeCc) / headVolumeCc;

  Map<String, double> get results => {
        'strokeMm': strokeMm,
        'sweptVolumeCc': sweptVolumeCc,
        'gasketVolumeCc': gasketVolumeCc,
        'deckVolumeCc': deckVolumeCc,
        'extraGasketVolumeCc': extraGasketVolumeCc,
        'engineCc': engineCc,
        'compressionRatio': compressionRatio,
        'dynamicSweptVolumeCc': dynamicSweptVolumeCc,
        'dynamicCompressionRatio': dynamicCompressionRatio,
      };
}

class CamRow {
  const CamRow({
    required this.open,
    required this.close,
    required this.tappet,
    required this.duration,
    required this.lift,
    required this.overlap,
    required this.lsa,
  });

  final double open;
  final double close;
  final double tappet;
  final double duration;
  final double lift;
  final double overlap;
  final double lsa;
}

class CamBalancingResult {
  const CamBalancingResult({
    required this.actualIntake,
    required this.actualExhaust,
    required this.actualLsa,
    required this.ivcIntake,
    required this.ivcExhaust,
    required this.ivcLsa,
    required this.lsaIntake,
    required this.lsaExhaust,
    required this.balancedLsa,
  });

  final CamRow actualIntake;
  final CamRow actualExhaust;
  final double actualLsa;
  final CamRow ivcIntake;
  final CamRow ivcExhaust;
  final double ivcLsa;
  final CamRow lsaIntake;
  final CamRow lsaExhaust;
  final double balancedLsa;
}

CamBalancingResult calculateCamBalancing({
  double intakeOpen = 20,
  double intakeClose = 57,
  double intakeTappet = 0.1,
  double exhaustOpen = 56,
  double exhaustClose = 34,
  double exhaustTappet = 0.08,
}) {
  // Actual Data: E=(open+close)+180; LSA intake=E/2-open; exhaust=E/2-close.
  final iDuration = intakeOpen + intakeClose + 180;
  final eDuration = exhaustOpen + exhaustClose + 180;
  final iLsa = (iDuration / 2) - intakeOpen;
  final eLsa = (eDuration / 2) - exhaustClose;
  final balancedLsa = (iLsa + eLsa) / 2;

  // Balancing IVC: C14=(actual intake close + actual exhaust open)/2.
  final ivcClose = (intakeClose + exhaustOpen) / 2;
  final ivcIntakeOpen = iDuration - (180 + ivcClose);
  final ivcExhaustOpen = ivcClose;
  final ivcExhaustClose = eDuration - (180 + ivcExhaustOpen);
  final ivcIntakeLsa = (iDuration / 2) - ivcIntakeOpen;
  final ivcExhaustLsa = (eDuration / 2) - ivcExhaustClose;
  final ivcBalancedLsa = (ivcIntakeLsa + ivcExhaustLsa) / 2;

  // Balancing LSA: workbook uses the balanced LSA from Actual Data (H9).
  final lsaIntakeOpen = (iDuration / 2) - balancedLsa;
  final lsaIntakeClose = (iDuration - 180) - lsaIntakeOpen;
  final lsaExhaustClose = (eDuration / 2) - balancedLsa;
  final lsaExhaustOpen = (eDuration - 180) - lsaExhaustClose;
  final lsaIntakeLsa = (iDuration / 2) - lsaIntakeOpen;
  final lsaExhaustLsa = (eDuration / 2) - lsaExhaustClose;

  CamRow row(double open, double close, double tappet, double duration,
      double lsa) =>
      CamRow(
        open: open,
        close: close,
        tappet: tappet,
        duration: duration,
        lift: 0, // F/G cells are blank in the workbook, so no derived values.
        overlap: 0,
        lsa: lsa,
      );

  return CamBalancingResult(
    actualIntake:
        row(intakeOpen, intakeClose, intakeTappet, iDuration, iLsa),
    actualExhaust:
        row(exhaustOpen, exhaustClose, exhaustTappet, eDuration, eLsa),
    actualLsa: (iLsa + eLsa) / 2,
    ivcIntake: row(
        ivcIntakeOpen, ivcClose, intakeTappet, iDuration, ivcIntakeLsa),
    ivcExhaust: row(
        ivcExhaustOpen, ivcExhaustClose, exhaustTappet, eDuration, ivcExhaustLsa),
    ivcLsa: ivcBalancedLsa,
    lsaIntake: row(
        lsaIntakeOpen, lsaIntakeClose, intakeTappet, iDuration, lsaIntakeLsa),
    lsaExhaust: row(
        lsaExhaustOpen, lsaExhaustClose, exhaustTappet, eDuration, lsaExhaustLsa),
    balancedLsa: (lsaIntakeLsa + lsaExhaustLsa) / 2,
  );
}

/// Workbook's Cam Pairing table: intake open starts at 0 and close at 30;
/// each subsequent row increments both by 5 degrees.
List<Map<String, double>> camPairingRows({int count = 11}) => List.generate(
      count,
      (i) {
        final open = i * 5.0;
        final close = 30 + i * 5.0;
        return {
          'open': open,
          'close': close,
          'duration': open + close,
          'degree': open + close + 180,
        };
      },
    );
