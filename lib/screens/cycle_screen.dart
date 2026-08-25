import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

class CycleScreen extends StatelessWidget {
  const CycleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final starts = app.cyclePeriodDays.toList()..sort();
    final mostRecentStart = starts.isNotEmpty ? starts.first : 1;
    var cycleDay = ((22 - mostRecentStart) % app.cycleAvgLen) + 1;
    if (cycleDay < 1) cycleDay += app.cycleAvgLen;
    final phase = cycleDay <= app.cyclePeriodLen
        ? 'Fase menstrual'
        : cycleDay <= 13
            ? 'Fase folicular'
            : cycleDay <= 16
                ? 'Ovulación'
                : 'Fase lútea';

    return Scaffold(
      appBar: AppBar(title: const Text('Ciclo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.redBg, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Text('Día $cycleDay', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.redFg)),
                const SizedBox(height: 4),
                Text(phase, style: const TextStyle(fontSize: 12, color: AppColors.redFg)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(children: const [Text('Agosto 2026', style: TextStyle(fontSize: 12, color: Colors.grey)), Spacer(), Text('Toca un día para marcar periodo', style: TextStyle(fontSize: 11, color: Colors.grey))]),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 31,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 5, crossAxisSpacing: 5, childAspectRatio: 1),
            itemBuilder: (ctx, i) {
              final day = i + 1;
              final isPeriod = app.cyclePeriodDays.contains(day);
              return GestureDetector(
                onTap: () => app.togglePeriodDay(day),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isPeriod ? AppColors.redBg : Colors.transparent,
                    border: isPeriod ? null : Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('$day', style: TextStyle(fontSize: 11, color: isPeriod ? AppColors.redFg : Colors.grey)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
