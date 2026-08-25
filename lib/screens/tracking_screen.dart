import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'entry_detail_screen.dart';

class _TrendBar {
  final String label;
  final int pct;
  final Color bg;
  final Color fg;
  const _TrendBar(this.label, this.pct, this.bg, this.fg);
}

final Map<String, List<_TrendBar>> _trendBars = {
  'animo': [
    _TrendBar('feliz', 38, AppColors.amberBg, AppColors.amberFg),
    _TrendBar('tranquilo', 31, AppColors.tealBg, AppColors.tealFg),
    _TrendBar('neutral', 15, AppColors.grayBg, AppColors.grayFg),
    _TrendBar('triste', 10, AppColors.blueBg, AppColors.blueFg),
    _TrendBar('irritado', 6, AppColors.coralBg, AppColors.coralFg),
  ],
  'sueno': [
    _TrendBar('alto', 44, AppColors.tealBg, AppColors.tealFg),
    _TrendBar('medio', 33, AppColors.grayBg, AppColors.grayFg),
    _TrendBar('bajo', 23, AppColors.coralBg, AppColors.coralFg),
  ],
  'energia': [
    _TrendBar('alta', 40, AppColors.tealBg, AppColors.tealFg),
    _TrendBar('media', 35, AppColors.grayBg, AppColors.grayFg),
    _TrendBar('baja', 25, AppColors.coralBg, AppColors.coralFg),
  ],
  'libido': [
    _TrendBar('alta', 28, AppColors.tealBg, AppColors.tealFg),
    _TrendBar('media', 47, AppColors.grayBg, AppColors.grayFg),
    _TrendBar('baja', 25, AppColors.coralBg, AppColors.coralFg),
  ],
  'ejercicio': [
    _TrendBar('sí', 64, AppColors.greenBg, AppColors.greenFg),
    _TrendBar('no', 36, AppColors.redBg, AppColors.redFg),
  ],
  'hidratacion': [
    _TrendBar('alta', 40, AppColors.greenBg, AppColors.greenFg),
    _TrendBar('media', 35, AppColors.amberBg, AppColors.amberFg),
    _TrendBar('baja', 25, AppColors.redBg, AppColors.redFg),
  ],
  'estres': [
    _TrendBar('bajo', 35, AppColors.greenBg, AppColors.greenFg),
    _TrendBar('medio', 45, AppColors.amberBg, AppColors.amberFg),
    _TrendBar('alto', 20, AppColors.redBg, AppColors.redFg),
  ],
};

const Map<String, String> _labels = {
  'animo': 'ánimo', 'sueno': 'sueño', 'energia': 'energía', 'libido': 'líbido',
  'ejercicio': 'ejercicio', 'hidratacion': 'hidratación', 'estres': 'estrés',
};

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String trendKey = 'animo';
  String crossA = 'sueno';
  String crossB = 'libido';

  int _hash(String a, String b) {
    final s = a + b;
    var h = 0;
    for (final c in s.codeUnits) {
      h = (h * 31 + c) % 100;
    }
    return h;
  }

  void _pickCross(bool isA) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: fieldDefs.values
              .map((f) => ListTile(
                    leading: Icon(f.icon, size: 18),
                    title: Text(f.label),
                    onTap: () {
                      setState(() {
                        if (isA) {
                          crossA = f.key;
                        } else {
                          crossB = f.key;
                        }
                      });
                      Navigator.pop(ctx);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pct = 55 + _hash(crossA, crossB) % 35;

    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [Icon(Icons.local_fire_department, size: 14), SizedBox(width: 4), Text('Racha', style: TextStyle(fontSize: 11, color: Colors.grey))]),
                        const Text('5 días', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                        Row(children: const [Icon(Icons.arrow_upward, size: 12, color: AppColors.success), Text(' +2 vs mes pasado', style: TextStyle(fontSize: 10, color: AppColors.success))]),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Entradas', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const Text('47', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                        Row(children: const [Icon(Icons.arrow_downward, size: 12, color: AppColors.danger), Text(' -3 vs mes pasado', style: TextStyle(fontSize: 10, color: AppColors.danger))]),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.bgAccent, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                const Text('Tu palabra del mes', style: TextStyle(fontSize: 10, color: AppColors.accent)),
                const Text('proyecto', style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: AppColors.accent)),
                const Text('mencionada 9 veces', style: TextStyle(fontSize: 10, color: AppColors.accent)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('Tus rachas', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: app.habits
                .map((h) => Chip(avatar: const Icon(Icons.local_fire_department, size: 14), label: Text(h['name'] as String, style: const TextStyle(fontSize: 12))))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text('Tendencias', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: fieldDefs.values.map((f) {
              final selected = trendKey == f.key;
              return GestureDetector(
                onTap: () => setState(() => trendKey = f.key),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EFE8),
                    borderRadius: BorderRadius.circular(10),
                    border: selected ? Border.all(color: AppColors.accent, width: 1.5) : null,
                  ),
                  child: Icon(f.icon, size: 15, color: Colors.grey.shade700),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          ..._trendBars[trendKey]!.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 56, child: Text(b.label, style: const TextStyle(fontSize: 11, color: Colors.grey))),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: b.pct / 100, minHeight: 12, backgroundColor: const Color(0xFFF1EFE8), color: b.fg),
                      ),
                    ),
                    SizedBox(width: 34, child: Text('${b.pct}%', textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: Colors.grey))),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          const Text('Cruza dos campos', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => _pickCross(true),
                child: CircleAvatar(radius: 16, backgroundColor: const Color(0xFFF1EFE8), child: Icon(fieldDefs[crossA]!.icon, size: 15, color: Colors.grey.shade700)),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey)),
              GestureDetector(
                onTap: () => _pickCross(false),
                child: CircleAvatar(radius: 16, backgroundColor: const Color(0xFFF1EFE8), child: Icon(fieldDefs[crossB]!.icon, size: 15, color: Colors.grey.shade700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Los días con ${_labels[crossA]} alto, tu ${_labels[crossB]} también es alto el $pct% de las veces.',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Días destacados', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.amberBg, child: Icon(Icons.sentiment_very_satisfied, color: AppColors.amberFg, size: 16)),
              title: const Text('22 de agosto · tu mejor día', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              subtitle: const Text('Ánimo alto, buen sueño y mucha energía', style: TextStyle(fontSize: 11)),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EntryDetailScreen(date: DateTime.now()))),
            ),
          ),
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.blueBg, child: Icon(Icons.sentiment_dissatisfied, color: AppColors.blueFg, size: 16)),
              title: const Text('8 de agosto · día más difícil', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              subtitle: const Text('Poco sueño y ánimo bajo', style: TextStyle(fontSize: 11)),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EntryDetailScreen(date: DateTime.now()))),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Patrones automáticos', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.bgAccent, borderRadius: BorderRadius.circular(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 15, color: AppColors.accent),
                const SizedBox(width: 8),
                Expanded(child: Text('Los días que duermes menos de 6h sueles marcar el ánimo más bajo. Se repite 6 de las últimas 8 veces.', style: TextStyle(fontSize: 11, color: AppColors.accent))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Tareas', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [Text('Completadas este mes', style: TextStyle(fontSize: 12, color: Colors.grey)), Spacer(), Text('72%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]),
                  const SizedBox(height: 6),
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: const LinearProgressIndicator(value: 0.72, minHeight: 6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
