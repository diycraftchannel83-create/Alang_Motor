import 'package:flutter/material.dart';
import 'other_calculations.dart';

/// A reusable worksheet-style page. Blank input values stay blank and
/// suppress dependent outputs instead of silently substituting zero.
class FormulaSheetPage extends StatefulWidget {
  const FormulaSheetPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.inputs,
    required this.calculate,
    required this.outputs,
    this.showGearTable = false,
  });

  final String title;
  final String subtitle;
  final Map<String, String> inputs;
  final SheetValues Function(SheetValues) calculate;
  final Map<String, String> outputs;
  final bool showGearTable;

  @override
  State<FormulaSheetPage> createState() => _FormulaSheetPageState();
}

class _FormulaSheetPageState extends State<FormulaSheetPage> {
  late final Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = widget.inputs.map(
      (key, value) => MapEntry(key, TextEditingController(text: value)),
    );
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  SheetValues get values => {
        for (final entry in controllers.entries)
          entry.key: entry.value.text.trim().isEmpty
              ? null
              : double.tryParse(entry.value.text.trim().replaceAll(',', '.')),
      };

  @override
  Widget build(BuildContext context) {
    final result = widget.calculate(values);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF176B45), Color(0xFF249568)],
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.title,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(widget.subtitle, style: const TextStyle(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('INPUT WORKSHEET', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Row(children: [
                Icon(Icons.edit, size: 16, color: Color(0xFF176B45)),
                SizedBox(width: 6),
                Expanded(child: Text('Biru = sel input yang dapat diedit', style: TextStyle(fontSize: 12, color: Color(0xFF176B45)))),
              ]),
              const SizedBox(height: 12),
              for (final entry in controllers.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: entry.value,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: entry.key,
                      filled: true,
                      fillColor: const Color(0xFFE1F2FF),
                      prefixIcon: const Icon(Icons.edit, size: 18, color: Color(0xFF176B45)),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
            ]),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 4, top: 6, bottom: 6),
          child: Text('HASIL FORMULA EXCEL', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        for (final entry in widget.outputs.entries)
          Card(
            child: ListTile(
              title: Text(entry.value, style: const TextStyle(fontSize: 13)),
              trailing: Text(
                result[entry.key] == null ? '—' : _fmt(result[entry.key]!),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        if (widget.showGearTable) ...[
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('LC135 5S → 6S — REFERENSI RASIO GIGI',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Row(children: [
                  Expanded(child: Text('Gigi')),
                  Expanded(child: Text('Input')),
                  Expanded(child: Text('Output')),
                  Expanded(child: Text('Ratio')),
                ]),
                const Divider(),
                for (final row in lc135GearRatios)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      Expanded(child: Text(row['gear'].toString())),
                      Expanded(child: Text(_fmt(row['input'] as double))),
                      Expanded(child: Text(_fmt(row['output'] as double))),
                      Expanded(child: Text(_fmt(row['ratio'] as double))),
                    ]),
                  ),
              ]),
            ),
          ),
        ],
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'Penanda warna biru hanya diterapkan pada field yang didefinisikan sebagai input untuk sheet ini. Hasil formula ditampilkan terpisah dan tidak dapat diedit. Formula ditranskripsikan dari sheet Excel. Nilai input yang dikosongkan tidak dianggap 0; hasil yang bergantung padanya ditampilkan sebagai —.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

String _fmt(double value) =>
    value.isFinite ? value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '') : '—';

