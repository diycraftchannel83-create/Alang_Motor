import 'package:flutter/material.dart';
import 'calculations.dart';
import 'other_sheets.dart';

void main() => runApp(const AlangMotorApp());

class AlangMotorApp extends StatelessWidget {
  const AlangMotorApp({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF176B45);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alang Motor',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const tabs = <Tab>[
      Tab(text: 'CR / DCR'),
      Tab(text: 'Cam'),
      Tab(text: 'Speed'),
      Tab(text: 'Power / Torque'),
      Tab(text: 'RPM Valve'),
      Tab(text: 'Karb / TB'),
      Tab(text: 'Porting'),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(children: [
            Icon(Icons.two_wheeler),
            SizedBox(width: 10),
            Text('Alang Motor', style: TextStyle(fontWeight: FontWeight.w800)),
          ]),
          bottom: const TabBar(
            isScrollable: true,
            tabs: tabs,
          ),
        ),
        body: const TabBarView(
          children: [
            CrDcrPage(),
            CamPage(),
            SpeedSheetPage(),
            PowerTorquePage(),
            RpmSheetPage(),
            CarbThrottlePage(),
            PortSheetPage(),
          ],
        ),
      ),
    );
  }
}

class CrDcrPage extends StatefulWidget {
  const CrDcrPage({super.key});
  @override
  State<CrDcrPage> createState() => _CrDcrPageState();
}

class _CrDcrPageState extends State<CrDcrPage> {
  final formKey = GlobalKey<FormState>();
  final fields = <String, TextEditingController>{
    'Bore (mm)': TextEditingController(text: '65'),
    'Stroke asal (mm)': TextEditingController(text: '57.8'),
    'Stroke jack (mm)': TextEditingController(text: '4.5'),
    'Volume head (cc)': TextEditingController(text: '14.5'),
    'IVC (derajat)': TextEditingController(text: '65'),
  };

