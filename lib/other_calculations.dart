import 'dart:math' as math;

/// Formula transcription from the workbook speed-2-1.xlsx.
/// Inputs are nullable so an empty Excel input remains empty, not zero.
typedef SheetValues = Map<String, double?>;

double? _v(SheetValues x, String key) => x[key];
double? _div(double? a, double? b) =>
    a == null || b == null || b == 0 ? null : a / b;

/// Sheet: Speed. Uses the original workbook constants 25.4, 3.14159,
/// 1,000,000 and 3,600 exactly as written.
SheetValues calculateSpeedSheet(SheetValues x) {
  final rpm = _v(x, 'rpm');
  final primary = _v(x, 'primary');
  final clutchGear = _v(x, 'clutchGear');
  final clutchSprocket = _v(x, 'clutchSprocket');
  final frontSprocket = _v(x, 'frontSprocket');
  final rearSprocket = _v(x, 'rearSprocket');
  final rimInches = _v(x, 'rimInches');
  final tireHeightInches = _v(x, 'tireHeightInches');
  final gearBox = _v(x, 'gearBox');
  final w8 = rpm;
  final w9 = _div(primary, gearBox);
  final w10 = _div(clutchGear, clutchSprocket);
  final w11 = _div(frontSprocket, rearSprocket);
  final finalRpm = (w8 == null || w9 == null || w10 == null || w11 == null)
      ? null
      : w8 * w9 * w10 * w11;
  final rimMm = rimInches == null ? null : rimInches * 25.4;
  final tireDiameter = rimMm == null || tireHeightInches == null
      ? null
      : ((tireHeightInches * 2) * 25.4) + rimMm;
  final circumference = tireDiameter == null
      ? null
      : (tireDiameter / 2) * 3.14159 * 2;
  final tireRpmMmSec =
      finalRpm == null || circumference == null ? null : (finalRpm / 60) * circumference;
  final speedKmh = tireRpmMmSec == null
      ? null
      : tireRpmMmSec / 1000000 * 3600;
  return {
    'ratioPrimaryClutch': w9,
    'ratioClutchSprocket': w10,
    'ratioFrontRear': w11,
    'finalRpm': finalRpm,
    'rimDiameterMm': rimMm,
    'tireDiameterMm': tireDiameter,
    'tireCircumferenceMm': circumference,
    'tireRpmMmSec': tireRpmMmSec,
    'speedKmh': speedKmh,
  };
}

/// Sheet: TvsHP. The constants (5252, 9.81, 60) match the source cells V2,
/// V10 and V11. Torque conversion constant 0.7376 is also preserved.
SheetValues calculatePowerTorqueSheet(SheetValues x) {
  final hp = _v(x, 'hp');
  final torqueNm = _v(x, 'torqueNm');
  final torqueForHp = _v(x, 'torqueForHp');
  final rpmHp = _v(x, 'rpmHp');
  final torqueKg = _v(x, 'torqueKg');
  final rpmTorque = _v(x, 'rpmTorque');
  final rod = _v(x, 'rod');
  final weight = _v(x, 'weight');
  final piston = _v(x, 'piston');
  final torqueFtLb = torqueNm == null ? null : torqueNm * 0.7376;
  final torqueRatio = _div(torqueFtLb, hp);
  final calculatedHp = (torqueForHp == null || rpmHp == null)
      ? null
      : (torqueForHp * rpmHp) / 5252;
  final calculatedTorque = (torqueKg == null || rpmTorque == null)
      ? null
      : (torqueKg / 1000) * 9.81 * (rpmTorque / 60);
  final balanceFactor = (rod == null || weight == null || piston == null)
      ? null
      : _div(rod + weight, rod + piston) == null
          ? null
          : ((rod + weight) / (rod + piston)) * 100;
  return {
    'torqueFtLb': torqueFtLb,
    'torqueRatio': torqueRatio,
    'calculatedHp': calculatedHp,
    'calculatedTorque': calculatedTorque,
    'balanceFactorPercent': balanceFactor,
  };
}