class SpeedSheetPage extends StatelessWidget {
  const SpeedSheetPage({super.key});
  @override
  Widget build(BuildContext context) => const FormulaSheetPage(
        title: 'Speed by RPM',
        subtitle: 'Rasio primary, gear, sprocket, diameter tayar dan kelajuan',
        inputs: {
          'rpm': '9000', 'primary': '24', 'clutchGear': '22',
          'clutchSprocket': '23', 'frontSprocket': '15',
          'rearSprocket': '29', 'gearBox': '69', 'rimInches': '17',
          'tireHeightInches': '2.5',
        },
        calculate: calculateSpeedSheet,
        outputs: {
          'ratioPrimaryClutch': 'Ratio primary / gear klac',
          'ratioClutchSprocket': 'Ratio gear klac / spoket',
          'ratioFrontRear': 'Ratio spoket depan / belakang',
          'finalRpm': 'RPM akhir selepas nisbah gear',
          'rimDiameterMm': 'Diameter rim (mm)',
          'tireDiameterMm': 'Diameter rim + tayar (mm)',
          'tireCircumferenceMm': 'Ukurlilit tayar (mm)',
          'tireRpmMmSec': 'Kelajuan putaran tayar (mm/s)',
          'speedKmh': 'Kelajuan (km/j)',
        },
      );
}

class PowerTorquePage extends StatelessWidget {
  const PowerTorquePage({super.key});
  @override
  Widget build(BuildContext context) => const FormulaSheetPage(
        title: 'Power & Torque',
        subtitle: 'HP, torque ratio, conversion ft.lb, torque dan balance factor',
        inputs: {
          'hp': '29.27', 'torqueNm': '21.46', 'torqueForHp': '21.46', 'rpmHp': '7000',
          'torqueKg': '22', 'rpmTorque': '8000', 'rod': '55',
          'weight': '118', 'piston': '280',
        },
        calculate: calculatePowerTorqueSheet,
        outputs: {
          'torqueFtLb': 'Torque (ft.lb)',
          'torqueRatio': 'Torque ratio',
          'calculatedHp': 'HP dari torque × RPM / 5252',
          'calculatedTorque': 'Torque formula (N.m)',
          'balanceFactorPercent': 'Balance factor (%)',
        },
      );
}

class RpmSheetPage extends StatelessWidget {
  const RpmSheetPage({super.key});
  @override
  Widget build(BuildContext context) => const FormulaSheetPage(
        title: 'RPM by Intake Valve',
        subtitle: 'Ukuran valve intake, jumlah valve, bore dan stroke',
        inputs: {
          'valveDiameter': '22', 'valveCount': '2', 'bore': '65',
          'strokeJack': '4', 'standardStroke': '58.7',
        },
        calculate: calculateRpmSheet,
        outputs: {
          'equivalentValveDiameter': 'Diameter ekuivalen 1 valve (mm)',
          'singleValveLift': 'Lift valve (mm)',
          'strokeTotal': 'Stroke total (mm)',
          'singleValveArea': 'Luas 1 valve (mm²)',
          'totalValveArea': 'Total luas valve (mm²)',
          'rpm': 'RPM hasil formula Excel',
        },
      );
}

class CarbThrottlePage extends StatelessWidget {
  const CarbThrottlePage({super.key});
  @override
  Widget build(BuildContext context) => const FormulaSheetPage(
        title: 'Karburator & Throttle Body',
        subtitle: 'Menghitung diameter ekuivalen, ukuran karburator dan TB',
        inputs: {'valveDiameter': '33', 'valveCount': '2'},
        calculate: calculateCarbThrottleSheet,
        outputs: {
          'equivalentValveDiameter': 'Diameter ekuivalen valve (mm)',
          'carburetorSize': 'Ukuran karburator (mm)',
          'throttleBodySize': 'Ukuran throttle body (mm)',
        },
        showGearTable: true,
      );
}

class PortSheetPage extends StatelessWidget {
  const PortSheetPage({super.key});
  @override
  Widget build(BuildContext context) => const FormulaSheetPage(
        title: 'Formula Saiz Porting',
        subtitle: 'Diameter port, luas port, tinggi dan lebar port oval',
        inputs: {'engineCc': '180', 'targetRpm': '12000'},
        calculate: calculatePortSheet,
        outputs: {
          'portDiameter': 'Besar port (mm)',
          'portArea': 'Luas port (mm²)',
          'ovalHeight': 'Besar port oval — tinggi (mm)',
          'ovalWidth': 'Besar port oval — lebar (mm)',
        },
      );
}