  double number(String label) =>
      double.tryParse(fields[label]!.text.replaceAll(',', '.')) ?? 0;

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final input = CrDcrInput(
      boreMm: number('Bore (mm)'),
      strokeOriginalMm: number('Stroke asal (mm)'),
      strokeJackMm: number('Stroke jack (mm)'),
      gasketThicknessMm: 0,
      deckClearanceMm: 0,
      headVolumeCc: number('Volume head (cc)'),
      extraGasketThicknessMm: 0,
      ivcDegrees: number('IVC (derajat)'),
    );
    final r = input.results;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _HeroCard(
          title: 'CR / DCR Calculator',
          subtitle: 'Perhitungan mengikuti formula workbook Excel',
          icon: Icons.speed,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('INPUT MESIN',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  ...fields.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: entry.value,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: false),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFE1F2FF),
                            labelText: entry.key,
                            suffixIcon: IconButton(
                              tooltip: 'Reset ke nilai contoh Excel',
                              onPressed: () {
                                setState(() {
                                  const defaults = {
                                    'Bore (mm)': '65',
                                    'Stroke asal (mm)': '57.8',
                                    'Stroke jack (mm)': '4.5',
                                    'Volume head (cc)': '14.5',
                                    'IVC (derajat)': '65',
                                  };
                                  entry.value.text = defaults[entry.key]!;
                                });
                              },
                              icon: const Icon(Icons.restart_alt),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                            if (n == null || !n.isFinite) return 'Masukkan angka valid';
                            if (n <= 0) {
                              return 'Nilai harus lebih besar dari 0';
                            }
                            if (n < 0) return 'Nilai tidak boleh negatif';
                            return null;
                          },
                        ),
                      )),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.calculate),
                      label: const Text('Hitung ulang'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('HASIL PERHITUNGAN',
            style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        _ResultTile(label: 'Stroke total', value: '${_fmt(r['strokeMm']!)} mm'),
        _ResultTile(label: 'Kapasitas mesin (CC)', value: '${_fmt(r['engineCc']!)} cc', primary: true),
        _ResultTile(label: 'Compression Ratio (CR)', value: '${_fmt(r['compressionRatio']!)} : 1', primary: true),
        _ResultTile(label: 'Dynamic Compression Ratio (DCR)', value: '${_fmt(r['dynamicCompressionRatio']!)} : 1', primary: true),
        _ResultTile(label: 'Volume gasket', value: '${_fmt(r['gasketVolumeCc']!)} cc'),
        _ResultTile(label: 'Volume deck', value: '${_fmt(r['deckVolumeCc']!)} cc'),
        _ResultTile(label: 'Volume gasket tambahan', value: '${_fmt(r['extraGasketVolumeCc']!)} cc'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Mode kompatibilitas Excel: formula DCR dan CR mengikuti workbook sumber. Pastikan satuan input sesuai sebelum memakai hasil untuk keputusan mekanis.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class CamPage extends StatefulWidget {
  const CamPage({super.key});
  @override
  State<CamPage> createState() => _CamPageState();
}

class _CamPageState extends State<CamPage> {
  final controllers = <String, TextEditingController>{
    'Intake open': TextEditingController(text: '20'),
    'Intake close': TextEditingController(text: '57'),
    'Intake tappet': TextEditingController(text: '0.1'),
    'Exhaust open': TextEditingController(text: '56'),
    'Exhaust close': TextEditingController(text: '34'),
    'Exhaust tappet': TextEditingController(text: '0.08'),
  };

  double n(String key) =>
      double.tryParse(controllers[key]!.text.replaceAll(',', '.')) ?? 0;

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = calculateCamBalancing(
      intakeOpen: n('Intake open'),
      intakeClose: n('Intake close'),
      intakeTappet: n('Intake tappet'),
      exhaustOpen: n('Exhaust open'),
      exhaustClose: n('Exhaust close'),
      exhaustTappet: n('Exhaust tappet'),
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _HeroCard(
          title: 'Cam Balancing',
          subtitle: 'Actual Data • Balancing IVC • Balancing LSA',
          icon: Icons.settings_input_component,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DATA CAM AKTUAL',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                ...controllers.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: e.value,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: e.key),
                        onChanged: (_) => setState(() {}),
                      ),
                    )),
              ],
            ),
          ),
        ),
        _CamSection(
          title: 'Actual Data',
          intake: r.actualIntake,
          exhaust: r.actualExhaust,
          balancedLsa: r.actualLsa,
        ),
        _CamSection(
          title: 'Balancing IVC',
          intake: r.ivcIntake,
          exhaust: r.ivcExhaust,
          balancedLsa: r.ivcLsa,
        ),
        _CamSection(
          title: 'Balancing LSA',
          intake: r.lsaIntake,
          exhaust: r.lsaExhaust,
          balancedLsa: r.balancedLsa,
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('CAM PAIRING',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Row(children: [
                Expanded(child: Text('Open')),
                Expanded(child: Text('Close')),
                Expanded(child: Text('Dur')),
                Expanded(child: Text('Degree')),
              ]),
              const Divider(),
              ...camPairingRows().map((row) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      Expanded(child: Text(_fmt(row['open']!))),
                      Expanded(child: Text(_fmt(row['close']!))),
                      Expanded(child: Text(_fmt(row['duration']!))),
                      Expanded(child: Text(_fmt(row['degree']!))),
                    ]),
                  )),
            ]),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Kolom Lift dan Overlap tidak dihitung karena pada workbook sumber sel-selnya kosong.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _CamSection extends StatelessWidget {
  const _CamSection({
    required this.title,
    required this.intake,
    required this.exhaust,
    required this.balancedLsa,
  });
  final String title;
  final CamRow intake;
  final CamRow exhaust;
  final double balancedLsa;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Row(children: [
              Expanded(flex: 2, child: Text('')),
              Expanded(child: Text('Open')),
              Expanded(child: Text('Close')),
              Expanded(child: Text('Dur')),
              Expanded(child: Text('LSA')),
            ]),
            const Divider(),
            _camRow('Intake', intake),
            _camRow('Exhaust', exhaust),
            const Divider(),
            Text('Balanced LSA: ${_fmt(balancedLsa)}°',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
        ),
      );

  Widget _camRow(String label, CamRow row) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(child: Text(_fmt(row.open))),
          Expanded(child: Text(_fmt(row.close))),
          Expanded(child: Text(_fmt(row.duration))),
          Expanded(child: Text(_fmt(row.lsa))),
        ]),
      );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.title, required this.subtitle, required this.icon});
  final String title;
  final String subtitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF176B45), Color(0xFF249568)],
          ),
        ),
        child: Row(children: [
          Icon(icon, color: Colors.white, size: 38),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
            ]),
          ),
        ]),
      );
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.label, required this.value, this.primary = false});
  final String label;
  final String value;
  final bool primary;
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          title: Text(label, style: TextStyle(fontSize: 13, color: primary ? const Color(0xFF176B45) : Colors.black87)),
          trailing: Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: primary ? 17 : 14)),
        ),
      );
}

String _fmt(double value) =>
    value.isFinite ? value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '') : '—';