/// Sheet: RPM. Replicates helper-cell formulas Z8:Z21, including 3.14159
/// and the workbook multiplier 2,286,000.
SheetValues calculateRpmSheet(SheetValues x) {
  final valveDiameter = _v(x, 'valveDiameter');
  final valveCount = _v(x, 'valveCount');
  final bore = _v(x, 'bore');
  final jack = _v(x, 'strokeJack');
  final standardStroke = _v(x, 'standardStroke');
  if ([valveDiameter, valveCount, bore, jack, standardStroke].contains(null)) {
    return {
      'equivalentValveDiameter': null, 'singleValveLift': null,
      'strokeTotal': null, 'rpm': null, 'singleValveArea': null,
      'totalValveArea': null,
    };
  }
  final radiusSquared = math.pow(valveDiameter! / 2, 2).toDouble();
  final singleArea = radiusSquared * 3.14159;
  final totalArea = singleArea * valveCount!;
  final areaDivPi = totalArea / 3.14159;
  final equivalentDiameter = math.sqrt(areaDivPi) * 2;
  final stroke = standardStroke! + (jack! * 2);
  final rpmNumerator = (equivalentDiameter * equivalentDiameter) * 2286000;
  final rpmDenominator = (bore! * bore) * stroke;
  return {
    'equivalentValveDiameter': equivalentDiameter,
    'singleValveLift': equivalentDiameter * 0.275,
    'strokeTotal': stroke,
    'rpm': _div(rpmNumerator, rpmDenominator),
    'singleValveArea': singleArea,
    'totalValveArea': totalArea,
  };
}

/// Sheet: karbTB. The original 3.14 approximations are intentionally kept.
SheetValues calculateCarbThrottleSheet(SheetValues x) {
  final valveDiameter = _v(x, 'valveDiameter');
  final valveCount = _v(x, 'valveCount');
  if (valveDiameter == null || valveCount == null) {
    return {'equivalentValveDiameter': null, 'carburetorSize': null, 'throttleBodySize': null};
  }
  final radiusSquared = math.pow(valveDiameter / 2, 2).toDouble();
  final singleArea = radiusSquared * 3.14;
  final totalArea = singleArea * valveCount;
  final areaDivPi = totalArea / 3.14;
  final equivalentDiameter = math.sqrt(areaDivPi) * 2;
  return {
    'equivalentValveDiameter': equivalentDiameter,
    'carburetorSize': equivalentDiameter * 0.93,
    'throttleBodySize': equivalentDiameter * 1.05,
  };
}

/// Sheet: Port. Preserves Excel PI() for port area, but 3.14 in the
/// subsequent oval-height calculation, matching the original mixed constants.
SheetValues calculatePortSheet(SheetValues x) {
  final engineCc = _v(x, 'engineCc');
  final targetRpm = _v(x, 'targetRpm');
  if (engineCc == null || targetRpm == null) {
    return {'portDiameter': null, 'portArea': null, 'ovalHeight': null, 'ovalWidth': null};
  }
  final displacementLitres = engineCc / 1000;
  final targetProduct = displacementLitres * targetRpm;
  final root = math.pow(targetProduct, 0.5).toDouble();
  final diameter = root * 0.8;
  final area = math.pi * diameter / 2 * diameter / 2;
  final areaHalf = area / 2;
  final ovalHeight = math.sqrt(areaHalf / 3.14) * 2;
  final ovalHeightOutput = ovalHeight * 0.9;
  final ovalWidth = ovalHeightOutput * 2 * 0.98;
  return {
    'portDiameter': diameter,
    'portArea': area,
    'ovalHeight': ovalHeightOutput,
    'ovalWidth': ovalWidth,
  };
}

/// Static gear reference table from rows 27-32 of the karbTB sheet.
const lc135GearRatios = <Map<String, Object>>[
  {'gear': '1st', 'input': 13.0, 'output': 34.0, 'ratio': 34.0 / 13.0},
  {'gear': '2nd', 'input': 14.0, 'output': 25.0, 'ratio': 25.0 / 14.0},
  {'gear': '3th', 'input': 19.0, 'output': 26.0, 'ratio': 26.0 / 19.0},
  {'gear': '4th', 'input': 21.0, 'output': 25.0, 'ratio': 25.0 / 21.0},
  {'gear': '5th', 'input': 21.0, 'output': 22.0, 'ratio': 22.0 / 21.0},
  {'gear': '6th', 'input': 22.0, 'output': 21.0, 'ratio': 21.0 / 22.0},
];
